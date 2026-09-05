"""Claim due outbox events and hand them to the worker queue.

Runs once per minute from the Render cron dispatcher (see render.yaml and
``make api-dispatch``). Each pass, inside one short transaction per batch:

1. selects due PENDING rows ordered by availability, locking them with SKIP
   LOCKED so overlapping runs never double-claim;
2. marks them PROCESSING and enqueues one idempotent Celery task per row;
3. if the broker is unreachable, the transaction rolls back, the rows stay
   PENDING, and a later run retries — queue loss delays work but never
   loses the intent, which remains durable in Postgres.

The dispatcher connects with the migration/operator credential and uses
staff scope: it only reads routing metadata (topic, business, dedupe key),
never financial payloads beyond what the task needs.
"""

from __future__ import annotations

from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from apps.tenancy import rls
from apps.tenancy.models import OutboxEvent
from apps.tenancy.tasks import process_outbox_event

BATCH_SIZE = 100


def _due_queryset(now):
    return (
        OutboxEvent.objects.select_for_update(skip_locked=True)
        .filter(status=OutboxEvent.Status.PENDING, available_at__lte=now)
        .order_by("available_at", "created_at")[:BATCH_SIZE]
    )


class Command(BaseCommand):
    help = "Claim due outbox rows and enqueue one idempotent task per row."

    def handle(self, *args, **options):
        from django.db import connection

        now = timezone.now()
        with transaction.atomic():
            rls.set_staff_scope(connection)
            rows = list(_due_queryset(now))
            if not rows:
                self.stdout.write("No due outbox events.")
                return
            for row in rows:
                row.status = OutboxEvent.Status.PROCESSING
                row.attempts += 1
                row.save(update_fields=["status", "attempts", "updated_at"])
            ids = [str(row.pk) for row in rows]
            try:
                for event_id in ids:
                    process_outbox_event.delay(event_id)
            except Exception:
                transaction.set_rollback(True)
                raise
        self.stdout.write(f"Dispatched {len(ids)} outbox event(s).")
