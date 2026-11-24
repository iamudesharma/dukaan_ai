"""Attachment quarantine, retention policy, and storage cleanup."""

import urllib.error
from datetime import timedelta
from unittest.mock import Mock
from uuid import uuid4

import pytest
from django.core.management import call_command
from django.core.management.base import CommandError
from django.utils import timezone

from apps.assistant import storage
from apps.assistant.models import AssistantProposal, Attachment
from apps.assistant.storage import (
    FakeStorageBackend,
    LocalStorageBackend,
    ScanResult,
    StorageError,
    SupabaseStorageBackend,
    get_attachment_scanner,
    storage_path_for,
)
from apps.assistant.tasks import ocr_attachment, transcribe_attachment
from apps.common.models import User
from apps.tenancy.models import AuditEvent, Business, Location, Membership

pytestmark = pytest.mark.django_db


@pytest.fixture(autouse=True)
def require_attachment_scanning(settings):
    settings.ATTACHMENT_QUARANTINE_REQUIRED = True


@pytest.fixture
def retention_scope():
    user = User.objects.create_user(username="retention-owner")
    business = Business.objects.create(name="Retention shop")
    location = Location.objects.create(business=business, code="MAIN", name="Main")
    Membership.objects.create(user=user, business=business, role="OWNER")
    return user, business, location


def _attachment(user, business, *, kind=Attachment.Kind.IMAGE):
    mime = "image/jpeg" if kind == Attachment.Kind.IMAGE else "audio/m4a"
    attachment = Attachment.objects.create(
        business=business,
        owner=user,
        kind=kind,
        mime=mime,
        size_bytes=12,
        storage_path=f"pending-{uuid4()}",
        status=Attachment.Status.READY,
    )
    attachment.storage_path = storage_path_for(
        business_id=business.id,
        kind=kind,
        attachment_id=attachment.id,
        mime=mime,
    )
    attachment.save(update_fields=["storage_path", "updated_at"])
    return attachment


def _proposal(user, business, location, attachment, *, status=AssistantProposal.Status.DRAFT):
    input_type = (
        AssistantProposal.InputType.IMAGE
        if attachment.kind == Attachment.Kind.IMAGE
        else AssistantProposal.InputType.VOICE
    )
    proposal = AssistantProposal.objects.create(
        business=business,
        location=location,
        actor=user,
        input_type=input_type,
        locale="en-IN",
        content="",
        command_type="UNSUPPORTED",
        payload={},
        preview="",
        warnings=[],
        blocking_questions=[],
        status=status,
        expires_at=timezone.now() + timedelta(hours=24),
    )
    attachment.proposal = proposal
    attachment.save(update_fields=["proposal", "updated_at"])
    return proposal


class CleanScanner:
    name = "test-clean"

    def scan(self, *, data: bytes, mime: str) -> ScanResult:
        return ScanResult(status=Attachment.ScanStatus.CLEAN)


class BrokenScanner(CleanScanner):
    name = "test-broken"

    def scan(self, *, data: bytes, mime: str) -> ScanResult:
        raise RuntimeError("scanner secret")


class TestQuarantine:
    def test_explicit_development_policy_can_disable_scanning(self, retention_scope, settings):
        user, business, _ = retention_scope
        settings.ATTACHMENT_QUARANTINE_REQUIRED = False
        attachment = _attachment(user, business)
        backend = FakeStorageBackend()

        backend.store_bytes(attachment.storage_path, b"local-development")

        attachment.refresh_from_db()
        assert attachment.scan_status == Attachment.ScanStatus.CLEAN
        assert attachment.scan_details == {"scanner": "scanning-policy-disabled"}
        assert backend.download_bytes(attachment.storage_path) == b"local-development"

    def test_default_scanner_quarantines_and_blocks_signed_reads(self, retention_scope):
        user, business, _ = retention_scope
        attachment = _attachment(user, business)
        backend = FakeStorageBackend()

        backend.store_bytes(attachment.storage_path, b"document-bytes")

        attachment.refresh_from_db()
        assert attachment.scan_status == Attachment.ScanStatus.QUARANTINED
        assert attachment.quarantined_at is not None
        assert attachment.scan_details["reason_code"] == "scanner_not_configured"
        with pytest.raises(StorageError, match="quarantined"):
            backend.download_bytes(attachment.storage_path)
        with pytest.raises(StorageError, match="not available"):
            backend.signed_read_url(attachment.storage_path)
        assert backend.objects[attachment.storage_path] == b"document-bytes"

    def test_configured_scanner_can_allow_processing(self, retention_scope, settings):
        user, business, _ = retention_scope
        attachment = _attachment(user, business)
        settings.ATTACHMENT_SCANNER = f"{CleanScanner.__module__}.CleanScanner"
        backend = FakeStorageBackend()
        assert get_attachment_scanner().name == "test-clean"

        backend.store_bytes(attachment.storage_path, b"clean-document")

        attachment.refresh_from_db()
        assert attachment.scan_status == Attachment.ScanStatus.CLEAN
        assert attachment.quarantined_at is None
        assert backend.download_bytes(attachment.storage_path) == b"clean-document"
        assert backend.signed_read_url(attachment.storage_path).startswith("fake://read/")

    def test_scanner_errors_fail_closed(self, retention_scope, settings):
        user, business, _ = retention_scope
        attachment = _attachment(user, business)
        settings.ATTACHMENT_SCANNER = f"{BrokenScanner.__module__}.BrokenScanner"
        backend = FakeStorageBackend()

        backend.store_bytes(attachment.storage_path, b"unknown-document")

        attachment.refresh_from_db()
        assert attachment.scan_status == Attachment.ScanStatus.QUARANTINED
        assert attachment.scan_details["reason_code"] == "scanner_error"
        with pytest.raises(StorageError):
            backend.download_bytes(attachment.storage_path)

    @pytest.mark.parametrize(
        "kind,task_name,engine_path,engine_method",
        [
            ("IMAGE", ocr_attachment, "apps.assistant.ocr.get_ocr_engine", "recognize"),
            (
                "VOICE",
                transcribe_attachment,
                "apps.assistant.transcription.get_transcriber",
                "transcribe",
            ),
        ],
    )
    def test_quarantined_bytes_never_reach_ocr_or_stt(
        self, retention_scope, monkeypatch, kind, task_name, engine_path, engine_method
    ):
        user, business, location = retention_scope
        attachment_kind = Attachment.Kind.IMAGE if kind == "IMAGE" else Attachment.Kind.VOICE
        attachment = _attachment(user, business, kind=attachment_kind)
        proposal = _proposal(user, business, location, attachment)
        backend = FakeStorageBackend()
        backend.store_bytes(attachment.storage_path, b"blocked-bytes")
        monkeypatch.setattr(storage, "get_storage_backend", lambda: backend)
        engine = Mock()
        monkeypatch.setattr(engine_path, lambda: engine)

        result = task_name.run(str(attachment.id))

        assert result == "fetch-failed"
        proposal.refresh_from_db()
        assert proposal.content == ""
        getattr(engine, engine_method).assert_not_called()

    def test_expired_clean_attachment_is_not_served(self, retention_scope, settings):
        user, business, _ = retention_scope
        attachment = _attachment(user, business)
        settings.ATTACHMENT_SCANNER = f"{CleanScanner.__module__}.CleanScanner"
        backend = FakeStorageBackend()
        backend.store_bytes(attachment.storage_path, b"clean-but-expired")
        Attachment.objects.filter(pk=attachment.pk).update(
            retention_expires_at=timezone.now() - timedelta(minutes=1)
        )

        with pytest.raises(StorageError, match="retention has expired"):
            backend.download_bytes(attachment.storage_path)


class TestRetentionPurge:
    def test_purge_deletes_only_policy_eligible_objects_and_rows(
        self, retention_scope, monkeypatch
    ):
        user, business, location = retention_scope
        backend = FakeStorageBackend()
        expired = timezone.now() - timedelta(days=1)
        attachments = {}
        for name in ("eligible", "active", "active_quarantined", "terminal", "future"):
            attachment = _attachment(user, business)
            backend.store_bytes(attachment.storage_path, name.encode())
            expiry = expired if name != "future" else timezone.now() + timedelta(days=30)
            Attachment.objects.filter(pk=attachment.pk).update(retention_expires_at=expiry)
            attachments[name] = attachment
        Attachment.objects.filter(pk=attachments["active"].pk).update(
            scan_status=Attachment.ScanStatus.CLEAN,
            quarantined_at=None,
            scan_details={},
        )
        _proposal(user, business, location, attachments["active"])
        _proposal(user, business, location, attachments["active_quarantined"])
        _proposal(
            user,
            business,
            location,
            attachments["terminal"],
            status=AssistantProposal.Status.CANCELLED,
        )
        monkeypatch.setattr(
            "apps.assistant.management.commands.purge_expired_attachments.get_storage_backend",
            lambda: backend,
        )

        call_command("purge_expired_attachments")

        deleted = [attachments[name] for name in ("eligible", "active_quarantined", "terminal")]
        retained = [attachments[name] for name in ("active", "future")]
        assert not Attachment.objects.filter(pk__in=[item.pk for item in deleted]).exists()
        assert Attachment.objects.filter(pk__in=[item.pk for item in retained]).count() == 2
        assert all(item.storage_path not in backend.objects for item in deleted)
        assert all(item.storage_path in backend.objects for item in retained)
        assert AuditEvent.objects.filter(event_type="attachment.purged").count() == 3

    def test_dry_run_keeps_objects_and_rows(self, retention_scope, monkeypatch):
        user, business, _ = retention_scope
        attachment = _attachment(user, business)
        backend = FakeStorageBackend()
        backend.store_bytes(attachment.storage_path, b"retained")
        Attachment.objects.filter(pk=attachment.pk).update(
            retention_expires_at=timezone.now() - timedelta(days=1)
        )
        monkeypatch.setattr(
            "apps.assistant.management.commands.purge_expired_attachments.get_storage_backend",
            lambda: backend,
        )

        call_command("purge_expired_attachments", "--dry-run")

        assert Attachment.objects.filter(pk=attachment.pk).exists()
        assert attachment.storage_path in backend.objects
        assert not AuditEvent.objects.filter(event_type="attachment.purged").exists()

    def test_storage_failure_keeps_row_for_retry(self, retention_scope, monkeypatch):
        user, business, _ = retention_scope
        attachment = _attachment(user, business)
        Attachment.objects.filter(pk=attachment.pk).update(
            retention_expires_at=timezone.now() - timedelta(days=1)
        )
        backend = Mock(name="fake")
        backend.name = "fake"
        backend.delete.side_effect = StorageError("delete unavailable")
        monkeypatch.setattr(
            "apps.assistant.management.commands.purge_expired_attachments.get_storage_backend",
            lambda: backend,
        )

        with pytest.raises(CommandError, match="could not be deleted"):
            call_command("purge_expired_attachments")

        assert Attachment.objects.filter(pk=attachment.pk).exists()
        assert not AuditEvent.objects.filter(event_type="attachment.purged").exists()


class TestStorageDelete:
    def test_fake_delete_is_idempotent(self):
        backend = FakeStorageBackend()
        backend.store_bytes("object", b"bytes")
        backend.delete("object")
        backend.delete_bytes("object")
        assert "object" not in backend.objects

    def test_local_delete_and_path_traversal(self, tmp_path, settings):
        settings.LOCAL_STORAGE_DIR = str(tmp_path)
        backend = LocalStorageBackend()
        backend.store_bytes("business/image/a.jpg", b"bytes")
        assert (tmp_path / "business/image/a.jpg").exists()

        backend.delete("business/image/a.jpg")
        backend.delete("business/image/a.jpg")

        assert not (tmp_path / "business/image/a.jpg").exists()
        with pytest.raises(StorageError, match="Invalid local storage path"):
            backend.delete("../outside.jpg")

    def test_supabase_delete_uses_authenticated_delete(self, settings, monkeypatch):
        settings.SUPABASE_URL = "https://ref.supabase.co"
        settings.SUPABASE_SERVICE_ROLE_KEY = "service-key"
        settings.SUPABASE_STORAGE_BUCKET = "business-documents"
        seen = {}

        def urlopen(request, timeout=60):
            seen["url"] = request.full_url
            seen["method"] = request.method
            seen["auth"] = request.headers.get("Authorization")
            response = Mock(read=Mock(return_value=b""))
            return Mock(__enter__=Mock(return_value=response), __exit__=Mock(return_value=False))

        monkeypatch.setattr(storage.urllib.request, "urlopen", urlopen)
        SupabaseStorageBackend().delete("business/image/a.jpg")

        assert seen == {
            "url": "https://ref.supabase.co/storage/v1/object/business-documents/business/image/a.jpg",
            "method": "DELETE",
            "auth": "Bearer service-key",
        }

    def test_supabase_delete_treats_missing_as_success_and_fails_on_outage(
        self, settings, monkeypatch
    ):
        settings.SUPABASE_URL = "https://ref.supabase.co"
        settings.SUPABASE_SERVICE_ROLE_KEY = "service-key"
        settings.SUPABASE_STORAGE_BUCKET = "business-documents"
        backend = SupabaseStorageBackend()

        def missing(*args, **kwargs):
            raise urllib.error.HTTPError("https://storage.invalid", 404, "missing", {}, None)

        monkeypatch.setattr(storage.urllib.request, "urlopen", missing)
        backend.delete("business/image/missing.jpg")

        def outage(*args, **kwargs):
            raise urllib.error.HTTPError("https://storage.invalid", 503, "outage", {}, None)

        monkeypatch.setattr(storage.urllib.request, "urlopen", outage)
        with pytest.raises(StorageError, match="HTTP 503"):
            backend.delete("business/image/a.jpg")
