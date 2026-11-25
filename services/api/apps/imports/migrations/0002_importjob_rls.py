"""Tenant isolation for normalized CSV import snapshots."""

from django.conf import settings
from django.db import migrations

from apps.tenancy import rls

TABLE = "imports_importjob"


def _quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def apply_importjob_rls(apps, schema_editor):
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
    role_name = getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)
    role = _quote_ident(role_name)
    role_literal = "'" + role_name.replace("'", "''") + "'"
    schema_editor.execute(
        "DO $$ BEGIN "
        f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = {role_literal}) THEN "
        f"EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON {quoted} TO {role}'; "
        "END IF; END $$"
    )


def remove_importjob_rls(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    quoted = _quote_ident(TABLE)
    role_name = getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)
    role = _quote_ident(role_name)
    role_literal = "'" + role_name.replace("'", "''") + "'"
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
        ("imports", "0001_initial"),
        ("tenancy", "0002_row_level_security"),
    ]

    operations = [migrations.RunPython(apply_importjob_rls, remove_importjob_rls)]
