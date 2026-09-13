from __future__ import annotations

import hashlib
import json
import re
from datetime import timedelta
from decimal import ROUND_HALF_UP, Decimal, InvalidOperation

from django.db import transaction
from django.utils import timezone
from rest_framework.exceptions import PermissionDenied, ValidationError

from apps.catalog.models import Party, Product, ProductPack
from apps.operations.models import (
    DocumentStatus,
    Expense,
    Payment,
    Purchase,
    Sale,
    StockBalance,
)
from apps.operations.serializers import (
    ExpenseCreateSerializer,
    PaymentCreateSerializer,
    PurchaseCreateSerializer,
    SaleCreateSerializer,
)
from apps.operations.services import (
    DomainConflict,
    post_expense,
    post_payment,
    post_purchase,
    post_sale,
)
from apps.tenancy.access import require_membership
from apps.tenancy.models import Business, GSTRegistration, IdempotencyRecord, Location

from .models import AssistantProposal, ProposalRevision


def _fingerprint(proposal):
    # Call under the business lock shared by every stock/ledger posting service.
    # Lock referenced catalog rows too: ordinary catalog edits do not take that lock.
    payload = proposal.payload
    packs = list(
        ProductPack.objects.select_for_update()
        .filter(
            pk__in=[line["pack_id"] for line in payload.get("lines", [])],
            product__business_id=proposal.business_id,
        )
        .order_by("pk")
        .values()
    )
    product_ids = [row["product_id"] for row in packs]
    customers = Party.objects.select_for_update().filter(business_id=proposal.business_id)
    if payload.get("customer_id"):
        customers = customers.filter(pk=payload["customer_id"])
    elif payload.get("new_customer_name"):
        customers = customers.filter(name__iexact=payload["new_customer_name"])
    else:
        customers = customers.none()
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
        "customers": list(customers.order_by("pk").values()),
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
                "preview_data",
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
    payload, preview, warnings, blockers, command_type = _build_proposal_data(
        proposal.content, proposal.business, proposal.location, proposal.locale
    )
    proposal.payload = payload
    proposal.preview = preview
    proposal.preview_data = _build_preview_data(payload, preview, blockers, proposal.location)
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


def _resolve_party(business: Business, name: str, kind: str):
    """Return (party_id, new_party_name, warnings, blockers).

    ``kind`` is "customer" or "supplier". Unknown names become
    create-on-confirm proposals, exactly like the sale flow."""
    if not name:
        return None, "", [], []
    parties = list(
        Party.objects.select_for_update().filter(
            business=business, is_active=True, name__iexact=name
        )
    )
    label = "customer" if kind == "customer" else "supplier"
    if len(parties) > 1:
        return (
            None,
            "",
            [],
            [f"More than one {label} is named '{name}'; select the correct {label}."],
        )
    if parties:
        party = parties[0]
        if kind == "customer" and not party.can_buy():
            return None, "", [], [f"'{name}' is not configured as a customer."]
        if kind == "supplier" and not party.can_supply():
            return None, "", [], [f"'{name}' is not configured as a supplier."]
        return str(party.id), "", [], []
    article = "customer" if kind == "customer" else "supplier"
    return (
        None,
        name,
        [f"A new {article} named '{name}' will be created."],
        [],
    )


def _resolve_customer(business: Business, customer_name: str):
    """Return (customer_id, new_customer_name, warnings, blockers)."""
    return _resolve_party(business, customer_name, "customer")


def _resolve_supplier(business: Business, supplier_name: str):
    """Return (supplier_id, new_supplier_name, warnings, blockers)."""
    return _resolve_party(business, supplier_name, "supplier")


def _resolve_product(business: Business, product_name: str):
    """Return (product, pack, error_message)."""
    product_terms = {product_name, product_name.rstrip("s"), f"{product_name}s"}
    products = Product.objects.select_for_update().filter(business=business, is_active=True)
    matched_products = []
    for term in product_terms:
        matched_products.extend(products.filter(name__iexact=term).prefetch_related("packs"))
    unique_products = {product.id: product for product in matched_products}
    if len(unique_products) != 1:
        message = (
            f"Select the exact product for '{product_name}'."
            if unique_products
            else f"Create or select the product '{product_name}' before confirming."
        )
        return None, None, message
    product = next(iter(unique_products.values()))
    pack = (
        product.packs.select_for_update()
        .filter(is_active=True, conversion_factor=Decimal("1"))
        .first()
        or product.packs.select_for_update().filter(is_active=True).first()
    )
    if not pack:
        return (
            None,
            None,
            f"Product '{product.name}' needs an active pack before it can be sold.",
        )
    return product, pack, ""


def _build_preview_data(payload, summary, blockers, location: Location):
    facts = []
    party_name = str(payload.get("new_customer_name") or payload.get("new_supplier_name") or "")
    party_id = payload.get("customer_id") or payload.get("supplier_id") or payload.get("party_id")
    if party_id:
        party = Party.objects.filter(pk=party_id).values("name").first()
        if party:
            party_name = party["name"]
    if party_name:
        facts.append({"label": "Party", "value": party_name, "warning": False})
    pack_ids = [line.get("pack_id") for line in payload.get("lines", []) if line.get("pack_id")]
    packs = {
        str(pack.id): pack
        for pack in ProductPack.objects.filter(pk__in=pack_ids).select_related("product")
    }
    for line in payload.get("lines", []):
        pack = packs.get(line.get("pack_id"))
        product_name = pack.product.name if pack else "Item"
        quantity = line.get("quantity", "")
        unit_price = int(line.get("unit_price_minor") or line.get("unit_cost_minor") or 0)
        value = f"{quantity} × ₹{minor_to_rupees(unit_price)}"
        facts.append({"label": product_name, "value": value, "warning": False})
    paid = int(payload.get("paid_amount_minor") or payload.get("amount_minor") or 0)
    if paid:
        label = "Paid" if payload.get("paid_amount_minor") else "Amount"
        facts.append({"label": label, "value": f"₹{minor_to_rupees(paid)}", "warning": False})
    if payload.get("category"):
        facts.append({"label": "Category", "value": str(payload["category"]), "warning": False})
    facts.append({"label": "Location", "value": location.name, "warning": False})
    return {
        "summary": summary,
        "facts": facts,
        "questions": list(blockers),
    }


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
    amounts = re.findall(r"(?:₹|Rs\.?|INR)\s*([0-9][0-9,]*(?:\.\d+)?)", text, flags=re.IGNORECASE)
    if not quantity_match:
        blockers.append("Please specify a quantity and product, for example '3 shirts for ₹2,400'.")
    if len(amounts) < 2:
        blockers.append("Please include the total and paid amount using ₹ or Rs.")
    if blockers:
        return {}, "", warnings, blockers

    count = _number(quantity_match.group("quantity"))
    product_name = quantity_match.group("product").strip(" ,.")
    product, pack, product_error = _resolve_product(business, product_name)
    if product is None:
        blockers.append(product_error)
        return {}, "", warnings, blockers

    customer_id, new_customer_name, customer_warnings, customer_blockers = _resolve_customer(
        business, customer_name
    )
    warnings.extend(customer_warnings)
    blockers.extend(customer_blockers)

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
        "price_mode": business.default_price_mode
        if business.default_price_mode in Sale.PriceMode.values
        else Sale.PriceMode.RETAIL,
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


def _normalize_ai_lines(business: Business, items, amount_key: str):
    """Resolve AI items to posting lines.

    Returns (lines, stated_total, blockers). ``amount_key`` is the per-line
    price field the target serializer expects (``unit_price_minor`` for
    sales, ``unit_cost_minor`` for purchases)."""
    lines = []
    stated_total = 0
    blockers = []
    for item in items:
        product_name = str(item.get("product") or "").strip()
        try:
            quantity = Decimal(str(item.get("quantity") or 0))
        except (InvalidOperation, ValueError):
            quantity = Decimal("0")
        unit_price = int(item.get("unit_price_minor") or 0)
        if not product_name or quantity <= 0:
            blockers.append("Every item needs a product name and a positive quantity.")
            continue
        _, pack, product_error = _resolve_product(business, product_name)
        if pack is None:
            blockers.append(product_error)
            continue
        lines.append(
            {
                "pack_id": str(pack.id),
                "quantity": str(quantity),
                amount_key: unit_price,
                "discount_minor": 0,
            }
        )
        stated_total += _mul_round_half_up(quantity, unit_price)
    if not lines:
        blockers.append("No product could be matched; add the product before confirming.")
    return lines, stated_total, blockers


def _check_stated_total(stated_total: int, expected_minor, blockers):
    if expected_minor and stated_total != int(expected_minor):
        blockers.append(
            f"The item prices add up to ₹{minor_to_rupees(stated_total)}, "
            f"but the stated total is ₹{minor_to_rupees(int(expected_minor))}. "
            "Please correct the amounts."
        )


def _normalize_ai_sale(result, business: Business, location: Location):
    warnings = list(result.warnings)
    blockers = list(result.blocking_questions)
    customer_id, new_customer_name, party_warnings, party_blockers = _resolve_customer(
        business, (result.customer_name or "").strip()
    )
    warnings.extend(party_warnings)
    blockers.extend(party_blockers)
    lines, stated_total, line_blockers = _normalize_ai_lines(
        business, result.items, "unit_price_minor"
    )
    blockers.extend(line_blockers)
    if lines:
        _check_stated_total(stated_total, result.total_minor, blockers)
    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "customer_id": customer_id,
        "new_customer_name": new_customer_name,
        "invoice_date": str(timezone.localdate()),
        "price_mode": business.default_price_mode
        if business.default_price_mode in Sale.PriceMode.values
        else Sale.PriceMode.RETAIL,
        "tax_inclusive": business.gst_enabled,
        "discount_total_minor": 0,
        "lines": lines,
        "paid_amount_minor": int(result.paid_minor or 0),
        "payment_method": "CASH",
        "negative_stock_acknowledged": False,
        "negative_stock_reason": "",
    }
    return payload, warnings, blockers


def _normalize_ai_purchase(result, business: Business, location: Location):
    warnings = list(result.warnings)
    blockers = list(result.blocking_questions)
    supplier_id, new_supplier_name, party_warnings, party_blockers = _resolve_supplier(
        business, (result.supplier_name or "").strip()
    )
    warnings.extend(party_warnings)
    blockers.extend(party_blockers)
    if not result.supplier_name:
        blockers.append("Please say which supplier this purchase is from.")
    lines, stated_total, line_blockers = _normalize_ai_lines(
        business, result.items, "unit_cost_minor"
    )
    blockers.extend(line_blockers)
    if lines:
        _check_stated_total(stated_total, result.total_minor, blockers)
    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "supplier_id": supplier_id,
        "new_supplier_name": new_supplier_name,
        "purchase_date": str(timezone.localdate()),
        "tax_inclusive": business.gst_enabled,
        "discount_total_minor": 0,
        "lines": lines,
        "paid_amount_minor": int(result.paid_minor or 0),
        "payment_method": "CASH",
    }
    return payload, warnings, blockers


def _oldest_due_document(party, business: Business, location: Location, direction: str):
    """Oldest posted document with an outstanding balance for this party.

    Payments always settle a specific bill: the suggestion is deterministic
    (oldest due first) and the fingerprint pins it, so a newer payment or
    reversal between review and confirm fails closed instead of settling the
    wrong bill."""
    if direction == Payment.Direction.RECEIPT:
        return (
            Sale.objects.filter(
                business=business,
                location=location,
                customer=party,
                status=DocumentStatus.POSTED,
                due_total_minor__gt=0,
            )
            .order_by("document_date", "created_at")
            .first()
        )
    return (
        Purchase.objects.filter(
            business=business,
            location=location,
            supplier=party,
            status=DocumentStatus.POSTED,
            due_total_minor__gt=0,
        )
        .order_by("document_date", "created_at")
        .first()
    )


def _normalize_ai_payment(result, business: Business, location: Location):
    warnings = list(result.warnings)
    blockers = list(result.blocking_questions)
    direction = (result.direction or "").strip().upper()
    if result.supplier_name and not result.customer_name:
        direction = direction or Payment.Direction.PAYMENT
    elif result.customer_name and not result.supplier_name:
        direction = direction or Payment.Direction.RECEIPT
    if direction not in {Payment.Direction.RECEIPT, Payment.Direction.PAYMENT}:
        blockers.append("Please say whether this is money received or money paid.")
        return {}, warnings, blockers
    kind = "customer" if direction == Payment.Direction.RECEIPT else "supplier"
    name = (result.customer_name or result.supplier_name or "").strip()
    party_id, new_party_name, party_warnings, party_blockers = _resolve_party(business, name, kind)
    warnings.extend(party_warnings)
    blockers.extend(party_blockers)
    if new_party_name:
        blockers.append(f"'{name}' has no outstanding bills yet; add them as a party first.")
        return {}, warnings, blockers
    amount = int(result.total_minor or result.paid_minor or 0)
    if amount <= 0:
        blockers.append("Please include the payment amount using ₹ or Rs.")
        return {}, warnings, blockers
    party = Party.objects.filter(pk=party_id).first()
    document = _oldest_due_document(party, business, location, direction) if party else None
    if document is None:
        blockers.append(f"'{name}' has no outstanding bills at this location.")
        return {}, warnings, blockers
    if amount > document.due_total_minor:
        blockers.append(
            f"The oldest pending bill ({document.number}) is "
            f"₹{minor_to_rupees(document.due_total_minor)}, but the stated amount is "
            f"₹{minor_to_rupees(amount)}. Please correct the amount."
        )
        return {}, warnings, blockers
    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "party_id": str(party.id),
        "direction": direction,
        "method": "CASH",
        "amount_minor": amount,
        "payment_date": str(timezone.localdate()),
        "note": f"Assistant payment against {document.number}",
    }
    if direction == Payment.Direction.RECEIPT:
        payload["sale_id"] = str(document.id)
    else:
        payload["purchase_id"] = str(document.id)
    return payload, warnings, blockers


def _normalize_ai_expense(result, business: Business, location: Location):
    warnings = list(result.warnings)
    blockers = list(result.blocking_questions)
    category = (result.category or "").strip()
    amount = int(result.total_minor or 0)
    if not category:
        blockers.append("Please say what this expense was for (for example Rent).")
    if amount <= 0:
        blockers.append("Please include the expense amount using ₹ or Rs.")
    if blockers:
        return {}, warnings, blockers
    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "expense_date": str(timezone.localdate()),
        "category": category,
        "payee": (result.payee or "").strip(),
        "amount_minor": amount,
        "payment_method": "CASH",
    }
    return payload, warnings, blockers


def _preview_text(command_type: str, result) -> str:
    parts = []
    name = result.customer_name or result.supplier_name
    if name:
        parts.append(f"Party: {name}")
    if result.items:
        for item in result.items:
            parts.append(f"{item.get('quantity', '?')} × {item.get('product', '?')}")
    if command_type == "EXPENSE" and result.category:
        parts.append(f"Category: {result.category}")
    if result.total_minor:
        parts.append(f"Total: ₹{result.total_minor / 100:.2f}")
    if result.paid_minor:
        parts.append(f"Paid: ₹{result.paid_minor / 100:.2f}")
    return "; ".join(parts)


def _interpret_with_ai(content: str, locale: str, business: Business, location: Location):
    from .chatgpt import interpret_with_ai

    result = interpret_with_ai(content, locale)
    if result is None or not result.is_valid:
        return None

    normalizers = {
        "SALE": _normalize_ai_sale,
        "PURCHASE": _normalize_ai_purchase,
        "PAYMENT": _normalize_ai_payment,
        "EXPENSE": _normalize_ai_expense,
    }
    normalizer = normalizers.get((result.command_type or "").upper())
    if normalizer is None:
        return None
    payload, warnings, blockers = normalizer(result, business, location)
    command_type = (result.command_type or "").upper()
    preview = _preview_text(command_type, result)
    return payload, preview, warnings, blockers, command_type


def _build_proposal_data(content: str, business: Business, location: Location, locale: str):
    """Return (payload, preview, warnings, blockers, command_type).

    The AI adapter runs first when enabled; the deterministic sale parser is
    the fallback. Both interpret and revise share this so a revised request
    is re-understood rather than forced through the sale grammar."""
    ai_result = _interpret_with_ai(content, locale, business, location)
    if ai_result:
        payload, preview, warnings, blockers, command_type = ai_result
    else:
        payload, preview, warnings, blockers = _parse_sale(content, business, location)
        command_type = "SALE" if payload else "UNSUPPORTED"
    return payload, preview, warnings, blockers, command_type


@transaction.atomic
def interpret(
    *, actor, business: Business, location: Location, input_type: str, content: str, locale: str
):
    require_membership(actor, business.id, location_id=location.id)
    if location.business_id != business.id:
        raise ValidationError("Location does not belong to the business")
    business = Business.objects.select_for_update().get(pk=business.pk)
    location = Location.objects.select_for_update().get(pk=location.pk)

    payload, preview, warnings, blockers, command_type = _build_proposal_data(
        content, business, location, locale
    )

    preview_data = _build_preview_data(payload, preview, blockers, location)
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
        preview_data=preview_data,
        warnings=warnings,
        blocking_questions=blockers,
        status=AssistantProposal.Status.DRAFT if blockers else AssistantProposal.Status.READY,
        expires_at=timezone.now() + timedelta(hours=24),
    )
    _record_revision(proposal)
    return proposal


# command_type -> (create serializer, posting service, result type, idempotency scope)
CONFIRM_HANDLERS = {
    "SALE": (SaleCreateSerializer, post_sale, "operations.sale", "sale.post"),
    "PURCHASE": (PurchaseCreateSerializer, post_purchase, "operations.purchase", "purchase.post"),
    "PAYMENT": (PaymentCreateSerializer, post_payment, "operations.payment", "payment.post"),
    "EXPENSE": (ExpenseCreateSerializer, post_expense, "operations.expense", "expense.post"),
}

CONFIRMED_MODELS = {
    "operations.sale": Sale,
    "operations.purchase": Purchase,
    "operations.payment": Payment,
    "operations.expense": Expense,
}

# Payload keys created during interpretation that the posting serializers
# must not see (party auto-creation markers and sale-only stock flags).
CONFIRM_DROPPED_KEYS = ("new_customer_name", "new_supplier_name")


@transaction.atomic
def confirm(
    *,
    proposal: AssistantProposal,
    actor,
    version: int,
    idempotency_key: str,
    negative_stock_acknowledged: bool = False,
    negative_stock_reason: str = "",
):
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
        model = CONFIRMED_MODELS.get(proposal.confirmed_result_type)
        if model is not None:
            return model.objects.get(pk=proposal.confirmed_result_id), True
    if proposal.expires_at <= timezone.now():
        raise DomainConflict("This proposal has expired", "proposal_expired")
    if proposal.status != AssistantProposal.Status.READY or proposal.blocking_questions:
        raise DomainConflict("Resolve all questions before confirming", "proposal_not_ready")
    if proposal.version != version:
        raise DomainConflict(
            "The proposal changed; review the latest version", "stale_proposal_version"
        )
    handler = CONFIRM_HANDLERS.get(proposal.command_type)
    if handler is None:
        raise ValidationError("This command type is not supported for confirmation")
    create_serializer, post_service, result_type, scope = handler

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

    if IdempotencyRecord.objects.filter(
        business_id=proposal.business_id,
        actor=actor,
        scope=scope,
        key=idempotency_key,
    ).exists():
        raise DomainConflict("This key belongs to another entry", "idempotency_key_reused")

    raw = dict(proposal.payload)
    for key in CONFIRM_DROPPED_KEYS:
        new_party_name = raw.pop(key, "")
        if new_party_name and not raw.get("customer_id") and not raw.get("supplier_id"):
            kind = (
                Party.Kind.SUPPLIER if proposal.command_type == "PURCHASE" else Party.Kind.CUSTOMER
            )
            party = Party.objects.create(
                business=proposal.business,
                name=new_party_name,
                kind=kind,
            )
            if proposal.command_type == "PURCHASE":
                raw["supplier_id"] = str(party.id)
            else:
                raw["customer_id"] = str(party.id)
    if proposal.command_type == "SALE":
        raw["negative_stock_acknowledged"] = bool(negative_stock_acknowledged)
        raw["negative_stock_reason"] = negative_stock_reason
    else:
        raw.pop("negative_stock_acknowledged", None)
        raw.pop("negative_stock_reason", None)
    raw["idempotency_key"] = idempotency_key
    serializer = create_serializer(data=raw)
    serializer.is_valid(raise_exception=True)
    instance, replayed = post_service(serializer.validated_data, actor, source="ASSISTANT")
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
