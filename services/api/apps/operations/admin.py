from django.contrib import admin

from .models import (
    DocumentSequence,
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
        StockMovement,
        PartyLedgerEntry,
        StockTransfer,
        StockTransferLine,
    ]
)
