import uuid

from django.db import IntegrityError, connection, transaction
from django.shortcuts import get_object_or_404
from django.utils import timezone
from drf_spectacular.utils import OpenApiParameter, extend_schema, extend_schema_view
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response

from apps.tenancy import rls

from .access import accessible_location_ids, require_membership
from .models import AuditEvent, Business, GSTRegistration, Invitation, Location, Membership
from .serializers import (
    AuditEventSerializer,
    BusinessSerializer,
    GSTRegistrationSerializer,
    InvitationAcceptSerializer,
    InvitationCreateSerializer,
    InvitationSerializer,
    LocationSerializer,
    MembershipSerializer,
)

BUSINESS_ID_PATH_PARAMETER = OpenApiParameter(
    name="id", type=uuid.UUID, location=OpenApiParameter.PATH, required=True
)


@extend_schema_view(
    retrieve=extend_schema(parameters=[BUSINESS_ID_PATH_PARAMETER]),
    update=extend_schema(parameters=[BUSINESS_ID_PATH_PARAMETER]),
    partial_update=extend_schema(parameters=[BUSINESS_ID_PATH_PARAMETER]),
)
class BusinessViewSet(
    mixins.ListModelMixin,
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    viewsets.GenericViewSet,
):
    serializer_class = BusinessSerializer

    def get_queryset(self):
        return Business.objects.filter(
            memberships__user=self.request.user, memberships__is_active=True, is_active=True
        ).distinct()

    def perform_update(self, serializer):
        instance = self.get_object()
        if "business" in self.request.data or "business_id" in self.request.data:
            raise ValidationError("A business cannot move between tenants")
        if "id" in self.request.data and str(self.request.data["id"]) != str(instance.pk):
            raise ValidationError("Business identity cannot be changed")
        require_membership(
            self.request.user,
            instance.pk,
            roles=[Membership.Role.OWNER],
        )
        serializer.save()


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


class AuditEventViewSet(mixins.ListModelMixin, viewsets.GenericViewSet):
    """Read-only audit trail for the Activity screen."""

    serializer_class = AuditEventSerializer

    def get_queryset(self):
        business_id = self.request.query_params.get("business_id")
        if not business_id:
            return AuditEvent.objects.none()
        require_membership(
            self.request.user,
            business_id,
            roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        )
        queryset = (
            AuditEvent.objects.filter(business_id=business_id)
            .select_related("actor", "location")
            .order_by("-created_at")
        )
        location_id = self.request.query_params.get("location_id")
        if location_id:
            queryset = queryset.filter(location_id=location_id)
        event_type = self.request.query_params.get("event_type")
        if event_type:
            queryset = queryset.filter(event_type=event_type)
        return queryset[:200]


class MembershipViewSet(viewsets.ModelViewSet):
    serializer_class = MembershipSerializer

    def get_queryset(self):
        business_id = self.request.query_params.get("business_id")
        if not business_id:
            return Membership.objects.none()
        require_membership(self.request.user, business_id, roles=[Membership.Role.OWNER])
        return Membership.objects.filter(business_id=business_id)

    def perform_create(self, serializer):
        business = serializer.validated_data["business"]
        require_membership(self.request.user, business.id, roles=[Membership.Role.OWNER])
        serializer.save()


class InvitationViewSet(mixins.ListModelMixin, mixins.CreateModelMixin, viewsets.GenericViewSet):
    serializer_class = InvitationSerializer

    def list(self, request, *args, **kwargs):
        business_id = request.query_params.get("business_id")
        if not business_id:
            return Response([])
        require_membership(request.user, business_id, roles=[Membership.Role.OWNER])
        return super().list(request, *args, **kwargs)

    def get_queryset(self):
        queryset = (
            Invitation.objects.select_related("business", "inviter", "accepted_by")
            .prefetch_related("locations")
            .order_by("-created_at")
        )
        business_id = self.request.query_params.get("business_id")
        if self.action == "list":
            if not business_id:
                return queryset.none()
            queryset = queryset.filter(business_id=business_id)
        return queryset

    def create(self, request, *args, **kwargs):
        serializer = InvitationCreateSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        require_membership(
            request.user, serializer.validated_data["business"].pk, roles=[Membership.Role.OWNER]
        )
        invitation = serializer.save()
        data = InvitationSerializer(invitation, context={"request": request}).data
        # Raw token is returned once for delivery; it is never stored or serialized.
        data["token"] = invitation._raw_token
        return Response(data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"], url_path="revoke")
    def revoke(self, request, pk=None):
        with transaction.atomic():
            # Acceptance locks this same row. Re-checking after the lock avoids
            # overwriting a concurrently accepted invitation with REVOKED.
            invitation = get_object_or_404(Invitation.objects.select_for_update(), pk=pk)
            require_membership(request.user, invitation.business_id, roles=[Membership.Role.OWNER])
            if invitation.status != Invitation.Status.PENDING:
                raise ValidationError("Only a pending invitation can be revoked.")
            invitation.status = Invitation.Status.REVOKED
            invitation.revoked_at = timezone.now()
            invitation.save(update_fields=["status", "revoked_at", "updated_at"])
            invitation.record_audit(Invitation.AuditEventType.REVOKED, request.user)
        return Response(InvitationSerializer(invitation, context={"request": request}).data)

    @action(detail=False, methods=["post"], url_path="accept")
    def accept(self, request):
        serializer = InvitationAcceptSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        token_hash = Invitation.hash_token(serializer.validated_data["token"])
        invalid = ValidationError("Invalid, expired, or unavailable invitation.")

        with transaction.atomic():
            invitation = (
                Invitation.objects.select_for_update()
                .select_related("business")
                .filter(
                    token_hash=token_hash,
                    invitee_phone=request.user.phone_e164,
                    status=Invitation.Status.PENDING,
                    expires_at__gt=timezone.now(),
                )
                .first()
            )
            if invitation is None:
                raise invalid
            if invitation.role not in Membership.Role.values:
                raise invalid
            if not invitation.business.is_active:
                raise invalid
            if Membership.objects.filter(user=request.user, business=invitation.business).exists():
                raise ValidationError("You already belong to this business.")

            # The invitation was resolved through the phone-scoped RLS
            # bootstrap policy. Only its verified business may expand scope.
            rls.expand_tenant_scope(connection, invitation.business_id)
            location_ids = set(invitation.locations.values_list("pk", flat=True))
            locations = list(
                Location.objects.filter(
                    pk__in=location_ids, business=invitation.business, is_active=True
                )
            )
            if {location.pk for location in locations} != location_ids:
                raise invalid

            try:
                membership = Membership.objects.create(
                    user=request.user,
                    business=invitation.business,
                    role=invitation.role,
                )
            except IntegrityError as exc:
                raise ValidationError("You already belong to this business.") from exc
            membership.locations.set(locations)
            invitation.status = Invitation.Status.ACCEPTED
            invitation.accepted_by = request.user
            invitation.accepted_at = timezone.now()
            invitation.save(update_fields=["status", "accepted_by", "accepted_at", "updated_at"])
            invitation.record_audit(
                Invitation.AuditEventType.ACCEPTED, request.user, membership=membership
            )

        return Response(InvitationSerializer(invitation, context={"request": request}).data)
