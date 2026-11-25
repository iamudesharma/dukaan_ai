"""Remove demo tenants and their rows from a database.

Run with the migration/operator credentials: disabling financial append-only
triggers needs table ownership (see docs/runbooks/database-roles.md).
"""

from contextlib import contextmanager

from django.core.management.base import BaseCommand, CommandError
from django.db import connection, transaction
from django.db.models.deletion import ProtectedError

from apps.assistant.models import AssistantProposal, Attachment, ProposalRevision
from apps.catalog.models import Party, Product, ProductPack
from apps.common.models import User
from apps.imports.models import ImportJob
from apps.integrations.models import (
    GmailImport,
    NotificationDelivery,
    NotificationDevice,
    Reminder,
)
from apps.operations.models import (
    DocumentSequence,
    Expense,
    InventoryCostLayer,
    PartyLedgerEntry,
    Payment,
    PaymentAllocation,
    Purchase,
    PurchaseLine,
    Sale,
    SaleLine,
    StockBalance,
    StockMovement,
    StockTransfer,
    StockTransferLine,
)
from apps.tenancy import rls
from apps.tenancy.models import (
    AuditEvent,
    Business,
    GSTRegistration,
    IdempotencyRecord,
    Invitation,
    Location,
    Membership,
    OutboxEvent,
)

DEFAULT_DEMO_USER = "dukaan-demo-owner"

SQLITE_RESTORE_TRIGGER = """
    CREATE TRIGGER proposal_revision_no_delete
    BEFORE DELETE ON assistant_proposalrevision
    BEGIN SELECT RAISE(ABORT, 'Proposal revisions are immutable'); END
"""


def _flush_deferred_constraints() -> None:
    """Fire queued deferred constraint checks before an ALTER TABLE.

    Django creates foreign keys DEFERRABLE INITIALLY DEFERRED on PostgreSQL, so
    any insert or delete earlier in the transaction leaves trigger events
    queued until COMMIT. PostgreSQL refuses ``ALTER TABLE`` on a table with
    pending trigger events ("cannot ALTER TABLE ... because it has pending
    trigger events"), which would otherwise break this command whenever it runs
    inside a transaction that already touched the revisions table — as the
    test suite does.
    """
    if connection.vendor != "postgresql":
        return
    with connection.cursor() as cursor:
        cursor.execute("SET CONSTRAINTS ALL IMMEDIATE")


@contextmanager
def revision_deletes_allowed():
    """Suspend append-only guards for an explicit, audited tenant deletion.

    Proposal revisions are protected on SQLite and Postgres. Inventory cost
    layers are protected on Postgres. Both guards are restored in a ``finally``
    so a failure cannot leave financial history mutable.
    """
    if connection.vendor == "sqlite":
        with connection.cursor() as cursor:
            cursor.execute("DROP TRIGGER IF EXISTS proposal_revision_no_delete")
        try:
            yield
        finally:
            with connection.cursor() as cursor:
                cursor.execute(SQLITE_RESTORE_TRIGGER)
    elif connection.vendor == "postgresql":
        _flush_deferred_constraints()
        with connection.cursor() as cursor:
            cursor.execute(
                "ALTER TABLE assistant_proposalrevision DISABLE TRIGGER proposal_revision_immutable"
            )
            cursor.execute(
                "ALTER TABLE operations_inventorycostlayer "
                "DISABLE TRIGGER inventory_cost_layer_immutable"
            )
        try:
            yield
        finally:
            _flush_deferred_constraints()
            with connection.cursor() as cursor:
                cursor.execute(
                    "ALTER TABLE assistant_proposalrevision "
                    "ENABLE TRIGGER proposal_revision_immutable"
                )
                cursor.execute(
                    "ALTER TABLE operations_inventorycostlayer "
                    "ENABLE TRIGGER inventory_cost_layer_immutable"
                )
    else:
        yield


def deletion_plan(business_ids: list[str]):
    """Children before parents: every business FK is PROTECT, and the lines,
    balances and movements all point at the records above them."""
    return [
        (
            "assistant.Attachment",
            Attachment.objects.filter(business_id__in=business_ids),
        ),
        (
            "assistant.ProposalRevision",
            ProposalRevision.objects.filter(proposal__business_id__in=business_ids),
        ),
        (
            "assistant.AssistantProposal",
            AssistantProposal.objects.filter(business_id__in=business_ids),
        ),
        ("operations.SaleLine", SaleLine.objects.filter(sale__business_id__in=business_ids)),
        (
            "operations.PurchaseLine",
            PurchaseLine.objects.filter(purchase__business_id__in=business_ids),
        ),
        (
            "operations.PaymentAllocation",
            PaymentAllocation.objects.filter(payment__business_id__in=business_ids),
        ),
        (
            "operations.StockTransferLine",
            StockTransferLine.objects.filter(transfer__business_id__in=business_ids),
        ),
        ("operations.Sale", Sale.objects.filter(business_id__in=business_ids)),
        ("operations.Purchase", Purchase.objects.filter(business_id__in=business_ids)),
        ("operations.Payment", Payment.objects.filter(business_id__in=business_ids)),
        ("operations.Expense", Expense.objects.filter(business_id__in=business_ids)),
        ("operations.StockTransfer", StockTransfer.objects.filter(business_id__in=business_ids)),
        ("operations.StockMovement", StockMovement.objects.filter(business_id__in=business_ids)),
        ("operations.StockBalance", StockBalance.objects.filter(business_id__in=business_ids)),
        (
            "operations.InventoryCostLayer",
            InventoryCostLayer.objects.filter(business_id__in=business_ids),
        ),
        (
            "operations.PartyLedgerEntry",
            PartyLedgerEntry.objects.filter(business_id__in=business_ids),
        ),
        (
            "operations.DocumentSequence",
            DocumentSequence.objects.filter(business_id__in=business_ids),
        ),
        ("catalog.ProductPack", ProductPack.objects.filter(product__business_id__in=business_ids)),
        ("catalog.Product", Product.objects.filter(business_id__in=business_ids)),
        ("catalog.Party", Party.objects.filter(business_id__in=business_ids)),
        (
            "integrations.GmailImport",
            GmailImport.objects.filter(business_id__in=business_ids),
        ),
        ("imports.ImportJob", ImportJob.objects.filter(business_id__in=business_ids)),
        (
            "integrations.NotificationDelivery",
            NotificationDelivery.objects.filter(reminder__business_id__in=business_ids),
        ),
        (
            "integrations.Reminder",
            Reminder.objects.filter(business_id__in=business_ids),
        ),
        (
            "integrations.NotificationDevice",
            NotificationDevice.objects.filter(business_id__in=business_ids),
        ),
        ("tenancy.Invitation", Invitation.objects.filter(business_id__in=business_ids)),
        ("tenancy.AuditEvent", AuditEvent.objects.filter(business_id__in=business_ids)),
        ("tenancy.Location", Location.objects.filter(business_id__in=business_ids)),
        ("tenancy.GSTRegistration", GSTRegistration.objects.filter(business_id__in=business_ids)),
        ("tenancy.Membership", Membership.objects.filter(business_id__in=business_ids)),
        (
            "tenancy.IdempotencyRecord",
            IdempotencyRecord.objects.filter(business_id__in=business_ids),
        ),
        ("tenancy.OutboxEvent", OutboxEvent.objects.filter(business_id__in=business_ids)),
        ("tenancy.Business", Business.objects.filter(pk__in=business_ids)),
    ]


class Command(BaseCommand):
    help = (
        "Delete demo tenants and their rows. Reports only until --confirm is passed. "
        "Run with the operator credentials so financial append-only triggers can be "
        "suspended for the deletion."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--business",
            action="append",
            default=[],
            metavar="UUID",
            help="Business to delete. Repeatable.",
        )
        parser.add_argument(
            "--user",
            action="append",
            default=[],
            metavar="USERNAME",
            help=f"Owner of the businesses to delete (default: {DEFAULT_DEMO_USER}). Repeatable.",
        )
        parser.add_argument(
            "--delete-users",
            action="store_true",
            help="Also delete the target users once they have no memberships left.",
        )
        parser.add_argument(
            "--force",
            action="store_true",
            help="Include businesses that other users also belong to.",
        )
        parser.add_argument(
            "--confirm",
            action="store_true",
            help="Delete the rows. Without this flag the command reports what it would delete.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report only, even if --confirm is passed.",
        )

    def handle(self, *args, **options):
        if options["confirm"] and options["dry_run"]:
            raise CommandError("--confirm and --dry-run cannot be used together")

        usernames = list(options["user"])
        if not usernames and not options["business"]:
            usernames = [DEFAULT_DEMO_USER]

        rls.set_staff_scope(connection)

        users = list(User.objects.filter(username__in=usernames)) if usernames else []
        missing = sorted(set(usernames) - {user.username for user in users})
        for username in missing:
            self.stderr.write(f"No user named {username!r}; ignoring.")

        business_ids = {str(pk) for pk in options["business"]}
        if users:
            business_ids.update(
                str(pk)
                for pk in Membership.objects.filter(user__in=users)
                .values_list("business_id", flat=True)
                .distinct()
            )

        businesses = list(Business.objects.filter(pk__in=business_ids))
        if not businesses:
            self.stdout.write("Nothing to purge: no matching businesses.")
            return

        # Businesses reached through the demo user are only removed when nobody
        # else still works in them. Businesses named explicitly by UUID are
        # taken as deliberate intent; --confirm is still required to delete.
        shared = []
        if users and not options["force"]:
            user_ids = {user.pk for user in users}
            for business in businesses:
                others = (
                    Membership.objects.filter(business=business)
                    .exclude(user_id__in=user_ids)
                    .exists()
                )
                if others:
                    shared.append(business)
            if shared:
                for business in shared:
                    self.stderr.write(
                        f"Skipping {business.name} ({business.pk}): other users are still "
                        "members. Pass --force to delete it anyway."
                    )
                businesses = [item for item in businesses if item not in shared]
                if not businesses:
                    self.stdout.write("Nothing to purge: every match is shared with other users.")
                    return

        business_ids = [str(business.pk) for business in businesses]
        self.stdout.write("Businesses in scope:")
        for business in businesses:
            self.stdout.write(f"  {business.name} ({business.pk})")

        plan = deletion_plan(business_ids)

        if not options["confirm"]:
            self.stdout.write("\nDry run — nothing was deleted. Row counts:")
            total = 0
            for label, queryset in plan:
                count = queryset.count()
                total += count
                if count:
                    self.stdout.write(f"  {label}: {count}")
            self.stdout.write(f"  total: {total}")
            self.stdout.write("\nRe-run with --confirm to delete these rows.")
            return

        with transaction.atomic():
            with revision_deletes_allowed():
                deleted = []
                for label, queryset in plan:
                    count, _ = queryset.delete()
                    if count:
                        deleted.append(f"{label}: {count}")
            if options["delete_users"]:
                for user in users:
                    if Membership.objects.filter(user=user).exists():
                        self.stderr.write(
                            f"Keeping {user.username}: still a member of another business."
                        )
                        continue
                    try:
                        # Savepoint: a PROTECTed reference elsewhere must not
                        # roll back the tenant deletion above.
                        with transaction.atomic():
                            user.delete()
                    except ProtectedError:
                        self.stderr.write(
                            f"Keeping {user.username}: still referenced by records "
                            "outside the purged businesses."
                        )
                        continue
                    deleted.append(f"common.User: {user.username}")

        self.stdout.write("\nDeleted:")
        for line in deleted:
            self.stdout.write(f"  {line}")
