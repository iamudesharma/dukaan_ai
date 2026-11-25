import re
from datetime import timedelta

from django.db import transaction
from django.utils import timezone
from rest_framework import serializers

from .models import (
    AuditEvent,
    Business,
    GSTRegistration,
    Invitation,
    Location,
    Membership,
    gstin_validator,
)

INVITEE_PHONE_REGEX = re.compile(r"^\+[1-9]\d{6,14}$")


class LocationSerializer(serializers.ModelSerializer):
    is_primary = serializers.SerializerMethodField()

    class Meta:
        model = Location
        fields = [
            "id",
            "business",
            "gst_registration",
            "code",
            "name",
            "address",
            "state_code",
            "is_primary",
            "is_active",
        ]
        read_only_fields = ["id"]

    def get_is_primary(self, obj) -> bool:
        if getattr(obj, "_is_primary", None) is not None:
            return obj._is_primary
        first_id = (
            Location.objects.filter(business_id=obj.business_id)
            .order_by("created_at", "pk")
            .values_list("pk", flat=True)
            .first()
        )
        return obj.pk == first_id

    def validate(self, attrs):
        if (
            self.instance
            and "business" in attrs
            and attrs["business"].pk != self.instance.business_id
        ):
            raise serializers.ValidationError("A location cannot move between businesses")
        business = attrs.get("business") or getattr(self.instance, "business", None)
        registration = attrs.get(
            "gst_registration", getattr(self.instance, "gst_registration", None)
        )
        if registration and registration.business_id != business.id:
            raise serializers.ValidationError("GST registration must belong to the business")
        return attrs


class GSTRegistrationSerializer(serializers.ModelSerializer):
    def validate(self, attrs):
        if (
            self.instance
            and "business" in attrs
            and attrs["business"].pk != self.instance.business_id
        ):
            raise serializers.ValidationError("A registration cannot move between businesses")
        business = attrs.get("business") or self.instance.business
        existing = GSTRegistration.objects.filter(business=business)
        if self.instance:
            existing = existing.exclude(pk=self.instance.pk)
        if existing.exists():
            raise serializers.ValidationError("Only one GST registration is supported per business")
        return attrs

    class Meta:
        model = GSTRegistration
        fields = [
            "id",
            "business",
            "gstin",
            "legal_name",
            "address",
            "state_code",
            "invoice_prefix",
            "is_active",
        ]
        read_only_fields = ["id"]


class BusinessSerializer(serializers.ModelSerializer):
    locations = LocationSerializer(many=True, read_only=True)
    role = serializers.SerializerMethodField()
    # Onboarding inputs. Accepted on create only and never echoed back.
    location_name = serializers.CharField(
        max_length=160, required=False, allow_blank=True, write_only=True
    )
    state_code = serializers.CharField(
        max_length=2, required=False, allow_blank=True, write_only=True
    )
    gstin = serializers.CharField(
        max_length=15,
        required=False,
        allow_blank=True,
        write_only=True,
        validators=[gstin_validator],
    )

    class Meta:
        model = Business
        fields = [
            "id",
            "name",
            "legal_name",
            "currency",
            "timezone",
            "gst_enabled",
            "negative_stock_allowed",
            "is_active",
            "role",
            "locations",
            "location_name",
            "state_code",
            "gstin",
        ]
        read_only_fields = ["id", "is_active", "role", "locations"]

    def get_role(self, obj) -> str | None:
        user = self.context["request"].user
        membership = obj.memberships.filter(user=user, is_active=True).first()
        return membership.role if membership else None

    def validate_gstin(self, value: str) -> str:
        return value.strip().upper()

    @transaction.atomic
    def create(self, validated_data):
        from django.db import connection

        from apps.tenancy import rls

        location_name = validated_data.pop("location_name", "") or "Main Shop"
        state_code = validated_data.pop("state_code", "")
        gstin = validated_data.pop("gstin", "")
        # The first two characters of a GSTIN are its state code.
        if gstin and not state_code:
            state_code = gstin[:2]
        if gstin:
            validated_data["gst_enabled"] = True

        # Allocate the server-side UUID before saving so the RLS WITH CHECK can
        # authorize this exact business ID. The caller cannot choose the ID.
        business = Business(**validated_data)
        rls.expand_tenant_scope(connection, business.pk)
        business.save(force_insert=True)
        registration = None
        if gstin:
            registration = GSTRegistration.objects.create(
                business=business,
                gstin=gstin,
                legal_name=business.legal_name or business.name,
                state_code=state_code,
            )
        Membership.objects.create(
            user=self.context["request"].user, business=business, role=Membership.Role.OWNER
        )
        Location.objects.create(
            business=business,
            code="MAIN",
            name=location_name,
            state_code=state_code,
            gst_registration=registration,
        )
        # New memberships change the request's business list; the expanded
        # scope already covers the created business for the rest of the call.
        return business


class AuditEventSerializer(serializers.ModelSerializer):
    actor_name = serializers.SerializerMethodField()

    class Meta:
        model = AuditEvent
        fields = [
            "id",
            "event_type",
            "aggregate_type",
            "aggregate_id",
            "location",
            "actor_name",
            "source",
            "metadata",
            "created_at",
        ]
        read_only_fields = fields

    def get_actor_name(self, obj) -> str | None:
        if obj.actor is None:
            return None
        return obj.actor.display_name or obj.actor.username


class MembershipSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()
    user_phone = serializers.SerializerMethodField()

    class Meta:
        model = Membership
        fields = [
            "id",
            "user",
            "user_name",
            "user_phone",
            "business",
            "role",
            "locations",
            "is_active",
        ]
        read_only_fields = ["id"]

    def get_user_name(self, obj) -> str:
        return obj.user.display_name or obj.user.username

    def get_user_phone(self, obj) -> str:
        return obj.user.phone_e164

    def validate(self, attrs):
        if (
            self.instance
            and "business" in attrs
            and attrs["business"].pk != self.instance.business_id
        ):
            raise serializers.ValidationError("A membership cannot move between businesses")
        business = attrs.get("business") or getattr(self.instance, "business", None)
        for location in attrs.get("locations", []):
            if location.business_id != business.id:
                raise serializers.ValidationError(
                    "Every assigned location must belong to the business"
                )
        return attrs


class InvitationSerializer(serializers.ModelSerializer):
    """Safe invitation representation; the persisted token digest is never exposed."""

    status = serializers.SerializerMethodField()

    class Meta:
        model = Invitation
        fields = [
            "id",
            "business",
            "invitee_phone",
            "role",
            "locations",
            "status",
            "expires_at",
            "inviter",
            "accepted_by",
            "accepted_at",
            "revoked_at",
            "created_at",
            "updated_at",
        ]
        read_only_fields = fields

    def get_status(self, obj: Invitation) -> str:
        return obj.effective_status


class InvitationCreateSerializer(serializers.Serializer):
    business = serializers.PrimaryKeyRelatedField(queryset=Business.objects.all())
    invitee_phone = serializers.CharField(max_length=20)
    role = serializers.ChoiceField(choices=Membership.Role.choices)
    locations = serializers.PrimaryKeyRelatedField(
        many=True, queryset=Location.objects.all(), required=False, allow_empty=True
    )
    expires_at = serializers.DateTimeField(required=False)

    def validate_invitee_phone(self, value: str) -> str:
        normalized = re.sub(r"[\s()-]", "", value)
        if not INVITEE_PHONE_REGEX.match(normalized):
            raise serializers.ValidationError(
                "Enter a valid phone number with country code, e.g. +919876543210."
            )
        return normalized

    def validate_expires_at(self, value):
        now = timezone.now()
        if value <= now:
            raise serializers.ValidationError("Expiry must be in the future.")
        if value > now + timedelta(days=30):
            raise serializers.ValidationError("Invitations can expire at most 30 days from now.")
        return value

    def validate(self, attrs: dict) -> dict:
        business = attrs["business"]
        if not business.is_active:
            raise serializers.ValidationError({"business": "This business is inactive."})

        locations = attrs.get("locations", [])
        location_ids = [location.pk for location in locations]
        if len(location_ids) != len(set(location_ids)):
            raise serializers.ValidationError({"locations": "Locations must be unique."})
        for location in locations:
            if location.business_id != business.pk:
                raise serializers.ValidationError(
                    {"locations": "Every assigned location must belong to the business."}
                )
            if not location.is_active:
                raise serializers.ValidationError(
                    {"locations": "Inactive locations cannot be assigned."}
                )
        return attrs

    @transaction.atomic
    def create(self, validated_data: dict) -> Invitation:
        expires_at = validated_data.pop("expires_at", None)
        locations = validated_data.pop("locations", [])
        invitation, raw_token = Invitation.create_with_token(
            **validated_data,
            inviter=self.context["request"].user,
            expires_at=expires_at,
        )
        invitation.locations.set(locations)
        invitation.record_audit(Invitation.AuditEventType.CREATED, self.context["request"].user)
        # Available only to the create view for its one-time delivery response;
        # it is not a model field and is never included by InvitationSerializer.
        invitation._raw_token = raw_token
        return invitation


class InvitationAcceptSerializer(serializers.Serializer):
    token = serializers.CharField(write_only=True, min_length=20, max_length=128)
