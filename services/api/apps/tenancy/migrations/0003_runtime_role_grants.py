"""Grant the runtime role access to non-tenant identity/auth tables.

Tenant tables and their RLS policies are handled by ``0002_row_level_security``
(and the attachment/integration follow-up migrations). The API also needs a
small set of global tables for identity bootstrap, OTP, token revocation, and
user-owned Gmail connections. Keep those grants separate from schema ownership
so runtime services never receive DDL privileges.
"""

from django.conf import settings
from django.db import migrations

from apps.tenancy import rls

TABLE_GRANTS = {
    "common_user": "SELECT, INSERT, UPDATE",
    "authentication_phoneotp": "SELECT, INSERT, UPDATE, DELETE",
    "authentication_blacklistedtoken": "SELECT, INSERT",
    "integrations_gmailconnection": "SELECT, INSERT, UPDATE, DELETE",
}
SEQUENCE_GRANTS = (
    "authentication_phoneotp_id_seq",
    "authentication_blacklistedtoken_id_seq",
)


def _role_sql() -> str:
    role_name = getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)
    role = '"' + role_name.replace('"', '""') + '"'
    role_literal = "'" + role_name.replace("'", "''") + "'"
    return role, role_literal


def apply_runtime_grants(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    role, role_literal = _role_sql()
    statements = [
        f"GRANT {privileges} ON {table} TO {role};" for table, privileges in TABLE_GRANTS.items()
    ]
    statements.extend(
        f"GRANT USAGE, SELECT ON SEQUENCE {sequence} TO {role};" for sequence in SEQUENCE_GRANTS
    )
    schema_editor.execute(
        "DO $$ BEGIN "
        f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = {role_literal}) THEN "
        f"{' '.join(statements)} "
        "END IF; END $$"
    )


def remove_runtime_grants(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    role, role_literal = _role_sql()
    objects = [*TABLE_GRANTS, *(f"SEQUENCE {sequence}" for sequence in SEQUENCE_GRANTS)]
    statements = [f"REVOKE ALL ON {obj} FROM {role};" for obj in objects]
    schema_editor.execute(
        "DO $$ BEGIN "
        f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = {role_literal}) THEN "
        f"{' '.join(statements)} "
        "END IF; END $$"
    )


class Migration(migrations.Migration):
    dependencies = [
        ("authentication", "0001_initial"),
        ("integrations", "0001_initial"),
        ("tenancy", "0002_row_level_security"),
    ]

    operations = [migrations.RunPython(apply_runtime_grants, remove_runtime_grants)]
