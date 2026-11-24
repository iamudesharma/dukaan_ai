"""Tenant isolation for notification devices, reminders, and deliveries."""

from django.conf import settings
from django.db import migrations

from apps.tenancy import rls


def _quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def _policies():
    direct = rls.direct_policy()
    return [
        ("integrations_notificationdevice", *direct),
        ("integrations_reminder", *direct),
        (
            "integrations_notificationdelivery",
            *rls.child_policy("integrations_reminder", "reminder_id"),
        ),
    ]


def apply_notification_rls(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    role_name = getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)
    role = _quote_ident(role_name)
    role_literal = role_name.replace("'", "''")
    policies = _policies()
    for table, _, _ in policies:
        quoted = _quote_ident(table)
        schema_editor.execute(f"ALTER TABLE {quoted} ENABLE ROW LEVEL SECURITY")
        schema_editor.execute(f"ALTER TABLE {quoted} FORCE ROW LEVEL SECURITY")
    for table, using, check in policies:
        quoted = _quote_ident(table)
        schema_editor.execute(f"DROP POLICY IF EXISTS tenant_isolation ON {quoted}")
        schema_editor.execute(
            f"CREATE POLICY tenant_isolation ON {quoted} "
            f"FOR ALL TO PUBLIC USING ({using}) WITH CHECK ({check})"
        )
        schema_editor.execute(
            "DO $$ BEGIN "
            f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '{role_literal}') THEN "
            f"EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON {quoted} TO {role}'; "
            "END IF; END $$"
        )


def remove_notification_rls(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    role_name = getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)
    role = _quote_ident(role_name)
    role_literal = "'" + role_name.replace("'", "''") + "'"
    for table, _, _ in reversed(_policies()):
        quoted = _quote_ident(table)
        schema_editor.execute(f"DROP POLICY IF EXISTS tenant_isolation ON {quoted}")
        schema_editor.execute(f"ALTER TABLE {quoted} NO FORCE ROW LEVEL SECURITY")
        schema_editor.execute(f"ALTER TABLE {quoted} DISABLE ROW LEVEL SECURITY")
        schema_editor.execute(
            "DO $$ BEGIN "
            f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = {role_literal}) THEN "
            f"EXECUTE 'REVOKE ALL ON {quoted} FROM {role}'; "
            "END IF; END $$"
        )


class Migration(migrations.Migration):
    dependencies = [
        ("integrations", "0003_notificationdevice_reminder_notificationdelivery_and_more"),
        ("tenancy", "0002_row_level_security"),
    ]

    operations = [migrations.RunPython(apply_notification_rls, remove_notification_rls)]
