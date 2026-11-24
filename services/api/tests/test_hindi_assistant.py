"""Offline Hindi commands stay deterministic, reviewable, and fail closed."""

from decimal import Decimal

import pytest
from rest_framework.test import APIClient

from apps.catalog.models import Party, Product, ProductPack
from apps.operations.models import Expense, Purchase, Sale, StockBalance
from apps.tenancy.models import Membership

pytestmark = pytest.mark.django_db


@pytest.fixture
def hindi_catalog(shop):
    _, business, location, _ = shop
    customer = Party.objects.create(business=business, name="रमेश", kind=Party.Kind.CUSTOMER)
    supplier = Party.objects.create(business=business, name="गुप्ता ट्रेडर्स", kind=Party.Kind.SUPPLIER)
    product = Product.objects.create(business=business, name="शर्ट")
    pack = ProductPack.objects.create(
        product=product,
        name="piece",
        conversion_factor=Decimal("1"),
        retail_price_minor=80000,
        wholesale_price_minor=75000,
    )
    StockBalance.objects.create(business=business, location=location, product=product, quantity=10)
    return customer, supplier, product, pack


def _client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def _proposal(client, shop, content, *, locale="hi-IN"):
    _, business, location, _ = shop
    response = client.post(
        "/api/v1/assistant/proposals/",
        {
            "business_id": str(business.pk),
            "location_id": str(location.pk),
            "input_type": "TEXT",
            "content": content,
            "locale": locale,
        },
        format="json",
    )
    assert response.status_code == 201, response.data
    return response.data


def test_hindi_sale_is_review_only_until_explicit_confirmation(shop, hindi_catalog):
    user, business, location, _ = shop
    customer, _, _, pack = hindi_catalog
    client = _client(user)

    proposal = _proposal(
        client,
        shop,
        "रमेश ने 3 शर्ट 2400 रुपये के लिए खरीदे, 1500 रुपये दिए और 900 रुपये बाकी।",
    )

    assert proposal["status"] == "READY"
    assert proposal["command_type"] == "SALE"
    assert proposal["payload"]["customer_id"] == str(customer.pk)
    assert proposal["payload"]["paid_amount_minor"] == 150000
    assert proposal["payload"]["lines"][0]["pack_id"] == str(pack.pk)
    assert proposal["payload"]["lines"][0]["quantity"] == "3"
    assert not Sale.objects.filter(business=business).exists()

    confirmed = client.post(
        f"/api/v1/assistant/proposals/{proposal['id']}/confirm/",
        {"version": proposal["version"], "idempotency_key": "hindi-sale-confirm"},
        format="json",
    )
    assert confirmed.status_code == 200, confirmed.data
    sale = Sale.objects.get(business=business, location=location)
    assert sale.grand_total_minor == 240000
    assert sale.paid_total_minor == 150000
    assert sale.due_total_minor == 90000


def test_hindi_purchase_and_expense_use_existing_posting_validation(shop, hindi_catalog):
    user, business, _, _ = shop
    _, supplier, _, pack = hindi_catalog
    client = _client(user)

    purchase_proposal = _proposal(
        client,
        shop,
        "गुप्ता ट्रेडर्स से 2 शर्ट 1600 रुपये में खरीदीं, 600 रुपये दिए।",
    )
    assert purchase_proposal["status"] == "READY", purchase_proposal
    assert purchase_proposal["command_type"] == "PURCHASE"
    assert purchase_proposal["payload"]["supplier_id"] == str(supplier.pk)
    assert purchase_proposal["payload"]["lines"][0]["pack_id"] == str(pack.pk)
    assert not Purchase.objects.filter(business=business).exists()

    expense_proposal = _proposal(client, shop, "बिजली का बिल 1200 रुपये।")
    assert expense_proposal["status"] == "READY", expense_proposal
    assert expense_proposal["command_type"] == "EXPENSE"
    assert expense_proposal["payload"]["category"] == "बिजली"
    assert expense_proposal["payload"]["amount_minor"] == 120000
    assert not Expense.objects.filter(business=business).exists()


def test_hindi_paid_before_total_and_mismatched_due_are_handled_safely(shop, hindi_catalog):
    user, _, _, _ = shop
    client = _client(user)

    valid = _proposal(
        client,
        shop,
        "रमेश ने 3 शर्ट खरीदे, 1500 रुपये दिए और कुल 2400 रुपये।",
    )
    assert valid["status"] == "READY", valid
    assert valid["payload"]["paid_amount_minor"] == 150000
    assert valid["payload"]["lines"][0]["unit_price_minor"] == 80000

    invalid = _proposal(
        client,
        shop,
        "रमेश ने 3 शर्ट 2400 रुपये के लिए खरीदे, 1500 रुपये दिए और 800 रुपये बाकी।",
    )
    assert invalid["status"] == "DRAFT"
    assert invalid["command_type"] == "UNSUPPORTED"
    assert invalid["payload"] == {}
    assert invalid["blocking_questions"]


def test_hindi_requires_exact_product_and_hindi_locale(shop, hindi_catalog):
    user, _, _, _ = shop
    client = _client(user)

    ambiguous = _proposal(client, shop, "रमेश ने 3 जीन्स 2400 रुपये के लिए खरीदे।")
    assert ambiguous["status"] == "DRAFT"
    assert ambiguous["command_type"] == "UNSUPPORTED"

    wrong_locale = _proposal(
        client,
        shop,
        "रमेश ने 3 शर्ट 2400 रुपये के लिए खरीदे।",
        locale="en-IN",
    )
    assert wrong_locale["status"] == "DRAFT"
    assert wrong_locale["command_type"] == "UNSUPPORTED"


def test_cashier_cannot_confirm_hindi_purchase(shop, hindi_catalog):
    user, business, location, _ = shop
    membership = Membership.objects.get(user=user, business=business)
    membership.role = Membership.Role.CASHIER
    membership.save(update_fields=["role", "updated_at"])
    membership.locations.add(location)
    client = _client(user)
    proposal = _proposal(
        client,
        shop,
        "गुप्ता ट्रेडर्स से 2 शर्ट 1600 रुपये में खरीदीं।",
    )
    assert proposal["status"] == "READY"

    response = client.post(
        f"/api/v1/assistant/proposals/{proposal['id']}/confirm/",
        {"version": proposal["version"], "idempotency_key": "cashier-hindi-purchase"},
        format="json",
    )
    assert response.status_code == 403
    assert not Purchase.objects.filter(business=business).exists()
