from decimal import ROUND_HALF_UP, Decimal

import django.core.validators
from django.db import migrations, models


def _minor(value) -> int:
    return int((Decimal(str(value)) * 100).to_integral_value(rounding=ROUND_HALF_UP))


def copy_tax_rates(apps, schema_editor):
    product = apps.get_model("catalog", "Product")
    for row in product.objects.all().iterator():
        row.tax_rate_bps = _minor(row.tax_rate)
        row.save(update_fields=["tax_rate_bps"])


def copy_pack_prices(apps, schema_editor):
    pack = apps.get_model("catalog", "ProductPack")
    for row in pack.objects.all().iterator():
        row.retail_price_minor = _minor(row.retail_price)
        row.wholesale_price_minor = _minor(row.wholesale_price)
        row.save(update_fields=["retail_price_minor", "wholesale_price_minor"])


def noop(apps, schema_editor):
    pass


class Migration(migrations.Migration):
    dependencies = [("catalog", "0002_initial")]

    operations = [
        migrations.AddField(
            model_name="product",
            name="tax_rate_bps",
            field=models.PositiveIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="productpack",
            name="retail_price_minor",
            field=models.BigIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="productpack",
            name="wholesale_price_minor",
            field=models.BigIntegerField(default=0),
        ),
        migrations.RunPython(copy_tax_rates, noop),
        migrations.RunPython(copy_pack_prices, noop),
        migrations.RemoveField(model_name="product", name="tax_rate"),
        migrations.RemoveField(model_name="productpack", name="retail_price"),
        migrations.RemoveField(model_name="productpack", name="wholesale_price"),
        migrations.AlterField(
            model_name="product",
            name="tax_rate_bps",
            field=models.PositiveIntegerField(
                default=0,
                validators=[
                    django.core.validators.MinValueValidator(0),
                    django.core.validators.MaxValueValidator(10000),
                ],
            ),
        ),
        migrations.AlterField(
            model_name="productpack",
            name="retail_price_minor",
            field=models.BigIntegerField(validators=[django.core.validators.MinValueValidator(0)]),
        ),
        migrations.AlterField(
            model_name="productpack",
            name="wholesale_price_minor",
            field=models.BigIntegerField(validators=[django.core.validators.MinValueValidator(0)]),
        ),
    ]
