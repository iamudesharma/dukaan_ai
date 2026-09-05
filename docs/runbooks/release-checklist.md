# Release checklist

## Before approval

- [ ] Scope, risk, rollout owner, and rollback trigger are recorded.
- [ ] Required CI and security checks pass for the exact commit.
- [ ] New tenant-scoped endpoints have positive and cross-tenant negative tests.
- [ ] Financial/inventory changes have transaction, precision, concurrency, idempotency, reversal, and audit tests.
- [ ] AI/provider behavior cannot bypass deterministic validation or authorization.
- [ ] New logs/errors are checked for secrets and PII.
- [ ] Dependencies, environment variables, migrations, runbooks, and client compatibility are documented.

## Database and recovery

- [ ] Migration is reviewed for locks, duration, reversibility, and old/new code compatibility.
- [ ] Latest recovery point is healthy and within the production RPO.
- [ ] A special recovery point and rollback plan exist for destructive or bulk changes.
- [ ] Long backfills run as resumable, observable jobs rather than blocking deploy.

## Deploy and smoke

- [ ] Deploy during the supported window; record commit and operator.
- [ ] Pre-deploy migration succeeds exactly once.
- [ ] `/healthz/` and `/readyz/` pass.
- [ ] Auth rejection, tenant access, idempotent write/retry, reversal, queue/worker, and private receipt smoke checks pass where affected.
- [ ] Error rate, latency, database connections, outbox age, worker failures, backups, and provider spend remain healthy.

## Closeout

- [ ] Continue observation for the risk-appropriate window.
- [ ] Confirm the previous release can still be selected for rollback.
- [ ] Record deviations, manual work, and follow-ups with owners and dates.
- [ ] Complete the contract/removal phase only after all active clients no longer depend on the old schema or behavior.
