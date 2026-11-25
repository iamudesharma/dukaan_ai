"""Posted-sale invoice PDFs: exact money, access control, tenancy and voiding."""

from __future__ import annotations

import re
from datetime import date
from decimal import Decimal

import pytest
from conftest import rls_is_enforced
from django.apps import apps
from django.db import connection
from django.test.utils import CaptureQueriesContext
from django.urls import include, path, reverse
from django.utils import timezone
from rest_framework.test import APIClient

from apps.catalog.models import Party, Product, ProductPack
from apps.common.models import User
from apps.invoices.money import (
    amount_in_words,
    format_half_rate_percent,
    format_money,
    format_rate_percent,
    format_rupees,
)
from apps.invoices.services import (
    InvoiceDataError,
    InvoiceNotPostable,
    build_sale_invoice,
    invoice_filename,
    render_sale_invoice_pdf,
)
from apps.operations.models import DocumentStatus, Sale, SaleLine
from apps.operations.services import post_sale, reverse_sale
from apps.tenancy import rls
from apps.tenancy.models import Business, GSTRegistration, Location, Membership

pytestmark = pytest.mark.django_db

# The project URL config is outside this task's allowed edit scope. Mount the
# app exactly where production should mount it so these tests exercise the
# complete public /api/v1/invoices/sales/{sale_id}/pdf/ route.
urlpatterns = [path("api/v1/invoices/", include("apps.invoices.urls"))]


@pytest.fixture(autouse=True)
def invoice_urlconf(settings):
    settings.ROOT_URLCONF = __name__


@pytest.fixture
def gst_sale(shop):
    user, business, location, product = shop
    business.legal_name = "Nova Retail Pvt. Ltd."
    business.gst_enabled = True
    business.save(update_fields=["legal_name", "gst_enabled", "updated_at"])
    registration = GSTRegistration.objects.create(
        business=business,
        gstin="27ABCDE1234F1Z5",
        legal_name="Nova Retail Pvt. Ltd.",
        address="12 Market Road, Nashik, Maharashtra",
        state_code="27",
        invoice_prefix="NOVA",
    )
    location.gst_registration = registration
    location.state_code = "27"
    location.save(update_fields=["gst_registration", "state_code", "updated_at"])
    product.hsn_sac = "6109"
    product.tax_rate_bps = 1800
    product.save(update_fields=["hsn_sac", "tax_rate_bps", "updated_at"])
    customer = Party.objects.create(
        business=business,
        name="Ramesh Kumar",
        kind=Party.Kind.CUSTOMER,
        gstin="27BBBBB2222B2Z6",
        state_code="27",
    )
    sale, replayed = post_sale(
        {
            "business": business,
            "location": location,
            "customer": customer,
            "invoice_date": date(2026, 11, 24),
            "lines": [
                {
                    "pack": product.packs.get(),
                    "quantity": Decimal("3.000"),
                    "unit_price_minor": 80000,
                }
            ],
            "paid_amount_minor": 150000,
            "payment_method": "UPI",
            "idempotency_key": "invoice-gst-sale",
        },
        user,
    )
    assert not replayed
    return sale


def _client(user) -> APIClient:
    client = APIClient()
    client.force_authenticate(user)
    return client


def _pdf_url(sale: Sale) -> str:
    return reverse("invoices:sale-pdf", kwargs={"sale_id": sale.pk})


def _decode_pdf_literal(value: bytes) -> str:
    escapes = {
        b"n": b"\n",
        b"r": b"\r",
        b"t": b"\t",
        b"b": b"\b",
        b"f": b"\f",
        b"(": b"(",
        b")": b")",
        b"\\": b"\\",
    }

    def replace(match: re.Match[bytes]) -> bytes:
        token = match.group(1)
        if re.fullmatch(rb"[0-7]{1,3}", token):
            return chr(int(token, 8)).encode("latin-1")
        return escapes.get(token, token)

    return re.sub(rb"\\([0-7]{1,3}|.)", replace, value).decode("latin-1")


def _pdf_text(content: bytes) -> str:
    """Extract text from ReportLab's deliberately uncompressed content streams."""
    literals = []
    for stream in re.findall(rb"stream\r?\n(.*?)endstream", content, re.DOTALL):
        if b"BT" not in stream:
            continue
        literals.extend(
            _decode_pdf_literal(value) for value in re.findall(rb"\(((?:\\.|[^\\)])*)\)", stream)
        )
    return re.sub(r"\s+", " ", " ".join(literals))


@pytest.mark.parametrize(
    ("paise", "expected"),
    [
        (0, "0.00"),
        (1, "0.01"),
        (101, "1.01"),
        (-1, "-0.01"),
        (240000, "2,400.00"),
        (10_000_000_000_000_001, "100,000,000,000,000.01"),
    ],
)
def test_money_is_rendered_from_integer_paise(paise, expected):
    assert format_money(paise) == expected


def test_money_words_and_rates_are_exact():
    assert format_rupees(-1) == "-Rs. 0.01"
    assert format_rate_percent(1800) == "18"
    assert format_half_rate_percent(1800) == "9"
    assert format_half_rate_percent(181) == "0.905"
    assert amount_in_words(0) == "Zero Rupees Only"
    assert amount_in_words(10_000_001) == "One Lakh Rupees and One Paise Only"


def test_owner_pdf_contains_gst_invoice_content_and_signature(shop, gst_sale):
    response = _client(shop[0]).get(_pdf_url(gst_sale))

    assert response.status_code == 200
    assert response["Content-Type"] == "application/pdf"
    assert response["Cache-Control"] == "private, no-store"
    assert response["X-Content-Type-Options"] == "nosniff"
    assert response["Content-Disposition"] == (
        f'attachment; filename="{invoice_filename(build_sale_invoice(gst_sale))}"'
    )
    content = response.content
    assert content.startswith(b"%PDF-")
    assert content.rstrip().endswith(b"%%EOF")
    assert re.search(rb"/MediaBox \[\s*0\s+0\s+595\.2756\s+841\.8898\s*\]", content)

    text = _pdf_text(content)
    for expected in (
        "GST TAX INVOICE",
        "ORIGINAL",
        "Revision 1",
        "Nova Retail Pvt. Ltd.",
        "27ABCDE1234F1Z5",
        "12 Market Road, Nashik, Maharashtra",
        "Ramesh Kumar",
        "27BBBBB2222B2Z6",
        gst_sale.number,
        "24 Nov 2026",
        "2026-27",
        "Intrastate",
        "SELLER",
        "BUYER",
        "LINE ITEMS",
        "shirt",
        "6109",
        "3.000",
        "800.00",
        "2,400.00",
        "216.00",
        "CGST",
        "SGST",
        "IGST",
        "@ 9%",
        "2,832.00",
        "1,500.00",
        "1,332.00",
        "AMOUNT IN WORDS",
        "Two Thousand Eight Hundred Thirty Two Rupees Only",
    ):
        assert expected in text, expected


def test_hindi_party_and_product_text_uses_embedded_unicode_font(shop, gst_sale):
    user, business, location, product = shop
    product.name = "शर्ट"
    product.save(update_fields=["name", "updated_at"])
    customer = gst_sale.customer
    customer.name = "रमेश कुमार"
    customer.save(update_fields=["name", "updated_at"])
    sale, replayed = post_sale(
        {
            "business": business,
            "location": location,
            "customer": customer,
            "invoice_date": date(2026, 11, 24),
            "lines": [
                {
                    "pack": product.packs.get(),
                    "quantity": Decimal("1.000"),
                    "unit_price_minor": 80000,
                }
            ],
            "paid_amount_minor": 80000,
            "payment_method": "CASH",
            "idempotency_key": "invoice-hindi-sale",
        },
        user,
    )
    assert not replayed

    response = _client(user).get(_pdf_url(sale))

    assert response.status_code == 200
    assert re.search(rb"/BaseFont /[A-Z]{6}\+NotoSansDevanagari-Regular", response.content)
    invoice = build_sale_invoice(sale)
    assert invoice.buyer_name == "रमेश कुमार"
    assert invoice.lines[0].description == "शर्ट"


def test_interstate_sale_renders_igst_instead_of_split_gst(shop, gst_sale):
    user, business, location, product = shop
    customer = gst_sale.customer
    customer.state_code = "09"
    customer.save(update_fields=["state_code", "updated_at"])
    interstate, _ = post_sale(
        {
            "business": business,
            "location": location,
            "customer": customer,
            "invoice_date": date(2026, 11, 24),
            "lines": [
                {
                    "pack": product.packs.get(),
                    "quantity": Decimal("3.000"),
                    "unit_price_minor": 80000,
                }
            ],
            "idempotency_key": "invoice-interstate-sale",
        },
        user,
    )

    response = _client(user).get(_pdf_url(interstate))
    assert response.status_code == 200
    text = _pdf_text(response.content)
    assert "Interstate" in text
    assert "432.00" in text
    assert "@ 18%" in text
    line = interstate.lines.get()
    assert (line.cgst_amount_minor, line.sgst_amount_minor, line.igst_amount_minor) == (
        0,
        0,
        43200,
    )


def test_manager_and_cashier_follow_sale_location_read_access(shop, gst_sale):
    user, business, location, _ = shop
    membership = Membership.objects.get(user=user, business=business)
    for role in (Membership.Role.MANAGER, Membership.Role.CASHIER):
        membership.role = role
        membership.save(update_fields=["role", "updated_at"])
        membership.locations.add(location)
        assert _client(user).get(_pdf_url(gst_sale)).status_code == 200


@pytest.mark.parametrize("role", [Membership.Role.MANAGER, Membership.Role.CASHIER])
def test_role_without_sale_location_access_gets_403(shop, gst_sale, role):
    user, business, location, _ = shop
    other_location = Location.objects.create(
        business=business, code="OTHER", name="Other branch", is_active=True
    )
    membership = Membership.objects.get(user=user, business=business)
    membership.role = role
    membership.save(update_fields=["role", "updated_at"])
    membership.locations.set([other_location])

    response = _client(user).get(_pdf_url(gst_sale))
    assert response.status_code == 403
    assert location.pk != other_location.pk


def test_inactive_member_and_anonymous_user_cannot_download(shop, gst_sale):
    user = shop[0]
    Membership.objects.filter(user=user).update(is_active=False)
    assert _client(user).get(_pdf_url(gst_sale)).status_code == 404
    assert APIClient().get(_pdf_url(gst_sale)).status_code == 401


def _other_tenant_sale() -> tuple[User, Sale]:
    owner = User.objects.create_user(username="invoice-other-owner")
    business = Business.objects.create(name="Other Tenant")
    location = Location.objects.create(business=business, code="MAIN", name="Main")
    Membership.objects.create(user=owner, business=business, role=Membership.Role.OWNER)
    product = Product.objects.create(business=business, name="Foreign item", hsn_sac="9999")
    pack = ProductPack.objects.create(
        product=product,
        name="piece",
        conversion_factor=1,
        retail_price_minor=12345,
        wholesale_price_minor=12345,
    )
    sale = Sale.objects.create(
        business=business,
        location=location,
        status=DocumentStatus.POSTED,
        number="OTHER/2026-27/000001",
        financial_year="2026-27",
        sequence_number=1,
        document_date=date(2026, 11, 24),
        posted_at=timezone.now(),
        created_by=owner,
        idempotency_key="other-tenant-invoice",
        seller_name="Other Tenant",
        buyer_name="Foreign Buyer",
        subtotal_minor=12345,
        taxable_total_minor=12345,
        grand_total_minor=12345,
        due_total_minor=12345,
    )
    SaleLine.objects.create(
        sale=sale,
        product=product,
        pack=pack,
        description="Foreign item",
        hsn_sac="9999",
        quantity=Decimal("1.000"),
        conversion_factor=1,
        base_quantity=Decimal("1.000"),
        unit_price_minor=12345,
        taxable_value_minor=12345,
        line_total_minor=12345,
    )
    return owner, sale


def test_cross_tenant_lookup_is_hidden_and_rls_remains_enforced(shop, gst_sale):
    other_owner, other_sale = _other_tenant_sale()

    response = _client(other_owner).get(_pdf_url(gst_sale))
    assert response.status_code == 404
    assert b"Nova Retail" not in response.content
    assert _client(shop[0]).get(_pdf_url(other_sale)).status_code == 404

    if rls_is_enforced(connection):
        rls.establish_scope(connection, other_owner)
        try:
            assert not Sale.objects.filter(pk=gst_sale.pk).exists()
        finally:
            rls.set_staff_scope(connection)


def test_reversed_sale_is_watermarked_and_marked_void(shop, gst_sale):
    reverse_sale(
        gst_sale,
        shop[0],
        reason="Duplicate customer request",
        idempotency_key="invoice-reverse-sale",
    )
    gst_sale.refresh_from_db()

    response = _client(shop[0]).get(_pdf_url(gst_sale))
    assert response.status_code == 200
    assert response["Content-Disposition"].endswith('-void.pdf"')
    text = _pdf_text(response.content)
    assert "VOID | REVERSED" in text
    assert "VOID DOCUMENT - REVERSED SALE" in text
    assert "Duplicate customer request" in text
    assert "not valid for claiming input tax credit" in text
    assert "VOID" in text
    assert build_sale_invoice(gst_sale).revision.is_void is True


def test_draft_or_incomplete_sale_cannot_be_rendered(shop, gst_sale):
    gst_sale.status = DocumentStatus.DRAFT
    gst_sale.save(update_fields=["status", "updated_at"])
    assert _client(shop[0]).get(_pdf_url(gst_sale)).status_code == 409
    with pytest.raises(InvoiceNotPostable):
        render_sale_invoice_pdf(gst_sale)

    gst_sale.status = DocumentStatus.POSTED
    gst_sale.save(update_fields=["status", "updated_at"])
    gst_sale.lines.all().delete()
    assert _client(shop[0]).get(_pdf_url(gst_sale)).status_code == 409
    with pytest.raises(InvoiceDataError):
        render_sale_invoice_pdf(gst_sale)


def test_repeated_download_is_deterministic_and_creates_no_invoice_ledger(shop, gst_sale):
    client = _client(shop[0])
    before = {
        model: model.objects.count()
        for model in (Sale, SaleLine, apps.get_model("operations", "PartyLedgerEntry"))
    }

    with CaptureQueriesContext(connection) as queries:
        first = client.get(_pdf_url(gst_sale))
    second = client.get(_pdf_url(gst_sale))

    assert first.status_code == second.status_code == 200
    assert first.content == second.content
    writes = [
        query["sql"]
        for query in queries
        if re.match(r"\s*(INSERT|UPDATE|DELETE)\b", query["sql"], re.IGNORECASE)
    ]
    assert writes == []
    assert {model: model.objects.count() for model in before} == before
    assert list(apps.get_app_config("invoices").get_models()) == []


def test_content_disposition_filename_is_header_and_path_safe(shop, gst_sale):
    gst_sale.number = 'INV"\r\nX-Injected: yes/..\\unsafe'
    gst_sale.save(update_fields=["number", "updated_at"])

    response = _client(shop[0]).get(_pdf_url(gst_sale))
    assert response.status_code == 200
    filename = (
        response["Content-Disposition"].removeprefix('attachment; filename="').removesuffix('"')
    )
    assert re.fullmatch(r"[A-Za-z0-9._-]+", filename)
    assert filename.endswith(".pdf")
    assert "\r" not in filename
    assert "\n" not in filename
    assert "/" not in filename
    assert "\\" not in filename
