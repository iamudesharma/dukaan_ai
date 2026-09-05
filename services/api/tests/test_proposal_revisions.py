import pytest
from django.db import DatabaseError, transaction
from rest_framework.test import APIClient
from test_posting import proposal_for

from apps.assistant.models import AssistantProposal
from apps.assistant.services import confirm, revise
from apps.catalog.models import Party
from apps.operations.models import Sale, StockBalance
from apps.operations.services import DomainConflict
from apps.tenancy.models import Membership

pytestmark = pytest.mark.django_db


@pytest.mark.parametrize("change", ["stock", "price", "tax", "customer", "settings"])
def test_changed_review_data_requires_refresh(shop, change):
    user, business, _, product = shop
    proposal = proposal_for(shop)
    if change == "stock":
        StockBalance.objects.update(quantity=9)
    elif change == "price":
        product.packs.update(retail_price_minor=90000)
    elif change == "tax":
        product.tax_rate_bps = 500
        product.save()
    elif change == "customer":
        Party.objects.create(business=business, name="Ramesh", kind="CUSTOMER")
    else:
        business.negative_stock_allowed = False
        business.save()
    with pytest.raises(DomainConflict, match="stale_proposal_data"):
        confirm(proposal=proposal, actor=user, version=1, idempotency_key="sale")
    assert not Sale.objects.exists()
    refreshed = revise(proposal=proposal, actor=user, version=1)
    assert refreshed.version == 2
    assert refreshed.revisions.count() == 2
    with pytest.raises(DomainConflict, match="stale_proposal_version"):
        confirm(proposal=refreshed, actor=user, version=1, idempotency_key="sale")
    # Tax-enabled products require a valid tax registration, covered by posting validation.
    if change != "tax":
        sale, _ = confirm(proposal=refreshed, actor=user, version=2, idempotency_key="sale")
        assert sale.grand_total_minor == 240000


def test_revision_keeps_original_and_cannot_be_changed_or_deleted(shop):
    user, _, _, _ = shop
    proposal = proposal_for(shop)
    original = proposal.revisions.get().snapshot
    revised = revise(
        proposal=proposal,
        actor=user,
        version=1,
        content="Ramesh bought 2 shirts for ₹1,600, paid ₹1,000.",
    )
    assert revised.revisions.get(version=1).snapshot == original
    assert revised.revisions.get(version=2).snapshot["payload"]["paid_amount_minor"] == 100000
    for operation in (
        lambda: revised.revisions.update(snapshot={}),
        lambda: revised.revisions.all().delete(),
    ):
        with pytest.raises(DatabaseError), transaction.atomic():
            operation()


def test_retry_after_stock_changes_returns_original_sale(shop):
    user, _, _, _ = shop
    proposal = proposal_for(shop)
    sale, _ = confirm(proposal=proposal, actor=user, version=1, idempotency_key="stable")
    StockBalance.objects.update(quantity=1)
    retry, replayed = confirm(proposal=proposal, actor=user, version=1, idempotency_key="stable")
    assert replayed and retry.pk == sale.pk
    with pytest.raises(DomainConflict, match="proposal_not_open"):
        revise(proposal=proposal, actor=user, version=1)


def test_payload_tampering_and_legacy_proposals_fail_closed(shop):
    user, _, _, _ = shop
    proposal = proposal_for(shop)
    proposal.payload["paid_amount_minor"] = 0
    proposal.save()
    with pytest.raises(DomainConflict, match="stale_proposal_data"):
        confirm(proposal=proposal, actor=user, version=1, idempotency_key="tampered")
    proposal = proposal_for(shop)
    AssistantProposal.objects.filter(pk=proposal.pk).update(data_fingerprint="")
    with pytest.raises(DomainConflict, match="stale_proposal_data"):
        confirm(proposal=proposal, actor=user, version=1, idempotency_key="legacy")


def test_revision_api_and_location_revocation(shop):
    user, _, location, _ = shop
    proposal = proposal_for(shop)
    client = APIClient()
    client.force_authenticate(user)
    url = f"/api/v1/assistant/proposals/{proposal.pk}/"
    assert client.post(url + "revise/", {"version": 1}, format="json").json()["version"] == 2
    assert len(client.get(url + "revisions/").json()) == 2
    membership = Membership.objects.get(user=user)
    membership.role = "CASHIER"
    membership.save()
    membership.locations.add(location)
    assert client.get(url).status_code == 200
    membership.locations.clear()
    assert client.get(url).status_code == 404
    assert client.get("/api/v1/assistant/proposals/").json() == []


def test_unrepresentable_total_needs_correction(shop):
    user, _, _, _ = shop
    proposal = revise(
        proposal=proposal_for(shop),
        actor=user,
        version=1,
        content="Ramesh bought 3 shirts for ₹100, paid ₹100.",
    )
    assert proposal.status == "DRAFT"
    assert "unit price" in " ".join(proposal.blocking_questions)


def test_key_from_another_sale_cannot_confirm_new_proposal(shop):
    user, _, _, _ = shop
    confirm(proposal=proposal_for(shop), actor=user, version=1, idempotency_key="shared")
    proposal = proposal_for(shop)
    with pytest.raises(DomainConflict, match="idempotency_key_reused"):
        confirm(proposal=proposal, actor=user, version=1, idempotency_key="shared")
    assert Sale.objects.count() == 1
