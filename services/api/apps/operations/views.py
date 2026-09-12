from decimal import ROUND_HALF_UP, Decimal

from django.db.models import Q, Sum
from django.utils import timezone
from drf_spectacular.utils import extend_schema
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.catalog.models import Product
from apps.tenancy.access import accessible_location_ids, require_membership
from apps.tenancy.models import Membership

from .models import (
    DocumentStatus,
    Expense,
    PartyLedgerEntry,
    Payment,
    Purchase,
    PurchaseLine,
    Sale,
    SaleLine,
    StockBalance,
    StockTransfer,
)
from .serializers import (
    ExpenseCreateSerializer,
    ExpenseSerializer,
    OpeningBalanceCreateSerializer,
    PartyLedgerEntrySerializer,
    PaymentCreateSerializer,
    PaymentSerializer,
    PurchaseCreateSerializer,
    PurchaseSerializer,
    ReverseSerializer,
    SaleCreateSerializer,
    SaleSerializer,
    StockAdjustmentSerializer,
    StockMovementSerializer,
    TransferCreateSerializer,
    TransferSerializer,
)
from .services import (
    post_expense,
    post_opening_balance,
    post_payment,
    post_purchase,
    post_sale,
    post_stock_adjustment,
    post_transfer,
    reverse_expense,
    reverse_payment,
    reverse_purchase,
    reverse_sale,
    reverse_transfer,
)

ZERO = 0


def _payload_with_idempotency(request):
    payload = request.data.copy()
    if "idempotency_key" not in payload and request.headers.get("Idempotency-Key"):
        payload["idempotency_key"] = request.headers["Idempotency-Key"]
    return payload


class PostingViewSet(mixins.ListModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    create_serializer_class = None
    post_service = None
    read_roles = None

    def get_queryset(self):
        return self.queryset.filter(
            business__memberships__user=self.request.user,
            business__memberships__is_active=True,
        ).distinct()

    def _check_object_access(self, instance):
        membership = require_membership(
            self.request.user,
            instance.business_id,
            roles=self.read_roles,
            location_id=instance.location_id,
        )
        if (
            isinstance(instance, Payment)
            and instance.direction == Payment.Direction.PAYMENT
            and membership.role == Membership.Role.CASHIER
        ):
            from rest_framework.exceptions import PermissionDenied

            raise PermissionDenied("Your role cannot view supplier payments")

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        self._check_object_access(instance)
        return Response(self.get_serializer(instance).data)

    def list(self, request, *args, **kwargs):
        business_id = request.query_params.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        membership = require_membership(request.user, business_id, roles=self.read_roles)
        queryset = self.get_queryset().filter(business_id=business_id)
        if self.queryset.model == StockTransfer:
            queryset = queryset.filter(
                from_location_id__in=accessible_location_ids(membership),
                to_location_id__in=accessible_location_ids(membership),
            )
        else:
            queryset = queryset.filter(location_id__in=accessible_location_ids(membership))
        if self.queryset.model == Payment and membership.role == Membership.Role.CASHIER:
            queryset = queryset.filter(direction=Payment.Direction.RECEIPT)
        location_id = request.query_params.get("location_id")
        if location_id:
            require_membership(request.user, business_id, location_id=location_id)
            if self.queryset.model == StockTransfer:
                queryset = queryset.filter(
                    Q(from_location_id=location_id) | Q(to_location_id=location_id)
                )
            else:
                queryset = queryset.filter(location_id=location_id)
        return Response(self.get_serializer(queryset.order_by("-created_at")[:200], many=True).data)

    @extend_schema(request=None, responses=None)
    def create(self, request):
        serializer = self.create_serializer_class(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        instance, replayed = self.post_service(serializer.validated_data, request.user)
        response = Response(
            self.get_serializer(instance).data,
            status=status.HTTP_200_OK if replayed else status.HTTP_201_CREATED,
        )
        response["Idempotent-Replay"] = str(replayed).lower()
        return response


class SaleViewSet(PostingViewSet):
    queryset = Sale.objects.select_related("customer", "location").prefetch_related("lines__pack")
    serializer_class = SaleSerializer
    create_serializer_class = SaleCreateSerializer
    post_service = staticmethod(post_sale)

    @action(detail=True, methods=["post"])
    def reverse(self, request, pk=None):
        sale = self.get_object()
        self._check_object_access(sale)
        serializer = ReverseSerializer(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        values = serializer.validated_data.copy()
        values.pop("negative_stock_acknowledged", None)
        sale, replayed = reverse_sale(sale, request.user, **values)
        return Response(
            SaleSerializer(sale).data,
            status=status.HTTP_200_OK,
            headers={"Idempotent-Replay": str(replayed).lower()},
        )


class PurchaseViewSet(PostingViewSet):
    read_roles = [Membership.Role.OWNER, Membership.Role.MANAGER]
    queryset = Purchase.objects.select_related("supplier", "location").prefetch_related(
        "lines__pack"
    )
    serializer_class = PurchaseSerializer
    create_serializer_class = PurchaseCreateSerializer
    post_service = staticmethod(post_purchase)

    @action(detail=True, methods=["post"])
    def reverse(self, request, pk=None):
        purchase = self.get_object()
        self._check_object_access(purchase)
        serializer = ReverseSerializer(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        purchase, replayed = reverse_purchase(purchase, request.user, **serializer.validated_data)
        return Response(
            PurchaseSerializer(purchase).data, headers={"Idempotent-Replay": str(replayed).lower()}
        )


class PaymentViewSet(PostingViewSet):
    queryset = Payment.objects.select_related("party", "location").prefetch_related("allocations")
    serializer_class = PaymentSerializer
    create_serializer_class = PaymentCreateSerializer
    post_service = staticmethod(post_payment)

    @action(detail=True, methods=["post"])
    def reverse(self, request, pk=None):
        payment = self.get_object()
        self._check_object_access(payment)
        serializer = ReverseSerializer(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        values = serializer.validated_data.copy()
        values.pop("negative_stock_acknowledged", None)
        payment, replayed = reverse_payment(payment, request.user, **values)
        return Response(
            PaymentSerializer(payment).data, headers={"Idempotent-Replay": str(replayed).lower()}
        )


class ExpenseViewSet(PostingViewSet):
    read_roles = [Membership.Role.OWNER, Membership.Role.MANAGER]
    queryset = Expense.objects.select_related("location")
    serializer_class = ExpenseSerializer
    create_serializer_class = ExpenseCreateSerializer
    post_service = staticmethod(post_expense)

    @action(detail=True, methods=["post"])
    def reverse(self, request, pk=None):
        expense = self.get_object()
        self._check_object_access(expense)
        serializer = ReverseSerializer(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        values = serializer.validated_data.copy()
        values.pop("negative_stock_acknowledged", None)
        expense, replayed = reverse_expense(expense, request.user, **values)
        return Response(
            ExpenseSerializer(expense).data, headers={"Idempotent-Replay": str(replayed).lower()}
        )


class TransferViewSet(PostingViewSet):
    read_roles = [Membership.Role.OWNER, Membership.Role.MANAGER]
    queryset = StockTransfer.objects.select_related(
        "from_location", "to_location"
    ).prefetch_related("lines")
    serializer_class = TransferSerializer
    create_serializer_class = TransferCreateSerializer
    post_service = staticmethod(post_transfer)

    def _check_object_access(self, instance):
        require_membership(
            self.request.user, instance.business_id, location_id=instance.from_location_id
        )
        require_membership(
            self.request.user, instance.business_id, location_id=instance.to_location_id
        )

    @action(detail=True, methods=["post"])
    def reverse(self, request, pk=None):
        transfer = self.get_object()
        self._check_object_access(transfer)
        serializer = ReverseSerializer(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        transfer, replayed = reverse_transfer(transfer, request.user, **serializer.validated_data)
        return Response(
            TransferSerializer(transfer).data, headers={"Idempotent-Replay": str(replayed).lower()}
        )


class StockAdjustmentView(APIView):
    def post(self, request):
        serializer = StockAdjustmentSerializer(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        movement, replayed = post_stock_adjustment(serializer.validated_data, request.user)
        return Response(
            StockMovementSerializer(movement).data,
            status=status.HTTP_200_OK if replayed else status.HTTP_201_CREATED,
            headers={"Idempotent-Replay": str(replayed).lower()},
        )


class OpeningBalanceView(APIView):
    def post(self, request):
        serializer = OpeningBalanceCreateSerializer(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        entry, replayed = post_opening_balance(serializer.validated_data, request.user)
        return Response(
            PartyLedgerEntrySerializer(entry).data,
            status=status.HTTP_200_OK if replayed else status.HTTP_201_CREATED,
            headers={"Idempotent-Replay": str(replayed).lower()},
        )


def _report_scope(request):
    business_id = request.query_params.get("business_id")
    if not business_id:
        raise ValidationError("business_id is required")
    membership = require_membership(request.user, business_id)
    location_ids = list(accessible_location_ids(membership))
    location_id = request.query_params.get("location_id")
    if location_id:
        require_membership(request.user, business_id, location_id=location_id)
        location_ids = [location_id]
    return business_id, location_ids


def _inr(minor: int) -> str:
    sign = "-" if minor < 0 else ""
    minor = abs(int(minor))
    return f"{sign}{minor // 100:,}.{minor % 100:02d}"


def _low_stock_count(business_id, location_ids) -> int:
    products = Product.objects.filter(business_id=business_id, is_active=True, track_inventory=True)
    totals = {
        row["product_id"]: row["total"]
        for row in StockBalance.objects.filter(
            business_id=business_id, location_id__in=location_ids
        )
        .values("product_id")
        .annotate(total=Sum("quantity"))
    }
    return sum(
        1 for product in products if (totals.get(product.id) or 0) <= product.low_stock_threshold
    )


def _gross_profit_minor(sales_queryset, business_id) -> int:
    """Revenue less cost of goods sold.

    Cost basis v1: the latest posted purchase cost per product (documented
    approximation until moving weighted-average costing lands). Revenue is the
    taxable value, so GST is not counted as profit."""
    latest_cost: dict = {}
    purchase_lines = (
        PurchaseLine.objects.filter(
            purchase__business_id=business_id,
            purchase__status=DocumentStatus.POSTED,
        )
        .select_related("purchase")
        .order_by("purchase__posted_at")
        .values("product_id", "unit_cost_minor", "conversion_factor")
    )
    for row in purchase_lines:
        factor = row["conversion_factor"]
        if factor:
            latest_cost[row["product_id"]] = Decimal(row["unit_cost_minor"]) / factor
    revenue = sales_queryset.aggregate(total=Sum("taxable_total_minor"))["total"] or 0
    cogs = 0
    for row in SaleLine.objects.filter(sale__in=sales_queryset).values(
        "product_id", "base_quantity"
    ):
        unit_cost = latest_cost.get(row["product_id"])
        if unit_cost is not None:
            cogs += int(
                (row["base_quantity"] * unit_cost).to_integral_value(rounding=ROUND_HALF_UP)
            )
    return int(revenue) - cogs


class DashboardView(APIView):
    def get(self, request):
        business_id, location_ids = _report_scope(request)
        today = timezone.localdate()
        sales = Sale.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=DocumentStatus.POSTED
        )
        purchases = Purchase.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=DocumentStatus.POSTED
        )
        expenses = Expense.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=DocumentStatus.POSTED
        )
        ledger = PartyLedgerEntry.objects.filter(
            business_id=business_id, location_id__in=location_ids
        )
        payments = Payment.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=DocumentStatus.POSTED
        )
        receivable = (
            ledger.filter(account=PartyLedgerEntry.Account.RECEIVABLE).aggregate(
                v=Sum("amount_minor")
            )["v"]
            or 0
        )
        payable = (
            ledger.filter(account=PartyLedgerEntry.Account.PAYABLE).aggregate(
                v=Sum("amount_minor")
            )["v"]
            or 0
        )
        receipts = (
            payments.filter(direction=Payment.Direction.RECEIPT).aggregate(v=Sum("amount_minor"))[
                "v"
            ]
            or 0
        )
        supplier_payments = (
            payments.filter(direction=Payment.Direction.PAYMENT).aggregate(v=Sum("amount_minor"))[
                "v"
            ]
            or 0
        )
        expense_total = expenses.aggregate(v=Sum("total_minor"))["v"] or 0
        sales_today = (
            sales.filter(document_date=today).aggregate(v=Sum("grand_total_minor"))["v"] or 0
        )
        receipts_today = (
            payments.filter(direction=Payment.Direction.RECEIPT, payment_date=today).aggregate(
                v=Sum("amount_minor")
            )["v"]
            or 0
        )
        low_stock_count = _low_stock_count(business_id, location_ids)
        gross_profit = _gross_profit_minor(sales, business_id)
        summary = (
            f"Today: ₹{_inr(sales_today)} sales, ₹{_inr(receipts_today)} collected. "
            f"₹{_inr(receivable)} to collect, ₹{_inr(payable)} to pay."
        )
        return Response(
            {
                "business_id": business_id,
                "as_of": today,
                "today": {
                    "sales": sales_today,
                    "purchases": purchases.filter(document_date=today).aggregate(
                        v=Sum("grand_total_minor")
                    )["v"]
                    or 0,
                    "expenses": expenses.filter(document_date=today).aggregate(
                        v=Sum("total_minor")
                    )["v"]
                    or 0,
                    "receipts": receipts_today,
                },
                "books": {
                    "sales": sales.aggregate(v=Sum("grand_total_minor"))["v"] or 0,
                    "purchases": purchases.aggregate(v=Sum("grand_total_minor"))["v"] or 0,
                    "expenses": expense_total,
                    "receivable": receivable,
                    "payable": payable,
                    "cash_flow": receipts - supplier_payments - expense_total,
                    "receipts": receipts,
                    "payments_out": supplier_payments,
                    "gross_profit_minor": gross_profit,
                },
                "receipts_minor": receipts,
                "low_stock_count": low_stock_count,
                "summary": summary,
            }
        )


class StockReportView(APIView):
    def get(self, request):
        business_id, location_ids = _report_scope(request)
        products = Product.objects.filter(
            business_id=business_id, is_active=True, track_inventory=True
        )
        balances = StockBalance.objects.filter(
            business_id=business_id, location_id__in=location_ids
        )
        by_product = {
            row["product_id"]: row["total"]
            for row in balances.values("product_id").annotate(total=Sum("quantity"))
        }
        rows = []
        for product in products.order_by("name"):
            current = by_product.get(product.id, ZERO)
            rows.append(
                {
                    "product_id": str(product.id),
                    "name": product.name,
                    "unit": product.base_unit,
                    "quantity": current,
                    "low_stock_threshold": product.low_stock_threshold,
                    "is_low_stock": current <= product.low_stock_threshold,
                }
            )
        return Response({"results": rows})


class PartyLedgerReportView(APIView):
    def get(self, request):
        business_id, location_ids = _report_scope(request)
        party_id = request.query_params.get("party_id")
        if not party_id:
            raise ValidationError("party_id is required")
        entries = PartyLedgerEntry.objects.filter(
            business_id=business_id,
            location_id__in=location_ids,
            party_id=party_id,
        ).order_by("occurred_at", "created_at")
        account = request.query_params.get("account")
        if account:
            entries = entries.filter(account=account)
        balance = entries.aggregate(v=Sum("amount_minor"))["v"] or ZERO
        return Response(
            {
                "party_id": party_id,
                "balance": balance,
                "entries": PartyLedgerEntrySerializer(entries[:500], many=True).data,
            }
        )
