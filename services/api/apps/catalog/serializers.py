from decimal import Decimal

from django.db import transaction
from django.db.models import Sum
from rest_framework import serializers

from apps.operations.models import PartyLedgerEntry, StockBalance

from .models import Party, Product, ProductPack


class ProductPackSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductPack
        fields = [
            "id",
            "name",
            "conversion_factor",
            "retail_price_minor",
            "wholesale_price_minor",
            "is_active",
        ]
        read_only_fields = ["id"]

    def validate_conversion_factor(self, value):
        if self.instance and value != self.instance.conversion_factor:
            if (
                self.instance.sale_lines.exists()
                or self.instance.purchase_lines.exists()
                or self.instance.transfer_lines.exists()
            ):
                raise serializers.ValidationError(
                    "A used pack conversion cannot be changed; create a new pack"
                )
        return value


def _stock_quantity(product: Product) -> Decimal:
    total = StockBalance.objects.filter(product=product).aggregate(total=Sum("quantity"))["total"]
    return total if total is not None else Decimal("0")


class ProductSerializer(serializers.ModelSerializer):
    packs = ProductPackSerializer(many=True)
    default_pack_id = serializers.SerializerMethodField()
    stock_quantity = serializers.SerializerMethodField()
    is_low_stock = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            "id",
            "business",
            "name",
            "sku",
            "base_unit",
            "track_inventory",
            "hsn_sac",
            "tax_rate_bps",
            "low_stock_threshold",
            "is_active",
            "default_pack_id",
            "stock_quantity",
            "is_low_stock",
            "packs",
        ]
        read_only_fields = ["id"]

    def get_default_pack_id(self, obj):
        packs = [pack for pack in obj.packs.all() if pack.is_active]
        if not packs:
            return None
        pack = min(packs, key=lambda item: item.conversion_factor)
        return str(pack.id)

    def get_stock_quantity(self, obj):
        annotated = getattr(obj, "_stock_quantity", None)
        value = annotated if annotated is not None else _stock_quantity(obj)
        return str(value)

    def get_is_low_stock(self, obj):
        if not obj.track_inventory:
            return False
        return Decimal(self.get_stock_quantity(obj)) <= obj.low_stock_threshold

    @transaction.atomic
    def create(self, validated_data):
        packs = validated_data.pop("packs")
        product = Product.objects.create(**validated_data)
        for pack in packs:
            ProductPack.objects.create(product=product, **pack)
        return product

    @transaction.atomic
    def update(self, instance, validated_data):
        packs = validated_data.pop("packs", None)
        instance = super().update(instance, validated_data)
        if packs is not None:
            by_id = {str(pack.id): pack for pack in instance.packs.all()}
            for data in packs:
                pack_id = str(data.pop("id", ""))
                if pack_id and pack_id in by_id:
                    serializer = ProductPackSerializer(by_id[pack_id], data=data, partial=True)
                    serializer.is_valid(raise_exception=True)
                    serializer.save()
                else:
                    ProductPack.objects.create(product=instance, **data)
        return instance


class PartySerializer(serializers.ModelSerializer):
    phone = serializers.CharField(source="phone_e164", read_only=True)
    receivable_minor = serializers.SerializerMethodField()
    payable_minor = serializers.SerializerMethodField()

    class Meta:
        model = Party
        fields = [
            "id",
            "business",
            "name",
            "kind",
            "phone_e164",
            "phone",
            "gstin",
            "state_code",
            "address",
            "is_active",
            "receivable_minor",
            "payable_minor",
        ]
        read_only_fields = ["id"]

    def _balance(self, obj, account: str) -> int:
        annotated = getattr(obj, f"_{account.lower()}_minor", None)
        if annotated is not None:
            return int(annotated)
        total = PartyLedgerEntry.objects.filter(party=obj, account=account).aggregate(
            total=Sum("amount_minor")
        )["total"]
        return int(total or 0)

    def get_receivable_minor(self, obj):
        return self._balance(obj, PartyLedgerEntry.Account.RECEIVABLE)

    def get_payable_minor(self, obj):
        return self._balance(obj, PartyLedgerEntry.Account.PAYABLE)
