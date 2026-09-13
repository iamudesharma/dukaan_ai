from datetime import timedelta

from django.db import connection, transaction
from django.utils import timezone
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import NotFound, PermissionDenied, ValidationError
from rest_framework.response import Response

from apps.authentication.models import SessionRevocation
from apps.tenancy import rls

from .access import accessible_location_ids, require_membership
from .models import Business, GSTRegistration, Invitation, Location, Membership
from .serializers import (
    AcceptInvitationSerializer,
    BusinessSerializer,
    GSTRegistrationSerializer,
    InvitationSerializer,
    LocationSerializer,
    MembershipSerializer,
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
        require_membership(
            self.request.user,
            self.get_object().pk,
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


class MembershipViewSet(viewsets.ModelViewSet):
    serializer_class = MembershipSerializer

    def get_queryset(self):
        owned_business_ids = Membership.objects.filter(
            user=self.request.user,
            is_active=True,
            role=Membership.Role.OWNER,
            business__is_active=True,
        ).values_list("business_id", flat=True)
        queryset = Membership.objects.filter(business_id__in=owned_business_ids).select_related(
            "user"
        )
        business_id = self.request.query_params.get("business_id")
        if business_id:
            require_membership(self.request.user, business_id, roles=[Membership.Role.OWNER])
            queryset = queryset.filter(business_id=business_id)
        return queryset

    def perform_create(self, serializer):
        business = serializer.validated_data["business"]
        require_membership(self.request.user, business.id, roles=[Membership.Role.OWNER])
        serializer.save()

    def perform_destroy(self, instance):
        """DELETE deactivates instead of deleting: membership rows are audit
        history. Use POST .../revoke/ when the member must also be signed out."""
        require_membership(self.request.user, instance.business_id, roles=[Membership.Role.OWNER])
        if instance.user_id == self.request.user.pk:
            raise ValidationError("You cannot revoke your own membership")
        instance.is_active = False
        instance.save(update_fields=["is_active", "updated_at"])

    @action(detail=True, methods=["post"])
    @transaction.atomic
    def revoke(self, request, pk=None):
        """Deactivate a membership and force the member to sign in again.

        Deactivation alone already blocks the business (every endpoint checks
        membership), but without session revocation the removed member keeps a
        valid identity token. Revoking sessions closes that gap; the member
        keeps access to their other businesses after signing in again."""
        membership = self.get_object()
        require_membership(request.user, membership.business_id, roles=[Membership.Role.OWNER])
        if membership.user_id == request.user.pk:
            raise ValidationError("You cannot revoke your own membership")
        membership.is_active = False
        membership.save(update_fields=["is_active", "updated_at"])
        SessionRevocation.objects.update_or_create(
            user=membership.user, defaults={"revoked_at": timezone.now()}
        )
        return Response(MembershipSerializer(membership).data)


class InvitationViewSet(
    mixins.ListModelMixin,
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    viewsets.GenericViewSet,
):
    serializer_class = InvitationSerializer

    def get_queryset(self):
        owned_business_ids = Membership.objects.filter(
            user=self.request.user,
            is_active=True,
            role=Membership.Role.OWNER,
            business__is_active=True,
        ).values_list("business_id", flat=True)
        queryset = Invitation.objects.filter(business_id__in=owned_business_ids)
        business_id = self.request.query_params.get("business_id")
        if business_id:
            require_membership(self.request.user, business_id, roles=[Membership.Role.OWNER])
            queryset = queryset.filter(business_id=business_id)
        status_value = self.request.query_params.get("status")
        if status_value:
            queryset = queryset.filter(status=status_value)
        return queryset.order_by("-created_at")

    def perform_create(self, serializer):
        business = serializer.validated_data["business"]
        require_membership(self.request.user, business.id, roles=[Membership.Role.OWNER])
        serializer.save(
            invited_by=self.request.user,
            expires_at=timezone.now() + timedelta(days=7),
        )

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        invitation = serializer.instance
        data = self.get_serializer(invitation).data
        # The token is returned once, at creation, so the inviter can share
        # the accept link out of band. It is never listed or retrieved again.
        data["token"] = str(invitation.token)
        headers = self.get_success_headers(serializer.data)
        return Response(data, status=status.HTTP_201_CREATED, headers=headers)

    @action(detail=True, methods=["post"])
    @transaction.atomic
    def accept(self, request, pk=None):
        """Join the invited business.

        The invitation token proves the invite; the verified phone number
        must match the invitation. The invitee is usually not a member yet,
        so the single invitation row is read under a staff scope that is
        restored immediately; acceptance still requires the unguessable token
        plus the matching verified phone number. The business is then added
        to the connection scope exactly like onboarding, so the membership
        insert passes the database check."""
        serializer = AcceptInvitationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        snapshot = rls.read_scope(connection)
        try:
            rls.set_staff_scope(connection)
            invitation = Invitation.objects.select_for_update().get(pk=pk)
        except Invitation.DoesNotExist:
            raise NotFound("Invitation not found") from None
        finally:
            rls.restore_scope(connection, snapshot)
        if str(invitation.token) != str(serializer.validated_data["token"]):
            raise PermissionDenied("This invitation link is not valid")
        if invitation.status != Invitation.Status.PENDING:
            raise ValidationError("This invitation is no longer pending")
        if invitation.expires_at <= timezone.now():
            invitation.status = Invitation.Status.EXPIRED
            invitation.save(update_fields=["status", "updated_at"])
            raise ValidationError("This invitation has expired")
        if (request.user.phone_e164 or "") != invitation.phone_e164:
            raise PermissionDenied(
                "Sign in with the invited phone number to accept this invitation"
            )
        rls.expand_tenant_scope(connection, invitation.business_id)
        membership, created = Membership.objects.get_or_create(
            user=request.user,
            business=invitation.business,
            defaults={"role": invitation.role},
        )
        if not created and not membership.is_active:
            membership.is_active = True
            membership.role = invitation.role
            membership.save(update_fields=["is_active", "role", "updated_at"])
        membership.locations.set(invitation.locations.all())
        invitation.status = Invitation.Status.ACCEPTED
        invitation.save(update_fields=["status", "updated_at"])
        return Response(MembershipSerializer(membership).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"])
    def revoke(self, request, pk=None):
        invitation = self.get_object()
        require_membership(request.user, invitation.business_id, roles=[Membership.Role.OWNER])
        if invitation.status != Invitation.Status.PENDING:
            raise ValidationError("Only a pending invitation can be revoked")
        invitation.status = Invitation.Status.REVOKED
        invitation.save(update_fields=["status", "updated_at"])
        return Response(InvitationSerializer(invitation).data)
