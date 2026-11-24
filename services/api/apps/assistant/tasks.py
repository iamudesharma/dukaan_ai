"""Voice transcription and image OCR workers (P1/P2).

``transcribe_attachment`` turns one uploaded voice note into a reviewable
proposal; ``ocr_attachment`` does the same for JPEG, PNG, and PDF attachments.
The flow is deliberately boring:

1. Download the bytes with server-side storage credentials (never trust the
   client's "upload finished" claim — a missing object is a retryable
   blocker, not a crash).
2. Transcribe via the configured :mod:`apps.assistant.transcription`
   provider, or recognize text with :mod:`apps.assistant.ocr`. Any failure
   records a blocking question; the text is never guessed and regex parsing
   never runs on an empty string.
3. Feed the recognized text through the existing P0 pipeline
   (``_build_from_content``) and record a new ``ProposalRevision``, so the
   empty placeholder (v1) and the text application (v2) stay auditable.

Idempotency: the task carries the attachment id. A second delivery after a
successful run returns ``already-processed`` without touching the proposal,
so redelivery after a crash never double-applies. A run after a *failed*
run retries normally — the guard only fires when text is already stored.

No automatic Celery retries: every outcome (success or named blocker) is
durable state on the proposal, and raising would roll that state back. The
client re-triggers by re-POSTing ``from-audio`` or ``from-image`` with the
same attachment.
"""

from __future__ import annotations

import logging
from datetime import timedelta

from celery import shared_task
from django.conf import settings
from django.db import transaction
from django.utils import timezone

from apps.tenancy import rls

logger = logging.getLogger(__name__)

TRANSCRIBING_BLOCKER = "Your voice note is being transcribed."
FETCH_FAILED_BLOCKER = "We couldn't fetch your voice note. Please try sending it again."
STT_FAILED_BLOCKER = "Voice transcription failed. Please try sending it again."
STT_EMPTY_BLOCKER = "We couldn't hear anything in your voice note. Please record it again."

READING_IMAGE_BLOCKER = "Your image or PDF is being read."
OCR_FETCH_FAILED_BLOCKER = "We couldn't fetch your image or PDF. Please try uploading it again."
OCR_UNAVAILABLE_BLOCKER = "Image text recognition is unavailable right now. Please try again later."
OCR_FAILED_BLOCKER = "We couldn't read your image or PDF. Please try uploading it again."
OCR_TIMEOUT_BLOCKER = "Reading the image or PDF took too long. Please try again."
OCR_EMPTY_BLOCKER = "We couldn't find any text in the image or PDF. Please upload a clearer one."
OCR_OVERSIZE_BLOCKER = "Your image or PDF is too large. Please attach a smaller file."


def _set_blocker(proposal, message: str) -> None:
    """Replace the processing placeholder with a terminal question."""
    from .services import _record_revision

    proposal.blocking_questions = [message]
    proposal.status = proposal.Status.DRAFT
    proposal.version += 1
    _record_revision(proposal)


@shared_task(bind=True, acks_late=True)
def transcribe_attachment(self, attachment_id: str) -> str:
    """Transcribe one voice attachment into its proposal; safe to redeliver."""
    from django.db import connection

    from .models import AssistantProposal, Attachment
    from .storage import StorageError, get_storage_backend
    from .transcription import TranscriptionError, get_transcriber

    with transaction.atomic():
        rls.set_staff_scope(connection)
        try:
            attachment = Attachment.objects.select_for_update().get(pk=attachment_id)
        except Attachment.DoesNotExist:
            logger.warning("Voice attachment %s no longer exists; acknowledging.", attachment_id)
            return "missing"
        if attachment.kind != Attachment.Kind.VOICE:
            logger.warning("Attachment %s is not voice; marking failed.", attachment_id)
            attachment.status = Attachment.Status.FAILED
            attachment.save(update_fields=["status", "updated_at"])
            return "wrong-kind"
        proposal = attachment.proposal
        if proposal is None:
            logger.warning("Voice attachment %s has no proposal; acknowledging.", attachment_id)
            return "missing-proposal"
        proposal = AssistantProposal.objects.select_for_update().get(pk=proposal.pk)
        if proposal.status in {
            AssistantProposal.Status.CONFIRMED,
            AssistantProposal.Status.CANCELLED,
            AssistantProposal.Status.EXPIRED,
        }:
            return "skipped"
        if attachment.status == Attachment.Status.READY and proposal.content:
            return "already-processed"

        try:
            audio = get_storage_backend().download_bytes(attachment.storage_path)
        except StorageError:
            logger.warning("Voice fetch failed: attachment=%s bytes=unknown", attachment_id)
            _set_blocker(proposal, FETCH_FAILED_BLOCKER)
            return "fetch-failed"
        if not audio:
            logger.warning("Voice attachment %s is empty (0 bytes).", attachment_id)
            _set_blocker(proposal, STT_EMPTY_BLOCKER)
            return "empty-audio"
        limit = int(getattr(settings, "ATTACHMENT_MAX_BYTES", 8 * 1024 * 1024))
        if len(audio) > limit:
            logger.warning(
                "Voice attachment %s exceeds limit: bytes=%d limit=%d",
                attachment_id,
                len(audio),
                limit,
            )
            attachment.status = Attachment.Status.FAILED
            attachment.save(update_fields=["status", "updated_at"])
            _set_blocker(
                proposal,
                "Your voice note is too long. Please record a shorter one.",
            )
            return "oversize-audio"

        try:
            result = get_transcriber().transcribe(audio, proposal.locale, mime=attachment.mime)
        except TranscriptionError as exc:
            # Log shape only: byte counts and engine, never the transcript.
            logger.warning(
                "STT failed: attachment=%s bytes=%d retryable=%s",
                attachment_id,
                len(audio),
                exc.retryable,
            )
            _set_blocker(proposal, STT_FAILED_BLOCKER)
            return "transcription-failed"

        transcript = (result.text or "").strip()
        if not transcript:
            logger.info("STT returned empty transcript: attachment=%s", attachment_id)
            _set_blocker(proposal, STT_EMPTY_BLOCKER)
            return "empty-transcript"

        from apps.tenancy.models import Business, Location

        from .services import _build_from_content, _record_revision

        business = Business.objects.select_for_update().get(pk=proposal.business_id)
        location = Location.objects.select_for_update().get(pk=proposal.location_id)
        command_type, payload, preview, warnings, blockers = _build_from_content(
            transcript, proposal.locale, business, location
        )
        if result.confidence is not None:
            provenance = (
                f"Voice transcript ({result.engine}, "
                f"confidence {result.confidence:.0%}). Review before confirming."
            )
        else:
            provenance = f"Voice transcript ({result.engine}). Review before confirming."
        logger.info(
            "STT applied: attachment=%s bytes=%d chars=%d engine=%s command=%s",
            attachment_id,
            len(audio),
            len(transcript),
            result.engine,
            command_type,
        )
        proposal.content = transcript
        proposal.command_type = command_type
        proposal.payload = payload
        proposal.preview = preview
        proposal.warnings = [provenance, *warnings]
        proposal.blocking_questions = blockers
        proposal.status = (
            AssistantProposal.Status.DRAFT if blockers else AssistantProposal.Status.READY
        )
        proposal.version += 1
        proposal.expires_at = timezone.now() + timedelta(hours=24)
        _record_revision(proposal)
        attachment.status = Attachment.Status.READY
        attachment.save(update_fields=["status", "updated_at"])
        return "processed"


@shared_task(bind=True, acks_late=True)
def ocr_attachment(self, attachment_id: str) -> str:
    """Read one image/PDF into its proposal; safe to redeliver.

    The worker derives tenancy only from server-side attachment/proposal rows,
    verifies their ownership and business/location links, and stores every
    failure as a durable blocker. It never falls back to invented text and
    never posts a domain document: successful OCR only feeds the existing
    review pipeline in ``_build_from_content``.
    """
    from django.db import connection

    from apps.tenancy.models import Business, Location

    from .models import AssistantProposal, Attachment
    from .ocr import OCRError, get_ocr_engine
    from .storage import StorageError, get_storage_backend

    with transaction.atomic():
        rls.set_staff_scope(connection)
        try:
            attachment = Attachment.objects.select_for_update().get(pk=attachment_id)
        except Attachment.DoesNotExist:
            logger.warning("Image attachment %s no longer exists; acknowledging.", attachment_id)
            return "missing"
        if attachment.kind != Attachment.Kind.IMAGE:
            logger.warning("Attachment %s is not an image; marking failed.", attachment_id)
            attachment.status = Attachment.Status.FAILED
            attachment.save(update_fields=["status", "updated_at"])
            return "wrong-kind"
        proposal = attachment.proposal
        if proposal is None:
            logger.warning("Image attachment %s has no proposal; acknowledging.", attachment_id)
            return "missing-proposal"
        proposal = AssistantProposal.objects.select_for_update().get(pk=proposal.pk)
        if proposal.status in {
            AssistantProposal.Status.CONFIRMED,
            AssistantProposal.Status.CANCELLED,
            AssistantProposal.Status.EXPIRED,
        }:
            return "skipped"
        if attachment.status == Attachment.Status.READY and proposal.content:
            return "already-processed"
        if (
            attachment.business_id != proposal.business_id
            or attachment.owner_id != proposal.actor_id
            or not Location.objects.filter(
                pk=proposal.location_id,
                business_id=proposal.business_id,
                is_active=True,
            ).exists()
            or not Business.objects.filter(pk=proposal.business_id, is_active=True).exists()
        ):
            logger.warning("Image attachment %s has an invalid proposal scope.", attachment_id)
            return "wrong-scope"

        limit = int(getattr(settings, "ATTACHMENT_MAX_BYTES", 8 * 1024 * 1024))
        if attachment.size_bytes > limit:
            attachment.status = Attachment.Status.FAILED
            attachment.save(update_fields=["status", "updated_at"])
            _set_blocker(proposal, OCR_OVERSIZE_BLOCKER)
            return "oversize-image"

        try:
            document = get_storage_backend().download_bytes(attachment.storage_path)
        except StorageError:
            logger.warning("Image fetch failed: attachment=%s bytes=unknown", attachment_id)
            _set_blocker(proposal, OCR_FETCH_FAILED_BLOCKER)
            return "fetch-failed"
        if not document:
            _set_blocker(proposal, OCR_EMPTY_BLOCKER)
            return "empty-document"
        if len(document) > limit:
            logger.warning(
                "Image attachment %s exceeds limit: bytes=%d limit=%d",
                attachment_id,
                len(document),
                limit,
            )
            attachment.status = Attachment.Status.FAILED
            attachment.save(update_fields=["status", "updated_at"])
            _set_blocker(proposal, OCR_OVERSIZE_BLOCKER)
            return "oversize-image"

        try:
            result = get_ocr_engine().recognize(document, mime=attachment.mime)
        except OCRError as exc:
            logger.warning(
                "OCR failed: attachment=%s bytes=%d code=%s retryable=%s",
                attachment_id,
                len(document),
                exc.code,
                exc.retryable,
            )
            if exc.code in {"disabled", "unavailable"}:
                _set_blocker(proposal, OCR_UNAVAILABLE_BLOCKER)
                return "ocr-unavailable"
            if exc.code == "oversize":
                attachment.status = Attachment.Status.FAILED
                attachment.save(update_fields=["status", "updated_at"])
                _set_blocker(proposal, OCR_OVERSIZE_BLOCKER)
                return "oversize-image"
            message = OCR_TIMEOUT_BLOCKER if exc.code == "timeout" else OCR_FAILED_BLOCKER
            _set_blocker(proposal, message)
            return "ocr-failed"

        text = (result.text or "").strip()
        if not text:
            logger.info("OCR returned no text: attachment=%s", attachment_id)
            _set_blocker(proposal, OCR_EMPTY_BLOCKER)
            return "empty-text"

        from .services import _build_from_content, _record_revision

        business = Business.objects.select_for_update().get(pk=proposal.business_id)
        location = Location.objects.select_for_update().get(pk=proposal.location_id)
        command_type, payload, preview, warnings, blockers = _build_from_content(
            text, proposal.locale, business, location
        )
        if command_type not in {"SALE", "PURCHASE", "EXPENSE"} or not payload:
            blockers = list(blockers) or [
                "This could not be understood as a sale, purchase, or expense."
            ]
        page_label = "page" if result.page_count == 1 else "pages"
        provenance = (
            f"OCR text ({result.engine}, {result.page_count} {page_label}). "
            "Check the recognized text before confirming."
        )
        logger.info(
            "OCR applied: attachment=%s bytes=%d chars=%d pages=%d engine=%s command=%s",
            attachment_id,
            len(document),
            len(text),
            result.page_count,
            result.engine,
            command_type,
        )
        proposal.content = text
        proposal.command_type = command_type
        proposal.payload = payload
        proposal.preview = preview
        proposal.warnings = [provenance, *warnings]
        proposal.blocking_questions = blockers
        proposal.status = (
            AssistantProposal.Status.DRAFT if blockers else AssistantProposal.Status.READY
        )
        proposal.version += 1
        proposal.expires_at = timezone.now() + timedelta(hours=24)
        _record_revision(proposal)
        attachment.status = Attachment.Status.READY
        attachment.save(update_fields=["status", "updated_at"])
        return "processed"
