from django.db import transaction
from rest_framework import serializers

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


class ProductSerializer(serializers.ModelSerializer):
    packs = ProductPackSerializer(many=True)

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
        ]
        read_only_fields = ["id"]
