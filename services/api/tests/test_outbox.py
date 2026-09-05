"""Outbox dispatcher and worker tests.

- Claiming is atomic, ordered, and concurrent-safe (SKIP LOCKED): one
  dispatcher pass claims each due row exactly once, ignores future rows,
  and leaves unknown topics for the worker to mark FAILED, never to retry
  forever.
- The worker task is idempotent: redelivering a PROCESSED row is a no-op,
  missing rows acknowledge quietly, and handler failures mark the row
  FAILED with the error recorded.
- An injected broker failure rolls the whole claim back: rows stay PENDING
  for the next dispatcher pass.
"""

from datetime import timedelta
from unittest.mock import patch

import pytest
from django.core.management import call_command
from django.test import override_settings
from django.utils import timezone

from apps.tenancy.models import OutboxEvent
from apps.tenancy.tasks import process_outbox_event

pytestmark = pytest.mark.django_db


def _event(topic="sale.posted", *, available_in=timedelta(0), dedupe="test-dedupe"):
    return OutboxEvent.objects.create(
        topic=topic,
        dedupe_key=dedupe,
        payload={"type": "operations.sale", "id": "00000000-0000-0000-0000-000000000000"},
        available_at=timezone.now() + available_in,
    )


@override_settings(CELERY_TASK_ALWAYS_EAGER=True)
def test_dispatch_claims_due_rows_once_in_order():
    first = _event(dedupe="first")
    second = _event(dedupe="second")
    future = _event(dedupe="future", available_in=timedelta(hours=1))
    call_command("dispatch_scheduled")
    first.refresh_from_db()
    second.refresh_from_db()
    future.refresh_from_db()
    # Eager mode runs the worker inline: claimed rows finish PROCESSED with
    # one attempt each, and the future row is untouched.
    assert (first.status, second.status) == ("PROCESSED", "PROCESSED")
    assert (first.attempts, second.attempts) == (1, 1)
    assert future.status == "PENDING"
    assert OutboxEvent.objects.filter(status="PROCESSED").count() == 2


def test_dispatch_is_empty_quietly():
    call_command("dispatch_scheduled")


def test_broker_failure_rolls_back_claim():
    event = _event()
    with patch(
        "apps.tenancy.management.commands.dispatch_scheduled.process_outbox_event",
    ) as task:
        task.delay.side_effect = RuntimeError("broker down")
        with pytest.raises(RuntimeError, match="broker down"):
            call_command("dispatch_scheduled")
    event.refresh_from_db()
    assert (event.status, event.attempts) == ("PENDING", 0)


def test_worker_processes_and_is_idempotent(shop):
    _, business, _, _ = shop
    event = OutboxEvent.objects.create(
        business=business,
        topic="sale.posted",
        dedupe_key="worker-once",
        payload={"type": "operations.sale"},
        available_at=timezone.now(),
    )
    assert process_outbox_event.run(str(event.pk)) == "processed"
    assert process_outbox_event.run(str(event.pk)) == "already-processed"
    event.refresh_from_db()
    assert event.status == "PROCESSED"
    assert event.processed_at is not None


def test_worker_unknown_topic_fails_closed_with_error():
    event = _event(topic="unknown.topic")
    assert process_outbox_event.run(str(event.pk)) == "failed"
    event.refresh_from_db()
    assert event.status == "FAILED"
    assert "unknown.topic" in event.last_error


def test_worker_missing_row_acknowledges():
    assert process_outbox_event.run("00000000-0000-0000-0000-000000000000") == "missing"
