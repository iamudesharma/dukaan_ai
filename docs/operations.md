# Production operations

## Availability signals

- `/healthz/`: process liveness. Alert only after repeated failure.
- `/readyz/`: database-backed readiness used by Render. Alert on sustained failure or deploy rollback.
- API: request count, p50/p95 latency, 4xx/5xx by stable error code, and saturation.
- Worker: queue depth/oldest age, task success/failure/retry, and worker heartbeat.
- Scheduler/outbox: last successful dispatch, oldest due row, claim latency, and dead-letter/manual-review count.
- Database: connection use, slow queries, storage, backup/PITR state, and failed transactions.
- Providers: OCR/AI/WhatsApp latency, rate limits, spend, and failure without logging payloads.

Initial service objectives should be measured before publication. A practical internal baseline is 99.9% monthly API availability and p95 under 750 ms for non-AI API calls; assistant/OCR flows are asynchronous and use separate completion-time objectives.

## Alert policy

Page for user-impacting data integrity, suspected cross-tenant access, sustained write unavailability, backup/PITR failure beyond the RPO, or rapidly growing unprocessed durable work. Ticket lower urgency performance regressions, isolated provider retry, and non-production failures.

Each alert needs an owner, actionable threshold, dashboard link, runbook, and test. Avoid alerts on raw Redis queue length alone; compare it with Postgres outbox age and worker health.

## Capacity and cost guardrails

- Begin with one small paid API instance, one small worker, one cron dispatcher, and the smallest persistent Key Value plan.
- Set provider usage budgets/alerts and per-tenant quotas before enabling AI/OCR broadly.
- Track database/storage growth and egress weekly.
- Scale workers only after confirming task idempotency and database connection capacity.
- Scale the API based on sustained latency/saturation, not single spikes.
- Never lower backup, private-storage, TLS, or tenant controls to save cost.

## Routine ownership

Daily checks: incident alerts, failed/dead work, recovery-point freshness, and provider budget anomalies. Weekly checks: dependency/security workflow results, privileged access changes, slow queries, storage growth, and restore evidence. Every release follows the [release checklist](runbooks/release-checklist.md).
