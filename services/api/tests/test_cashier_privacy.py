"""Cashier responses contain sales data, never supplier/cost/book data."""

from datetime import date
from decimal import Decimal
from uuid import uuid4

import pytest
from rest_framework.exceptions import PermissionDenied
from rest_framework.test import APIClient

from apps.catalog.models import Party
from apps.operations.models import (
    DocumentStatus,
    PartyLedgerEntry,
    Payment,
    Purchase,
    Sale,
)
from apps.operations.services import post_sale
from apps.tenancy.models import Membership

pytestmark = pytest.mark.django_db


@pytest.fixture
def cashier_client(shop):
    user, business, location, _ = shop
    membership = Membership.objects.get(user=user, business=business)
    membership.role = Membership.Role.CASHIER
    membership.save(update_fields=["role", "updated_at"])
    membership.locations.add(location)
    client = APIClient()
    client.force_authenticate(user)
    return client


def _customer_and_supplier(shop):
    _, business, _, _ = shop
    customer = Party.objects.create(business=business, name="Customer", kind=Party.Kind.CUSTOMER)
    supplier = Party.objects.create(business=business, name="Supplier", kind=Party.Kind.SUPPLIER)
    both = Party.objects.create(business=business, name="Both", kind=Party.Kind.BOTH)
    return customer, supplier, both


def _sale(shop, customer):
    user, business, location, _ = shop
    return Sale.objects.create(
        business=business,
        location=location,
        customer=customer,
        status=DocumentStatus.POSTED,
        number="CASH-SALE",
        financial_year="2026-27",
        sequence_number=1,
        document_date=date(2026, 11, 24),
        posted_at="2026-11-24T12:00:00Z",
        created_by=user,
        idempotency_key="cash-sale",
        grand_total_minor=80000,
        paid_total_minor=0,
        due_total_minor=80000,
    )


def _payment(shop, party, *, direction, key):
    user, business, location, _ = shop
    return Payment.objects.create(
        business=business,
        location=location,
        party=party,
        direction=direction,
        method=Payment.Method.CASH,
        amount_minor=10000,
        payment_date=date(2026, 11, 24),
        status=DocumentStatus.POSTED,
        created_by=user,
        idempotency_key=key,
    )


def test_product_prices_are_role_aware(shop, cashier_client):
    _, business, location, product = shop
    query = {"business_id": str(business.pk), "location_id": str(location.pk)}

    listed = cashier_client.get("/api/v1/products/", query)
    assert listed.status_code == 200
    pack = listed.json()["results"][0]["packs"][0]
    assert pack["retail_price_minor"] == 80000
    assert "wholesale_price_minor" not in pack

    detail = cashier_client.get(f"/api/v1/products/{product.pk}/", query)
    assert detail.status_code == 200
    assert "wholesale_price_minor" not in detail.json()["packs"][0]

    owner_client = APIClient()
    owner_client.force_authenticate(shop[0])
    # The shared user is currently a cashier; restore OWNER for the positive case.
    Membership.objects.filter(user=shop[0], business=business).update(role=Membership.Role.OWNER)
    owner_pack = owner_client.get(f"/api/v1/products/{product.pk}/", query).json()["packs"][0]
    assert owner_pack["wholesale_price_minor"] == 75000


def test_cashier_cannot_choose_wholesale_pricing_indirectly(shop):
    user, business, location, product = shop
    membership = Membership.objects.get(user=user, business=business)
    membership.role = Membership.Role.CASHIER
    membership.save(update_fields=["role", "updated_at"])
    membership.locations.add(location)
    payload = {
        "business": business,
        "location": location,
        "invoice_date": date(2026, 11, 24),
        "price_mode": Sale.PriceMode.WHOLESALE,
        "lines": [{"pack": product.packs.get(), "quantity": Decimal("1")}],
        "idempotency_key": "cashier-wholesale",
    }
    with pytest.raises(PermissionDenied):
        post_sale(payload, user)

    payload["price_mode"] = Sale.PriceMode.RETAIL
    payload["paid_amount_minor"] = 80000
    payload["idempotency_key"] = "cashier-retail"
    sale, replayed = post_sale(payload, user)
    assert not replayed
    assert sale.grand_total_minor == 80000


def test_cashier_parties_are_customers_only_without_payables(shop, cashier_client):
    _, business, location, _ = shop
    customer, supplier, both = _customer_and_supplier(shop)
    PartyLedgerEntry.objects.create(
        business=business,
        location=location,
        party=customer,
        account=PartyLedgerEntry.Account.RECEIVABLE,
        amount_minor=5000,
        source_type="SALE",
        source_id=uuid4(),
        occurred_at="2026-11-24T12:00:00Z",
    )
    # Even malformed/legacy payable rows on a customer must not be exposed.
    PartyLedgerEntry.objects.create(
        business=business,
        location=location,
        party=customer,
        account=PartyLedgerEntry.Account.PAYABLE,
        amount_minor=9000,
        source_type="PURCHASE",
        source_id=uuid4(),
        occurred_at="2026-11-24T12:00:00Z",
    )
    query = {"business_id": str(business.pk)}

    listed = cashier_client.get("/api/v1/parties/", query)
    assert listed.status_code == 200
    assert [row["id"] for row in listed.json()["results"]] == [str(customer.pk)]
    assert listed.json()["results"][0]["receivable_minor"] == 5000
    assert "payable_minor" not in listed.json()["results"][0]

    detail = cashier_client.get(f"/api/v1/parties/{customer.pk}/", query)
    assert detail.status_code == 200
    assert detail.json()["receivable_minor"] == 5000
    assert "payable_minor" not in detail.json()

    assert cashier_client.get(f"/api/v1/parties/{supplier.pk}/", query).status_code == 404
    assert cashier_client.get(f"/api/v1/parties/{both.pk}/", query).status_code == 404


def test_owner_still_sees_suppliers_and_payables(shop):
    user, business, _, _ = shop
    customer, supplier, both = _customer_and_supplier(shop)
    PartyLedgerEntry.objects.create(
        business=business,
        location=shop[2],
        party=supplier,
        account=PartyLedgerEntry.Account.PAYABLE,
        amount_minor=12000,
        source_type="PURCHASE",
        source_id=uuid4(),
        occurred_at="2026-11-24T12:00:00Z",
    )
    client = APIClient()
    client.force_authenticate(user)
    query = {"business_id": str(business.pk)}
    listed = client.get("/api/v1/parties/", query)
    assert listed.status_code == 200
    rows = {row["id"]: row for row in listed.json()["results"]}
    assert set(rows) == {str(customer.pk), str(supplier.pk), str(both.pk)}
    assert rows[str(supplier.pk)]["payable_minor"] == 12000


def test_cashier_cannot_mutate_catalog(shop, cashier_client):
    _, business, _, product = shop
    response = cashier_client.patch(
        f"/api/v1/products/{product.pk}/",
        {"business": str(business.pk), "name": "Changed"},
        format="json",
    )
    assert response.status_code == 403
    response = cashier_client.post(
        "/api/v1/parties/",
        {"business": str(business.pk), "name": "New", "kind": Party.Kind.SUPPLIER},
        format="json",
    )
    assert response.status_code == 403


@pytest.mark.parametrize(
    "report_path",
    [
        "/api/v1/reports/dashboard/",
        "/api/v1/reports/stock/",
        "/api/v1/reports/party-ledger/",
    ],
)
def test_cashier_reports_are_rejected_but_owner_reports_work(shop, cashier_client, report_path):
    _, business, location, _ = shop
    customer, _, _ = _customer_and_supplier(shop)
    PartyLedgerEntry.objects.create(
        business=business,
        location=location,
        party=customer,
        account=PartyLedgerEntry.Account.RECEIVABLE,
        amount_minor=5000,
        source_type="SALE",
        source_id=uuid4(),
        occurred_at="2026-11-24T12:00:00Z",
    )
    query = {"business_id": str(business.pk), "party_id": str(customer.pk)}
    assert cashier_client.get(report_path, query).status_code == 403

    Membership.objects.filter(user=shop[0], business=business).update(role=Membership.Role.OWNER)
    assert cashier_client.get(report_path, query).status_code == 200


@pytest.mark.parametrize(
    "endpoint",
    ["purchases", "expenses", "transfers", "audit-events"],
)
def test_cashier_cannot_read_cost_supplier_or_audit_endpoints(shop, cashier_client, endpoint):
    _, business, _, _ = shop
    response = cashier_client.get(f"/api/v1/{endpoint}/", {"business_id": str(business.pk)})
    assert response.status_code == 403


def test_cashier_payments_expose_receipts_only(shop, cashier_client):
    _, business, _, _ = shop
    customer, supplier, _ = _customer_and_supplier(shop)
    _sale(shop, customer)
    Purchase.objects.create(
        business=business,
        location=shop[2],
        supplier=supplier,
        status=DocumentStatus.POSTED,
        number="CASH-PURCHASE",
        financial_year="2026-27",
        sequence_number=1,
        document_date=date(2026, 11, 24),
        posted_at="2026-11-24T12:00:00Z",
        created_by=shop[0],
        idempotency_key="cash-purchase",
        grand_total_minor=20000,
    )
    receipt = _payment(shop, customer, direction=Payment.Direction.RECEIPT, key="cashier-receipt")
    supplier_payment = _payment(
        shop, supplier, direction=Payment.Direction.PAYMENT, key="cashier-supplier-payment"
    )
    query = {"business_id": str(business.pk)}

    listed = cashier_client.get("/api/v1/payments/", query)
    assert listed.status_code == 200
    assert [row["id"] for row in listed.json()] == [str(receipt.pk)]
    assert cashier_client.get(f"/api/v1/payments/{receipt.pk}/", query).status_code == 200
    assert cashier_client.get(f"/api/v1/payments/{supplier_payment.pk}/", query).status_code == 403
