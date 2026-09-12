import uuid
from decimal import Decimal

import pytest
from rest_framework.test import APIClient

from apps.tenancy.models import GSTRegistration, Membership

pytestmark = pytest.mark.django_db


def make_client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def create_party(client, business, name, kind):
    response = client.post(
        "/api/v1/parties/",
        {"business": str(business.pk), "name": name, "kind": kind},
        format="json",
    )
    assert response.status_code == 201, response.data
    return response.data["id"]


def create_sale(
    client,
    shop,
    *,
    customer_name="Ramesh",
    quantity="3",
    unit_price_minor=80000,
    paid=150000,
):
    _, business, location, product = shop
    pack = product.packs.first()
    customer_id = create_party(client, business, customer_name, "CUSTOMER")
    response = client.post(
        "/api/v1/sales/",
        {
            "business_id": str(business.pk),
            "location_id": str(location.pk),
            "customer_id": customer_id,
            "price_mode": "RETAIL",
            "tax_inclusive": False,
            "lines": [
                {
                    "pack_id": str(pack.pk),
                    "quantity": quantity,
                    "unit_price_minor": unit_price_minor,
                }
            ],
            "paid_amount_minor": paid,
            "payment_method": "CASH",
            "idempotency_key": str(uuid.uuid4()),
        },
        format="json",
    )
    assert response.status_code == 201, response.data
    return response.data


def create_purchase(
    client,
    shop,
    *,
    supplier_name="Wholesale supplier",
    quantity="5",
    unit_cost_minor=40000,
    paid=0,
):
    _, business, location, product = shop
    pack = product.packs.first()
    supplier_id = create_party(client, business, supplier_name, "SUPPLIER")
    response = client.post(
        "/api/v1/purchases/",
        {
            "business_id": str(business.pk),
            "location_id": str(location.pk),
            "supplier_id": supplier_id,
            "tax_inclusive": False,
            "lines": [
                {
                    "pack_id": str(pack.pk),
                    "quantity": quantity,
                    "unit_cost_minor": unit_cost_minor,
                }
            ],
            "paid_amount_minor": paid,
            "payment_method": "CASH",
            "idempotency_key": str(uuid.uuid4()),
        },
        format="json",
    )
    assert response.status_code == 201, response.data
    return response.data


def create_expense(client, shop, amount_minor=25000, category="Rent"):
    _, business, location, _ = shop
    response = client.post(
        "/api/v1/expenses/",
        {
            "business_id": str(business.pk),
            "location_id": str(location.pk),
            "category": category,
            "amount_minor": amount_minor,
            "payment_method": "CASH",
            "idempotency_key": str(uuid.uuid4()),
        },
        format="json",
    )
    assert response.status_code == 201, response.data
    return response.data


def report_params(business, location=None):
    params = {"business_id": str(business.pk)}
    if location is not None:
        params["location_id"] = str(location.pk)
    return params


def test_day_book_lists_documents_and_cash_totals(shop):
    user, business, location, _ = shop
    client = make_client(user)
    create_sale(client, shop)
    create_purchase(client, shop)
    create_expense(client, shop)
    response = client.get("/api/v1/reports/day-book/", report_params(business, location))
    assert response.status_code == 200, response.data
    data = response.data
    kinds = {entry["kind"] for entry in data["entries"]}
    assert {"SALE", "PURCHASE", "PAYMENT_IN", "EXPENSE"} <= kinds
    assert data["summary"]["sales_minor"] == 240000
    assert data["summary"]["purchases_minor"] == 200000
    assert data["summary"]["receipts_minor"] == 150000
    assert data["summary"]["expenses_minor"] == 25000
    assert data["summary"]["net_cash_minor"] == 150000 - 0 - 25000

    empty = client.get(
        "/api/v1/reports/day-book/",
        {**report_params(business, location), "from": "2099-01-01", "to": "2099-01-02"},
    )
    assert empty.status_code == 200
    assert empty.data["entries"] == []
    assert empty.data["summary"]["sales_minor"] == 0


def test_sales_report_groups_by_day_party_and_product(shop):
    user, business, location, _ = shop
    client = make_client(user)
    create_sale(client, shop)
    params = report_params(business, location)

    by_party = client.get("/api/v1/reports/sales/", {**params, "group_by": "party"})
    assert by_party.status_code == 200
    assert by_party.data["rows"][0]["label"] == "Ramesh"
    assert by_party.data["rows"][0]["grand_total_minor"] == 240000

    by_product = client.get("/api/v1/reports/sales/", {**params, "group_by": "product"})
    assert by_product.data["rows"][0]["label"] == "shirt"
    assert Decimal(by_product.data["rows"][0]["quantity"]) == Decimal("3")

    by_day = client.get("/api/v1/reports/sales/", {**params, "group_by": "day"})
    assert by_day.data["rows"][0]["count"] == 1
    assert by_day.data["totals"]["grand_total_minor"] == 240000


def test_purchase_report_requires_manager(shop):
    user, business, location, _ = shop
    client = make_client(user)
    create_purchase(client, shop)
    params = report_params(business, location)
    allowed = client.get("/api/v1/reports/purchases/", params)
    assert allowed.status_code == 200
    assert allowed.data["totals"]["grand_total_minor"] == 200000

    membership = Membership.objects.get(user=user)
    membership.role = "CASHIER"
    membership.save()
    membership.locations.add(location)
    denied = client.get("/api/v1/reports/purchases/", params)
    assert denied.status_code == 403


def test_gst_report_splits_output_and_b2c(shop):
    user, business, location, product = shop
    business.gst_enabled = True
    business.save(update_fields=["gst_enabled"])
    registration = GSTRegistration.objects.create(
        business=business,
        gstin="27AAAAA1234A1Z5",
        legal_name="Test shop",
        state_code="27",
        invoice_prefix="INV",
    )
    location.gst_registration = registration
    location.state_code = "27"
    location.save(update_fields=["gst_registration", "state_code"])
    product.tax_rate_bps = 1800
    product.save(update_fields=["tax_rate_bps"])

    client = make_client(user)
    create_sale(client, shop, paid=240000)
    response = client.get("/api/v1/reports/gst/", report_params(business, location))
    assert response.status_code == 200, response.data
    output = response.data["output"]
    assert output["totals"]["taxable_minor"] == 240000
    assert output["totals"]["cgst_minor"] == 21600
    assert output["totals"]["sgst_minor"] == 21600
    assert output["totals"]["igst_minor"] == 0
    assert response.data["b2c"]["count"] == 1
    assert response.data["b2b"]["count"] == 0


def test_party_balances_and_cashier_payable_masking(shop):
    user, business, location, _ = shop
    client = make_client(user)
    create_sale(client, shop)
    create_purchase(client, shop)
    response = client.get("/api/v1/reports/party-balances/", report_params(business, location))
    assert response.status_code == 200
    by_name = {row["name"]: row for row in response.data["rows"]}
    assert by_name["Ramesh"]["receivable_minor"] == 90000
    assert by_name["Wholesale supplier"]["payable_minor"] == 200000
    assert response.data["totals"]["payable_minor"] == 200000

    membership = Membership.objects.get(user=user)
    membership.role = "CASHIER"
    membership.save()
    membership.locations.add(location)
    parties = client.get("/api/v1/parties/", {"business_id": str(business.pk)})
    assert parties.status_code == 200
    supplier = next(row for row in parties.data if row["name"] == "Wholesale supplier")
    assert supplier["payable_minor"] == 0
    denied = client.get("/api/v1/reports/party-balances/", report_params(business, location))
    assert denied.status_code == 403


def test_stock_valuation_uses_latest_purchase_cost(shop):
    user, business, location, _ = shop
    client = make_client(user)
    create_purchase(client, shop, quantity="5", unit_cost_minor=40000)
    create_sale(client, shop, quantity="3", paid=240000)
    # 10 opening + 5 purchased - 3 sold = 12
    response = client.get("/api/v1/reports/stock-valuation/", report_params(business, location))
    assert response.status_code == 200, response.data
    row = response.data["rows"][0]
    assert Decimal(row["quantity"]) == Decimal("12")
    assert Decimal(row["cost_per_base_unit_minor"]) == Decimal("40000")
    assert row["stock_value_cost_minor"] == 480000
    assert row["stock_value_retail_minor"] == 960000


def test_stock_movements_filter_by_type_and_product(shop):
    user, business, location, product = shop
    client = make_client(user)
    create_sale(client, shop, quantity="3", paid=240000)
    response = client.get(
        "/api/v1/stock/movements/",
        {
            **report_params(business, location),
            "movement_type": "SALE",
            "product_id": str(product.pk),
        },
    )
    assert response.status_code == 200
    assert len(response.data) == 1
    assert response.data[0]["movement_type"] == "SALE"
    assert Decimal(response.data[0]["quantity"]) == Decimal("-3")
    empty = client.get(
        "/api/v1/stock/movements/",
        {**report_params(business, location), "movement_type": "PURCHASE"},
    )
    assert empty.data == []


def test_report_export_returns_csv(shop):
    user, business, location, _ = shop
    client = make_client(user)
    create_sale(client, shop)
    response = client.get(
        "/api/v1/reports/export/",
        {**report_params(business, location), "report": "sales", "group_by": "day"},
    )
    assert response.status_code == 200
    assert response["Content-Type"].startswith("text/csv")
    assert 'filename="sales-' in response["Content-Disposition"]
    body = response.content.decode()
    assert body.splitlines()[0].startswith("key,label,count")
    assert "240000" in body


def test_posting_list_supports_date_status_and_pagination(shop):
    user, business, location, _ = shop
    client = make_client(user)
    create_sale(client, shop, customer_name="Ramesh")
    create_sale(client, shop, customer_name="Suresh")
    params = report_params(business, location)

    paged = client.get("/api/v1/sales/", {**params, "limit": "1"})
    assert paged.status_code == 200
    assert paged.data["count"] == 2
    assert len(paged.data["results"]) == 1

    filtered = client.get("/api/v1/sales/", {**params, "from": "2099-01-01", "to": "2099-01-02"})
    assert filtered.data == []

    bad_status = client.get("/api/v1/sales/", {**params, "status": "BROKEN"})
    assert bad_status.status_code == 400


def test_invalid_date_range_is_rejected(shop):
    user, business, location, _ = shop
    client = make_client(user)
    params = report_params(business, location)
    bad = client.get("/api/v1/reports/day-book/", {**params, "from": "not-a-date"})
    assert bad.status_code == 400
    assert (
        client.get(
            "/api/v1/reports/day-book/", {**params, "from": "2026-02-02", "to": "2026-01-01"}
        ).status_code
        == 400
    )
