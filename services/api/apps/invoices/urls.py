from django.urls import path

from .views import SaleInvoicePDFView

app_name = "invoices"

# Mount at ``api/v1/invoices/`` in the project URL configuration.
urlpatterns = [
    path(
        "sales/<uuid:sale_id>/pdf/",
        SaleInvoicePDFView.as_view(),
        name="sale-pdf",
    ),
]
