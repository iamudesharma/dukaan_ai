from django.db import transaction
from rest_framework import serializers

from .models import Business, GSTRegistration, Location, Membership


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
            "negative_stock_allowed",
            "is_active",
            "role",
            "locations",
        ]
        read_only_fields = ["id", "is_active", "role", "locations"]

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
