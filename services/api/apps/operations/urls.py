from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import (
    DashboardView,
    ExpenseViewSet,
    OpeningBalanceView,
    PartyLedgerReportView,
    PaymentViewSet,
    PurchaseViewSet,
    SaleViewSet,
    StockAdjustmentView,
    StockReportView,
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
    path("party-ledger/opening-balances/", OpeningBalanceView.as_view(), name="opening-balance"),
    path("reports/dashboard/", DashboardView.as_view(), name="dashboard"),
    path("reports/stock/", StockReportView.as_view(), name="stock-report"),
    path("reports/party-ledger/", PartyLedgerReportView.as_view(), name="party-ledger-report"),
] + router.urls
