import uuid
from decimal import Decimal

from django.db.models import BigIntegerField, DecimalField, OuterRef, Subquery, Sum, Value
from django.db.models.functions import Coalesce
from rest_framework import viewsets
from rest_framework.exceptions import ValidationError

from apps.common.pagination import StandardResultsPagination
from apps.operations.models import PartyLedgerEntry, StockBalance
from apps.tenancy.access import require_membership
from apps.tenancy.models import Membership

from .models import Party, Product
from .serializers import PartySerializer, ProductSerializer


class BusinessScopedCatalogViewSet(viewsets.ModelViewSet):
    business_field = "business_id"
    pagination_class = StandardResultsPagination

    def get_business_id(self):
        return self.request.query_params.get("business_id") or self.request.data.get("business")

    def get_membership(self):
        business_id = self.get_business_id()
        if not business_id:
            return None
        cached_business_id = getattr(self, "_membership_business_id", None)
        if cached_business_id != str(business_id):
            self._membership = require_membership(self.request.user, business_id)
            self._membership_business_id = str(business_id)
        return self._membership

    def get_location_id(self):
        if hasattr(self, "_location_id"):
            return self._location_id
        raw_location_id = self.request.query_params.get("location_id")
        location_id = None
        if raw_location_id and self.get_business_id():
            try:
                location_id = uuid.UUID(str(raw_location_id))
            except (AttributeError, TypeError, ValueError):
                raise ValidationError({"location_id": "Must be a valid UUID."}) from None
            require_membership(
                self.request.user,
                self.get_business_id(),
                location_id=location_id,
            )
        self._location_id = location_id
        return location_id

    def get_queryset(self):
        business_id = self.get_business_id()
        if not business_id:
            return self.queryset.none()
        self.get_membership()
        self.get_location_id()
        return self.queryset.filter(business_id=business_id)

    def get_serializer_context(self):
        context = super().get_serializer_context()
        business_id = self.get_business_id()
        context["business_id"] = business_id
        context["location_id"] = self.get_location_id()
        context["membership"] = self.get_membership()
        return context

    def perform_create(self, serializer):
        business = serializer.validated_data["business"]
        require_membership(
            self.request.user,
            business.id,
            roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        )
        serializer.save()

    def perform_update(self, serializer):
        if (
            "business" in serializer.validated_data
            and serializer.validated_data["business"].pk != self.get_object().business_id
        ):
            raise ValidationError("Catalog records cannot move between businesses")
        require_membership(
            self.request.user,
            self.get_object().business_id,
            roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        )
        serializer.save()

    def perform_destroy(self, instance):
        require_membership(
            self.request.user,
            instance.business_id,
            roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        )
        instance.is_active = False
        instance.save(update_fields=["is_active", "updated_at"])


def _ledger_total_subquery(account, location_id=None):
    entries = PartyLedgerEntry.objects.filter(
        business_id=OuterRef("business_id"),
        party_id=OuterRef("pk"),
        account=account,
    )
    if location_id:
        entries = entries.filter(location_id=location_id)
    return Subquery(
        entries.values("party_id").annotate(total=Sum("amount_minor")).values("total"),
        output_field=BigIntegerField(),
    )


class ProductViewSet(BusinessScopedCatalogViewSet):
    queryset = Product.objects.prefetch_related("packs").order_by("name")
    serializer_class = ProductSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        location_id = self.get_location_id()
        if location_id:
            stock_totals = (
                StockBalance.objects.filter(
                    business_id=OuterRef("business_id"),
                    location_id=location_id,
                    product_id=OuterRef("pk"),
                )
                .values("product_id")
                .annotate(total=Sum("quantity"))
                .values("total")
            )
            queryset = queryset.annotate(
                stock_quantity=Coalesce(
                    Subquery(
                        stock_totals,
                        output_field=DecimalField(max_digits=18, decimal_places=3),
                    ),
                    Value(Decimal("0")),
                    output_field=DecimalField(max_digits=18, decimal_places=3),
                )
            )
        return queryset


class PartyViewSet(BusinessScopedCatalogViewSet):
    queryset = Party.objects.order_by("name")
    serializer_class = PartySerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        location_id = self.get_location_id()
        membership = self.get_membership()
        if membership and membership.role == Membership.Role.CASHIER:
            # A BOTH party is also a supplier. Do not expose its identity or
            # supplier-side balance to a cashier; sales can use CUSTOMER rows.
            queryset = queryset.filter(kind=Party.Kind.CUSTOMER)
        return queryset.annotate(
            receivable_minor=Coalesce(
                _ledger_total_subquery(PartyLedgerEntry.Account.RECEIVABLE, location_id),
                Value(0),
            ),
            payable_minor=Coalesce(
                _ledger_total_subquery(PartyLedgerEntry.Account.PAYABLE, location_id),
                Value(0),
            ),
        )
