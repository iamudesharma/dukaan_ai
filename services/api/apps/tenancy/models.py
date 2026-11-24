import hashlib
import secrets
from datetime import timedelta

from django.conf import settings
from django.core.validators import RegexValidator
from django.db import models
from django.utils import timezone

from apps.common.models import UUIDModel

gstin_validator = RegexValidator(
    regex=r"^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$",
    message="Enter a valid 15-character GSTIN.",
)
invitee_phone_validator = RegexValidator(
    regex=r"^\+[1-9]\d{6,14}$",
    message="Enter a valid phone number with country code, e.g. +919876543210.",
)


class Business(UUIDModel):
    name = models.CharField(max_length=160)
    legal_name = models.CharField(max_length=200, blank=True)
    currency = models.CharField(max_length=3, default="INR")
    timezone = models.CharField(max_length=64, default="Asia/Kolkata")
    gst_enabled = models.BooleanField(default=False)
    negative_stock_allowed = models.BooleanField(default=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        verbose_name_plural = "businesses"

    def __str__(self) -> str:
        return self.name


class GSTRegistration(UUIDModel):
    business = models.ForeignKey(
        Business, on_delete=models.PROTECT, related_name="gst_registrations"
    )
    gstin = models.CharField(max_length=15, validators=[gstin_validator])
    legal_name = models.CharField(max_length=200)
    address = models.TextField(blank=True)
    state_code = models.CharField(max_length=2)
    invoice_prefix = models.CharField(max_length=8, default="INV")
    is_active = models.BooleanField(default=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["business", "gstin"], name="uniq_business_gstin")
        ]


class Location(UUIDModel):
    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="locations")
    gst_registration = models.ForeignKey(
        GSTRegistration,
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        related_name="locations",
    )
    code = models.CharField(max_length=20)
    name = models.CharField(max_length=160)
    address = models.TextField(blank=True)
    state_code = models.CharField(max_length=2, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["business", "code"], name="uniq_location_code")
        ]

    def __str__(self) -> str:
        return f"{self.business.name} / {self.name}"


class Membership(UUIDModel):
    class Role(models.TextChoices):
        OWNER = "OWNER", "Owner"
        MANAGER = "MANAGER", "Manager"
        CASHIER = "CASHIER", "Cashier"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="memberships"
    )
    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="memberships")
    role = models.CharField(max_length=10, choices=Role.choices)
    locations = models.ManyToManyField(Location, blank=True, related_name="memberships")
    is_active = models.BooleanField(default=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["user", "business"], name="uniq_user_business")
        ]


class Invitation(UUIDModel):
    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        ACCEPTED = "ACCEPTED", "Accepted"
        REVOKED = "REVOKED", "Revoked"
        EXPIRED = "EXPIRED", "Expired"

    class AuditEventType(models.TextChoices):
        CREATED = "invitation.created", "Invitation created"
        REVOKED = "invitation.revoked", "Invitation revoked"
        ACCEPTED = "invitation.accepted", "Invitation accepted"

    DEFAULT_EXPIRY_DAYS = 7
    TOKEN_BYTES = 32

    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="invitations")
    invitee_phone = models.CharField(
        max_length=20, validators=[invitee_phone_validator], db_index=True
    )
    role = models.CharField(max_length=10, choices=Membership.Role.choices)
    locations = models.ManyToManyField(Location, blank=True, related_name="invitations")
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.PENDING)
    token_hash = models.CharField(max_length=64, unique=True, editable=False)
    expires_at = models.DateTimeField()
    inviter = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="sent_invitations"
    )
    accepted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="accepted_invitations",
    )
    accepted_at = models.DateTimeField(null=True, blank=True)
    revoked_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["business", "status", "created_at"]),
            models.Index(fields=["invitee_phone", "status"]),
            models.Index(fields=["status", "expires_at"]),
        ]

    def __str__(self) -> str:
        return f"{self.business.name} invitation for {self.invitee_phone}"

    @staticmethod
    def hash_token(token: str) -> str:
        return hashlib.sha256(token.encode()).hexdigest()

    @classmethod
    def create_with_token(cls, *, expires_at=None, **fields) -> tuple["Invitation", str]:
        """Create an invite and return its raw token exactly once.

        Only the SHA-256 digest is persisted. Callers may deliver the returned
        token to the invitee, but API serializers never expose the digest.
        """
        raw_token = secrets.token_urlsafe(cls.TOKEN_BYTES)
        invitation = cls.objects.create(
            **fields,
            token_hash=cls.hash_token(raw_token),
            expires_at=expires_at or timezone.now() + timedelta(days=cls.DEFAULT_EXPIRY_DAYS),
        )
        return invitation, raw_token

    @property
    def is_expired(self) -> bool:
        return self.expires_at <= timezone.now()

    @property
    def effective_status(self) -> str:
        if self.status == self.Status.PENDING and self.is_expired:
            return self.Status.EXPIRED
        return self.status

    def record_audit(self, event_type, actor, *, membership=None) -> "AuditEvent":
        """Record an allowlisted lifecycle event without invitation credentials."""
        if event_type not in self.AuditEventType.values:
            raise ValueError("Unsupported invitation audit event")
        metadata = {
            "invitation_id": str(self.pk),
            "status": self.status,
            "role": self.role,
            "location_ids": sorted(str(location.pk) for location in self.locations.all()),
            "expires_at": self.expires_at.isoformat(),
        }
        if membership is not None:
            metadata["membership_id"] = str(membership.pk)
        return AuditEvent.objects.create(
            business=self.business,
            actor=actor,
            event_type=event_type,
            aggregate_type=self._meta.label_lower,
            aggregate_id=self.pk,
            source="API",
            metadata=metadata,
        )


class IdempotencyRecord(UUIDModel):
    business = models.ForeignKey(
        Business, on_delete=models.PROTECT, related_name="idempotency_records"
    )
    actor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT)
    scope = models.CharField(max_length=64)
    key = models.CharField(max_length=128)
    result_type = models.CharField(max_length=64)
    result_id = models.UUIDField()

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["business", "actor", "scope", "key"],
                name="uniq_idempotency_scope",
            )
        ]


class AuditEvent(UUIDModel):
    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="audit_events")
    location = models.ForeignKey(Location, null=True, blank=True, on_delete=models.PROTECT)
    actor = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.PROTECT
    )
    event_type = models.CharField(max_length=80)
    aggregate_type = models.CharField(max_length=64)
    aggregate_id = models.UUIDField()
    source = models.CharField(max_length=32, default="API")
    metadata = models.JSONField(default=dict, blank=True)

    class Meta:
        indexes = [models.Index(fields=["business", "created_at"])]


class OutboxEvent(UUIDModel):
    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        PROCESSING = "PROCESSING", "Processing"
        PROCESSED = "PROCESSED", "Processed"
        FAILED = "FAILED", "Failed"

    business = models.ForeignKey(Business, null=True, blank=True, on_delete=models.PROTECT)
    topic = models.CharField(max_length=100)
    dedupe_key = models.CharField(max_length=160, unique=True)
    payload = models.JSONField(default=dict)
    status = models.CharField(max_length=12, choices=Status.choices, default=Status.PENDING)
    attempts = models.PositiveIntegerField(default=0)
    available_at = models.DateTimeField()
    processed_at = models.DateTimeField(null=True, blank=True)
    last_error = models.TextField(blank=True)

    class Meta:
        indexes = [models.Index(fields=["status", "available_at"])]
