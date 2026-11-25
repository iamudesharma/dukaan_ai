import pytest
from django.conf import settings
from django.test import override_settings
from django.urls import resolve
from rest_framework.test import APIClient, APIRequestFactory

from apps.common.throttling import (
    AssistantRateThrottle,
    AuthRateThrottle,
    ReadRateThrottle,
    UploadRateThrottle,
    WriteRateThrottle,
)

pytestmark = pytest.mark.django_db

HIGH_RATE = "1000/min"


def _rates(**overrides):
    rates = {
        "auth": HIGH_RATE,
        "assistant": HIGH_RATE,
        "uploads": HIGH_RATE,
        "write": HIGH_RATE,
        "read": HIGH_RATE,
        **overrides,
    }
    return override_settings(
        REST_FRAMEWORK={**settings.REST_FRAMEWORK, "DEFAULT_THROTTLE_RATES": rates}
    )


def test_auth_throttle_rejects_excess_requests():
    client = APIClient()
    with _rates(auth="1/min"):
        first = client.post("/api/v1/auth/signup/", {}, format="json")
        second = client.post("/api/v1/auth/signup/", {}, format="json")
    assert first.status_code == 400
    assert second.status_code == 429
    assert second.json()["error"]["code"] == "throttled"


def test_assistant_throttle_rejects_excess_requests(shop):
    client = APIClient()
    client.force_authenticate(shop[0])
    with _rates(assistant="1/min"):
        first = client.post("/api/v1/assistant/proposals/", {}, format="json")
        second = client.post("/api/v1/assistant/proposals/", {}, format="json")
    assert first.status_code == 400
    assert second.status_code == 429


def test_upload_throttle_rejects_excess_presign_requests(shop):
    client = APIClient()
    client.force_authenticate(shop[0])
    with _rates(uploads="1/min"):
        first = client.post("/api/v1/assistant/attachments/presign/", {}, format="json")
        second = client.post("/api/v1/assistant/attachments/presign/", {}, format="json")
    assert first.status_code == 400
    assert second.status_code == 429


def test_general_write_throttle_rejects_excess_mutations(shop):
    client = APIClient()
    client.force_authenticate(shop[0])
    with _rates(write="1/min"):
        first = client.post("/api/v1/parties/", {}, format="json")
        second = client.post("/api/v1/parties/", {}, format="json")
    assert first.status_code == 400
    assert second.status_code == 429


def test_general_read_throttle_rejects_excess_reads(shop):
    _, business, _, _ = shop
    client = APIClient()
    client.force_authenticate(shop[0])
    with _rates(read="1/min"):
        first = client.get("/api/v1/products/", {"business_id": str(business.pk)})
        second = client.get("/api/v1/products/", {"business_id": str(business.pk)})
    assert first.status_code == 200
    assert second.status_code == 429


def test_throttle_scopes_do_not_share_counters(shop):
    _, business, _, _ = shop
    client = APIClient()
    client.force_authenticate(shop[0])
    with _rates(read="1/min", write="1/min"):
        assert client.get("/api/v1/products/", {"business_id": str(business.pk)}).status_code == 200
        assert client.get("/api/v1/products/", {"business_id": str(business.pk)}).status_code == 429
        # The same user has an independent bucket for mutations.
        assert client.post("/api/v1/parties/", {}, format="json").status_code == 400


def test_auth_scope_covers_otp_signup_and_login():
    factory = APIRequestFactory()
    throttle = AuthRateThrottle()
    for path in (
        "/api/v1/auth/signup/",
        "/api/v1/auth/login/",
        "/api/v1/auth/otp/send/",
        "/api/v1/auth/otp/verify/",
    ):
        request = factory.post(path)
        request.resolver_match = resolve(path)
        assert throttle.applies_to(request, None), path


def test_assistant_scope_covers_interpret_confirm_audio_and_future_image():
    factory = APIRequestFactory()
    throttle = AssistantRateThrottle()
    paths = (
        "/api/v1/assistant/proposals/",
        "/api/v1/assistant/proposals/00000000-0000-0000-0000-000000000001/confirm/",
        "/api/v1/assistant/proposals/from-audio/",
        "/api/v1/assistant/proposals/from-image/",
    )
    for path in paths:
        request = factory.post(path)
        if path != paths[-1]:
            request.resolver_match = resolve(path)
        assert throttle.applies_to(request, None), path


def test_upload_scope_covers_presign_and_upload_without_throttling_reads():
    factory = APIRequestFactory()
    throttle = UploadRateThrottle()
    for path in (
        "/api/v1/assistant/attachments/presign/",
        "/api/v1/assistant/attachments/upload/",
    ):
        request = factory.post(path)
        request.resolver_match = resolve(path)
        assert throttle.applies_to(request, None), path
        read_request = factory.get(path)
        read_request.resolver_match = resolve(path)
        assert not throttle.applies_to(read_request, None), path


def test_read_and_write_scopes_are_selected_by_method():
    factory = APIRequestFactory()
    write = WriteRateThrottle()
    read = ReadRateThrottle()
    request = factory.patch("/api/v1/parties/")
    assert write.applies_to(request, None)
    assert not read.applies_to(request, None)
    request = factory.get("/api/v1/parties/")
    assert read.applies_to(request, None)
    assert not write.applies_to(request, None)
