"""Purging demo data is explicit, reversible until confirmed, and complete."""

from io import StringIO
from uuid import uuid4

import pytest
from django.core.management import call_command
from django.core.management.base import CommandError
from django.db import connection, transaction
from django.db.utils import IntegrityError, ProgrammingError
from django.utils import timezone
from test_posting import proposal_for

from apps.assistant.models import AssistantProposal, Attachment, ProposalRevision
from apps.assistant.services import confirm
from apps.catalog.models import Party, Product, ProductPack
from apps.common.models import User
from apps.imports.models import ImportJob
from apps.integrations.models import (
    GmailImport,
    NotificationDelivery,
    NotificationDevice,
    Reminder,
)
from apps.operations.models import InventoryCostLayer, Sale, StockBalance, StockMovement
from apps.tenancy.models import Business, Invitation, Location, Membership

pytestmark = pytest.mark.django_db


@pytest.fixture
def tenant_with_history(shop):
    user, business, _, _ = shop
    proposal = proposal_for(shop)
    confirm(proposal=proposal, actor=user, version=1, idempotency_key="purge-1")
    # Interpretation and confirmation already wrote append-only revisions.
    assert ProposalRevision.objects.exists()
    Attachment.objects.create(
        business=business,
        owner=user,
        kind=Attachment.Kind.VOICE,
        mime="audio/m4a",
        size_bytes=10,
        storage_path=f"{business.id}/voice/test.m4a",
        status=Attachment.Status.READY,
        proposal=proposal,
    )
    GmailImport.objects.create(
        user=user,
        business=business,
        location=shop[2],
        message_id="gmail-1",
        subject="Receipt",
    )
    ImportJob.objects.create(
        business=business,
        user=user,
        kind=ImportJob.Kind.PRODUCT,
        status=ImportJob.Status.READY,
        original_filename="products.csv",
        file_sha256="a" * 64,
        file_size_bytes=100,
    )
    device = NotificationDevice.objects.create(
        user=user,
        business=business,
        location=shop[2],
        fcm_token=f"purge-device-{business.pk}",
    )
    reminder = Reminder.objects.create(
        user=user,
        business=business,
        location=shop[2],
        title="Review stock",
        body="Check low stock.",
        scheduled_at=timezone.now(),
        dedupe_key=f"purge-reminder-{business.pk}",
    )
    NotificationDelivery.objects.create(
        reminder=reminder,
        device=device,
        dedupe_key=f"purge-delivery-{business.pk}",
    )
    Invitation.create_with_token(
        business=business,
        inviter=user,
        invitee_phone="+919876500099",
        role=Membership.Role.CASHIER,
    )
    assert InventoryCostLayer.objects.filter(business=business).exists()
    return shop


def test_dry_run_deletes_nothing(tenant_with_history):
    _, business, _, _ = tenant_with_history
    output = StringIO()

    call_command("purge_demo_data", "--business", str(business.pk), stdout=output)

    assert "Dry run" in output.getvalue()
    assert Business.objects.filter(pk=business.pk).exists()
    assert Sale.objects.exists()


def test_confirm_removes_the_tenant_and_every_row_beneath_it(tenant_with_history):
    user, business, _, _ = tenant_with_history
    output = StringIO()

    call_command(
        "purge_demo_data",
        "--business",
        str(business.pk),
        "--confirm",
        stdout=output,
    )

    assert not Business.objects.filter(pk=business.pk).exists()
    assert not Membership.objects.exists()
    assert not Location.objects.exists()
    assert not Product.objects.exists()
    assert not ProductPack.objects.exists()
    assert not Party.objects.exists()
    assert not StockBalance.objects.exists()
    assert not StockMovement.objects.exists()
    assert not Sale.objects.exists()
    # The append-only revision guard is suspended for the deletion and restored.
    assert not ProposalRevision.objects.exists()
    assert not AssistantProposal.objects.exists()
    assert not Attachment.objects.exists()
    assert not GmailImport.objects.exists()
    assert not ImportJob.objects.exists()
    assert not NotificationDelivery.objects.exists()
    assert not Reminder.objects.exists()
    assert not NotificationDevice.objects.exists()
    assert not Invitation.objects.exists()
    assert not InventoryCostLayer.objects.exists()
    assert "Deleted:" in output.getvalue()
    assert User.objects.filter(pk=user.pk).exists()


def test_confirmed_deletion_restores_the_revision_trigger(tenant_with_history):
    user, business, _, _ = tenant_with_history
    call_command("purge_demo_data", "--business", str(business.pk), "--confirm", stdout=StringIO())

    replacement = Business.objects.create(name="Replacement")
    Membership.objects.create(user=user, business=replacement, role="OWNER")
    location = Location.objects.create(business=replacement, code="MAIN", name="Main")
    proposal = AssistantProposal.objects.create(
        business=replacement,
        location=location,
        actor=user,
        input_type="TEXT",
        content="shirt 2",
        expires_at=timezone.now(),
    )
    revision = ProposalRevision.objects.create(
        proposal=proposal, version=1, snapshot={}, data_fingerprint="fp"
    )

    # The append-only guard is back on, so revisions cannot be removed again.
    # The delete runs in a savepoint because PostgreSQL aborts the whole
    # transaction when a statement raises, and it reports the plpgsql RAISE as
    # ProgrammingError where SQLite surfaces an IntegrityError.
    with pytest.raises((IntegrityError, ProgrammingError)):
        with transaction.atomic():
            ProposalRevision.objects.filter(pk=revision.pk).delete()


@pytest.mark.skipif(
    connection.vendor != "postgresql", reason="cost-layer trigger is PostgreSQL-only"
)
def test_confirmed_deletion_restores_cost_layer_immutability(tenant_with_history):
    user, business, _, _ = tenant_with_history
    call_command("purge_demo_data", "--business", str(business.pk), "--confirm", stdout=StringIO())

    replacement = Business.objects.create(name="Replacement")
    Location.objects.create(business=replacement, code="MAIN", name="Main")
    product = Product.objects.create(business=replacement, name="Shirt")
    layer = InventoryCostLayer.objects.create(
        business=replacement,
        location=replacement.locations.get(),
        product=product,
        layer_type=InventoryCostLayer.Type.OPENING,
        source_type="TEST",
        source_id=uuid4(),
        quantity_delta=1,
        costed_quantity_delta=0,
        unknown_cost_quantity_delta=1,
        value_delta_minor=0,
        occurred_at=timezone.now(),
    )

    with pytest.raises((IntegrityError, ProgrammingError)):
        with transaction.atomic():
            InventoryCostLayer.objects.filter(pk=layer.pk).update(value_delta_minor=1)


def test_shared_business_is_skipped_unless_forced(tenant_with_history):
    user, business, _, _ = tenant_with_history
    other = User.objects.create_user(username="partner")
    Membership.objects.create(user=other, business=business, role="MANAGER")
    error = StringIO()

    call_command(
        "purge_demo_data",
        "--user",
        user.username,
        "--confirm",
        stdout=StringIO(),
        stderr=error,
    )

    assert Business.objects.filter(pk=business.pk).exists()
    assert "Skipping" in error.getvalue()

    call_command(
        "purge_demo_data",
        "--user",
        user.username,
        "--force",
        "--confirm",
        stdout=StringIO(),
        stderr=StringIO(),
    )
    assert not Business.objects.filter(pk=business.pk).exists()


def test_delete_users_removes_an_orphaned_owner(tenant_with_history):
    user, business, _, _ = tenant_with_history

    call_command(
        "purge_demo_data",
        "--business",
        str(business.pk),
        "--user",
        user.username,
        "--delete-users",
        "--confirm",
        stdout=StringIO(),
    )

    assert not Business.objects.filter(pk=business.pk).exists()
    assert not User.objects.filter(pk=user.pk).exists()


def test_delete_users_keeps_a_user_with_another_business(tenant_with_history):
    user, business, _, _ = tenant_with_history
    second = Business.objects.create(name="Second shop")
    Membership.objects.create(user=user, business=second, role="OWNER")
    # The second shop is shared, so it is skipped and the owner survives.
    Membership.objects.create(
        user=User.objects.create_user(username="partner"), business=second, role="MANAGER"
    )

    call_command(
        "purge_demo_data",
        "--user",
        user.username,
        "--delete-users",
        "--confirm",
        stdout=StringIO(),
        stderr=StringIO(),
    )

    assert not Business.objects.filter(pk=business.pk).exists()
    assert Business.objects.filter(pk=second.pk).exists()
    assert User.objects.filter(pk=user.pk).exists()


def test_unknown_target_reports_nothing_to_do(shop):
    output = StringIO()
    call_command("purge_demo_data", "--user", "nobody-here", stdout=output)
    assert "Nothing to purge" in output.getvalue()


def test_confirm_and_dry_run_conflict():
    with pytest.raises(CommandError):
        call_command("purge_demo_data", "--confirm", "--dry-run")
