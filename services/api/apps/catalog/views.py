from decimal import Decimal

from django.db.models import BigIntegerField, DecimalField, Q, Sum, Value
from django.db.models.functions import Coalesce
from rest_framework import viewsets
from rest_framework.exceptions import ValidationError

from apps.operations.models import PartyLedgerEntry
from apps.tenancy.access import accessible_location_ids, require_membership
from apps.tenancy.models import Membership

from .models import Party, Product
from .serializers import PartySerializer, ProductSerializer


class BusinessScopedCatalogViewSet(viewsets.ModelViewSet):
    business_field = "business_id"

    def get_business_id(self):
        return self.request.query_params.get("business_id") or self.request.data.get("business")

    def get_location_ids(self):
        """Resolve the request's location scope for aggregate columns.

        A ``location_id`` query parameter narrows the scope; otherwise the
        caller sees aggregates across every location they can access."""
        business_id = self.get_business_id()
        if not business_id:
            return None
        location_id = self.request.query_params.get("location_id")
        if location_id:
            membership = require_membership(self.request.user, business_id, location_id=location_id)
        else:
            membership = require_membership(self.request.user, business_id)
        if location_id:
            return [location_id]
        return list(accessible_location_ids(membership))

    def get_queryset(self):
        business_id = self.get_business_id()
        if not business_id:
            return self.queryset.none()
        require_membership(self.request.user, business_id)
        return self.queryset.filter(business_id=business_id)

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


class ProductViewSet(BusinessScopedCatalogViewSet):
    queryset = Product.objects.prefetch_related("packs").all()
    serializer_class = ProductSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        location_ids = self.get_location_ids()
        if location_ids is None:
            return queryset.none()
        stock_filter = Q(stock_balances__location_id__in=location_ids)
        return queryset.annotate(
            _stock_quantity=Coalesce(
                Sum("stock_balances__quantity", filter=stock_filter),
                Value(Decimal("0")),
                output_field=DecimalField(max_digits=18, decimal_places=3),
            )
        )


class PartyViewSet(BusinessScopedCatalogViewSet):
    queryset = Party.objects.all()
    serializer_class = PartySerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        business_id = self.get_business_id()
        location_ids = self.get_location_ids()
        if location_ids is None or not business_id:
            return queryset.none()
        membership = require_membership(self.request.user, business_id)
        receivable = Coalesce(
            Sum(
                "ledger_entries__amount_minor",
                filter=Q(
                    ledger_entries__account=PartyLedgerEntry.Account.RECEIVABLE,
                    ledger_entries__location_id__in=location_ids,
                ),
            ),
            Value(0),
            output_field=BigIntegerField(),
        )
        if membership.role == Membership.Role.CASHIER:
            # Cashiers must not see supplier payables, matching the payment
            # document restriction on the operations endpoints.
            payable = Value(0, output_field=BigIntegerField())
        else:
            payable = Coalesce(
                Sum(
                    "ledger_entries__amount_minor",
                    filter=Q(
                        ledger_entries__account=PartyLedgerEntry.Account.PAYABLE,
                        ledger_entries__location_id__in=location_ids,
                    ),
                ),
                Value(0),
                output_field=BigIntegerField(),
            )
        return queryset.annotate(_receivable_minor=receivable, _payable_minor=payable)
