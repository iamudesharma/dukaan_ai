import re

from django.db import transaction
from rest_framework import serializers

from .models import Business, GSTRegistration, Invitation, Location, Membership

PHONE_REGEX = re.compile(r"^\+[1-9]\d{6,14}$")


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

    def get_is_primary(self, obj):
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

    class Meta:
        model = Business
        fields = [
            "id",
            "name",
            "legal_name",
            "currency",
            "timezone",
            "gst_enabled",
            "default_price_mode",
            "negative_stock_allowed",
            "is_active",
            "role",
            "locations",
        ]
        read_only_fields = ["id", "is_active", "role", "locations"]

    def validate_default_price_mode(self, value):
        from apps.operations.models import Sale

        if value not in Sale.PriceMode.values:
            raise serializers.ValidationError("Price mode must be RETAIL or WHOLESALE")
        return value

    def get_role(self, obj):
        user = self.context["request"].user
        membership = obj.memberships.filter(user=user, is_active=True).first()
        return membership.role if membership else None

    @transaction.atomic
    def create(self, validated_data):
        from django.db import connection

        from apps.tenancy import rls

        business = Business.objects.create(**validated_data)
        # The RLS WITH CHECK requires the new business to already be in
        # scope. Its UUID is server-generated, so expanding scope here is
        # safe: the caller cannot choose or guess it.
        rls.expand_tenant_scope(connection, business.pk)
        Membership.objects.create(
            user=self.context["request"].user, business=business, role=Membership.Role.OWNER
        )
        Location.objects.create(business=business, code="MAIN", name="Main Shop")
        # New memberships change the request's business list; the expanded
        # scope already covers the created business for the rest of the call.
        return business


class InvitationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Invitation
        fields = [
            "id",
            "business",
            "phone_e164",
            "role",
            "locations",
            "status",
            "expires_at",
            "created_at",
        ]
        read_only_fields = ["id", "status", "expires_at", "created_at"]

    def validate_phone_e164(self, value: str) -> str:
        normalized = re.sub(r"[\s()-]", "", value)
        if not PHONE_REGEX.match(normalized):
            raise serializers.ValidationError(
                "Enter a valid phone number with country code, e.g. +919876543210."
            )
        return normalized

    def validate_role(self, value):
        if value == Membership.Role.OWNER:
            raise serializers.ValidationError("Ownership is transferred, not invited")
        if value not in Membership.Role.values:
            raise serializers.ValidationError("Unknown role")
        return value

    def validate(self, attrs):
        from .models import Membership as MembershipModel

        business = attrs.get("business") or getattr(self.instance, "business", None)
        for location in attrs.get("locations", []):
            if location.business_id != business.id:
                raise serializers.ValidationError(
                    "Every assigned location must belong to the business"
                )
        if self.instance is None and business is not None:
            phone = attrs.get("phone_e164", "")
            user_model = MembershipModel.user.field.related_model
            existing_user = user_model.objects.filter(phone_e164=phone, is_active=True).first()
            if (
                existing_user
                and MembershipModel.objects.filter(
                    user=existing_user, business=business, is_active=True
                ).exists()
            ):
                raise serializers.ValidationError("This phone number is already a member")
            if Invitation.objects.filter(
                business=business, phone_e164=phone, status=Invitation.Status.PENDING
            ).exists():
                raise serializers.ValidationError("A pending invitation already exists")
        return attrs


class AcceptInvitationSerializer(serializers.Serializer):
    token = serializers.UUIDField()


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

    def get_user_name(self, obj):
        return obj.user.display_name or obj.user.username

    def get_user_phone(self, obj):
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
