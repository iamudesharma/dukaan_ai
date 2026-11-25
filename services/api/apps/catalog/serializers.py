from decimal import Decimal

from django.db import transaction
from django.db.models import Sum
from rest_framework import serializers

from apps.operations.models import PartyLedgerEntry, StockBalance
from apps.tenancy.access import is_cashier
from apps.tenancy.models import Membership

from .models import Party, Product, ProductPack


def _cashier_context(context, business_id) -> bool:
    if business_id is None:
        return False
    membership = context.get("membership")
    if membership is not None and str(membership.business_id) == str(business_id):
        return membership.role == Membership.Role.CASHIER
    request = context.get("request")
    user = getattr(request, "user", None)
    return bool(user and user.is_authenticated and is_cashier(user, business_id))


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

    def to_representation(self, instance):
        data = super().to_representation(instance)
        business_id = self.context.get("business_id") or instance.product.business_id
        if _cashier_context(self.context, business_id):
            data.pop("wholesale_price_minor", None)
        return data

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

    def get_default_pack_id(self, obj) -> str | None:
        packs = [pack for pack in obj.packs.all() if pack.is_active]
        if not packs:
            return None
        pack = min(packs, key=lambda item: item.conversion_factor)
        return str(pack.id)

    def get_stock_quantity(self, obj) -> str:
        annotated = getattr(obj, "_stock_quantity", None)
        value = annotated if annotated is not None else _stock_quantity(obj)
        return str(value)

    def get_is_low_stock(self, obj) -> bool:
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

    def get_receivable_minor(self, obj) -> int:
        return self._balance(obj, PartyLedgerEntry.Account.RECEIVABLE)

    def get_payable_minor(self, obj) -> int:
        return self._balance(obj, PartyLedgerEntry.Account.PAYABLE)

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if _cashier_context(self.context, instance.business_id):
            data.pop("payable_minor", None)
        return data
