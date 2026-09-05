from __future__ import annotations

import uuid
from collections import defaultdict
from datetime import date
from decimal import ROUND_HALF_UP, Decimal
from typing import Any

from django.db import transaction
from django.utils import timezone
from rest_framework.exceptions import APIException, ValidationError

from apps.catalog.models import Party, Product, ProductPack
from apps.tenancy.access import require_membership
from apps.tenancy.models import (
    AuditEvent,
    Business,
    IdempotencyRecord,
    Location,
    Membership,
    OutboxEvent,
)

from .models import (
    DocumentSequence,
    DocumentStatus,
    Expense,
    PartyLedgerEntry,
    Payment,
    PaymentAllocation,
    Purchase,
    PurchaseLine,
    Sale,
    SaleLine,
    StockBalance,
    StockMovement,
    StockTransfer,
    StockTransferLine,
)

QUANTITY = Decimal("0.001")
ZERO = Decimal("0")
ZERO_MINOR = 0
BASIS_POINTS = 10_000


class DomainConflict(APIException):
    status_code = 409
    default_code = "domain_conflict"
    default_detail = "The requested operation conflicts with current business state."

    def __init__(self, detail, code=None):
        super().__init__({"message": detail, "code": code or self.default_code})


def as_minor(value: int | str) -> int:
    """Coerce a validated paise amount to a plain int. Money is stored and
    exchanged as integer paise; never use binary floating point."""
    return int(value)


def _round_half_up(value: Decimal) -> int:
    return int(value.to_integral_value(rounding=ROUND_HALF_UP))


def _mul_round_half_up(quantity_value: Decimal, minor: int) -> int:
    return _round_half_up(quantity_value * minor)


def _div_round_half_up(numerator: int, denominator: int) -> int:
    return (2 * numerator + denominator) // (2 * denominator)


def quantity(value: Decimal | str | int) -> Decimal:
    return Decimal(value).quantize(QUANTITY, rounding=ROUND_HALF_UP)


def financial_year(on_date: date) -> str:
    start = on_date.year if on_date.month >= 4 else on_date.year - 1
    return f"{start}-{str(start + 1)[-2:]}"


def _scope_and_prefix(location: Location, document_type: str) -> tuple[str, str]:
    if document_type == "SALE" and location.gst_registration_id:
        registration = location.gst_registration
        return f"location:{location.id}", f"{registration.invoice_prefix}-{location.code}"
    prefixes = {"SALE": "INV", "PURCHASE": "PUR", "EXPENSE": "EXP", "TRANSFER": "TRF"}
    return f"location:{location.id}", f"{prefixes[document_type]}-{location.code}"


def _next_number(business: Business, location: Location, document_type: str, on_date: date):
    fy = financial_year(on_date)
    scope, prefix = _scope_and_prefix(location, document_type)
    sequence, _ = DocumentSequence.objects.select_for_update().get_or_create(
        business=business,
        scope_key=scope,
        document_type=document_type,
        financial_year=fy,
        defaults={"next_number": 1},
    )
    value = sequence.next_number
    sequence.next_number += 1
    sequence.save(update_fields=["next_number", "updated_at"])
    return f"{prefix}/{fy}/{value:06d}", fy, value


def _existing(business, actor, scope: str, key: str, model):
    record = IdempotencyRecord.objects.filter(
        business=business,
        actor=actor,
        scope=scope,
        key=key,
    ).first()
    if not record:
        return None
    try:
        return model.objects.get(pk=record.result_id)
    except model.DoesNotExist as exc:
        raise DomainConflict(
            "An idempotency record points to a missing result", "idempotency_corrupt"
        ) from exc


def _remember(business, actor, scope: str, key: str, instance):
    IdempotencyRecord.objects.create(
        business=business,
        actor=actor,
        scope=scope,
        key=key,
        result_type=instance._meta.label_lower,
        result_id=instance.pk,
    )


def _audit(instance, actor, event_type: str, *, source="API", metadata=None, location=None):
    AuditEvent.objects.create(
        business=instance.business,
        location=location or getattr(instance, "location", None),
        actor=actor,
        event_type=event_type,
        aggregate_type=instance._meta.label_lower,
        aggregate_id=instance.pk,
        source=source,
        metadata=metadata or {},
    )


def _outbox(instance, topic: str):
    OutboxEvent.objects.get_or_create(
        dedupe_key=f"{topic}:{instance.pk}",
        defaults={
            "business": instance.business,
            "topic": topic,
            "payload": {"type": instance._meta.label_lower, "id": str(instance.pk)},
            "available_at": timezone.now(),
        },
    )


def _validate_common(business: Business, location: Location):
    if location.business_id != business.id or not location.is_active:
        raise ValidationError("Location does not belong to the active business")
    if business.currency != "INR":
        raise ValidationError("The MVP supports INR businesses only")


def _validate_party(party: Party | None, business: Business, expected: str):
    if party is None:
        return
    if party.business_id != business.id or not party.is_active:
        raise ValidationError("Party does not belong to the active business")
    if expected == "customer" and not party.can_buy():
        raise ValidationError("Selected party is not a customer")
    if expected == "supplier" and not party.can_supply():
        raise ValidationError("Selected party is not a supplier")


def _tax_context(business: Business, location: Location, party: Party | None, *, purchase=False):
    registration = location.gst_registration
    if business.gst_enabled and registration is None:
        raise ValidationError("A GST-enabled location requires a GST registration")
    local_state = registration.state_code if registration else location.state_code
    party_state = party.state_code if party else local_state
    is_interstate = bool(
        business.gst_enabled and local_state and party_state and local_state != party_state
    )
    if purchase:
        return {
            "seller_name": party.name if party else "",
            "seller_gstin": party.gstin if party else "",
            "seller_state_code": party_state,
            "buyer_name": registration.legal_name
            if registration
            else business.legal_name or business.name,
            "buyer_gstin": registration.gstin if registration else "",
            "buyer_state_code": local_state,
            "place_of_supply": local_state,
            "is_interstate": is_interstate,
        }
    return {
        "seller_name": registration.legal_name
        if registration
        else business.legal_name or business.name,
        "seller_gstin": registration.gstin if registration else "",
        "seller_address": registration.address if registration else location.address,
        "seller_state_code": local_state,
        "buyer_name": party.name if party else "Cash customer",
        "buyer_gstin": party.gstin if party else "",
        "buyer_state_code": party_state,
        "place_of_supply": party_state or local_state,
        "is_interstate": is_interstate,
    }


def _calculate_lines(
    raw_lines: list[dict[str, Any]],
    *,
    business: Business,
    tax_inclusive: bool,
    is_interstate: bool,
    price_mode: str | None = None,
    invoice_discount=ZERO_MINOR,
    purchase=False,
):
    if not raw_lines:
        raise ValidationError("At least one line is required")
    prepared = []
    subtotal_minor = 0
    for raw in raw_lines:
        pack: ProductPack = raw["pack"]
        product = pack.product
        if product.business_id != business.id or not product.is_active or not pack.is_active:
            raise ValidationError("Every pack must belong to an active product in the business")
        line_quantity = quantity(raw["quantity"])
        if line_quantity <= ZERO:
            raise ValidationError("Line quantity must be greater than zero")
        if purchase:
            unit_price_minor = as_minor(raw["unit_cost_minor"])
        elif raw.get("unit_price_minor") is not None:
            unit_price_minor = as_minor(raw["unit_price_minor"])
        else:
            unit_price_minor = (
                pack.wholesale_price_minor
                if price_mode == Sale.PriceMode.WHOLESALE
                else pack.retail_price_minor
            )
        if unit_price_minor < 0:
            raise ValidationError("Unit price cannot be negative")
        line_discount_minor = as_minor(raw.get("discount_minor", 0))
        gross_minor = _mul_round_half_up(line_quantity, unit_price_minor)
        if line_discount_minor < 0 or line_discount_minor > gross_minor:
            raise ValidationError("Line discount must be between zero and line value")
        subtotal_minor += gross_minor
        prepared.append(
            {
                "pack": pack,
                "product": product,
                "quantity": line_quantity,
                "unit_price_minor": unit_price_minor,
                "line_discount_minor": line_discount_minor,
                "gross_minor": gross_minor,
            }
        )

    invoice_discount_minor = as_minor(invoice_discount)
    remaining_basis = sum(
        (item["gross_minor"] - item["line_discount_minor"] for item in prepared), 0
    )
    if invoice_discount_minor < 0 or invoice_discount_minor > remaining_basis:
        raise ValidationError("Invoice discount exceeds the line value")

    discount_left = invoice_discount_minor
    calculated = []
    for index, item in enumerate(prepared):
        basis = item["gross_minor"] - item["line_discount_minor"]
        if index == len(prepared) - 1:
            allocated = discount_left
        elif remaining_basis:
            allocated = _div_round_half_up(invoice_discount_minor * basis, remaining_basis)
            discount_left -= allocated
        else:
            allocated = 0
        total_discount = item["line_discount_minor"] + allocated
        net = item["gross_minor"] - total_discount
        tax_rate_bps = product_tax_rate_bps(item["product"], business)
        if tax_inclusive and tax_rate_bps:
            taxable = _div_round_half_up(net * BASIS_POINTS, BASIS_POINTS + tax_rate_bps)
            tax = net - taxable
            line_total = net
        else:
            taxable = net
            tax = _div_round_half_up(taxable * tax_rate_bps, BASIS_POINTS)
            line_total = taxable + tax
        if is_interstate:
            cgst = sgst = 0
            igst = tax
        else:
            cgst = (tax + 1) // 2
            sgst = tax - cgst
            igst = 0
        calculated.append(
            {
                **item,
                "base_quantity": quantity(item["quantity"] * item["pack"].conversion_factor),
                "discount_minor": total_discount,
                "taxable_value_minor": taxable,
                "tax_rate_bps": tax_rate_bps,
                "cgst_amount_minor": cgst,
                "sgst_amount_minor": sgst,
                "igst_amount_minor": igst,
                "line_total_minor": line_total,
            }
        )
    return {
        "lines": calculated,
        "subtotal_minor": subtotal_minor,
        "discount_total_minor": sum((item["discount_minor"] for item in calculated), 0),
        "taxable_total_minor": sum((item["taxable_value_minor"] for item in calculated), 0),
        "tax_total_minor": sum(
            (
                item["cgst_amount_minor"] + item["sgst_amount_minor"] + item["igst_amount_minor"]
                for item in calculated
            ),
            0,
        ),
        "grand_total_minor": sum((item["line_total_minor"] for item in calculated), 0),
    }


def product_tax_rate_bps(product, business) -> int:
    return product.tax_rate_bps if business.gst_enabled else 0


def _locked_balance(business, location, product):
    balance = (
        StockBalance.objects.select_for_update()
        .filter(
            business=business,
            location=location,
            product=product,
        )
        .first()
    )
    if balance is None:
        balance = StockBalance.objects.create(business=business, location=location, product=product)
    return balance


def _check_and_apply_stock(
    *,
    business,
    location,
    deltas,
    source_type,
    source_id,
    movement_type,
    occurred_at,
    actor_role,
    acknowledged=False,
    reason="",
    packs=None,
):
    projected = []
    balances = {}
    for product_id in sorted(deltas, key=str):
        product = Product.objects.get(pk=product_id)
        if not product.track_inventory:
            continue
        balance = _locked_balance(business, location, product)
        new_quantity = quantity(balance.quantity + deltas[product_id])
        balances[product_id] = (balance, new_quantity, product)
        if new_quantity < ZERO:
            projected.append(
                {
                    "product_id": str(product.id),
                    "name": product.name,
                    "projected_quantity": str(new_quantity),
                }
            )
    if projected:
        if not business.negative_stock_allowed:
            raise DomainConflict(
                "This business does not allow negative stock", "negative_stock_blocked"
            )
        if actor_role not in {Membership.Role.OWNER, Membership.Role.MANAGER}:
            raise DomainConflict(
                "A manager or owner must approve negative stock", "negative_stock_requires_manager"
            )
        if not acknowledged or not reason.strip():
            exc = DomainConflict(
                "Confirm the current negative-stock impact and provide a reason",
                "negative_stock_confirmation_required",
            )
            exc.detail["products"] = projected
            raise exc
    for product_id, (balance, new_quantity, product) in balances.items():
        delta = quantity(deltas[product_id])
        balance.quantity = new_quantity
        balance.save(update_fields=["quantity", "updated_at"])
        StockMovement.objects.create(
            business=business,
            location=location,
            product=product,
            pack=(packs or {}).get(product_id),
            movement_type=movement_type,
            quantity=delta,
            source_type=source_type,
            source_id=source_id,
            note=reason,
            occurred_at=occurred_at,
        )


def _create_payment_locked(
    *,
    business,
    location,
    party,
    direction,
    method,
    amount,
    payment_date,
    actor,
    source,
    idempotency_key,
    sale=None,
    purchase=None,
    reference="",
    note="",
):
    payment = Payment.objects.create(
        business=business,
        location=location,
        party=party,
        direction=direction,
        method=method,
        amount_minor=as_minor(amount),
        payment_date=payment_date,
        created_by=actor,
        source=source,
        idempotency_key=idempotency_key,
        reference=reference,
        note=note,
    )
    PaymentAllocation.objects.create(
        payment=payment, sale=sale, purchase=purchase, amount_minor=payment.amount_minor
    )
    if party:
        PartyLedgerEntry.objects.create(
            business=business,
            location=location,
            party=party,
            account=(
                PartyLedgerEntry.Account.RECEIVABLE
                if direction == Payment.Direction.RECEIPT
                else PartyLedgerEntry.Account.PAYABLE
            ),
            amount_minor=-payment.amount_minor,
            source_type="PAYMENT",
            source_id=payment.id,
            note=note,
            occurred_at=timezone.now(),
        )
    return payment


@transaction.atomic
def post_sale(data: dict[str, Any], actor, *, source="API"):
    business = Business.objects.select_for_update().get(pk=data["business"].pk)
    location = data["location"]
    _validate_common(business, location)
    membership = require_membership(actor, business.id, location_id=location.id)
    key = data["idempotency_key"]
    if existing := _existing(business, actor, "sale.post", key, Sale):
        return existing, True
    customer = data.get("customer")
    _validate_party(customer, business, "customer")
    tax_context = _tax_context(business, location, customer)
    totals = _calculate_lines(
        data["lines"],
        business=business,
        tax_inclusive=data.get("tax_inclusive", False),
        is_interstate=tax_context.pop("is_interstate"),
        price_mode=data.get("price_mode", Sale.PriceMode.RETAIL),
        invoice_discount=data.get("discount_total_minor", ZERO_MINOR),
    )
    paid = as_minor(data.get("paid_amount_minor", ZERO_MINOR))
    if paid < 0 or paid > totals["grand_total_minor"]:
        raise ValidationError("Paid amount must be between zero and the invoice total")
    due = totals["grand_total_minor"] - paid
    if due and customer is None:
        raise ValidationError("A customer is required for a credit sale")

    deltas = defaultdict(lambda: ZERO)
    packs = {}
    for line in totals["lines"]:
        if line["product"].track_inventory:
            deltas[line["product"].id] -= line["base_quantity"]
            packs[line["product"].id] = line["pack"]

    on_date = data.get("invoice_date") or timezone.localdate()
    number, fy, sequence = _next_number(business, location, "SALE", on_date)
    sale = Sale.objects.create(
        business=business,
        location=location,
        customer=customer,
        number=number,
        financial_year=fy,
        sequence_number=sequence,
        document_date=on_date,
        posted_at=timezone.now(),
        created_by=actor,
        source=source,
        idempotency_key=key,
        price_mode=data.get("price_mode", Sale.PriceMode.RETAIL),
        tax_inclusive=data.get("tax_inclusive", False),
        paid_total_minor=paid,
        due_total_minor=due,
        negative_stock_acknowledged=data.get("negative_stock_acknowledged", False),
        negative_stock_reason=data.get("negative_stock_reason", ""),
        **tax_context,
        **{
            name: totals[name]
            for name in [
                "subtotal_minor",
                "discount_total_minor",
                "taxable_total_minor",
                "tax_total_minor",
                "grand_total_minor",
            ]
        },
    )
    _check_and_apply_stock(
        business=business,
        location=location,
        deltas=deltas,
        source_type="SALE",
        source_id=sale.id,
        movement_type=StockMovement.Type.SALE,
        occurred_at=sale.posted_at,
        actor_role=membership.role,
        acknowledged=sale.negative_stock_acknowledged,
        reason=sale.negative_stock_reason,
        packs=packs,
    )
    for line in totals["lines"]:
        SaleLine.objects.create(
            sale=sale,
            product=line["product"],
            pack=line["pack"],
            description=line["product"].name,
            hsn_sac=line["product"].hsn_sac,
            quantity=line["quantity"],
            conversion_factor=line["pack"].conversion_factor,
            base_quantity=line["base_quantity"],
            unit_price_minor=line["unit_price_minor"],
            discount_minor=line["discount_minor"],
            taxable_value_minor=line["taxable_value_minor"],
            tax_rate_bps=line["tax_rate_bps"],
            cgst_amount_minor=line["cgst_amount_minor"],
            sgst_amount_minor=line["sgst_amount_minor"],
            igst_amount_minor=line["igst_amount_minor"],
            line_total_minor=line["line_total_minor"],
        )
    if customer:
        PartyLedgerEntry.objects.create(
            business=business,
            location=location,
            party=customer,
            account=PartyLedgerEntry.Account.RECEIVABLE,
            amount_minor=sale.grand_total_minor,
            source_type="SALE",
            source_id=sale.id,
            note=sale.number,
            occurred_at=sale.posted_at,
        )
    if paid:
        _create_payment_locked(
            business=business,
            location=location,
            party=customer,
            direction=Payment.Direction.RECEIPT,
            method=data.get("payment_method", Payment.Method.CASH),
            amount=paid,
            payment_date=on_date,
            actor=actor,
            source=source,
            idempotency_key=f"sale:{sale.id}:initial",
            sale=sale,
            reference=data.get("payment_reference", ""),
            note=f"Initial payment for {sale.number}",
        )
    _remember(business, actor, "sale.post", key, sale)
    _audit(sale, actor, "sale.posted", source=source)
    _outbox(sale, "sale.posted")
    return sale, False


@transaction.atomic
def post_purchase(data: dict[str, Any], actor, *, source="API"):
    business = Business.objects.select_for_update().get(pk=data["business"].pk)
    location = data["location"]
    _validate_common(business, location)
    require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=location.id,
    )
    key = data["idempotency_key"]
    if existing := _existing(business, actor, "purchase.post", key, Purchase):
        return existing, True
    supplier = data["supplier"]
    _validate_party(supplier, business, "supplier")
    tax_context = _tax_context(business, location, supplier, purchase=True)
    totals = _calculate_lines(
        data["lines"],
        business=business,
        tax_inclusive=data.get("tax_inclusive", False),
        is_interstate=tax_context.pop("is_interstate"),
        invoice_discount=data.get("discount_total_minor", ZERO_MINOR),
        purchase=True,
    )
    paid = as_minor(data.get("paid_amount_minor", ZERO_MINOR))
    if paid < 0 or paid > totals["grand_total_minor"]:
        raise ValidationError("Paid amount must be between zero and the bill total")
    on_date = data.get("purchase_date") or timezone.localdate()
    number, fy, sequence = _next_number(business, location, "PURCHASE", on_date)
    purchase = Purchase.objects.create(
        business=business,
        location=location,
        supplier=supplier,
        number=number,
        financial_year=fy,
        sequence_number=sequence,
        document_date=on_date,
        posted_at=timezone.now(),
        created_by=actor,
        source=source,
        idempotency_key=key,
        supplier_bill_number=data.get("supplier_bill_number", ""),
        tax_inclusive=data.get("tax_inclusive", False),
        paid_total_minor=paid,
        due_total_minor=totals["grand_total_minor"] - paid,
        **tax_context,
        **{
            name: totals[name]
            for name in [
                "subtotal_minor",
                "discount_total_minor",
                "taxable_total_minor",
                "tax_total_minor",
                "grand_total_minor",
            ]
        },
    )
    deltas = defaultdict(lambda: ZERO)
    packs = {}
    for line in totals["lines"]:
        PurchaseLine.objects.create(
            purchase=purchase,
            product=line["product"],
            pack=line["pack"],
            description=line["product"].name,
            hsn_sac=line["product"].hsn_sac,
            quantity=line["quantity"],
            conversion_factor=line["pack"].conversion_factor,
            base_quantity=line["base_quantity"],
            unit_cost_minor=line["unit_price_minor"],
            discount_minor=line["discount_minor"],
            taxable_value_minor=line["taxable_value_minor"],
            tax_rate_bps=line["tax_rate_bps"],
            cgst_amount_minor=line["cgst_amount_minor"],
            sgst_amount_minor=line["sgst_amount_minor"],
            igst_amount_minor=line["igst_amount_minor"],
            line_total_minor=line["line_total_minor"],
        )
        if line["product"].track_inventory:
            deltas[line["product"].id] += line["base_quantity"]
            packs[line["product"].id] = line["pack"]
    _check_and_apply_stock(
        business=business,
        location=location,
        deltas=deltas,
        source_type="PURCHASE",
        source_id=purchase.id,
        movement_type=StockMovement.Type.PURCHASE,
        occurred_at=purchase.posted_at,
        actor_role=Membership.Role.MANAGER,
        packs=packs,
    )
    PartyLedgerEntry.objects.create(
        business=business,
        location=location,
        party=supplier,
        account=PartyLedgerEntry.Account.PAYABLE,
        amount_minor=purchase.grand_total_minor,
        source_type="PURCHASE",
        source_id=purchase.id,
        note=purchase.number,
        occurred_at=purchase.posted_at,
    )
    if paid:
        _create_payment_locked(
            business=business,
            location=location,
            party=supplier,
            direction=Payment.Direction.PAYMENT,
            method=data.get("payment_method", Payment.Method.CASH),
            amount=paid,
            payment_date=on_date,
            actor=actor,
            source=source,
            idempotency_key=f"purchase:{purchase.id}:initial",
            purchase=purchase,
            reference=data.get("payment_reference", ""),
            note=f"Initial payment for {purchase.number}",
        )
    _remember(business, actor, "purchase.post", key, purchase)
    _audit(purchase, actor, "purchase.posted", source=source)
    _outbox(purchase, "purchase.posted")
    return purchase, False


@transaction.atomic
def post_payment(data: dict[str, Any], actor, *, source="API"):
    business = Business.objects.select_for_update().get(pk=data["business"].pk)
    location = data["location"]
    _validate_common(business, location)
    direction = data["direction"]
    roles = [Membership.Role.OWNER, Membership.Role.MANAGER]
    if direction == Payment.Direction.RECEIPT:
        roles.append(Membership.Role.CASHIER)
    require_membership(actor, business.id, roles=roles, location_id=location.id)
    key = data["idempotency_key"]
    if existing := _existing(business, actor, "payment.post", key, Payment):
        return existing, True

    party = data["party"]
    expected = "customer" if direction == Payment.Direction.RECEIPT else "supplier"
    _validate_party(party, business, expected)
    sale = data.get("sale")
    purchase = data.get("purchase")
    if direction == Payment.Direction.RECEIPT:
        if not sale or purchase:
            raise ValidationError("A customer receipt must target one sale")
        if (
            sale.business_id != business.id
            or sale.location_id != location.id
            or sale.customer_id != party.id
        ):
            raise ValidationError("Sale, customer, business, and location must match")
        if sale.status != DocumentStatus.POSTED:
            raise ValidationError("Only a posted sale can receive payment")
        target_due = sale.due_total_minor
    else:
        if not purchase or sale:
            raise ValidationError("A supplier payment must target one purchase")
        if (
            purchase.business_id != business.id
            or purchase.location_id != location.id
            or purchase.supplier_id != party.id
        ):
            raise ValidationError("Purchase, supplier, business, and location must match")
        if purchase.status != DocumentStatus.POSTED:
            raise ValidationError("Only a posted purchase can receive payment")
        target_due = purchase.due_total_minor
    amount = as_minor(data["amount_minor"])
    if amount <= 0:
        raise ValidationError("Payment amount must be greater than zero")
    if amount > target_due:
        raise DomainConflict(
            "Payment exceeds the document outstanding amount", "payment_exceeds_due"
        )
    payment = _create_payment_locked(
        business=business,
        location=location,
        party=party,
        direction=direction,
        method=data["method"],
        amount=amount,
        payment_date=data.get("payment_date") or timezone.localdate(),
        actor=actor,
        source=source,
        idempotency_key=key,
        sale=sale,
        purchase=purchase,
        reference=data.get("reference", ""),
        note=data.get("note", ""),
    )
    target = sale or purchase
    target.paid_total_minor += amount
    target.due_total_minor = target.grand_total_minor - target.paid_total_minor
    target.save(update_fields=["paid_total_minor", "due_total_minor", "updated_at"])
    _remember(business, actor, "payment.post", key, payment)
    _audit(payment, actor, "payment.posted", source=source)
    _outbox(payment, "payment.posted")
    return payment, False


@transaction.atomic
def post_expense(data: dict[str, Any], actor, *, source="API"):
    business = Business.objects.select_for_update().get(pk=data["business"].pk)
    location = data["location"]
    _validate_common(business, location)
    require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=location.id,
    )
    key = data["idempotency_key"]
    if existing := _existing(business, actor, "expense.post", key, Expense):
        return existing, True
    amount = as_minor(data["amount_minor"])
    tax_amount = as_minor(data.get("tax_amount_minor", ZERO_MINOR))
    if amount <= 0 or tax_amount < 0:
        raise ValidationError("Expense amount must be positive and tax cannot be negative")
    on_date = data.get("expense_date") or timezone.localdate()
    number, fy, sequence = _next_number(business, location, "EXPENSE", on_date)
    expense = Expense.objects.create(
        business=business,
        location=location,
        number=number,
        financial_year=fy,
        sequence_number=sequence,
        document_date=on_date,
        posted_at=timezone.now(),
        created_by=actor,
        source=source,
        idempotency_key=key,
        category=data["category"],
        payee=data.get("payee", ""),
        note=data.get("note", ""),
        amount_minor=amount,
        tax_amount_minor=tax_amount,
        total_minor=amount + tax_amount,
        payment_method=data["payment_method"],
    )
    _remember(business, actor, "expense.post", key, expense)
    _audit(expense, actor, "expense.posted", source=source)
    _outbox(expense, "expense.posted")
    return expense, False


@transaction.atomic
def post_transfer(data: dict[str, Any], actor, *, source="API"):
    business = Business.objects.select_for_update().get(pk=data["business"].pk)
    from_location = data["from_location"]
    to_location = data["to_location"]
    _validate_common(business, from_location)
    _validate_common(business, to_location)
    if from_location.id == to_location.id:
        raise ValidationError("Transfer locations must differ")
    membership = require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=from_location.id,
    )
    require_membership(actor, business.id, location_id=to_location.id)
    key = data["idempotency_key"]
    if existing := _existing(business, actor, "transfer.post", key, StockTransfer):
        return existing, True
    raw_lines = data["lines"]
    if not raw_lines:
        raise ValidationError("At least one transfer line is required")
    deltas = defaultdict(lambda: ZERO)
    prepared = []
    packs = {}
    for raw in raw_lines:
        pack = raw["pack"]
        product = pack.product
        if (
            product.business_id != business.id
            or not pack.is_active
            or not product.is_active
            or not product.track_inventory
        ):
            raise ValidationError("Transfer packs must be active tracked products in this business")
        count = quantity(raw["quantity"])
        if count <= ZERO:
            raise ValidationError("Transfer quantity must be greater than zero")
        base = quantity(count * pack.conversion_factor)
        deltas[product.id] -= base
        packs[product.id] = pack
        prepared.append((pack, product, count, base))
    on_date = data.get("transfer_date") or timezone.localdate()
    number, fy, sequence = _next_number(business, from_location, "TRANSFER", on_date)
    transfer = StockTransfer.objects.create(
        business=business,
        location=from_location,
        from_location=from_location,
        to_location=to_location,
        number=number,
        financial_year=fy,
        sequence_number=sequence,
        document_date=on_date,
        posted_at=timezone.now(),
        created_by=actor,
        source=source,
        idempotency_key=key,
        note=data.get("note", ""),
        negative_stock_acknowledged=data.get("negative_stock_acknowledged", False),
        negative_stock_reason=data.get("negative_stock_reason", ""),
    )
    _check_and_apply_stock(
        business=business,
        location=from_location,
        deltas=deltas,
        source_type="TRANSFER",
        source_id=transfer.id,
        movement_type=StockMovement.Type.TRANSFER_OUT,
        occurred_at=transfer.posted_at,
        actor_role=membership.role,
        acknowledged=transfer.negative_stock_acknowledged,
        reason=transfer.negative_stock_reason,
        packs=packs,
    )
    incoming = {product_id: -delta for product_id, delta in deltas.items()}
    _check_and_apply_stock(
        business=business,
        location=to_location,
        deltas=incoming,
        source_type="TRANSFER",
        source_id=transfer.id,
        movement_type=StockMovement.Type.TRANSFER_IN,
        occurred_at=transfer.posted_at,
        actor_role=membership.role,
        packs=packs,
    )
    for pack, product, count, base in prepared:
        StockTransferLine.objects.create(
            transfer=transfer,
            product=product,
            pack=pack,
            quantity=count,
            conversion_factor=pack.conversion_factor,
            base_quantity=base,
        )
    _remember(business, actor, "transfer.post", key, transfer)
    _audit(transfer, actor, "transfer.posted", source=source)
    _outbox(transfer, "transfer.posted")
    return transfer, False


@transaction.atomic
def post_stock_adjustment(data: dict[str, Any], actor, *, source="API"):
    business = Business.objects.select_for_update().get(pk=data["business"].pk)
    location = data["location"]
    product = data["product"]
    _validate_common(business, location)
    membership = require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=location.id,
    )
    if product.business_id != business.id or not product.track_inventory:
        raise ValidationError("Product must be a tracked product in this business")
    key = data["idempotency_key"]
    if existing := _existing(business, actor, "stock.adjust", key, StockMovement):
        return existing, True
    delta = quantity(data["quantity_delta"])
    if not delta:
        raise ValidationError("Stock adjustment cannot be zero")
    source_id = data.get("source_id") or uuid.uuid4()
    _check_and_apply_stock(
        business=business,
        location=location,
        deltas={product.id: delta},
        source_type="STOCK_ADJUSTMENT",
        source_id=source_id,
        movement_type=data.get("movement_type", StockMovement.Type.ADJUSTMENT),
        occurred_at=timezone.now(),
        actor_role=membership.role,
        acknowledged=data.get("negative_stock_acknowledged", False),
        reason=data["reason"],
    )
    movement = StockMovement.objects.get(
        source_type="STOCK_ADJUSTMENT", source_id=source_id, product=product, location=location
    )
    _remember(business, actor, "stock.adjust", key, movement)
    _audit(movement, actor, "stock.adjusted", source=source, location=location)
    return movement, False


@transaction.atomic
def post_opening_balance(data: dict[str, Any], actor, *, source="API"):
    business = Business.objects.select_for_update().get(pk=data["business"].pk)
    location = data["location"]
    party = data["party"]
    _validate_common(business, location)
    require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=location.id,
    )
    _validate_party(
        party,
        business,
        "customer" if data["account"] == PartyLedgerEntry.Account.RECEIVABLE else "supplier",
    )
    key = data["idempotency_key"]
    if existing := _existing(business, actor, "party.opening", key, PartyLedgerEntry):
        return existing, True
    amount = as_minor(data["amount_minor"])
    if amount < 0:
        raise ValidationError("Opening balance cannot be negative")
    entry = PartyLedgerEntry.objects.create(
        business=business,
        location=location,
        party=party,
        account=data["account"],
        amount_minor=amount,
        source_type="OPENING_BALANCE",
        source_id=party.id,
        note=data.get("note", "Opening balance"),
        occurred_at=timezone.now(),
    )
    _remember(business, actor, "party.opening", key, entry)
    _audit(entry, actor, "party.opening_recorded", source=source, location=location)
    return entry, False


def _reverse_payment_locked(payment: Payment, actor, reason: str, source: str):
    if payment.status != DocumentStatus.POSTED:
        raise DomainConflict("Payment is not posted", "already_reversed")
    allocations = list(payment.allocations.select_related("sale", "purchase"))
    for allocation in allocations:
        target = allocation.sale or allocation.purchase
        target.paid_total_minor -= allocation.amount_minor
        target.due_total_minor = target.grand_total_minor - target.paid_total_minor
        target.save(update_fields=["paid_total_minor", "due_total_minor", "updated_at"])
    if payment.party:
        PartyLedgerEntry.objects.create(
            business=payment.business,
            location=payment.location,
            party=payment.party,
            account=(
                PartyLedgerEntry.Account.RECEIVABLE
                if payment.direction == Payment.Direction.RECEIPT
                else PartyLedgerEntry.Account.PAYABLE
            ),
            amount_minor=payment.amount_minor,
            source_type="PAYMENT_REVERSAL",
            source_id=payment.id,
            note=reason,
            occurred_at=timezone.now(),
        )
    payment.status = DocumentStatus.REVERSED
    payment.reversal_reason = reason
    payment.reversed_at = timezone.now()
    payment.save(update_fields=["status", "reversal_reason", "reversed_at", "updated_at"])
    _audit(payment, actor, "payment.reversed", source=source, metadata={"reason": reason})
    _outbox(payment, "payment.reversed")


@transaction.atomic
def reverse_payment(payment: Payment, actor, *, reason: str, idempotency_key: str, source="API"):
    business = Business.objects.select_for_update().get(pk=payment.business_id)
    payment = Payment.objects.select_for_update().get(pk=payment.pk, business=business)
    roles = [Membership.Role.OWNER, Membership.Role.MANAGER]
    if payment.direction == Payment.Direction.RECEIPT:
        roles.append(Membership.Role.CASHIER)
    require_membership(actor, business.id, roles=roles, location_id=payment.location_id)
    if existing := _existing(business, actor, "payment.reverse", idempotency_key, Payment):
        return existing, True
    if not reason.strip():
        raise ValidationError("A reversal reason is required")
    _reverse_payment_locked(payment, actor, reason, source)
    _remember(business, actor, "payment.reverse", idempotency_key, payment)
    return payment, False


@transaction.atomic
def reverse_sale(sale: Sale, actor, *, reason: str, idempotency_key: str, source="API"):
    business = Business.objects.select_for_update().get(pk=sale.business_id)
    sale = (
        Sale.objects.select_for_update()
        .prefetch_related("lines", "payment_allocations__payment__allocations")
        .get(pk=sale.pk)
    )
    require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=sale.location_id,
    )
    if existing := _existing(business, actor, "sale.reverse", idempotency_key, Sale):
        return existing, True
    if sale.status != DocumentStatus.POSTED:
        raise DomainConflict("Sale is not posted", "already_reversed")
    if not reason.strip():
        raise ValidationError("A reversal reason is required")
    payments = {
        allocation.payment
        for allocation in sale.payment_allocations.all()
        if allocation.payment.status == DocumentStatus.POSTED
    }
    for payment in payments:
        if payment.allocations.exclude(sale=sale).exists():
            raise DomainConflict(
                "Reverse a payment allocated to multiple documents before reversing this sale",
                "shared_payment_allocation",
            )
    deltas = defaultdict(lambda: ZERO)
    packs = {}
    for line in sale.lines.all():
        if line.product.track_inventory:
            deltas[line.product_id] += line.base_quantity
            packs[line.product_id] = line.pack
    _check_and_apply_stock(
        business=business,
        location=sale.location,
        deltas=deltas,
        source_type="SALE_REVERSAL",
        source_id=sale.id,
        movement_type=StockMovement.Type.SALE_REVERSAL,
        occurred_at=timezone.now(),
        actor_role=Membership.Role.MANAGER,
        reason=reason,
        packs=packs,
    )
    if sale.customer:
        PartyLedgerEntry.objects.create(
            business=business,
            location=sale.location,
            party=sale.customer,
            account=PartyLedgerEntry.Account.RECEIVABLE,
            amount_minor=-sale.grand_total_minor,
            source_type="SALE_REVERSAL",
            source_id=sale.id,
            note=reason,
            occurred_at=timezone.now(),
        )
    for payment in payments:
        _reverse_payment_locked(payment, actor, reason, source)
    sale.status = DocumentStatus.REVERSED
    sale.reversal_reason = reason
    sale.reversed_at = timezone.now()
    sale.save(update_fields=["status", "reversal_reason", "reversed_at", "updated_at"])
    _remember(business, actor, "sale.reverse", idempotency_key, sale)
    _audit(sale, actor, "sale.reversed", source=source, metadata={"reason": reason})
    _outbox(sale, "sale.reversed")
    return sale, False


@transaction.atomic
def reverse_purchase(
    purchase: Purchase,
    actor,
    *,
    reason: str,
    idempotency_key: str,
    negative_stock_acknowledged=False,
    source="API",
):
    business = Business.objects.select_for_update().get(pk=purchase.business_id)
    purchase = (
        Purchase.objects.select_for_update()
        .prefetch_related("lines", "payment_allocations__payment__allocations")
        .get(pk=purchase.pk)
    )
    membership = require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=purchase.location_id,
    )
    if existing := _existing(business, actor, "purchase.reverse", idempotency_key, Purchase):
        return existing, True
    if purchase.status != DocumentStatus.POSTED:
        raise DomainConflict("Purchase is not posted", "already_reversed")
    if not reason.strip():
        raise ValidationError("A reversal reason is required")
    payments = {
        allocation.payment
        for allocation in purchase.payment_allocations.all()
        if allocation.payment.status == DocumentStatus.POSTED
    }
    for payment in payments:
        if payment.allocations.exclude(purchase=purchase).exists():
            raise DomainConflict(
                "Reverse a payment allocated to multiple documents first",
                "shared_payment_allocation",
            )
    deltas = defaultdict(lambda: ZERO)
    packs = {}
    for line in purchase.lines.all():
        if line.product.track_inventory:
            deltas[line.product_id] -= line.base_quantity
            packs[line.product_id] = line.pack
    _check_and_apply_stock(
        business=business,
        location=purchase.location,
        deltas=deltas,
        source_type="PURCHASE_REVERSAL",
        source_id=purchase.id,
        movement_type=StockMovement.Type.PURCHASE_REVERSAL,
        occurred_at=timezone.now(),
        actor_role=membership.role,
        acknowledged=negative_stock_acknowledged,
        reason=reason,
        packs=packs,
    )
    PartyLedgerEntry.objects.create(
        business=business,
        location=purchase.location,
        party=purchase.supplier,
        account=PartyLedgerEntry.Account.PAYABLE,
        amount_minor=-purchase.grand_total_minor,
        source_type="PURCHASE_REVERSAL",
        source_id=purchase.id,
        note=reason,
        occurred_at=timezone.now(),
    )
    for payment in payments:
        _reverse_payment_locked(payment, actor, reason, source)
    purchase.status = DocumentStatus.REVERSED
    purchase.reversal_reason = reason
    purchase.reversed_at = timezone.now()
    purchase.save(update_fields=["status", "reversal_reason", "reversed_at", "updated_at"])
    _remember(business, actor, "purchase.reverse", idempotency_key, purchase)
    _audit(purchase, actor, "purchase.reversed", source=source, metadata={"reason": reason})
    _outbox(purchase, "purchase.reversed")
    return purchase, False


@transaction.atomic
def reverse_expense(expense: Expense, actor, *, reason: str, idempotency_key: str, source="API"):
    business = Business.objects.select_for_update().get(pk=expense.business_id)
    expense = Expense.objects.select_for_update().get(pk=expense.pk)
    require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=expense.location_id,
    )
    if existing := _existing(business, actor, "expense.reverse", idempotency_key, Expense):
        return existing, True
    if expense.status != DocumentStatus.POSTED:
        raise DomainConflict("Expense is not posted", "already_reversed")
    if not reason.strip():
        raise ValidationError("A reversal reason is required")
    expense.status = DocumentStatus.REVERSED
    expense.reversal_reason = reason
    expense.reversed_at = timezone.now()
    expense.save(update_fields=["status", "reversal_reason", "reversed_at", "updated_at"])
    _remember(business, actor, "expense.reverse", idempotency_key, expense)
    _audit(expense, actor, "expense.reversed", source=source, metadata={"reason": reason})
    _outbox(expense, "expense.reversed")
    return expense, False


@transaction.atomic
def reverse_transfer(
    transfer: StockTransfer,
    actor,
    *,
    reason: str,
    idempotency_key: str,
    negative_stock_acknowledged=False,
    source="API",
):
    business = Business.objects.select_for_update().get(pk=transfer.business_id)
    transfer = (
        StockTransfer.objects.select_for_update().prefetch_related("lines").get(pk=transfer.pk)
    )
    membership = require_membership(
        actor,
        business.id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
        location_id=transfer.from_location_id,
    )
    require_membership(actor, business.id, location_id=transfer.to_location_id)
    if existing := _existing(business, actor, "transfer.reverse", idempotency_key, StockTransfer):
        return existing, True
    if transfer.status != DocumentStatus.POSTED:
        raise DomainConflict("Transfer is not posted", "already_reversed")
    if not reason.strip():
        raise ValidationError("A reversal reason is required")
    incoming_to_source = defaultdict(lambda: ZERO)
    outgoing_from_destination = defaultdict(lambda: ZERO)
    packs = {}
    for line in transfer.lines.all():
        incoming_to_source[line.product_id] += line.base_quantity
        outgoing_from_destination[line.product_id] -= line.base_quantity
        packs[line.product_id] = line.pack
    _check_and_apply_stock(
        business=business,
        location=transfer.to_location,
        deltas=outgoing_from_destination,
        source_type="TRANSFER_REVERSAL",
        source_id=transfer.id,
        movement_type=StockMovement.Type.TRANSFER_REVERSAL,
        occurred_at=timezone.now(),
        actor_role=membership.role,
        acknowledged=negative_stock_acknowledged,
        reason=reason,
        packs=packs,
    )
    _check_and_apply_stock(
        business=business,
        location=transfer.from_location,
        deltas=incoming_to_source,
        source_type="TRANSFER_REVERSAL",
        source_id=transfer.id,
        movement_type=StockMovement.Type.TRANSFER_REVERSAL,
        occurred_at=timezone.now(),
        actor_role=membership.role,
        reason=reason,
        packs=packs,
    )
    transfer.status = DocumentStatus.REVERSED
    transfer.reversal_reason = reason
    transfer.reversed_at = timezone.now()
    transfer.save(update_fields=["status", "reversal_reason", "reversed_at", "updated_at"])
    _remember(business, actor, "transfer.reverse", idempotency_key, transfer)
    _audit(transfer, actor, "transfer.reversed", source=source, metadata={"reason": reason})
    _outbox(transfer, "transfer.reversed")
    return transfer, False
