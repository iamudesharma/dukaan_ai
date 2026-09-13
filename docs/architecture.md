# DukaanAI MVP architecture

Status: approved implementation baseline, 2026-09-04.

## Product boundary

The MVP is a mobile-first business operations system, not a general autonomous agent. It records sales, purchases, payments, expenses, stock movements, parties, and credit balances from structured forms or natural-language drafts. The system may propose a transaction, but the deterministic domain layer validates and commits it.

The production clients are the Flutter Android app and the React/Vite console in `apps/web`. Both authenticate with Supabase and use Django as the only business-data API. The prior Vinext/OpenAI Sites scaffold was retired; see [Sites production boundary](sites-production-boundary.md).

## Runtime view

```text
Flutter Android app / React web console
                 |
          HTTPS + Supabase JWT
                 |
        Render Web Service (Django API)
            |                 |
     Supabase Postgres   Render Key Value
       + Storage              |
                              v
                    Render Background Worker

        Render Cron Job -- dispatches due, durable work --> Postgres outbox
```

- **Django API:** owns validation, authorization, idempotency, business transactions, and the public `/api/v1` contract.
- **Supabase Auth:** issues user JWTs. The API verifies issuer, audience, signature, expiry, and membership; clients never receive the service-role key.
- **Supabase Postgres:** the sole durable system of record for operational and financial data.
- **Supabase Storage:** private receipt and attachment objects. Postgres stores object metadata and tenant ownership.
- **Render Key Value (Valkey-compatible):** Celery broker only. It is not authoritative business storage.
- **Celery worker:** performs retryable OCR, notifications, summaries, exports, and other slow work.
- **Scheduled dispatcher:** runs once per minute, claims due rows/outbox work in Postgres, and enqueues idempotent tasks.
- **Outbox topics:** `sale|purchase|payment|expense|transfer.posted|reversed`
  (audit fan-out), `reminder.send`, `export.run`, `invoice.generate`,
  `proposal.extract` (bill-media text extraction → proposal finalize).
- **API contract:** `docs/api/openapi.yml` generated from code
  (`make api-schema`), drift-tested in CI; typed clients generated for web
  (`npm run gen:api`) and Flutter (`make mobile-gen`), adopted
  incrementally. See [API contract](./api/CONTRACT.md).

All Render services run in Singapore. The Supabase project should use the closest available Southeast Asia region. Keeping the API, queue, and database near one another reduces latency and avoids unnecessary cross-region data movement.

## Data ownership and tenancy

Every tenant-owned aggregate carries an immutable `business_id`. Membership maps a Supabase user ID to a business and a role. The API derives the active user from the verified token and validates access to the requested business; it never trusts a client-supplied user ID.

The baseline defense is application-enforced tenant scoping plus database
constraints. Since 2026-09-05 this is proven, not planned: `FORCE ROW LEVEL
SECURITY` covers every tenant table including Phase 2–4 additions
(invitations, notification preferences, reminders, export jobs,
attachments), verified by direct as-`dukaan_app`-role tests
(`tests/test_rls.py`: fail-closed reads, scoped reads, rejected
cross-tenant writes, child inheritance, scoped self-bootstrap).
Privileged database credentials are server-only.

Recommended invariants:

- monetary values use integer paise and an explicit INR currency; percentages use basis points;
- quantities use fixed-precision decimals and an explicit unit;
- each sale, purchase, payment, and stock change has a stable ID, actor, tenant, timestamp, and audit metadata;
- idempotency keys are unique within a business and command type;
- inventory changes are represented as movements, not silent counter edits;
- outstanding balances are derived from posted documents and allocations;
- posted documents are reversed or adjusted, not destructively rewritten;
- all rows touched by one business command commit in one database transaction.

## Command lifecycle

For “Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending”:

1. The assistant endpoint stores the raw utterance and creates a draft command.
2. An AI extractor produces typed candidate fields plus uncertainties; it does not write ledgers or stock directly.
3. Deterministic code resolves or proposes the customer/product and checks quantities, totals, permissions, and duplicate/idempotency keys.
4. The user confirms any material ambiguity.
5. One database transaction posts the sale, stock movement, payment allocation, balance impact, audit entry, and durable outbox records.
6. A concise confirmation is generated from committed records, never from the model's uncommitted proposal.

## Reliability model

Client retries, worker retries, cron overlap, and provider webhooks are expected. Every mutation and external side effect must therefore have an idempotency key. Workers acknowledge only after durable work is complete. A failed enqueue is recovered from Postgres by a later dispatcher run.

Queue loss may delay work but must not lose a sale, payment, reminder, or notification intent. Readiness checks include the database; liveness checks only verify that the API process can respond.

Schema changes use expand/migrate/contract releases. Destructive changes and long data rewrites do not share a release with code that first depends on them.

## Deployment units

The root [`render.yaml`](../render.yaml) declares:

- one paid Django web service, with migrations in the pre-deploy phase;
- one paid Celery worker;
- one one-minute cron dispatcher;
- one private, persistent Key Value service with `noeviction`;
- one React/Vite static web service with an SPA rewrite;
- one shared environment group for server-side configuration.

Horizontal API/worker scaling is permitted once idempotency and database locking are in place. The first deployment intentionally uses one small instance of each to minimize cost and operational surface.

## Evolution boundaries

- Add model providers behind a typed assistant adapter; domain commands remain provider-independent.
- Add OCR behind an attachment-processing interface; preserve the original object and extraction provenance.
- Add WhatsApp behind an outbound-message adapter and durable delivery state.
- Add read replicas/search/warehouse only after measured load requires them.
- Do not introduce microservices for the MVP. Django modules and transaction boundaries are the scaling seam.

## Primary references

- [Render Blueprint specification](https://render.com/docs/blueprint-spec)
- [Render regions](https://render.com/docs/regions)
- [Supabase database connections](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [Supabase regions](https://supabase.com/docs/guides/platform/regions)
