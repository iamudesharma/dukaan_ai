from django.contrib import admin

from .models import (
    Attachment,
    DocumentSequence,
    Expense,
    ExportJob,
    PartyLedgerEntry,
    Payment,
    PaymentAllocation,
    Purchase,
    PurchaseLine,
    Reminder,
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
        Reminder,
        ExportJob,
        Attachment,
    ]
)
