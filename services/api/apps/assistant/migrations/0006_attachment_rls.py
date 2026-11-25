"""Tenant isolation for the attachment table.

Mirrors ``tenancy.0002_row_level_security`` for the one table that migration
predates: FORCE RLS plus the standard direct-tenant policy, and DML grants
for the least-privilege application role when it exists.
"""

from django.conf import settings
from django.db import migrations

from apps.tenancy import rls

TABLE = "assistant_attachment"


def _app_role() -> str:
    return getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)


def _quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def apply_attachment_rls(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    quoted = _quote_ident(TABLE)
    using, check = rls.direct_policy()
    schema_editor.execute(f"ALTER TABLE {quoted} ENABLE ROW LEVEL SECURITY")
    schema_editor.execute(f"ALTER TABLE {quoted} FORCE ROW LEVEL SECURITY")
    schema_editor.execute(f"DROP POLICY IF EXISTS tenant_isolation ON {quoted}")
    schema_editor.execute(
        f"CREATE POLICY tenant_isolation ON {quoted} "
        f"FOR ALL TO PUBLIC USING ({using}) WITH CHECK ({check})"
    )
    role = _quote_ident(_app_role())
    schema_editor.execute(
        "DO $$ BEGIN "
        f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '{_app_role()}') THEN "
        f"EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON {quoted} TO {role}'; "
        "END IF; END $$"
    )


def remove_attachment_rls(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    quoted = _quote_ident(TABLE)
    role = _quote_ident(_app_role())
    schema_editor.execute(f"DROP POLICY IF EXISTS tenant_isolation ON {quoted}")
    schema_editor.execute(f"ALTER TABLE {quoted} NO FORCE ROW LEVEL SECURITY")
    schema_editor.execute(f"ALTER TABLE {quoted} DISABLE ROW LEVEL SECURITY")
    schema_editor.execute(f"REVOKE ALL ON {quoted} FROM {role}")


class Migration(migrations.Migration):
    dependencies = [
        ("assistant", "0005_attachment"),
    ]

    operations = [migrations.RunPython(apply_attachment_rls, remove_attachment_rls)]
