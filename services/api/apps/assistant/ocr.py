"""OCR image and PDF attachments through the doc-extractor HTTP service.

The client uses only Python's standard library. Document bytes are sent directly
to the configured service, the recognized text is read with a strict size cap,
and the remote job is deleted on a best-effort basis after every outcome.
"""

from __future__ import annotations

import http.client
import json
import logging
import secrets
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass

from django.conf import settings

logger = logging.getLogger(__name__)

DEFAULT_MAX_BYTES = 8 * 1024 * 1024
DEFAULT_MAX_RESULT_BYTES = 2 * 1024 * 1024
MAX_JSON_RESPONSE_BYTES = 1024 * 1024
MAX_PDF_PAGES = 5
SUPPORTED_MIMES = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "application/pdf": "pdf",
}
TERMINAL_STATES = {"completed", "failed", "cancelled"}
ACTIVE_STATES = {"queued", "running"}


@dataclass
class OCRResult:
    text: str
    engine: str
    page_count: int = 1


class OCRError(Exception):
    """OCR could not produce a trustworthy result.

    ``code`` lets the worker distinguish configuration, timeout, size, and
    service failures while exposing only a stable, user-safe blocker.
    """

    def __init__(self, message: str, *, code: str = "ocr-failed", retryable: bool = True) -> None:
        super().__init__(message)
        self.code = code
        self.retryable = retryable


def _positive_int(name: str, default: int) -> int:
    try:
        value = int(getattr(settings, name, default))
    except (TypeError, ValueError):
        return default
    return value if value > 0 else default


def _positive_float(name: str, default: float) -> float:
    try:
        value = float(getattr(settings, name, default))
    except (TypeError, ValueError):
        return default
    return value if value > 0 else default


def _validated_base_url(value: object) -> str:
    base = str(value or "").strip().rstrip("/")
    if not base or any(ord(character) < 32 or ord(character) == 127 for character in base):
        raise OCRError("OCR service URL is not configured.", code="unavailable", retryable=False)
    try:
        parsed = urllib.parse.urlsplit(base)
        port = parsed.port
        hostname = parsed.hostname
    except ValueError as exc:
        raise OCRError("OCR service URL is invalid.", code="unavailable", retryable=False) from exc
    if (
        parsed.scheme.lower() not in {"http", "https"}
        or not parsed.netloc
        or not hostname
        or parsed.username is not None
        or parsed.password is not None
        or parsed.query
        or parsed.fragment
        or port == 0
    ):
        raise OCRError(
            "OCR service URL must be an HTTP(S) base URL.",
            code="unavailable",
            retryable=False,
        )
    return base


def _close_response(response: object) -> None:
    close = getattr(response, "close", None)
    if callable(close):
        try:
            close()
        except Exception:
            # Closing a failed response must never replace the OCR outcome.
            pass


class DocExtractorOCR:
    """Stdlib HTTP client for the Rust doc-extractor extraction API."""

    def __init__(self) -> None:
        self.base_url = _validated_base_url(
            getattr(settings, "OCR_API_URL", "http://127.0.0.1:8790")
        )
        self.token = str(getattr(settings, "OCR_API_TOKEN", "") or "").strip()
        if self.token and any(
            ord(character) < 33 or ord(character) > 126 for character in self.token
        ):
            raise OCRError("OCR service token is invalid.", code="unavailable", retryable=False)
        self.provider = str(getattr(settings, "OCR_PROVIDER", "ocria") or "ocria").strip()
        self.provider = self.provider or "ocria"
        self.languages = str(getattr(settings, "OCR_LANGUAGES", "eng+hin") or "eng+hin").strip()
        self.languages = self.languages or "eng+hin"
        self.request_timeout = _positive_float("OCR_REQUEST_TIMEOUT_SECONDS", 120)
        self.poll_timeout = _positive_float("OCR_POLL_TIMEOUT_SECONDS", 300)
        self.poll_interval = _positive_float("OCR_POLL_INTERVAL_SECONDS", 1)
        self.max_result_bytes = _positive_int("OCR_MAX_RESULT_BYTES", DEFAULT_MAX_RESULT_BYTES)
        provider_label = {
            "ocria": "ocria-nano-1",
            "ocria_nano": "ocria-nano-1",
            "liteparse": "ocria-nano-1",
        }.get(self.provider, self.provider)
        self.name = f"doc-extractor/{provider_label}"

    def _headers(self, *, content_type: str | None = None, accept: str | None = None) -> dict:
        headers = {}
        if content_type:
            headers["Content-Type"] = content_type
        if accept:
            headers["Accept"] = accept
        if self.token:
            headers["Authorization"] = f"Bearer {self.token}"
        return headers

    def _read_limited(self, response: object, limit: int, *, stage: str) -> bytes:
        headers = getattr(response, "headers", None)
        if headers is not None:
            try:
                declared_length = int(headers.get("Content-Length", ""))
            except (AttributeError, TypeError, ValueError):
                declared_length = 0
            if declared_length > limit:
                raise OCRError(
                    "OCR service response exceeds the allowed size.",
                    code="response-too-large",
                    retryable=False,
                )
        try:
            body = response.read(limit + 1)
        except TimeoutError as exc:
            raise OCRError("OCR service request timed out.", code="timeout") from exc
        except (OSError, http.client.HTTPException) as exc:
            raise OCRError("OCR service response could not be read.", code="network-error") from exc
        if not isinstance(body, bytes | bytearray):
            raise OCRError(
                "OCR service returned an invalid response.",
                code="malformed-response",
                retryable=False,
            )
        if len(body) > limit:
            raise OCRError(
                "OCR service response exceeds the allowed size.",
                code="response-too-large",
                retryable=False,
            )
        return bytes(body)

    def _request(
        self,
        path: str,
        *,
        method: str,
        body: bytes | None = None,
        content_type: str | None = None,
        accept: str | None = None,
        limit: int = MAX_JSON_RESPONSE_BYTES,
        timeout: float | None = None,
        stage: str,
    ) -> bytes:
        request = urllib.request.Request(
            f"{self.base_url}{path}",
            data=body,
            headers=self._headers(content_type=content_type, accept=accept),
            method=method,
        )
        try:
            response = urllib.request.urlopen(
                request, timeout=self.request_timeout if timeout is None else timeout
            )
        except urllib.error.HTTPError as exc:
            status = exc.code
            _close_response(exc)
            logger.warning("OCR service HTTP error: stage=%s status=%s", stage, status)
            raise OCRError(
                "OCR service rejected the request.",
                code="http-error",
                retryable=status in {408, 425, 429} or status >= 500,
            ) from exc
        except urllib.error.URLError as exc:
            if isinstance(exc.reason, TimeoutError):
                raise OCRError("OCR service request timed out.", code="timeout") from exc
            raise OCRError("OCR service could not be reached.", code="network-error") from exc
        except TimeoutError as exc:
            raise OCRError("OCR service request timed out.", code="timeout") from exc
        except (OSError, http.client.HTTPException, UnicodeError) as exc:
            raise OCRError("OCR service request failed.", code="network-error") from exc

        try:
            status = getattr(response, "status", None)
            if not isinstance(status, int):
                getcode = getattr(response, "getcode", None)
                status = getcode() if callable(getcode) else None
            if not isinstance(status, int):
                status = 200
            if not 200 <= status < 300:
                logger.warning("OCR service HTTP error: stage=%s status=%s", stage, status)
                raise OCRError(
                    "OCR service rejected the request.",
                    code="http-error",
                    retryable=status in {408, 425, 429} or status >= 500,
                )
            return self._read_limited(response, limit, stage=stage)
        finally:
            _close_response(response)

    def _decode_json(self, body: bytes, *, stage: str) -> dict:
        try:
            payload = json.loads(body.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError, RecursionError) as exc:
            raise OCRError(
                "OCR service returned malformed JSON.",
                code="malformed-response",
                retryable=False,
            ) from exc
        if not isinstance(payload, dict):
            raise OCRError(
                "OCR service returned an invalid job response.",
                code="malformed-response",
                retryable=False,
            )
        if payload.get("error") and "state" not in payload and "id" not in payload:
            raise OCRError("OCR service reported an error.", code="service-error", retryable=False)
        return payload

    def _json_request(self, path: str, *, method: str, stage: str, **kwargs) -> dict:
        body = self._request(
            path,
            method=method,
            accept="application/json",
            stage=stage,
            **kwargs,
        )
        return self._decode_json(body, stage=stage)

    def _multipart_body(
        self, document_bytes: bytes, *, mime: str, is_pdf: bool
    ) -> tuple[bytes, str]:
        boundary = f"dukaan-ocr-{secrets.token_hex(16)}"
        options = {
            "ocr": True,
            "ocr_provider": self.provider,
            "languages": self.languages,
            "result_format": "text",
            "vision": False,
            "interpret_diagrams": False,
        }
        if is_pdf:
            options["pages"] = f"1-{MAX_PDF_PAGES}"
        filename = f"document.{SUPPORTED_MIMES[mime]}"
        body = b"".join(
            (
                f"--{boundary}\r\n".encode(),
                (
                    f'Content-Disposition: form-data; name="file"; filename="{filename}"\r\n'
                    f"Content-Type: {mime}\r\n\r\n"
                ).encode(),
                document_bytes,
                b"\r\n",
                f"--{boundary}\r\n".encode(),
                b'Content-Disposition: form-data; name="options"\r\n',
                b"Content-Type: application/json\r\n\r\n",
                json.dumps(options, separators=(",", ":"), ensure_ascii=False).encode("utf-8"),
                b"\r\n",
                f"--{boundary}--\r\n".encode(),
            )
        )
        return body, f"multipart/form-data; boundary={boundary}"

    def _submit(self, document_bytes: bytes, *, mime: str, is_pdf: bool) -> str:
        body, content_type = self._multipart_body(document_bytes, mime=mime, is_pdf=is_pdf)
        payload = self._json_request(
            "/v1/extractions",
            method="POST",
            stage="submit",
            body=body,
            content_type=content_type,
        )
        job_id = payload.get("id")
        if not isinstance(job_id, str) or not job_id.strip() or len(job_id) > 512:
            raise OCRError(
                "OCR service returned an invalid job id.",
                code="malformed-response",
                retryable=False,
            )
        return job_id

    def _wait_for_completion(self, job_id: str) -> dict:
        encoded_id = urllib.parse.quote(job_id, safe="")
        deadline = time.monotonic() + self.poll_timeout
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise OCRError("OCR job timed out.", code="timeout")
            job = self._json_request(
                f"/v1/extractions/{encoded_id}",
                method="GET",
                stage="poll",
                timeout=min(self.request_timeout, remaining),
            )
            state = job.get("state")
            if not isinstance(state, str) or state not in TERMINAL_STATES | ACTIVE_STATES:
                raise OCRError(
                    "OCR service returned an invalid job state.",
                    code="malformed-response",
                    retryable=False,
                )
            if state == "completed":
                return job
            if state == "failed":
                raise OCRError("OCR job failed.", code="job-failed", retryable=False)
            if state == "cancelled":
                raise OCRError("OCR job was cancelled.", code="job-cancelled", retryable=False)
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise OCRError("OCR job timed out.", code="timeout")
            time.sleep(min(self.poll_interval, remaining))

    def _result_text(self, job_id: str) -> str:
        encoded_id = urllib.parse.quote(job_id, safe="")
        body = self._request(
            f"/v1/extractions/{encoded_id}/result?format=text",
            method="GET",
            accept="text/plain",
            limit=self.max_result_bytes,
            stage="result",
        )
        try:
            text = body.decode("utf-8").strip()
        except UnicodeDecodeError as exc:
            raise OCRError(
                "OCR service returned invalid UTF-8 text.",
                code="malformed-response",
                retryable=False,
            ) from exc
        if text.startswith("{"):
            try:
                payload = json.loads(text)
            except (json.JSONDecodeError, RecursionError):
                payload = None
            if isinstance(payload, dict) and payload.get("error"):
                raise OCRError(
                    "OCR service reported an error.", code="service-error", retryable=False
                )
        if not text:
            return ""
        return text

    def _cleanup(self, job_id: str) -> None:
        encoded_id = urllib.parse.quote(job_id, safe="")
        try:
            self._request(
                f"/v1/extractions/{encoded_id}",
                method="DELETE",
                stage="cleanup",
            )
        except Exception:
            # Retention cleanup is best effort and must not hide the OCR result.
            logger.warning("OCR service cleanup failed.")

    @staticmethod
    def _reject_provider_fallback(job: dict) -> None:
        """Reject remote fallback text instead of mislabelling it as OCRia."""
        messages = []
        warnings = job.get("warnings")
        if isinstance(warnings, list):
            messages.extend(warning for warning in warnings if isinstance(warning, str))
        failures = job.get("unit_failures")
        if isinstance(failures, list):
            for failure in failures:
                if isinstance(failure, dict):
                    messages.extend(
                        failure[key]
                        for key in ("code", "message")
                        if isinstance(failure.get(key), str)
                    )
        for message in messages:
            lowered = message.lower()
            tesseract_fallback = "tesseract" in lowered and any(
                marker in lowered
                for marker in ("fallback", "fell back", "falling back", "used", "instead")
            )
            ocria_unavailable = "ocria" in lowered and any(
                marker in lowered
                for marker in ("unavailable", "not available", "missing", "fallback")
            )
            if tesseract_fallback or ocria_unavailable:
                raise OCRError(
                    "The configured OCR provider is unavailable.",
                    code="unavailable",
                    retryable=False,
                )

    @staticmethod
    def _page_count(job: dict, *, is_pdf: bool) -> int:
        total = job.get("total")
        if isinstance(total, bool) or not isinstance(total, int) or total < 1:
            return 1
        return min(total, MAX_PDF_PAGES) if is_pdf else total

    def recognize(self, document_bytes: bytes, *, mime: str) -> OCRResult:
        """Recognize one allowed document without downloading OCR models."""
        if not getattr(settings, "OCR_ENABLED", True):
            raise OCRError("OCR is disabled.", code="disabled", retryable=False)
        limit = _positive_int("ATTACHMENT_MAX_BYTES", DEFAULT_MAX_BYTES)
        if not document_bytes:
            raise OCRError("Document is empty.", code="empty-document", retryable=False)
        if len(document_bytes) > limit:
            raise OCRError(
                "Document exceeds the attachment limit.", code="oversize", retryable=False
            )
        normalized_mime = (mime or "").split(";", 1)[0].strip().lower()
        if normalized_mime not in SUPPORTED_MIMES:
            raise OCRError("Unsupported document type.", code="unsupported", retryable=False)
        is_pdf = normalized_mime == "application/pdf"

        job_id = self._submit(document_bytes, mime=normalized_mime, is_pdf=is_pdf)
        try:
            job = self._wait_for_completion(job_id)
            self._reject_provider_fallback(job)
            text = self._result_text(job_id)
            return OCRResult(
                text=text,
                engine=self.name,
                page_count=self._page_count(job, is_pdf=is_pdf),
            )
        finally:
            self._cleanup(job_id)


def get_ocr_engine() -> DocExtractorOCR:
    """Return the configured doc-extractor HTTP OCR engine."""
    return DocExtractorOCR()
