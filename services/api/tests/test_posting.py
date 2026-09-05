from decimal import Decimal
from unittest.mock import patch

import pytest
from django.db import connection
from django.db.models import Sum
from rest_framework.test import APIClient

from apps.assistant.services import confirm, interpret
from apps.catalog.models import Party
from apps.operations.models import (
    PartyLedgerEntry,
    Payment,
    PaymentAllocation,
    Sale,
    StockBalance,
    StockMovement,
)
from apps.operations.services import reverse_sale
from apps.tenancy.models import AuditEvent, Business, Membership, OutboxEvent

pytestmark = pytest.mark.django_db


def proposal_for(shop):
    user, business, location, _ = shop
    return interpret(
        actor=user,
        business=business,
        location=location,
        input_type="TEXT",
        locale="en",
        content="Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.",
    )


def test_ramesh_confirmation_retry_and_reversal(shop):
    user, _, _, _ = shop
    proposal = proposal_for(shop)
    assert proposal.status == "READY"
    assert Sale.objects.count() == Payment.objects.count() == Party.objects.count() == 0
    sale, replayed = confirm(proposal=proposal, actor=user, version=1, idempotency_key="ramesh-1")
    assert not replayed
    assert (sale.grand_total_minor, sale.paid_total_minor, sale.due_total_minor) == (
        240000,
        150000,
        90000,
    )
    assert StockBalance.objects.get().quantity == Decimal("7")
    assert StockMovement.objects.get().quantity == Decimal("-3")
    assert Payment.objects.get().amount_minor == 150000
    assert PaymentAllocation.objects.get().amount_minor == 150000
    assert PartyLedgerEntry.objects.aggregate(total=Sum("amount_minor"))["total"] == 90000
    assert AuditEvent.objects.filter(event_type="sale.posted").count() == 1
    assert OutboxEvent.objects.filter(topic="sale.posted").count() == 1
    same, replayed = confirm(proposal=proposal, actor=user, version=1, idempotency_key="ramesh-1")
    assert replayed and same.pk == sale.pk
    assert Sale.objects.count() == Payment.objects.count() == 1
    reverse_sale(sale, user, reason="Correction", idempotency_key="reverse-1")
    assert StockBalance.objects.get().quantity == Decimal("10")
    assert PartyLedgerEntry.objects.aggregate(total=Sum("amount_minor"))["total"] == 0


def test_outbox_failure_rolls_back_entire_confirmation(shop):
    user, _, _, _ = shop
    proposal = proposal_for(shop)
    with patch("apps.operations.services._outbox", side_effect=RuntimeError("injected failure")):
        with pytest.raises(RuntimeError):
            confirm(proposal=proposal, actor=user, version=1, idempotency_key="failure")
    assert Sale.objects.count() == Payment.objects.count() == Party.objects.count() == 0
    assert StockBalance.objects.get().quantity == Decimal("10")
    assert StockMovement.objects.count() == AuditEvent.objects.count() == 0


def test_revoked_member_cannot_confirm(shop):
    user, _, _, _ = shop
    proposal = proposal_for(shop)
    Membership.objects.filter(user=user).update(is_active=False)
    from rest_framework.exceptions import PermissionDenied

    with pytest.raises(PermissionDenied):
        confirm(proposal=proposal, actor=user, version=1, idempotency_key="revoked")
    assert Sale.objects.count() == 0


@pytest.mark.parametrize("route", ["purchases", "expenses", "transfers"])
def test_cashier_cannot_read_manager_documents(shop, route):
    user, business, location, _ = shop
    membership = Membership.objects.get(user=user)
    membership.role = "CASHIER"
    membership.save()
    membership.locations.add(location)
    client = APIClient()
    client.force_authenticate(user)
    response = client.get(f"/api/v1/{route}/", {"business_id": str(business.pk)})
    assert response.status_code == 403


def test_other_business_is_not_readable(shop):
    user, _, _, _ = shop
    other = Business.objects.create(name="Other business")
    client = APIClient()
    client.force_authenticate(user)
    status_code = client.get("/api/v1/sales/", {"business_id": str(other.pk)}).status_code
    if connection.vendor == "postgresql":
        # RLS hides the foreign business entirely, so the lookup 404s instead
        # of 403ing: the API does not even confirm the tenant exists.
        assert status_code == 404
    else:
        assert status_code == 403


def test_sale_reversal_endpoint(shop):
    user, _, _, _ = shop
    sale, _ = confirm(
        proposal=proposal_for(shop), actor=user, version=1, idempotency_key="api-sale"
    )
    client = APIClient()
    client.force_authenticate(user)
    response = client.post(
        f"/api/v1/sales/{sale.pk}/reverse/",
        {"reason": "Correction", "idempotency_key": "api-reverse"},
        format="json",
    )
    assert response.status_code == 200
    assert response.json()["status"] == "REVERSED"
