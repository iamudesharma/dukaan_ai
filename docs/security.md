# Security baseline

This is the minimum launch posture for a multi-tenant system that stores business and financial records. It is a living control document, not a certification claim.

## Trust boundaries

- Flutter and browser clients are untrusted. They contain public configuration only.
- Django is the only component allowed to use the Supabase service-role key or privileged database connection.
- AI/OCR/WhatsApp providers receive the minimum data necessary for one job. Their responses are untrusted input.
- Valkey/Celery is a delivery mechanism. Sensitive records and authorization decisions are not stored there as the sole copy.

## Authentication and authorization

1. Supabase Auth signs the user JWT.
2. Django verifies signature via the project JWKS, issuer, `authenticated` audience, expiry, and allowed algorithm.
3. Django maps the immutable token subject to an internal user and active business membership.
4. Every queryset and object lookup is scoped to that business before role checks.
5. Sensitive actions use explicit permissions and write an audit event.

Production must have `DEV_AUTH_ENABLED=false`. Never accept tenant ID, role, actor ID, price authority, or outstanding balance solely because the client supplied it. Cross-tenant negative tests are required for list, detail, mutation, export, attachment, and async-task paths.

## Financial and inventory integrity

- Use database transactions and constraints for multi-row commands.
- Require idempotency keys on retryable writes and provider webhooks.
- Store money as integer paise and quantities as fixed-precision decimals; never use binary floating point.
- Preserve actor, source, request ID, timestamps, and before/after or reversal links.
- Do not allow a language model to execute unrestricted SQL or call low-level write functions.
- AI output becomes a typed draft. Deterministic validation and, when ambiguous, user confirmation precede posting.
- Keep a durable outbox so queue failure cannot silently drop downstream work.

## Secrets and environments

- Secrets live in Render/Supabase/GitHub secret controls, not source, logs, screenshots, crash reports, or mobile binaries.
- Separate development, staging, and production Supabase projects and keys.
- Rotate `DJANGO_SECRET_KEY`, database credentials, service-role keys, provider tokens, and webhook secrets after suspected exposure.
- Keep only `VITE_*` public configuration, publishable/anon keys, and `DUKAAN_API_BASE_URL` in client builds.
- Restrict production database network access to approved egress ranges when operationally possible, and enforce TLS.
- Review Render and Supabase member access quarterly; require MFA for administrators.

The checked-in production templates contain names and placeholders only. `render.yaml` prompts for secrets at Blueprint creation and injects the private queue connection without exposing it publicly.

## API and platform controls

- TLS redirect, secure cookies, HSTS, allowed hosts, and exact CORS origins are enabled in production.
- `/healthz/` reveals process health only; `/readyz/` reveals no credentials or internal exception detail.
- Apply request/body limits, rate limits, and tighter limits to authentication, assistant, upload, and export endpoints.
- Return stable public error codes; send stack traces only to protected observability.
- Log request ID, tenant ID, actor ID, route, result, and duration. Redact tokens, phone numbers, free-text notes, OCR text, and object URLs.
- Protect admin endpoints with strong authentication, least privilege, and preferably network restrictions; do not expose a default staff account.

## Receipt and attachment safety

- Buckets are private. Issue short-lived signed URLs only after a tenant-scoped authorization check.
- Enforce size, MIME allowlist, extension, and decoded-file validation; do not trust filename or `Content-Type` alone.
- Generate random object keys prefixed by tenant and attachment IDs; discard user paths.
- Quarantine files until malware/format checks and OCR processing finish.
- Strip unsafe metadata when producing derivatives. Never serve active content inline from the application origin.
- Define retention/deletion behavior and record deletion audits.

## Supply chain and change control

GitHub Actions run CodeQL, Python/npm audits, dependency review, and secret scanning. Dependabot covers Actions, npm, Python, and Dart packages. Branch protection should require the `Required CI gate` and security review for authentication, tenant filtering, financial posting, migrations, upload handling, and deployment changes.

Action references use maintained major-version tags so Dependabot can update them. A hardened organization may pin actions to reviewed commit SHAs and use an allowlist.

## Response minimum

For a suspected breach: preserve logs, stop the affected path, revoke exposed credentials, prevent further cross-tenant access, assess affected tenants/time range, and follow [incident response](runbooks/incident-response.md). Never erase audit evidence during containment.

## Launch gates

- Production and staging are isolated.
- Restore has been rehearsed and the evidence recorded.
- Tenant isolation tests pass.
- CORS/allowed hosts and debug/auth bypass settings are verified from the live environment.
- Private receipt access is tested with both an authorized and a different-tenant user.
- Rate limiting, alert routing, credential rotation owners, and incident contacts are assigned.
- The retired Sites/Vinext placeholder is absent from the production deployment.

## Primary references

- [Django deployment checklist](https://docs.djangoproject.com/en/5.2/howto/deployment/checklist/)
- [Supabase production checklist](https://supabase.com/docs/guides/deployment/going-into-prod)
- [Supabase SSL enforcement](https://supabase.com/docs/guides/platform/ssl-enforcement)
- [Supabase network restrictions](https://supabase.com/docs/guides/platform/network-restrictions)
