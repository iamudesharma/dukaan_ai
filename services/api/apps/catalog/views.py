from rest_framework import viewsets
from rest_framework.exceptions import ValidationError

from apps.tenancy.access import require_membership
from apps.tenancy.models import Membership

from .models import Party, Product
from .serializers import PartySerializer, ProductSerializer


class BusinessScopedCatalogViewSet(viewsets.ModelViewSet):
    business_field = "business_id"

    def get_business_id(self):
        return self.request.query_params.get("business_id") or self.request.data.get("business")

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


class PartyViewSet(BusinessScopedCatalogViewSet):
    queryset = Party.objects.all()
    serializer_class = PartySerializer
