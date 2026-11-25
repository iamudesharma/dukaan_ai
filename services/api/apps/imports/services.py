from __future__ import annotations

from decimal import Decimal

from django.db import transaction
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework.exceptions import APIException, ValidationError

from apps.catalog.models import Party, Product, ProductPack
from apps.tenancy.access import require_membership
from apps.tenancy.models import (
    AuditEvent,
    Business,
    IdempotencyRecord,
    Membership,
    OutboxEvent,
)

from .models import ImportJob
from .parsing import parse_csv

IMPORT_ROLES = [Membership.Role.OWNER, Membership.Role.MANAGER]
CONFIRM_SCOPE = "import.confirm"


class ImportConflict(APIException):
    status_code = 409
    default_code = "import_conflict"
    default_detail = "The import cannot be confirmed in its current state."


def _dry_run_payload(parsed, *, business_id: str, kind: str, duplicate_strategy: str) -> dict:
    preview, counts = _preview_rows(
        business_id=business_id,
        kind=kind,
        rows=parsed.rows,
        duplicate_strategy=duplicate_strategy,
    )
    return {
        "dry_run": True,
        "kind": kind,
        "duplicate_strategy": duplicate_strategy,
        "row_count": parsed.row_count,
        "valid_row_count": parsed.valid_row_count,
        "error_count": len(parsed.errors),
        "errors": parsed.errors,
        "created_count": counts["created"],
        "updated_count": counts["updated"],
        "skipped_count": counts["skipped"],
        "preview": preview,
    }


def create_import_job(
    *,
    actor,
    business_id: str,
    kind: str,
    uploaded,
    dry_run: bool,
    duplicate_strategy: str,
) -> tuple[ImportJob | None, dict | None]:
    """Validate an upload and persist only its normalized row snapshot."""
    require_membership(actor, business_id, roles=IMPORT_ROLES)
    parsed = parse_csv(uploaded, kind)
    if dry_run:
        return None, _dry_run_payload(
            parsed,
            business_id=business_id,
            kind=kind,
            duplicate_strategy=duplicate_strategy,
        )

    job = ImportJob.objects.create(
        business_id=business_id,
        user=actor,
        kind=kind,
        status=ImportJob.Status.INVALID if parsed.errors else ImportJob.Status.READY,
        duplicate_strategy=duplicate_strategy,
        row_count=parsed.row_count,
        valid_row_count=parsed.valid_row_count,
        error_count=len(parsed.errors),
        errors=parsed.errors,
        rows=parsed.rows,
        original_filename=parsed.original_filename,
        file_sha256=parsed.file_sha256,
        file_size_bytes=parsed.file_size_bytes,
    )
    return job, None


def _existing_product_keys(business_id: str) -> set[tuple[str, str]]:
    keys: set[tuple[str, str]] = set()
    for name, sku in Product.objects.filter(business_id=business_id).values_list("name", "sku"):
        keys.add(("name", name.casefold()))
        if sku:
            keys.add(("sku", sku.casefold()))
    return keys


def _existing_party_keys(business_id: str) -> set[tuple[str, str]]:
    keys: set[tuple[str, str]] = set()
    rows = Party.objects.filter(business_id=business_id).values_list("name", "phone_e164", "gstin")
    for name, phone, gstin in rows:
        keys.add(("name", name.casefold()))
        if phone:
            keys.add(("phone", phone))
        if gstin:
            keys.add(("gstin", gstin.casefold()))
    return keys


def _row_identity(kind: str, row: dict) -> tuple[str, str]:
    if kind == ImportJob.Kind.PRODUCT:
        if row["sku"]:
            return "sku", row["sku"].casefold()
        return "name", row["name"].casefold()
    if row["gstin"]:
        return "gstin", row["gstin"].casefold()
    if row["phone"]:
        return "phone", row["phone"]
    return "name", row["name"].casefold()


def _add_preview_keys(kind: str, row: dict, keys: set[tuple[str, str]]) -> None:
    if kind == ImportJob.Kind.PRODUCT:
        keys.add(("name", row["name"].casefold()))
        if row["sku"]:
            keys.add(("sku", row["sku"].casefold()))
        return
    keys.add(("name", row["name"].casefold()))
    if row["phone"]:
        keys.add(("phone", row["phone"]))
    if row["gstin"]:
        keys.add(("gstin", row["gstin"].casefold()))


def _preview_rows(
    *, business_id: str, kind: str, rows: list[dict], duplicate_strategy: str
) -> tuple[list[dict], dict[str, int]]:
    """Preview deterministic first-row/last-row duplicate handling without writes."""
    keys = (
        _existing_product_keys(business_id)
        if kind == ImportJob.Kind.PRODUCT
        else _existing_party_keys(business_id)
    )
    counts = {"created": 0, "updated": 0, "skipped": 0}
    preview: list[dict] = []
    for row in rows:
        duplicate = _row_identity(kind, row) in keys
        if duplicate and duplicate_strategy == ImportJob.DuplicateStrategy.SKIP:
            action = "SKIP"
        elif duplicate:
            action = "UPDATE"
        else:
            action = "CREATE"
        count_key = {"CREATE": "created", "UPDATE": "updated", "SKIP": "skipped"}[action]
        counts[count_key] += 1
        preview.append({"row": row["_row"], "action": action})
        _add_preview_keys(kind, row, keys)
    return preview, counts


def _find_product(business_id: str, row: dict) -> Product | None:
    products = Product.objects.select_for_update().filter(business_id=business_id)
    if row["sku"]:
        products = products.filter(sku__iexact=row["sku"])
    else:
        products = products.filter(name__iexact=row["name"])
    return products.order_by("created_at", "pk").first()


def _apply_product_row(business_id: str, row: dict, duplicate_strategy: str) -> str:
    product = _find_product(business_id, row)
    if product is not None and duplicate_strategy == ImportJob.DuplicateStrategy.SKIP:
        return "skipped"

    values = {
        "name": row["name"],
        "sku": row["sku"],
        "base_unit": row["base_unit"],
        "hsn_sac": row["hsn_sac"],
        "tax_rate_bps": row["gst_bps"],
        "low_stock_threshold": Decimal(row["low_stock_threshold"]),
    }
    if product is None:
        product = Product.objects.create(business_id=business_id, **values)
        action = "created"
    else:
        for field, value in values.items():
            setattr(product, field, value)
        product.save(update_fields=[*values, "updated_at"])
        action = "updated"

    pack_data = row.get("pack")
    if not pack_data:
        return action
    pack = (
        product.packs.select_for_update()
        .filter(name__iexact=pack_data["name"])
        .order_by("created_at", "pk")
        .first()
    )
    conversion = Decimal(pack_data["conversion_factor"])
    if (
        pack is not None
        and pack.conversion_factor != conversion
        and (
            pack.sale_lines.exists() or pack.purchase_lines.exists() or pack.transfer_lines.exists()
        )
    ):
        raise ValidationError(
            {
                "_row": [
                    f"Row {row['_row']}: conversion for used pack '{pack.name}' cannot be changed."
                ]
            }
        )
    pack_values = {
        "name": pack_data["name"],
        "conversion_factor": conversion,
        "retail_price_minor": pack_data["retail_price_minor"],
        "wholesale_price_minor": pack_data["wholesale_price_minor"],
    }
    if pack is None:
        ProductPack.objects.create(product=product, **pack_values)
    else:
        for field, value in pack_values.items():
            setattr(pack, field, value)
        pack.save(update_fields=[*pack_values, "updated_at"])
    return action


def _find_party(business_id: str, row: dict) -> Party | None:
    parties = Party.objects.select_for_update().filter(business_id=business_id)
    if row["gstin"]:
        parties = parties.filter(gstin__iexact=row["gstin"])
    elif row["phone"]:
        parties = parties.filter(phone_e164=row["phone"])
    else:
        parties = parties.filter(name__iexact=row["name"])
    return parties.order_by("created_at", "pk").first()


def _apply_party_row(business_id: str, row: dict, duplicate_strategy: str) -> str:
    party = _find_party(business_id, row)
    if party is not None and duplicate_strategy == ImportJob.DuplicateStrategy.SKIP:
        return "skipped"
    values = {
        "name": row["name"],
        "kind": row["kind"],
        "phone_e164": row["phone"],
        "gstin": row["gstin"],
        "state_code": row["state"],
        "address": row["address"],
    }
    if party is None:
        Party.objects.create(business_id=business_id, **values)
        return "created"
    for field, value in values.items():
        setattr(party, field, value)
    party.save(update_fields=[*values, "updated_at"])
    return "updated"


@transaction.atomic
def confirm_import(*, job_id, actor, idempotency_key: str) -> tuple[ImportJob, bool]:
    """Apply a validated snapshot atomically and emit one audit/outbox pair.

    A business lock serializes catalog imports. The job row lock plus the
    stored confirmation key makes retries return the original result without
    repeating writes or events. Duplicate UPDATE imports apply rows in file
    order (last row wins); SKIP imports retain the first row.
    """
    job = get_object_or_404(ImportJob, pk=job_id)
    require_membership(actor, job.business_id, roles=IMPORT_ROLES)
    Business.objects.select_for_update().get(pk=job.business_id)
    job = ImportJob.objects.select_for_update().get(pk=job.pk)

    if job.status == ImportJob.Status.COMPLETED:
        if job.confirmation_key != idempotency_key:
            raise ImportConflict("This import was already confirmed with another key.")
        return job, True
    if job.status != ImportJob.Status.READY or job.errors:
        raise ImportConflict("Only a valid, unconfirmed import can be confirmed.")

    existing_idempotency = IdempotencyRecord.objects.filter(
        business_id=job.business_id,
        actor=actor,
        scope=CONFIRM_SCOPE,
        key=idempotency_key,
    ).first()
    if existing_idempotency is not None:
        if existing_idempotency.result_id == job.pk:
            raise ImportConflict("The import has an incomplete idempotency record; retry safely.")
        raise ImportConflict("This idempotency key belongs to another import.")

    counts = {"created": 0, "updated": 0, "skipped": 0}
    for row in job.rows:
        if job.kind == ImportJob.Kind.PRODUCT:
            action = _apply_product_row(job.business_id, row, job.duplicate_strategy)
        else:
            action = _apply_party_row(job.business_id, row, job.duplicate_strategy)
        counts[action] += 1

    job.status = ImportJob.Status.COMPLETED
    job.created_count = counts["created"]
    job.updated_count = counts["updated"]
    job.skipped_count = counts["skipped"]
    job.confirmed_by = actor
    job.confirmed_at = timezone.now()
    job.confirmation_key = idempotency_key
    job.save(
        update_fields=[
            "status",
            "created_count",
            "updated_count",
            "skipped_count",
            "confirmed_by",
            "confirmed_at",
            "confirmation_key",
            "updated_at",
        ]
    )
    IdempotencyRecord.objects.create(
        business_id=job.business_id,
        actor=actor,
        scope=CONFIRM_SCOPE,
        key=idempotency_key,
        result_type="imports.importjob",
        result_id=job.pk,
    )
    metadata = {
        "import_job_id": str(job.pk),
        "kind": job.kind,
        "row_count": job.row_count,
        "created_count": job.created_count,
        "updated_count": job.updated_count,
        "skipped_count": job.skipped_count,
        "file_sha256": job.file_sha256,
    }
    AuditEvent.objects.create(
        business_id=job.business_id,
        actor=actor,
        event_type="import.confirmed",
        aggregate_type="imports.importjob",
        aggregate_id=job.pk,
        source="API",
        metadata=metadata,
    )
    OutboxEvent.objects.get_or_create(
        dedupe_key=f"import.confirmed:{job.pk}",
        defaults={
            "business_id": job.business_id,
            "topic": "import.confirmed",
            "payload": {"type": "imports.importjob", "id": str(job.pk)},
            "available_at": timezone.now(),
        },
    )
    return job, False
