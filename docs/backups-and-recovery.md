# Backups and recovery policy

## Service objectives

For public production, DukaanAI targets:

- transactional Postgres: recovery point objective (RPO) of 15 minutes and recovery time objective (RTO) of 4 hours;
- receipt objects: RPO of 24 hours and RTO of 8 hours;
- queue/cache: no recovery objective; it may be rebuilt because durable work intent lives in Postgres.

These are operational targets, not guarantees from the application. Do not advertise them until the selected Supabase plan, point-in-time recovery configuration, object-copy job, staffing, and a timed restore drill demonstrate them.

## What is protected

Supabase database backups protect the Postgres schema and rows. They do **not** restore the binary objects held by Supabase Storage; the database contains only their metadata. Receipt objects therefore require a separate encrypted copy to another controlled bucket or provider.

Render Key Value persistence improves queue availability but is not a business-data backup. Celery messages may be dropped during recovery. The Postgres outbox/scheduled rows must safely re-dispatch unfinished work.

## Required production configuration

1. Use a paid Supabase production project with automated backups.
2. Enable point-in-time recovery with a retention window that meets the 15-minute transactional RPO.
3. Enable database TLS and retain recovery credentials in the approved secret manager.
4. Copy private Storage objects at least daily to a separately administered encrypted location; verify object count, size, and checksum manifests.
5. Retain immutable application audit records according to the business/privacy retention policy.
6. Keep infrastructure definitions and migration files in the versioned repository.
7. Alert on failed backups/copies, stale successful timestamps, and restore-test failure.

If point-in-time recovery is not purchased during a closed pilot, record the reduced database RPO shown in the Supabase dashboard and obtain explicit risk acceptance. Public production must meet the target above.

## Operating cadence

- Daily: verify the latest database recovery point and storage-copy completion.
- Weekly: inspect failures, storage growth, retention, and an outbox replay sample.
- Monthly: restore the latest database and a sample of receipt objects into an isolated recovery project; run integrity checks.
- Quarterly: conduct a timed, end-to-end recovery exercise and update contacts, timings, and gaps.
- Before destructive migrations or bulk imports: create/verify a recovery point and a tested rollback approach.

Evidence must include timestamp, operator, source recovery point, target environment, integrity-query results, sampled object checksums, observed RPO/RTO, and cleanup confirmation. Never restore production PII into a developer environment.

## Integrity checks after restore

- migrations match the deployed release;
- every tenant-owned row has a valid business reference;
- document totals equal line/payment allocations within currency precision;
- stock movement sums agree with materialized balances;
- outstanding balances can be rebuilt from posted documents and allocations;
- audit/outbox records have no impossible gaps or duplicate idempotency keys;
- authorized users can access their private receipt sample and another tenant cannot;
- `/healthz/` and `/readyz/` pass, followed by a synthetic sale-and-reversal flow.

Use the detailed [restore runbook](runbooks/restore.md). Supabase documents backup behavior and plan-dependent retention in [Database Backups](https://supabase.com/docs/guides/platform/backups).
