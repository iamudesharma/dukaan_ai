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
from apps.operations.models import Sale, StockBalance
from apps.operations.serializers import SaleCreateSerializer
from apps.operations.services import DomainConflict, post_sale
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
    payload, preview, warnings, blockers = _parse_sale(
        proposal.content,
        proposal.business,
        proposal.location,
    )
    proposal.payload = payload
    proposal.preview = preview
    proposal.warnings = warnings
    proposal.blocking_questions = blockers
    proposal.command_type = "SALE" if payload else "UNSUPPORTED"
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
    amounts = re.findall(r"(?:₹|Rs\.?|INR)\s*([0-9][0-9,]*(?:\.\d+)?)", text, flags=re.IGNORECASE)
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


def _interpret_with_ai(content: str, locale: str, business: Business, location: Location):
    from .chatgpt import interpret_with_ai

    result = interpret_with_ai(content, locale)
    if result is None or not result.is_valid:
        return None

    payload = {
        "business_id": str(business.id),
        "location_id": str(location.id),
        "customer_name": result.customer_name,
        "items": result.items,
        "total_minor": result.total_minor,
        "paid_minor": result.paid_minor,
    }
    preview_parts = []
    if result.customer_name:
        preview_parts.append(f"Party: {result.customer_name}")
    if result.items:
        for item in result.items:
            preview_parts.append(f"{item.get('quantity', '?')} × {item.get('product', '?')}")
    if result.total_minor:
        preview_parts.append(f"Total: ₹{result.total_minor / 100:.2f}")
    if result.paid_minor:
        preview_parts.append(f"Paid: ₹{result.paid_minor / 100:.2f}")
    preview = "; ".join(preview_parts) if preview_parts else ""
    return payload, preview, result.warnings, result.blocking_questions


@transaction.atomic
def interpret(
    *, actor, business: Business, location: Location, input_type: str, content: str, locale: str
):
    require_membership(actor, business.id, location_id=location.id)
    if location.business_id != business.id:
        raise ValidationError("Location does not belong to the business")
    business = Business.objects.select_for_update().get(pk=business.pk)
    location = Location.objects.select_for_update().get(pk=location.pk)

    ai_result = _interpret_with_ai(content, locale, business, location)
    if ai_result:
        payload, preview, warnings, blockers = ai_result
        command_type = "SALE" if payload.get("items") else "UNSUPPORTED"
    else:
        payload, preview, warnings, blockers = _parse_sale(content, business, location)
        command_type = "SALE" if payload else "UNSUPPORTED"

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
        if proposal.confirmed_result_type == "operations.sale":
            return Sale.objects.get(pk=proposal.confirmed_result_id), True
    if proposal.expires_at <= timezone.now():
        raise DomainConflict("This proposal has expired", "proposal_expired")
    if proposal.status != AssistantProposal.Status.READY or proposal.blocking_questions:
        raise DomainConflict("Resolve all questions before confirming", "proposal_not_ready")
    if proposal.version != version:
        raise DomainConflict(
            "The proposal changed; review the latest version", "stale_proposal_version"
        )
    if proposal.command_type != "SALE":
        raise ValidationError("This command type is not supported for confirmation")

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
        scope="sale.post",
        key=idempotency_key,
    ).exists():
        raise DomainConflict("This key belongs to another sale", "idempotency_key_reused")

    raw = dict(proposal.payload)
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
    sale, replayed = post_sale(serializer.validated_data, actor, source="ASSISTANT")
    proposal.status = AssistantProposal.Status.CONFIRMED
    proposal.confirmed_at = timezone.now()
    proposal.confirmed_result_type = "operations.sale"
    proposal.confirmed_result_id = sale.id
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
    return sale, replayed
