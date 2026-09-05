# Database and object restore runbook

Only an authorized incident lead and database owner may initiate a production restore. A restore can discard acknowledged writes and must not be used as a routine rollback.

## Prepare

1. Declare an incident and stop or narrowly block production writes.
2. Record the suspected corruption time, desired recovery point, current commit/migration, latest database/object recovery points, and affected tenants.
3. Export and preserve post-recovery-point audit, idempotency, outbox, provider delivery, and payment evidence needed for reconciliation.
4. Prefer an isolated Supabase recovery project or approved clone. Never validate a destructive restore over the only production copy.
5. Select the application commit compatible with the restored schema.

## Restore Postgres

Use the Supabase Dashboard's backup or point-in-time recovery workflow for the selected project/plan, following [Supabase Database Backups](https://supabase.com/docs/guides/platform/backups). Have a second operator verify the project and recovery timestamp before confirmation.

If recovery creates a new project or connection endpoint:

- update the server-only `DATABASE_URL` and the matching Auth URL/JWKS/issuer/service-role configuration;
- reapply TLS/network restrictions and private bucket policies;
- rotate credentials exposed during the incident;
- keep clients and external providers pointed away until validation passes.

Do not immediately run the newest migrations. First deploy the schema-compatible application, inspect migration state, then apply only the reviewed forward migrations required for the chosen release.

## Restore receipt objects

Database recovery restores Storage metadata, not the object bytes. From the independently retained encrypted object copy:

1. compare the manifest with restored metadata at the recovery point;
2. restore only expected object keys into a private bucket;
3. verify checksums, content type, tenant prefix, and policy;
4. quarantine mismatches and keep signed URL issuance disabled for them;
5. test one authorized and one cross-tenant/unauthorized access case.

## Rebuild asynchronous work

Treat the queue as disposable. Start with an empty/replacement broker only after preserving incident evidence. Re-dispatch eligible Postgres outbox/scheduled rows using original idempotency keys. Reconcile provider delivery IDs before retrying messages, payments, or other external effects.

## Validate and reopen

Run all integrity checks in [backups and recovery](../backups-and-recovery.md), then a synthetic tenant flow covering auth, sale, payment, stock movement, balance, reversal, reminder dispatch, and private receipt access. Compare acknowledged writes after the recovery point and replay them only through reviewed domain commands.

Two operators approve reopening. Record actual recovery point, data loss/reconciliation, RTO, validation evidence, credentials rotated, and follow-up owners. Delete the isolated recovery environment only after retention approval; confirm deletion in the incident record.
