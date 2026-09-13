"""Text extraction for uploaded bill media.

Pipeline per attachment:

- PDF: embedded text via pypdf (pure Python, no system binaries).
- Photo/audio: AI transcription when the interpreter is enabled; otherwise
  empty — the proposal still links the file and asks the shopkeeper to
  describe it, so nothing is silently invented.

Returns ``(text, provenance_note)``. Empty text is not an error: callers
fold the note into warnings/blockers instead of failing the proposal.
"""

from __future__ import annotations

import logging

logger = logging.getLogger(__name__)


def extract_text(*, filename: str, mime_type: str, file_path: str) -> tuple[str, str]:
    kind = _kind_of(filename, mime_type)
    if kind == "pdf":
        return _extract_pdf(file_path)
    if kind in {"photo", "audio"}:
        return _extract_with_ai(file_path, kind)
    return "", f"Files of type {mime_type or 'unknown'} cannot be read yet."


def _kind_of(filename: str, mime_type: str) -> str:
    mime = (mime_type or "").lower()
    name = (filename or "").lower()
    if mime == "application/pdf" or name.endswith(".pdf"):
        return "pdf"
    if mime.startswith("image/") or name.endswith((".jpg", ".jpeg", ".png", ".webp")):
        return "photo"
    if mime.startswith("audio/") or name.endswith((".mp3", ".m4a", ".wav", ".ogg")):
        return "audio"
    return "unknown"


def _extract_pdf(file_path: str) -> tuple[str, str]:
    try:
        from pypdf import PdfReader
    except ImportError:
        logger.warning("pypdf not installed; PDF text extraction unavailable")
        return "", "The PDF could not be read automatically; please describe the bill."
    try:
        reader = PdfReader(file_path)
        pages = [(page.extract_text() or "").strip() for page in reader.pages]
        text = "\n".join(part for part in pages if part).strip()
    except Exception:
        logger.exception("PDF text extraction failed")
        return "", "The PDF could not be read automatically; please describe the bill."
    if not text:
        return "", "No readable text was found in the PDF; please describe the bill."
    return text[:5000], ""


def _extract_with_ai(file_path: str, kind: str) -> tuple[str, str]:
    from django.conf import settings

    if not getattr(settings, "USE_AI_INTERPRETER", False):
        medium = "photo" if kind == "photo" else "recording"
        return "", (
            f"The {medium} could not be transcribed automatically; "
            "please describe the bill and the proposal will be re-read."
        )
    # No vision/transcription provider is wired yet: same honest fallback.
    # When one lands, it plugs in here behind the existing outbox dedupe key.
    logger.info("AI extraction requested for %s (no provider wired); asking user", file_path)
    medium = "photo" if kind == "photo" else "recording"
    return "", (
        f"The {medium} could not be transcribed automatically; "
        "please describe the bill and the proposal will be re-read."
    )
