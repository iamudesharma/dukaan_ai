"""Delete attachment objects and rows only after retention policy permits."""

from __future__ import annotations

import logging

from django.core.management.base import BaseCommand, CommandError
from django.db import connection, transaction
from django.utils import timezone

from apps.assistant.models import Attachment
from apps.assistant.storage import StorageError, get_storage_backend
from apps.tenancy import rls
from apps.tenancy.models import AuditEvent

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = "Purge expired attachment objects and rows, preserving open clean proposal work."

    def add_arguments(self, parser):
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report eligible attachments without deleting objects or rows.",
        )
        parser.add_argument(
            "--limit",
            type=int,
            default=1000,
            help="Maximum number of expired rows to inspect in this run.",
        )

    def handle(self, *args, **options):
        limit = options["limit"]
        if limit < 1:
            raise CommandError("--limit must be positive")
        dry_run = options["dry_run"]
        now = timezone.now()
        rls.set_staff_scope(connection)
        candidates = list(
            Attachment.objects.select_related("proposal")
            .filter(retention_expires_at__lte=now)
            .order_by("retention_expires_at", "created_at")[:limit]
        )
        backend = get_storage_backend()
        purged = 0
        skipped = 0
        failed = 0
        for candidate in candidates:
            with transaction.atomic():
                try:
                    attachment = Attachment.objects.select_for_update().get(pk=candidate.pk)
                except Attachment.DoesNotExist:
                    skipped += 1
                    continue
                if not attachment.retention_policy_allows(now):
                    skipped += 1
                    continue
                if dry_run:
                    purged += 1
                    continue
                try:
                    # Object first, row second. A failed delete leaves the row
                    # as durable retry evidence; storage deletion is idempotent.
                    backend.delete(attachment.storage_path)
                except StorageError:
                    failed += 1
                    logger.warning("Attachment purge failed: attachment=%s", attachment.id)
                    continue
                proposal = attachment.proposal
                AuditEvent.objects.create(
                    business=attachment.business,
                    location=proposal.location if proposal is not None else None,
                    actor=None,
                    event_type="attachment.purged",
                    aggregate_type="assistant.attachment",
                    aggregate_id=attachment.id,
                    source="RETENTION",
                    metadata={
                        "scan_status": attachment.scan_status,
                        "size_bytes": attachment.size_bytes,
                        "retention_expires_at": attachment.retention_expires_at.isoformat(),
                        "storage_backend": backend.name,
                    },
                )
                attachment.delete()
                purged += 1

        prefix = "Would purge" if dry_run else "Purged"
        self.stdout.write(f"{prefix} {purged} attachment(s); skipped {skipped}; failed {failed}.")
        if failed:
            raise CommandError(f"{failed} attachment object(s) could not be deleted")
