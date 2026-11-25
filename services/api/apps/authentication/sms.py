"""SMS delivery providers for authentication codes.

The OTP record remains owned by Django. Providers only deliver an already
created code; they never generate or verify it. MSG91 can return an error body
with HTTP 200, so success is determined from the response payload as well as the
HTTP status.
"""

from __future__ import annotations

import json
import logging
import urllib.error
import urllib.parse
import urllib.request

from django.conf import settings

logger = logging.getLogger(__name__)


class SmsDeliveryError(Exception):
    """The code could not be delivered through the configured provider."""


class SmsProvider:
    name = "base"

    def send_otp(self, phone: str, otp: str) -> None:
        raise NotImplementedError


class Msg91SmsProvider(SmsProvider):
    name = "msg91"

    def __init__(
        self,
        *,
        auth_key: str = "",
        template_id: str = "",
        api_base: str = "",
        otp_variable: str = "",
        timeout_seconds: int = 15,
    ) -> None:
        self.auth_key = auth_key or getattr(settings, "MSG91_AUTH_KEY", "")
        self.template_id = template_id or getattr(settings, "MSG91_OTP_TEMPLATE_ID", "")
        self.api_base = (
            api_base or getattr(settings, "MSG91_API_BASE", "https://control.msg91.com/api/v5")
        ).rstrip("/")
        self.otp_variable = otp_variable or getattr(settings, "MSG91_OTP_VARIABLE", "OTP")
        try:
            self.timeout_seconds = int(getattr(settings, "SMS_TIMEOUT_SECONDS", timeout_seconds))
        except (TypeError, ValueError):
            self.timeout_seconds = timeout_seconds

    def send_otp(self, phone: str, otp: str) -> None:
        if not self.auth_key:
            raise SmsDeliveryError("MSG91_AUTH_KEY is not configured")
        if not self.template_id:
            raise SmsDeliveryError("MSG91_OTP_TEMPLATE_ID is not configured")

        mobile = phone.lstrip("+")
        if not mobile.isdigit():
            raise SmsDeliveryError("MSG91 requires an international phone number")

        query = urllib.parse.urlencode(
            {
                "template_id": self.template_id,
                "mobile": mobile,
                "otp": otp,
                "otp_expiry": 5,
                "otp_length": len(otp),
                "unicode": 0,
                "realTimeResponse": 1,
            }
        )
        request = urllib.request.Request(
            f"{self.api_base}/otp?{query}",
            data=json.dumps({self.otp_variable: otp}).encode(),
            headers={
                "authkey": self.auth_key,
                "Accept": "application/json",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=self.timeout_seconds) as response:
                raw = response.read().decode()
        except urllib.error.HTTPError as exc:
            logger.warning("MSG91 OTP delivery failed: HTTP %s", exc.code)
            raise SmsDeliveryError(f"MSG91 returned HTTP {exc.code}") from exc
        except OSError as exc:
            logger.warning("MSG91 OTP delivery failed: %s", type(exc).__name__)
            raise SmsDeliveryError("MSG91 could not be reached") from exc

        try:
            payload = json.loads(raw or "{}")
        except ValueError as exc:
            raise SmsDeliveryError("MSG91 returned an unreadable response") from exc

        if not isinstance(payload, dict) or payload.get("type") != "success":
            # Never log the provider body: it can contain request identifiers and
            # occasionally echoes request details.
            logger.warning("MSG91 OTP delivery rejected the request")
            raise SmsDeliveryError("MSG91 rejected the OTP request")


def get_sms_provider() -> SmsProvider:
    provider = str(getattr(settings, "SMS_PROVIDER", "msg91") or "msg91").lower()
    if provider == "msg91":
        return Msg91SmsProvider()
    raise SmsDeliveryError(f"Unsupported SMS_PROVIDER={provider!r}")
