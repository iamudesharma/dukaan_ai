import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework import status
from rest_framework.test import APIClient

from apps.assistant.models import Attachment
from apps.assistant.storage import LocalStorageBackend, StorageError


def test_local_storage_round_trip_stays_inside_project(tmp_path, settings):
    settings.LOCAL_STORAGE_DIR = str(tmp_path)
    backend = LocalStorageBackend()

    backend.store_bytes("business/voice/test.m4a", b"audio")

    assert backend.download_bytes("business/voice/test.m4a") == b"audio"
    assert (tmp_path / "business" / "voice" / "test.m4a").read_bytes() == b"audio"


def test_local_storage_rejects_path_traversal(tmp_path, settings):
    settings.LOCAL_STORAGE_DIR = str(tmp_path)
    backend = LocalStorageBackend()

    with pytest.raises(StorageError, match="Invalid local storage path"):
        backend.store_bytes("../outside.m4a", b"audio")


def test_local_storage_download_is_size_bounded(tmp_path, settings):
    settings.LOCAL_STORAGE_DIR = str(tmp_path)
    settings.ATTACHMENT_MAX_BYTES = 4
    backend = LocalStorageBackend()
    target = tmp_path / "business" / "voice" / "oversize.m4a"
    target.parent.mkdir(parents=True)
    target.write_bytes(b"12345")

    with pytest.raises(StorageError, match="size limit"):
        backend.download_bytes("business/voice/oversize.m4a")


def test_voice_upload_endpoint_persists_local_file(shop, tmp_path, settings):
    user, business, location, _product = shop
    settings.STORAGE_BACKEND = "local"
    settings.LOCAL_STORAGE_DIR = str(tmp_path)
    client = APIClient()
    client.force_authenticate(user=user)

    response = client.post(
        "/api/v1/assistant/attachments/upload/",
        {
            "business_id": str(business.id),
            "kind": "VOICE",
            "mime": "audio/m4a",
            "size_bytes": "5",
            "file": SimpleUploadedFile("voice.m4a", b"audio", content_type="audio/m4a"),
        },
        format="multipart",
    )

    assert response.status_code == status.HTTP_201_CREATED
    attachment = Attachment.objects.get(pk=response.data["id"])
    assert attachment.status == Attachment.Status.READY
    assert attachment.size_bytes == 5
    assert (tmp_path / attachment.storage_path).read_bytes() == b"audio"
