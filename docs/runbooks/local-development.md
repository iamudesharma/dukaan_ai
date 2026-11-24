# Local development runbook

## Prerequisites

- uv 0.9.17 (uses or installs the pinned Python 3.13.5)
- Docker with Compose
- Node.js 22
- JDK 21 and Dart 3.8+ when regenerating/checking API clients
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

In separate terminals, load the same `.env` and run `make api-worker` when testing asynchronous work. Run `make api-dispatch` for one outbox-only pass or `make api-maintenance` to dispatch work and purge a bounded batch of expired attachments. Local development may leave `ATTACHMENT_QUARANTINE_REQUIRED=false`; production defaults and templates require a real scanner. The API endpoints are:

- health: `http://localhost:8000/healthz/`
- readiness: `http://localhost:8000/readyz/`
- OpenAPI: `http://localhost:8000/api/schema/`
- API documentation: `http://localhost:8000/api/docs/`

The Android emulator reaches the host API through the default `http://10.0.2.2:8000/api/v1`. A physical device needs a reachable LAN or tunnel URL passed with `--dart-define=DUKAAN_API_BASE_URL=...`.

## Creating accounts locally

The API owns authentication: users sign up with a phone number and password
(`POST /api/v1/auth/signup/`) and then create their business
(`POST /api/v1/businesses/`). There is no fixture or sample account to load.

Verification codes use MSG91 when configured. Local development can set
`OTP_EXPOSE_DEV_CODE=true` with `SMS_ENABLED=false` to return the code in the API
response. Both clients discover availability from `/api/v1/auth/capabilities/`.

## Using live Neon and Redis/Upstash

Docker is optional. A local `.env` can point directly at hosted services:

```env
DATABASE_URL=postgresql://operator:...@ep-....aws.neon.tech/dukaan?sslmode=require
DUKAAN_APP_DATABASE_URL=postgresql://dukaan_app:...@ep-....aws.neon.tech/dukaan?sslmode=require
DUKAAN_USE_APP_DB_ROLE=true
REDIS_URL=rediss://default:...@....upstash.io:6379
CELERY_BROKER_URL=rediss://default:...@....upstash.io:6379
```

Use Neon's **direct hostname without `-pooler`**. Its PgBouncer pooler runs in
transaction mode, but DukaanAI RLS uses connection-local settings
(`app.current_user_id` and `app.business_ids`). Transaction pooling is unsupported.
Supabase session-mode pooling is also supported. See
[database roles](database-roles.md) for the operator and `dukaan_app` roles.

Create the `dukaan_app` role once with the operator credential, then apply
migrations with `DUKAAN_USE_APP_DB_ROLE=false`. Runtime API/worker/scheduler
processes use the separate app URL. Hosted `rediss://` brokers are normalized to
require TLS certificate verification.

Authentication is owned by Django. Private object Storage remains independently
configured through `STORAGE_BACKEND=supabase` (or local storage for development).
Django migrations own the application schema; do not maintain a second competing
set of SQL migrations.

## Checks and cleanup

Run `make api-check`, `make web-check`, and `make mobile-check` for the area changed. `make config-check` validates the checked-in YAML and Compose definition.

`make infra-down` preserves local data. `make infra-reset` is intentionally interactive because it deletes only the named DukaanAI local volumes.
