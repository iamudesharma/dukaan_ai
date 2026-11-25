# Implementation checkpoint — 2026-11-24

This repository is a working development foundation, not a completed production launch.

## Latest verified work

- API/client contracts now use explicit minor-unit dashboard fields, real
  location-scoped stock quantities, party balances, and owner-only business
  updates. Web and Flutter consume those contracts with regression tests.
- MSG91 OTP delivery is implemented behind a provider boundary, including DLT
  template configuration, HTTP-200 error detection, and fail-closed delivery.
  Live delivery still requires MSG91 credentials and an approved template.
- Gmail read-only OAuth and payment/receipt extraction are implemented. Imports
  are review-only and never post automatically. Live use requires Google OAuth
  credentials and consent-screen verification.
- Local whisper.cpp transcription uses an existing `whisper-cli` binary and an
  existing model file. The Flutter app records M4A audio and uploads it through
  Django for asynchronous transcription. The application never downloads model
  weights.
- The OpenAI-compatible assistant adapter now supports typed function/tool
  calls for Gmail extraction; model output remains untrusted and validated.
- Offline drafts are user/business scoped. Mobile reconnect no longer posts
  drafts automatically; assistant drafts require review and explicit confirm.
- Cashier responses and clients hide supplier, cost, margin, report, and manager
  data; backend endpoints enforce the same boundary.
- Image/PDF OCR is delegated to the Rust `doc-extractor` HTTP service using
  the provisioned OCRia-nano-1 model. DukaanAI installs no OCR packages and
  downloads no models; web and mobile upload raw documents for review. Live
  PNG and PDF smoke tests returned `Invoice TOTAL 12345` with no fallback.
- Runtime services can use a separate least-privilege database URL, production
  throttles use Redis, and the API/worker Docker image contains no OCR runtime.
  The image builds successfully and passes Django system checks.
- Secure owner-managed invitations, phone-bound acceptance, lifecycle audits,
  and all-device session revocation are implemented. Password change/reset also
  revokes existing tokens.
- Posted sales render deterministic GST-style A4 invoice PDFs with exact paise,
  GST breakdowns, paid/due, Unicode/Hindi text, safe filenames, and VOID marking
  for reversed sales. PDFs create no second ledger.
- Durable notification devices/reminders use outbox-only FCM HTTP v1 delivery,
  per-device idempotency, retries, and fail-closed credentials. Attachment
  scanning/quarantine, bounded reads, retention audits, and scheduled purging are
  implemented; open review attachments are retained.
- Weighted-average inventory valuation, immutable cost layers, COGS/gross-profit
  reporting, payment-allocation review/reallocation, and transactional CSV
  product/party imports are implemented. Missing cost evidence remains unknown.
- Offline deterministic Hindi parsing now produces reviewable sale, purchase,
  and expense drafts with exact catalog resolution and fail-closed ambiguity;
  no Hindi input posts without explicit confirmation.
- The OpenAPI contract now validates with zero warnings/errors across 81 paths
  and 113 operations. Reproducible TypeScript and Dart/Dio clients are checked in
  under `packages/api-contract` with CI drift checks.
- Local development can run without Docker using direct Neon Postgres and
  Upstash Redis. Runtime services use a separate least-privilege database role,
  Neon transaction pooling is explicitly rejected for RLS safety, and hosted
  Redis broker connections require TLS certificate verification.

Verified locally: backend 399 tests on SQLite and 409 tests on PostgreSQL/RLS;
web typecheck/build and 99 tests; hermetic Chromium E2E 5 tests; Flutter 141
tests with zero analyzer errors or warnings. Final runtime-grant and onboarding
fixes were verified against live Neon with a rolled-back write/RLS/invoice
smoke, and an Upstash Celery probe completed successfully in the worker.
OpenAPI validates with zero warnings/errors, generated TypeScript/Dart clients
pass drift/type/analyzer checks, and Python/npm dependency audits report no
known vulnerabilities. The API/worker Docker image builds without OCR packages,
includes invoice fonts, and passes Django system checks. Live Rust OCRia smoke
tests read PNG/PDF receipts and produced reviewable proposals. Flutter analysis
retains 53 non-fatal Material deprecation notices.

## Earlier foundation

Implemented: React console and Flutter navigation/capture screens, offline draft stores,
Django catalog and transaction services, initial migrations, JWT authentication boundary,
location membership checks, sale/purchase/payment/expense/transfer services, reversals,
audit/outbox records, sale/purchase/expense proposal confirmation, deployment templates and CI.
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

- Complete the live Android owner/cashier smoke on a stable emulator or device before release. The aborted attempt persisted no E2E users or tenant data; generated client/schema checks and hermetic browser E2E coverage are complete.
- Configure staging/production accounts, MSG91/DLT, Google OAuth verification, FCM credentials, signing keys, storage backups, production attachment scanning, and deployment credentials.

The assistant supports deterministic parsing plus an optional OpenAI-compatible
model adapter and typed tool calls. Local Whisper transcription and Rust
doc-extractor OCR are available without DukaanAI downloading models. Production provider
credentials and external launch approvals remain required.

Accounts and onboarding (2026-09-11): a real user signs up with phone + password, then creates
their business through `POST /api/v1/businesses/`, which creates the OWNER membership and the
first location in one call (optional `location_name`, `state_code` and `gstin`). `signup`,
`login` and `otp/verify` report `onboarding_required`, and `GET /api/v1/bootstrap/` returns the
`onboarding_required` error code until a business exists. No client ships sample data: the web
console calls `VITE_API_URL` for every request, the Flutter app signs in against
`DUKAAN_API_BASE_URL` and refreshes its own tokens, and the only remaining dev-only path is the
server-side `X-Dev-User-ID` header behind `DEV_AUTH_ENABLED`.

Verification codes: MSG91 delivery is implemented, but live use still requires
an auth key and approved DLT OTP template. With `SMS_ENABLED=false` and
`OTP_EXPOSE_DEV_CODE=false`, OTP endpoints return `503 sms_not_configured`.
Local development can return the code with `OTP_EXPOSE_DEV_CODE=true`; both
clients discover OTP availability from `/api/v1/auth/capabilities/`.

Local operator command: `uv run --locked python manage.py purge_demo_data` reports the seeded
demo tenants and their row counts, and deletes nothing until `--confirm` is passed. It replaces
the removed `seed_demo`; create test data through the API instead.
