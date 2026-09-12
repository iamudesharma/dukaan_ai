from django.urls import path
from rest_framework.routers import DefaultRouter

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
] + router.urls
