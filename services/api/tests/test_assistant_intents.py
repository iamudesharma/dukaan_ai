"""Assistant multi-intent confirmation: purchase, payment, expense.

SALE confirmation is covered by tests/test_posting.py. These tests drive the
AI normalization path (mocked provider) plus direct confirm dispatch for the
new intents, including the fail-closed payment cases."""

from unittest.mock import patch

import pytest
from rest_framework.test import APIClient
from test_posting import proposal_for

from apps.assistant.chatgpt import Interpretation
from apps.assistant.services import confirm, interpret
from apps.operations.models import Expense, Payment, Purchase
from apps.operations.services import DomainConflict

pytestmark = pytest.mark.django_db


def make_client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def ai_proposal(shop, interpretation):
    user, business, location, _ = shop
    with patch("apps.assistant.chatgpt.interpret_with_ai", return_value=interpretation):
        proposal = interpret(
            actor=user,
            business=business,
            location=location,
            input_type="TEXT",
            content="ignored when the provider answers",
            locale="en",
        )
    assert proposal.command_type == interpretation.command_type
    return proposal


def test_purchase_proposal_confirms_and_adds_stock(shop):
    user, _, _, _ = shop
    proposal = ai_proposal(
        shop,
        Interpretation(
            command_type="PURCHASE",
            supplier_name="Sharma Suppliers",
            items=[{"product": "shirt", "quantity": 5, "unit_price_minor": 40000}],
            total_minor=200000,
            paid_minor=0,
        ),
    )
    assert proposal.status == "READY"
    assert proposal.payload["lines"][0]["unit_cost_minor"] == 40000
    purchase, replayed = confirm(
        proposal=proposal, actor=user, version=1, idempotency_key="purchase-1"
    )
    assert not replayed
    assert (purchase.grand_total_minor, purchase.due_total_minor) == (200000, 200000)
    assert purchase.supplier.name == "Sharma Suppliers"
    assert Purchase.objects.count() == 1


def test_purchase_without_supplier_needs_details(shop):
    proposal = ai_proposal(
        shop,
        Interpretation(
            command_type="PURCHASE",
            items=[{"product": "shirt", "quantity": 5, "unit_price_minor": 40000}],
            total_minor=200000,
        ),
    )
    assert proposal.status == "DRAFT"
    assert proposal.command_type == "PURCHASE"


def test_payment_settles_oldest_due_sale(shop):
    user, _, _, _ = shop
    confirm(proposal=proposal_for(shop), actor=user, version=1, idempotency_key="sale-1")
    proposal = ai_proposal(
        shop,
        Interpretation(
            command_type="PAYMENT",
            customer_name="Ramesh",
            direction="RECEIPT",
            total_minor=50000,
        ),
    )
    assert proposal.status == "READY"
    assert proposal.payload["sale_id"]
    payment, _ = confirm(proposal=proposal, actor=user, version=1, idempotency_key="pay-1")
    assert payment.amount_minor == 50000
    assert payment.direction == "RECEIPT"
    assert Payment.objects.count() == 2  # initial sale payment + this one


def test_payment_without_dues_needs_details(shop):
    proposal = ai_proposal(
        shop,
        Interpretation(
            command_type="PAYMENT",
            customer_name="Nobody",
            direction="RECEIPT",
            total_minor=50000,
        ),
    )
    assert proposal.status == "DRAFT"
    assert "outstanding" in " ".join(proposal.blocking_questions)


def test_payment_exceeding_due_fails_closed(shop):
    user, _, _, _ = shop
    confirm(proposal=proposal_for(shop), actor=user, version=1, idempotency_key="sale-1")
    proposal = ai_proposal(
        shop,
        Interpretation(
            command_type="PAYMENT",
            customer_name="Ramesh",
            direction="RECEIPT",
            total_minor=90000,
        ),
    )
    # Settle the bill directly so the pinned proposal now exceeds the due.
    from apps.operations.models import Sale

    sale = Sale.objects.get()
    sale.due_total_minor = 1000
    sale.save(update_fields=["due_total_minor"])
    with pytest.raises(DomainConflict, match="payment_exceeds_due"):
        confirm(proposal=proposal, actor=user, version=1, idempotency_key="pay-1")
    assert Payment.objects.count() == 1  # only the sale's initial payment


def test_expense_proposal_confirms(shop):
    user, _, _, _ = shop
    proposal = ai_proposal(
        shop,
        Interpretation(command_type="EXPENSE", category="Rent", total_minor=25000),
    )
    assert proposal.status == "READY"
    expense, replayed = confirm(
        proposal=proposal, actor=user, version=1, idempotency_key="expense-1"
    )
    assert not replayed
    assert (expense.total_minor, expense.category) == (25000, "Rent")
    assert Expense.objects.count() == 1


def test_expense_without_category_needs_details(shop):
    proposal = ai_proposal(shop, Interpretation(command_type="EXPENSE", total_minor=25000))
    assert proposal.status == "DRAFT"
    assert proposal.command_type == "EXPENSE"


def test_confirm_result_serializes_per_intent(shop):
    user, _, _, _ = shop
    client = make_client(user)
    proposal = ai_proposal(
        shop,
        Interpretation(command_type="EXPENSE", category="Rent", total_minor=25000),
    )
    response = client.post(
        f"/api/v1/assistant/proposals/{proposal.pk}/confirm/",
        {"version": 1, "idempotency_key": "expense-api-1"},
        format="json",
    )
    assert response.status_code == 200, response.data
    assert response.data["result"]["category"] == "Rent"
    assert response.data["proposal"]["status"] == "CONFIRMED"
