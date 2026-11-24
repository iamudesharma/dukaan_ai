from django.db import transaction
from rest_framework import serializers

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


class ProductSerializer(serializers.ModelSerializer):
    packs = ProductPackSerializer(many=True)
    stock_quantity = serializers.DecimalField(
        max_digits=18, decimal_places=3, read_only=True, default=None
    )

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
            "stock_quantity",
            "packs",
        ]
        read_only_fields = ["id"]

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
    receivable_minor = serializers.IntegerField(read_only=True, default=0)
    payable_minor = serializers.IntegerField(read_only=True, default=0)

    class Meta:
        model = Party
        fields = [
            "id",
            "business",
            "name",
            "kind",
            "phone_e164",
            "gstin",
            "state_code",
            "address",
            "is_active",
            "receivable_minor",
            "payable_minor",
        ]
        read_only_fields = ["id"]

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if _cashier_context(self.context, instance.business_id):
            data.pop("payable_minor", None)
        return data
