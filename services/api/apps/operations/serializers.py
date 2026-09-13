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
        choices=Sale.PriceMode.choices, required=False, allow_null=True
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

    def validate(self, attrs):
        if not attrs.get("price_mode"):
            business = attrs.get("business")
            attrs["price_mode"] = (
                business.default_price_mode
                if business and business.default_price_mode in Sale.PriceMode.values
                else Sale.PriceMode.RETAIL
            )
        return attrs


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
        ]


class SaleSerializer(serializers.ModelSerializer):
    lines = SaleLineSerializer(many=True, read_only=True)
    customer_name = serializers.SerializerMethodField()
    invoice_number = serializers.CharField(source="number", read_only=True)
    occurred_at = serializers.DateTimeField(source="posted_at", read_only=True)

    class Meta:
        model = Sale
        fields = [
            "id",
            "business",
            "location",
            "customer",
            "customer_name",
            "status",
            "number",
            "invoice_number",
            "occurred_at",
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

    def get_customer_name(self, obj):
        if obj.customer_id:
            return obj.customer.name
        return obj.buyer_name


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
    supplier_name = serializers.SerializerMethodField()
    invoice_number = serializers.CharField(source="number", read_only=True)
    occurred_at = serializers.DateTimeField(source="posted_at", read_only=True)

    class Meta:
        model = Purchase
        fields = [
            "id",
            "business",
            "location",
            "supplier",
            "supplier_name",
            "status",
            "number",
            "invoice_number",
            "occurred_at",
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

    def get_supplier_name(self, obj):
        return obj.supplier.name if obj.supplier_id else ""


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
    class Meta:
        model = PaymentAllocation
        fields = ["id", "sale", "purchase", "amount_minor"]


class PaymentSerializer(serializers.ModelSerializer):
    allocations = PaymentAllocationSerializer(many=True, read_only=True)
    party_name = serializers.SerializerMethodField()
    occurred_at = serializers.DateTimeField(source="payment_date", read_only=True)

    class Meta:
        model = Payment
        fields = [
            "id",
            "business",
            "location",
            "party",
            "party_name",
            "direction",
            "method",
            "amount_minor",
            "reference",
            "note",
            "payment_date",
            "occurred_at",
            "status",
            "source",
            "reversal_reason",
            "reversed_at",
            "allocations",
        ]

    def get_party_name(self, obj):
        return obj.party.name if obj.party_id else ""


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
    occurred_at = serializers.DateTimeField(source="posted_at", read_only=True)

    class Meta:
        model = Expense
        fields = [
            "id",
            "business",
            "location",
            "status",
            "number",
            "document_date",
            "occurred_at",
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
