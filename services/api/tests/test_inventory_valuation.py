from datetime import date
from decimal import Decimal
from unittest.mock import patch

import pytest
from rest_framework.test import APIClient

from apps.catalog.models import Party
from apps.operations.models import (
    DocumentStatus,
    InventoryCostLayer,
    Purchase,
    Sale,
    SaleLine,
    StockBalance,
)
from apps.operations.services import (
    DomainConflict,
    post_purchase,
    post_sale,
    post_transfer,
    reverse_purchase,
    reverse_sale,
    reverse_transfer,
    weighted_average_unit_cost,
)
from apps.tenancy.models import Business, Location, Membership

pytestmark = pytest.mark.django_db
TODAY = date(2026, 11, 24)


def _reset_stock(shop):
    _, business, location, product = shop
    StockBalance.objects.filter(business=business, location=location, product=product).update(
        quantity=Decimal("0"),
        costed_quantity=Decimal("0"),
        unknown_cost_quantity=Decimal("0"),
        inventory_value_minor=0,
        average_cost_minor=None,
    )


def _parties(shop):
    _, business, _, _ = shop
    return (
        Party.objects.create(business=business, name="Customer", kind=Party.Kind.CUSTOMER),
        Party.objects.create(business=business, name="Supplier", kind=Party.Kind.SUPPLIER),
    )


def _purchase(shop, *, key, quantity="1", unit_cost=10000):
    user, business, location, product = shop
    _, supplier = _parties(shop)
    purchase, replayed = post_purchase(
        {
            "business": business,
            "location": location,
            "supplier": supplier,
            "purchase_date": TODAY,
            "lines": [
                {
                    "pack": product.packs.get(),
                    "quantity": Decimal(quantity),
                    "unit_cost_minor": unit_cost,
                }
            ],
            "idempotency_key": key,
        },
        user,
    )
    return purchase, replayed


def _sale(shop, *, key, quantity="1", unit_price=20000, lines=None, **extra):
    user, business, location, product = shop
    customer, _ = _parties(shop)
    sale, replayed = post_sale(
        {
            "business": business,
            "location": location,
            "customer": customer,
            "invoice_date": TODAY,
            "lines": lines
            or [
                {
                    "pack": product.packs.get(),
                    "quantity": Decimal(quantity),
                    "unit_price_minor": unit_price,
                }
            ],
            "idempotency_key": key,
            **extra,
        },
        user,
    )
    return sale, replayed


def _balance(shop):
    _, business, location, product = shop
    return StockBalance.objects.get(business=business, location=location, product=product)


def _client(shop):
    client = APIClient()
    client.force_authenticate(shop[0])
    return client


def test_weighted_average_uses_decimal_quantity_and_integer_paise():
    assert weighted_average_unit_cost(100_000, Decimal("7.5")) == 13_333
    assert weighted_average_unit_cost(10_001, Decimal("2")) == 5_001
    assert weighted_average_unit_cost(0, Decimal("2")) == 0
    assert weighted_average_unit_cost(10_000, Decimal("0")) is None


def test_partial_purchase_and_sale_layers_reconcile_to_valuation(shop):
    _reset_stock(shop)
    _purchase(shop, key="p-1", quantity="2.5", unit_cost=333)
    _purchase(shop, key="p-2", quantity="1.25", unit_cost=1000)
    balance = _balance(shop)
    assert balance.quantity == Decimal("3.750")
    assert balance.inventory_value_minor == 2083
    assert balance.average_cost_minor == 555

    sale, _ = _sale(shop, key="s-partial", quantity="0.625", unit_price=1000)
    line = sale.lines.get()
    assert line.base_quantity == Decimal("0.625")
    assert line.unit_cost_minor == 555
    assert line.cogs_minor == 347
    assert line.costing_complete is True

    balance.refresh_from_db()
    assert balance.quantity == Decimal("3.125")
    assert balance.costed_quantity == Decimal("3.125")
    assert balance.unknown_cost_quantity == Decimal("0")
    assert balance.inventory_value_minor == 1736
    layers = InventoryCostLayer.objects.all()
    assert sum((layer.quantity_delta for layer in layers), Decimal("0")) == balance.quantity
    assert sum((layer.value_delta_minor for layer in layers), 0) == balance.inventory_value_minor


def test_multiple_sale_lines_share_one_average_and_exact_cogs_remainder(shop):
    _reset_stock(shop)
    _purchase(shop, key="p-rounding", quantity="1", unit_cost=1)
    pack = shop[3].packs.get()
    sale, _ = _sale(
        shop,
        key="s-rounding",
        lines=[
            {"pack": pack, "quantity": Decimal("0.5"), "unit_price_minor": 100},
            {"pack": pack, "quantity": Decimal("0.5"), "unit_price_minor": 100},
        ],
    )
    assert sorted(line.cogs_minor for line in sale.lines.all()) == [0, 1]
    assert all(line.costing_complete for line in sale.lines.all())
    assert _balance(shop).inventory_value_minor == 0


def test_sale_reversal_restores_original_layer_cost_after_later_purchase(shop):
    _reset_stock(shop)
    first, _ = _purchase(shop, key="p-first", quantity="10", unit_cost=10000)
    sale, _ = _sale(shop, key="s-reverse", quantity="4", unit_price=30000)
    original_cogs = sale.lines.get().cogs_minor
    _purchase(shop, key="p-later", quantity="10", unit_cost=20000)
    assert _balance(shop).inventory_value_minor == 260_000

    reverse_sale(sale, shop[0], reason="Wrong quantity", idempotency_key="s-reverse-1")
    balance = _balance(shop)
    assert balance.quantity == Decimal("20.000")
    assert balance.inventory_value_minor == 300_000
    assert balance.average_cost_minor == 15_000
    reversal = InventoryCostLayer.objects.get(
        source_type="SALE", source_id=sale.id, reversal_of__isnull=False
    )
    original = reversal.reversal_of
    assert reversal.value_delta_minor == -original.value_delta_minor == original_cogs
    assert reversal.quantity_delta == -original.quantity_delta

    reverse_purchase(first, shop[0], reason="Wrong cost", idempotency_key="p-first-reverse")
    balance.refresh_from_db()
    assert balance.quantity == Decimal("10.000")
    assert balance.inventory_value_minor == 200_000
    assert balance.average_cost_minor == 20_000
    assert InventoryCostLayer.objects.filter(reversal_of__isnull=False).count() == 2


def test_purchase_and_sale_idempotency_does_not_duplicate_layers(shop):
    _reset_stock(shop)
    purchase, replayed = _purchase(shop, key="same-purchase", quantity="2", unit_cost=10000)
    assert not replayed
    same_purchase, replayed = _purchase(shop, key="same-purchase", quantity="2", unit_cost=10000)
    assert replayed and same_purchase.pk == purchase.pk
    assert (
        InventoryCostLayer.objects.filter(layer_type=InventoryCostLayer.Type.PURCHASE).count() == 1
    )

    sale, replayed = _sale(shop, key="same-sale", quantity="1")
    assert not replayed
    same_sale, replayed = _sale(shop, key="same-sale", quantity="1")
    assert replayed and same_sale.pk == sale.pk
    assert InventoryCostLayer.objects.filter(layer_type=InventoryCostLayer.Type.SALE).count() == 1
    assert SaleLine.objects.count() == 1


def test_unknown_stock_is_not_assigned_zero_cogs_or_profit(shop):
    # The shop fixture has ten legacy units with no cost history.
    sale, _ = _sale(shop, key="unknown-cost", quantity="3", unit_price=20000)
    line = sale.lines.get()
    assert line.cogs_minor is None
    assert line.unit_cost_minor is None
    assert line.costing_complete is False
    balance = _balance(shop)
    assert balance.quantity == Decimal("7.000")
    assert balance.unknown_cost_quantity == Decimal("7.000")
    assert balance.inventory_value_minor == 0

    response = _client(shop).get("/api/v1/reports/valuation/", {"business_id": str(shop[1].pk)})
    assert response.status_code == 200
    data = response.json()
    assert data["sales"]["cogs_minor"] == 0
    assert data["sales"]["gross_profit_minor"] is None
    assert data["sales"]["costing_complete"] is False
    assert data["inventory"]["total_value_minor"] is None
    assert Decimal(data["results"][0]["quantity"]) == Decimal("7")


def test_negative_stock_policy_and_missing_cost_are_preserved(shop):
    _reset_stock(shop)
    shop[1].negative_stock_allowed = False
    shop[1].save(update_fields=["negative_stock_allowed", "updated_at"])
    with pytest.raises(DomainConflict) as error:
        _sale(shop, key="blocked-negative", quantity="1")
    assert error.value.detail["code"] == "negative_stock_blocked"
    assert Sale.objects.count() == InventoryCostLayer.objects.count() == 0

    shop[1].negative_stock_allowed = True
    shop[1].save(update_fields=["negative_stock_allowed", "updated_at"])
    sale, _ = _sale(
        shop,
        key="allowed-negative",
        quantity="1",
        negative_stock_acknowledged=True,
        negative_stock_reason="Confirmed stock count",
    )
    assert sale.lines.get().cogs_minor is None
    balance = _balance(shop)
    assert balance.quantity == Decimal("-1.000")
    assert balance.costed_quantity == Decimal("-1.000")
    assert balance.average_cost_minor is None

    reverse_sale(sale, shop[0], reason="Corrected", idempotency_key="negative-reverse")
    balance.refresh_from_db()
    assert balance.quantity == Decimal("0.000")
    assert balance.costed_quantity == Decimal("0.000")


def test_valuation_report_uses_posted_sales_and_net_sales(shop):
    _reset_stock(shop)
    _purchase(shop, key="report-purchase", quantity="10", unit_cost=10000)
    sale, _ = _sale(shop, key="report-sale", quantity="4", unit_price=20000)
    reversed_sale, _ = _sale(shop, key="report-reversed-sale", quantity="1", unit_price=50000)
    reverse_sale(
        reversed_sale,
        shop[0],
        reason="Excluded from report",
        idempotency_key="report-reversed-sale-reverse",
    )

    response = _client(shop).get("/api/v1/reports/valuation/", {"business_id": str(shop[1].pk)})
    assert response.status_code == 200
    data = response.json()
    row = data["results"][0]
    assert Decimal(row["quantity"]) == Decimal("6")
    assert row["average_cost_minor"] == 10_000
    assert row["total_value_minor"] == 60_000
    assert data["inventory"]["total_value_minor"] == 60_000
    assert data["sales"]["posted_sale_count"] == 1
    assert data["sales"]["net_sales_minor"] == 80_000
    assert data["sales"]["cogs_minor"] == sale.lines.get().cogs_minor == 40_000
    assert data["sales"]["gross_profit_minor"] == 40_000
    assert data["sales"]["costing_complete"] is True
    dashboard = (
        _client(shop).get("/api/v1/reports/dashboard/", {"business_id": str(shop[1].pk)}).json()
    )
    assert dashboard["gross_profit_minor"] == 40_000

    excluded = (
        _client(shop)
        .get(
            "/api/v1/reports/valuation/",
            {"business_id": str(shop[1].pk), "date_from": "2026-11-25"},
        )
        .json()
    )
    assert excluded["sales"]["posted_sale_count"] == 0
    assert excluded["sales"]["gross_profit_minor"] == 0


def test_valuation_report_is_tenant_isolated_and_manager_only(shop):
    user, business, _, _ = shop
    other = Business.objects.create(name="Foreign valuation")
    client = _client(shop)
    response = client.get("/api/v1/reports/valuation/", {"business_id": str(other.pk)})
    assert response.status_code in {403, 404}

    membership = Membership.objects.get(user=user, business=business)
    membership.role = Membership.Role.CASHIER
    membership.save(update_fields=["role", "updated_at"])
    response = client.get("/api/v1/reports/valuation/", {"business_id": str(business.pk)})
    assert response.status_code == 403


def test_cashier_sale_responses_do_not_expose_cost_fields(shop):
    _reset_stock(shop)
    _purchase(shop, key="privacy-purchase", quantity="2", unit_cost=10000)
    sale, _ = _sale(shop, key="privacy-sale", quantity="1")
    user, business, location, _ = shop
    membership = Membership.objects.get(user=user, business=business)
    membership.role = Membership.Role.CASHIER
    membership.save(update_fields=["role", "updated_at"])
    membership.locations.add(location)
    client = _client(shop)
    query = {"business_id": str(business.pk), "location_id": str(location.pk)}
    listed = client.get("/api/v1/sales/", query).json()[0]
    detail = client.get(f"/api/v1/sales/{sale.pk}/", query).json()
    for row in (listed, detail):
        assert "unit_cost_minor" not in row["lines"][0]
        assert "cogs_minor" not in row["lines"][0]
        assert "costing_complete" not in row["lines"][0]

    membership.role = Membership.Role.OWNER
    membership.save(update_fields=["role", "updated_at"])
    owner_row = client.get(f"/api/v1/sales/{sale.pk}/", query).json()
    assert owner_row["lines"][0]["cogs_minor"] == 10_000


def test_transfer_moves_valuation_and_reversal_restores_both_locations(shop):
    _reset_stock(shop)
    _purchase(shop, key="transfer-purchase", quantity="10", unit_cost=10000)
    user, business, location, product = shop
    destination = Location.objects.create(business=business, code="B", name="Branch")
    transfer, _ = post_transfer(
        {
            "business": business,
            "from_location": location,
            "to_location": destination,
            "lines": [{"pack": product.packs.get(), "quantity": Decimal("3")}],
            "transfer_date": TODAY,
            "idempotency_key": "transfer-1",
        },
        user,
    )
    source = _balance(shop)
    target = StockBalance.objects.get(location=destination, product=product)
    assert (source.quantity, source.inventory_value_minor) == (Decimal("7"), 70_000)
    assert (target.quantity, target.inventory_value_minor) == (Decimal("3"), 30_000)
    assert target.average_cost_minor == 10_000

    reverse_transfer(transfer, user, reason="Wrong branch", idempotency_key="transfer-reverse")
    source.refresh_from_db()
    target.refresh_from_db()
    assert (source.quantity, source.inventory_value_minor) == (Decimal("10"), 100_000)
    assert (target.quantity, target.inventory_value_minor) == (Decimal("0"), 0)


def test_audit_failure_rolls_back_costing_and_stock(shop):
    _reset_stock(shop)
    with patch("apps.operations.services._audit", side_effect=RuntimeError("audit unavailable")):
        with pytest.raises(RuntimeError):
            _sale(
                shop,
                key="rollback-costing",
                quantity="1",
                negative_stock_acknowledged=True,
                negative_stock_reason="Atomicity test",
            )
    assert Sale.objects.count() == SaleLine.objects.count() == 0
    assert InventoryCostLayer.objects.count() == 0
    balance = _balance(shop)
    assert balance.quantity == Decimal("0")
    assert balance.inventory_value_minor == 0


def test_legacy_documents_without_layers_do_not_fabricate_costs(shop):
    user, business, location, product = shop
    customer, supplier = _parties(shop)
    sale = Sale.objects.create(
        business=business,
        location=location,
        customer=customer,
        number="LEGACY-SALE",
        financial_year="2026-27",
        sequence_number=1,
        document_date=TODAY,
        posted_at="2026-11-24T12:00:00Z",
        created_by=user,
        idempotency_key="legacy-sale",
        grand_total_minor=20_000,
    )
    SaleLine.objects.create(
        sale=sale,
        product=product,
        pack=product.packs.get(),
        description=product.name,
        quantity=Decimal("1"),
        conversion_factor=Decimal("1"),
        base_quantity=Decimal("1"),
        unit_price_minor=20_000,
        taxable_value_minor=20_000,
        line_total_minor=20_000,
    )
    purchase = Purchase.objects.create(
        business=business,
        location=location,
        supplier=supplier,
        number="LEGACY-PURCHASE",
        financial_year="2026-27",
        sequence_number=1,
        document_date=TODAY,
        posted_at="2026-11-24T12:00:00Z",
        created_by=user,
        idempotency_key="legacy-purchase",
        grand_total_minor=10_000,
    )
    reverse_sale(sale, user, reason="Legacy correction", idempotency_key="legacy-sale-reverse")
    reverse_purchase(purchase, user, reason="Legacy correction", idempotency_key="legacy-p-rev")
    sale.refresh_from_db()
    purchase.refresh_from_db()
    assert sale.status == purchase.status == DocumentStatus.REVERSED
    response = _client(shop).get("/api/v1/reports/valuation/", {"business_id": str(business.pk)})
    assert response.json()["sales"]["gross_profit_minor"] == 0
