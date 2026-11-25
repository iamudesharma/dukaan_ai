import json
from unittest.mock import MagicMock

import pytest
from django.test import override_settings
from rest_framework import status
from rest_framework.test import APIClient

from apps.authentication.models import PhoneOTP
from apps.authentication.sms import Msg91SmsProvider, SmsDeliveryError


def _response(payload):
    response = MagicMock()
    response.__enter__.return_value.read.return_value = json.dumps(payload).encode()
    return response


@override_settings(
    MSG91_AUTH_KEY="test-key",
    MSG91_OTP_TEMPLATE_ID="template-id",
    MSG91_OTP_VARIABLE="OTP",
    MSG91_API_BASE="https://msg91.test/api/v5",
    SMS_TIMEOUT_SECONDS=5,
)
def test_msg91_sends_otp_and_checks_success_payload(monkeypatch):
    calls = []

    def fake_urlopen(request, timeout):
        calls.append((request, timeout))
        return _response({"type": "success", "request_id": "req-1"})

    monkeypatch.setattr("apps.authentication.sms.urllib.request.urlopen", fake_urlopen)

    Msg91SmsProvider().send_otp("+919876543210", "123456")

    request, timeout = calls[0]
    assert request.full_url.startswith("https://msg91.test/api/v5/otp?")
    assert "mobile=919876543210" in request.full_url
    assert "otp=123456" in request.full_url
    assert request.get_header("Authkey") == "test-key"
    assert json.loads(request.data) == {"OTP": "123456"}
    assert timeout == 5


@override_settings(
    MSG91_AUTH_KEY="test-key",
    MSG91_OTP_TEMPLATE_ID="template-id",
    MSG91_API_BASE="https://msg91.test/api/v5",
)
def test_msg91_rejects_error_payload_even_with_http_200(monkeypatch):
    monkeypatch.setattr(
        "apps.authentication.sms.urllib.request.urlopen",
        lambda request, timeout: _response({"type": "error", "message": "Invalid authkey"}),
    )

    with pytest.raises(SmsDeliveryError):
        Msg91SmsProvider().send_otp("+919876543210", "123456")


@override_settings(MSG91_AUTH_KEY="", MSG91_OTP_TEMPLATE_ID="template-id")
def test_msg91_fails_closed_without_credentials():
    with pytest.raises(SmsDeliveryError, match="MSG91_AUTH_KEY"):
        Msg91SmsProvider().send_otp("+919876543210", "123456")


@pytest.mark.django_db
@override_settings(SMS_ENABLED=True, OTP_EXPOSE_DEV_CODE=False)
def test_otp_endpoint_returns_502_and_removes_code_when_delivery_fails(monkeypatch):
    def fail(self, phone, otp):
        raise SmsDeliveryError("provider unavailable")

    monkeypatch.setattr("apps.authentication.otp.OTPService.send", fail)

    response = APIClient().post("/api/v1/auth/otp/send/", {"phone": "+919876543210"})

    assert response.status_code == status.HTTP_502_BAD_GATEWAY
    assert response.data["code"] == "sms_delivery_failed"
    assert not PhoneOTP.objects.filter(phone_e164="+919876543210").exists()


@pytest.mark.django_db
@override_settings(SMS_ENABLED=True, OTP_EXPOSE_DEV_CODE=False)
def test_otp_endpoint_calls_provider_without_exposing_code(monkeypatch):
    calls = []

    def send(self, phone, otp):
        calls.append((phone, otp))
        return True

    monkeypatch.setattr("apps.authentication.otp.OTPService.send", send)

    response = APIClient().post("/api/v1/auth/otp/send/", {"phone": "+919876543210"})

    assert response.status_code == status.HTTP_200_OK
    assert "dev_otp" not in response.data
    assert calls and calls[0][0] == "+919876543210"
    assert len(calls[0][1]) == 6


@override_settings(SMS_ENABLED=True, OTP_EXPOSE_DEV_CODE=False)
def test_auth_capabilities_reports_real_sms_status():
    response = APIClient().get("/api/v1/auth/capabilities/")

    assert response.status_code == status.HTTP_200_OK
    assert response.data == {"password": True, "otp": True, "dev_otp": False}
