"""Phase 3 serializers: activity, reminders, exports, attachments."""

from rest_framework import serializers

from apps.catalog.models import Party

from .models import Attachment, ExportJob, Reminder
from .reports import REPORT_BUILDERS


class ActivitySerializer(serializers.Serializer):
    id = serializers.CharField()
    event_type = serializers.CharField()
    aggregate_type = serializers.CharField()
    aggregate_id = serializers.CharField()
    actor_id = serializers.CharField(allow_null=True)
    actor_name = serializers.CharField(allow_null=True)
    location_id = serializers.CharField(allow_null=True)
    source = serializers.CharField()
    metadata = serializers.DictField()
    created_at = serializers.DateTimeField()


class ReminderCreateSerializer(serializers.Serializer):
    business_id = serializers.UUIDField()
    party_id = serializers.PrimaryKeyRelatedField(queryset=Party.objects.filter(is_active=True))
    channel = serializers.ChoiceField(
        choices=Reminder.Channel.choices, default=Reminder.Channel.SHARE
    )
    location_id = serializers.UUIDField(required=False, allow_null=True)
    message = serializers.CharField(max_length=500, required=False, allow_blank=True)


class ReminderSerializer(serializers.ModelSerializer):
    party_name = serializers.CharField(source="party.name", read_only=True)

    class Meta:
        model = Reminder
        fields = [
            "id",
            "business",
            "location",
            "party",
            "party_name",
            "channel",
            "message",
            "amount_minor",
            "status",
            "provider_message_id",
            "sent_at",
            "created_at",
        ]
        read_only_fields = fields


class ExportCreateSerializer(serializers.Serializer):
    business_id = serializers.UUIDField()
    report = serializers.ChoiceField(choices=[(name, name) for name in sorted(REPORT_BUILDERS)])
    format = serializers.ChoiceField(choices=ExportJob.Format.choices, default=ExportJob.Format.CSV)
    location_id = serializers.UUIDField(required=False, allow_null=True)
    from_date = serializers.DateField(required=False, allow_null=True)
    to_date = serializers.DateField(required=False, allow_null=True)
    group_by = serializers.CharField(max_length=16, required=False, default="day")


class ExportJobSerializer(serializers.ModelSerializer):
    download_url = serializers.SerializerMethodField()

    class Meta:
        model = ExportJob
        fields = [
            "id",
            "business",
            "report",
            "format",
            "params",
            "status",
            "error",
            "download_url",
            "created_at",
        ]
        read_only_fields = fields

    def get_download_url(self, obj):
        if obj.status == ExportJob.Status.READY and obj.file:
            return f"/api/v1/exports/{obj.pk}/?download=1"
        return None


class AttachmentSerializer(serializers.ModelSerializer):
    download_url = serializers.SerializerMethodField()

    class Meta:
        model = Attachment
        fields = [
            "id",
            "business",
            "kind",
            "sale",
            "mime_type",
            "size_bytes",
            "status",
            "error",
            "download_url",
            "created_at",
        ]
        read_only_fields = fields

    def get_download_url(self, obj):
        if obj.status == Attachment.Status.READY and obj.file:
            return f"/api/v1/attachments/{obj.pk}/?download=1"
        return None
