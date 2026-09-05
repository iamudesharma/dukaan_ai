# Implementation checkpoint — 2026-09-05

This repository is a working development foundation, not a completed production launch.

Implemented: React console and Flutter navigation/capture screens, offline draft stores,
Django catalog and transaction services, initial migrations, JWT authentication boundary,
location membership checks, sale/purchase/payment/expense/transfer services, reversals,
audit/outbox records, sale proposal confirmation, deployment templates and CI.
Stale-data proposal fingerprints and immutable proposal revisions are implemented
(`AssistantProposal.data_fingerprint`, append-only `ProposalRevision` with database
immutability triggers) and covered by `tests/test_proposal_revisions.py`.

Integer-paise contract (2026-09-05): all money is stored and exchanged as integer
paise (`*_minor` fields) with GST rates in basis points (`tax_rate_bps`); quantities
stay fixed-precision decimals. The Django API, web console, and Flutter client all
speak the minor-unit contract. Verified: the Ramesh sale (₹2,400/₹1,500/₹900),
repeat confirmation, reversal, injected outbox failure rollback, revoked membership,
cashier document restrictions, scoped bootstrap, and the full suite on SQLite
(26 passed, RLS tests skip) and PostgreSQL 18 (33 passed, including 7 direct RLS tests).

PostgreSQL RLS (2026-09-05): `FORCE ROW LEVEL SECURITY` on every tenant table
(direct `business_id` tables plus line/pack/revision/allocation children through
their parents). Request scope (`app.current_user_id` + `app.business_ids`) is set
from server-verified values in DRF token auth and the session login signal;
pooled connections are cleared per request. Separate migration/operator and
application (`dukaan_app`) roles; see [database roles](runbooks/database-roles.md).
Verified directly as the app role over raw SQL: fail-closed reads, scoped reads,
rejected cross-tenant writes (owner included), child-table inheritance, scoped
self-bootstrap. Transaction-mode pooling is unsupported (documented in runbooks).

Outbox plane (2026-09-05): the previously referenced `dispatch_scheduled` command
now exists — it claims due rows with `SKIP LOCKED` and enqueues one idempotent
`process_outbox_event` Celery task per row; broker failure rolls the claim back
for a later pass. Worker acknowledges only after durable handling; unknown topics
fail closed with the error recorded. Covered by `tests/test_outbox.py`.

Verified locally: the Ramesh sale, repeat confirmation, reversal, injected outbox failure
rollback, revoked membership, cashier document restrictions, and scoped bootstrap.

Remaining launch-critical implementation:

- Complete onboarding, invitations/session revocation, full Hindi UI and role-specific clients.
- Complete real AI/media extraction, secure uploads, invoice PDFs, outbox workers and notifications.
- Finish reports, weighted-average costing, imports, payment allocation review and remaining forms.
- Generate API clients, pin all runtimes, and run PostgreSQL, Android and browser end-to-end tests.
- Configure staging/production accounts, SMS/DLT, storage, backups and deployment credentials.

The current assistant uses a narrow deterministic sale parser. Voice/media integrations and
model-based extraction must not be presented as live production capabilities yet.

Local demo: run `uv run --locked python manage.py migrate` then `uv run --locked python manage.py seed_demo` from
`services/api` after `uv sync --locked`. The seed requires development
authentication and prints the user UUID for local API testing. It is safe to run again.
