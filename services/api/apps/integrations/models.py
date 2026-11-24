from django.conf import settings
from django.db import models
from django.utils import timezone

from apps.common.models import UUIDModel
from apps.tenancy.models import Business, Location


class GmailConnection(UUIDModel):
    """User-level OAuth connection. Tokens are encrypted at rest."""

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="gmail_connection",
    )
    email = models.EmailField()
    access_token_ciphertext = models.TextField()
    refresh_token_ciphertext = models.TextField()
    token_expiry = models.DateTimeField(null=True, blank=True)


class GmailImport(UUIDModel):
    """A reviewable financial fact extracted from one Gmail message."""

    class Status(models.TextChoices):
        NEEDS_REVIEW = "NEEDS_REVIEW", "Needs review"
        REVIEWED = "REVIEWED", "Reviewed"
        DISMISSED = "DISMISSED", "Dismissed"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="gmail_imports",
    )
    business = models.ForeignKey(Business, on_delete=models.CASCADE, related_name="gmail_imports")
    location = models.ForeignKey(Location, on_delete=models.CASCADE, related_name="gmail_imports")
    message_id = models.CharField(max_length=128)
    subject = models.CharField(max_length=500, blank=True)
    received_at = models.DateTimeField(null=True, blank=True)
    kind = models.CharField(max_length=16, default="UNKNOWN")
    direction = models.CharField(max_length=16, blank=True)
    party_name = models.CharField(max_length=200, blank=True)
    amount_minor = models.BigIntegerField(null=True, blank=True)
    reference = models.CharField(max_length=200, blank=True)
    confidence = models.FloatField(null=True, blank=True)
    preview = models.TextField(blank=True)
    raw_extraction = models.JSONField(default=dict)
    status = models.CharField(max_length=16, choices=Status.choices, default=Status.NEEDS_REVIEW)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["user", "business", "message_id"],
                name="gmail_import_unique_message_per_business",
            )
        ]
        indexes = [
            models.Index(
                fields=["business", "status", "created_at"], name="gmail_import_business_idx"
            )
        ]


class NotificationDevice(UUIDModel):
    """A push destination owned by one user within a business scope.

    Tokens are credentials: API serializers never return the full value. A
    device is disabled rather than deleted so registration and token rotation
    retain an audit trail.
    """

    class Status(models.TextChoices):
        ACTIVE = "ACTIVE", "Active"
        DISABLED = "DISABLED", "Disabled"

    class Platform(models.TextChoices):
        ANDROID = "ANDROID", "Android"
        IOS = "IOS", "iOS"
        WEB = "WEB", "Web"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="notification_devices"
    )
    business = models.ForeignKey(
        Business, on_delete=models.PROTECT, related_name="notification_devices"
    )
    location = models.ForeignKey(
        Location,
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        related_name="notification_devices",
    )
    fcm_token = models.CharField(max_length=512, unique=True)
    platform = models.CharField(max_length=8, choices=Platform.choices, default=Platform.ANDROID)
    status = models.CharField(max_length=8, choices=Status.choices, default=Status.ACTIVE)
    last_seen_at = models.DateTimeField(default=timezone.now)
    unregistered_at = models.DateTimeField(null=True, blank=True)
    metadata = models.JSONField(default=dict, blank=True)

    class Meta:
        indexes = [
            models.Index(fields=["user", "business", "status"], name="notif_device_scope_idx")
        ]

    def __str__(self) -> str:
        return f"{self.user_id} device ({self.status})"


class Reminder(UUIDModel):
    """Durable notification intent for a user reminder or domain event.

    Creation writes this row and its outbox event in one transaction. Delivery
    is performed only by the outbox worker; request handlers never call FCM.
    """

    class Kind(models.TextChoices):
        USER = "USER", "User reminder"
        DOMAIN = "DOMAIN", "Domain event"

    class Status(models.TextChoices):
        SCHEDULED = "SCHEDULED", "Scheduled"
        QUEUED = "QUEUED", "Queued"
        SENT = "SENT", "Sent"
        FAILED = "FAILED", "Failed"
        CANCELLED = "CANCELLED", "Cancelled"
        SKIPPED = "SKIPPED", "Skipped"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="reminders"
    )
    business = models.ForeignKey(Business, on_delete=models.PROTECT, related_name="reminders")
    location = models.ForeignKey(
        Location,
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        related_name="reminders",
    )
    kind = models.CharField(max_length=6, choices=Kind.choices, default=Kind.USER)
    title = models.CharField(max_length=120)
    body = models.CharField(max_length=500)
    scheduled_at = models.DateTimeField()
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.SCHEDULED)
    dedupe_key = models.CharField(max_length=180)
    data = models.JSONField(default=dict, blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    source_event = models.ForeignKey(
        "tenancy.OutboxEvent",
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        related_name="notification_reminders",
    )
    queued_at = models.DateTimeField(null=True, blank=True)
    sent_at = models.DateTimeField(null=True, blank=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    last_error = models.CharField(max_length=240, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["user", "business", "dedupe_key"],
                name="reminder_unique_per_user_business",
            )
        ]
        indexes = [
            models.Index(
                fields=["business", "status", "scheduled_at"], name="reminder_dispatch_idx"
            ),
            models.Index(fields=["user", "scheduled_at"], name="reminder_user_schedule_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.title} ({self.status})"


class NotificationDelivery(UUIDModel):
    """Per-device delivery evidence used as the push idempotency record."""

    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        SENT = "SENT", "Sent"
        FAILED = "FAILED", "Failed"
        SKIPPED = "SKIPPED", "Skipped"

    reminder = models.ForeignKey(Reminder, on_delete=models.CASCADE, related_name="deliveries")
    device = models.ForeignKey(
        NotificationDevice, on_delete=models.PROTECT, related_name="deliveries"
    )
    dedupe_key = models.CharField(max_length=255, unique=True)
    status = models.CharField(max_length=8, choices=Status.choices, default=Status.PENDING)
    attempts = models.PositiveIntegerField(default=0)
    provider_message_id = models.CharField(max_length=255, blank=True)
    last_error = models.CharField(max_length=240, blank=True)
    sent_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["reminder", "device"], name="notification_delivery_unique_device"
            )
        ]
        indexes = [models.Index(fields=["reminder", "status"], name="notif_delivery_status_idx")]
