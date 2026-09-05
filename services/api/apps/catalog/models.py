from decimal import Decimal

from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from apps.common.models import UUIDModel
from apps.tenancy.models import Business


class Party(UUIDModel):
    class Kind(models.TextChoices):
        CUSTOMER = "CUSTOMER", "Customer"
        SUPPLIER = "SUPPLIER", "Supplier"
        BOTH = "BOTH", "Customer and supplier"

    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="parties")
    name = models.CharField(max_length=180)
    kind = models.CharField(max_length=10, choices=Kind.choices)
    phone_e164 = models.CharField(max_length=20, blank=True)
    gstin = models.CharField(max_length=15, blank=True)
    state_code = models.CharField(max_length=2, blank=True)
    address = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        indexes = [models.Index(fields=["business", "name"])]

    def can_buy(self) -> bool:
        return self.kind in {self.Kind.CUSTOMER, self.Kind.BOTH}

    def can_supply(self) -> bool:
        return self.kind in {self.Kind.SUPPLIER, self.Kind.BOTH}


class Product(UUIDModel):
    class Unit(models.TextChoices):
        PIECE = "PIECE", "Piece"
        KILOGRAM = "KILOGRAM", "Kilogram"
        LITRE = "LITRE", "Litre"
        METRE = "METRE", "Metre"
        SERVICE = "SERVICE", "Service"

    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="products")
    name = models.CharField(max_length=180)
    sku = models.CharField(max_length=64, blank=True)
    base_unit = models.CharField(max_length=12, choices=Unit.choices, default=Unit.PIECE)
    track_inventory = models.BooleanField(default=True)
    hsn_sac = models.CharField(max_length=12, blank=True)
    tax_rate_bps = models.PositiveIntegerField(
        default=0,
        validators=[MinValueValidator(0), MaxValueValidator(10000)],
    )
    low_stock_threshold = models.DecimalField(max_digits=18, decimal_places=3, default=Decimal("0"))
    is_active = models.BooleanField(default=True)

    class Meta:
        indexes = [
            models.Index(fields=["business", "name"]),
            models.Index(fields=["business", "sku"]),
        ]


class ProductPack(UUIDModel):
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name="packs")
    name = models.CharField(max_length=80)
    conversion_factor = models.DecimalField(
        max_digits=18,
        decimal_places=6,
        validators=[MinValueValidator(Decimal("0.000001"))],
    )
    retail_price_minor = models.BigIntegerField(validators=[MinValueValidator(0)])
    wholesale_price_minor = models.BigIntegerField(validators=[MinValueValidator(0)])
    is_active = models.BooleanField(default=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["product", "name"], name="uniq_product_pack_name")
        ]
