from decimal import ROUND_HALF_UP, Decimal

import django.core.validators
from django.db import migrations, models


def _minor(value) -> int:
    return int((Decimal(str(value)) * 100).to_integral_value(rounding=ROUND_HALF_UP))


DOCUMENT_TOTALS = [
    "subtotal",
    "discount_total",
    "taxable_total",
    "tax_total",
    "grand_total",
    "paid_total",
    "due_total",
]

LINE_MONEY = [
    "discount",
    "taxable_value",
    "cgst_amount",
    "sgst_amount",
    "igst_amount",
    "line_total",
]

LINE_PRICE = {"saleline": "unit_price", "purchaseline": "unit_cost"}

BPS_VALIDATORS = [
    django.core.validators.MinValueValidator(0),
    django.core.validators.MaxValueValidator(10000),
]


def copy_documents(apps, schema_editor):
    for name in ("Sale", "Purchase"):
        model = apps.get_model("operations", name)
        for row in model.objects.all().iterator():
            updates = {f"{field}_minor": _minor(getattr(row, field)) for field in DOCUMENT_TOTALS}
            for field, value in updates.items():
                setattr(row, field, value)
            row.save(update_fields=list(updates))


def copy_lines(apps, schema_editor):
    for model_name, price_field in (
        ("SaleLine", "unit_price"),
        ("PurchaseLine", "unit_cost"),
    ):
        model = apps.get_model("operations", model_name)
        for row in model.objects.all().iterator():
            updates = {f"{price_field}_minor": _minor(getattr(row, price_field))}
            updates.update({f"{field}_minor": _minor(getattr(row, field)) for field in LINE_MONEY})
            updates["tax_rate_bps"] = _minor(row.tax_rate)
            for field, value in updates.items():
                setattr(row, field, value)
            row.save(update_fields=list(updates))


def copy_simple_amounts(apps, schema_editor):
    for name, fields in (
        ("Payment", ["amount"]),
        ("PaymentAllocation", ["amount"]),
        ("Expense", ["amount", "tax_amount", "total"]),
        ("PartyLedgerEntry", ["amount"]),
    ):
        model = apps.get_model("operations", name)
        for row in model.objects.all().iterator():
            updates = {f"{field}_minor": _minor(getattr(row, field)) for field in fields}
            for field, value in updates.items():
                setattr(row, field, value)
            row.save(update_fields=list(updates))


def noop(apps, schema_editor):
    pass


def _with_default(model_name, name, default=0):
    return migrations.AddField(
        model_name=model_name, name=name, field=models.BigIntegerField(default=default)
    )


def _without_default(model_name, name):
    return migrations.AddField(model_name=model_name, name=name, field=models.BigIntegerField())


class Migration(migrations.Migration):
    dependencies = [("operations", "0001_initial")]

    operations = [
        *[_with_default("sale", f"{field}_minor") for field in DOCUMENT_TOTALS],
        *[_with_default("purchase", f"{field}_minor") for field in DOCUMENT_TOTALS],
        _without_default("saleline", "unit_price_minor"),
        _without_default("purchaseline", "unit_cost_minor"),
        _with_default("saleline", "discount_minor"),
        _without_default("saleline", "taxable_value_minor"),
        migrations.AddField(
            model_name="saleline",
            name="tax_rate_bps",
            field=models.PositiveIntegerField(default=0),
        ),
        *[_with_default("saleline", f"{field}_minor") for field in LINE_MONEY[2:5]],
        _without_default("saleline", "line_total_minor"),
        _with_default("purchaseline", "discount_minor"),
        _without_default("purchaseline", "taxable_value_minor"),
        migrations.AddField(
            model_name="purchaseline",
            name="tax_rate_bps",
            field=models.PositiveIntegerField(default=0),
        ),
        *[_with_default("purchaseline", f"{field}_minor") for field in LINE_MONEY[2:5]],
        _without_default("purchaseline", "line_total_minor"),
        _without_default("payment", "amount_minor"),
        _without_default("paymentallocation", "amount_minor"),
        _without_default("expense", "amount_minor"),
        _with_default("expense", "tax_amount_minor"),
        _without_default("expense", "total_minor"),
        _without_default("partyledgerentry", "amount_minor"),
        migrations.RunPython(copy_documents, noop),
        migrations.RunPython(copy_lines, noop),
        migrations.RunPython(copy_simple_amounts, noop),
        *[migrations.RemoveField(model_name="sale", name=field) for field in DOCUMENT_TOTALS],
        *[migrations.RemoveField(model_name="purchase", name=field) for field in DOCUMENT_TOTALS],
        migrations.RemoveField(model_name="saleline", name="unit_price"),
        migrations.RemoveField(model_name="purchaseline", name="unit_cost"),
        *[
            migrations.RemoveField(model_name="saleline", name=field)
            for field in [*LINE_MONEY, "tax_rate"]
        ],
        *[
            migrations.RemoveField(model_name="purchaseline", name=field)
            for field in [*LINE_MONEY, "tax_rate"]
        ],
        migrations.RemoveField(model_name="payment", name="amount"),
        migrations.RemoveField(model_name="paymentallocation", name="amount"),
        migrations.RemoveField(model_name="expense", name="amount"),
        migrations.RemoveField(model_name="expense", name="tax_amount"),
        migrations.RemoveField(model_name="expense", name="total"),
        migrations.RemoveField(model_name="partyledgerentry", name="amount"),
        migrations.AlterField(
            model_name="saleline",
            name="tax_rate_bps",
            field=models.PositiveIntegerField(default=0, validators=BPS_VALIDATORS),
        ),
        migrations.AlterField(
            model_name="purchaseline",
            name="tax_rate_bps",
            field=models.PositiveIntegerField(default=0, validators=BPS_VALIDATORS),
        ),
    ]
