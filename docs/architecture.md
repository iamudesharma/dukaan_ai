# DukaanAI MVP architecture

Status: implemented foundation, updated 2026-11-24.

## Product boundary

The MVP is a mobile-first business operations system, not a general autonomous agent. It records sales, purchases, payments, expenses, stock movements, parties, and credit balances from structured forms or natural-language drafts. The system may propose a transaction, but the deterministic domain layer validates and commits it.

The production clients are the Flutter Android app and the React/Vite console in `apps/web`. Both authenticate against Django's phone/password JWT API and use Django as the only business-data API. Supabase supplies hosted Postgres and private object Storage; it is not the identity provider. The prior Vinext/OpenAI Sites scaffold was retired; see [Sites production boundary](sites-production-boundary.md).

## Runtime view

```text
Flutter Android app / React web console
                 |
          HTTPS + Django JWT
                 |
        Render Web Service (Django API)
            |                 |
     Postgres (Neon/Supabase)  Redis/Valkey
       + Storage              |
                              v
                    Render Background Worker

        Render Cron Job -- dispatches due, durable work --> Postgres outbox
```

- **Django API:** owns validation, authorization, idempotency, business transactions, and the public `/api/v1` contract.
- **Django authentication:** issues and verifies access/refresh JWTs for the internal user model, checks per-token blacklisting and all-device token versions, and derives active business/location memberships. Clients never receive the service-role key.
- **PostgreSQL (Neon or Supabase):** the sole durable system of record for operational and financial data. Tenant tables enforce Row Level Security, including child and valuation tables. DukaanAI currently uses direct Neon connections because its RLS scope is session/connection-local.
- **Private object Storage:** receipt and attachment objects. Postgres stores object metadata, scan/quarantine state, retention deadlines, and tenant ownership.
- **Redis/Valkey (local, Upstash, or Render Key Value):** Celery broker and production cache. It is not authoritative business storage; the Postgres outbox remains the recovery source.
- **Celery worker:** performs retryable OCR/STT, push delivery, summaries, exports, and other slow work.
- **Rust `doc-extractor`:** separate HTTP OCR plane using the provisioned OCRia-nano-1 model; DukaanAI sends raw document bytes and rejects provider fallback.
- **Scheduled dispatcher:** runs once per minute, claims due outbox work, enqueues idempotent tasks, and purges a bounded batch of policy-eligible expired attachments.

All Render services run in Singapore. The Postgres and Redis projects should use the closest available Southeast Asia region. Keeping the API, queue, and database near one another reduces latency and avoids unnecessary cross-region data movement.

## Data ownership and tenancy

Every tenant-owned aggregate carries an immutable `business_id`. Membership maps an internal Django user ID to a business, role, and assigned locations. The API derives the active user from the verified token and validates access to the requested business; it never trusts a client-supplied user ID.

The baseline defense is application-enforced tenant scoping plus forced PostgreSQL Row Level Security and runtime grants for a separate least-privilege role. Privileged migration/operator credentials are server-only. Cross-tenant negative tests cover direct database access as well as HTTP paths.

Recommended invariants:

- monetary values use integer paise and an explicit INR currency; percentages use basis points;
- quantities use fixed-precision decimals and an explicit unit;
- each sale, purchase, payment, and stock change has a stable ID, actor, tenant, timestamp, and audit metadata;
- idempotency keys are unique within a business and command type;
- inventory changes are represented as movements, not silent counter edits;
- purchases, sales, transfers, and reversals write append-only valuation layers; missing historical cost stays unknown and profit stays null;
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
- Treat `packages/api-contract/openapi.json` as the canonical wire contract; regenerate TypeScript/Dart clients and fail CI on drift.
- Do not introduce microservices for the MVP. Django modules and transaction boundaries are the scaling seam.

## Primary references

- [Render Blueprint specification](https://render.com/docs/blueprint-spec)
- [Render regions](https://render.com/docs/regions)
- [Supabase database connections](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [Supabase regions](https://supabase.com/docs/guides/platform/regions)
