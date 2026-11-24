# Production launch checklist

This is the external/operational work that cannot be completed from source code
alone. Record an owner and evidence for every item before accepting customer
data.

## Accounts and credentials

- [ ] Separate staging and production Postgres projects (Neon or Supabase).
- [ ] Paid Postgres plan with automated backups and point-in-time recovery.
- [ ] Private `business-documents` Storage bucket; no public policy.
- [ ] Production attachment scanner configured; quarantine fails closed and expired-object purge is scheduled.
- [ ] FCM project/service account configured, or push explicitly disabled; reminder retry/disable behavior tested.
- [ ] Separate encrypted copy of receipt objects with checksum manifests.
- [ ] Render services in Singapore with custom domains and certificates.
- [ ] Secrets stored only in Render/Supabase/GitHub secret controls.
- [ ] Alert owner, incident contact, credential-rotation owner, and budget alerts assigned.

## Database

- [ ] Operator role owns tables and runs migrations.
- [ ] Runtime API/worker/scheduler use `DUKAAN_APP_DATABASE_URL` with the least-privilege role.
- [ ] TLS is required; transaction-mode pooling is not used.
- [ ] Restore drill completed within the documented RPO/RTO.
- [ ] Cross-tenant negative tests pass on PostgreSQL.

## SMS

- [ ] MSG91 KYC complete.
- [ ] DLT Principal Entity, sender/header, and OTP content template approved.
- [ ] `MSG91_AUTH_KEY` and `MSG91_OTP_TEMPLATE_ID` configured.
- [ ] Render outbound IPs allowlisted in MSG91.
- [ ] `SMS_ENABLED=true` and `OTP_EXPOSE_DEV_CODE=false`.
- [ ] Real OTP delivery and reset tested on multiple Indian carriers.

## Gmail

- [ ] Google Cloud project with Gmail API enabled.
- [ ] OAuth consent screen configured and verified for `gmail.readonly`.
- [ ] Exact production callback URI registered.
- [ ] `GMAIL_TOKEN_ENCRYPTION_KEY` generated and stored securely.
- [ ] Connect, disconnect/revoke, list, import, and token refresh tested.
- [ ] Imported Gmail facts remain review-only and never post automatically.

## AI and OCR

- [ ] `AI_API_KEY` configured for typed extraction; spend limits and alerts enabled.
- [ ] Provider data-handling terms approved for customer data.
- [ ] Rust `doc-extractor` service deployed with OCRia-nano-1 provisioned.
- [ ] OCRia-nano-1 model licence reviewed for the intended commercial use.
- [ ] `OCR_API_URL` and optional `OCR_API_TOKEN` configured on the DukaanAI worker.
- [ ] Real receipt image and multi-page PDF OCR tested through the service.
- [ ] OCR output is always reviewed before confirmation.

## Android

- [ ] Production keystore generated and stored in an approved secret manager.
- [ ] `android/key.properties` supplied in CI or equivalent environment variables.
- [ ] Release build is not debug-signed.
- [ ] Cleartext traffic is disabled in release.
- [ ] Signed AAB/APK installed and smoke-tested on a physical device.

## Release smoke

- [ ] `/healthz/`, `/readyz/`, and `/api/docs/` pass.
- [ ] Signup/login/OTP and business onboarding pass.
- [ ] Idempotent sale, payment, reversal, and stock movement pass.
- [ ] Weighted-average valuation/COGS, split payment reallocation, and CSV dry-run/confirm pass without fabricating missing costs.
- [ ] Owner invitation acceptance/revocation and all-device session revocation pass; password reset invalidates old tokens.
- [ ] Original and reversed-sale invoice PDFs render exact money/GST and Hindi text correctly.
- [ ] Queue loss/retry and outbox recovery pass.
- [ ] Authorized and cross-tenant private receipt access tested.
- [ ] Web SPA direct routes and mobile API base URL verified.
- [ ] Required CI gate and branch protection enabled.
- [ ] Rollback release remains selectable.
