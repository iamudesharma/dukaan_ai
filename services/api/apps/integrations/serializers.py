from django.utils import timezone
from drf_spectacular.utils import extend_schema_field
from rest_framework import serializers

from apps.tenancy.models import Business, Location

from .models import GmailImport, NotificationDevice, Reminder


class GmailImportSerializer(serializers.Serializer):
    message_id = serializers.CharField(max_length=128)
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )

    def validate(self, attrs):
        if attrs["location"].business_id != attrs["business"].id:
            raise serializers.ValidationError("Location does not belong to this business")
        return attrs


class GmailExtractedSerializer(serializers.Serializer):
    kind = serializers.ChoiceField(choices=["PAYMENT", "RECEIPT", "EXPENSE", "UNKNOWN"])
    direction = serializers.ChoiceField(choices=["RECEIPT", "PAYMENT"], allow_blank=True)
    party_name = serializers.CharField(allow_blank=True)
    amount_minor = serializers.IntegerField(allow_null=True)
    reference = serializers.CharField(allow_blank=True)
    confidence = serializers.FloatField(allow_null=True)


class GmailImportResultSerializer(serializers.ModelSerializer):
    extracted = serializers.SerializerMethodField()

    class Meta:
        model = GmailImport
        fields = [
            "id",
            "status",
            "subject",
            "received_at",
            "preview",
            "extracted",
        ]

    @extend_schema_field(GmailExtractedSerializer)
    def get_extracted(self, obj) -> dict:
        return {
            "kind": obj.kind,
            "direction": obj.direction,
            "party_name": obj.party_name,
            "amount_minor": obj.amount_minor,
            "reference": obj.reference,
            "confidence": obj.confidence,
        }


class NotificationDeviceRegistrationSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location",
        queryset=Location.objects.filter(is_active=True),
        required=False,
        allow_null=True,
    )
    fcm_token = serializers.CharField(max_length=512, write_only=True, trim_whitespace=True)
    platform = serializers.ChoiceField(
        choices=NotificationDevice.Platform.choices, default=NotificationDevice.Platform.ANDROID
    )
    metadata = serializers.JSONField(
        required=False,
        help_text="Arbitrary device metadata supplied by the client; must be a JSON object.",
    )

    def validate_fcm_token(self, value):
        if len(value) < 8 or any(character.isspace() for character in value):
            raise serializers.ValidationError("Enter a valid FCM registration token")
        return value

    def validate_metadata(self, value):
        if not isinstance(value, dict):
            raise serializers.ValidationError("Device metadata must be an object")
        return value

    def validate(self, attrs):
        location = attrs.get("location")
        if location is not None and location.business_id != attrs["business"].id:
            raise serializers.ValidationError("Location does not belong to this business")
        return attrs


class NotificationDeviceSerializer(serializers.ModelSerializer):
    token_suffix = serializers.SerializerMethodField()

    class Meta:
        model = NotificationDevice
        fields = [
            "id",
            "business",
            "location",
            "platform",
            "status",
            "token_suffix",
            "last_seen_at",
            "unregistered_at",
            "metadata",
            "created_at",
            "updated_at",
        ]
        read_only_fields = fields

    def get_token_suffix(self, obj) -> str:
        return f"…{obj.fcm_token[-4:]}" if obj.fcm_token else ""


class ReminderCreateSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location",
        queryset=Location.objects.filter(is_active=True),
        required=False,
        allow_null=True,
    )
    title = serializers.CharField(max_length=120)
    body = serializers.CharField(max_length=500)
    scheduled_at = serializers.DateTimeField()
    dedupe_key = serializers.CharField(max_length=160, required=False)
    data = serializers.JSONField(
        required=False,
        help_text="Arbitrary notification payload fields; must be a JSON object.",
    )

    def validate_data(self, value):
        if not isinstance(value, dict):
            raise serializers.ValidationError("Reminder data must be an object")
        return value

    def validate_scheduled_at(self, value):
        if value <= timezone.now():
            raise serializers.ValidationError("Reminder time must be in the future")
        return value

    def validate(self, attrs):
        location = attrs.get("location")
        if location is not None and location.business_id != attrs["business"].id:
            raise serializers.ValidationError("Location does not belong to this business")
        return attrs


class ReminderUpdateSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=120, required=False)
    body = serializers.CharField(max_length=500, required=False)
    scheduled_at = serializers.DateTimeField(required=False)

    def validate(self, attrs):
        if not attrs:
            raise serializers.ValidationError("Provide at least one reminder field to update")
        scheduled_at = attrs.get("scheduled_at")
        if scheduled_at is not None and scheduled_at <= timezone.now():
            raise serializers.ValidationError("Reminder time must be in the future")
        return attrs


class ReminderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reminder
        fields = [
            "id",
            "business",
            "location",
            "kind",
            "title",
            "body",
            "scheduled_at",
            "status",
            "dedupe_key",
            "data",
            "metadata",
            "queued_at",
            "sent_at",
            "cancelled_at",
            "last_error",
            "created_at",
            "updated_at",
        ]
        read_only_fields = fields


class GmailStatusSerializer(serializers.Serializer):
    connected = serializers.BooleanField()
    email = serializers.EmailField(allow_null=True)


class GmailConnectSerializer(serializers.Serializer):
    authorization_url = serializers.URLField()


class GmailMessageSerializer(serializers.Serializer):
    id = serializers.CharField()
    subject = serializers.CharField()
    snippet = serializers.CharField()
    received_at = serializers.DateTimeField(allow_null=True)


class GmailMessagesSerializer(serializers.Serializer):
    results = GmailMessageSerializer(many=True)


class GmailImportsSerializer(serializers.Serializer):
    results = GmailImportResultSerializer(many=True)
