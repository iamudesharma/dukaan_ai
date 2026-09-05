# Render deployment runbook

The [`render.yaml`](../../render.yaml) Blueprint creates the React static console, Django web service, Celery worker, one-minute scheduled dispatcher, and private persistent Key Value service in Singapore. Supabase remains the durable database, Auth, and receipt storage provider.

## One-time prerequisites

1. Create separate staging and production Supabase projects in the closest appropriate Southeast Asia region.
2. In production, enable SSL enforcement, automated backups, point-in-time recovery, MFA for administrators, and the recovery controls in [backups and recovery](../backups-and-recovery.md).
3. Create a private `receipts` bucket. Confirm that no public policy grants object access.
4. Choose the persistent/session database connection appropriate for a long-running Django service. If direct IPv6 is unavailable, use the Supavisor session pooler rather than transaction mode. Require TLS with `sslmode=require`. Transaction-mode pooling is not supported: request tenant scope uses connection-local settings that transaction mode discards (see [database roles](database-roles.md)).
5. Connect the repository to Render and create a Blueprint from `render.yaml`. Review the proposed paid resources before applying it.

The Blueprint prompts for service-level values during initial creation. Render does not support secret prompts inside Blueprint-defined environment groups, so copy the same project/connection values carefully where repeated:

- `DJANGO_ALLOWED_HOSTS`: the exact Render API hostname and later the custom API hostname, comma-separated without schemes;
- `DATABASE_URL`: the production Supabase connection string, URL-encoded and with TLS required;
- `CORS_ALLOWED_ORIGINS`: the exact production and staging web origins;
- `SUPABASE_URL`, `SUPABASE_JWKS_URL`, and `SUPABASE_JWT_ISSUER` from the same production project;
- `SUPABASE_SERVICE_ROLE_KEY`: server-only, never the publishable/anon key;
- `OPENAI_API_KEY`: server-only assistant access; leave AI feature flags off until configured and evaluated;
- `FCM_SERVICE_ACCOUNT_JSON`: server-only notification credentials.

For `dukaan-web`, provide the public `VITE_API_URL`, `VITE_SUPABASE_URL`, and `VITE_SUPABASE_ANON_KEY`. Keep `VITE_DEMO_MODE=false`; `VITE_SENTRY_DSN` is optional but recommended. No server secret may use a `VITE_*` name.

The API needs all values above plus `DUKAAN_APP_DB_ROLE`/`DUKAAN_APP_DB_PASSWORD` (the least-privilege runtime role; see [database roles](database-roles.md)). The worker needs the same `DATABASE_URL`, `SUPABASE_URL`, and service-role key. The scheduler needs the same `DATABASE_URL`. The shared `dukaan-runtime` environment group generates one Django secret for all three Python services and holds only non-secret constants. Render injects the private Key Value connection into `REDIS_URL` and `CELERY_BROKER_URL`.

After Blueprint creation, add `SENTRY_DSN` manually to `dukaan-runtime` when an error-tracking project and alert owner exist. Render preserves manually added environment-group values that the Blueprint omits.

## First deployment

1. Keep Supabase network restrictions open only long enough to discover the Render services' documented outbound IP ranges. Then allow the required ranges and retest before launch.
2. Confirm CI is green for the exact commit.
3. Apply the Blueprint. Python services install using `uv sync --locked --no-dev`. The API collects static files and its pre-deploy phase runs `uv run --locked --no-dev python manage.py migrate --noinput` once before traffic switches. `UV_VERSION` and `PYTHON_VERSION` are pinned in the shared runtime group.
4. Confirm the worker is connected and the scheduler completes without overlapping or duplicating due work.
5. Add custom API and web domains and certificates in Render. Update `DJANGO_ALLOWED_HOSTS`, mobile build configuration, `VITE_API_URL`, and the exact web CORS origin.
6. Confirm the web console's SPA rewrite works on a directly loaded nested route such as `/reports`.

The Blueprint begins with a one-hour HSTS window and no subdomain/preload directive. After every HTTPS hostname and subdomain is verified, raise `DJANGO_SECURE_HSTS_SECONDS` gradually; enable include-subdomains/preload only after an explicit domain-wide review.

## Smoke tests

From an approved network, verify:

```sh
curl --fail --silent --show-error https://api.example.com/healthz/
curl --fail --silent --show-error https://api.example.com/readyz/
curl --fail --silent --show-error https://api.example.com/api/schema/ >/dev/null
```

Then use a dedicated production smoke tenant to:

1. authenticate and verify an unauthenticated API request is rejected;
2. post one idempotent test sale and retry the identical request;
3. confirm only one sale/payment/stock effect exists;
4. reverse it using the supported domain action;
5. schedule a test reminder and observe one worker delivery attempt;
6. upload a harmless receipt fixture, read it as the tenant, and verify another tenant cannot read it;
7. check logs and error tracking for accidental token, phone, OCR, or object-URL disclosure.

Record commit SHA, migration, operator, time, results, and dashboard links in the release record.

## Routine release

- Use expand/migrate/contract schema changes. Migrations in the current release must remain compatible with the previously running code.
- Render deploys only after repository checks pass. Watch pre-deploy, web, worker, scheduler, and database signals through the smoke window.
- Do not run migrations concurrently from web, worker, or cron start commands.
- Do not retry an uncertain bulk/business write without its original idempotency key.

## Rollback

For an application regression, stop rollout and redeploy the last known-good commit from Render. A backward-compatible expansion migration normally stays in place. Never reverse a destructive migration until a database owner has verified the recovery point and data impact.

If a new version has already written incompatible data, disable the affected feature/write path, preserve evidence, and follow [incident response](incident-response.md). Restore is a last resort and follows the [restore runbook](restore.md).

## Primary references

- [Deploy Django on Render](https://render.com/docs/deploy-django)
- [Render Background Workers](https://render.com/docs/background-workers)
- [Render Key Value](https://render.com/docs/key-value)
- [Render Cron Jobs](https://render.com/docs/cronjobs)
- [Render health checks](https://render.com/docs/health-checks)
- [Supabase database connections](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [Supabase network restrictions](https://supabase.com/docs/guides/platform/network-restrictions)
