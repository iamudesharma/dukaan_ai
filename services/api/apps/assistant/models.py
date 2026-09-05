from django.conf import settings
from django.db import models

from apps.common.models import UUIDModel
from apps.tenancy.models import Business, Location


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
