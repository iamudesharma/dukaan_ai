from drf_spectacular.utils import extend_schema_field
from rest_framework import serializers

from apps.catalog.models import Party, Product, ProductPack
from apps.tenancy.models import Business, Location

from .models import (
    Expense,
    PartyLedgerEntry,
    Payment,
    PaymentAllocation,
    Purchase,
    PurchaseLine,
    Sale,
    SaleLine,
    StockMovement,
    StockTransfer,
    StockTransferLine,
)


class SaleLineInputSerializer(serializers.Serializer):
    pack_id = serializers.PrimaryKeyRelatedField(
        source="pack", queryset=ProductPack.objects.select_related("product")
    )
    quantity = serializers.DecimalField(max_digits=18, decimal_places=3)
    unit_price_minor = serializers.IntegerField(min_value=0, required=False)
    discount_minor = serializers.IntegerField(min_value=0, required=False, default=0)


class SaleCreateSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )
    customer_id = serializers.PrimaryKeyRelatedField(
        source="customer",
        queryset=Party.objects.filter(is_active=True),
        required=False,
        allow_null=True,
    )
    invoice_date = serializers.DateField(required=False)
    price_mode = serializers.ChoiceField(
        choices=Sale.PriceMode.choices, default=Sale.PriceMode.RETAIL
    )
    tax_inclusive = serializers.BooleanField(default=False)
    discount_total_minor = serializers.IntegerField(min_value=0, default=0)
    lines = SaleLineInputSerializer(many=True, allow_empty=False)
    paid_amount_minor = serializers.IntegerField(min_value=0, default=0)
    payment_method = serializers.ChoiceField(
        choices=Payment.Method.choices, default=Payment.Method.CASH
    )
    payment_reference = serializers.CharField(max_length=120, required=False, allow_blank=True)
    negative_stock_acknowledged = serializers.BooleanField(default=False)
    negative_stock_reason = serializers.CharField(max_length=240, required=False, allow_blank=True)
    idempotency_key = serializers.CharField(max_length=128)


class SaleLineSerializer(serializers.ModelSerializer):
    pack_name = serializers.CharField(source="pack.name", read_only=True)

    class Meta:
        model = SaleLine
        fields = [
            "id",
            "product",
            "pack",
            "pack_name",
            "description",
            "hsn_sac",
            "quantity",
            "conversion_factor",
            "base_quantity",
            "unit_price_minor",
            "discount_minor",
            "taxable_value_minor",
            "tax_rate_bps",
            "cgst_amount_minor",
            "sgst_amount_minor",
            "igst_amount_minor",
            "line_total_minor",
            "unit_cost_minor",
            "cogs_minor",
            "costing_complete",
        ]


class SaleSerializer(serializers.ModelSerializer):
    lines = SaleLineSerializer(many=True, read_only=True)

    def to_representation(self, instance):
        data = super().to_representation(instance)
        membership = self.context.get("membership")
        if membership is not None and membership.role == "CASHIER":
            for line in data["lines"]:
                line.pop("unit_cost_minor", None)
                line.pop("cogs_minor", None)
                line.pop("costing_complete", None)
        return data

    class Meta:
        model = Sale
        fields = [
            "id",
            "business",
            "location",
            "customer",
            "status",
            "number",
            "financial_year",
            "document_date",
            "price_mode",
            "tax_inclusive",
            "seller_name",
            "seller_gstin",
            "buyer_name",
            "buyer_gstin",
            "place_of_supply",
            "subtotal_minor",
            "discount_total_minor",
            "taxable_total_minor",
            "tax_total_minor",
            "grand_total_minor",
            "paid_total_minor",
            "due_total_minor",
            "negative_stock_acknowledged",
            "negative_stock_reason",
            "source",
            "posted_at",
            "reversal_reason",
            "reversed_at",
            "lines",
        ]


class PurchaseLineInputSerializer(serializers.Serializer):
    pack_id = serializers.PrimaryKeyRelatedField(
        source="pack", queryset=ProductPack.objects.select_related("product")
    )
    quantity = serializers.DecimalField(max_digits=18, decimal_places=3)
    unit_cost_minor = serializers.IntegerField(min_value=0)
    discount_minor = serializers.IntegerField(min_value=0, required=False, default=0)


class PurchaseCreateSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )
    supplier_id = serializers.PrimaryKeyRelatedField(
        source="supplier", queryset=Party.objects.filter(is_active=True)
    )
    purchase_date = serializers.DateField(required=False)
    supplier_bill_number = serializers.CharField(max_length=64, required=False, allow_blank=True)
    tax_inclusive = serializers.BooleanField(default=False)
    discount_total_minor = serializers.IntegerField(min_value=0, default=0)
    lines = PurchaseLineInputSerializer(many=True, allow_empty=False)
    paid_amount_minor = serializers.IntegerField(min_value=0, default=0)
    payment_method = serializers.ChoiceField(
        choices=Payment.Method.choices, default=Payment.Method.CASH
    )
    payment_reference = serializers.CharField(max_length=120, required=False, allow_blank=True)
    idempotency_key = serializers.CharField(max_length=128)


class PurchaseLineSerializer(serializers.ModelSerializer):
    class Meta:
        model = PurchaseLine
        fields = [
            "id",
            "product",
            "pack",
            "description",
            "hsn_sac",
            "quantity",
            "conversion_factor",
            "base_quantity",
            "unit_cost_minor",
            "discount_minor",
            "taxable_value_minor",
            "tax_rate_bps",
            "cgst_amount_minor",
            "sgst_amount_minor",
            "igst_amount_minor",
            "line_total_minor",
        ]


class PurchaseSerializer(serializers.ModelSerializer):
    lines = PurchaseLineSerializer(many=True, read_only=True)

    class Meta:
        model = Purchase
        fields = [
            "id",
            "business",
            "location",
            "supplier",
            "status",
            "number",
            "financial_year",
            "document_date",
            "supplier_bill_number",
            "tax_inclusive",
            "seller_name",
            "seller_gstin",
            "buyer_name",
            "buyer_gstin",
            "place_of_supply",
            "subtotal_minor",
            "discount_total_minor",
            "taxable_total_minor",
            "tax_total_minor",
            "grand_total_minor",
            "paid_total_minor",
            "due_total_minor",
            "source",
            "posted_at",
            "reversal_reason",
            "reversed_at",
            "lines",
        ]


class PaymentCreateSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )
    party_id = serializers.PrimaryKeyRelatedField(
        source="party", queryset=Party.objects.filter(is_active=True)
    )
    direction = serializers.ChoiceField(choices=Payment.Direction.choices)
    method = serializers.ChoiceField(choices=Payment.Method.choices)
    amount_minor = serializers.IntegerField(min_value=1)
    sale_id = serializers.PrimaryKeyRelatedField(
        source="sale", queryset=Sale.objects.all(), required=False, allow_null=True
    )
    purchase_id = serializers.PrimaryKeyRelatedField(
        source="purchase", queryset=Purchase.objects.all(), required=False, allow_null=True
    )
    payment_date = serializers.DateField(required=False)
    reference = serializers.CharField(max_length=120, required=False, allow_blank=True)
    note = serializers.CharField(max_length=240, required=False, allow_blank=True)
    idempotency_key = serializers.CharField(max_length=128)


class PaymentAllocationSerializer(serializers.ModelSerializer):
    document_type = serializers.SerializerMethodField()
    document_id = serializers.SerializerMethodField()
    document_number = serializers.SerializerMethodField()
    document_total_minor = serializers.SerializerMethodField()
    document_paid_total_minor = serializers.SerializerMethodField()
    document_due_total_minor = serializers.SerializerMethodField()

    def _document(self, allocation):
        return allocation.sale or allocation.purchase

    @extend_schema_field({"type": "string", "enum": ["SALE", "PURCHASE"]})
    def get_document_type(self, allocation) -> str:
        return "SALE" if allocation.sale_id else "PURCHASE"

    def get_document_id(self, allocation) -> str | None:
        document = self._document(allocation)
        return str(document.pk) if document else None

    def get_document_number(self, allocation) -> str | None:
        document = self._document(allocation)
        return document.number if document else None

    def get_document_total_minor(self, allocation) -> int | None:
        document = self._document(allocation)
        return document.grand_total_minor if document else None

    def get_document_paid_total_minor(self, allocation) -> int | None:
        document = self._document(allocation)
        return document.paid_total_minor if document else None

    def get_document_due_total_minor(self, allocation) -> int | None:
        document = self._document(allocation)
        return document.due_total_minor if document else None

    class Meta:
        model = PaymentAllocation
        fields = [
            "id",
            "sale",
            "purchase",
            "amount_minor",
            "document_type",
            "document_id",
            "document_number",
            "document_total_minor",
            "document_paid_total_minor",
            "document_due_total_minor",
        ]


class PaymentAllocationInputSerializer(serializers.Serializer):
    amount_minor = serializers.IntegerField(min_value=1)
    sale_id = serializers.UUIDField(required=False, allow_null=True)
    purchase_id = serializers.UUIDField(required=False, allow_null=True)
    document_type = serializers.ChoiceField(
        choices=["SALE", "PURCHASE"], required=False, allow_null=True
    )
    document_id = serializers.UUIDField(required=False, allow_null=True)

    def validate(self, attrs):
        generic = attrs.get("document_type") is not None or attrs.get("document_id") is not None
        direct = attrs.get("sale_id") is not None or attrs.get("purchase_id") is not None
        if generic and direct:
            raise serializers.ValidationError(
                "Use either sale_id/purchase_id or document_type with document_id"
            )
        if generic:
            if not attrs.get("document_type") or not attrs.get("document_id"):
                raise serializers.ValidationError(
                    "document_type and document_id must be supplied together"
                )
            attrs["sale_id" if attrs["document_type"] == "SALE" else "purchase_id"] = attrs.pop(
                "document_id"
            )
            attrs.pop("document_type")
        if bool(attrs.get("sale_id")) == bool(attrs.get("purchase_id")):
            raise serializers.ValidationError("Exactly one sale or purchase document is required")
        return attrs


class PaymentReallocationSerializer(serializers.Serializer):
    allocations = PaymentAllocationInputSerializer(many=True, allow_empty=False)
    reason = serializers.CharField(max_length=240)
    idempotency_key = serializers.CharField(max_length=128)


class PaymentSerializer(serializers.ModelSerializer):
    allocations = PaymentAllocationSerializer(many=True, read_only=True)
    allocated_total_minor = serializers.SerializerMethodField()
    unallocated_total_minor = serializers.SerializerMethodField()

    def get_allocated_total_minor(self, payment) -> int:
        return sum(allocation.amount_minor for allocation in payment.allocations.all())

    def get_unallocated_total_minor(self, payment) -> int:
        return payment.amount_minor - self.get_allocated_total_minor(payment)

    class Meta:
        model = Payment
        fields = [
            "id",
            "business",
            "location",
            "party",
            "direction",
            "method",
            "amount_minor",
            "reference",
            "note",
            "payment_date",
            "status",
            "source",
            "reversal_reason",
            "reversed_at",
            "allocations",
            "allocated_total_minor",
            "unallocated_total_minor",
        ]


class PaymentAllocationTotalsSerializer(serializers.Serializer):
    payment_count = serializers.IntegerField()
    payment_total_minor = serializers.IntegerField()
    allocated_total_minor = serializers.IntegerField()
    unallocated_total_minor = serializers.IntegerField()
    outstanding_document_count = serializers.IntegerField()
    outstanding_total_minor = serializers.IntegerField()


class OutstandingDocumentSerializer(serializers.Serializer):
    document_type = serializers.ChoiceField(choices=["SALE", "PURCHASE"])
    document_id = serializers.UUIDField()
    number = serializers.CharField()
    document_date = serializers.DateField()
    party_id = serializers.UUIDField(allow_null=True)
    party_name = serializers.CharField(allow_null=True)
    grand_total_minor = serializers.IntegerField()
    paid_total_minor = serializers.IntegerField()
    due_total_minor = serializers.IntegerField()


class PaymentAllocationReviewSerializer(serializers.Serializer):
    results = PaymentSerializer(many=True)
    totals = PaymentAllocationTotalsSerializer()
    outstanding_documents = OutstandingDocumentSerializer(many=True)


class ExpenseCreateSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )
    expense_date = serializers.DateField(required=False)
    category = serializers.CharField(max_length=80)
    payee = serializers.CharField(max_length=180, required=False, allow_blank=True)
    note = serializers.CharField(max_length=240, required=False, allow_blank=True)
    amount_minor = serializers.IntegerField(min_value=1)
    tax_amount_minor = serializers.IntegerField(min_value=0, default=0)
    payment_method = serializers.ChoiceField(choices=Payment.Method.choices)
    idempotency_key = serializers.CharField(max_length=128)


class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = [
            "id",
            "business",
            "location",
            "status",
            "number",
            "document_date",
            "category",
            "payee",
            "note",
            "amount_minor",
            "tax_amount_minor",
            "total_minor",
            "payment_method",
            "source",
            "posted_at",
            "reversal_reason",
            "reversed_at",
        ]


class TransferLineInputSerializer(serializers.Serializer):
    pack_id = serializers.PrimaryKeyRelatedField(
        source="pack", queryset=ProductPack.objects.select_related("product")
    )
    quantity = serializers.DecimalField(max_digits=18, decimal_places=3)


class TransferCreateSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    from_location_id = serializers.PrimaryKeyRelatedField(
        source="from_location", queryset=Location.objects.filter(is_active=True)
    )
    to_location_id = serializers.PrimaryKeyRelatedField(
        source="to_location", queryset=Location.objects.filter(is_active=True)
    )
    transfer_date = serializers.DateField(required=False)
    note = serializers.CharField(max_length=240, required=False, allow_blank=True)
    lines = TransferLineInputSerializer(many=True, allow_empty=False)
    negative_stock_acknowledged = serializers.BooleanField(default=False)
    negative_stock_reason = serializers.CharField(max_length=240, required=False, allow_blank=True)
    idempotency_key = serializers.CharField(max_length=128)


class TransferLineSerializer(serializers.ModelSerializer):
    class Meta:
        model = StockTransferLine
        fields = ["id", "product", "pack", "quantity", "conversion_factor", "base_quantity"]


class TransferSerializer(serializers.ModelSerializer):
    lines = TransferLineSerializer(many=True, read_only=True)

    class Meta:
        model = StockTransfer
        fields = [
            "id",
            "business",
            "from_location",
            "to_location",
            "status",
            "number",
            "document_date",
            "note",
            "negative_stock_acknowledged",
            "negative_stock_reason",
            "posted_at",
            "reversal_reason",
            "reversed_at",
            "lines",
        ]


class StockAdjustmentSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )
    product_id = serializers.PrimaryKeyRelatedField(
        source="product", queryset=Product.objects.filter(is_active=True)
    )
    quantity_delta = serializers.DecimalField(max_digits=18, decimal_places=3)
    movement_type = serializers.ChoiceField(
        choices=[StockMovement.Type.OPENING, StockMovement.Type.ADJUSTMENT],
        default=StockMovement.Type.ADJUSTMENT,
    )
    reason = serializers.CharField(max_length=240)
    negative_stock_acknowledged = serializers.BooleanField(default=False)
    idempotency_key = serializers.CharField(max_length=128)


class StockMovementSerializer(serializers.ModelSerializer):
    class Meta:
        model = StockMovement
        fields = [
            "id",
            "business",
            "location",
            "product",
            "pack",
            "movement_type",
            "quantity",
            "source_type",
            "source_id",
            "note",
            "occurred_at",
        ]


class OpeningBalanceCreateSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )
    party_id = serializers.PrimaryKeyRelatedField(
        source="party", queryset=Party.objects.filter(is_active=True)
    )
    account = serializers.ChoiceField(choices=PartyLedgerEntry.Account.choices)
    amount_minor = serializers.IntegerField(min_value=0)
    note = serializers.CharField(max_length=240, required=False, allow_blank=True)
    idempotency_key = serializers.CharField(max_length=128)


class PartyLedgerEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = PartyLedgerEntry
        fields = [
            "id",
            "business",
            "location",
            "party",
            "account",
            "amount_minor",
            "source_type",
            "source_id",
            "note",
            "occurred_at",
        ]


class ReverseSerializer(serializers.Serializer):
    reason = serializers.CharField(max_length=240)
    idempotency_key = serializers.CharField(max_length=128)
    negative_stock_acknowledged = serializers.BooleanField(default=False)


class DashboardTodaySerializer(serializers.Serializer):
    sales_minor = serializers.IntegerField()
    purchases_minor = serializers.IntegerField()
    expenses_minor = serializers.IntegerField()


class DashboardBooksSerializer(serializers.Serializer):
    sales_minor = serializers.IntegerField()
    purchases_minor = serializers.IntegerField()
    expenses_minor = serializers.IntegerField()
    receipts_minor = serializers.IntegerField()
    supplier_payments_minor = serializers.IntegerField()
    receivable_minor = serializers.IntegerField()
    payable_minor = serializers.IntegerField()
    cash_flow_minor = serializers.IntegerField()


class DashboardSerializer(serializers.Serializer):
    business_id = serializers.UUIDField()
    as_of = serializers.DateField()
    today = DashboardTodaySerializer()
    books = DashboardBooksSerializer()
    low_stock_count = serializers.IntegerField()
    # Null means at least one posted line has missing or incomplete costing.
    gross_profit_minor = serializers.IntegerField(allow_null=True)
    summary = serializers.CharField()


class StockReportRowSerializer(serializers.Serializer):
    product_id = serializers.UUIDField()
    name = serializers.CharField()
    unit = serializers.CharField()
    quantity = serializers.DecimalField(max_digits=18, decimal_places=3)
    low_stock_threshold = serializers.DecimalField(max_digits=18, decimal_places=3)
    is_low_stock = serializers.BooleanField()


class StockReportSerializer(serializers.Serializer):
    results = StockReportRowSerializer(many=True)


class SalesMetricsSerializer(serializers.Serializer):
    posted_sale_count = serializers.IntegerField()
    line_count = serializers.IntegerField()
    net_sales_minor = serializers.IntegerField()
    cogs_minor = serializers.IntegerField()
    gross_profit_minor = serializers.IntegerField(allow_null=True)
    missing_cost_line_count = serializers.IntegerField()
    costing_complete = serializers.BooleanField()


class ValuationInventorySerializer(serializers.Serializer):
    total_quantity = serializers.DecimalField(max_digits=18, decimal_places=3)
    average_cost_minor = serializers.IntegerField(allow_null=True)
    total_value_minor = serializers.IntegerField(allow_null=True)
    known_value_minor = serializers.IntegerField()
    costing_complete = serializers.BooleanField()


class ValuationRowSerializer(serializers.Serializer):
    product_id = serializers.UUIDField()
    name = serializers.CharField()
    unit = serializers.CharField()
    quantity = serializers.DecimalField(max_digits=18, decimal_places=3)
    average_cost_minor = serializers.IntegerField(allow_null=True)
    total_value_minor = serializers.IntegerField(allow_null=True)
    known_value_minor = serializers.IntegerField()
    unknown_cost_quantity = serializers.DecimalField(max_digits=18, decimal_places=3)
    costing_complete = serializers.BooleanField()


class ValuationReportSerializer(serializers.Serializer):
    inventory = ValuationInventorySerializer()
    sales = SalesMetricsSerializer()
    results = ValuationRowSerializer(many=True)


class PartyLedgerReportSerializer(serializers.Serializer):
    party_id = serializers.UUIDField()
    balance = serializers.IntegerField()
    entries = PartyLedgerEntrySerializer(many=True)
