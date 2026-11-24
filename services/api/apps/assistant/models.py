from datetime import timedelta

from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models
from django.utils import timezone

from apps.common.models import UUIDModel
from apps.tenancy.models import Business, Location


def _retention_days(setting_name: str, default: int) -> int:
    try:
        value = int(getattr(settings, setting_name, default))
    except (TypeError, ValueError):
        return default
    return max(1, value)


def attachment_retention_expiry():
    """Default object-retention deadline for newly created attachments."""
    return timezone.now() + timedelta(days=_retention_days("ATTACHMENT_RETENTION_DAYS", 30))


class AssistantProposal(UUIDModel):
    class InputType(models.TextChoices):
        TEXT = "TEXT", "Text"
        VOICE = "VOICE", "Voice transcript"
        IMAGE = "IMAGE", "Image OCR text"

    class Status(models.TextChoices):
        DRAFT = "DRAFT", "Needs clarification"
        READY = "READY", "Ready to confirm"
        CONFIRMED = "CONFIRMED", "Confirmed"
        CANCELLED = "CANCELLED", "Cancelled"
        EXPIRED = "EXPIRED", "Expired"

    business = models.ForeignKey(
        Business, on_delete=models.PROTECT, related_name="assistant_proposals"
    )
    location = models.ForeignKey(
        Location, on_delete=models.PROTECT, related_name="assistant_proposals"
    )
    actor = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="assistant_proposals"
    )
    input_type = models.CharField(max_length=8, choices=InputType.choices)
    locale = models.CharField(max_length=16, default="hi-IN")
    content = models.TextField()
    command_type = models.CharField(max_length=32, default="UNSUPPORTED")
    payload = models.JSONField(default=dict)
    preview = models.TextField(blank=True)
    warnings = models.JSONField(default=list)
    blocking_questions = models.JSONField(default=list)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.DRAFT)
    version = models.PositiveIntegerField(default=1)
    data_fingerprint = models.CharField(max_length=64, blank=True)
    expires_at = models.DateTimeField()
    confirmed_at = models.DateTimeField(null=True, blank=True)
    confirmed_result_type = models.CharField(max_length=64, blank=True)
    confirmed_result_id = models.UUIDField(null=True, blank=True)
    confirmation_idempotency_key = models.CharField(max_length=128, blank=True)

    class Meta:
        indexes = [models.Index(fields=["business", "actor", "status", "created_at"])]


class ProposalRevision(UUIDModel):
    """Append-only review evidence; lifecycle state remains on the proposal."""

    proposal = models.ForeignKey(
        AssistantProposal, on_delete=models.PROTECT, related_name="revisions"
    )
    version = models.PositiveIntegerField()
    snapshot = models.JSONField()
    data_fingerprint = models.CharField(max_length=64)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["proposal", "version"], name="uniq_proposal_revision")
        ]
        ordering = ["version"]


class Attachment(UUIDModel):
    """Tenant-owned upload record. Bytes live in private object storage;
    Postgres carries only identity, tenancy, and processing state."""

    class Kind(models.TextChoices):
        VOICE = "VOICE", "Voice recording"
        IMAGE = "IMAGE", "Image or scan"

    class Status(models.TextChoices):
        PENDING = "PENDING", "Awaiting upload"
        READY = "READY", "Uploaded"
        FAILED = "FAILED", "Rejected"

    class ScanStatus(models.TextChoices):
        PENDING = "PENDING", "Awaiting scan"
        CLEAN = "CLEAN", "Clean"
        QUARANTINED = "QUARANTINED", "Quarantined"
        FAILED = "FAILED", "Scan failed"

    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="attachments")
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="attachments"
    )
    proposal = models.ForeignKey(
        AssistantProposal,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="attachments",
    )
    kind = models.CharField(max_length=8, choices=Kind.choices)
    mime = models.CharField(max_length=64)
    size_bytes = models.BigIntegerField(validators=[MinValueValidator(1)])
    sha256 = models.CharField(max_length=64, blank=True)
    storage_path = models.CharField(max_length=512, unique=True)
    status = models.CharField(max_length=8, choices=Status.choices, default=Status.PENDING)
    scan_status = models.CharField(
        max_length=12, choices=ScanStatus.choices, default=ScanStatus.PENDING
    )
    quarantined_at = models.DateTimeField(null=True, blank=True)
    retention_expires_at = models.DateTimeField(default=attachment_retention_expiry)
    scan_details = models.JSONField(default=dict, blank=True)

    class Meta:
        indexes = [
            models.Index(fields=["business", "status", "created_at"]),
            models.Index(
                fields=["retention_expires_at", "scan_status"], name="attachment_retention_idx"
            ),
        ]

    @property
    def safe_for_processing(self) -> bool:
        return (
            self.scan_status == self.ScanStatus.CLEAN
            and self.quarantined_at is None
            and (self.retention_expires_at is None or self.retention_expires_at > timezone.now())
        )

    def retention_policy_allows(self, now) -> bool:
        """Whether object and row deletion is permitted by retention policy."""
        if self.retention_expires_at is None or self.retention_expires_at > now:
            return False
        # Quarantined bytes are never usable review evidence and may be purged
        # at their shorter quarantine deadline even if a proposal remains open.
        if self.scan_status == self.ScanStatus.QUARANTINED:
            return True
        # Open review work keeps its clean source object even after the ordinary
        # deadline. Terminal/no-proposal attachments are eligible for purge.
        if self.proposal_id is not None and self.proposal.status in {
            AssistantProposal.Status.DRAFT,
            AssistantProposal.Status.READY,
        }:
            return False
        return True
