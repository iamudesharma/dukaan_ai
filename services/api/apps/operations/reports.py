"""Report builders shared by the JSON report views and the CSV export view.

Money stays in integer paise; quantities are decimals. Every builder receives
an already-authorized business and location scope, so it does no access checks
itself. Cost basis for valuation/gross profit is the latest posted purchase
cost per product (documented v1 approximation)."""

from __future__ import annotations

import csv
import io
from datetime import date
from decimal import ROUND_HALF_UP, Decimal

from django.db.models import Count, F, Q, Sum
from django.http import HttpResponse
from django.utils.dateparse import parse_date
from rest_framework.exceptions import ValidationError

from apps.catalog.models import Party, Product, ProductPack

from .models import (
    DocumentStatus,
    Expense,
    PartyLedgerEntry,
    Payment,
    Purchase,
    PurchaseLine,
    Sale,
    SaleLine,
    StockBalance,
    StockMovement,
)

POSTED = DocumentStatus.POSTED


def parse_range(request) -> tuple[date | None, date | None]:
    from_value = request.query_params.get("from")
    to_value = request.query_params.get("to")
    start = parse_date(from_value) if from_value else None
    end = parse_date(to_value) if to_value else None
    if from_value and start is None:
        raise ValidationError("from must be an ISO date (YYYY-MM-DD)")
    if to_value and end is None:
        raise ValidationError("to must be an ISO date (YYYY-MM-DD)")
    if start and end and start > end:
        raise ValidationError("from cannot be after to")
    return start, end


def _in_range(queryset, field: str, start, end):
    if start:
        queryset = queryset.filter(**{f"{field}__gte": start})
    if end:
        queryset = queryset.filter(**{f"{field}__lte": end})
    return queryset


def _number(value) -> int:
    return int(value) if value is not None else 0


def latest_purchase_costs(business_id) -> dict:
    """Latest posted cost per base unit for each purchased product."""
    latest: dict = {}
    rows = (
        PurchaseLine.objects.filter(
            purchase__business_id=business_id,
            purchase__status=POSTED,
        )
        .select_related("purchase")
        .order_by("purchase__posted_at")
        .values("product_id", "unit_cost_minor", "conversion_factor")
    )
    for row in rows:
        factor = row["conversion_factor"]
        if factor:
            latest[row["product_id"]] = Decimal(row["unit_cost_minor"]) / factor
    return latest


def _party_names(business_id) -> dict:
    return dict(Party.objects.filter(business_id=business_id).values_list("id", "name"))


def _document_annotations() -> dict:
    return {
        "count": Count("id"),
        "subtotal": Sum("subtotal_minor"),
        "discount": Sum("discount_total_minor"),
        "taxable": Sum("taxable_total_minor"),
        "tax": Sum("tax_total_minor"),
        "grand": Sum("grand_total_minor"),
        "paid": Sum("paid_total_minor"),
        "due": Sum("due_total_minor"),
    }


def _document_totals(queryset) -> dict:
    return _document_row(queryset.aggregate(**_document_annotations()))


def _document_row(row: dict) -> dict:
    return {
        "count": _number(row.get("count")),
        "subtotal_minor": _number(row.get("subtotal")),
        "discount_minor": _number(row.get("discount")),
        "taxable_minor": _number(row.get("taxable")),
        "tax_minor": _number(row.get("tax")),
        "grand_total_minor": _number(row.get("grand")),
        "paid_minor": _number(row.get("paid")),
        "due_minor": _number(row.get("due")),
    }


def day_book(*, business_id, location_ids, start, end, **_) -> dict:
    sales = _in_range(
        Sale.objects.filter(business_id=business_id, location_id__in=location_ids, status=POSTED),
        "document_date",
        start,
        end,
    )
    purchases = _in_range(
        Purchase.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=POSTED
        ),
        "document_date",
        start,
        end,
    )
    payments = _in_range(
        Payment.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=POSTED
        ),
        "payment_date",
        start,
        end,
    )
    expenses = _in_range(
        Expense.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=POSTED
        ),
        "document_date",
        start,
        end,
    )
    names = _party_names(business_id)
    entries: list[dict] = []
    for row in sales.values(
        "document_date", "number", "grand_total_minor", "customer_id", "buyer_name"
    ):
        entries.append(
            {
                "date": row["document_date"].isoformat(),
                "kind": "SALE",
                "number": row["number"],
                "party_name": names.get(row["customer_id"]) or row["buyer_name"] or "Cash customer",
                "direction": "IN",
                "amount_minor": _number(row["grand_total_minor"]),
                "status": "POSTED",
            }
        )
    for row in purchases.values(
        "document_date", "number", "grand_total_minor", "supplier_id", "seller_name"
    ):
        entries.append(
            {
                "date": row["document_date"].isoformat(),
                "kind": "PURCHASE",
                "number": row["number"],
                "party_name": names.get(row["supplier_id"]) or row["seller_name"] or "Supplier",
                "direction": "OUT",
                "amount_minor": _number(row["grand_total_minor"]),
                "status": "POSTED",
            }
        )
    for row in payments.values(
        "payment_date", "reference", "amount_minor", "direction", "party_id"
    ):
        is_receipt = row["direction"] == Payment.Direction.RECEIPT
        entries.append(
            {
                "date": row["payment_date"].isoformat(),
                "kind": "PAYMENT_IN" if is_receipt else "PAYMENT_OUT",
                "number": row["reference"] or "PAYMENT",
                "party_name": names.get(row["party_id"]) or "Cash",
                "direction": "IN" if is_receipt else "OUT",
                "amount_minor": _number(row["amount_minor"]),
                "status": "POSTED",
            }
        )
    for row in expenses.values("document_date", "number", "total_minor", "payee"):
        entries.append(
            {
                "date": row["document_date"].isoformat(),
                "kind": "EXPENSE",
                "number": row["number"],
                "party_name": row["payee"] or "Expense",
                "direction": "OUT",
                "amount_minor": _number(row["total_minor"]),
                "status": "POSTED",
            }
        )
    entries.sort(key=lambda item: (item["date"], item["kind"], item["number"]))
    sales_total = _number(sales.aggregate(v=Sum("grand_total_minor"))["v"])
    purchases_total = _number(purchases.aggregate(v=Sum("grand_total_minor"))["v"])
    receipts_total = _number(
        payments.filter(direction=Payment.Direction.RECEIPT).aggregate(v=Sum("amount_minor"))["v"]
    )
    supplier_payments = _number(
        payments.filter(direction=Payment.Direction.PAYMENT).aggregate(v=Sum("amount_minor"))["v"]
    )
    expenses_total = _number(expenses.aggregate(v=Sum("total_minor"))["v"])
    return {
        "from": start.isoformat() if start else None,
        "to": end.isoformat() if end else None,
        "summary": {
            "sales_minor": sales_total,
            "purchases_minor": purchases_total,
            "receipts_minor": receipts_total,
            "payments_minor": supplier_payments,
            "expenses_minor": expenses_total,
            "net_cash_minor": receipts_total - supplier_payments - expenses_total,
        },
        "entries": entries,
    }


def _line_tax_expression():
    return Sum(F("cgst_amount_minor") + F("sgst_amount_minor") + F("igst_amount_minor"))


def sales_summary(*, business_id, location_ids, start, end, group_by="day", **_) -> dict:
    queryset = _in_range(
        Sale.objects.filter(business_id=business_id, location_id__in=location_ids, status=POSTED),
        "document_date",
        start,
        end,
    )
    return _document_summary(
        queryset=queryset,
        line_queryset=SaleLine.objects.filter(sale__in=queryset),
        party_field="customer_id",
        party_fallback="buyer_name",
        business_id=business_id,
        start=start,
        end=end,
        group_by=group_by,
    )


def purchase_summary(*, business_id, location_ids, start, end, group_by="day", **_) -> dict:
    queryset = _in_range(
        Purchase.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=POSTED
        ),
        "document_date",
        start,
        end,
    )
    return _document_summary(
        queryset=queryset,
        line_queryset=PurchaseLine.objects.filter(purchase__in=queryset),
        party_field="supplier_id",
        party_fallback="seller_name",
        business_id=business_id,
        start=start,
        end=end,
        group_by=group_by,
    )


def _document_summary(
    *,
    queryset,
    line_queryset,
    party_field: str,
    party_fallback: str,
    business_id,
    start,
    end,
    group_by: str,
) -> dict:
    if group_by not in {"day", "party", "product"}:
        raise ValidationError("group_by must be one of day, party, product")
    rows: list[dict] = []
    if group_by == "day":
        grouped = (
            queryset.values("document_date")
            .annotate(**_document_annotations())
            .order_by("document_date")
        )
        for row in grouped:
            rows.append(
                {
                    "key": str(row["document_date"]),
                    "label": str(row["document_date"]),
                    **_document_row(row),
                }
            )
    elif group_by == "party":
        names = _party_names(business_id)
        grouped = (
            queryset.values(party_field, party_fallback)
            .annotate(**_document_annotations())
            .order_by()
        )
        for row in grouped:
            label = names.get(row[party_field]) or row[party_fallback] or "Cash customer"
            rows.append(
                {
                    "key": str(row[party_field] or "cash"),
                    "label": label,
                    **_document_row(row),
                }
            )
        rows.sort(key=lambda item: item["label"].lower())
    else:
        names = dict(Product.objects.filter(business_id=business_id).values_list("id", "name"))
        grouped = (
            line_queryset.values("product_id")
            .annotate(
                count=Count("id"),
                quantity=Sum("base_quantity"),
                taxable=Sum("taxable_value_minor"),
                tax=_line_tax_expression(),
                grand=Sum("line_total_minor"),
            )
            .order_by("product_id")
        )
        for row in grouped:
            rows.append(
                {
                    "key": str(row["product_id"]),
                    "label": names.get(row["product_id"], "Product"),
                    "count": _number(row["count"]),
                    "quantity": str(row["quantity"] or 0),
                    "subtotal_minor": 0,
                    "discount_minor": 0,
                    "taxable_minor": _number(row["taxable"]),
                    "tax_minor": _number(row["tax"]),
                    "grand_total_minor": _number(row["grand"]),
                    "paid_minor": 0,
                    "due_minor": 0,
                }
            )
    return {
        "from": start.isoformat() if start else None,
        "to": end.isoformat() if end else None,
        "group_by": group_by,
        "totals": _document_totals(queryset),
        "rows": rows,
    }


def _gst_rows(lines) -> list[dict]:
    rows = []
    for row in (
        lines.values("tax_rate_bps")
        .annotate(
            taxable=Sum("taxable_value_minor"),
            cgst=Sum("cgst_amount_minor"),
            sgst=Sum("sgst_amount_minor"),
            igst=Sum("igst_amount_minor"),
        )
        .order_by("tax_rate_bps")
    ):
        cgst = _number(row["cgst"])
        sgst = _number(row["sgst"])
        igst = _number(row["igst"])
        rows.append(
            {
                "rate_bps": row["tax_rate_bps"],
                "taxable_minor": _number(row["taxable"]),
                "cgst_minor": cgst,
                "sgst_minor": sgst,
                "igst_minor": igst,
                "tax_minor": cgst + sgst + igst,
            }
        )
    return rows


def _gst_totals(rows: list[dict]) -> dict:
    totals = {"taxable_minor": 0, "cgst_minor": 0, "sgst_minor": 0, "igst_minor": 0, "tax_minor": 0}
    for row in rows:
        for key in totals:
            totals[key] += row[key]
    return totals


def gst_summary(*, business_id, location_ids, start, end, **_) -> dict:
    sales = _in_range(
        Sale.objects.filter(business_id=business_id, location_id__in=location_ids, status=POSTED),
        "document_date",
        start,
        end,
    )
    purchases = _in_range(
        Purchase.objects.filter(
            business_id=business_id, location_id__in=location_ids, status=POSTED
        ),
        "document_date",
        start,
        end,
    )
    output = _gst_rows(SaleLine.objects.filter(sale__in=sales))
    input_rows = _gst_rows(PurchaseLine.objects.filter(purchase__in=purchases))
    b2b = sales.exclude(buyer_gstin="")
    b2c = sales.filter(buyer_gstin="")
    return {
        "from": start.isoformat() if start else None,
        "to": end.isoformat() if end else None,
        "output": {"rows": output, "totals": _gst_totals(output)},
        "input": {"rows": input_rows, "totals": _gst_totals(input_rows)},
        "b2b": {
            "count": b2b.count(),
            "taxable_minor": _number(b2b.aggregate(v=Sum("taxable_total_minor"))["v"]),
            "tax_minor": _number(b2b.aggregate(v=Sum("tax_total_minor"))["v"]),
        },
        "b2c": {
            "count": b2c.count(),
            "taxable_minor": _number(b2c.aggregate(v=Sum("taxable_total_minor"))["v"]),
            "tax_minor": _number(b2c.aggregate(v=Sum("tax_total_minor"))["v"]),
        },
    }


def party_balances(
    *, business_id, location_ids, start=None, end=None, kind=None, search=None, **_
) -> dict:
    parties = Party.objects.filter(business_id=business_id, is_active=True)
    if kind:
        parties = parties.filter(kind=kind)
    if search:
        parties = parties.filter(Q(name__icontains=search) | Q(phone_e164__icontains=search))
    ledger = PartyLedgerEntry.objects.filter(business_id=business_id, location_id__in=location_ids)
    if start:
        ledger = ledger.filter(occurred_at__date__gte=start)
    if end:
        ledger = ledger.filter(occurred_at__date__lte=end)
    sums = ledger.values("party_id", "account").annotate(total=Sum("amount_minor"))
    balances: dict = {}
    for row in sums:
        balances[(row["party_id"], row["account"])] = _number(row["total"])
    rows = []
    totals = {"receivable_minor": 0, "payable_minor": 0}
    for party in parties.order_by("name"):
        receivable = balances.get((party.id, PartyLedgerEntry.Account.RECEIVABLE), 0)
        payable = balances.get((party.id, PartyLedgerEntry.Account.PAYABLE), 0)
        rows.append(
            {
                "party_id": str(party.id),
                "name": party.name,
                "kind": party.kind,
                "phone": party.phone_e164,
                "receivable_minor": receivable,
                "payable_minor": payable,
            }
        )
        totals["receivable_minor"] += receivable
        totals["payable_minor"] += payable
    return {"totals": totals, "rows": rows}


def stock_valuation(*, business_id, location_ids, search=None, **_) -> dict:
    products = Product.objects.filter(business_id=business_id, is_active=True, track_inventory=True)
    if search:
        products = products.filter(Q(name__icontains=search) | Q(sku__icontains=search))
    product_ids = list(products.values_list("id", flat=True))
    quantities = {
        row["product_id"]: row["total"]
        for row in StockBalance.objects.filter(
            business_id=business_id, location_id__in=location_ids, product_id__in=product_ids
        )
        .values("product_id")
        .annotate(total=Sum("quantity"))
    }
    costs = latest_purchase_costs(business_id)
    retail: dict = {}
    for row in (
        ProductPack.objects.filter(product_id__in=product_ids, is_active=True)
        .order_by("conversion_factor")
        .values("product_id", "retail_price_minor", "conversion_factor")
    ):
        if row["product_id"] in retail or not row["conversion_factor"]:
            continue
        retail[row["product_id"]] = Decimal(row["retail_price_minor"]) / row["conversion_factor"]
    rows = []
    totals = {"cost_value_minor": 0, "retail_value_minor": 0, "known_cost_rows": 0}
    for product in products.order_by("name"):
        quantity = quantities.get(product.id) or Decimal("0")
        cost_per_base = costs.get(product.id)
        retail_per_base = retail.get(product.id)
        cost_value = (
            int((quantity * cost_per_base).to_integral_value(rounding=ROUND_HALF_UP))
            if cost_per_base is not None
            else None
        )
        retail_value = (
            int((quantity * retail_per_base).to_integral_value(rounding=ROUND_HALF_UP))
            if retail_per_base is not None
            else None
        )
        rows.append(
            {
                "product_id": str(product.id),
                "name": product.name,
                "unit": product.base_unit,
                "quantity": str(quantity),
                "cost_per_base_unit_minor": str(cost_per_base.quantize(Decimal("0.000001")))
                if cost_per_base is not None
                else None,
                "stock_value_cost_minor": cost_value,
                "retail_per_base_unit_minor": str(retail_per_base)
                if retail_per_base is not None
                else None,
                "stock_value_retail_minor": retail_value,
            }
        )
        if cost_value is not None:
            totals["cost_value_minor"] += cost_value
            totals["known_cost_rows"] += 1
        if retail_value is not None:
            totals["retail_value_minor"] += retail_value
    return {"totals": totals, "rows": rows}


REPORT_BUILDERS = {
    "day-book": day_book,
    "sales": sales_summary,
    "purchases": purchase_summary,
    "gst": gst_summary,
    "party-balances": party_balances,
    "stock-valuation": stock_valuation,
}

MANAGER_REPORTS = {"day-book", "purchases", "gst", "party-balances", "stock-valuation"}


def report_csv(*, name: str, data: dict) -> tuple[list[str], list[list]]:
    if name == "day-book":
        headers = ["date", "kind", "number", "party", "direction", "amount_minor", "status"]
        rows = [
            [
                entry["date"],
                entry["kind"],
                entry["number"],
                entry["party_name"],
                entry["direction"],
                entry["amount_minor"],
                entry["status"],
            ]
            for entry in data["entries"]
        ]
    elif name in {"sales", "purchases"}:
        headers = [
            "key",
            "label",
            "count",
            "taxable_minor",
            "tax_minor",
            "grand_total_minor",
            "paid_minor",
            "due_minor",
        ]
        rows = [
            [
                row["key"],
                row["label"],
                row["count"],
                row["taxable_minor"],
                row["tax_minor"],
                row["grand_total_minor"],
                row["paid_minor"],
                row["due_minor"],
            ]
            for row in data["rows"]
        ]
    elif name == "gst":
        headers = ["side", "rate_bps", "taxable_minor", "cgst_minor", "sgst_minor", "igst_minor"]

        def gst_row(side, row):
            return [
                side,
                row["rate_bps"],
                row["taxable_minor"],
                row["cgst_minor"],
                row["sgst_minor"],
                row["igst_minor"],
            ]

        rows = [gst_row("output", row) for row in data["output"]["rows"]] + [
            gst_row("input", row) for row in data["input"]["rows"]
        ]
    elif name == "party-balances":
        headers = ["party_id", "name", "kind", "phone", "receivable_minor", "payable_minor"]
        rows = [
            [
                row["party_id"],
                row["name"],
                row["kind"],
                row["phone"],
                row["receivable_minor"],
                row["payable_minor"],
            ]
            for row in data["rows"]
        ]
    elif name == "stock-valuation":
        headers = [
            "product_id",
            "name",
            "unit",
            "quantity",
            "cost_per_base_unit_minor",
            "stock_value_cost_minor",
            "retail_per_base_unit_minor",
            "stock_value_retail_minor",
        ]
        rows = [
            [
                row["product_id"],
                row["name"],
                row["unit"],
                row["quantity"],
                row["cost_per_base_unit_minor"],
                row["stock_value_cost_minor"],
                row["retail_per_base_unit_minor"],
                row["stock_value_retail_minor"],
            ]
            for row in data["rows"]
        ]
    else:
        raise ValidationError("Unknown report")
    return headers, rows


def csv_response(filename: str, headers: list[str], rows: list[list]) -> HttpResponse:
    buffer = io.StringIO()
    writer = csv.writer(buffer)
    writer.writerow(headers)
    writer.writerows(rows)
    response = HttpResponse(buffer.getvalue(), content_type="text/csv; charset=utf-8")
    response["Content-Disposition"] = f'attachment; filename="{filename}"'
    return response


def build_report(name: str, *, request, business_id, location_ids, **kwargs) -> dict:
    builder = REPORT_BUILDERS.get(name)
    if builder is None:
        raise ValidationError("Unknown report")
    start, end = parse_range(request)
    kwargs.setdefault("group_by", request.query_params.get("group_by", "day"))
    return builder(
        business_id=business_id,
        location_ids=location_ids,
        start=start,
        end=end,
        **kwargs,
    )


def movement_queryset(*, business_id, location_ids):
    return StockMovement.objects.filter(business_id=business_id, location_id__in=location_ids)
