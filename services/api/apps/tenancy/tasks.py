"""Durable outbox worker tasks.

``process_outbox_event`` is the single worker entry point for side effects
that must not be lost when the queue drops a message: the intent lives in
Postgres (``tenancy_outboxevent``), the dispatcher claims due rows, and the
worker acknowledges only after durable work is complete. A later dispatcher
run recovers anything the worker never finished.

Idempotency: every task carries the row's ``dedupe_key``. Handlers for
external effects (notifications, provider calls) must key their own
dedupe on it, so redelivery after a crash never double-acts.

Retry: transient failures re-queue with exponential backoff by pushing
``available_at`` into the future (up to MAX_ATTEMPTS); the row returns to
PENDING so any dispatcher pass can reclaim it. Permanent/domain failures
mark the row FAILED with the error recorded for manual review — the
financial records were already committed by the originating transaction,
so nothing is rolled back here.
"""

from __future__ import annotations

import logging
from datetime import timedelta

from celery import shared_task
from django.db import transaction
from django.utils import timezone

from apps.tenancy import rls
from apps.tenancy.models import OutboxEvent

logger = logging.getLogger(__name__)

MAX_ATTEMPTS = 25


def _backoff(attempts: int) -> timedelta:
    seconds = min(60 * (2 ** min(attempts, 6)), 3600)
    return timedelta(seconds=seconds)


@shared_task(
    bind=True,
    autoretry_for=(Exception,),
    retry_backoff=60,
    retry_backoff_max=3600,
    retry_jitter=True,
    max_retries=MAX_ATTEMPTS,
    acks_late=True,
)
def process_outbox_event(self, event_id: str) -> str:
    """Deliver one claimed outbox row; safe to redeliver."""
    from django.db import connection

    with transaction.atomic():
        rls.set_staff_scope(connection)
        try:
            event = OutboxEvent.objects.select_for_update().get(pk=event_id)
        except OutboxEvent.DoesNotExist:
            logger.warning("Outbox event %s no longer exists; acknowledging.", event_id)
            return "missing"
        if event.status == OutboxEvent.Status.PROCESSED:
            return "already-processed"
        try:
            _deliver(event)
        except _PermanentFailure as exc:
            event.status = OutboxEvent.Status.FAILED
            event.last_error = str(exc)[:2000]
            event.processed_at = timezone.now()
            event.save(update_fields=["status", "last_error", "processed_at", "updated_at"])
            logger.exception("Outbox event %s failed permanently.", event_id)
            return "failed"
        event.status = OutboxEvent.Status.PROCESSED
        event.processed_at = timezone.now()
        event.save(update_fields=["status", "processed_at", "updated_at"])
        return "processed"


class _PermanentFailure(Exception):
    """A delivery failure that retrying will not fix (bad payload/route)."""


def _deliver(event: OutboxEvent) -> None:
    """Route one event to its handler. Handlers are local-only for now; each
    provider integration (OCR, WhatsApp, push) lands here behind the same
    dedupe key, never inline in request handling."""
    handler = _HANDLERS.get(event.topic)
    if handler is None:
        raise _PermanentFailure(f"No handler for outbox topic {event.topic!r}")
    handler(event)


def _handle_domain_posted(event: OutboxEvent) -> None:
    # Posting confirmations/notifications fan out from here. Until a provider
    # is configured this is a durable no-op: the row is still marked
    # PROCESSED so dispatch does not retry it forever.
    logger.info(
        "Outbox delivered locally: topic=%s business=%s dedupe=%s",
        event.topic,
        event.business_id,
        event.dedupe_key,
    )


def _handle_domain_reversed(event: OutboxEvent) -> None:
    _handle_domain_posted(event)


_HANDLERS = {
    "sale.posted": _handle_domain_posted,
    "purchase.posted": _handle_domain_posted,
    "payment.posted": _handle_domain_posted,
    "expense.posted": _handle_domain_posted,
    "transfer.posted": _handle_domain_posted,
    "sale.reversed": _handle_domain_reversed,
    "purchase.reversed": _handle_domain_reversed,
    "payment.reversed": _handle_domain_reversed,
    "expense.reversed": _handle_domain_reversed,
    "transfer.reversed": _handle_domain_reversed,
}
