from datetime import date
from decimal import Decimal
from uuid import uuid4

import pytest
from freezegun import freeze_time
from rest_framework.test import APIClient

from apps.catalog.models import Party, Product
from apps.common.models import User
from apps.operations.models import (
    DocumentStatus,
    Expense,
    PartyLedgerEntry,
    Payment,
    Purchase,
    Sale,
    StockBalance,
)
from apps.operations.services import post_sale, reverse_sale
from apps.tenancy.models import Business, Location, Membership

pytestmark = pytest.mark.django_db


@pytest.fixture
def client(shop):
    api = APIClient()
    api.force_authenticate(shop[0])
    return api


def _sale(shop, *, number, amount_minor, document_date, status=DocumentStatus.POSTED):
    user, business, location, _ = shop
    return Sale.objects.create(
        business=business,
        location=location,
        status=status,
        number=number,
        financial_year="2026-27",
        sequence_number=1,
        document_date=document_date,
        posted_at="2026-11-24T12:00:00Z",
        created_by=user,
        idempotency_key=number,
        grand_total_minor=amount_minor,
    )


def _purchase(shop, supplier, *, number, amount_minor, document_date):
    user, business, location, _ = shop
    return Purchase.objects.create(
        business=business,
        location=location,
        supplier=supplier,
        status=DocumentStatus.POSTED,
        number=number,
        financial_year="2026-27",
        sequence_number=1,
        document_date=document_date,
        posted_at="2026-11-24T12:00:00Z",
        created_by=user,
        idempotency_key=number,
        grand_total_minor=amount_minor,
    )


def _payment(shop, *, number, amount_minor, direction):
    user, business, location, _ = shop
    return Payment.objects.create(
        business=business,
        location=location,
        direction=direction,
        method=Payment.Method.CASH,
        amount_minor=amount_minor,
        payment_date="2026-11-24",
        status=DocumentStatus.POSTED,
        created_by=user,
        idempotency_key=number,
    )


def _ledger_entry(shop, party, *, account, amount_minor, location, source_type):
    _, business, _, _ = shop
    return PartyLedgerEntry.objects.create(
        business=business,
        location=location,
        party=party,
        account=account,
        amount_minor=amount_minor,
        source_type=source_type,
        source_id=uuid4(),
        occurred_at="2026-11-24T12:00:00Z",
    )


@freeze_time("2026-11-24 12:00:00")
def test_dashboard_contract_keeps_paise_and_reports_real_low_stock(shop, client):
    _, business, location, product = shop
    today = "2026-11-24"
    yesterday = "2026-11-23"
    other_location = Location.objects.create(business=business, code="B", name="Branch")

    product.low_stock_threshold = Decimal("10")
    product.save(update_fields=["low_stock_threshold", "updated_at"])
    StockBalance.objects.filter(product=product, location=location).update(quantity=Decimal("10"))
    StockBalance.objects.create(
        business=business, location=other_location, product=product, quantity=Decimal("0")
    )
    split_product = Product.objects.create(
        business=business, name="Split stock", low_stock_threshold=Decimal("5")
    )
    for stock_location, quantity in ((location, "4"), (other_location, "4")):
        StockBalance.objects.create(
            business=business,
            location=stock_location,
            product=split_product,
            quantity=Decimal(quantity),
        )
    inactive = Product.objects.create(
        business=business, name="Inactive", low_stock_threshold=Decimal("100"), is_active=False
    )
    StockBalance.objects.create(business=business, location=location, product=inactive, quantity=0)
    untracked = Product.objects.create(
        business=business,
        name="Service",
        low_stock_threshold=Decimal("100"),
        track_inventory=False,
    )
    StockBalance.objects.create(business=business, location=location, product=untracked, quantity=0)

    supplier = Party.objects.create(business=business, name="Supplier", kind=Party.Kind.SUPPLIER)
    _sale(shop, number="S-TODAY", amount_minor=12345, document_date=today)
    _sale(shop, number="S-OLD", amount_minor=555, document_date=yesterday)
    _sale(
        shop,
        number="S-REVERSED",
        amount_minor=999,
        document_date=today,
        status=DocumentStatus.REVERSED,
    )
    _purchase(shop, supplier, number="P-TODAY", amount_minor=23456, document_date=today)
    _purchase(shop, supplier, number="P-OLD", amount_minor=444, document_date=yesterday)
    Expense.objects.create(
        business=business,
        location=location,
        status=DocumentStatus.POSTED,
        number="E-TODAY",
        financial_year="2026-27",
        sequence_number=1,
        document_date=today,
        posted_at="2026-11-24T12:00:00Z",
        created_by=shop[0],
        idempotency_key="E-TODAY",
        category="Supplies",
        amount_minor=3000,
        tax_amount_minor=456,
        total_minor=3456,
        payment_method=Payment.Method.CASH,
    )
    _payment(shop, number="RCPT", amount_minor=1000, direction=Payment.Direction.RECEIPT)
    _payment(shop, number="PAY", amount_minor=500, direction=Payment.Direction.PAYMENT)
    customer = Party.objects.create(business=business, name="Customer", kind=Party.Kind.CUSTOMER)
    _ledger_entry(
        shop,
        customer,
        account=PartyLedgerEntry.Account.RECEIVABLE,
        amount_minor=12345,
        location=location,
        source_type="SALE",
    )
    _ledger_entry(
        shop,
        customer,
        account=PartyLedgerEntry.Account.RECEIVABLE,
        amount_minor=-1000,
        location=location,
        source_type="PAYMENT",
    )
    _ledger_entry(
        shop,
        supplier,
        account=PartyLedgerEntry.Account.PAYABLE,
        amount_minor=23456,
        location=location,
        source_type="PURCHASE",
    )
    _ledger_entry(
        shop,
        supplier,
        account=PartyLedgerEntry.Account.PAYABLE,
        amount_minor=-500,
        location=location,
        source_type="PAYMENT",
    )

    response = client.get("/api/v1/reports/dashboard/", {"business_id": str(business.pk)})
    assert response.status_code == 200
    data = response.json()
    assert data["business_id"] == str(business.pk)
    assert data["as_of"] == today
    assert data["today"] == {
        "sales_minor": 12345,
        "purchases_minor": 23456,
        "expenses_minor": 3456,
        "receipts_minor": 1000,
    }
    assert data["books"] == {
        "sales_minor": 12900,
        "purchases_minor": 23900,
        "expenses_minor": 3456,
        "receipts_minor": 1000,
        "supplier_payments_minor": 500,
        "receivable_minor": 11345,
        "payable_minor": 22956,
        "cash_flow_minor": -2956,
    }
    assert not set(data["today"]) & {"sales", "purchases", "expenses"}
    assert not set(data["books"]) & {
        "sales",
        "purchases",
        "expenses",
        "receipts",
        "supplier_payments",
        "receivable",
        "payable",
        "cash_flow",
    }
    assert data["low_stock_count"] == 1
    assert data["gross_profit_minor"] is None
    assert "₹123.45" in data["summary"]
    assert "1 low-stock product" in data["summary"]
    assert (
        client.get("/api/v1/reports/dashboard/", {"business_id": str(business.pk)}).json()[
            "summary"
        ]
        == data["summary"]
    )

    branch = client.get(
        "/api/v1/reports/dashboard/",
        {"business_id": str(business.pk), "location_id": str(other_location.pk)},
    ).json()
    assert branch["low_stock_count"] == 2


def test_product_list_and_detail_include_location_stock_and_pack_prices(shop, client):
    _, business, location, product = shop
    other_location = Location.objects.create(business=business, code="B", name="Branch")
    StockBalance.objects.create(
        business=business, location=other_location, product=product, quantity=Decimal("3")
    )
    query = {"business_id": str(business.pk), "location_id": str(location.pk)}

    listed = client.get("/api/v1/products/", query)
    assert listed.status_code == 200
    row = listed.json()["results"][0]
    assert row["id"] == str(product.pk)
    assert Decimal(row["stock_quantity"]) == Decimal("10")
    assert row["base_unit"] == Product.Unit.PIECE
    assert row["packs"] == [
        {
            "id": str(product.packs.get().pk),
            "name": "piece",
            "conversion_factor": "1.000000",
            "retail_price_minor": 80000,
            "wholesale_price_minor": 75000,
            "is_active": True,
        }
    ]

    detail = client.get(f"/api/v1/products/{product.pk}/", query)
    assert detail.status_code == 200
    assert Decimal(detail.json()["stock_quantity"]) == Decimal("10")

    branch = client.get(
        f"/api/v1/products/{product.pk}/",
        {**query, "location_id": str(other_location.pk)},
    )
    assert Decimal(branch.json()["stock_quantity"]) == Decimal("3")

    unscoped = client.get(f"/api/v1/products/{product.pk}/", {"business_id": str(business.pk)})
    assert unscoped.status_code == 200
    # Without a location filter, catalog stock aggregates every accessible location.
    assert Decimal(unscoped.json()["stock_quantity"]) == Decimal("13")


def test_party_list_and_detail_include_location_scoped_ledger_balances(shop, client):
    _, business, location, _ = shop
    other_location = Location.objects.create(business=business, code="B", name="Branch")
    party = Party.objects.create(business=business, name="Both sides", kind=Party.Kind.BOTH)
    for entry_location, receivable, payable in (
        (location, 10000, 8000),
        (other_location, 4000, 2000),
    ):
        _ledger_entry(
            shop,
            party,
            account=PartyLedgerEntry.Account.RECEIVABLE,
            amount_minor=receivable,
            location=entry_location,
            source_type="SALE",
        )
        _ledger_entry(
            shop,
            party,
            account=PartyLedgerEntry.Account.PAYABLE,
            amount_minor=payable,
            location=entry_location,
            source_type="PURCHASE",
        )
    _ledger_entry(
        shop,
        party,
        account=PartyLedgerEntry.Account.RECEIVABLE,
        amount_minor=-2500,
        location=location,
        source_type="PAYMENT",
    )
    base_query = {"business_id": str(business.pk)}

    listed = client.get("/api/v1/parties/", base_query)
    assert listed.status_code == 200
    assert listed.json()["results"][0]["receivable_minor"] == 11500
    assert listed.json()["results"][0]["payable_minor"] == 10000

    detail = client.get(f"/api/v1/parties/{party.pk}/", base_query)
    assert detail.status_code == 200
    assert detail.json()["receivable_minor"] == 11500
    assert detail.json()["payable_minor"] == 10000

    scoped = client.get(
        f"/api/v1/parties/{party.pk}/", {**base_query, "location_id": str(location.pk)}
    )
    assert scoped.status_code == 200
    assert scoped.json()["receivable_minor"] == 7500
    assert scoped.json()["payable_minor"] == 8000


def test_party_balance_tracks_posted_sale_payment_and_reversal(shop, client):
    user, business, location, product = shop
    party = Party.objects.create(
        business=business, name="Credit customer", kind=Party.Kind.CUSTOMER
    )
    sale, _ = post_sale(
        {
            "business": business,
            "location": location,
            "customer": party,
            "invoice_date": date(2026, 11, 24),
            "lines": [{"pack": product.packs.get(), "quantity": Decimal("1")}],
            "paid_amount_minor": 20000,
            "payment_method": Payment.Method.CASH,
            "idempotency_key": "contract-sale",
        },
        user,
    )
    url = f"/api/v1/parties/{party.pk}/"
    query = {"business_id": str(business.pk), "location_id": str(location.pk)}
    assert client.get(url, query).json()["receivable_minor"] == 60000

    reverse_sale(sale, user, reason="Correction", idempotency_key="contract-reversal")
    balance = client.get(url, query).json()
    assert balance["receivable_minor"] == 0
    assert balance["payable_minor"] == 0


@pytest.mark.parametrize("endpoint", ["products", "parties"])
def test_catalog_location_must_belong_to_business_and_be_accessible(shop, endpoint):
    owner, business, allowed, _ = shop
    restricted = Location.objects.create(business=business, code="B", name="Restricted")
    other = Business.objects.create(name="Other shop")
    foreign = Location.objects.create(business=other, code="MAIN", name="Foreign")
    manager = User.objects.create_user(username="manager")
    membership = Membership.objects.create(user=manager, business=business, role="MANAGER")
    membership.locations.add(allowed)
    client = APIClient()
    client.force_authenticate(manager)
    base_query = {"business_id": str(business.pk)}

    assert client.get(f"/api/v1/{endpoint}/", base_query).status_code == 200
    assert (
        client.get(
            f"/api/v1/{endpoint}/", {**base_query, "location_id": str(allowed.pk)}
        ).status_code
        == 200
    )
    assert (
        client.get(
            f"/api/v1/{endpoint}/", {**base_query, "location_id": str(restricted.pk)}
        ).status_code
        == 403
    )
    assert client.get(
        f"/api/v1/{endpoint}/", {**base_query, "location_id": str(foreign.pk)}
    ).status_code in {403, 404}
    assert (
        client.get(f"/api/v1/{endpoint}/", {**base_query, "location_id": "not-a-uuid"}).status_code
        == 400
    )

    client.force_authenticate(owner)
    assert client.get(
        f"/api/v1/{endpoint}/", {**base_query, "location_id": str(foreign.pk)}
    ).status_code in {403, 404}


def test_owner_can_patch_and_update_business_settings(shop, client):
    _, business, _, _ = shop
    url = f"/api/v1/businesses/{business.pk}/"
    response = client.patch(
        url,
        {"name": "Renamed shop", "negative_stock_allowed": False},
        format="json",
    )
    assert response.status_code == 200
    business.refresh_from_db()
    assert business.name == "Renamed shop"
    assert business.negative_stock_allowed is False

    response = client.put(url, {"name": "Updated shop"}, format="json")
    assert response.status_code == 200
    business.refresh_from_db()
    assert business.name == "Updated shop"


@pytest.mark.parametrize("field", ["business", "business_id", "id"])
def test_business_update_cannot_move_tenant_identity(shop, client, field):
    _, business, _, _ = shop
    other = Business.objects.create(name="Other shop")
    response = client.patch(
        f"/api/v1/businesses/{business.pk}/",
        {field: str(other.pk), "name": "Moved"},
        format="json",
    )
    assert response.status_code == 400
    business.refresh_from_db()
    assert business.name == "Test shop"
    assert Business.objects.filter(pk=business.pk).exists()


@pytest.mark.parametrize("role", [Membership.Role.MANAGER, Membership.Role.CASHIER])
def test_non_owner_cannot_update_business(shop, role):
    user, business, location, _ = shop
    membership = Membership.objects.get(user=user, business=business)
    membership.role = role
    membership.save(update_fields=["role", "updated_at"])
    membership.locations.add(location)
    client = APIClient()
    client.force_authenticate(user)
    response = client.patch(
        f"/api/v1/businesses/{business.pk}/", {"name": "Unauthorized"}, format="json"
    )
    assert response.status_code == 403
    business.refresh_from_db()
    assert business.name == "Test shop"
