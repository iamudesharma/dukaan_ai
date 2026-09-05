from decimal import Decimal

from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from apps.catalog.models import Party, Product, ProductPack
from apps.common.models import UUIDModel
from apps.tenancy.models import Business, Location


class DocumentStatus(models.TextChoices):
    DRAFT = "DRAFT", "Draft"
    POSTED = "POSTED", "Posted"
    REVERSED = "REVERSED", "Reversed"


class DocumentSequence(UUIDModel):
    business = models.ForeignKey(Business, on_delete=models.PROTECT)
    scope_key = models.CharField(max_length=80)
    document_type = models.CharField(max_length=20)
    financial_year = models.CharField(max_length=7)
    next_number = models.PositiveBigIntegerField(default=1)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["business", "scope_key", "document_type", "financial_year"],
                name="uniq_document_sequence",
            )
        ]


class PostedDocument(UUIDModel):
    business = models.ForeignKey(Business, on_delete=models.PROTECT)
    location = models.ForeignKey(Location, on_delete=models.PROTECT)
    status = models.CharField(
        max_length=10, choices=DocumentStatus.choices, default=DocumentStatus.POSTED
    )
    number = models.CharField(max_length=48)
    financial_year = models.CharField(max_length=7)
    sequence_number = models.PositiveBigIntegerField()
    document_date = models.DateField()
    posted_at = models.DateTimeField()
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT)
    source = models.CharField(max_length=24, default="API")
    idempotency_key = models.CharField(max_length=128)
    reversal_reason = models.CharField(max_length=240, blank=True)
    reversed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        abstract = True


class Sale(PostedDocument):
    class PriceMode(models.TextChoices):
        RETAIL = "RETAIL", "Retail"
        WHOLESALE = "WHOLESALE", "Wholesale"

    customer = models.ForeignKey(
        Party, null=True, blank=True, on_delete=models.PROTECT, related_name="sales"
    )
    price_mode = models.CharField(
        max_length=10, choices=PriceMode.choices, default=PriceMode.RETAIL
    )
    tax_inclusive = models.BooleanField(default=False)
    seller_name = models.CharField(max_length=200, blank=True)
    seller_gstin = models.CharField(max_length=15, blank=True)
    seller_address = models.TextField(blank=True)
    seller_state_code = models.CharField(max_length=2, blank=True)
    buyer_name = models.CharField(max_length=180, blank=True)
    buyer_gstin = models.CharField(max_length=15, blank=True)
    buyer_state_code = models.CharField(max_length=2, blank=True)
    place_of_supply = models.CharField(max_length=2, blank=True)
    subtotal_minor = models.BigIntegerField(default=0)
    discount_total_minor = models.BigIntegerField(default=0)
    taxable_total_minor = models.BigIntegerField(default=0)
    tax_total_minor = models.BigIntegerField(default=0)
    grand_total_minor = models.BigIntegerField(default=0)
    paid_total_minor = models.BigIntegerField(default=0)
    due_total_minor = models.BigIntegerField(default=0)
    negative_stock_acknowledged = models.BooleanField(default=False)
    negative_stock_reason = models.CharField(max_length=240, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["business", "number"], name="uniq_sale_number"),
            models.UniqueConstraint(
                fields=["business", "created_by", "idempotency_key"],
                name="uniq_sale_idempotency",
            ),
        ]


class SaleLine(UUIDModel):
    sale = models.ForeignKey(Sale, on_delete=models.PROTECT, related_name="lines")
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name="sale_lines")
    pack = models.ForeignKey(ProductPack, on_delete=models.PROTECT, related_name="sale_lines")
    description = models.CharField(max_length=180)
    hsn_sac = models.CharField(max_length=12, blank=True)
    quantity = models.DecimalField(max_digits=18, decimal_places=3)
    conversion_factor = models.DecimalField(max_digits=18, decimal_places=6)
    base_quantity = models.DecimalField(max_digits=18, decimal_places=3)
    unit_price_minor = models.BigIntegerField()
    discount_minor = models.BigIntegerField(default=0)
    taxable_value_minor = models.BigIntegerField()
    tax_rate_bps = models.PositiveIntegerField(
        default=0, validators=[MinValueValidator(0), MaxValueValidator(10000)]
    )
    cgst_amount_minor = models.BigIntegerField(default=0)
    sgst_amount_minor = models.BigIntegerField(default=0)
    igst_amount_minor = models.BigIntegerField(default=0)
    line_total_minor = models.BigIntegerField()


class Purchase(PostedDocument):
    supplier = models.ForeignKey(Party, on_delete=models.PROTECT, related_name="purchases")
    supplier_bill_number = models.CharField(max_length=64, blank=True)
    tax_inclusive = models.BooleanField(default=False)
    seller_name = models.CharField(max_length=180, blank=True)
    seller_gstin = models.CharField(max_length=15, blank=True)
    seller_state_code = models.CharField(max_length=2, blank=True)
    buyer_name = models.CharField(max_length=200, blank=True)
    buyer_gstin = models.CharField(max_length=15, blank=True)
    buyer_state_code = models.CharField(max_length=2, blank=True)
    place_of_supply = models.CharField(max_length=2, blank=True)
    subtotal_minor = models.BigIntegerField(default=0)
    discount_total_minor = models.BigIntegerField(default=0)
    taxable_total_minor = models.BigIntegerField(default=0)
    tax_total_minor = models.BigIntegerField(default=0)
    grand_total_minor = models.BigIntegerField(default=0)
    paid_total_minor = models.BigIntegerField(default=0)
    due_total_minor = models.BigIntegerField(default=0)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["business", "number"], name="uniq_purchase_number"),
            models.UniqueConstraint(
                fields=["business", "created_by", "idempotency_key"],
                name="uniq_purchase_idempotency",
            ),
        ]


class PurchaseLine(UUIDModel):
    purchase = models.ForeignKey(Purchase, on_delete=models.PROTECT, related_name="lines")
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name="purchase_lines")
    pack = models.ForeignKey(ProductPack, on_delete=models.PROTECT, related_name="purchase_lines")
    description = models.CharField(max_length=180)
    hsn_sac = models.CharField(max_length=12, blank=True)
    quantity = models.DecimalField(max_digits=18, decimal_places=3)
    conversion_factor = models.DecimalField(max_digits=18, decimal_places=6)
    base_quantity = models.DecimalField(max_digits=18, decimal_places=3)
    unit_cost_minor = models.BigIntegerField()
    discount_minor = models.BigIntegerField(default=0)
    taxable_value_minor = models.BigIntegerField()
    tax_rate_bps = models.PositiveIntegerField(
        default=0, validators=[MinValueValidator(0), MaxValueValidator(10000)]
    )
    cgst_amount_minor = models.BigIntegerField(default=0)
    sgst_amount_minor = models.BigIntegerField(default=0)
    igst_amount_minor = models.BigIntegerField(default=0)
    line_total_minor = models.BigIntegerField()


class Payment(UUIDModel):
    class Direction(models.TextChoices):
        RECEIPT = "RECEIPT", "Customer receipt"
        PAYMENT = "PAYMENT", "Supplier payment"

    class Method(models.TextChoices):
        CASH = "CASH", "Cash"
        UPI = "UPI", "UPI"
        CARD = "CARD", "Card"
        BANK = "BANK", "Bank transfer"
        OTHER = "OTHER", "Other"

    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="payments")
    location = models.ForeignKey(Location, on_delete=models.PROTECT, related_name="payments")
    party = models.ForeignKey(
        Party,
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        related_name="payments",
    )
    direction = models.CharField(max_length=10, choices=Direction.choices)
    method = models.CharField(max_length=10, choices=Method.choices)
    amount_minor = models.BigIntegerField()
    reference = models.CharField(max_length=120, blank=True)
    note = models.CharField(max_length=240, blank=True)
    payment_date = models.DateField()
    status = models.CharField(
        max_length=10, choices=DocumentStatus.choices, default=DocumentStatus.POSTED
    )
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT)
    source = models.CharField(max_length=24, default="API")
    idempotency_key = models.CharField(max_length=128)
    reversal_reason = models.CharField(max_length=240, blank=True)
    reversed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["business", "created_by", "idempotency_key"],
                name="uniq_payment_idempotency",
            )
        ]


class PaymentAllocation(UUIDModel):
    payment = models.ForeignKey(Payment, on_delete=models.PROTECT, related_name="allocations")
    sale = models.ForeignKey(
        Sale, null=True, blank=True, on_delete=models.PROTECT, related_name="payment_allocations"
    )
    purchase = models.ForeignKey(
        Purchase,
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        related_name="payment_allocations",
    )
    amount_minor = models.BigIntegerField()

    class Meta:
        constraints = [
            models.CheckConstraint(
                condition=(
                    models.Q(sale__isnull=False, purchase__isnull=True)
                    | models.Q(sale__isnull=True, purchase__isnull=False)
                ),
                name="allocation_exactly_one_document",
            )
        ]


class Expense(PostedDocument):
    category = models.CharField(max_length=80)
    payee = models.CharField(max_length=180, blank=True)
    note = models.CharField(max_length=240, blank=True)
    amount_minor = models.BigIntegerField()
    tax_amount_minor = models.BigIntegerField(default=0)
    total_minor = models.BigIntegerField()
    payment_method = models.CharField(max_length=10, choices=Payment.Method.choices)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["business", "number"], name="uniq_expense_number"),
            models.UniqueConstraint(
                fields=["business", "created_by", "idempotency_key"],
                name="uniq_expense_idempotency",
            ),
        ]


class StockBalance(UUIDModel):
    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="stock_balances")
    location = models.ForeignKey(Location, on_delete=models.PROTECT, related_name="stock_balances")
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name="stock_balances")
    quantity = models.DecimalField(max_digits=18, decimal_places=3, default=Decimal("0"))

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["business", "location", "product"], name="uniq_stock_balance"
            )
        ]


class StockMovement(UUIDModel):
    class Type(models.TextChoices):
        OPENING = "OPENING", "Opening stock"
        SALE = "SALE", "Sale"
        SALE_REVERSAL = "SALE_REVERSAL", "Sale reversal"
        PURCHASE = "PURCHASE", "Purchase"
        PURCHASE_REVERSAL = "PURCHASE_REVERSAL", "Purchase reversal"
        ADJUSTMENT = "ADJUSTMENT", "Adjustment"
        TRANSFER_OUT = "TRANSFER_OUT", "Transfer out"
        TRANSFER_IN = "TRANSFER_IN", "Transfer in"
        TRANSFER_REVERSAL = "TRANSFER_REVERSAL", "Transfer reversal"

    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="stock_movements")
    location = models.ForeignKey(Location, on_delete=models.PROTECT, related_name="stock_movements")
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name="stock_movements")
    pack = models.ForeignKey(ProductPack, null=True, blank=True, on_delete=models.PROTECT)
    movement_type = models.CharField(max_length=24, choices=Type.choices)
    quantity = models.DecimalField(max_digits=18, decimal_places=3)
    source_type = models.CharField(max_length=32)
    source_id = models.UUIDField()
    note = models.CharField(max_length=240, blank=True)
    occurred_at = models.DateTimeField()

    class Meta:
        indexes = [models.Index(fields=["business", "location", "product", "occurred_at"])]


class PartyLedgerEntry(UUIDModel):
    class Account(models.TextChoices):
        RECEIVABLE = "RECEIVABLE", "Customer receivable"
        PAYABLE = "PAYABLE", "Supplier payable"

    business = models.ForeignKey(
        Business, on_delete=models.PROTECT, related_name="party_ledger_entries"
    )
    location = models.ForeignKey(
        Location, on_delete=models.PROTECT, related_name="party_ledger_entries"
    )
    party = models.ForeignKey(Party, on_delete=models.PROTECT, related_name="ledger_entries")
    account = models.CharField(max_length=10, choices=Account.choices)
    amount_minor = models.BigIntegerField()
    source_type = models.CharField(max_length=32)
    source_id = models.UUIDField()
    note = models.CharField(max_length=240, blank=True)
    occurred_at = models.DateTimeField()

    class Meta:
        indexes = [models.Index(fields=["business", "party", "account", "occurred_at"])]


class StockTransfer(PostedDocument):
    from_location = models.ForeignKey(
        Location, on_delete=models.PROTECT, related_name="transfers_out"
    )
    to_location = models.ForeignKey(Location, on_delete=models.PROTECT, related_name="transfers_in")
    note = models.CharField(max_length=240, blank=True)
    negative_stock_acknowledged = models.BooleanField(default=False)
    negative_stock_reason = models.CharField(max_length=240, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["business", "number"], name="uniq_transfer_number"),
            models.UniqueConstraint(
                fields=["business", "created_by", "idempotency_key"],
                name="uniq_transfer_idempotency",
            ),
            models.CheckConstraint(
                condition=~models.Q(from_location=models.F("to_location")),
                name="transfer_locations_differ",
            ),
        ]


class StockTransferLine(UUIDModel):
    transfer = models.ForeignKey(StockTransfer, on_delete=models.PROTECT, related_name="lines")
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name="transfer_lines")
    pack = models.ForeignKey(ProductPack, on_delete=models.PROTECT, related_name="transfer_lines")
    quantity = models.DecimalField(max_digits=18, decimal_places=3)
    conversion_factor = models.DecimalField(max_digits=18, decimal_places=6)
    base_quantity = models.DecimalField(max_digits=18, decimal_places=3)
