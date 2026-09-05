# Local development runbook

## Prerequisites

- uv 0.9.17 (uses or installs the pinned Python 3.13.5)
- Docker with Compose
- Node.js 22
- Flutter stable with an Android/iOS target for mobile work

## Fast local mode

This mode uses containerized Postgres and Valkey plus the Django development authentication bypass. It is for trusted local development only.

```sh
cp .env.example .env
make infra-up
set -a
. ./.env
set +a
make api-install
make api-migrate
make api-run
```

In separate terminals, load the same `.env` and run `make api-worker` when testing asynchronous work. Run `make api-dispatch` to execute one scheduler pass. The API endpoints are:

- health: `http://localhost:8000/healthz/`
- readiness: `http://localhost:8000/readyz/`
- OpenAPI: `http://localhost:8000/api/schema/`
- API documentation: `http://localhost:8000/api/docs/`

The Android emulator reaches the host API through the default `http://10.0.2.2:8000/api/v1`. A physical device needs a reachable LAN or tunnel URL passed with `--dart-define=DUKAAN_API_BASE_URL=...`.

## Supabase integration mode

Use this mode to exercise real JWT verification, Auth, and private Storage behavior. Prefer a local Supabase CLI stack or a dedicated non-production project; never point local code at production.

1. Start Supabase and obtain its current URL, database connection, publishable/anon key, JWKS/issuer values, and service-role key using `supabase status`. Do not copy keys into tracked files.
2. Start only the local queue with `docker compose up -d --wait redis` if Supabase supplies Postgres.
3. Override `DATABASE_URL` and the `SUPABASE_*` variables in the private `.env`.
4. Set `DEV_AUTH_ENABLED=false`, apply Django migrations to that database, and run the API.
5. Create/verify a private `receipts` bucket and test authorized, expired, and cross-tenant signed-URL access.

Django migrations own the application schema. Do not maintain a second competing set of Supabase SQL migrations for the same tables.

## Checks and cleanup

Run `make api-check`, `make web-check`, and `make mobile-check` for the area changed. `make config-check` validates the checked-in YAML and Compose definition.

`make infra-down` preserves local data. `make infra-reset` is intentionally interactive because it deletes only the named DukaanAI local volumes.
