from rest_framework import serializers

from .models import ImportJob


class ImportUploadSerializer(serializers.Serializer):
    business_id = serializers.UUIDField(required=False)
    business = serializers.UUIDField(required=False, write_only=True)
    file = serializers.FileField()
    dry_run = serializers.BooleanField(required=False, default=False)
    duplicate_strategy = serializers.CharField(
        required=False,
        default=ImportJob.DuplicateStrategy.UPDATE,
        max_length=8,
        help_text="UPDATE or SKIP (case-insensitive).",
    )

    def validate_business_id(self, value):
        return str(value)

    def validate_business(self, value):
        return str(value)

    def validate_duplicate_strategy(self, value):
        normalized = str(value).upper()
        if normalized not in ImportJob.DuplicateStrategy.values:
            raise serializers.ValidationError("Must be UPDATE or SKIP.")
        return normalized

    def validate(self, attrs):
        from_business_id = attrs.get("business_id")
        from_business = attrs.pop("business", None)
        if from_business_id and from_business and from_business_id != from_business:
            raise serializers.ValidationError(
                {"business_id": "business and business_id must refer to the same tenant."}
            )
        attrs["business_id"] = from_business_id or from_business
        if not attrs["business_id"]:
            raise serializers.ValidationError({"business_id": "This field is required."})
        return attrs


class ImportJobSerializer(serializers.ModelSerializer):
    class Meta:
        model = ImportJob
        fields = [
            "id",
            "business",
            "user",
            "confirmed_by",
            "kind",
            "status",
            "duplicate_strategy",
            "row_count",
            "valid_row_count",
            "error_count",
            "created_count",
            "updated_count",
            "skipped_count",
            "errors",
            "original_filename",
            "file_sha256",
            "file_size_bytes",
            "created_at",
            "updated_at",
            "confirmed_at",
        ]
        read_only_fields = fields


class ImportConfirmSerializer(serializers.Serializer):
    idempotency_key = serializers.CharField(
        required=False,
        allow_blank=True,
        max_length=128,
    )

    def validate_idempotency_key(self, value):
        return value.strip()


class ImportDryRunPreviewSerializer(serializers.Serializer):
    row = serializers.IntegerField(help_text="One-based CSV row number, including the header.")
    action = serializers.ChoiceField(choices=["CREATE", "UPDATE", "SKIP"])


class ImportDryRunSerializer(serializers.Serializer):
    dry_run = serializers.BooleanField()
    kind = serializers.ChoiceField(choices=ImportJob.Kind.choices)
    duplicate_strategy = serializers.ChoiceField(choices=ImportJob.DuplicateStrategy.choices)
    row_count = serializers.IntegerField()
    valid_row_count = serializers.IntegerField()
    error_count = serializers.IntegerField()
    errors = serializers.JSONField(
        help_text="Per-row validation errors; keys depend on the imported product or party columns."
    )
    created_count = serializers.IntegerField()
    updated_count = serializers.IntegerField()
    skipped_count = serializers.IntegerField()
    preview = ImportDryRunPreviewSerializer(many=True)


class ImportJobListSerializer(serializers.Serializer):
    count = serializers.IntegerField()
    next = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results = ImportJobSerializer(many=True)


class ImportConfirmResponseSerializer(serializers.Serializer):
    job = ImportJobSerializer()
    replayed = serializers.BooleanField()
