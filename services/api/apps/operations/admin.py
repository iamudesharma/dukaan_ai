from django.contrib import admin

from .models import (
    DocumentSequence,
    Expense,
    InventoryCostLayer,
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

admin.site.register(
    [
        DocumentSequence,
        Sale,
        SaleLine,
        Purchase,
        PurchaseLine,
        Payment,
        PaymentAllocation,
        Expense,
        StockBalance,
        InventoryCostLayer,
        StockMovement,
        PartyLedgerEntry,
        StockTransfer,
        StockTransferLine,
    ]
)
