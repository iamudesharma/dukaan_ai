"""Phase-0 upload foundation: presign tickets, validation, storage seam."""

import io
import urllib.error
import urllib.request

import pytest
from django.contrib.auth import get_user_model
from django.db import connection
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.assistant.models import Attachment
from apps.assistant.storage import (
    FakeStorageBackend,
    StorageError,
    SupabaseStorageBackend,
    extension_for_mime,
    get_storage_backend,
    storage_path_for,
)
from apps.tenancy.models import Business, Location, Membership

User = get_user_model()


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def user(db):
    return User.objects.create_user(
        username="phone_+919876543211",
        phone_e164="+919876543211",
        password="SecurePass123!",
    )


@pytest.fixture
def business(db, user):
    biz = Business.objects.create(name="Voice Shop")
    Location.objects.create(business=biz, code="MAIN", name="Main Store")
    Membership.objects.create(user=user, business=biz, role="OWNER", is_active=True)
    return biz


def credentials_for(api_client, user):
    refresh = RefreshToken.for_user(user)
    api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")


def presign_payload(business, **overrides):
    payload = {
        "business_id": str(business.id),
        "kind": "VOICE",
        "mime": "audio/m4a",
        "size_bytes": 1024,
    }
    payload.update(overrides)
    return payload


@pytest.mark.django_db
class TestPresignEndpoint:
    def test_presign_voice_returns_ticket_and_pending_row(self, api_client, user, business):
        credentials_for(api_client, user)
        response = api_client.post(
            "/api/v1/assistant/attachments/presign/",
            presign_payload(business),
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        body = response.json()
        attachment = Attachment.objects.get()
        assert body["attachment"]["id"] == str(attachment.id)
        assert attachment.status == Attachment.Status.PENDING
        assert attachment.owner_id == user.pk
        assert attachment.storage_path.startswith(f"{business.id}/voice/")
        assert attachment.storage_path.endswith(".m4a")
        assert body["upload_url"]
        assert body["expires_at"]
        assert body["upload_headers"]["Content-Type"] == "audio/m4a"

    def test_rejects_unsupported_mime(self, api_client, user, business):
        credentials_for(api_client, user)
        response = api_client.post(
            "/api/v1/assistant/attachments/presign/",
            presign_payload(business, mime="text/plain"),
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_rejects_oversize_file(self, api_client, user, business, settings):
        credentials_for(api_client, user)
        settings.ATTACHMENT_MAX_BYTES = 100
        response = api_client.post(
            "/api/v1/assistant/attachments/presign/",
            presign_payload(business, size_bytes=101),
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert Attachment.objects.count() == 0

    def test_cross_tenant_presign_is_forbidden(self, api_client, user, business, db):
        other_owner = User.objects.create_user(username="other-owner")
        other = Business.objects.create(name="Other shop")
        Location.objects.create(business=other, code="MAIN", name="Main")
        Membership.objects.create(user=other_owner, business=other, role="OWNER", is_active=True)
        credentials_for(api_client, other_owner)
        response = api_client.post(
            "/api/v1/assistant/attachments/presign/",
            presign_payload(business),
            format="json",
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN
        assert Attachment.objects.count() == 0

    def test_unauthenticated_presign_is_rejected(self, api_client, business):
        response = api_client.post(
            "/api/v1/assistant/attachments/presign/",
            presign_payload(business),
            format="json",
        )
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_storage_outage_fails_closed(self, api_client, user, business, settings):
        settings.STORAGE_BACKEND = "supabase"
        settings.SUPABASE_URL = ""
        settings.SUPABASE_SERVICE_ROLE_KEY = ""
        credentials_for(api_client, user)
        response = api_client.post(
            "/api/v1/assistant/attachments/presign/",
            presign_payload(business),
            format="json",
        )
        assert response.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert Attachment.objects.get().status == Attachment.Status.FAILED


class TestStorageSeam:
    def test_default_backend_is_fake(self, settings):
        settings.STORAGE_BACKEND = "fake"
        assert isinstance(get_storage_backend(), FakeStorageBackend)

    def test_unknown_backend_falls_back_to_fake(self, settings):
        settings.STORAGE_BACKEND = "s3"
        assert isinstance(get_storage_backend(), FakeStorageBackend)

    def test_extension_allowlist(self):
        assert extension_for_mime("audio/m4a") == "m4a"
        assert extension_for_mime("AUDIO/MP4") == "m4a"
        assert extension_for_mime("image/png") == "png"
        assert extension_for_mime("text/plain") is None

    def test_storage_path_has_no_user_input(self):
        path = storage_path_for(
            business_id="biz-id",
            kind="VOICE",
            attachment_id="att-id",
            mime="audio/m4a",
        )
        assert path == "biz-id/voice/att-id.m4a"
        with pytest.raises(StorageError):
            storage_path_for(
                business_id="biz-id",
                kind="VOICE",
                attachment_id="att-id",
                mime="text/plain",
            )

    def test_fake_round_trip(self):
        backend = FakeStorageBackend()
        backend.store_bytes("p", b"audio")
        assert backend.download_bytes("p") == b"audio"
        with pytest.raises(StorageError):
            backend.download_bytes("missing")

    def _http_reply(self, payload: dict):
        body = io.BytesIO(str(payload).replace("'", '"').encode())

        class Reply:
            def __enter__(self):
                return self

            def __exit__(self, *args):
                return False

            def read(self):
                return body.read()

        return Reply()

    def test_supabase_presign_uses_signed_url(self, settings, monkeypatch):
        settings.SUPABASE_URL = "https://ref.supabase.co"
        settings.SUPABASE_SERVICE_ROLE_KEY = "service-key"
        settings.SUPABASE_STORAGE_BUCKET = "business-documents"
        seen = {}

        def fake_urlopen(request, timeout=20):
            seen["url"] = request.full_url
            seen["auth"] = request.headers.get("Authorization")
            return self._http_reply({"url": "https://signed.example/upload?token=t"})

        monkeypatch.setattr(urllib.request, "urlopen", fake_urlopen)
        ticket = SupabaseStorageBackend().presign_upload(
            path="biz/voice/a.m4a", mime="audio/m4a", size_bytes=10
        )
        assert ticket.upload_url == "https://signed.example/upload?token=t"
        assert "upload/sign/business-documents/biz/voice/a.m4a" in seen["url"]
        assert seen["auth"] == "Bearer service-key"

    def test_supabase_store_bytes_uses_authenticated_object_upload(self, settings, monkeypatch):
        settings.SUPABASE_URL = "https://ref.supabase.co"
        settings.SUPABASE_SERVICE_ROLE_KEY = "service-key"
        settings.SUPABASE_STORAGE_BUCKET = "business-documents"
        seen = {}

        def fake_urlopen(request, timeout=20):
            seen["url"] = request.full_url
            seen["method"] = request.method
            seen["data"] = request.data
            seen["auth"] = request.headers.get("Authorization")
            return self._http_reply({})

        monkeypatch.setattr(urllib.request, "urlopen", fake_urlopen)
        SupabaseStorageBackend().store_bytes("biz/voice/a.m4a", b"audio")

        assert seen["url"].endswith("/storage/v1/object/business-documents/biz/voice/a.m4a")
        assert seen["method"] == "POST"
        assert seen["data"] == b"audio"
        assert seen["auth"] == "Bearer service-key"

    def test_supabase_presign_without_url_fails_closed(self, settings, monkeypatch):
        settings.SUPABASE_URL = "https://ref.supabase.co"
        settings.SUPABASE_SERVICE_ROLE_KEY = "service-key"
        settings.SUPABASE_STORAGE_BUCKET = "business-documents"
        monkeypatch.setattr(urllib.request, "urlopen", lambda *a, **k: self._http_reply({}))
        with pytest.raises(StorageError):
            SupabaseStorageBackend().presign_upload(
                path="biz/voice/a.m4a", mime="audio/m4a", size_bytes=10
            )

    def test_supabase_http_error_fails_closed(self, settings, monkeypatch):
        settings.SUPABASE_URL = "https://ref.supabase.co"
        settings.SUPABASE_SERVICE_ROLE_KEY = "service-key"
        settings.SUPABASE_STORAGE_BUCKET = "business-documents"

        def boom(*args, **kwargs):
            raise urllib.error.HTTPError(args[0], 401, "Unauthorized", {}, None)

        monkeypatch.setattr(urllib.request, "urlopen", boom)
        with pytest.raises(StorageError, match="HTTP 401"):
            SupabaseStorageBackend().presign_upload(
                path="biz/voice/a.m4a", mime="audio/m4a", size_bytes=10
            )


@pytest.mark.django_db(transaction=True)
@pytest.mark.skipif(
    connection.vendor != "postgresql",
    reason="RLS is a PostgreSQL control",
)
class TestAttachmentRls:
    def test_attachment_table_is_force_protected(self):
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT c.relrowsecurity, c.relforcerowsecurity FROM pg_class c "
                "JOIN pg_namespace n ON n.oid = c.relnamespace "
                "WHERE c.relname = 'assistant_attachment' AND n.nspname = current_schema()"
            )
            rowsecurity, force = cursor.fetchone()
            cursor.execute(
                "SELECT count(*) FROM pg_policies WHERE tablename = 'assistant_attachment'"
            )
            (policies,) = cursor.fetchone()
        assert rowsecurity and force
        assert policies >= 1
