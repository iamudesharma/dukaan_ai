# Database roles and Row Level Security

Two Postgres roles separate schema ownership from request handling. The
migration in `apps/tenancy/migrations/0002_row_level_security.py` enables
`FORCE ROW LEVEL SECURITY` on every tenant table, so **both** roles only
see rows in their connection's request scope (`app.current_user_id` +
`app.business_ids`, both set from server-verified values).

## Roles

- **Migration/operator role** (for example `dukaan` locally, the Neon/Supabase
  project credential in production): owns the tables, runs `migrate`,
  `purge_demo_data` (needs ownership to suspend the append-only revision
  trigger), and `dispatch_scheduled`. It is still bound by RLS — verified by
  `test_owner_writes_outside_scope_are_rejected` — and must set staff scope
  for operator work.
- **Application role** (`dukaan_app` by default, see `DUKAAN_APP_DB_ROLE`):
  the only credential the API and worker use at runtime. It holds
  `SELECT/INSERT/UPDATE/DELETE` on tenant tables plus sequence usage, and
  Row Level Security limits it to the request's businesses. It cannot run
  DDL.

`common_user` (identity bootstrap anchor) and `django_session` (random keys
only) are intentionally outside RLS; everything else tenant-owned is
covered, including line/pack/revision/allocation child tables through
their parents.

## One-time setup per database

Create the role before running migrations (the database itself must already
exist). Run as the table owner or a superuser:

```sql
CREATE ROLE dukaan_app LOGIN PASSWORD '<strong-random-password>';
GRANT CONNECT ON DATABASE dukaan TO dukaan_app;
GRANT USAGE ON SCHEMA public TO dukaan_app;
```

The RLS migration applies tenant table/sequence grants,
`tenancy/0003_runtime_role_grants.py` applies identity/auth/OAuth grants, and
`tenancy/0005_runtime_session_grants.py` adds session-version and migration-table
reads. If the role is added after those migrations have run, reapply the grant
blocks as the owner before enabling `DUKAAN_USE_APP_DB_ROLE=true`.

Store the password in server-side secret controls only. Runtime services put it
in the URL-encoded `DUKAAN_APP_DATABASE_URL`; it must never enter a client build,
log line, or screenshot. `DUKAAN_APP_DB_PASSWORD` is retained only for the local
raw-SQL RLS probe in `tests/test_rls.py`. Rotate the password with the other
database credentials after any suspected exposure (see [security](../security.md)).

## Connection environment

Two URLs separate schema ownership from request handling:

- `DATABASE_URL` — migration/operator credential. It owns the schema and runs
  migrations and operator-only commands.
- `DUKAAN_APP_DATABASE_URL` — runtime credential for `dukaan_app` (or the role
  named by `DUKAAN_APP_DB_ROLE`). The API, Celery worker, and scheduled
  dispatcher use this URL.
- `DUKAAN_USE_APP_DB_ROLE` — `true` selects `DUKAAN_APP_DATABASE_URL`; `false`
  (the default) selects `DATABASE_URL`. Enabling the runtime role without its
  URL is a startup error, never a silent fallback to the operator credential.

Use a direct Postgres connection or a session-mode pooler. Neon's `-pooler`
hostname uses transaction mode and is not compatible with DukaanAI's
connection-local RLS settings.

For example, a runtime environment sets:

```dotenv
DATABASE_URL=postgresql://operator:...@host:5432/dukaan?sslmode=require
DUKAAN_APP_DATABASE_URL=postgresql://dukaan_app:...@host:5432/dukaan?sslmode=require
DUKAAN_APP_DB_ROLE=dukaan_app
DUKAAN_USE_APP_DB_ROLE=true
```

Migrations and operator commands explicitly force the owning credential:

```sh
DUKAAN_USE_APP_DB_ROLE=false uv run --locked python manage.py migrate --noinput
DUKAAN_USE_APP_DB_ROLE=false uv run --locked python manage.py purge_demo_data
```

Render's API pre-deploy command forces `DUKAAN_USE_APP_DB_ROLE=false`; its API,
worker, and scheduler inherit `true` from the shared runtime environment group.
The dispatcher and worker use the application role with a server-set staff scope
for system outbox rows; neither performs DDL.

This matters because of how PostgreSQL treats privileged roles:

| Role attribute | Effect on RLS |
| --- | --- |
| `SUPERUSER` | Exempt from every policy, `FORCE` included |
| `BYPASSRLS` | Same exemption, granted explicitly |
| Table owner, neither of the above | Bound by `FORCE ROW LEVEL SECURITY` |

The local `dukaan` role (created from `POSTGRES_USER`) and many hosted operator
roles are superusers, so RLS does not apply to an operator connection. The
application role is neither a superuser nor a table owner and is therefore bound
by the policies. Application-layer membership checks remain defense in depth.

The runtime grants deliberately cover only tenant DML plus the global identity,
OTP, revoked-token, and user-owned Gmail-connection tables needed by the API and
worker. They do not grant table ownership or DDL. `tests/test_rls.py` verifies
those grants and opens a dedicated connection as `dukaan_app` to assert
isolation directly. Tests over the default operator connection cannot observe
RLS while that connection is privileged; they check
`conftest.rls_is_enforced` and state the precondition instead of asserting
behaviour the environment cannot produce.

## Pooling requirement

Request scope uses connection-local `SET`. Use direct connections or the
Supavisor **session** pooler. **Transaction-mode pooling discards `SET`
between statements and silently drops every request's scope**, which under
fail-closed RLS means all tenant reads return empty. The deploy runbook
already requires session mode for the Django service.

## Verification

- `tests/test_rls.py` connects as the application role over raw SQL and
  proves fail-closed reads, scoped reads, rejected cross-tenant writes
  (owner included), child-table inheritance, and scoped self-bootstrap.
  It runs on PostgreSQL and skips on SQLite.
- The suite-wide fixture in `tests/conftest.py` re-establishes per-request
  scope exactly like production auth does, so the domain tests exercise
  the same enforcement path as deployed requests.
- CI's backend job creates both roles in its Postgres service and runs the
  full suite (including `test_rls.py`) against it.
