import uuid
from datetime import date
from decimal import Decimal

from django.db.models import Count, DecimalField, F, OuterRef, Q, Subquery, Sum, Value
from django.db.models.functions import Coalesce
from django.utils import timezone
from drf_spectacular.utils import OpenApiParameter, extend_schema, extend_schema_view
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
    Sale,
    SaleLine,
    StockBalance,
    StockTransfer,
)
from .serializers import (
    DashboardSerializer,
    ExpenseCreateSerializer,
    ExpenseSerializer,
    OpeningBalanceCreateSerializer,
    PartyLedgerEntrySerializer,
    PartyLedgerReportSerializer,
    PaymentAllocationReviewSerializer,
    PaymentCreateSerializer,
    PaymentReallocationSerializer,
    PaymentSerializer,
    PurchaseCreateSerializer,
    PurchaseSerializer,
    ReverseSerializer,
    SaleCreateSerializer,
    SaleSerializer,
    StockAdjustmentSerializer,
    StockMovementSerializer,
    StockReportSerializer,
    TransferCreateSerializer,
    TransferSerializer,
    ValuationReportSerializer,
)
from .services import (
    post_expense,
    post_opening_balance,
    post_payment,
    post_purchase,
    post_sale,
    post_stock_adjustment,
    post_transfer,
    reallocate_payment,
    reverse_expense,
    reverse_payment,
    reverse_purchase,
    reverse_sale,
    reverse_transfer,
    weighted_average_unit_cost,
)

ZERO = 0


def _iso(value):
    return value.isoformat() if value is not None else None


def _format_minor(value: int) -> str:
    sign = "-" if value < 0 else ""
    rupees, paise = divmod(abs(value), 100)
    return f"{sign}₹{rupees:,}.{paise:02d}"


def _brief_rows(queryset):
    """Slim list rows for the entries screens: header fields only, no lines.

    Requested with ``?brief=1``. Keys mirror the full serializers so both
    clients parse brief and full rows with the same code. Line items,
    allocations, and audit fields are omitted, which cuts the entries
    payload by roughly an order of magnitude on slow connections.
    """
    model = queryset.model
    if model is Sale:
        queryset = queryset.select_related("customer")
    elif model is Purchase:
        queryset = queryset.select_related("supplier")
    elif model is Payment:
        queryset = queryset.select_related("party")
    rows = []
    for obj in queryset.prefetch_related(None).order_by("-created_at")[:200]:
        if isinstance(obj, Sale):
            row = {
                "id": str(obj.pk),
                "number": obj.number,
                "status": obj.status,
                "grand_total_minor": obj.grand_total_minor,
                "due_total_minor": obj.due_total_minor,
                "invoice_date": _iso(obj.document_date),
                "document_date": _iso(obj.document_date),
                "occurred_at": _iso(obj.posted_at),
                "posted_at": _iso(obj.posted_at),
                "created_at": _iso(obj.created_at),
            }
            if obj.customer is not None:
                row["customer"] = {"name": obj.customer.name}
        elif isinstance(obj, Purchase):
            row = {
                "id": str(obj.pk),
                "number": obj.number,
                "status": obj.status,
                "grand_total_minor": obj.grand_total_minor,
                "due_total_minor": obj.due_total_minor,
                "invoice_date": _iso(obj.document_date),
                "document_date": _iso(obj.document_date),
                "occurred_at": _iso(obj.posted_at),
                "posted_at": _iso(obj.posted_at),
                "created_at": _iso(obj.created_at),
            }
            if obj.supplier is not None:
                row["supplier"] = {"name": obj.supplier.name}
        elif isinstance(obj, Payment):
            row = {
                "id": str(obj.pk),
                "reference": obj.reference,
                "status": obj.status,
                "direction": obj.direction,
                "method": obj.method,
                "amount_minor": obj.amount_minor,
                "invoice_date": _iso(obj.payment_date),
                "payment_date": _iso(obj.payment_date),
                "occurred_at": _iso(obj.payment_date),
                "created_at": _iso(obj.created_at),
            }
            if obj.party is not None:
                row["party"] = {"name": obj.party.name}
        elif isinstance(obj, Expense):
            row = {
                "id": str(obj.pk),
                "number": obj.number,
                "status": obj.status,
                "category": obj.category,
                "total_minor": obj.total_minor,
                "invoice_date": _iso(obj.document_date),
                "document_date": _iso(obj.document_date),
                "occurred_at": _iso(obj.posted_at),
                "posted_at": _iso(obj.posted_at),
                "created_at": _iso(obj.created_at),
            }
            if obj.payee:
                row["party_name"] = obj.payee
        else:
            row = {
                "id": str(obj.pk),
                "number": obj.number,
                "status": obj.status,
                "note": obj.note,
                "invoice_date": _iso(obj.document_date),
                "document_date": _iso(obj.document_date),
                "occurred_at": _iso(obj.posted_at),
                "posted_at": _iso(obj.posted_at),
                "created_at": _iso(obj.created_at),
            }
        rows.append(row)
    return rows


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

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["membership"] = getattr(self, "_membership", None)
        return context

    def _check_object_access(self, instance):
        membership = require_membership(
            self.request.user,
            instance.business_id,
            roles=self.read_roles,
            location_id=instance.location_id,
        )
        self._membership = membership
        if (
            isinstance(instance, Payment)
            and instance.direction == Payment.Direction.PAYMENT
            and membership.role == Membership.Role.CASHIER
        ):
            from rest_framework.exceptions import PermissionDenied

            raise PermissionDenied("Your role cannot view supplier payments")
        return membership

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        self._check_object_access(instance)
        return Response(self.get_serializer(instance).data)

    @extend_schema(
        description=(
            "List up to 200 posted records. Set brief=1 to omit lines, allocations, "
            "and audit fields from the rows."
        ),
        parameters=[
            OpenApiParameter(
                name="business_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=True,
            ),
            OpenApiParameter(
                name="location_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=False,
            ),
            OpenApiParameter(
                name="brief", type=bool, location=OpenApiParameter.QUERY, required=False
            ),
        ],
    )
    def list(self, request, *args, **kwargs):
        business_id = request.query_params.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        membership = require_membership(request.user, business_id, roles=self.read_roles)
        self._membership = membership
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
        if request.query_params.get("brief") == "1":
            return Response(_brief_rows(queryset))
        return Response(self.get_serializer(queryset.order_by("-created_at")[:200], many=True).data)

    def create(self, request):
        serializer = self.create_serializer_class(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        instance, replayed = self.post_service(serializer.validated_data, request.user)
        self._membership = require_membership(
            request.user, instance.business_id, location_id=instance.location_id
        )
        response = Response(
            self.get_serializer(instance).data,
            status=status.HTTP_200_OK if replayed else status.HTTP_201_CREATED,
        )
        response["Idempotent-Replay"] = str(replayed).lower()
        return response


@extend_schema_view(
    create=extend_schema(
        request=SaleCreateSerializer,
        responses={200: SaleSerializer, 201: SaleSerializer},
    )
)
class SaleViewSet(PostingViewSet):
    queryset = Sale.objects.select_related("customer", "location").prefetch_related("lines__pack")
    serializer_class = SaleSerializer
    create_serializer_class = SaleCreateSerializer
    post_service = staticmethod(post_sale)

    @extend_schema(request=ReverseSerializer, responses=SaleSerializer)
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


@extend_schema_view(
    create=extend_schema(
        request=PurchaseCreateSerializer,
        responses={200: PurchaseSerializer, 201: PurchaseSerializer},
    )
)
class PurchaseViewSet(PostingViewSet):
    read_roles = [Membership.Role.OWNER, Membership.Role.MANAGER]
    queryset = Purchase.objects.select_related("supplier", "location").prefetch_related(
        "lines__pack"
    )
    serializer_class = PurchaseSerializer
    create_serializer_class = PurchaseCreateSerializer
    post_service = staticmethod(post_purchase)

    @extend_schema(request=ReverseSerializer, responses=PurchaseSerializer)
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


@extend_schema_view(
    create=extend_schema(
        request=PaymentCreateSerializer,
        responses={200: PaymentSerializer, 201: PaymentSerializer},
    )
)
class PaymentViewSet(PostingViewSet):
    queryset = Payment.objects.select_related("party", "location").prefetch_related(
        "allocations__sale", "allocations__purchase"
    )
    serializer_class = PaymentSerializer
    create_serializer_class = PaymentCreateSerializer
    post_service = staticmethod(post_payment)

    @extend_schema(
        operation_id="payments_allocation_review_list",
        summary="Review payment allocations and outstanding documents",
        parameters=[
            OpenApiParameter(
                name="business_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=True,
            ),
            OpenApiParameter(
                name="location_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=False,
            ),
            OpenApiParameter(
                name="party_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=False,
            ),
            OpenApiParameter(
                name="direction",
                type=str,
                location=OpenApiParameter.QUERY,
                required=False,
                enum=Payment.Direction.values,
            ),
            OpenApiParameter(
                name="status",
                type=str,
                location=OpenApiParameter.QUERY,
                required=False,
                enum=DocumentStatus.values,
                default=DocumentStatus.POSTED,
            ),
        ],
        responses=PaymentAllocationReviewSerializer,
    )
    @action(detail=False, methods=["get"], url_path="allocation-review")
    def allocation_review(self, request):
        business_id = request.query_params.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        membership = require_membership(
            request.user,
            business_id,
            roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        )
        self._membership = membership
        location_ids = list(accessible_location_ids(membership))
        location_id = request.query_params.get("location_id")
        if location_id:
            require_membership(request.user, business_id, location_id=location_id)
            location_ids = [location_id]
        payments = self.get_queryset().filter(business_id=business_id, location_id__in=location_ids)
        direction = request.query_params.get("direction")
        if direction:
            if direction not in Payment.Direction.values:
                raise ValidationError("Invalid payment direction")
            payments = payments.filter(direction=direction)
        party_id = request.query_params.get("party_id")
        if party_id:
            payments = payments.filter(party_id=party_id)
        payment_status = request.query_params.get("status", DocumentStatus.POSTED)
        if payment_status not in DocumentStatus.values:
            raise ValidationError("Invalid payment status")
        payments = payments.filter(status=payment_status).order_by("-created_at")[:200]
        rows = self.get_serializer(payments, many=True).data

        outstanding = []
        sale_scope = dict(
            business_id=business_id,
            location_id__in=location_ids,
            status=DocumentStatus.POSTED,
            due_total_minor__gt=0,
        )
        purchase_scope = dict(sale_scope)
        if party_id:
            sale_scope["customer_id"] = party_id
            purchase_scope["supplier_id"] = party_id
        if direction in {None, Payment.Direction.RECEIPT}:
            for sale in (
                Sale.objects.filter(**sale_scope)
                .select_related("customer")
                .order_by("document_date", "number")[:500]
            ):
                outstanding.append(
                    {
                        "document_type": "SALE",
                        "document_id": str(sale.pk),
                        "number": sale.number,
                        "document_date": sale.document_date,
                        "party_id": str(sale.customer_id) if sale.customer_id else None,
                        "party_name": sale.customer.name if sale.customer else None,
                        "grand_total_minor": sale.grand_total_minor,
                        "paid_total_minor": sale.paid_total_minor,
                        "due_total_minor": sale.due_total_minor,
                    }
                )
        if direction in {None, Payment.Direction.PAYMENT}:
            for purchase in (
                Purchase.objects.filter(**purchase_scope)
                .select_related("supplier")
                .order_by("document_date", "number")[:500]
            ):
                outstanding.append(
                    {
                        "document_type": "PURCHASE",
                        "document_id": str(purchase.pk),
                        "number": purchase.number,
                        "document_date": purchase.document_date,
                        "party_id": str(purchase.supplier_id),
                        "party_name": purchase.supplier.name,
                        "grand_total_minor": purchase.grand_total_minor,
                        "paid_total_minor": purchase.paid_total_minor,
                        "due_total_minor": purchase.due_total_minor,
                    }
                )
        return Response(
            {
                "results": rows,
                "totals": {
                    "payment_count": len(rows),
                    "payment_total_minor": sum(row["amount_minor"] for row in rows),
                    "allocated_total_minor": sum(row["allocated_total_minor"] for row in rows),
                    "unallocated_total_minor": sum(row["unallocated_total_minor"] for row in rows),
                    "outstanding_document_count": len(outstanding),
                    "outstanding_total_minor": sum(
                        document["due_total_minor"] for document in outstanding
                    ),
                },
                "outstanding_documents": outstanding,
            }
        )

    @extend_schema(
        operation_id="payments_reallocate_create",
        summary="Replace a payment's document allocations",
        request=PaymentReallocationSerializer,
        responses=PaymentSerializer,
    )
    @action(detail=True, methods=["post"], url_path="reallocate")
    def reallocate(self, request, pk=None):
        payment = self.get_object()
        self._check_object_access(payment)
        serializer = PaymentReallocationSerializer(data=_payload_with_idempotency(request))
        serializer.is_valid(raise_exception=True)
        values = serializer.validated_data
        payment, replayed = reallocate_payment(
            payment,
            values["allocations"],
            request.user,
            reason=values["reason"],
            idempotency_key=values["idempotency_key"],
        )
        return Response(
            self.get_serializer(payment).data,
            headers={"Idempotent-Replay": str(replayed).lower()},
        )

    @extend_schema(request=ReverseSerializer, responses=PaymentSerializer)
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


@extend_schema_view(
    create=extend_schema(
        request=ExpenseCreateSerializer,
        responses={200: ExpenseSerializer, 201: ExpenseSerializer},
    )
)
class ExpenseViewSet(PostingViewSet):
    read_roles = [Membership.Role.OWNER, Membership.Role.MANAGER]
    queryset = Expense.objects.select_related("location")
    serializer_class = ExpenseSerializer
    create_serializer_class = ExpenseCreateSerializer
    post_service = staticmethod(post_expense)

    @extend_schema(request=ReverseSerializer, responses=ExpenseSerializer)
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


@extend_schema_view(
    create=extend_schema(
        request=TransferCreateSerializer,
        responses={200: TransferSerializer, 201: TransferSerializer},
    )
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

    @extend_schema(request=ReverseSerializer, responses=TransferSerializer)
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
    @extend_schema(
        summary="Post an opening-stock or manual stock adjustment",
        request=StockAdjustmentSerializer,
        responses={200: StockMovementSerializer, 201: StockMovementSerializer},
    )
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
    @extend_schema(
        summary="Post a party-ledger opening balance",
        request=OpeningBalanceCreateSerializer,
        responses={200: PartyLedgerEntrySerializer, 201: PartyLedgerEntrySerializer},
    )
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
    membership = require_membership(
        request.user,
        business_id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
    )
    location_ids = list(accessible_location_ids(membership))
    location_id = request.query_params.get("location_id")
    if location_id:
        require_membership(request.user, business_id, location_id=location_id)
        location_ids = [location_id]
    return business_id, location_ids


def _report_scope_parameters():
    return [
        OpenApiParameter(
            name="business_id",
            type=uuid.UUID,
            location=OpenApiParameter.QUERY,
            required=True,
        ),
        OpenApiParameter(
            name="location_id",
            type=uuid.UUID,
            location=OpenApiParameter.QUERY,
            required=False,
        ),
    ]


def _posted_sales_metrics(sales):
    sale_lines = SaleLine.objects.filter(sale__in=sales)
    aggregates = sale_lines.aggregate(
        line_count=Count("id"),
        known_cogs_minor=Sum("cogs_minor"),
    )
    missing_cost_lines = sale_lines.filter(
        Q(cogs_minor__isnull=True) | Q(costing_complete=False)
    ).count()
    posted_sale_count = sales.count()
    net_sales = sales.aggregate(total=Sum("taxable_total_minor"))["total"] or 0
    known_cogs = aggregates["known_cogs_minor"] or 0
    profit_complete = posted_sale_count == 0 or (
        aggregates["line_count"] and missing_cost_lines == 0
    )
    return {
        "posted_sale_count": posted_sale_count,
        "line_count": aggregates["line_count"] or 0,
        "net_sales_minor": net_sales,
        "cogs_minor": known_cogs,
        "gross_profit_minor": net_sales - known_cogs if profit_complete else None,
        "missing_cost_line_count": missing_cost_lines,
        "costing_complete": bool(profit_complete),
    }


class DashboardView(APIView):
    @extend_schema(
        summary="Get operational dashboard totals",
        parameters=_report_scope_parameters(),
        responses=DashboardSerializer,
    )
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
        cash_flow = receipts - supplier_payments - expense_total
        today_sales = (
            sales.filter(document_date=today).aggregate(v=Sum("grand_total_minor"))["v"] or 0
        )
        today_purchases = (
            purchases.filter(document_date=today).aggregate(v=Sum("grand_total_minor"))["v"] or 0
        )
        receipts_today = (
            payments.filter(direction=Payment.Direction.RECEIPT, payment_date=today).aggregate(
                v=Sum("amount_minor")
            )["v"]
            or 0
        )
        today_expenses = (
            expenses.filter(document_date=today).aggregate(v=Sum("total_minor"))["v"] or 0
        )
        stock_totals = (
            StockBalance.objects.filter(
                business_id=business_id,
                location_id__in=location_ids,
                product_id=OuterRef("pk"),
            )
            .values("product_id")
            .annotate(total=Sum("quantity"))
            .values("total")
        )
        low_stock_count = (
            Product.objects.filter(business_id=business_id, is_active=True, track_inventory=True)
            .annotate(
                stock_quantity=Coalesce(
                    Subquery(
                        stock_totals,
                        output_field=DecimalField(max_digits=18, decimal_places=3),
                    ),
                    Value(Decimal("0")),
                    output_field=DecimalField(max_digits=18, decimal_places=3),
                )
            )
            .filter(stock_quantity__lte=F("low_stock_threshold"))
            .count()
        )
        summary = (
            f"Today: sales {_format_minor(today_sales)}, "
            f"purchases {_format_minor(today_purchases)}, "
            f"expenses {_format_minor(today_expenses)}. "
            f"Books: receivables {_format_minor(receivable)}, "
            f"payables {_format_minor(payable)}, "
            f"cash flow {_format_minor(cash_flow)}. "
            f"{low_stock_count} low-stock {'product' if low_stock_count == 1 else 'products'}."
        )
        sales_metrics = _posted_sales_metrics(sales)
        return Response(
            {
                "business_id": business_id,
                "as_of": today,
                "today": {
                    "sales_minor": today_sales,
                    "purchases_minor": today_purchases,
                    "expenses_minor": today_expenses,
                    "receipts_minor": receipts_today,
                },
                "books": {
                    "sales_minor": sales.aggregate(v=Sum("grand_total_minor"))["v"] or 0,
                    "purchases_minor": purchases.aggregate(v=Sum("grand_total_minor"))["v"] or 0,
                    "expenses_minor": expense_total,
                    "receipts_minor": receipts,
                    "supplier_payments_minor": supplier_payments,
                    "receivable_minor": receivable,
                    "payable_minor": payable,
                    "cash_flow_minor": cash_flow,
                },
                "low_stock_count": low_stock_count,
                # Missing/legacy costs keep this null rather than implying a margin.
                "gross_profit_minor": sales_metrics["gross_profit_minor"],
                "summary": summary,
            }
        )


class StockReportView(APIView):
    @extend_schema(
        summary="List current stock quantities and low-stock flags",
        parameters=_report_scope_parameters(),
        responses=StockReportSerializer,
    )
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


class ValuationReportView(APIView):
    @extend_schema(
        summary="Report inventory valuation and posted-sale costing",
        parameters=[
            *_report_scope_parameters(),
            OpenApiParameter(
                name="date_from",
                type=date,
                location=OpenApiParameter.QUERY,
                required=False,
                description="Inclusive sale date lower bound (YYYY-MM-DD).",
            ),
            OpenApiParameter(
                name="date_to",
                type=date,
                location=OpenApiParameter.QUERY,
                required=False,
                description="Inclusive sale date upper bound (YYYY-MM-DD).",
            ),
        ],
        responses=ValuationReportSerializer,
    )
    def get(self, request):
        business_id, location_ids = _report_scope(request)
        date_from = request.query_params.get("date_from")
        date_to = request.query_params.get("date_to")
        try:
            date_from = date.fromisoformat(date_from) if date_from else None
            date_to = date.fromisoformat(date_to) if date_to else None
        except ValueError as exc:
            raise ValidationError("Dates must use YYYY-MM-DD format") from exc
        if date_from and date_to and date_from > date_to:
            raise ValidationError("date_from cannot be after date_to")

        products = Product.objects.filter(business_id=business_id, track_inventory=True)
        balances = (
            StockBalance.objects.filter(
                business_id=business_id,
                location_id__in=location_ids,
                product_id__in=products.values("id"),
            )
            .values("product_id")
            .annotate(
                total_quantity=Sum("quantity"),
                costed_quantity=Sum("costed_quantity"),
                known_value_minor=Sum("inventory_value_minor"),
            )
        )
        by_product = {row["product_id"]: row for row in balances}
        rows = []
        inventory_complete = True
        known_value_total = 0
        quantity_total = Decimal("0")
        costed_quantity_total = Decimal("0")
        for product in products.order_by("name"):
            balance = by_product.get(product.id, {})
            current = balance.get("total_quantity") or Decimal("0")
            costed = balance.get("costed_quantity") or Decimal("0")
            known_value = balance.get("known_value_minor") or 0
            # Direct legacy imports may only have changed StockBalance.quantity.
            # Every non-costed unit is therefore explicitly unknown.
            unknown = current - costed
            complete = unknown == ZERO
            inventory_complete = inventory_complete and complete
            quantity_total += current
            costed_quantity_total += costed
            known_value_total += known_value
            rows.append(
                {
                    "product_id": str(product.id),
                    "name": product.name,
                    "unit": product.base_unit,
                    "quantity": current,
                    "average_cost_minor": weighted_average_unit_cost(known_value, costed)
                    if complete and costed > ZERO
                    else None,
                    "total_value_minor": known_value if complete else None,
                    "known_value_minor": known_value,
                    "unknown_cost_quantity": unknown,
                    "costing_complete": complete,
                }
            )

        sales = Sale.objects.filter(
            business_id=business_id,
            location_id__in=location_ids,
            status=DocumentStatus.POSTED,
        )
        if date_from:
            sales = sales.filter(document_date__gte=date_from)
        if date_to:
            sales = sales.filter(document_date__lte=date_to)
        sales_metrics = _posted_sales_metrics(sales)
        return Response(
            {
                "inventory": {
                    "total_quantity": quantity_total,
                    "average_cost_minor": weighted_average_unit_cost(
                        known_value_total, costed_quantity_total
                    )
                    if inventory_complete and costed_quantity_total > ZERO
                    else None,
                    "total_value_minor": known_value_total if inventory_complete else None,
                    "known_value_minor": known_value_total,
                    "costing_complete": inventory_complete,
                },
                "sales": sales_metrics,
                "results": rows,
            }
        )


class PartyLedgerReportView(APIView):
    @extend_schema(
        summary="Get a party's ledger entries and balance",
        parameters=[
            *_report_scope_parameters(),
            OpenApiParameter(
                name="party_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=True,
            ),
            OpenApiParameter(
                name="account",
                type=str,
                location=OpenApiParameter.QUERY,
                required=False,
                enum=PartyLedgerEntry.Account.values,
            ),
        ],
        responses=PartyLedgerReportSerializer,
    )
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
