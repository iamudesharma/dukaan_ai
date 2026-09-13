"""Durable outbox worker tasks.

``process_outbox_event`` is the single worker entry point for side effects
that must not be lost when the queue drops a message: the intent lives in
Postgres (``tenancy_outboxevent``), the dispatcher claims due rows, and the
worker acknowledges only after durable work is complete. A later dispatcher
run recovers anything the worker never finished.

Idempotency: every task carries the row's ``dedupe_key``. Handlers for
external effects (notifications, provider calls) must key their own
dedupe on it, so redelivery after a crash never double-acts.

Retry: transient failures re-queue with exponential backoff by pushing
``available_at`` into the future (up to MAX_ATTEMPTS); the row returns to
PENDING so any dispatcher pass can reclaim it. Permanent/domain failures
mark the row FAILED with the error recorded for manual review — the
financial records were already committed by the originating transaction,
so nothing is rolled back here.
"""

from __future__ import annotations

import logging
from datetime import timedelta

from celery import shared_task
from django.db import transaction
from django.utils import timezone

from apps.tenancy import rls
from apps.tenancy.models import OutboxEvent

logger = logging.getLogger(__name__)

MAX_ATTEMPTS = 25


def _backoff(attempts: int) -> timedelta:
    seconds = min(60 * (2 ** min(attempts, 6)), 3600)
    return timedelta(seconds=seconds)


@shared_task(
    bind=True,
    autoretry_for=(Exception,),
    retry_backoff=60,
    retry_backoff_max=3600,
    retry_jitter=True,
    max_retries=MAX_ATTEMPTS,
    acks_late=True,
)
def process_outbox_event(self, event_id: str) -> str:
    """Deliver one claimed outbox row; safe to redeliver."""
    from django.db import connection

    with transaction.atomic():
        rls.set_staff_scope(connection)
        try:
            event = OutboxEvent.objects.select_for_update().get(pk=event_id)
        except OutboxEvent.DoesNotExist:
            logger.warning("Outbox event %s no longer exists; acknowledging.", event_id)
            return "missing"
        if event.status == OutboxEvent.Status.PROCESSED:
            return "already-processed"
        try:
            _deliver(event)
        except _PermanentFailure as exc:
            event.status = OutboxEvent.Status.FAILED
            event.last_error = str(exc)[:2000]
            event.processed_at = timezone.now()
            event.save(update_fields=["status", "last_error", "processed_at", "updated_at"])
            logger.exception("Outbox event %s failed permanently.", event_id)
            return "failed"
        event.status = OutboxEvent.Status.PROCESSED
        event.processed_at = timezone.now()
        event.save(update_fields=["status", "processed_at", "updated_at"])
        return "processed"


class _PermanentFailure(Exception):
    """A delivery failure that retrying will not fix (bad payload/route)."""


def _deliver(event: OutboxEvent) -> None:
    """Route one event to its handler. Handlers are local-only for now; each
    provider integration (OCR, WhatsApp, push) lands here behind the same
    dedupe key, never inline in request handling."""
    handler = _HANDLERS.get(event.topic)
    if handler is None:
        raise _PermanentFailure(f"No handler for outbox topic {event.topic!r}")
    handler(event)


def _handle_domain_posted(event: OutboxEvent) -> None:
    # Posting confirmations/notifications fan out from here. Until a provider
    # is configured this is a durable no-op: the row is still marked
    # PROCESSED so dispatch does not retry it forever.
    logger.info(
        "Outbox delivered locally: topic=%s business=%s dedupe=%s",
        event.topic,
        event.business_id,
        event.dedupe_key,
    )


def _handle_domain_reversed(event: OutboxEvent) -> None:
    _handle_domain_posted(event)


def _handle_reminder_send(event: OutboxEvent) -> None:
    """Deliver one reminder via the messaging adapter.

    Idempotent on the outbox dedupe key: an already-SENT reminder is a
    no-op so redelivery after a crash never double-sends. Transient
    provider errors propagate so Celery retries with backoff; the
    financial records were committed long ago, so nothing rolls back.
    """
    from apps.operations.messaging import TransientDeliveryError, send_reminder
    from apps.operations.models import Reminder

    reminder_id = (event.payload or {}).get("reminder_id")
    try:
        reminder = Reminder.objects.select_for_update().get(pk=reminder_id)
    except Exception as exc:
        raise _PermanentFailure(f"Reminder {reminder_id} not found") from exc
    if reminder.status == Reminder.Status.SENT:
        return
    message_id = None
    try:
        message_id = send_reminder(
            channel=reminder.channel,
            phone=(getattr(reminder.party, "phone_e164", "") or ""),
            message=reminder.message,
        )
    except TransientDeliveryError as exc:
        # Missing phone will never resolve by retrying: fail permanently.
        if "No phone number" in str(exc):
            from django.utils import timezone as _tz

            reminder.status = Reminder.Status.FAILED
            reminder.last_error = str(exc)[:2000]
            reminder.save(update_fields=["status", "last_error", "updated_at"])
            raise _PermanentFailure(str(exc)) from exc
        raise
    reminder.status = Reminder.Status.SENT
    reminder.provider_message_id = message_id
    from django.utils import timezone as _tz

    reminder.sent_at = _tz.now()
    reminder.last_error = ""
    reminder.save(
        update_fields=[
            "status",
            "provider_message_id",
            "sent_at",
            "last_error",
            "updated_at",
        ]
    )


def _export_stub_request(params: dict):
    from types import SimpleNamespace

    query = {}
    for key in ("from", "to", "group_by", "location_id"):
        if params.get(key) is not None:
            query[key] = str(params[key])
    return SimpleNamespace(query_params=query)


def _handle_export_run(event: OutboxEvent) -> None:
    """Render an export job file into private storage.

    Idempotent: an already-READY job is a no-op. Unknown reports are
    permanent failures (bad request, retrying will not fix it).
    """
    import csv
    import io

    from django.core.files.base import ContentFile

    from apps.operations.models import ExportJob
    from apps.operations.pdf import render_simple_pdf
    from apps.operations.reports import REPORT_BUILDERS, build_report, report_csv

    export_id = (event.payload or {}).get("export_id")
    try:
        job = ExportJob.objects.select_for_update().get(pk=export_id)
    except Exception as exc:
        raise _PermanentFailure(f"Export {export_id} not found") from exc
    if job.status == ExportJob.Status.READY:
        return
    if job.report not in REPORT_BUILDERS:
        job.status = ExportJob.Status.FAILED
        job.error = f"Unknown report {job.report!r}"
        job.save(update_fields=["status", "error", "updated_at"])
        raise _PermanentFailure(job.error)
    job.status = ExportJob.Status.PROCESSING
    job.save(update_fields=["status", "updated_at"])
    try:
        params = dict(job.params or {})
        location_ids = params.get("location_ids") or []
        stub = _export_stub_request(params)
        data = build_report(
            job.report,
            request=stub,
            business_id=str(job.business_id),
            location_ids=location_ids,
        )
        headers, rows = report_csv(name=job.report, data=data)
        if job.format == ExportJob.Format.PDF:
            lines = [" | ".join(headers)]
            for row in rows:
                lines.append(" | ".join(str(cell) for cell in row))
            pdf_bytes = render_simple_pdf(title=f"{job.report} export", lines=lines)
            filename = f"exports/{job.pk}.pdf"
            job.file.save(filename, ContentFile(pdf_bytes), save=False)
        else:
            buffer = io.StringIO()
            writer = csv.writer(buffer)
            writer.writerow(headers)
            writer.writerows(rows)
            filename = f"exports/{job.pk}.csv"
            job.file.save(filename, ContentFile(buffer.getvalue().encode("utf-8")), save=False)
    except _PermanentFailure:
        raise
    except Exception as exc:
        job.status = ExportJob.Status.FAILED
        job.error = str(exc)[:2000]
        job.save(update_fields=["status", "error", "updated_at"])
        raise _PermanentFailure(job.error) from exc
    job.status = ExportJob.Status.READY
    job.error = ""
    job.save(update_fields=["status", "file", "error", "updated_at"])


def _handle_invoice_generate(event: OutboxEvent) -> None:
    """Render a sale invoice PDF into private storage.

    Idempotent: an already-READY attachment is a no-op. The attachment row
    is the idempotency record (unique per business+kind+sale), so a retry
    never creates a second invoice file.
    """
    from django.core.files.base import ContentFile

    from apps.operations.models import Attachment, Sale
    from apps.operations.pdf import invoice_lines, render_simple_pdf

    attachment_id = (event.payload or {}).get("attachment_id")
    try:
        attachment = Attachment.objects.select_for_update().get(pk=attachment_id)
    except Exception as exc:
        raise _PermanentFailure(f"Attachment {attachment_id} not found") from exc
    if attachment.status == Attachment.Status.READY and attachment.file:
        return
    try:
        sale = (
            Sale.objects.filter(pk=attachment.sale_id)
            .select_related("business")
            .prefetch_related("lines__product")
            .get()
        )
    except Exception as exc:
        attachment.status = Attachment.Status.FAILED
        attachment.error = "Sale not found"
        attachment.save(update_fields=["status", "error", "updated_at"])
        raise _PermanentFailure(attachment.error) from exc
    try:
        items = [
            f"{line.quantity} x {(getattr(line.product, 'name', None) or 'Item')} - "
            f"Rs {line.line_total_minor / 100:,.2f}"
            for line in sale.lines.all()
        ]
        party = sale.buyer_name or "Walk-in"
        pdf_bytes = render_simple_pdf(
            title=f"Invoice {sale.number}",
            lines=invoice_lines(
                number=sale.number,
                business=sale.business.name,
                party=party,
                total_minor=sale.grand_total_minor,
                items=items,
            ),
        )
        filename = f"invoices/{attachment.pk}.pdf"
        attachment.file.save(filename, ContentFile(pdf_bytes), save=False)
        attachment.mime_type = "application/pdf"
        attachment.size_bytes = len(pdf_bytes)
    except Exception as exc:
        attachment.status = Attachment.Status.FAILED
        attachment.error = str(exc)[:2000]
        attachment.save(update_fields=["status", "error", "updated_at"])
        raise _PermanentFailure(attachment.error) from exc
    attachment.status = Attachment.Status.READY
    attachment.error = ""
    attachment.save(
        update_fields=["status", "file", "mime_type", "size_bytes", "error", "updated_at"]
    )


def _handle_proposal_extract(event: OutboxEvent) -> None:
    """Extract bill text for a PROCESSING proposal, then finalize it.

    Idempotent: attachments already carrying extracted_text are skipped, and
    finalize is a no-op once the proposal leaves PROCESSING — redelivery
    after a crash resumes instead of duplicating.
    """
    from apps.assistant.models import AssistantProposal
    from apps.assistant.services import finalize_proposal_extraction
    from apps.operations.extraction import extract_text
    from apps.operations.models import Attachment

    proposal_id = (event.payload or {}).get("proposal_id")
    try:
        proposal = AssistantProposal.objects.get(pk=proposal_id)
    except Exception as exc:
        raise _PermanentFailure(f"Proposal {proposal_id} not found") from exc
    if proposal.status != AssistantProposal.Status.PROCESSING:
        return
    for attachment in Attachment.objects.filter(
        proposal_id=proposal.pk, business_id=proposal.business_id
    ):
        if attachment.extracted_text or not attachment.file:
            continue
        try:
            text, _note = extract_text(
                filename=attachment.original_name,
                mime_type=attachment.mime_type,
                file_path=attachment.file.path,
            )
        except Exception:
            logger.exception("Attachment text extraction failed")
            continue
        attachment.extracted_text = text[:5000]
        attachment.save(update_fields=["extracted_text", "updated_at"])
    finalize_proposal_extraction(proposal.pk)


_HANDLERS = {
    "sale.posted": _handle_domain_posted,
    "purchase.posted": _handle_domain_posted,
    "payment.posted": _handle_domain_posted,
    "expense.posted": _handle_domain_posted,
    "transfer.posted": _handle_domain_posted,
    "sale.reversed": _handle_domain_reversed,
    "purchase.reversed": _handle_domain_reversed,
    "payment.reversed": _handle_domain_reversed,
    "expense.reversed": _handle_domain_reversed,
    "transfer.reversed": _handle_domain_reversed,
    "reminder.send": _handle_reminder_send,
    "export.run": _handle_export_run,
    "invoice.generate": _handle_invoice_generate,
    "proposal.extract": _handle_proposal_extract,
}
