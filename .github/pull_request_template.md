## What changed

Describe the customer or operational outcome and the smallest implementation that achieves it.

## Verification

- [ ] Backend: migrations and uv.lock changes are included; `make api-check` passes where applicable.
- [ ] Web: lint, format check, tests (when configured), and production build pass where applicable.
- [ ] Mobile: `flutter analyze` and `flutter test` pass where applicable.
- [ ] Tenant isolation and authorization were considered for every changed query/endpoint.
- [ ] Financial and inventory writes remain transactional, idempotent, and auditable.
- [ ] No secret, customer PII, receipt image, or production data was committed or logged.
- [ ] Migration, rollback, monitoring, and documentation impact was considered.

## Release notes / risk

State the rollout plan, any feature flag, migration risk, and what to watch after deployment.
