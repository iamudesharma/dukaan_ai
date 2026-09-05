# Database roles and Row Level Security

Two Postgres roles separate schema ownership from request handling. The
migration in `apps/tenancy/migrations/0002_row_level_security.py` enables
`FORCE ROW LEVEL SECURITY` on every tenant table, so **both** roles only
see rows in their connection's request scope (`app.current_user_id` +
`app.business_ids`, both set from server-verified values).

## Roles

- **Migration/operator role** (for example `dukaan` locally, the Supabase
  project credential in production): owns the tables, runs `migrate`,
  `seed_demo` (local only), and `dispatch_scheduled`. It is still bound by
  RLS — verified by `test_owner_writes_outside_scope_are_rejected` — and
  must set staff scope for operator work.
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

Run as the table owner (or a superuser), after migrations:

```sql
CREATE ROLE dukaan_app LOGIN PASSWORD '<strong-random-password>';
GRANT CONNECT ON DATABASE dukaan TO dukaan_app;
GRANT USAGE ON SCHEMA public TO dukaan_app;
-- Table and sequence grants are applied by the RLS migration itself when
-- the role already exists; re-run the GRANT block from that migration if
-- the role was created afterwards.
```

Store the password in server-side secret controls only
(`DUKAAN_APP_DB_PASSWORD`). It must never enter a client build, log line,
or screenshot. Rotate it with the other database credentials after any
suspected exposure (see [security](../security.md)).

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
