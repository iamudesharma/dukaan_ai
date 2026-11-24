from datetime import date
from decimal import Decimal
from unittest.mock import patch

import pytest
from rest_framework.exceptions import ValidationError
from rest_framework.test import APIClient

from apps.catalog.models import Party, Product, ProductPack
from apps.common.models import User
from apps.operations.models import (
    DocumentStatus,
    PartyLedgerEntry,
    Payment,
    PaymentAllocation,
)
from apps.operations.services import (
    DomainConflict,
    post_payment,
    post_purchase,
    post_sale,
    reallocate_payment,
    reverse_payment,
)
from apps.tenancy.models import AuditEvent, Business, Location, Membership

pytestmark = pytest.mark.django_db
TODAY = date(2026, 11, 24)


def _parties(shop):
    _, business, _, _ = shop
    return (
        Party.objects.create(business=business, name="Customer", kind=Party.Kind.CUSTOMER),
        Party.objects.create(business=business, name="Supplier", kind=Party.Kind.SUPPLIER),
    )


def _sale(shop, customer, *, key, total=30_000, **extra):
    user, business, location, product = shop
    sale, _ = post_sale(
        {
            "business": business,
            "location": location,
            "customer": customer,
            "invoice_date": TODAY,
            "lines": [
                {
                    "pack": product.packs.get(),
                    "quantity": Decimal("1"),
                    "unit_price_minor": total,
                }
            ],
            "idempotency_key": key,
            **extra,
        },
        user,
    )
    return sale


def _purchase(shop, supplier, *, key, total=30_000):
    user, business, location, product = shop
    purchase, _ = post_purchase(
        {
            "business": business,
            "location": location,
            "supplier": supplier,
            "purchase_date": TODAY,
            "lines": [
                {
                    "pack": product.packs.get(),
                    "quantity": Decimal("1"),
                    "unit_cost_minor": total,
                }
            ],
            "idempotency_key": key,
        },
        user,
    )
    return purchase


def _payment(shop, party, document, *, key, amount=15_000, direction=None):
    user, business, location, _ = shop
    direction = direction or (
        Payment.Direction.RECEIPT
        if document.__class__.__name__ == "Sale"
        else Payment.Direction.PAYMENT
    )
    payment, _ = post_payment(
        {
            "business": business,
            "location": location,
            "party": party,
            "direction": direction,
            "method": Payment.Method.CASH,
            "amount_minor": amount,
            "sale": document if direction == Payment.Direction.RECEIPT else None,
            "purchase": document if direction == Payment.Direction.PAYMENT else None,
            "payment_date": TODAY,
            "idempotency_key": key,
        },
        user,
    )
    return payment


def _client(shop):
    client = APIClient()
    client.force_authenticate(shop[0])
    return client


def _reallocate_payload(payment, first, second, amounts=(10_000, 5_000), key="reallocate-1"):
    document_type = "SALE" if payment.direction == Payment.Direction.RECEIPT else "PURCHASE"
    id_field = "sale_id" if document_type == "SALE" else "purchase_id"
    return {
        "reason": "Correct invoice allocation",
        "idempotency_key": key,
        "allocations": [
            {id_field: str(first.pk), "amount_minor": amounts[0]},
            {id_field: str(second.pk), "amount_minor": amounts[1]},
        ],
    }


@pytest.mark.parametrize("direction", [Payment.Direction.RECEIPT, Payment.Direction.PAYMENT])
def test_split_and_reallocate_payment_updates_documents_ledger_and_audit(shop, direction):
    customer, supplier = _parties(shop)
    if direction == Payment.Direction.RECEIPT:
        party = customer
        first = _sale(shop, customer, key="sale-1")
        second = _sale(shop, customer, key="sale-2")
    else:
        party = supplier
        first = _purchase(shop, supplier, key="purchase-1")
        second = _purchase(shop, supplier, key="purchase-2")
    payment = _payment(shop, party, first, key="payment-1", direction=direction)
    ledger_total = sum(entry.amount_minor for entry in PartyLedgerEntry.objects.filter(party=party))

    updated, replayed = reallocate_payment(
        payment,
        [
            {
                "sale_id" if direction == Payment.Direction.RECEIPT else "purchase_id": first.pk,
                "amount_minor": 10_000,
            },
            {
                "sale_id" if direction == Payment.Direction.RECEIPT else "purchase_id": second.pk,
                "amount_minor": 5_000,
            },
        ],
        shop[0],
        reason="Correct invoice allocation",
        idempotency_key="reallocate-1",
    )
    assert not replayed and updated.pk == payment.pk
    first.refresh_from_db()
    second.refresh_from_db()
    assert (first.paid_total_minor, first.due_total_minor) == (10_000, 20_000)
    assert (second.paid_total_minor, second.due_total_minor) == (5_000, 25_000)
    assert (
        sum(allocation.amount_minor for allocation in payment.allocations.all())
        == payment.amount_minor
    )
    assert (
        sum(entry.amount_minor for entry in PartyLedgerEntry.objects.filter(party=party))
        == ledger_total
    )
    audit = AuditEvent.objects.get(event_type="payment.reallocated")
    assert audit.aggregate_id == payment.pk
    assert audit.metadata["reason"] == "Correct invoice allocation"
    assert len(audit.metadata["previous"]) == 1
    assert len(audit.metadata["allocations"]) == 2


@pytest.mark.parametrize("direction", [Payment.Direction.RECEIPT, Payment.Direction.PAYMENT])
def test_reallocation_endpoint_is_idempotent(shop, direction):
    customer, supplier = _parties(shop)
    party = customer if direction == Payment.Direction.RECEIPT else supplier
    if direction == Payment.Direction.RECEIPT:
        first = _sale(shop, customer, key="idem-sale-1")
        second = _sale(shop, customer, key="idem-sale-2")
    else:
        first = _purchase(shop, supplier, key="idem-purchase-1")
        second = _purchase(shop, supplier, key="idem-purchase-2")
    payment = _payment(shop, party, first, key="idem-payment", direction=direction)
    payload = _reallocate_payload(payment, first, second)
    url = f"/api/v1/payments/{payment.pk}/reallocate/"
    client = _client(shop)

    first_response = client.post(url, payload, format="json")
    second_response = client.post(url, payload, format="json")
    assert first_response.status_code == second_response.status_code == 200
    assert first_response.headers["Idempotent-Replay"] == "false"
    assert second_response.headers["Idempotent-Replay"] == "true"
    assert first_response.json()["allocated_total_minor"] == 15_000
    assert second_response.json()["unallocated_total_minor"] == 0
    assert PaymentAllocation.objects.filter(payment=payment).count() == 2
    assert AuditEvent.objects.filter(event_type="payment.reallocated").count() == 1


def test_location_manager_can_reallocate_payment(shop):
    customer, _ = _parties(shop)
    first = _sale(shop, customer, key="manager-sale-1")
    second = _sale(shop, customer, key="manager-sale-2")
    payment = _payment(shop, customer, first, key="manager-payment")
    manager = User.objects.create_user(username="location-manager")
    membership = Membership.objects.create(
        user=manager, business=shop[1], role=Membership.Role.MANAGER
    )
    membership.locations.add(shop[2])
    client = APIClient()
    client.force_authenticate(manager)
    response = client.post(
        f"/api/v1/payments/{payment.pk}/reallocate/",
        _reallocate_payload(payment, first, second, key="manager-reallocate"),
        format="json",
    )
    assert response.status_code == 200
    assert response.json()["allocated_total_minor"] == payment.amount_minor


def test_allocation_review_lists_payments_totals_and_outstanding_sales(shop):
    customer, _ = _parties(shop)
    first = _sale(shop, customer, key="review-sale-1")
    second = _sale(shop, customer, key="review-sale-2")
    payment = _payment(shop, customer, first, key="review-payment")
    response = _client(shop).get(
        "/api/v1/payments/allocation-review/",
        {
            "business_id": str(shop[1].pk),
            "direction": Payment.Direction.RECEIPT,
            "party_id": str(customer.pk),
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["totals"]["payment_count"] == 1
    assert data["totals"]["payment_total_minor"] == 15_000
    assert data["totals"]["allocated_total_minor"] == 15_000
    assert data["totals"]["unallocated_total_minor"] == 0
    assert data["totals"]["outstanding_total_minor"] == 45_000
    row = data["results"][0]
    assert row["id"] == str(payment.pk)
    assert row["allocations"][0]["document_id"] == str(first.pk)
    assert row["allocations"][0]["document_number"] == first.number
    assert {item["document_id"] for item in data["outstanding_documents"]} == {
        str(first.pk),
        str(second.pk),
    }


def test_allocation_review_lists_outstanding_purchases(shop):
    _, supplier = _parties(shop)
    purchase = _purchase(shop, supplier, key="review-purchase")
    response = _client(shop).get(
        "/api/v1/payments/allocation-review/",
        {
            "business_id": str(shop[1].pk),
            "direction": Payment.Direction.PAYMENT,
            "party_id": str(supplier.pk),
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["results"] == []
    assert data["outstanding_documents"][0]["document_type"] == "PURCHASE"
    assert data["outstanding_documents"][0]["document_id"] == str(purchase.pk)
    assert data["totals"]["outstanding_total_minor"] == 30_000


def test_over_allocation_of_payment_or_document_is_rejected_atomically(shop):
    customer, _ = _parties(shop)
    first = _sale(shop, customer, key="over-sale-1", total=30_000)
    second = _sale(shop, customer, key="over-sale-2", total=4_000)
    payment = _payment(shop, customer, first, key="over-payment", amount=5_000)
    original_allocations = list(payment.allocations.values_list("pk", flat=True))

    with pytest.raises(DomainConflict) as payment_error:
        reallocate_payment(
            payment,
            [
                {"sale_id": first.pk, "amount_minor": 3_000},
                {"sale_id": second.pk, "amount_minor": 3_000},
            ],
            shop[0],
            reason="Too much",
            idempotency_key="over-payment-total",
        )
    assert payment_error.value.detail["code"] == "payment_allocation_exceeds_payment"

    with pytest.raises(DomainConflict) as document_error:
        reallocate_payment(
            payment,
            [
                {"sale_id": first.pk, "amount_minor": 1},
                {"sale_id": second.pk, "amount_minor": 4_999},
            ],
            shop[0],
            reason="Exceeds due",
            idempotency_key="over-document",
        )
    assert document_error.value.detail["code"] == "payment_exceeds_due"
    assert list(payment.allocations.values_list("pk", flat=True)) == original_allocations
    first.refresh_from_db()
    second.refresh_from_db()
    assert (first.paid_total_minor, first.due_total_minor) == (5_000, 25_000)
    assert (second.paid_total_minor, second.due_total_minor) == (0, 4_000)


def test_partial_payment_reallocation_is_rejected(shop):
    customer, _ = _parties(shop)
    first = _sale(shop, customer, key="partial-sale-1")
    second = _sale(shop, customer, key="partial-sale-2")
    payment = _payment(shop, customer, first, key="partial-payment")
    with pytest.raises(ValidationError):
        reallocate_payment(
            payment,
            [
                {"sale_id": first.pk, "amount_minor": 5_000},
                {"sale_id": second.pk, "amount_minor": 5_000},
            ],
            shop[0],
            reason="Incomplete",
            idempotency_key="partial-reallocation",
        )


def test_reallocation_audit_failure_rolls_back_allocations_and_totals(shop):
    customer, _ = _parties(shop)
    first = _sale(shop, customer, key="atomic-sale-1")
    second = _sale(shop, customer, key="atomic-sale-2")
    payment = _payment(shop, customer, first, key="atomic-payment")
    original = list(payment.allocations.values_list("pk", flat=True))
    with patch("apps.operations.services._audit", side_effect=RuntimeError("audit unavailable")):
        with pytest.raises(RuntimeError):
            reallocate_payment(
                payment,
                [
                    {"sale_id": first.pk, "amount_minor": 10_000},
                    {"sale_id": second.pk, "amount_minor": 5_000},
                ],
                shop[0],
                reason="Atomic",
                idempotency_key="atomic-reallocation",
            )
    assert list(payment.allocations.values_list("pk", flat=True)) == original
    first.refresh_from_db()
    second.refresh_from_db()
    assert (first.paid_total_minor, first.due_total_minor) == (15_000, 15_000)
    assert (second.paid_total_minor, second.due_total_minor) == (0, 30_000)
    assert AuditEvent.objects.filter(event_type="payment.reallocated").count() == 0


def test_cross_tenant_allocation_is_rejected(shop):
    customer, _ = _parties(shop)
    first = _sale(shop, customer, key="tenant-sale-1")
    payment = _payment(shop, customer, first, key="tenant-payment")
    other_user = User.objects.create_user(username="other-owner")
    other_business = Business.objects.create(name="Other payment tenant")
    other_location = Location.objects.create(business=other_business, code="MAIN", name="Main")
    Membership.objects.create(user=other_user, business=other_business, role="OWNER")
    other_customer = Party.objects.create(
        business=other_business, name="Foreign customer", kind=Party.Kind.CUSTOMER
    )
    foreign_product = Product.objects.create(business=other_business, name="Foreign product")
    ProductPack.objects.create(
        product=foreign_product,
        name="piece",
        conversion_factor=Decimal("1"),
        retail_price_minor=30_000,
        wholesale_price_minor=25_000,
    )
    foreign = _sale(
        (other_user, other_business, other_location, foreign_product),
        other_customer,
        key="foreign-sale",
        negative_stock_acknowledged=True,
        negative_stock_reason="Foreign test stock",
    )
    with pytest.raises(ValidationError):
        reallocate_payment(
            payment,
            [{"sale_id": foreign.pk, "amount_minor": payment.amount_minor}],
            shop[0],
            reason="Cross tenant",
            idempotency_key="cross-tenant",
        )
    assert payment.allocations.get().sale_id == first.pk


def test_cashier_cannot_review_or_reallocate_but_can_list_receipts(shop):
    customer, supplier = _parties(shop)
    user, business, location, _ = shop
    membership = Membership.objects.get(user=user, business=business)
    first = _sale(shop, customer, key="cashier-sale-1")
    second = _sale(shop, customer, key="cashier-sale-2")
    receipt = _payment(shop, customer, first, key="cashier-receipt")
    purchase = _purchase(shop, supplier, key="cashier-purchase")
    _payment(
        shop,
        supplier,
        purchase,
        key="cashier-supplier-payment",
        direction=Payment.Direction.PAYMENT,
    )
    membership.role = Membership.Role.CASHIER
    membership.save(update_fields=["role", "updated_at"])
    membership.locations.add(location)
    client = _client(shop)
    assert (
        client.get(
            "/api/v1/payments/allocation-review/", {"business_id": str(business.pk)}
        ).status_code
        == 403
    )
    response = client.post(
        f"/api/v1/payments/{receipt.pk}/reallocate/",
        _reallocate_payload(receipt, first, second),
        format="json",
    )
    assert response.status_code == 403
    listed = client.get("/api/v1/payments/", {"business_id": str(business.pk)})
    assert listed.status_code == 200
    assert [row["id"] for row in listed.json()] == [str(receipt.pk)]


def test_reversed_split_payment_restores_each_document_once(shop):
    customer, _ = _parties(shop)
    first = _sale(shop, customer, key="reverse-sale-1")
    second = _sale(shop, customer, key="reverse-sale-2")
    payment = _payment(shop, customer, first, key="reverse-split-payment")
    reallocate_payment(
        payment,
        [
            {"sale_id": first.pk, "amount_minor": 10_000},
            {"sale_id": second.pk, "amount_minor": 5_000},
        ],
        shop[0],
        reason="Split",
        idempotency_key="split-before-reverse",
    )
    reverse_payment(payment, shop[0], reason="Returned", idempotency_key="reverse-split")
    payment.refresh_from_db()
    first.refresh_from_db()
    second.refresh_from_db()
    assert (first.paid_total_minor, first.due_total_minor) == (0, 30_000)
    assert (second.paid_total_minor, second.due_total_minor) == (0, 30_000)
    assert payment.status == DocumentStatus.REVERSED
    assert (
        sum(
            entry.amount_minor
            for entry in PartyLedgerEntry.objects.filter(party=customer, account="RECEIVABLE")
        )
        == 60_000
    )
