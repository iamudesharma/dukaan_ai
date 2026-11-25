"""Private object-storage seam for voice/image uploads (P1/P2).

Bytes never touch Postgres: this module mints short-lived upload tickets
and reads objects back with server-side credentials only. Clients receive
opaque URLs, never keys. ``STORAGE_BACKEND=fake`` (default) keeps local
development and tests hermetic; production sets ``supabase`` with the
server-only service-role key already used for Auth.
"""

from __future__ import annotations

import json
import logging
import re
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from datetime import timedelta
from pathlib import Path

from django.conf import settings
from django.db import DatabaseError
from django.utils import timezone
from django.utils.module_loading import import_string

logger = logging.getLogger(__name__)

VOICE_MIMES = {
    "audio/m4a": "m4a",
    "audio/mp4": "m4a",
    "audio/x-m4a": "m4a",
    "audio/wav": "wav",
}
IMAGE_MIMES = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "application/pdf": "pdf",
}
ALLOWED_MIMES = {**VOICE_MIMES, **IMAGE_MIMES}


class StorageError(Exception):
    """The storage plane failed or answered unexpectedly. Fail closed."""


@dataclass
class UploadTicket:
    path: str
    upload_url: str
    expires_at: object
    headers: dict = field(default_factory=dict)


@dataclass
class ScanResult:
    status: str
    reason_code: str = ""


class AttachmentScanner:
    """Pluggable scanner interface. Implementations must fail closed."""

    name = "base"

    def scan(self, *, data: bytes, mime: str) -> ScanResult:
        raise NotImplementedError


class QuarantineScanner(AttachmentScanner):
    """Secure default: bytes remain unavailable until a real scanner is configured."""

    name = "quarantine-default"

    def scan(self, *, data: bytes, mime: str) -> ScanResult:
        return ScanResult(status="QUARANTINED", reason_code="scanner_not_configured")


class ScanningDisabledScanner(AttachmentScanner):
    """Explicit development-only policy bypass; never selected in production defaults."""

    name = "scanning-policy-disabled"

    def scan(self, *, data: bytes, mime: str) -> ScanResult:
        return ScanResult(status="CLEAN", reason_code="scanning_not_required")


def get_attachment_scanner() -> AttachmentScanner:
    """Resolve ``ATTACHMENT_SCANNER`` as a dotted implementation path.

    A blank scanner quarantines by default. Trusted local development can set
    ``ATTACHMENT_QUARANTINE_REQUIRED=false``; broken configured scanners still
    fail closed and never silently become an allow decision.
    """
    configured = str(getattr(settings, "ATTACHMENT_SCANNER", "") or "").strip()
    if not configured:
        if not getattr(settings, "ATTACHMENT_QUARANTINE_REQUIRED", True):
            return ScanningDisabledScanner()
        return QuarantineScanner()
    try:
        implementation = import_string(configured)
        scanner = implementation() if isinstance(implementation, type) else implementation
        if not callable(getattr(scanner, "scan", None)):
            raise TypeError("scanner has no scan method")
        return scanner
    except Exception:
        logger.warning("Attachment scanner configuration is invalid; quarantining uploads.")
        return QuarantineScanner()


def _scan_attachment(attachment, data: bytes) -> None:
    from .models import Attachment

    scanner = get_attachment_scanner()
    try:
        result = scanner.scan(data=data, mime=attachment.mime)
        status = str(result.status)
        reason_code = str(result.reason_code or "")[:120]
    except Exception:
        status = Attachment.ScanStatus.QUARANTINED
        reason_code = "scanner_error"
    if status not in {Attachment.ScanStatus.CLEAN, Attachment.ScanStatus.QUARANTINED}:
        status = Attachment.ScanStatus.QUARANTINED
        reason_code = "invalid_scanner_result"

    now = timezone.now()
    attachment.scan_status = status
    scanner_name = str(getattr(scanner, "name", type(scanner).__name__))[:80]
    attachment.scan_details = {"scanner": scanner_name}
    if status == Attachment.ScanStatus.CLEAN:
        attachment.quarantined_at = None
        if attachment.retention_expires_at is None:
            attachment.retention_expires_at = now + timedelta(days=30)
    else:
        try:
            days = max(1, int(getattr(settings, "ATTACHMENT_QUARANTINE_RETENTION_DAYS", 7)))
        except (TypeError, ValueError):
            days = 7
        attachment.quarantined_at = now
        attachment.retention_expires_at = now + timedelta(days=days)
        attachment.scan_details["reason_code"] = reason_code
    attachment.save(
        update_fields=[
            "scan_status",
            "quarantined_at",
            "retention_expires_at",
            "scan_details",
            "updated_at",
        ]
    )


_ATTACHMENT_PATH = re.compile(
    r"^(?P<business_id>[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-"
    r"[0-9a-fA-F]{4}-[0-9a-fA-F]{12})/(?P<kind>voice|image)/"
    r"(?P<attachment_id>[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-"
    r"[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\.[a-z0-9]+$"
)


def _attachment_for_path(path: str):
    """Resolve a real attachment path, failing closed if its row is invisible."""
    match = _ATTACHMENT_PATH.fullmatch(path)
    if match is None:
        return None
    from .models import Attachment

    try:
        attachment = Attachment.objects.filter(storage_path=path).first()
        if attachment is None:
            # The server-mediated upload view saves its final path after the
            # write. The path itself carries server-generated tenant/row UUIDs,
            # so a matching pending row can be scanned without trusting input.
            attachment = Attachment.objects.filter(
                pk=match.group("attachment_id"),
                business_id=match.group("business_id"),
                kind=match.group("kind").upper(),
                storage_path="pending",
            ).first()
    except DatabaseError as exc:
        raise StorageError("Attachment security state is unavailable") from exc
    if attachment is None:
        raise StorageError("Attachment record is unavailable")
    return attachment


def _attachment_limit() -> int:
    return max(1, int(getattr(settings, "ATTACHMENT_MAX_BYTES", 8 * 1024 * 1024)))


def _bounded_download(read) -> bytes:
    data = read(_attachment_limit() + 1)
    if len(data) > _attachment_limit():
        raise StorageError("Attachment exceeds the configured size limit")
    return data


def extension_for_mime(mime: str) -> str | None:
    return ALLOWED_MIMES.get((mime or "").lower())


def storage_path_for(*, business_id, kind: str, attachment_id, mime: str) -> str:
    """Tenant-scoped path with no user input: nothing to traverse or spoof."""
    ext = extension_for_mime(mime)
    if ext is None:
        raise StorageError(f"Unsupported upload mime {mime!r}")
    return f"{business_id}/{kind.lower()}/{attachment_id}.{ext}"


class StorageBackend:
    name = "base"

    def presign_upload(self, *, path: str, mime: str, size_bytes: int) -> UploadTicket:
        raise NotImplementedError

    def store_bytes(self, path: str, data: bytes) -> None:
        self._store_bytes(path, data)
        attachment = _attachment_for_path(path)
        if attachment is not None:
            _scan_attachment(attachment, data)

    def _store_bytes(self, path: str, data: bytes) -> None:
        raise NotImplementedError

    def download_bytes(self, path: str) -> bytes:
        attachment = _attachment_for_path(path)
        if attachment is None:
            return self._download_bytes(path)
        if attachment.scan_status == attachment.ScanStatus.QUARANTINED:
            raise StorageError("Attachment is quarantined")
        if (
            attachment.retention_expires_at is not None
            and attachment.retention_expires_at <= timezone.now()
        ):
            raise StorageError("Attachment retention has expired")
        if attachment.safe_for_processing:
            return self._download_bytes(path)

        data = self._download_bytes(path)
        _scan_attachment(attachment, data)
        if not attachment.safe_for_processing:
            raise StorageError("Attachment did not pass security scanning")
        return data

    def _download_bytes(self, path: str) -> bytes:
        raise NotImplementedError

    def _require_clean_for_read(self, path: str) -> None:
        attachment = _attachment_for_path(path)
        if attachment is not None and not attachment.safe_for_processing:
            raise StorageError("Attachment is not available for processing")

    def signed_read_url(self, path: str) -> str:
        raise NotImplementedError

    def delete(self, path: str) -> None:
        """Delete an object. Missing objects are an idempotent success."""
        self._delete(path)

    def delete_bytes(self, path: str) -> None:
        self.delete(path)

    def _delete(self, path: str) -> None:
        raise NotImplementedError


class FakeStorageBackend(StorageBackend):
    """Hermetic stand-in: tickets are opaque, objects live in memory.

    The fake upload URL is not dereferenceable on purpose — end-to-end
    byte flow is proven with the supabase backend or provider fakes, never
    against SQLite. ``store_bytes`` exists so Phase-1 worker tests can
    stage fixtures without a network.
    """

    name = "fake"

    def __init__(self) -> None:
        self.objects: dict[str, bytes] = {}

    def presign_upload(self, *, path: str, mime: str, size_bytes: int) -> UploadTicket:
        ttl = int(getattr(settings, "SIGNED_URL_TTL_SECONDS", 900))
        return UploadTicket(
            path=path,
            upload_url=f"fake://upload/{path}",
            expires_at=timezone.now() + timedelta(seconds=ttl),
            headers={"Content-Type": mime},
        )

    def _store_bytes(self, path: str, data: bytes) -> None:
        self.objects[path] = bytes(data)

    def _download_bytes(self, path: str) -> bytes:
        try:
            data = self.objects[path]
        except KeyError as exc:
            raise StorageError(f"Fake object missing: {path}") from exc
        if len(data) > _attachment_limit():
            raise StorageError("Attachment exceeds the configured size limit")
        return data

    def signed_read_url(self, path: str) -> str:
        self._require_clean_for_read(path)
        return f"fake://read/{path}"

    def _delete(self, path: str) -> None:
        self.objects.pop(path, None)


def _supabase_headers() -> dict[str, str]:
    key = getattr(settings, "SUPABASE_SERVICE_ROLE_KEY", "")
    if not key:
        raise StorageError("SUPABASE_SERVICE_ROLE_KEY is not configured")
    return {"apikey": key, "Authorization": f"Bearer {key}"}


def _supabase_base() -> str:
    base = (getattr(settings, "SUPABASE_URL", "") or "").rstrip("/")
    if not base:
        raise StorageError("SUPABASE_URL is not configured")
    return base


def _supabase_bucket() -> str:
    bucket = getattr(settings, "SUPABASE_STORAGE_BUCKET", "")
    if not bucket:
        raise StorageError("SUPABASE_STORAGE_BUCKET is not configured")
    return bucket


def _post_json(url: str, payload: dict, *, timeout: int = 20) -> dict:
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={**_supabase_headers(), "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return json.loads(response.read().decode() or "{}")
    except urllib.error.HTTPError as exc:
        raise StorageError(f"Storage request failed: HTTP {exc.code}") from exc
    except (OSError, ValueError) as exc:
        raise StorageError(f"Storage request failed: {type(exc).__name__}") from exc


class SupabaseStorageBackend(StorageBackend):
    """Private-bucket backend over the Storage REST API (stdlib only).

    Response shapes are parsed defensively (``url``/``signedURL``/``token``
    variants): a drifted provider answer raises StorageError naming the
    endpoint instead of minting a broken ticket.
    """

    name = "supabase"

    def presign_upload(self, *, path: str, mime: str, size_bytes: int) -> UploadTicket:
        base, bucket = _supabase_base(), _supabase_bucket()
        data = _post_json(f"{base}/storage/v1/object/upload/sign/{bucket}/{path}", {})
        url = data.get("url") or data.get("signedUrl") or data.get("signedURL")
        if not url:
            token = data.get("token")
            if token:
                url = f"{base}/storage/v1/object/upload/{bucket}/{path}?token={token}"
        if not url:
            raise StorageError("Storage endpoint returned no signed upload URL")
        if url.startswith("/"):
            url = base + url
        ttl = int(getattr(settings, "SIGNED_URL_TTL_SECONDS", 900))
        return UploadTicket(
            path=path,
            upload_url=url,
            expires_at=timezone.now() + timedelta(seconds=ttl),
            headers={"Content-Type": mime},
        )

    def _download_bytes(self, path: str) -> bytes:
        base, bucket = _supabase_base(), _supabase_bucket()
        request = urllib.request.Request(
            f"{base}/storage/v1/object/{bucket}/{path}", headers=_supabase_headers()
        )
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return _bounded_download(response.read)
        except urllib.error.HTTPError as exc:
            raise StorageError(f"Storage download failed: HTTP {exc.code}") from exc
        except OSError as exc:
            raise StorageError(f"Storage download failed: {type(exc).__name__}") from exc

    def signed_read_url(self, path: str) -> str:
        self._require_clean_for_read(path)
        base, bucket = _supabase_base(), _supabase_bucket()
        ttl = int(getattr(settings, "SIGNED_URL_TTL_SECONDS", 900))
        data = _post_json(f"{base}/storage/v1/object/sign/{bucket}/{path}", {"expiresIn": ttl})
        url = data.get("signedURL") or data.get("signedUrl") or data.get("url")
        if not url:
            raise StorageError("Storage endpoint returned no signed read URL")
        return base + url if url.startswith("/") else url

    def _store_bytes(self, path: str, data: bytes) -> None:
        base, bucket = _supabase_base(), _supabase_bucket()
        request = urllib.request.Request(
            f"{base}/storage/v1/object/{bucket}/{path}",
            data=data,
            headers={
                **_supabase_headers(),
                "Content-Type": "application/octet-stream",
                "x-upsert": "false",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                response.read()
        except urllib.error.HTTPError as exc:
            raise StorageError(f"Storage upload failed: HTTP {exc.code}") from exc
        except OSError as exc:
            raise StorageError("Storage upload could not be reached") from exc

    def _delete(self, path: str) -> None:
        base, bucket = _supabase_base(), _supabase_bucket()
        request = urllib.request.Request(
            f"{base}/storage/v1/object/{bucket}/{path}",
            headers=_supabase_headers(),
            method="DELETE",
        )
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                response.read()
        except urllib.error.HTTPError as exc:
            if exc.code == 404:
                return
            raise StorageError(f"Storage delete failed: HTTP {exc.code}") from exc
        except OSError as exc:
            raise StorageError(f"Storage delete failed: {type(exc).__name__}") from exc


class LocalStorageBackend(StorageBackend):
    """Project-local private storage for development and local Whisper runs."""

    name = "local"

    def __init__(self) -> None:
        self.root = Path(getattr(settings, "LOCAL_STORAGE_DIR", ".local_storage")).expanduser()

    def _path(self, path: str) -> Path:
        candidate = (self.root / path).resolve()
        if self.root.resolve() not in candidate.parents:
            raise StorageError("Invalid local storage path")
        return candidate

    def _store_bytes(self, path: str, data: bytes) -> None:
        target = self._path(path)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)

    def _download_bytes(self, path: str) -> bytes:
        try:
            with self._path(path).open("rb") as source:
                return _bounded_download(source.read)
        except OSError as exc:
            raise StorageError("Local object missing") from exc

    def signed_read_url(self, path: str) -> str:
        self._require_clean_for_read(path)
        raise StorageError("Local storage does not issue public read URLs")

    def _delete(self, path: str) -> None:
        try:
            self._path(path).unlink(missing_ok=True)
        except OSError as exc:
            raise StorageError("Local object could not be deleted") from exc


def get_storage_backend() -> StorageBackend:
    backend = str(getattr(settings, "STORAGE_BACKEND", "fake") or "fake").lower()
    if backend == "supabase":
        return SupabaseStorageBackend()
    if backend == "local":
        return LocalStorageBackend()
    if backend != "fake":
        logger.warning("Unknown STORAGE_BACKEND=%s; using fake backend", backend)
    return FakeStorageBackend()
