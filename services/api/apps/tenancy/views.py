from rest_framework import mixins, viewsets

from .access import accessible_location_ids, require_membership
from .models import Business, GSTRegistration, Location, Membership
from .serializers import (
    BusinessSerializer,
    GSTRegistrationSerializer,
    LocationSerializer,
    MembershipSerializer,
)


class BusinessViewSet(
    mixins.ListModelMixin,
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    viewsets.GenericViewSet,
):
    serializer_class = BusinessSerializer

    def get_queryset(self):
        return Business.objects.filter(
            memberships__user=self.request.user, memberships__is_active=True, is_active=True
        ).distinct()


class LocationViewSet(viewsets.ModelViewSet):
    serializer_class = LocationSerializer

    def get_queryset(self):
        business_id = self.request.query_params.get("business_id")
        if not business_id:
            return Location.objects.none()
        membership = require_membership(self.request.user, business_id)
        return Location.objects.filter(
            id__in=accessible_location_ids(membership), business_id=business_id
        )

    def perform_create(self, serializer):
        business = serializer.validated_data["business"]
        require_membership(self.request.user, business.id, roles=[Membership.Role.OWNER])
        serializer.save()

    def perform_update(self, serializer):
        require_membership(
            self.request.user, self.get_object().business_id, roles=[Membership.Role.OWNER]
        )
        serializer.save()

    def perform_destroy(self, instance):
        require_membership(self.request.user, instance.business_id, roles=[Membership.Role.OWNER])
        instance.is_active = False
        instance.save(update_fields=["is_active", "updated_at"])


class GSTRegistrationViewSet(viewsets.ModelViewSet):
    serializer_class = GSTRegistrationSerializer
    http_method_names = ["get", "post", "patch", "head", "options"]

    def perform_update(self, serializer):
        require_membership(
            self.request.user, self.get_object().business_id, roles=[Membership.Role.OWNER]
        )
        serializer.save()

    def get_queryset(self):
        business_id = self.request.query_params.get("business_id")
        if not business_id:
            return GSTRegistration.objects.none()
        require_membership(
            self.request.user, business_id, roles=[Membership.Role.OWNER, Membership.Role.MANAGER]
        )
        return GSTRegistration.objects.filter(business_id=business_id)

    def perform_create(self, serializer):
        business = serializer.validated_data["business"]
        require_membership(self.request.user, business.id, roles=[Membership.Role.OWNER])
        serializer.save()


class MembershipViewSet(viewsets.ModelViewSet):
    serializer_class = MembershipSerializer

    def get_queryset(self):
        business_id = self.request.query_params.get("business_id")
        if not business_id:
            return Membership.objects.none()
        require_membership(self.request.user, business_id, roles=[Membership.Role.OWNER])
        return Membership.objects.filter(business_id=business_id).select_related("user")

    def perform_create(self, serializer):
        business = serializer.validated_data["business"]
        require_membership(self.request.user, business.id, roles=[Membership.Role.OWNER])
        serializer.save()
