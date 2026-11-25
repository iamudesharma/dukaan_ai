"""Stateless GST-style invoice documents derived from posted sales.

There is deliberately no invoice model, mutable invoice row, or second ledger.
A frozen value snapshot is rendered on demand. Reversed sales retain their
posted amounts and receive an explicit revision/void watermark.
"""

from __future__ import annotations

import hashlib
import html
import json
import re
from dataclasses import dataclass, replace
from datetime import date, datetime
from decimal import Decimal
from io import BytesIO
from pathlib import Path
from typing import Any
from uuid import UUID
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from django.utils import timezone
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas
from reportlab.platypus import (
    KeepTogether,
    LongTable,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)
from rest_framework.exceptions import APIException

from apps.operations.models import DocumentStatus, Sale

from .money import (
    amount_in_words,
    format_half_rate_percent,
    format_money,
    format_rate_percent,
    format_rupees,
)

_FONT_DIR = Path(__file__).with_name("fonts")
pdfmetrics.registerFont(TTFont("DukaanSans", str(_FONT_DIR / "noto-devanagari-400.ttf")))
pdfmetrics.registerFont(TTFont("DukaanSans-Bold", str(_FONT_DIR / "noto-devanagari-700.ttf")))
pdfmetrics.registerFontFamily(
    "DukaanSans",
    normal="DukaanSans",
    bold="DukaanSans-Bold",
    italic="DukaanSans",
    boldItalic="DukaanSans-Bold",
)


class InvoiceNotPostable(APIException):
    status_code = 409
    default_code = "invoice_not_postable"
    default_detail = "Only a posted sale can be rendered as an invoice."


class InvoiceDataError(APIException):
    status_code = 409
    default_code = "invoice_data_incomplete"
    default_detail = "The posted sale does not contain invoice line items."


@dataclass(frozen=True, slots=True)
class InvoiceLine:
    description: str
    hsn_sac: str
    quantity: Decimal
    unit_price_minor: int
    discount_minor: int
    taxable_value_minor: int
    tax_rate_bps: int
    cgst_amount_minor: int
    sgst_amount_minor: int
    igst_amount_minor: int
    line_total_minor: int


@dataclass(frozen=True, slots=True)
class InvoiceRevision:
    """Immutable revision identity; a reversed document is revision 1, voided."""

    number: int
    status: str
    is_void: bool
    reversed_at: datetime | None
    reversal_reason: str
    source_fingerprint: str


@dataclass(frozen=True, slots=True)
class SaleInvoice:
    sale_id: UUID
    number: str
    document_date: date
    financial_year: str
    posted_at: datetime
    seller_name: str
    seller_gstin: str
    seller_address: str
    seller_state_code: str
    buyer_name: str
    buyer_gstin: str
    buyer_state_code: str
    place_of_supply: str
    supply_type: str
    tax_inclusive: bool
    business_timezone: str
    lines: tuple[InvoiceLine, ...]
    subtotal_minor: int
    discount_total_minor: int
    taxable_total_minor: int
    cgst_total_minor: int
    sgst_total_minor: int
    igst_total_minor: int
    tax_total_minor: int
    grand_total_minor: int
    paid_total_minor: int
    due_total_minor: int
    revision: InvoiceRevision


_MONTHS = (
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
)
_NAVY = colors.HexColor("#17324D")
_TEAL = colors.HexColor("#0F766E")
_INK = colors.HexColor("#172B3A")
_MUTED = colors.HexColor("#5F6F7F")
_LINE = colors.HexColor("#D9E2EA")
_PALE = colors.HexColor("#F4F7FA")
_RED = colors.HexColor("#B42318")
_RED_PALE = colors.HexColor("#FDECEA")
_WATERMARK = colors.HexColor("#F7E2DF")
_PAGE_WIDTH, _PAGE_HEIGHT = A4
_MARGIN = 16 * mm
_CONTENT_WIDTH = _PAGE_WIDTH - (2 * _MARGIN)
_SUMMARY_GAP = 13
_SUMMARY_COLUMN = (_CONTENT_WIDTH - _SUMMARY_GAP) / 2


def _invoice_payload(invoice: SaleInvoice) -> dict[str, Any]:
    return {
        "sale_id": str(invoice.sale_id),
        "number": invoice.number,
        "document_date": invoice.document_date.isoformat(),
        "financial_year": invoice.financial_year,
        "posted_at": invoice.posted_at.isoformat(),
        "seller": {
            "name": invoice.seller_name,
            "gstin": invoice.seller_gstin,
            "address": invoice.seller_address,
            "state_code": invoice.seller_state_code,
        },
        "buyer": {
            "name": invoice.buyer_name,
            "gstin": invoice.buyer_gstin,
            "state_code": invoice.buyer_state_code,
        },
        "place_of_supply": invoice.place_of_supply,
        "supply_type": invoice.supply_type,
        "tax_inclusive": invoice.tax_inclusive,
        "lines": [
            {
                "description": line.description,
                "hsn_sac": line.hsn_sac,
                "quantity": str(line.quantity),
                "unit_price_minor": line.unit_price_minor,
                "discount_minor": line.discount_minor,
                "taxable_value_minor": line.taxable_value_minor,
                "tax_rate_bps": line.tax_rate_bps,
                "cgst_amount_minor": line.cgst_amount_minor,
                "sgst_amount_minor": line.sgst_amount_minor,
                "igst_amount_minor": line.igst_amount_minor,
                "line_total_minor": line.line_total_minor,
            }
            for line in invoice.lines
        ],
        "totals": {
            "subtotal_minor": invoice.subtotal_minor,
            "discount_total_minor": invoice.discount_total_minor,
            "taxable_total_minor": invoice.taxable_total_minor,
            "cgst_total_minor": invoice.cgst_total_minor,
            "sgst_total_minor": invoice.sgst_total_minor,
            "igst_total_minor": invoice.igst_total_minor,
            "tax_total_minor": invoice.tax_total_minor,
            "grand_total_minor": invoice.grand_total_minor,
            "paid_total_minor": invoice.paid_total_minor,
            "due_total_minor": invoice.due_total_minor,
        },
        "revision": {
            "number": invoice.revision.number,
            "status": invoice.revision.status,
            "reversed_at": (
                invoice.revision.reversed_at.isoformat() if invoice.revision.reversed_at else None
            ),
            "reversal_reason": invoice.revision.reversal_reason,
        },
    }


def _fingerprint(invoice: SaleInvoice) -> str:
    encoded = json.dumps(
        _invoice_payload(invoice), ensure_ascii=True, separators=(",", ":"), sort_keys=True
    ).encode("ascii")
    return hashlib.sha256(encoded).hexdigest()


def build_sale_invoice(sale: Sale) -> SaleInvoice:
    """Take an immutable, authorization-independent snapshot of a posted sale."""
    if sale.status not in {DocumentStatus.POSTED, DocumentStatus.REVERSED}:
        raise InvoiceNotPostable()

    lines = tuple(
        InvoiceLine(
            description=line.description,
            hsn_sac=line.hsn_sac,
            quantity=line.quantity,
            unit_price_minor=int(line.unit_price_minor),
            discount_minor=int(line.discount_minor),
            taxable_value_minor=int(line.taxable_value_minor),
            tax_rate_bps=int(line.tax_rate_bps),
            cgst_amount_minor=int(line.cgst_amount_minor),
            sgst_amount_minor=int(line.sgst_amount_minor),
            igst_amount_minor=int(line.igst_amount_minor),
            line_total_minor=int(line.line_total_minor),
        )
        for line in sorted(sale.lines.all(), key=lambda line: (line.created_at, str(line.id)))
    )
    if not lines:
        raise InvoiceDataError()

    if sale.seller_state_code and sale.buyer_state_code:
        interstate = sale.seller_state_code != sale.buyer_state_code
    else:
        interstate = any(line.igst_amount_minor for line in lines)

    invoice = SaleInvoice(
        sale_id=sale.pk,
        number=sale.number,
        document_date=sale.document_date,
        financial_year=sale.financial_year,
        posted_at=sale.posted_at,
        seller_name=sale.seller_name or sale.business.legal_name or sale.business.name,
        seller_gstin=sale.seller_gstin,
        seller_address=sale.seller_address,
        seller_state_code=sale.seller_state_code,
        buyer_name=sale.buyer_name or "Cash customer",
        buyer_gstin=sale.buyer_gstin,
        buyer_state_code=sale.buyer_state_code,
        place_of_supply=sale.place_of_supply,
        supply_type="Interstate" if interstate else "Intrastate",
        tax_inclusive=sale.tax_inclusive,
        business_timezone=sale.business.timezone,
        lines=lines,
        subtotal_minor=int(sale.subtotal_minor),
        discount_total_minor=int(sale.discount_total_minor),
        taxable_total_minor=int(sale.taxable_total_minor),
        cgst_total_minor=sum(line.cgst_amount_minor for line in lines),
        sgst_total_minor=sum(line.sgst_amount_minor for line in lines),
        igst_total_minor=sum(line.igst_amount_minor for line in lines),
        tax_total_minor=int(sale.tax_total_minor),
        grand_total_minor=int(sale.grand_total_minor),
        paid_total_minor=int(sale.paid_total_minor),
        due_total_minor=int(sale.due_total_minor),
        revision=InvoiceRevision(
            number=1,
            status=sale.status,
            is_void=sale.status == DocumentStatus.REVERSED,
            reversed_at=sale.reversed_at,
            reversal_reason=sale.reversal_reason,
            source_fingerprint="",
        ),
    )
    return replace(
        invoice,
        revision=replace(invoice.revision, source_fingerprint=_fingerprint(invoice)),
    )


def invoice_filename(invoice: SaleInvoice) -> str:
    """Build an ASCII attachment filename that cannot inject headers or paths."""
    safe_number = re.sub(r"[^A-Za-z0-9_-]+", "-", invoice.number).strip("-_")[:96]
    safe_number = safe_number or str(invoice.sale_id)
    suffix = "-void" if invoice.revision.is_void else ""
    return f"invoice-{safe_number}{suffix}.pdf"


def _paragraph_style(name: str, **values: Any) -> ParagraphStyle:
    options = {
        "fontName": "Helvetica",
        "fontSize": 8,
        "leading": 10,
        "textColor": _INK,
        "spaceBefore": 0,
        "spaceAfter": 0,
    }
    options.update(values)
    return ParagraphStyle(name, **options)


_LABEL = _paragraph_style("invoice-label", fontSize=6.5, leading=8, textColor=_MUTED)
_VALUE = _paragraph_style("invoice-value", fontSize=8, leading=10)
_SMALL = _paragraph_style("invoice-small", fontSize=7, leading=9, textColor=_MUTED)
_HEADER = _paragraph_style(
    "invoice-table-header",
    fontName="Helvetica-Bold",
    fontSize=6.1,
    leading=7.2,
    textColor=colors.white,
    alignment=TA_CENTER,
)
_CELL = _paragraph_style("invoice-cell", fontSize=6.7, leading=8.2)
_CELL_RIGHT = _paragraph_style("invoice-cell-right", fontSize=6.7, leading=8.2, alignment=TA_RIGHT)
_CELL_CENTER = _paragraph_style(
    "invoice-cell-center", fontSize=6.7, leading=8.2, alignment=TA_CENTER
)


def _text(value: Any, style: ParagraphStyle, *, markup: bool = False) -> Paragraph:
    raw = str(value)
    if any(ord(character) > 127 for character in raw):
        font_name = "DukaanSans-Bold" if style.fontName == "Helvetica-Bold" else "DukaanSans"
        style = ParagraphStyle(f"{style.name}-unicode", parent=style, fontName=font_name)
    if markup:
        return Paragraph(raw, style)
    escaped = html.escape(raw, quote=False).replace("\n", "<br/>")
    return Paragraph(escaped or "-", style)


def _format_date(value: date) -> str:
    return f"{value.day:02d} {_MONTHS[value.month - 1]} {value.year:04d}"


def _format_reversed_at(value: datetime | None, timezone_name: str) -> str:
    if value is None:
        return ""
    try:
        zone = ZoneInfo(timezone_name)
    except ZoneInfoNotFoundError:
        zone = timezone.utc
    local = timezone.localtime(value, zone) if timezone.is_aware(value) else value
    return f"{_format_date(local.date())} {local:%H:%M} {zone.key}"


def _header(invoice: SaleInvoice) -> Table:
    title = _paragraph_style(
        "invoice-title", fontName="Helvetica-Bold", fontSize=19, leading=22, textColor=colors.white
    )
    seller = _paragraph_style(
        "invoice-header-seller", fontSize=9, leading=11, textColor=colors.white
    )
    status = _paragraph_style(
        "invoice-status",
        fontName="Helvetica-Bold",
        fontSize=10,
        leading=13,
        textColor=colors.white,
        alignment=TA_CENTER,
    )
    status_subtitle = _paragraph_style(
        "invoice-status-subtitle",
        fontSize=7,
        leading=9,
        textColor=colors.white,
        alignment=TA_CENTER,
    )
    left = [
        _text("GST TAX INVOICE", title),
        Spacer(1, 3),
        _text(invoice.seller_name, seller),
    ]
    badge_text = "VOID | REVERSED" if invoice.revision.is_void else "ORIGINAL"
    right = [
        _text(badge_text, status),
        Spacer(1, 3),
        _text(f"Revision {invoice.revision.number}", status_subtitle),
    ]
    table = Table([[left, right]], colWidths=[_CONTENT_WIDTH - 142, 142])
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (0, 0), _NAVY),
                ("BACKGROUND", (1, 0), (1, 0), _RED if invoice.revision.is_void else _TEAL),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 13),
                ("RIGHTPADDING", (0, 0), (-1, -1), 13),
                ("TOPPADDING", (0, 0), (-1, -1), 12),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 12),
            ]
        )
    )
    return table


def _party_card(title: str, name: str, gstin: str, state_code: str, address: str = "") -> Table:
    heading = _paragraph_style(
        f"invoice-{title}-heading",
        fontName="Helvetica-Bold",
        fontSize=7,
        leading=9,
        textColor=_TEAL,
    )
    body = _paragraph_style(f"invoice-{title}-body", fontSize=8, leading=11)
    details = [_text(title, heading), Spacer(1, 4), _text(name, body)]
    details.extend([Spacer(1, 3), _text(f"GSTIN: {gstin or '-'}", body)])
    if address:
        details.extend([Spacer(1, 3), _text(address, body)])
    if state_code:
        details.extend([Spacer(1, 3), _text(f"State code: {state_code}", body)])
    card = Table([[details]], colWidths=[(_CONTENT_WIDTH - 13) / 2])
    card.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), _PALE),
                ("BOX", (0, 0), (-1, -1), 0.5, _LINE),
                ("LEFTPADDING", (0, 0), (-1, -1), 10),
                ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                ("TOPPADDING", (0, 0), (-1, -1), 9),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 9),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ]
        )
    )
    return card


def _parties(invoice: SaleInvoice) -> Table:
    seller = _party_card(
        "SELLER",
        invoice.seller_name,
        invoice.seller_gstin,
        invoice.seller_state_code,
        invoice.seller_address,
    )
    buyer = _party_card("BUYER", invoice.buyer_name, invoice.buyer_gstin, invoice.buyer_state_code)
    table = Table(
        [[seller, "", buyer]], colWidths=[(_CONTENT_WIDTH - 13) / 2, 13, (_CONTENT_WIDTH - 13) / 2]
    )
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
            ]
        )
    )
    return table


def _metadata(invoice: SaleInvoice) -> Table:
    rows = [
        ("INVOICE NO.", invoice.number, "INVOICE DATE", _format_date(invoice.document_date)),
        (
            "FINANCIAL YEAR",
            invoice.financial_year,
            "PLACE OF SUPPLY",
            invoice.place_of_supply or "-",
        ),
        (
            "SUPPLY TYPE",
            invoice.supply_type,
            "PRICE BASIS",
            "Tax inclusive" if invoice.tax_inclusive else "Tax exclusive",
        ),
    ]
    data = [
        [_text(row[0], _LABEL), _text(row[1], _VALUE), _text(row[2], _LABEL), _text(row[3], _VALUE)]
        for row in rows
    ]
    table = Table(data, colWidths=[76, 189, 80, _CONTENT_WIDTH - 345])
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), colors.white),
                ("BOX", (0, 0), (-1, -1), 0.5, _LINE),
                ("INNERGRID", (0, 0), (-1, -1), 0.25, _LINE),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
            ]
        )
    )
    return table


def _reversal_notice(invoice: SaleInvoice) -> Table | None:
    if not invoice.revision.is_void:
        return None
    heading = _paragraph_style(
        "invoice-void-heading", fontName="Helvetica-Bold", fontSize=9, leading=11, textColor=_RED
    )
    body = _paragraph_style("invoice-void-body", fontSize=7.5, leading=10, textColor=_RED)
    reversed_at = _format_reversed_at(invoice.revision.reversed_at, invoice.business_timezone)
    details = [
        _text("VOID DOCUMENT - REVERSED SALE", heading),
        Spacer(1, 3),
        _text(f"Reversed on: {reversed_at or '-'}", body),
        _text(f"Reason: {invoice.revision.reversal_reason or '-'}", body),
        _text("This revision is not valid for claiming input tax credit.", body),
    ]
    table = Table([[details]], colWidths=[_CONTENT_WIDTH])
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), _RED_PALE),
                ("BOX", (0, 0), (-1, -1), 0.7, _RED),
                ("LEFTPADDING", (0, 0), (-1, -1), 10),
                ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                ("TOPPADDING", (0, 0), (-1, -1), 8),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
            ]
        )
    )
    return table


def _split_tax_cell(amount_minor: int, tax_rate_bps: int) -> Paragraph:
    rate = format_half_rate_percent(tax_rate_bps) if amount_minor and tax_rate_bps else ""
    return _text(
        f"{format_money(amount_minor)}<br/><font size=5.6 color='#5F6F7F'>"
        f"{f'@ {rate}%' if rate else ''}</font>",
        _CELL_RIGHT,
        markup=True,
    )


def _igst_cell(amount_minor: int, tax_rate_bps: int) -> Paragraph:
    rate = format_rate_percent(tax_rate_bps) if amount_minor and tax_rate_bps else ""
    return _text(
        f"{format_money(amount_minor)}<br/><font size=5.6 color='#5F6F7F'>"
        f"{f'@ {rate}%' if rate else ''}</font>",
        _CELL_RIGHT,
        markup=True,
    )


def _items_table(invoice: SaleInvoice) -> LongTable:
    headers = (
        "#",
        "Description",
        "HSN / SAC",
        "Qty",
        "Rate (Rs.)",
        "Taxable (Rs.)",
        "CGST (Rs.)",
        "SGST (Rs.)",
        "IGST (Rs.)",
        "Total (Rs.)",
    )
    data: list[list[Any]] = [[_text(value, _HEADER) for value in headers]]
    for index, line in enumerate(invoice.lines, start=1):
        description = _text(line.description, _CELL)
        if line.discount_minor:
            discount = format_rupees(line.discount_minor)
            description = _text(
                f"{html.escape(line.description, quote=False)}<br/>"
                f"<font size=5.8 color='#5F6F7F'>Discount: {discount}</font>",
                _CELL,
                markup=True,
            )
        data.append(
            [
                _text(index, _CELL_CENTER),
                description,
                _text(line.hsn_sac or "-", _CELL_CENTER),
                _text(f"{line.quantity:f}", _CELL_RIGHT),
                _text(format_money(line.unit_price_minor), _CELL_RIGHT),
                _text(format_money(line.taxable_value_minor), _CELL_RIGHT),
                _split_tax_cell(line.cgst_amount_minor, line.tax_rate_bps),
                _split_tax_cell(line.sgst_amount_minor, line.tax_rate_bps),
                _igst_cell(line.igst_amount_minor, line.tax_rate_bps),
                _text(format_money(line.line_total_minor), _CELL_RIGHT),
            ]
        )
    widths = [16, 100, 38, 38, 54, 57, 47, 47, 47]
    widths.append(_CONTENT_WIDTH - sum(widths))
    table = LongTable(data, colWidths=widths, repeatRows=1, hAlign="LEFT")
    commands = [
        ("BACKGROUND", (0, 0), (-1, 0), _NAVY),
        ("BOX", (0, 0), (-1, -1), 0.5, _LINE),
        ("INNERGRID", (0, 0), (-1, -1), 0.25, _LINE),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 3),
        ("RIGHTPADDING", (0, 0), (-1, -1), 3),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]
    for row in range(2, len(data), 2):
        commands.append(("BACKGROUND", (0, row), (-1, row), _PALE))
    table.setStyle(TableStyle(commands))
    return table


def _totals_table(invoice: SaleInvoice) -> Table:
    label = _paragraph_style("invoice-total-label", fontSize=7.5, leading=9)
    value = _paragraph_style("invoice-total-value", fontSize=7.5, leading=9, alignment=TA_RIGHT)
    grand_label = _paragraph_style(
        "invoice-grand-label",
        fontName="Helvetica-Bold",
        fontSize=8.5,
        leading=10,
        textColor=colors.white,
    )
    grand_value = _paragraph_style(
        "invoice-grand-value",
        fontName="Helvetica-Bold",
        fontSize=8.5,
        leading=10,
        textColor=colors.white,
        alignment=TA_RIGHT,
    )
    due_label = _paragraph_style(
        "invoice-due-label",
        fontName="Helvetica-Bold",
        fontSize=8,
        leading=10,
        textColor=colors.white,
    )
    due_value = _paragraph_style(
        "invoice-due-value",
        fontName="Helvetica-Bold",
        fontSize=8,
        leading=10,
        textColor=colors.white,
        alignment=TA_RIGHT,
    )
    rows = [
        ("Subtotal", format_rupees(invoice.subtotal_minor), label, value),
        ("Discount", f"- {format_rupees(invoice.discount_total_minor)}", label, value),
        ("Taxable value", format_rupees(invoice.taxable_total_minor), label, value),
        ("CGST", format_rupees(invoice.cgst_total_minor), label, value),
        ("SGST", format_rupees(invoice.sgst_total_minor), label, value),
        ("IGST", format_rupees(invoice.igst_total_minor), label, value),
        ("Total GST", format_rupees(invoice.tax_total_minor), label, value),
        ("Grand total", format_rupees(invoice.grand_total_minor), grand_label, grand_value),
        ("Paid", format_rupees(invoice.paid_total_minor), label, value),
        ("Balance due", format_rupees(invoice.due_total_minor), due_label, due_value),
    ]
    data = [[_text(row[0], row[2]), _text(row[1], row[3])] for row in rows]
    table = Table(data, colWidths=[_SUMMARY_COLUMN - 99, 99], hAlign="RIGHT")
    table.setStyle(
        TableStyle(
            [
                ("BOX", (0, 0), (-1, -1), 0.5, _LINE),
                ("INNERGRID", (0, 0), (-1, -1), 0.25, _LINE),
                ("BACKGROUND", (0, 7), (-1, 7), _NAVY),
                ("BACKGROUND", (0, 9), (-1, 9), _TEAL),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 7),
                ("RIGHTPADDING", (0, 0), (-1, -1), 7),
                ("TOPPADDING", (0, 0), (-1, -1), 3.5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3.5),
            ]
        )
    )
    return table


def _summary(invoice: SaleInvoice) -> Table:
    amount_label = _paragraph_style(
        "invoice-words-label", fontName="Helvetica-Bold", fontSize=6.5, leading=8, textColor=_TEAL
    )
    amount_value = _paragraph_style("invoice-words-value", fontSize=8.5, leading=11)
    words = Table(
        [
            [_text("AMOUNT IN WORDS", amount_label)],
            [_text(amount_in_words(invoice.grand_total_minor), amount_value)],
        ],
        colWidths=[_SUMMARY_COLUMN],
    )
    words.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), _PALE),
                ("BOX", (0, 0), (-1, -1), 0.5, _LINE),
                ("LEFTPADDING", (0, 0), (-1, -1), 9),
                ("RIGHTPADDING", (0, 0), (-1, -1), 9),
                ("TOPPADDING", (0, 0), (-1, -1), 7),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
            ]
        )
    )
    gst_summary = _text(
        "<b>GST summary</b><br/>"
        f"CGST: {format_rupees(invoice.cgst_total_minor)} &nbsp; | &nbsp; "
        f"SGST: {format_rupees(invoice.sgst_total_minor)}<br/>"
        f"IGST: {format_rupees(invoice.igst_total_minor)}",
        _SMALL,
        markup=True,
    )
    left = [words, Spacer(1, 8), gst_summary]
    if invoice.revision.is_void:
        left.extend(
            [
                Spacer(1, 8),
                _text("VOID - retained only as a reversal audit document.", _SMALL),
            ]
        )
    table = Table(
        [[left, "", _totals_table(invoice)]],
        colWidths=[_SUMMARY_COLUMN, _SUMMARY_GAP, _SUMMARY_COLUMN],
    )
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
            ]
        )
    )
    return table


def _draw_page(canvas: Canvas, document: SimpleDocTemplate, invoice: SaleInvoice) -> None:
    canvas.saveState()
    if invoice.revision.is_void:
        canvas.setFillColor(_WATERMARK)
        canvas.setFont("Helvetica-Bold", 92)
        canvas.translate(_PAGE_WIDTH / 2, _PAGE_HEIGHT / 2)
        canvas.rotate(38)
        canvas.drawCentredString(0, 0, "VOID")
    canvas.setStrokeColor(_LINE)
    canvas.setLineWidth(0.5)
    canvas.line(_MARGIN, 13 * mm, _PAGE_WIDTH - _MARGIN, 13 * mm)
    canvas.setFillColor(_MUTED)
    canvas.setFont("Helvetica", 6.5)
    canvas.drawString(
        _MARGIN,
        9 * mm,
        f"DukaanAI | {invoice.number} | Revision {invoice.revision.number} | "
        f"ID {invoice.revision.source_fingerprint[:12].upper()}",
    )
    canvas.drawRightString(
        _PAGE_WIDTH - _MARGIN, 9 * mm, f"Page {document.page} | Computer-generated invoice"
    )
    canvas.restoreState()


def _render_invoice(invoice: SaleInvoice) -> bytes:
    output = BytesIO()
    document = SimpleDocTemplate(
        output,
        pagesize=A4,
        leftMargin=_MARGIN,
        rightMargin=_MARGIN,
        topMargin=13 * mm,
        bottomMargin=19 * mm,
        title=f"Tax Invoice {invoice.number}",
        author=invoice.seller_name,
        subject=f"Revision {invoice.revision.number} ({invoice.revision.status}); "
        f"source {invoice.revision.source_fingerprint}",
        creator="DukaanAI",
        invariant=1,
        pageCompression=0,
        lang="en-IN",
    )
    story = [
        _header(invoice),
        Spacer(1, 10),
        _parties(invoice),
        Spacer(1, 9),
        _metadata(invoice),
    ]
    notice = _reversal_notice(invoice)
    if notice is not None:
        story.extend([Spacer(1, 9), notice])
    story.extend(
        [
            Spacer(1, 11),
            _text("LINE ITEMS", _LABEL),
            Spacer(1, 4),
            _items_table(invoice),
            Spacer(1, 11),
            KeepTogether([_summary(invoice)]),
            Spacer(1, 9),
            _text(
                "This is a computer-generated invoice derived from the posted sale. "
                "Subject to the seller's terms and conditions.",
                _SMALL,
            ),
        ]
    )

    def draw_page(canvas: Canvas, doc: SimpleDocTemplate) -> None:
        _draw_page(canvas, doc, invoice)

    document.build(story, onFirstPage=draw_page, onLaterPages=draw_page)
    return output.getvalue()


def render_sale_invoice_pdf(sale: Sale) -> bytes:
    """Render a sale without creating or updating any database records."""
    return _render_invoice(build_sale_invoice(sale))


def render_invoice_pdf(invoice: SaleInvoice) -> bytes:
    """Render an already-authorized immutable invoice snapshot."""
    return _render_invoice(invoice)
