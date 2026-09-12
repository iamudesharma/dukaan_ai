import uuid
from decimal import Decimal

import pytest
from rest_framework.test import APIClient

from apps.catalog.models import Product, ProductPack
from apps.operations.models import StockBalance

pytestmark = pytest.mark.django_db


def make_client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def create_customer(client, business, name="Ramesh"):
    response = client.post(
        "/api/v1/parties/",
        {"business": str(business.pk), "name": name, "kind": "CUSTOMER"},
        format="json",
    )
    assert response.status_code == 201, response.data
    return response.data["id"]


def post_credit_sale(client, shop, *, quantity="3", unit_price_minor=80000, paid=150000):
    _, business, location, product = shop
    pack = product.packs.first()
    customer_id = create_customer(client, business)
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


def first_row(response):
    if isinstance(response.data, dict):
        return response.data["results"][0]
    return response.data[0]


def test_product_list_exposes_stock_and_low_stock_flag(shop):
    user, business, location, product = shop
    client = make_client(user)
    response = client.get(
        "/api/v1/products/",
        {"business_id": str(business.pk), "location_id": str(location.pk)},
    )
    assert response.status_code == 200
    row = first_row(response)
    assert Decimal(row["stock_quantity"]) == Decimal("10")
    assert row["is_low_stock"] is False
    assert row["default_pack_id"] == str(product.packs.first().pk)


def test_product_stock_is_location_scoped(shop):
    user, business, _, product = shop
    from apps.tenancy.models import Location

    branch = Location.objects.create(business=business, code="BR2", name="Branch")
    StockBalance.objects.create(business=business, location=branch, product=product, quantity=4)
    client = make_client(user)
    response = client.get(
        "/api/v1/products/",
        {"business_id": str(business.pk), "location_id": str(branch.pk)},
    )
    assert Decimal(first_row(response)["stock_quantity"]) == Decimal("4")


def test_party_list_exposes_balances_and_phone_alias(shop):
    user, business, _, _ = shop
    client = make_client(user)
    post_credit_sale(client, shop)
    response = client.get("/api/v1/parties/", {"business_id": str(business.pk)})
    assert response.status_code == 200
    row = first_row(response)
    assert row["receivable_minor"] == 90000
    assert row["payable_minor"] == 0
    assert row["phone"] == ""


def test_document_list_exposes_names_and_timestamps(shop):
    user, business, location, _ = shop
    client = make_client(user)
    post_credit_sale(client, shop)
    response = client.get(
        "/api/v1/sales/",
        {"business_id": str(business.pk), "location_id": str(location.pk)},
    )
    assert response.status_code == 200
    row = first_row(response)
    assert row["customer_name"] == "Ramesh"
    assert row["invoice_number"] == row["number"]
    assert row["occurred_at"]


def test_dashboard_includes_receipts_profit_low_stock_and_summary(shop):
    user, business, location, _ = shop
    client = make_client(user)
    post_credit_sale(client, shop)
    extra = Product.objects.create(business=business, name="cap", low_stock_threshold=5)
    ProductPack.objects.create(
        product=extra,
        name="piece",
        conversion_factor=1,
        retail_price_minor=10000,
        wholesale_price_minor=9000,
    )
    StockBalance.objects.create(business=business, location=location, product=extra, quantity=3)
    response = client.get(
        "/api/v1/reports/dashboard/",
        {"business_id": str(business.pk), "location_id": str(location.pk)},
    )
    assert response.status_code == 200
    data = response.data
    assert data["today"]["sales"] == 240000
    assert data["today"]["receipts"] == 150000
    assert data["books"]["receipts"] == 150000
    assert data["receipts_minor"] == 150000
    assert data["books"]["gross_profit_minor"] == 240000
    assert data["low_stock_count"] == 1
    assert "2,400" in data["summary"]


def test_location_primary_and_membership_identity(shop):
    user, business, location, _ = shop
    client = make_client(user)
    locations = client.get("/api/v1/locations/", {"business_id": str(business.pk)})
    assert locations.status_code == 200
    row = first_row(locations)
    assert row["id"] == str(location.pk)
    assert row["is_primary"] is True
    memberships = client.get("/api/v1/memberships/", {"business_id": str(business.pk)})
    assert memberships.status_code == 200
    member = first_row(memberships)
    assert member["user_name"] == "owner"
    assert member["user_phone"] == ""


def test_assistant_preview_data_and_negative_stock_acknowledgement(shop):
    user, business, location, product = shop
    StockBalance.objects.filter(product=product).update(quantity=1)
    client = make_client(user)
    response = client.post(
        "/api/v1/assistant/proposals/",
        {
            "business_id": str(business.pk),
            "location_id": str(location.pk),
            "input_type": "TEXT",
            "content": "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.",
            "locale": "en-IN",
        },
        format="json",
    )
    assert response.status_code == 201
    proposal = response.data
    assert proposal["command_type"] == "SALE"
    assert proposal["status"] == "READY"
    labels = [fact["label"] for fact in proposal["preview_data"]["facts"]]
    assert "Party" in labels
    assert "shirt" in labels
    assert proposal["preview_data"]["summary"] == proposal["preview"]

    blocked = client.post(
        f"/api/v1/assistant/proposals/{proposal['id']}/confirm/",
        {"version": 1, "idempotency_key": "negative-1"},
        format="json",
    )
    assert blocked.status_code == 409
    assert blocked.data["error"]["detail"]["code"] == "negative_stock_confirmation_required"

    acknowledged = client.post(
        f"/api/v1/assistant/proposals/{proposal['id']}/confirm/",
        {
            "version": 1,
            "idempotency_key": "negative-1",
            "negative_stock_acknowledged": True,
            "negative_stock_reason": "Physical count was lower",
        },
        format="json",
    )
    assert acknowledged.status_code == 200, acknowledged.data
    assert acknowledged.data["result"]["number"]
    assert acknowledged.data["result"]["negative_stock_acknowledged"] is True
