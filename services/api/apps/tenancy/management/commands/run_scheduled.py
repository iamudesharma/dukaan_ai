"""Run the durable outbox dispatcher and attachment-retention maintenance."""

from __future__ import annotations

from django.core.management import call_command
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "Dispatch due outbox work, then purge a bounded batch of expired attachments."

    def add_arguments(self, parser):
        parser.add_argument(
            "--purge-limit",
            type=int,
            default=100,
            help="Maximum expired attachment rows inspected by the retention pass.",
        )
        parser.add_argument(
            "--skip-purge",
            action="store_true",
            help="Only dispatch outbox work (useful when storage credentials are unavailable).",
        )

    def handle(self, *args, **options):
        purge_limit = options["purge_limit"]
        if purge_limit < 1:
            from django.core.management.base import CommandError

            raise CommandError("--purge-limit must be positive")

        call_command("dispatch_scheduled")
        if options["skip_purge"]:
            self.stdout.write("Attachment retention pass skipped.")
            return
        call_command("purge_expired_attachments", limit=purge_limit)
