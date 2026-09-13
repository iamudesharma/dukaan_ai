from rest_framework import serializers

from apps.tenancy.models import Business, Location

from .models import AssistantProposal


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
    content = serializers.CharField(max_length=5000, allow_blank=True, default="")
    locale = serializers.CharField(max_length=16, default="hi-IN")
    attachment_ids = serializers.ListField(
        child=serializers.UUIDField(), required=False, default=list, max_length=5
    )


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
            "attachments",
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
