"""Durable reminder scheduling and outbox-driven push delivery."""

from __future__ import annotations

import logging

from django.conf import settings
from django.core.exceptions import ValidationError as DjangoValidationError
from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from apps.operations.models import Expense, Payment, Purchase, Sale, StockTransfer
from apps.tenancy.models import Membership, OutboxEvent

from .models import NotificationDelivery, NotificationDevice, Reminder
from .push import FCMError, get_fcm_sender

logger = logging.getLogger(__name__)

REMINDER_TOPIC = "notification.reminder"


def schedule_reminder(
    *,
    user,
    business,
    location,
    title: str,
    body: str,
    scheduled_at,
    dedupe_key: str,
    kind: str = Reminder.Kind.USER,
    data: dict | None = None,
    metadata: dict | None = None,
    source_event: OutboxEvent | None = None,
) -> tuple[Reminder, bool]:
    """Persist a reminder and its dispatch intent atomically.

    The unique user/business/dedupe constraint makes client retries return the
    original reminder. Terminal reminders are never rescheduled by a replay.
    """
    with transaction.atomic():
        reminder, created = Reminder.objects.get_or_create(
            user=user,
            business=business,
            dedupe_key=dedupe_key,
            defaults={
                "location": location,
                "kind": kind,
                "title": title,
                "body": body,
                "scheduled_at": scheduled_at,
                "data": data or {},
                "metadata": metadata or {},
                "source_event": source_event,
            },
        )
        if reminder.status in {
            Reminder.Status.SCHEDULED,
            Reminder.Status.QUEUED,
        }:
            OutboxEvent.objects.get_or_create(
                dedupe_key=f"reminder:{reminder.id}",
                defaults={
                    "business": business,
                    "topic": REMINDER_TOPIC,
                    "payload": {"reminder_id": str(reminder.id)},
                    "available_at": reminder.scheduled_at,
                },
            )
        return reminder, created


_DOCUMENT_MODELS = {
    "operations.sale": Sale,
    "operations.purchase": Purchase,
    "operations.payment": Payment,
    "operations.expense": Expense,
    "operations.stocktransfer": StockTransfer,
}
_DOCUMENT_LABELS = {
    "sale": "Sale",
    "purchase": "Purchase",
    "payment": "Payment",
    "expense": "Expense",
    "transfer": "Transfer",
}


def enqueue_domain_notification(event: OutboxEvent) -> None:
    """Create a second durable outbox intent for a posted/reversed document.

    This handler performs no provider I/O. Missing documents are acknowledged
    because test/import fixtures may carry only routing metadata.
    """
    payload = event.payload if isinstance(event.payload, dict) else {}
    model = _DOCUMENT_MODELS.get(str(payload.get("type", "")))
    document_id = payload.get("id")
    if model is None or not document_id:
        return
    try:
        document = model.objects.select_related("business").get(pk=document_id)
    except (model.DoesNotExist, DjangoValidationError, ValueError, TypeError):
        return
    if event.business_id is not None and document.business_id != event.business_id:
        return

    location = getattr(document, "location", None) or getattr(document, "to_location", None)
    membership = Membership.objects.filter(
        user=document.created_by,
        business=document.business,
        is_active=True,
    ).first()
    if membership is None:
        return
    if (
        location is not None
        and membership.role != Membership.Role.OWNER
        and not membership.locations.filter(pk=location.pk).exists()
    ):
        return

    action = "reversed" if event.topic.endswith(".reversed") else "posted"
    document_kind = event.topic.split(".", 1)[0]
    label = _DOCUMENT_LABELS.get(document_kind, document_kind.title())
    identifier = str(getattr(document, "number", "") or getattr(document, "reference", "")).strip()
    body = f"{label} {identifier} was {action}." if identifier else f"{label} was {action}."
    schedule_reminder(
        user=document.created_by,
        business=document.business,
        location=location,
        title=f"{label} {action}",
        body=body,
        scheduled_at=timezone.now(),
        dedupe_key=f"domain:{event.dedupe_key}",
        kind=Reminder.Kind.DOMAIN,
        data={
            "event_id": str(event.id),
            "document_id": str(document.id),
            "topic": event.topic,
            "business_id": str(document.business_id),
            "location_id": str(location.id) if location else "",
        },
        metadata={"source": "outbox", "topic": event.topic},
        source_event=event,
    )


def _device_queryset(reminder: Reminder):
    membership = Membership.objects.filter(
        user=reminder.user,
        business=reminder.business,
        is_active=True,
    ).first()
    if membership is None:
        return NotificationDevice.objects.none()
    if (
        reminder.location_id is not None
        and membership.role != Membership.Role.OWNER
        and not membership.locations.filter(pk=reminder.location_id).exists()
    ):
        return NotificationDevice.objects.none()
    devices = NotificationDevice.objects.filter(
        user=reminder.user,
        business=reminder.business,
        status=NotificationDevice.Status.ACTIVE,
    )
    if reminder.location_id is not None:
        devices = devices.filter(Q(location__isnull=True) | Q(location_id=reminder.location_id))
    return devices.order_by("created_at")


def _save_delivery(delivery: NotificationDelivery, *fields: str) -> None:
    delivery.save(update_fields=[*fields, "updated_at"])


def deliver_reminder(reminder_id: str) -> str:
    """Fan out one reminder, recording per-device idempotency and failures.

    Successful device deliveries commit before a transient failure asks the
    outbox worker to retry. Redelivery therefore sends only unfinished rows.
    """
    with transaction.atomic():
        try:
            reminder = Reminder.objects.select_for_update().get(pk=reminder_id)
        except (Reminder.DoesNotExist, DjangoValidationError, ValueError, TypeError):
            return "missing"
        if reminder.status in {
            Reminder.Status.SENT,
            Reminder.Status.FAILED,
            Reminder.Status.CANCELLED,
            Reminder.Status.SKIPPED,
        }:
            return "already-processed"

        reminder.status = Reminder.Status.QUEUED
        reminder.queued_at = timezone.now()
        reminder.save(update_fields=["status", "queued_at", "updated_at"])
        devices = list(_device_queryset(reminder))
        if not devices:
            reminder.status = Reminder.Status.SKIPPED
            reminder.last_error = ""
            reminder.save(update_fields=["status", "last_error", "updated_at"])
            return "skipped"

        if not getattr(settings, "FCM_ENABLED", False):
            for device in devices:
                delivery, _ = NotificationDelivery.objects.get_or_create(
                    reminder=reminder,
                    device=device,
                    defaults={"dedupe_key": f"{reminder.dedupe_key}:{device.id}"},
                )
                if delivery.status != NotificationDelivery.Status.SENT:
                    delivery.status = NotificationDelivery.Status.SKIPPED
                    delivery.last_error = ""
                    _save_delivery(delivery, "status", "last_error")
            reminder.status = Reminder.Status.SKIPPED
            reminder.last_error = ""
            reminder.save(update_fields=["status", "last_error", "updated_at"])
            return "skipped"

        sender = get_fcm_sender()
        retryable = False
        first_error = ""
        sent_any = False
        failed_any = False
        for device in devices:
            delivery, _ = NotificationDelivery.objects.get_or_create(
                reminder=reminder,
                device=device,
                defaults={"dedupe_key": f"{reminder.dedupe_key}:{device.id}"},
            )
            if delivery.status in {
                NotificationDelivery.Status.SENT,
                NotificationDelivery.Status.SKIPPED,
            }:
                sent_any = sent_any or delivery.status == NotificationDelivery.Status.SENT
                continue

            delivery.attempts += 1
            try:
                message_id = sender.send(
                    token=device.fcm_token,
                    title=reminder.title,
                    body=reminder.body,
                    dedupe_key=delivery.dedupe_key,
                    data={
                        **reminder.data,
                        "reminder_id": str(reminder.id),
                        "business_id": str(reminder.business_id),
                        "location_id": str(reminder.location_id or ""),
                    },
                )
            except FCMError as exc:
                delivery.last_error = str(exc)[:240]
                if exc.code == "disabled":
                    delivery.status = NotificationDelivery.Status.SKIPPED
                    _save_delivery(delivery, "attempts", "status", "last_error")
                    reminder.status = Reminder.Status.SKIPPED
                    reminder.last_error = ""
                    reminder.save(update_fields=["status", "last_error", "updated_at"])
                    return "skipped"
                if exc.retryable:
                    delivery.status = NotificationDelivery.Status.PENDING
                    retryable = True
                    first_error = first_error or delivery.last_error
                else:
                    delivery.status = NotificationDelivery.Status.FAILED
                    failed_any = True
                    first_error = first_error or delivery.last_error
                    if exc.status_code == 404:
                        device.status = NotificationDevice.Status.DISABLED
                        device.unregistered_at = timezone.now()
                        device.save(update_fields=["status", "unregistered_at", "updated_at"])
                _save_delivery(delivery, "attempts", "status", "last_error")
                continue
            except Exception as exc:
                # A provider adapter must not leak tokens or response bodies.
                logger.warning("FCM delivery failed: %s", type(exc).__name__)
                delivery.status = NotificationDelivery.Status.PENDING
                delivery.last_error = "Push delivery failed unexpectedly."
                retryable = True
                first_error = first_error or delivery.last_error
                _save_delivery(delivery, "attempts", "status", "last_error")
                continue

            delivery.status = NotificationDelivery.Status.SENT
            delivery.provider_message_id = message_id[:255]
            delivery.sent_at = timezone.now()
            delivery.last_error = ""
            sent_any = True
            _save_delivery(
                delivery,
                "attempts",
                "status",
                "provider_message_id",
                "last_error",
                "sent_at",
            )

        if retryable:
            reminder.status = Reminder.Status.SCHEDULED
            reminder.last_error = first_error[:240]
            reminder.save(update_fields=["status", "last_error", "updated_at"])
            # Return only after this atomic block commits its per-device
            # evidence. The outbox handler can then request a durable retry
            # without rolling successful deliveries back.
            return "retry"

        reminder.status = Reminder.Status.FAILED if failed_any else Reminder.Status.SENT
        reminder.sent_at = timezone.now() if sent_any else None
        reminder.last_error = first_error[:240]
        reminder.save(update_fields=["status", "sent_at", "last_error", "updated_at"])
        return "failed" if failed_any else "sent"
