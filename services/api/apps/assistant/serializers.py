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


class CancelSerializer(serializers.Serializer):
    version = serializers.IntegerField(min_value=1)


class ReviseSerializer(serializers.Serializer):
    version = serializers.IntegerField(min_value=1)
    content = serializers.CharField(max_length=5000, required=False)
