from django.conf import settings
from rest_framework import serializers

from apps.tenancy.models import Business, Location

from .models import AssistantProposal, Attachment
from .storage import ALLOWED_MIMES


class InterpretSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )
    input_type = serializers.ChoiceField(
        choices=AssistantProposal.InputType.choices, default=AssistantProposal.InputType.TEXT
    )
    content = serializers.CharField(max_length=5000)
    locale = serializers.CharField(max_length=16, default="hi-IN")


class AssistantProposalSerializer(serializers.ModelSerializer):
    class Meta:
        model = AssistantProposal
        fields = [
            "id",
            "business",
            "location",
            "input_type",
            "locale",
            "content",
            "command_type",
            "payload",
            "preview",
            "preview_data",
            "warnings",
            "blocking_questions",
            "status",
            "version",
            "expires_at",
            "confirmed_at",
            "confirmed_result_type",
            "confirmed_result_id",
            "created_at",
        ]
        read_only_fields = fields


class ConfirmSerializer(serializers.Serializer):
    version = serializers.IntegerField(min_value=1)
    idempotency_key = serializers.CharField(max_length=128)
    negative_stock_acknowledged = serializers.BooleanField(default=False)
    negative_stock_reason = serializers.CharField(
        max_length=240, required=False, allow_blank=True, default=""
    )


class CancelSerializer(serializers.Serializer):
    version = serializers.IntegerField(min_value=1)


class ReviseSerializer(serializers.Serializer):
    version = serializers.IntegerField(min_value=1)
    content = serializers.CharField(max_length=5000, required=False)


class PresignSerializer(serializers.Serializer):
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    kind = serializers.ChoiceField(choices=Attachment.Kind.choices)
    mime = serializers.CharField(max_length=64)
    size_bytes = serializers.IntegerField(min_value=1)
    sha256 = serializers.RegexField(r"^[0-9a-fA-F]{64}$", required=False, allow_blank=True)

    def validate_mime(self, value):
        if value.lower() not in ALLOWED_MIMES:
            raise serializers.ValidationError("Unsupported upload type")
        return value.lower()

    def validate(self, attrs):
        limit = int(getattr(settings, "ATTACHMENT_MAX_BYTES", 8 * 1024 * 1024))
        if attrs["size_bytes"] > limit:
            raise serializers.ValidationError(f"File exceeds the {limit} byte upload limit")
        return attrs


class AttachmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attachment
        fields = [
            "id",
            "business",
            "kind",
            "mime",
            "size_bytes",
            "status",
            "proposal",
            "created_at",
        ]
        read_only_fields = fields


class FromAudioSerializer(serializers.Serializer):
    attachment_id = serializers.PrimaryKeyRelatedField(
        source="attachment", queryset=Attachment.objects.all()
    )
    business_id = serializers.PrimaryKeyRelatedField(
        source="business", queryset=Business.objects.filter(is_active=True)
    )
    location_id = serializers.PrimaryKeyRelatedField(
        source="location", queryset=Location.objects.filter(is_active=True)
    )
    locale = serializers.CharField(max_length=16, default="hi-IN")


class FromImageSerializer(FromAudioSerializer):
    """Same proposal coordinates as audio; the view enforces IMAGE ownership."""
