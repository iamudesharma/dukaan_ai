"""Enforce tenant isolation at the database layer.

Uses ``FORCE ROW LEVEL SECURITY`` so policies apply to table owners as well
as the application role: every Postgres connection must carry a request
scope (``app.current_user_id`` + ``app.business_ids``) set from
server-verified values before touching tenant rows. Verified on PostgreSQL
18: without scope a connection sees zero tenant rows, and wrong-scope
writes are rejected by the database.

The application role (``DUKAAN_APP_DB_ROLE``, default ``dukaan_app``)
receives DML privileges on tenant tables but can only see rows in its
request scope. Table ownership and DDL stay with the migration role.
``common_user`` (identity bootstrap anchor) and ``django_session`` (random
keys only) are intentionally outside RLS — see apps.tenancy.rls.
"""

from django.conf import settings
from django.db import migrations

from apps.tenancy import rls


def _app_role() -> str:
    return getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)


def _quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def _policies():
    statements = []
    for table in rls.DIRECT_TABLES:
        if table == "tenancy_outboxevent":
            using, check = rls.outbox_policy()
        else:
            using, check = rls.direct_policy()
        statements.append((table, using, check))
    business_using, business_check = rls.business_policy()
    statements.append(("tenancy_business", business_using, business_check))
    membership_using, membership_check = rls.membership_policy()
    # tenancy_membership is already in DIRECT_TABLES; replace its policy.
    statements = [
        (table, using, check)
        if table != "tenancy_membership"
        else (table, membership_using, membership_check)
        for table, using, check in statements
    ]
    for child, parent, fk in rls.CHILD_TABLES:
        using, check = rls.child_policy(parent, fk)
        statements.append((child, using, check))
    return statements


def apply_rls(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    role = _quote_ident(_app_role())
    tables = [table for table, _, _ in _policies()]
    for table in tables:
        quoted = _quote_ident(table)
        schema_editor.execute(f"ALTER TABLE {quoted} ENABLE ROW LEVEL SECURITY")
        schema_editor.execute(f"ALTER TABLE {quoted} FORCE ROW LEVEL SECURITY")
    for table, using, check in _policies():
        quoted = _quote_ident(table)
        schema_editor.execute(f"DROP POLICY IF EXISTS tenant_isolation ON {quoted}")
        schema_editor.execute(
            f"CREATE POLICY tenant_isolation ON {quoted} "
            f"FOR ALL TO PUBLIC USING ({using}) WITH CHECK ({check})"
        )
    # Least-privilege grants for deployments that run the API as a dedicated
    # role. Skipped when the role does not exist (single-role deployments
    # rely on the TO PUBLIC policies plus request scope instead).
    grants = ", ".join(_quote_ident(table) for table in tables)
    schema_editor.execute(
        "DO $$ DECLARE r record; BEGIN "
        f"IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '{_app_role()}') THEN "
        f"EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON {grants} TO {role}'; "
        "FOR r IN SELECT c.oid::regclass AS seq FROM pg_class c "
        "JOIN pg_namespace n ON n.oid = c.relnamespace "
        "WHERE c.relkind = 'S' LOOP "
        f"EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %%s TO {role}', r.seq); "
        "END LOOP; END IF; END $$"
    )


def remove_rls(apps, schema_editor):
    if schema_editor.connection.vendor != "postgresql":
        return
    role = _quote_ident(_app_role())
    tables = [table for table, _, _ in _policies()]
    for table in tables:
        quoted = _quote_ident(table)
        schema_editor.execute(f"DROP POLICY IF EXISTS tenant_isolation ON {quoted}")
        schema_editor.execute(f"ALTER TABLE {quoted} NO FORCE ROW LEVEL SECURITY")
        schema_editor.execute(f"ALTER TABLE {quoted} DISABLE ROW LEVEL SECURITY")
    grants = ", ".join(_quote_ident(table) for table in tables)
    schema_editor.execute(f"REVOKE ALL ON {grants} FROM {role}")


class Migration(migrations.Migration):
    dependencies = [
        ("assistant", "0004_immutable_revisions"),
        ("catalog", "0003_money_minor"),
        ("common", "0001_initial"),
        ("operations", "0002_money_minor"),
        ("tenancy", "0001_initial"),
    ]

    operations = [migrations.RunPython(apply_rls, remove_rls)]
