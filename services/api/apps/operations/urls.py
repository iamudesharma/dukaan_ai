from django.urls import path
from rest_framework.routers import DefaultRouter

from .phase3_views import (
    ActivityView,
    AttachmentDetailView,
    ExportDetailView,
    ExportListCreateView,
    ReminderDetailView,
    ReminderListCreateView,
    ReminderSuggestionsView,
    SaleInvoiceView,
)
from .views import (
    DashboardView,
    DayBookView,
    ExpenseViewSet,
    GstReportView,
    OpeningBalanceView,
    PartyBalancesView,
    PartyLedgerReportView,
    PaymentViewSet,
    PurchaseReportView,
    PurchaseViewSet,
    ReportExportView,
    SalesReportView,
    SaleViewSet,
    StockAdjustmentView,
    StockMovementListView,
    StockReportView,
    StockValuationView,
    TransferViewSet,
)

router = DefaultRouter()
router.register("sales", SaleViewSet, basename="sale")
router.register("purchases", PurchaseViewSet, basename="purchase")
router.register("payments", PaymentViewSet, basename="payment")
router.register("expenses", ExpenseViewSet, basename="expense")
router.register("transfers", TransferViewSet, basename="transfer")

urlpatterns = [
    path("stock/adjustments/", StockAdjustmentView.as_view(), name="stock-adjustment"),
    path("stock/movements/", StockMovementListView.as_view(), name="stock-movements"),
    path("party-ledger/opening-balances/", OpeningBalanceView.as_view(), name="opening-balance"),
    path("reports/dashboard/", DashboardView.as_view(), name="dashboard"),
    path("reports/day-book/", DayBookView.as_view(), name="day-book"),
    path("reports/sales/", SalesReportView.as_view(), name="sales-report"),
    path("reports/purchases/", PurchaseReportView.as_view(), name="purchase-report"),
    path("reports/gst/", GstReportView.as_view(), name="gst-report"),
    path("reports/party-balances/", PartyBalancesView.as_view(), name="party-balances"),
    path("reports/stock/", StockReportView.as_view(), name="stock-report"),
    path("reports/stock-valuation/", StockValuationView.as_view(), name="stock-valuation"),
    path("reports/party-ledger/", PartyLedgerReportView.as_view(), name="party-ledger-report"),
    path("reports/export/", ReportExportView.as_view(), name="report-export"),
    path("activity/", ActivityView.as_view(), name="activity"),
    path("reminders/", ReminderListCreateView.as_view(), name="reminders"),
    path("reminders/suggestions/", ReminderSuggestionsView.as_view(), name="reminder-suggestions"),
    path("reminders/<uuid:pk>/", ReminderDetailView.as_view(), name="reminder-detail"),
    path("exports/", ExportListCreateView.as_view(), name="exports"),
    path("exports/<uuid:pk>/", ExportDetailView.as_view(), name="export-detail"),
    path("sales/<uuid:pk>/invoice/", SaleInvoiceView.as_view(), name="sale-invoice"),
    path("attachments/<uuid:pk>/", AttachmentDetailView.as_view(), name="attachment-detail"),
] + router.urls
