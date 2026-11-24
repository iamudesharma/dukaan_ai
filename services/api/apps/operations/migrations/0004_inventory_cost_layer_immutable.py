"""Database-enforced append-only inventory valuation postings."""

from django.db import migrations

TRIGGER = "inventory_cost_layer_immutable"
FUNCTION = "operations_inventorycostlayer_prevent_mutation"
TABLE = "operations_inventorycostlayer"


def apply_immutable_trigger(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    schema_editor.execute(
        f"""
        CREATE OR REPLACE FUNCTION {FUNCTION}() RETURNS trigger
        LANGUAGE plpgsql AS $$
        BEGIN
            RAISE EXCEPTION 'Inventory cost layers are immutable';
        END;
        $$;
        """
    )
    schema_editor.execute(f"DROP TRIGGER IF EXISTS {TRIGGER} ON {TABLE}")
    schema_editor.execute(
        f"CREATE TRIGGER {TRIGGER} BEFORE UPDATE OR DELETE ON {TABLE} "
        f"FOR EACH ROW EXECUTE FUNCTION {FUNCTION}()"
    )


def remove_immutable_trigger(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    schema_editor.execute(f"DROP TRIGGER IF EXISTS {TRIGGER} ON {TABLE}")
    schema_editor.execute(f"DROP FUNCTION IF EXISTS {FUNCTION}()")


class Migration(migrations.Migration):
    dependencies = [
        ("operations", "0003_saleline_cogs_minor_saleline_costing_complete_and_more"),
    ]

    operations = [
        migrations.RunPython(apply_immutable_trigger, remove_immutable_trigger),
    ]
