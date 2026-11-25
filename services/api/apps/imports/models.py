from django.conf import settings
from django.db import models

from apps.common.models import UUIDModel
from apps.tenancy.models import Business


class ImportJob(UUIDModel):
    """A validated CSV snapshot and its confirmation state.

    ``rows`` contains only normalized, validated field values needed to apply
    the import. The uploaded file bytes are deliberately never persisted in
    Postgres; only the original filename, byte count, and SHA-256 digest are
    retained.
    """

    class Kind(models.TextChoices):
        PRODUCT = "PRODUCT", "Product"
        PARTY = "PARTY", "Party"

    class Status(models.TextChoices):
        READY = "READY", "Ready to confirm"
        INVALID = "INVALID", "Contains invalid rows"
        COMPLETED = "COMPLETED", "Completed"
        FAILED = "FAILED", "Failed"

    class DuplicateStrategy(models.TextChoices):
        UPDATE = "UPDATE", "Update existing rows"
        SKIP = "SKIP", "Skip existing rows"

    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="import_jobs")
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="import_jobs",
    )
    confirmed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="confirmed_import_jobs",
        null=True,
        blank=True,
    )
    kind = models.CharField(max_length=8, choices=Kind.choices)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.READY)
    duplicate_strategy = models.CharField(
        max_length=8,
        choices=DuplicateStrategy.choices,
        default=DuplicateStrategy.UPDATE,
    )

    row_count = models.PositiveIntegerField(default=0)
    valid_row_count = models.PositiveIntegerField(default=0)
    error_count = models.PositiveIntegerField(default=0)
    created_count = models.PositiveIntegerField(default=0)
    updated_count = models.PositiveIntegerField(default=0)
    skipped_count = models.PositiveIntegerField(default=0)
    errors = models.JSONField(default=list, blank=True)
    rows = models.JSONField(default=list, blank=True)

    original_filename = models.CharField(max_length=255)
    file_sha256 = models.CharField(max_length=64)
    file_size_bytes = models.PositiveIntegerField()
    confirmation_key = models.CharField(max_length=128, blank=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        indexes = [
            models.Index(fields=["business", "status", "created_at"]),
            models.Index(fields=["user", "created_at"]),
        ]

    def __str__(self) -> str:
        return f"{self.kind} import {self.pk}"
