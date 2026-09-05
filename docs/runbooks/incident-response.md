# Incident response runbook

## Severity

- **SEV-1:** confirmed/suspected cross-tenant exposure, credential compromise with access, incorrect financial/stock posting at scale, unrecoverable writes, or complete production outage.
- **SEV-2:** material degradation, growing durable-work backlog, one critical provider unavailable without fallback, or a contained data-integrity issue.
- **SEV-3:** limited defect with a workaround and no security/data-integrity risk.

Security or tenant-isolation uncertainty starts as SEV-1 until disproved.

## First 15 minutes

1. Assign incident lead, operations lead, communications owner, and scribe; record all times in IST and UTC.
2. Open an access-controlled incident record. Capture deploy SHA, affected services/tenants, first known event, alerts, request IDs, and recovery-point freshness.
3. Stop propagation using the narrowest reversible control: disable the affected feature/provider, pause the worker, or block the affected write route. Preserve read access when safe.
4. Preserve logs, database/audit records, queue/outbox state, and provider delivery IDs. Do not delete evidence or run ad-hoc corrective SQL.
5. Decide whether to rollback application code, rotate credentials, isolate a tenant/provider, or enter maintenance. Declare customer impact conservatively.

## Playbooks

### Bad application release

Stop automatic rollout and redeploy the last known-good commit. Leave compatible expansion migrations in place. If the new release wrote incompatible records, disable that path and reconcile through reviewed domain commands or a dedicated migration; do not directly overwrite balances.

### Database unavailable or corrupted

Block writes, verify Supabase status and connection/network limits, and avoid a retry storm. If integrity is suspect, capture a recovery point and follow [restore](restore.md) into isolation first. Reconcile all acknowledged client writes and idempotency keys after the selected recovery time.

### Queue/worker outage

Keep the API's durable transaction/outbox path available if safe. Pause provider dispatch, repair or replace the worker/Key Value service, and replay only claimed/unfinished outbox rows with their original idempotency keys. Watch provider duplicate-delivery semantics and backlog age.

### Credential exposure

Revoke/rotate the exposed credential at its issuer, update Render/GitHub/Supabase secrets, redeploy/restart consumers, invalidate sessions if necessary, and search access/audit logs for use from first possible exposure. Treat service-role or database credentials as potential access to every tenant.

### Cross-tenant access or privacy leak

Disable the affected route/export/object policy immediately, preserve authorization and object-access evidence, identify exact tenants/fields/time window, and engage legal/privacy notification owners. Add a reproducing negative test before re-enabling the path.

### AI/OCR/WhatsApp provider fault

Disable automated action for the provider while preserving drafts/outbox intents. Do not silently post low-confidence or malformed extraction. Reconcile outbound messages using provider IDs before retrying.

## Recovery and closeout

Verify tenant isolation, financial/inventory invariants, idempotent retry, receipt privacy, outbox age, and customer-visible flows before reopening. Monitor through at least one normal traffic/dispatch cycle.

Within five business days, produce a blameless review with timeline, impact, detection gap, root cause, contributing controls, recovery performance, and owned corrective actions. Rotate incident artifacts and access according to the privacy policy.
