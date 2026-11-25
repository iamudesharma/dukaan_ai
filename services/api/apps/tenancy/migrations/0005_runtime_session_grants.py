"""Complete runtime grants for session revocation and migration checks."""

from django.conf import settings
from django.db import migrations

from apps.tenancy import rls


def apply_session_grants(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    role_name = getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)
    role = '"' + role_name.replace('"', '""') + '"'
    role_literal = "'" + role_name.replace("'", "''") + "'"
    statements = [
        f"GRANT SELECT, INSERT, UPDATE ON authentication_sessionversion TO {role};",
        f"GRANT USAGE, SELECT ON SEQUENCE authentication_sessionversion_id_seq TO {role};",
        f"GRANT SELECT ON django_migrations TO {role};",
    ]
    schema_editor.execute(
        "DO $$ BEGIN "
        f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = {role_literal}) THEN "
        f"{' '.join(statements)} "
        "END IF; END $$"
    )


def remove_session_grants(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    role_name = getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)
    role = '"' + role_name.replace('"', '""') + '"'
    role_literal = "'" + role_name.replace("'", "''") + "'"
    objects = (
        "authentication_sessionversion",
        "SEQUENCE authentication_sessionversion_id_seq",
        "django_migrations",
    )
    statements = " ".join(f"REVOKE ALL ON {obj} FROM {role};" for obj in objects)
    schema_editor.execute(
        "DO $$ BEGIN "
        f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = {role_literal}) THEN "
        f"{statements} "
        "END IF; END $$"
    )


class Migration(migrations.Migration):
    dependencies = [
        ("tenancy", "0004_invitation"),
    ]

    operations = [migrations.RunPython(apply_session_grants, remove_session_grants)]
