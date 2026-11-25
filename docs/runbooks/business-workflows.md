# Business workflows and operational jobs

This runbook covers invitations, session revocation, invoices, imports,
valuation, payment allocation, reminders, and attachment retention. All endpoints
are under `/api/v1/` and remain subject to authentication, business/location
membership, role checks, and PostgreSQL row-level security.

## Invitations and sessions

Owners manage invitations at `/api/v1/invitations/`:

- `POST` with `business`, `invitee_phone`, `role`, optional `locations`, and
  optional `expires_at` creates a hashed, expiring invitation.
- The raw token is returned **once**. Store it only in the intended delivery
  channel; API list/detail responses never contain the token or its digest.
- `GET ?business_id=...` lists safe invitation metadata.
- `POST /api/v1/invitations/{id}/revoke/` revokes a pending invitation.
- `POST /api/v1/invitations/accept/` accepts a token as the authenticated phone
  owner. Phone, expiry, business, role, and location validity are rechecked.

`POST /api/v1/auth/sessions/revoke-all/` requires the current password or a valid
verification code. It increments the user's token version, invalidating every
existing access and refresh token. Password change and password reset do the
same automatically. Clients must clear local tokens and sign in again.

## Sale invoices

`GET /api/v1/invoices/sales/{sale_id}/pdf/` renders an A4 GST-style PDF directly
from the posted sale. It includes seller/buyer details, GSTIN, HSN/SAC, quantity,
taxable value, CGST/SGST/IGST, totals, paid/due, and amount in words. Money is
formatted from integer paise.

The endpoint creates no mutable invoice row and no second ledger. Reversed sales
render as revision 1 with a VOID watermark, reversal timestamp/reason, and source
fingerprint. Responses use `application/pdf`, a safe attachment filename,
`Cache-Control: private, no-store`, and `X-Content-Type-Options: nosniff`.

## CSV imports

Manager/owner import endpoints:

- `POST /api/v1/imports/products/`
- `POST /api/v1/imports/parties/`
- `GET /api/v1/imports/`
- `GET /api/v1/imports/{job_id}/`
- `POST /api/v1/imports/{job_id}/confirm/`

Uploads are multipart with `business_id`, `file`, optional `dry_run`, and
`duplicate_strategy=UPDATE|SKIP`. The default limits are 2 MiB and 5,000 rows.
UTF-8, headers, field lengths, numeric precision, phone/GSTIN/state formats, and
pack completeness are validated before confirmation. Raw CSV bytes are never
stored in Postgres; only normalized rows, filename, size, digest, and errors are
retained.

Product columns:

```text
name,sku,base_unit,hsn_sac,gst_bps,low_stock_threshold,
pack_name,pack_conversion,retail_price_minor,wholesale_price_minor
```

Only `name` is required. If any pack column is supplied, all four pack columns
must be present. Party columns are:

```text
name,kind,phone,gstin,state,address
```

`name` and `kind` are required. Confirmation is transactional and idempotent;
duplicate rows update or skip deterministically and write audit/outbox records.
An import never posts sales or purchases.

## Valuation and payment allocation

`GET /api/v1/reports/valuation/?business_id=...&location_id=...` reports quantity,
weighted-average unit cost, inventory value, COGS, and gross profit. Optional
`date_from`/`date_to` limit the sales metrics. Purchases create durable cost
layers; sales consume weighted-average cost and store COGS on each sale line.
Reversals restore the original layers.

Legacy stock or sales without cost evidence remain explicitly unknown. Inventory
value or gross profit is `null` when incomplete; the API never fabricates margin
from a selling price.

Managers/owners use:

- `GET /api/v1/payments/allocation-review/?business_id=...` for payments,
  allocation totals, unallocated amounts, and outstanding sale/purchase
  documents.
- `POST /api/v1/payments/{id}/reallocate/` with replacement `allocations`, a
  `reason`, and an `idempotency_key`.

Reallocation is atomic, audited, idempotent, and rejects over-allocation,
cross-party documents, invalid directions, and non-postable documents. Cashiers
cannot access valuation, supplier payments, or allocation review.

## Push notifications and reminders

Notification devices and reminders are user/business scoped:

- `GET/POST /api/v1/integrations/notifications/devices/`
- `DELETE /api/v1/integrations/notifications/devices/{id}/`
- `GET/POST /api/v1/integrations/notifications/reminders/`
- `GET/PATCH/DELETE /api/v1/integrations/notifications/reminders/{id}/`

Full FCM tokens are write-only credentials and are never returned. Reminder
creation writes the reminder and its outbox intent in one transaction. Delivery
happens only in the worker; request handlers never call FCM. Per-device delivery
records make retries idempotent, and transient failures return the outbox row to
the durable retry queue.

Configure server-only values:

```sh
FCM_ENABLED=true
FCM_PROJECT_ID=...
FCM_SERVICE_ACCOUNT_JSON=...
```

The JSON is a Google service-account object with Firebase Messaging permission.
When FCM is disabled or credentials are missing, delivery fails closed/skips and
secrets are not logged. A client cannot claim push delivery until it has a real
FCM registration token.

## Attachment quarantine and retention

Private uploads receive `scan_status`, quarantine, and retention fields. OCR/STT
and signed reads reject quarantined or expired objects. Configure a scanner with
a dotted implementation path, never a shell command:

```sh
ATTACHMENT_SCANNER=your_package.scanner.AttachmentScanner
ATTACHMENT_QUARANTINE_REQUIRED=true
ATTACHMENT_QUARANTINE_RETENTION_DAYS=7
ATTACHMENT_RETENTION_DAYS=30
```

Production defaults require scanning. A blank scanner quarantines uploads. A
broken configured scanner also quarantines; it never becomes an allow decision.
Trusted local development may explicitly set
`ATTACHMENT_QUARANTINE_REQUIRED=false` to keep the fake/local storage workflow
usable. Do not disable it in production.

The scheduler runs both durable dispatch and a bounded retention pass:

```sh
make api-maintenance
# equivalent:
cd services/api && uv run --locked python manage.py run_scheduled --purge-limit 100
```

Use `purge_expired_attachments --dry-run` to inspect eligibility. Open DRAFT or
READY proposal attachments are retained beyond the ordinary deadline. Object
deletion happens before row deletion; storage failures leave durable retry
evidence and an audit event is written on success. Supabase credentials must be
available to the scheduler for object deletion.
