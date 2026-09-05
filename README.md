# DukaanAI

DukaanAI is a mobile-first AI business assistant for small and medium shops. A shop owner can speak, type, photograph, or upload what happened; DukaanAI turns it into a reviewable business command and reliably records sales, purchases, stock, payments, expenses, parties, and udhaar.

The design principle is simple: AI interprets intent, deterministic application code protects money and inventory.

Development status: the MVP is in progress. See the [implementation checkpoint](docs/implementation-status.md) for verified workflows and the remaining production work; deployment templates do not imply launch readiness.

## MVP stack

- **Mobile:** Flutter, with Hindi/Hinglish/English-friendly flows and an API base URL supplied at build time.
- **API:** Django + Django REST Framework in a modular monolith.
- **Durable platform:** Supabase Postgres, Auth, and private Storage.
- **Async work:** Celery with private Render Key Value (Valkey-compatible) and a Postgres-backed outbox.
- **Production runtime:** Render-hosted Django API, React static web, worker, and cron dispatcher in Singapore.
- **Web:** React/Vite owner and manager console in `apps/web`, using the same Django authorization boundary as mobile.

See [architecture](docs/architecture.md) for the system boundaries and transaction model. The [Sites boundary](docs/sites-production-boundary.md) records why the original Sites/Vinext placeholder was retired rather than used for production data.

## Repository layout

```text
apps/mobile/        Flutter Android production client
apps/web/           React/Vite production web console
services/api/       Django API, worker tasks, migrations, and tests
config/env/         Safe environment-variable templates
docs/               Architecture, security, operations, and runbooks
infra/              Infrastructure guide
compose.yaml        Local Postgres and Valkey
render.yaml         Production Render Blueprint
```

## Start locally

Prerequisites are uv 0.9.17, Docker Compose, Node.js 22, and the pinned Flutter SDK for mobile work. uv manages Python 3.13.5 and backend dependencies.

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

The API is available at `http://localhost:8000`; health and interactive documentation are at `/healthz/`, `/readyz/`, and `/api/docs/`. Run the worker in a second loaded shell with `make api-worker`.

Backend dependencies live in `services/api/pyproject.toml` and the committed `uv.lock`. See the [backend uv guide](services/api/README.md) for adding packages and updating the lockfile. Manual virtual environment activation is unnecessary.

For real Auth/Storage integration, a Flutter emulator, physical-device networking, and safe cleanup, follow the [local development runbook](docs/runbooks/local-development.md).

## Quality checks

```sh
make api-check
make web-check
make mobile-check
make config-check
```

GitHub Actions detects backend, web, mobile, and operations paths and runs only the relevant jobs. A separate workflow performs CodeQL, dependency review/audits, and secret scanning; Dependabot covers GitHub Actions, npm, Python, and Dart dependencies.

## Production

The checked-in [Render Blueprint](render.yaml) provisions the low-operational-overhead API topology. It intentionally does not provision a second database: use a dedicated paid Supabase production project with TLS, backups, point-in-time recovery, private receipt storage, and network restrictions.

Before accepting real customer data:

1. complete the [security launch gates](docs/security.md#launch-gates);
2. demonstrate the [backup and recovery objectives](docs/backups-and-recovery.md);
3. deploy and smoke-test through the [Render runbook](docs/runbooks/deploy-render.md);
4. protect the main branch with `Required CI gate` and security review;
5. verify both the Android app and React console reach only the Django business API.

Environment names and client/server boundaries are documented in [`config/env`](config/env/README.md). Never put a service-role key, database URL, Django secret, or provider token into Flutter or browser configuration.

## Operating guides

Start at the [documentation index](docs/README.md). Releases use the [release checklist](docs/runbooks/release-checklist.md); production events follow [incident response](docs/runbooks/incident-response.md) and [restore](docs/runbooks/restore.md).
