from __future__ import annotations

import hashlib
import json
import re
from datetime import timedelta
from decimal import ROUND_HALF_UP, Decimal

from django.db import transaction
from django.utils import timezone
from rest_framework.exceptions import PermissionDenied, ValidationError

from apps.catalog.models import Party, Product, ProductPack
from apps.operations.models import Expense, Purchase, Sale, StockBalance
from apps.operations.serializers import (
    ExpenseCreateSerializer,
    PurchaseCreateSerializer,
    SaleCreateSerializer,
)
from apps.operations.services import (
    DomainConflict,
    post_expense,
    post_purchase,
    post_sale,
)
from apps.tenancy.access import require_membership
from apps.tenancy.models import Business, GSTRegistration, IdempotencyRecord, Location

from .adapter import (
    COMMAND_EXPENSE,
    COMMAND_PAYMENT,
    COMMAND_PURCHASE,
    COMMAND_SALE,
    COMMAND_TRANSFER,
    COMMAND_UNKNOWN,
    Extraction,
    ItemCandidate,
    get_adapter,
)
from .models import AssistantProposal, ProposalRevision

CONFIRM_SCOPE = {
    COMMAND_SALE: "sale.post",
    COMMAND_PURCHASE: "purchase.post",
    COMMAND_EXPENSE: "expense.post",
}

CONFIRM_RESULT_MODEL = {
    "operations.sale": Sale,
    "operations.purchase": Purchase,
    "operations.expense": Expense,
}


def _fingerprint(proposal):
    # Call under the business lock shared by every stock/ledger posting service.
    # Lock referenced catalog rows too: ordinary catalog edits do not take that lock.
    payload = proposal.payload
    pack_ids = [line.get("pack_id") for line in payload.get("lines", []) if line.get("pack_id")]
    packs = list(
        ProductPack.objects.select_for_update()
        .filter(
            pk__in=pack_ids,
            product__business_id=proposal.business_id,
        )
        .order_by("pk")
        .values()
    )
    product_ids = [row["product_id"] for row in packs]
    party_id = payload.get("customer_id") or payload.get("supplier_id") or payload.get("party_id")
    new_party_name = (
        payload.get("new_customer_name")
        or payload.get("new_supplier_name")
        or payload.get("new_party_name")
        or ""
    )
    parties = Party.objects.select_for_update().filter(business_id=proposal.business_id)
    if party_id:
        parties = parties.filter(pk=party_id)
    elif new_party_name:
        parties = parties.filter(name__iexact=new_party_name)
    else:
        parties = parties.none()
    location = Location.objects.select_for_update().filter(pk=proposal.location_id).values().get()
    state = {
        "payload": payload,
        "business": Business.objects.filter(pk=proposal.business_id).values().get(),
        "location": location,
        "gst": list(
            GSTRegistration.objects.select_for_update()
            .filter(
                pk=location["gst_registration_id"],
                business_id=proposal.business_id,
            )
            .values()
        ),
        "packs": packs,
        "products": list(
            Product.objects.select_for_update()
            .filter(
                pk__in=product_ids,
                business_id=proposal.business_id,
            )
            .order_by("pk")
            .values()
        ),
        "customers": list(parties.order_by("pk").values()),
        "stock": list(
            StockBalance.objects.select_for_update()
            .filter(
                business_id=proposal.business_id,
                location_id=proposal.location_id,
                product_id__in=product_ids,
            )
            .order_by("product_id")
            .values("product_id", "quantity")
        ),
    }
    return hashlib.sha256(json.dumps(state, sort_keys=True, default=str).encode()).hexdigest()


def _record_revision(proposal):
    proposal.data_fingerprint = _fingerprint(proposal)
    proposal.save()
    ProposalRevision.objects.create(
        proposal=proposal,
        version=proposal.version,
        data_fingerprint=proposal.data_fingerprint,
        snapshot={
            field: getattr(proposal, field)
            for field in (
                "content",
                "input_type",
                "locale",
                "command_type",
                "payload",
                "preview",
                "warnings",
                "blocking_questions",
                "status",
            )
        },
    )


@transaction.atomic
def revise(*, proposal, actor, version, content=None):
    Business.objects.select_for_update().get(pk=proposal.business_id)
    proposal = AssistantProposal.objects.select_for_update().get(pk=proposal.pk)
    require_membership(actor, proposal.business_id, location_id=proposal.location_id)
    if proposal.actor_id != actor.pk:
        raise PermissionDenied("Only the proposal author can revise it")
    if proposal.version != version:
        raise DomainConflict("Review the latest version", "stale_proposal_version")
    if proposal.status not in {AssistantProposal.Status.DRAFT, AssistantProposal.Status.READY}:
        raise DomainConflict("Only an open proposal can be revised", "proposal_not_open")
    proposal.content = content if content is not None else proposal.content
    command_type, payload, preview, warnings, blockers = _build_from_content(
        proposal.content,
        proposal.locale,
        proposal.business,
        proposal.location,
    )
    proposal.payload = payload
    proposal.preview = preview
    proposal.warnings = warnings
    proposal.blocking_questions = blockers
    proposal.command_type = command_type
    proposal.status = AssistantProposal.Status.DRAFT if blockers else AssistantProposal.Status.READY
    proposal.version += 1
    proposal.expires_at = timezone.now() + timedelta(hours=24)
    _record_revision(proposal)
    return proposal


def _number(value: str) -> Decimal:
    return Decimal(value.replace(",", ""))


def _rupees_to_minor(value: str) -> int:
    return int((_number(value) * 100).to_integral_value(rounding=ROUND_HALF_UP))


def _round_half_up(value: Decimal) -> int:
    return int(value.to_integral_value(rounding=ROUND_HALF_UP))


def _div_round_half_up(numerator: int, denominator: int) -> int:
    return (2 * numerator + denominator) // (2 * denominator)


def _mul_round_half_up(quantity_value: Decimal, minor: int) -> int:
    return int((quantity_value * minor).to_integral_value(rounding=ROUND_HALF_UP))


def minor_to_rupees(minor: int) -> str:
    return f"{minor // 100}.{minor % 100:02d}"


def _parse_sale(content: str, business: Business, location: Location):
    text = " ".join(content.strip().split())
    lowered = text.casefold()
    blockers = []
    warnings = []
    if " bought " in lowered:
        customer_name, remainder = re.split(r"\s+bought\s+", text, maxsplit=1, flags=re.IGNORECASE)
    elif re.search(r"\s+ne\s+", lowered):
        customer_name, remainder = re.split(r"\s+ne\s+", text, maxsplit=1, flags=re.IGNORECASE)
    else:
        return {}, "", warnings, ["Please say who bought the items and include 'bought' or 'ne'."]
    customer_name = customer_name.strip(" ,.")
    quantity_match = re.match(
        r"(?P<quantity>\d+(?:\.\d+)?)\s+(?P<product>.+?)\s+(?:for|ke\s+liye|mein|me)\s+",
        remainder,
        flags=re.IGNORECASE,
    )
    text = re.sub(
        r"([0-9][0-9,]*(?:\.\d+)?)\s*rupees?\b",
        r"Rs \1",
        text,
        flags=re.IGNORECASE,
    )
    amounts = re.findall(
        r"(?:₹|Rs\.?|INR|rupees?)\s*([0-9][0-9,]*(?:\.\d+)?)",
        text,
        flags=re.IGNORECASE,
    )
    if not quantity_match:
        blockers.append("Please specify a quantity and product, for example '3 shirts for ₹2,400'.")
    if len(amounts) < 2:
        blockers.append("Please include the total and paid amount using ₹ or Rs.")
    if blockers:
        return {}, "", warnings, blockers

    count = _number(quantity_match.group("quantity"))
    product_name = quantity_match.group("product").strip(" ,.")
    product_terms = {product_name, product_name.rstrip("s"), f"{product_name}s"}
    products = Product.objects.select_for_update().filter(business=business, is_active=True)
    matched_products = []
    for term in product_terms:
        matched_products.extend(products.filter(name__iexact=term).prefetch_related("packs"))
    unique_products = {product.id: product for product in matched_products}
    if len(unique_products) != 1:
        blockers.append(
            f"Select the exact product for '{product_name}'."
            if unique_products
            else f"Create or select the product '{product_name}' before confirming."
        )
        return {}, "", warnings, blockers
    product = next(iter(unique_products.values()))
    pack = (
        product.packs.select_for_update()
        .filter(is_active=True, conversion_factor=Decimal("1"))
        .first()
        or product.packs.select_for_update().filter(is_active=True).first()
    )
    if not pack:
        return (
            {},
            "",
            warnings,
            [f"Product '{product.name}' needs an active pack before it can be sold."],
        )

    customers = list(
        Party.objects.select_for_update().filter(
            business=business, is_active=True, name__iexact=customer_name
        )
    )
    customer_id = None
    new_customer_name = ""
    if len(customers) > 1:
        blockers.append(
            f"More than one customer is named '{customer_name}'; select the correct customer."
        )
    elif customers:
        if not customers[0].can_buy():
            blockers.append(f"'{customer_name}' is not configured as a customer.")
        else:
            customer_id = str(customers[0].id)
    else:
        new_customer_name = customer_name
        warnings.append(f"A new customer named '{customer_name}' will be created.")

    total_minor = _rupees_to_minor(amounts[0])
    paid_minor = _rupees_to_minor(amounts[1])
    stated_due_minor = (
        _rupees_to_minor(amounts[2]) if len(amounts) >= 3 else total_minor - paid_minor
    )
    calculated_due_minor = total_minor - paid_minor
    if count <= 0 or total_minor <= 0 or paid_minor < 0 or paid_minor > total_minor:
        blockers.append("Quantity and total must be positive, and paid cannot exceed total.")
    if stated_due_minor != calculated_due_minor:
        blockers.append(
            f"The stated pending amount is ₹{minor_to_rupees(stated_due_minor)}, "
            f"but total minus paid is ₹{minor_to_rupees(calculated_due_minor)}. "
            "Please correct it."
        )
    unit_price_minor = _round_half_up(Decimal(total_minor) / count) if count > 0 else 0
    if count > 0 and total_minor and _mul_round_half_up(count, unit_price_minor) != total_minor:
        blockers.append(
            "This total cannot be represented by a whole-paise unit price. "
            "Correct the quantity or total before confirming."
        )
    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "customer_id": customer_id,
        "new_customer_name": new_customer_name,
        "invoice_date": str(timezone.localdate()),
        "price_mode": Sale.PriceMode.RETAIL,
        "tax_inclusive": business.gst_enabled,
        "discount_total_minor": 0,
        "lines": [
            {
                "pack_id": str(pack.id),
                "quantity": str(count),
                "unit_price_minor": unit_price_minor,
                "discount_minor": 0,
            }
        ],
        "paid_amount_minor": paid_minor,
        "payment_method": "CASH",
        "negative_stock_acknowledged": False,
        "negative_stock_reason": "",
    }
    preview = (
        f"Sale to {customer_name}: {count.normalize()} {product.name} for "
        f"₹{minor_to_rupees(total_minor)}; ₹{minor_to_rupees(paid_minor)} paid and "
        f"₹{minor_to_rupees(calculated_due_minor)} pending at {location.name}."
    )
    return payload, preview, warnings, blockers


def _resolve_party(business: Business, name: str, expected: str):
    """Resolve an extracted party name to (party_id, new_name, warnings, blockers)."""
    warnings: list[str] = []
    parties = list(
        Party.objects.select_for_update().filter(
            business=business, is_active=True, name__iexact=name
        )
    )
    if len(parties) > 1:
        return (
            None,
            "",
            warnings,
            [f"More than one party is named '{name}'; select the correct one."],
        )
    if parties:
        party = parties[0]
        if expected == "customer" and not party.can_buy():
            return None, "", warnings, [f"'{name}' is not configured as a customer."]
        if expected == "supplier" and not party.can_supply():
            return None, "", warnings, [f"'{name}' is not configured as a supplier."]
        return str(party.id), "", warnings, []
    role = (
        "customer" if expected == "customer" else "supplier" if expected == "supplier" else "party"
    )
    warnings.append(f"A new {role} named '{name}' will be created.")
    return None, name, warnings, []


def _resolve_pack(business: Business, product_name: str):
    """Resolve a product name to (product, pack, blocker)."""
    terms = {product_name, product_name.rstrip("s"), f"{product_name}s"}
    matched: dict = {}
    for term in terms:
        for product in (
            Product.objects.select_for_update()
            .filter(business=business, is_active=True, name__iexact=term)
            .prefetch_related("packs")
        ):
            matched[product.id] = product
    if len(matched) != 1:
        if matched:
            return None, None, f"Select the exact product for '{product_name}'."
        return None, None, f"Create or select the product '{product_name}' before confirming."
    product = next(iter(matched.values()))
    pack = (
        product.packs.select_for_update()
        .filter(is_active=True, conversion_factor=Decimal("1"))
        .first()
        or product.packs.select_for_update().filter(is_active=True).first()
    )
    if not pack:
        return None, None, f"Product '{product.name}' needs an active pack before it can be sold."
    return product, pack, ""


def _resolve_item_lines(extraction: Extraction, business: Business):
    """Resolve extraction items to postable lines. Returns (lines, display, blocker)."""
    lines = []
    display = []
    for item in extraction.items:
        name = item.product.strip()
        if item.quantity <= 0:
            return [], [], f"Quantity for '{name or 'an item'}' must be greater than zero."
        product, pack, blocker = _resolve_pack(business, name)
        if blocker:
            return [], [], blocker
        assert product is not None and pack is not None
        lines.append((product, pack, item.quantity, item.unit_price_minor))
        display.append(f"{item.quantity.normalize()} {product.name}")
    if not lines:
        return [], [], "Please include at least one item with quantity and product."
    return lines, display, ""


def _build_sale_from_extraction(extraction: Extraction, business: Business, location: Location):
    warnings = list(extraction.warnings)
    blockers = list(extraction.blocking_questions)
    if blockers or extraction.command_type != COMMAND_SALE:
        return {}, "", warnings, blockers or ["This could not be understood as a sale."]
    if not extraction.party_name:
        blockers.append("Please say who bought the items.")
        return {}, "", warnings, blockers
    customer_id, new_customer_name, party_warnings, party_blockers = _resolve_party(
        business, extraction.party_name, "customer"
    )
    warnings.extend(party_warnings)
    if party_blockers:
        return {}, "", warnings, party_blockers
    lines, display, line_blocker = _resolve_item_lines(extraction, business)
    if line_blocker:
        return {}, "", warnings, [line_blocker]
    total_minor = extraction.total_minor
    paid_minor = extraction.paid_minor
    if total_minor <= 0:
        # Single line without a stated total: price from catalog or item price.
        if len(lines) == 1:
            product, pack, count, item_price = lines[0]
            unit = item_price if item_price is not None else pack.retail_price_minor
            total_minor = _mul_round_half_up(count, unit)
        else:
            blockers.append("Please include the total amount using ₹ or Rs.")
            return {}, "", warnings, blockers
    if paid_minor < 0 or paid_minor > total_minor:
        blockers.append("Paid amount must be between zero and the total.")
        return {}, "", warnings, blockers
    payload_lines = []
    if len(lines) == 1:
        product, pack, count, item_price = lines[0]
        unit_price_minor = (
            item_price
            if item_price is not None
            else _round_half_up(Decimal(total_minor) / count)
            if count > 0
            else 0
        )
        if count > 0 and _mul_round_half_up(count, unit_price_minor) != total_minor:
            blockers.append(
                "This total cannot be represented by a whole-paise unit price. "
                "Correct the quantity or total before confirming."
            )
            return {}, "", warnings, blockers
        payload_lines.append(
            {
                "pack_id": str(pack.id),
                "quantity": str(count),
                "unit_price_minor": unit_price_minor,
                "discount_minor": 0,
            }
        )
    else:
        running = 0
        for _product, pack, count, item_price in lines:
            if item_price is None:
                blockers.append("Add a per-item price for every item in a multi-item sale.")
                return {}, "", warnings, blockers
            line_total = _mul_round_half_up(count, item_price)
            running += line_total
            payload_lines.append(
                {
                    "pack_id": str(pack.id),
                    "quantity": str(count),
                    "unit_price_minor": item_price,
                    "discount_minor": 0,
                }
            )
        if running != total_minor:
            blockers.append(
                f"Item prices add up to ₹{minor_to_rupees(running)} but the total is "
                f"₹{minor_to_rupees(total_minor)}. Please correct it."
            )
            return {}, "", warnings, blockers
    calculated_due = total_minor - paid_minor
    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "customer_id": customer_id,
        "new_customer_name": new_customer_name,
        "invoice_date": str(timezone.localdate()),
        "price_mode": Sale.PriceMode.RETAIL,
        "tax_inclusive": business.gst_enabled,
        "discount_total_minor": 0,
        "lines": payload_lines,
        "paid_amount_minor": paid_minor,
        "payment_method": "CASH",
        "negative_stock_acknowledged": False,
        "negative_stock_reason": "",
    }
    party_label = extraction.party_name
    preview = (
        f"Sale to {party_label}: {', '.join(display)} for ₹{minor_to_rupees(total_minor)}; "
        f"₹{minor_to_rupees(paid_minor)} paid and ₹{minor_to_rupees(calculated_due)} "
        f"pending at {location.name}."
    )
    return payload, preview, warnings, blockers


def _build_purchase_from_extraction(extraction: Extraction, business: Business, location: Location):
    warnings = list(extraction.warnings)
    blockers = list(extraction.blocking_questions)
    if blockers or extraction.command_type != COMMAND_PURCHASE:
        return {}, "", warnings, blockers or ["This could not be understood as a purchase."]
    if not extraction.party_name:
        blockers.append("Please say which supplier this purchase is from.")
        return {}, "", warnings, blockers
    supplier_id, new_supplier_name, party_warnings, party_blockers = _resolve_party(
        business, extraction.party_name, "supplier"
    )
    warnings.extend(party_warnings)
    if party_blockers:
        return {}, "", warnings, party_blockers
    lines, display, line_blocker = _resolve_item_lines(extraction, business)
    if line_blocker:
        return {}, "", warnings, [line_blocker]
    total_minor = extraction.total_minor
    paid_minor = extraction.paid_minor
    if total_minor <= 0:
        if len(lines) == 1:
            _product, pack, count, item_price = lines[0]
            unit = item_price if item_price is not None else pack.retail_price_minor
            total_minor = _mul_round_half_up(count, unit)
        else:
            blockers.append("Please include the bill total using ₹ or Rs.")
            return {}, "", warnings, blockers
    if paid_minor < 0 or paid_minor > total_minor:
        blockers.append("Paid amount must be between zero and the bill total.")
        return {}, "", warnings, blockers
    payload_lines = []
    if len(lines) == 1:
        _product, pack, count, item_price = lines[0]
        unit = (
            item_price
            if item_price is not None
            else _round_half_up(Decimal(total_minor) / count)
            if count > 0
            else 0
        )
        if count > 0 and _mul_round_half_up(count, unit) != total_minor:
            blockers.append("Correct the quantity or bill total before confirming.")
            return {}, "", warnings, blockers
        payload_lines.append(
            {
                "pack_id": str(pack.id),
                "quantity": str(count),
                "unit_cost_minor": unit,
                "discount_minor": 0,
            }
        )
    else:
        running = 0
        for _product, pack, count, item_price in lines:
            if item_price is None:
                blockers.append("Add a per-item cost for every item in a multi-item purchase.")
                return {}, "", warnings, blockers
            running += _mul_round_half_up(count, item_price)
            payload_lines.append(
                {
                    "pack_id": str(pack.id),
                    "quantity": str(count),
                    "unit_cost_minor": item_price,
                    "discount_minor": 0,
                }
            )
        if running != total_minor:
            blockers.append(
                f"Item costs add up to ₹{minor_to_rupees(running)} but the bill total is "
                f"₹{minor_to_rupees(total_minor)}. Please correct it."
            )
            return {}, "", warnings, blockers
    due = total_minor - paid_minor
    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "supplier_id": supplier_id,
        "new_supplier_name": new_supplier_name,
        "purchase_date": str(timezone.localdate()),
        "supplier_bill_number": "",
        "tax_inclusive": business.gst_enabled,
        "discount_total_minor": 0,
        "lines": payload_lines,
        "paid_amount_minor": paid_minor,
        "payment_method": "CASH",
        "payment_reference": "",
    }
    preview = (
        f"Purchase from {extraction.party_name}: {', '.join(display)} for "
        f"₹{minor_to_rupees(total_minor)}; ₹{minor_to_rupees(paid_minor)} paid and "
        f"₹{minor_to_rupees(due)} pending at {location.name}."
    )
    return payload, preview, warnings, blockers


def _build_expense_from_extraction(extraction: Extraction, business: Business, location: Location):
    warnings = list(extraction.warnings)
    blockers = list(extraction.blocking_questions)
    if blockers or extraction.command_type != COMMAND_EXPENSE:
        return {}, "", warnings, blockers or ["This could not be understood as an expense."]
    if not extraction.expense_category:
        blockers.append("Please say what this expense was for (for example 'electricity').")
        return {}, "", warnings, blockers
    amount = extraction.amount_minor or extraction.total_minor
    if amount <= 0:
        blockers.append("Please include the expense amount using ₹ or Rs.")
        return {}, "", warnings, blockers
    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "expense_date": str(timezone.localdate()),
        "category": extraction.expense_category,
        "payee": extraction.party_name or "",
        "note": "",
        "amount_minor": amount,
        "tax_amount_minor": 0,
        "payment_method": "CASH",
    }
    preview = (
        f"Expense '{extraction.expense_category}' of ₹{minor_to_rupees(amount)} at {location.name}."
    )
    return payload, preview, warnings, blockers


def _interpret_with_ai(content: str, locale: str, business: Business, location: Location):
    """Run the configured adapter and resolve to a postable proposal.

    Returns (command_type, payload, preview, warnings, blockers). Returns None
    when no adapter is configured so callers fall back to deterministic parsing.
    Transport/model failures are surfaced as UNSUPPORTED proposals — never
    silently replaced by the regex path.
    """
    adapter = get_adapter()
    if adapter is None:
        return None
    extraction = adapter.interpret(content, locale)
    if extraction is None:
        return None
    builders = {
        COMMAND_SALE: _build_sale_from_extraction,
        COMMAND_PURCHASE: _build_purchase_from_extraction,
        COMMAND_EXPENSE: _build_expense_from_extraction,
    }
    if extraction.command_type in builders:
        builder = builders[extraction.command_type]
        payload, preview, warnings, blockers = builder(extraction, business, location)
        if blockers or not payload:
            return "UNSUPPORTED", {}, preview, warnings, blockers
        return extraction.command_type, payload, preview, warnings, blockers
    if extraction.command_type == COMMAND_PAYMENT:
        preview_bits = []
        if extraction.party_name:
            preview_bits.append(f"Party: {extraction.party_name}")
        amount = extraction.amount_minor or extraction.paid_minor or extraction.total_minor
        if amount:
            preview_bits.append(f"Amount: ₹{minor_to_rupees(amount)}")
        preview = "; ".join(preview_bits)
        blockers = list(extraction.blocking_questions) or [
            "Open the sale or purchase and record this payment there — "
            "AI payment confirmation lands in P3."
        ]
        return "UNSUPPORTED", {}, preview, list(extraction.warnings), blockers
    if extraction.command_type == COMMAND_TRANSFER:
        blockers = list(extraction.blocking_questions) or [
            "Record stock transfers from the stock page with both locations — "
            "AI transfer confirmation is not enabled yet."
        ]
        return "UNSUPPORTED", {}, "", list(extraction.warnings), blockers
    blockers = list(extraction.blocking_questions) or [
        "This could not be understood as a business command."
    ]
    return "UNSUPPORTED", {}, "", list(extraction.warnings), blockers


_HI_DEVANAGARI = re.compile(r"[\u0900-\u097F]")
_HI_CURRENCY = r"(?:₹|Rs\.?|INR|रुपये|रूपये|रू\.?)"
_HI_NUMBER = r"[0-9][0-9,]*(?:\.[0-9]+)?"
_HI_MONEY = re.compile(
    rf"(?:(?:{_HI_CURRENCY})\s*(?P<prefix>{_HI_NUMBER})|"
    rf"(?P<suffix>{_HI_NUMBER})\s*(?:{_HI_CURRENCY}))"
)
_HI_PAID = re.compile(
    rf"(?:(?:{_HI_CURRENCY})\s*)?(?P<amount>{_HI_NUMBER})"
    rf"(?:\s*(?:{_HI_CURRENCY}))?\s*"
    r"(?:दिए|दी|भुगतान\s+किया|भुगतान\s+की|चुकाई|प्राप्त\s+हुए|प्राप्त\s+हुई)"
)
_HI_DUE = re.compile(
    rf"(?:(?:{_HI_CURRENCY})\s*)?(?P<amount>{_HI_NUMBER})"
    rf"(?:\s*(?:{_HI_CURRENCY}))?\s*(?:बाकी|बकाया|शेष)"
)
_HI_LABELED_TOTAL = re.compile(
    rf"(?:कुल|टोटल|बिल\s+कुल)\s*(?:(?:{_HI_CURRENCY})\s*)?(?P<amount>{_HI_NUMBER})"
)


def _hi_money_value(match: re.Match) -> int:
    return _rupees_to_minor(match.group("prefix") or match.group("suffix"))


def _hi_plain_amount(match: re.Match | None) -> int:
    return _rupees_to_minor(match.group("amount")) if match else 0


def _hi_item_candidate(text: str, *, purchase: bool) -> tuple[str | None, ItemCandidate | None]:
    if purchase:
        pattern = re.compile(
            rf"(?P<party>.+?)\s+से\s+(?:हमने\s+)?(?P<quantity>{_HI_NUMBER})\s+"
            rf"(?P<product>.+?)(?=\s+(?:\d|{_HI_CURRENCY}|खरीदीं|खरीदा|खरीदी|मंगवाया|मंगाई))"
        )
    else:
        pattern = re.compile(
            rf"^(?P<party>.+?)\s+ने\s+(?P<quantity>{_HI_NUMBER})\s+"
            rf"(?P<product>.+?)(?=\s+(?:\d|{_HI_CURRENCY}|खरीदे|खरीदा|ले\s+लिया|ले\s+लिए))"
        )
    match = pattern.search(text)
    if match is None:
        return None, None
    party = match.group("party").strip(" ,।")
    party = re.sub(r"^हमने\s+", "", party).strip()
    product = re.sub(r"\s+(?:को|के\s+लिए)$", "", match.group("product")).strip(" ,।")
    if not party or not product:
        return None, None
    return party, ItemCandidate(product=product, quantity=_number(match.group("quantity")))


def _parse_hi_extraction(content: str) -> Extraction:
    """Parse a conservative subset of Devanagari business commands.

    This is deliberately not a general-language model. It recognizes one exact
    catalog item plus explicit money amounts, and leaves ambiguous input as a
    review blocker. The existing deterministic builders remain responsible for
    catalog resolution, paise math, tax, and posting validation.
    """
    text = " ".join(content.strip().split())
    warnings = ["यह हिंदी नियम-आधारित व्याख्या है; पुष्टि से पहले राशि और वस्तु जाँचें।"]
    unknown = Extraction(
        command_type=COMMAND_UNKNOWN,
        warnings=warnings,
        blocking_questions=["इसे बिक्री, खरीद या खर्च के रूप में सुरक्षित रूप से नहीं समझा जा सका।"],
        model="deterministic-hi-v1",
    )

    expense = re.search(r"(?P<category>.+?)\s+(?:का|की)\s+(?:बिल|खर्च)\b", text)
    if expense:
        amount_matches = list(_HI_MONEY.finditer(text))
        if not amount_matches:
            return Extraction(
                command_type=COMMAND_EXPENSE,
                expense_category=expense.group("category").strip(" ,।"),
                warnings=warnings,
                blocking_questions=["खर्च की राशि ₹ या रुपये के साथ बताएँ।"],
                model="deterministic-hi-v1",
            )
        return Extraction(
            command_type=COMMAND_EXPENSE,
            expense_category=expense.group("category").strip(" ,।"),
            amount_minor=_hi_money_value(amount_matches[0]),
            warnings=warnings,
            model="deterministic-hi-v1",
        )

    purchase = bool(
        re.search(r"\s+से\s+", text) and re.search(r"(?:खरीदीं|खरीदा|खरीदी|मंगवाया|मंगाई)", text)
    )
    sale = bool(re.search(r"\s+ने\s+", text) and re.search(r"(?:खरीदे|खरीदा|ले\s+लिया|ले\s+लिए)", text))
    if not purchase and not sale:
        return unknown

    party, item = _hi_item_candidate(text, purchase=purchase)
    if party is None or item is None:
        return Extraction(
            command_type=COMMAND_PURCHASE if purchase else COMMAND_SALE,
            warnings=warnings,
            blocking_questions=["ग्राहक या सप्लायर, एक वस्तु, उसकी मात्रा और स्पष्ट राशि बताएँ।"],
            model="deterministic-hi-v1",
        )

    paid_match = _HI_PAID.search(text)
    due_match = _HI_DUE.search(text)
    paid_minor = _hi_plain_amount(paid_match)
    stated_due_minor = _hi_plain_amount(due_match)
    labeled_total = _HI_LABELED_TOTAL.search(text)
    excluded_spans = [match.span() for match in (paid_match, due_match) if match is not None]
    total_minor = _hi_plain_amount(labeled_total)
    if not total_minor:
        for match in _HI_MONEY.finditer(text):
            if any(match.start() < end and match.end() > start for start, end in excluded_spans):
                continue
            total_minor = _hi_money_value(match)
            break

    blockers = []
    if item.quantity <= 0:
        blockers.append("मात्रा शून्य से अधिक होनी चाहिए।")
    if stated_due_minor and total_minor and stated_due_minor != total_minor - paid_minor:
        blockers.append("बताई गई बाकी राशि कुल और भुगतान के अंतर से मेल नहीं खाती।")
    return Extraction(
        command_type=COMMAND_PURCHASE if purchase else COMMAND_SALE,
        party_name=party,
        items=[item],
        total_minor=total_minor,
        paid_minor=paid_minor,
        warnings=warnings,
        blocking_questions=blockers,
        model="deterministic-hi-v1",
    )


def _build_from_hi_content(content: str, business: Business, location: Location):
    extraction = _parse_hi_extraction(content)
    builders = {
        COMMAND_SALE: _build_sale_from_extraction,
        COMMAND_PURCHASE: _build_purchase_from_extraction,
        COMMAND_EXPENSE: _build_expense_from_extraction,
    }
    builder = builders.get(extraction.command_type)
    if builder is None:
        return (
            "UNSUPPORTED",
            {},
            "",
            extraction.warnings,
            extraction.blocking_questions,
        )
    payload, preview, warnings, blockers = builder(extraction, business, location)
    if blockers or not payload:
        return "UNSUPPORTED", {}, preview, warnings, blockers
    return extraction.command_type, payload, preview, warnings, blockers


def _build_from_content(content: str, locale: str, business: Business, location: Location):
    ai_result = _interpret_with_ai(content, locale, business, location)
    if ai_result is not None:
        return ai_result
    if locale.casefold().startswith("hi") and _HI_DEVANAGARI.search(content):
        return _build_from_hi_content(content, business, location)
    payload, preview, warnings, blockers = _parse_sale(content, business, location)
    return ("SALE" if payload else "UNSUPPORTED"), payload, preview, warnings, blockers


@transaction.atomic
def interpret(
    *, actor, business: Business, location: Location, input_type: str, content: str, locale: str
):
    require_membership(actor, business.id, location_id=location.id)
    if location.business_id != business.id:
        raise ValidationError("Location does not belong to the business")
    business = Business.objects.select_for_update().get(pk=business.pk)
    location = Location.objects.select_for_update().get(pk=location.pk)

    command_type, payload, preview, warnings, blockers = _build_from_content(
        content, locale, business, location
    )

    proposal = AssistantProposal.objects.create(
        business=business,
        location=location,
        actor=actor,
        input_type=input_type,
        locale=locale,
        content=content,
        command_type=command_type,
        payload=payload,
        preview=preview,
        warnings=warnings,
        blocking_questions=blockers,
        status=AssistantProposal.Status.DRAFT if blockers else AssistantProposal.Status.READY,
        expires_at=timezone.now() + timedelta(hours=24),
    )
    _record_revision(proposal)
    return proposal


@transaction.atomic
def confirm(*, proposal: AssistantProposal, actor, version: int, idempotency_key: str):
    Business.objects.select_for_update().get(pk=proposal.business_id)
    proposal = AssistantProposal.objects.select_for_update().get(pk=proposal.pk)
    if proposal.actor_id != actor.id:
        raise PermissionDenied("Only the proposal author can confirm it")
    require_membership(actor, proposal.business_id, location_id=proposal.location_id)
    if proposal.status == AssistantProposal.Status.CONFIRMED:
        if proposal.confirmation_idempotency_key != idempotency_key:
            raise DomainConflict(
                "This proposal was already confirmed with another key", "already_confirmed"
            )
        model = CONFIRM_RESULT_MODEL.get(proposal.confirmed_result_type)
        if model is not None:
            return model.objects.get(pk=proposal.confirmed_result_id), True
        return Sale.objects.get(pk=proposal.confirmed_result_id), True
    if proposal.expires_at <= timezone.now():
        raise DomainConflict("This proposal has expired", "proposal_expired")
    if proposal.status != AssistantProposal.Status.READY or proposal.blocking_questions:
        raise DomainConflict("Resolve all questions before confirming", "proposal_not_ready")
    if proposal.version != version:
        raise DomainConflict(
            "The proposal changed; review the latest version", "stale_proposal_version"
        )
    if proposal.command_type not in CONFIRM_SCOPE:
        raise ValidationError("Only sale, purchase, and expense proposals can be confirmed yet")

    revision = proposal.revisions.filter(version=version).first()
    if (
        not revision
        or not proposal.data_fingerprint
        or revision.data_fingerprint != proposal.data_fingerprint
        or revision.snapshot["payload"] != proposal.payload
        or _fingerprint(proposal) != proposal.data_fingerprint
    ):
        raise DomainConflict(
            "Shop details changed. Refresh this proposal and review it before recording.",
            "stale_proposal_data",
        )

    scope = CONFIRM_SCOPE[proposal.command_type]
    if IdempotencyRecord.objects.filter(
        business_id=proposal.business_id,
        actor=actor,
        scope=scope,
        key=idempotency_key,
    ).exists():
        raise DomainConflict("This key belongs to another document", "idempotency_key_reused")

    raw = dict(proposal.payload)
    if proposal.command_type == COMMAND_SALE:
        new_customer_name = raw.pop("new_customer_name", "")
        if new_customer_name and not raw.get("customer_id"):
            customer = Party.objects.create(
                business=proposal.business,
                name=new_customer_name,
                kind=Party.Kind.CUSTOMER,
            )
            raw["customer_id"] = str(customer.id)
        raw["idempotency_key"] = idempotency_key
        serializer = SaleCreateSerializer(data=raw)
        serializer.is_valid(raise_exception=True)
        instance, replayed = post_sale(serializer.validated_data, actor, source="ASSISTANT")
        result_type = "operations.sale"
    elif proposal.command_type == COMMAND_PURCHASE:
        new_supplier_name = raw.pop("new_supplier_name", "")
        if new_supplier_name and not raw.get("supplier_id"):
            supplier = Party.objects.create(
                business=proposal.business,
                name=new_supplier_name,
                kind=Party.Kind.SUPPLIER,
            )
            raw["supplier_id"] = str(supplier.id)
        raw["idempotency_key"] = idempotency_key
        serializer = PurchaseCreateSerializer(data=raw)
        serializer.is_valid(raise_exception=True)
        instance, replayed = post_purchase(serializer.validated_data, actor, source="ASSISTANT")
        result_type = "operations.purchase"
    else:
        raw["idempotency_key"] = idempotency_key
        serializer = ExpenseCreateSerializer(data=raw)
        serializer.is_valid(raise_exception=True)
        instance, replayed = post_expense(serializer.validated_data, actor, source="ASSISTANT")
        result_type = "operations.expense"
    proposal.status = AssistantProposal.Status.CONFIRMED
    proposal.confirmed_at = timezone.now()
    proposal.confirmed_result_type = result_type
    proposal.confirmed_result_id = instance.id
    proposal.confirmation_idempotency_key = idempotency_key
    proposal.save(
        update_fields=[
            "status",
            "confirmed_at",
            "confirmed_result_type",
            "confirmed_result_id",
            "confirmation_idempotency_key",
            "updated_at",
        ]
    )
    return instance, replayed
