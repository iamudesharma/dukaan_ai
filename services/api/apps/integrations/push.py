"""Firebase Cloud Messaging HTTP v1 sender.

Only ``google-auth`` and the Python standard library are used. Service-account
JSON is read from Django settings at send time and is never logged or included
in an exception message.
"""

from __future__ import annotations

import hashlib
import json
import logging
import urllib.error
import urllib.parse
import urllib.request
import uuid
from collections.abc import Mapping

from django.conf import settings
from google.auth.transport.requests import Request as GoogleAuthRequest
from google.oauth2 import service_account

logger = logging.getLogger(__name__)

FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
FCM_SEND_URL = "https://fcm.googleapis.com/v1/projects/{project}/messages:send"
MAX_RESPONSE_BYTES = 64 * 1024


class FCMError(Exception):
    """A safe, classified push failure containing no credential or token."""

    def __init__(self, message: str, *, code: str, retryable: bool, status_code=None) -> None:
        super().__init__(message)
        self.code = code
        self.retryable = retryable
        self.status_code = status_code


def _service_account_info() -> dict:
    raw = getattr(settings, "FCM_SERVICE_ACCOUNTCOUNT_JSON", None)
    if not raw:
        # Backward-compatible spelling used by earlier deployments.
        raw = getattr(settings, "FCM_SERVICE_ACCOUNT_JSON", "")
    if isinstance(raw, Mapping):
        value = dict(raw)
    elif isinstance(raw, str) and raw.strip():
        try:
            decoded = json.loads(raw)
        except (ValueError, RecursionError) as exc:
            raise FCMError(
                "FCM service-account JSON is invalid.",
                code="misconfigured",
                retryable=False,
            ) from exc
        if not isinstance(decoded, dict):
            raise FCMError(
                "FCM service-account JSON must be an object.",
                code="misconfigured",
                retryable=False,
            )
        value = decoded
    else:
        raise FCMError(
            "FCM service-account credentials are not configured.",
            code="misconfigured",
            retryable=False,
        )
    if not value.get("client_email") or not value.get("private_key"):
        raise FCMError(
            "FCM service-account credentials are incomplete.",
            code="misconfigured",
            retryable=False,
        )
    return value


def _credentials():
    project_id = str(getattr(settings, "FCM_PROJECT_ID", "") or "").strip()
    if not project_id:
        raise FCMError("FCM_PROJECT_ID is not configured.", code="misconfigured", retryable=False)
    info = _service_account_info()
    account_project = str(info.get("project_id") or "").strip()
    if account_project and account_project != project_id:
        raise FCMError(
            "FCM project and service-account project do not match.",
            code="misconfigured",
            retryable=False,
        )
    try:
        credentials = service_account.Credentials.from_service_account_info(
            info, scopes=[FCM_SCOPE]
        )
    except Exception as exc:
        raise FCMError(
            "FCM service-account credentials are invalid.",
            code="misconfigured",
            retryable=False,
        ) from exc
    if not credentials.valid:
        try:
            credentials.refresh(GoogleAuthRequest())
        except Exception as exc:
            raise FCMError(
                "FCM service-account authentication failed.",
                code="authentication",
                retryable=True,
            ) from exc
    if not credentials.token:
        raise FCMError(
            "FCM authentication returned no access token.",
            code="authentication",
            retryable=False,
        )
    return project_id, credentials


def _message_payload(
    *,
    token: str,
    title: str,
    body: str,
    dedupe_key: str,
    data: Mapping | None,
) -> dict:
    token_digest = hashlib.sha256(token.encode("utf-8")).hexdigest()
    stable_id = uuid.uuid5(uuid.NAMESPACE_URL, f"dukaanai:{dedupe_key}:{token_digest}")
    string_data = {
        str(key): str(value)
        for key, value in (data or {}).items()
        if value is not None and str(key)
    }
    return {
        "message": {
            "token": token,
            "notification": {"title": title[:120], "body": body[:500]},
            "data": string_data,
            "android": {
                "priority": "HIGH",
                "collapse_key": hashlib.sha256(dedupe_key.encode("utf-8")).hexdigest()[:64],
            },
            "apns": {
                "headers": {"apns-id": str(stable_id)},
                "payload": {"aps": {"sound": "default"}},
            },
        }
    }


class FCMv1Sender:
    """Small HTTP v1 client; callers provide already-validated content."""

    name = "fcm-v1"

    def send(
        self,
        *,
        token: str,
        title: str,
        body: str,
        dedupe_key: str,
        data: Mapping | None = None,
    ) -> str:
        if not getattr(settings, "FCM_ENABLED", False):
            raise FCMError("Push notifications are disabled.", code="disabled", retryable=False)
        if not token or not title or not body or not dedupe_key:
            raise FCMError(
                "Push notification payload is incomplete.",
                code="invalid-payload",
                retryable=False,
            )
        project_id, credentials = _credentials()
        url = FCM_SEND_URL.format(project=urllib.parse.quote(project_id, safe=""))
        payload = _message_payload(
            token=token,
            title=title,
            body=body,
            dedupe_key=dedupe_key,
            data=data,
        )
        request = urllib.request.Request(
            url,
            data=json.dumps(payload, separators=(",", ":")).encode("utf-8"),
            headers={
                "Authorization": f"Bearer {credentials.token}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=20) as response:
                raw = response.read(MAX_RESPONSE_BYTES + 1)
                status_code = getattr(response, "status", None) or response.getcode()
        except urllib.error.HTTPError as exc:
            status_code = exc.code
            exc.close()
            retryable = status_code == 429 or status_code >= 500
            logger.warning("FCM send failed: HTTP %s", status_code)
            raise FCMError(
                f"FCM rejected the notification (HTTP {status_code}).",
                code="http-error",
                retryable=retryable,
                status_code=status_code,
            ) from None
        except (OSError, TimeoutError, urllib.error.URLError) as exc:
            logger.warning("FCM send failed: %s", type(exc).__name__)
            raise FCMError("FCM could not be reached.", code="network", retryable=True) from None

        if not isinstance(status_code, int) or not 200 <= status_code < 300:
            raise FCMError(
                "FCM returned an unexpected response.",
                code="malformed-response",
                retryable=True,
            )
        if len(raw) > MAX_RESPONSE_BYTES:
            raise FCMError(
                "FCM response exceeded the size limit.",
                code="malformed-response",
                retryable=False,
            )
        try:
            decoded = json.loads(raw.decode("utf-8"))
        except (UnicodeDecodeError, ValueError, RecursionError) as exc:
            raise FCMError(
                "FCM returned malformed JSON.", code="malformed-response", retryable=False
            ) from exc
        message_id = decoded.get("name") if isinstance(decoded, dict) else None
        if not isinstance(message_id, str) or not message_id:
            raise FCMError(
                "FCM returned no message id.", code="malformed-response", retryable=False
            )
        return message_id[:255]


def get_fcm_sender() -> FCMv1Sender:
    return FCMv1Sender()
