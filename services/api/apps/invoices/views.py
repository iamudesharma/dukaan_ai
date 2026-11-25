"""Read-only invoice downloads with sale-level and tenant-level authorization."""

from __future__ import annotations

from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import extend_schema
from rest_framework import views
from rest_framework.permissions import IsAuthenticated

from apps.operations.models import Sale
from apps.tenancy.access import require_membership
from apps.tenancy.models import Membership

from .services import build_sale_invoice, invoice_filename, render_invoice_pdf


class SaleInvoicePDFView(views.APIView):
    """Download a GST-style PDF for a sale the caller may already retrieve.

    Owners and managers use their sale/location access. Cashiers intentionally
    follow the same read policy as ``SaleViewSet``: an active membership at the
    sale's location is required, otherwise DRF returns 403. The queryset also
    limits lookup to the caller's active memberships; PostgreSQL RLS provides a
    second, database-enforced tenant boundary.
    """

    permission_classes = [IsAuthenticated]

    @extend_schema(
        operation_id="invoices_sale_pdf_retrieve",
        responses={(200, "application/pdf"): OpenApiTypes.BINARY},
    )
    def get(self, request, sale_id) -> HttpResponse:
        sales = (
            Sale.objects.select_related("business")
            .filter(
                business__memberships__user=request.user,
                business__memberships__is_active=True,
            )
            .distinct()
            .prefetch_related("lines")
        )
        sale = get_object_or_404(sales, pk=sale_id)
        require_membership(
            request.user,
            sale.business_id,
            roles=[
                Membership.Role.OWNER,
                Membership.Role.MANAGER,
                Membership.Role.CASHIER,
            ],
            location_id=sale.location_id,
        )

        invoice = build_sale_invoice(sale)
        content = render_invoice_pdf(invoice)
        response = HttpResponse(content, content_type="application/pdf")
        response["Content-Disposition"] = f'attachment; filename="{invoice_filename(invoice)}"'
        response["Cache-Control"] = "private, no-store"
        response["X-Content-Type-Options"] = "nosniff"
        return response
