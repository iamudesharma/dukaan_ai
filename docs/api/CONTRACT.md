# DukaanAI API contract

Source of truth: [`openapi.yml`](./openapi.yml), generated from the Django
code by `make api-schema` (drf-spectacular). `tests/test_schema.py` fails
CI when the committed file drifts from the code, so generated clients are
never built from a stale contract.

Typed clients (incremental adoption):

- Web: `apps/web/src/lib/api-schema.ts` via `npm run gen:api`
  (`openapi-typescript`). `interpretCommand` already types its request body
  against `components["schemas"]["Interpret"]`.
- Flutter: `apps/mobile/packages/dukaan_api_client` via `make mobile-gen`
  (OpenAPI Generator, Dart). `interpret()` already builds its request with
  the generated `Interpret` model. Excluded from hand-lint; never hand-edit.

## Transport conventions

- Money is integer paise (`*_minor`); GST rates are basis points
  (`tax_rate_bps`); quantities are fixed-precision decimal strings.
- Errors use the `{error: {code, detail}}` envelope; domain conflicts are
  `409` with a machine-readable `detail.code` (e.g.
  `negative_stock_confirmation_required`, `stale_proposal_data`).
- Mutations accept an idempotency key (body `idempotency_key` or
  `Idempotency-Key` header). Replays return the original result with
  `Idempotent-Replay: true`.
- Reads scope by `business_id` (+ optional `location_id`, `from`/`to`);
  lists paginate with `limit`/`offset`.
- Browser clients send `X-Client` and must be on the CORS allowlist with
  `x-client`/`idempotency-key` in `CORS_ALLOW_HEADERS` (a missing entry
  fails closed as `Failed to fetch` — found by the web e2e).

## Endpoint inventory

| Area | Routes |
|---|---|
| Auth | `auth/signup|login|otp/send|otp/verify|refresh|logout|logout-all|password/...`, `devices/` |
| Bootstrap | `me/` (PATCH display name), `bootstrap/` (404 `onboarding_required`) |
| Tenancy | `businesses/`, `locations/`, `gst-registrations/`, `memberships/` (+`revoke/`), `invitations/` (+`accept|revoke`), `notification-preferences/` |
| Catalog | `products/`, `parties/` (balances, `kind`/`search` filters) |
| Operations | `sales|purchases|payments|expenses|transfers/` (create/retrieve/reverse), `stock/adjustments|movements/`, `party-ledger/opening-balances/` |
| Reports | `reports/dashboard|day-book|sales|purchases|gst|party-balances|stock|stock-valuation|party-ledger|export/` (sync CSV); async `exports/` + `sales/{id}/invoice/` + `attachments/` + `attachments/presign/` |
| Activity | `activity/` (manager-only, `kind` groups: transactions/team/assistant) |
| Reminders | `reminders/`, `reminders/suggestions/`, `reminders/{id}/` |
| Assistant | `assistant/proposals/` (TEXT direct; IMAGE/VOICE/`attachment_ids` → PROCESSING), `revise`, `revisions`, `confirm` (SALE/PURCHASE/PAYMENT/EXPENSE), `cancel` |
| Search | `search/` (`q` ≥ 2 chars; cashiers: no suppliers/purchases) |

## Durability rules

- Side effects (reminders, exports, invoices, extraction) persist intent in
  Postgres (row + outbox event, one transaction) before any worker runs;
  the dispatcher reclaims after restarts. Topics: `reminder.send`,
  `export.run`, `invoice.generate`, `proposal.extract`.
- Manual and assistant sales share the negative-stock gate: below-zero
  projections need a manager/owner ack **plus** a reason
  (`negative_stock_confirmation_required`).
- Proposals are append-only reviewed (`ProposalRevision`); PROCESSING
  proposals are pollable, cancellable, never confirmable.

## Known approximations

- Gross profit / stock valuation use latest posted purchase cost (D1).
- SMS/WhatsApp send via a logging adapter until DLT/provider credentials
  land; photo/audio transcription needs an AI provider, else the proposal
  asks the shopkeeper to describe the bill (extraction provenance kept).
- Attachment presign returns direct-upload instructions until private
  Supabase storage signing is configured.
