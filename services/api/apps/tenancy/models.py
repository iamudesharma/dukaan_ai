import uuid

from django.conf import settings
from django.core.validators import RegexValidator
from django.db import models

from apps.common.models import UUIDModel

gstin_validator = RegexValidator(
    regex=r"^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$",
    message="Enter a valid 15-character GSTIN.",
)


class Business(UUIDModel):
    name = models.CharField(max_length=160)
    legal_name = models.CharField(max_length=200, blank=True)
    currency = models.CharField(max_length=3, default="INR")
    timezone = models.CharField(max_length=64, default="Asia/Kolkata")
    gst_enabled = models.BooleanField(default=False)
    negative_stock_allowed = models.BooleanField(default=True)
    default_price_mode = models.CharField(max_length=10, default="RETAIL")
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
    """Invite a phone number to join a business.

    The invitee accepts with an unguessable token after signing in with the
    matching phone number; acceptance creates the membership. Tokens never
    grant access on their own."""

    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        ACCEPTED = "ACCEPTED", "Accepted"
        REVOKED = "REVOKED", "Revoked"
        EXPIRED = "EXPIRED", "Expired"

    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="invitations")
    phone_e164 = models.CharField(max_length=20, db_index=True)
    role = models.CharField(max_length=10, choices=Membership.Role.choices)
    locations = models.ManyToManyField(Location, blank=True, related_name="invitations")
    token = models.UUIDField(default=uuid.uuid4, editable=False)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.PENDING)
    invited_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="sent_invitations"
    )
    expires_at = models.DateTimeField()

    class Meta:
        indexes = [models.Index(fields=["business", "status", "created_at"])]

    def __str__(self) -> str:
        return f"Invite {self.phone_e164} to {self.business_id} as {self.role}"


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
