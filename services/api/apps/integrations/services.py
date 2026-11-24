from __future__ import annotations

import base64
import email
import logging
import re
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal, InvalidOperation

from django.conf import settings
from django.core.signing import BadSignature, dumps, loads
from django.utils import timezone
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import Flow
from googleapiclient.discovery import build

from apps.assistant.adapter import OpenAICompatibleAdapter, get_adapter

from .encryption import decrypt_token, encrypt_token
from .models import GmailConnection, GmailImport

logger = logging.getLogger(__name__)

GMAIL_SCOPE = "https://www.googleapis.com/auth/gmail.readonly"
FINANCIAL_QUERY = (
    "newer_than:30d "
    "(subject:(payment OR receipt OR invoice OR transaction OR UPI OR bank OR statement))"
)
STATE_SALT = "dukaanai.gmail.oauth.state"

EXTRACTION_TOOL = {
    "name": "record_financial_email",
    "description": "Extract a payment, receipt, or expense from a financial email.",
    "parameters": {
        "type": "object",
        "properties": {
            "kind": {"type": "string", "enum": ["PAYMENT", "RECEIPT", "EXPENSE", "UNKNOWN"]},
            "direction": {"type": "string", "enum": ["RECEIPT", "PAYMENT", ""]},
            "party_name": {"type": "string"},
            "amount_minor": {"type": ["integer", "null"], "minimum": 1},
            "reference": {"type": "string"},
            "confidence": {"type": "number", "minimum": 0, "maximum": 1},
        },
        "required": ["kind", "direction", "party_name", "amount_minor", "reference", "confidence"],
    },
}


class GmailError(Exception):
    pass


@dataclass
class GmailMessage:
    id: str
    subject: str
    snippet: str
    received_at: datetime | None
    text: str


def _client_config() -> dict:
    if not getattr(settings, "GMAIL_ENABLED", False):
        raise GmailError("Gmail integration is disabled")
    client_id = getattr(settings, "GMAIL_CLIENT_ID", "")
    client_secret = getattr(settings, "GMAIL_CLIENT_SECRET", "")
    redirect_uri = getattr(settings, "GMAIL_REDIRECT_URI", "")
    if not client_id or not client_secret or not redirect_uri:
        raise GmailError("Gmail OAuth is not configured")
    return {
        "web": {
            "client_id": client_id,
            "client_secret": client_secret,
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "redirect_uris": [redirect_uri],
        }
    }


def issue_state(user) -> str:
    return dumps({"user_id": str(user.id)}, salt=STATE_SALT, compress=True)


def resolve_state(state: str) -> str:
    try:
        payload = loads(state, salt=STATE_SALT, max_age=600)
    except BadSignature as exc:
        raise GmailError("Invalid or expired Gmail authorization state") from exc
    user_id = payload.get("user_id") if isinstance(payload, dict) else None
    if not user_id:
        raise GmailError("Invalid Gmail authorization state")
    return str(user_id)


def authorization_url(user) -> str:
    flow = Flow.from_client_config(_client_config(), scopes=[GMAIL_SCOPE])
    url, _ = flow.authorization_url(
        state=issue_state(user),
        access_type="offline",
        include_granted_scopes="true",
        prompt="consent",
    )
    return url


def complete_authorization(code: str, user) -> GmailConnection:
    flow = Flow.from_client_config(_client_config(), scopes=[GMAIL_SCOPE])
    try:
        flow.fetch_token(code=code)
    except Exception as exc:
        raise GmailError("Google rejected the authorization code") from exc
    credentials = flow.credentials
    if not credentials.refresh_token:
        raise GmailError("Google did not return offline access; reconnect and try again")

    try:
        service = build("gmail", "v1", credentials=credentials, cache_discovery=False)
        profile = service.users().getProfile(userId="me").execute()
    except Exception as exc:
        raise GmailError("Could not read the connected Gmail profile") from exc

    connection, _ = GmailConnection.objects.update_or_create(
        user=user,
        defaults={
            "email": str(profile.get("emailAddress", ""))[:254],
            "access_token_ciphertext": encrypt_token(credentials.token or ""),
            "refresh_token_ciphertext": encrypt_token(credentials.refresh_token),
            "token_expiry": credentials.expiry,
        },
    )
    return connection


def disconnect_gmail(user) -> None:
    connection = GmailConnection.objects.filter(user=user).first()
    if connection is None:
        return
    try:
        token = decrypt_token(connection.refresh_token_ciphertext)
        request = urllib.request.Request(
            "https://oauth2.googleapis.com/revoke",
            data=urllib.parse.urlencode({"token": token}).encode(),
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            method="POST",
        )
        with urllib.request.urlopen(request, timeout=10) as response:
            response.read()
    except (OSError, ValueError, urllib.error.URLError):
        logger.info("Gmail token revocation did not complete; removing local connection")
    connection.delete()


def _credentials(connection: GmailConnection) -> Credentials:
    credentials = Credentials(
        token=decrypt_token(connection.access_token_ciphertext),
        refresh_token=decrypt_token(connection.refresh_token_ciphertext),
        token_uri="https://oauth2.googleapis.com/token",
        client_id=getattr(settings, "GMAIL_CLIENT_ID", ""),
        client_secret=getattr(settings, "GMAIL_CLIENT_SECRET", ""),
        scopes=[GMAIL_SCOPE],
    )
    if credentials.expired and credentials.refresh_token:
        try:
            credentials.refresh(Request())
        except Exception as exc:
            raise GmailError("Gmail access expired; reconnect the account") from exc
        connection.access_token_ciphertext = encrypt_token(credentials.token or "")
        connection.token_expiry = credentials.expiry
        connection.save(update_fields=["access_token_ciphertext", "token_expiry", "updated_at"])
    return credentials


def _service(connection: GmailConnection):
    if not getattr(settings, "GMAIL_ENABLED", False):
        raise GmailError("Gmail integration is disabled")
    return build("gmail", "v1", credentials=_credentials(connection), cache_discovery=False)


def _header(payload: dict, name: str) -> str:
    for item in payload.get("headers", []):
        if str(item.get("name", "")).lower() == name.lower():
            return str(item.get("value", ""))
    return ""


def _decode(data: str) -> str:
    try:
        return base64.urlsafe_b64decode(data.encode()).decode("utf-8", errors="replace")
    except (ValueError, TypeError):
        return ""


def _body_text(payload: dict) -> str:
    if payload.get("body", {}).get("data"):
        return _decode(payload["body"]["data"])
    chunks = []
    for part in payload.get("parts", []):
        if part.get("mimeType") == "text/plain":
            chunks.append(_body_text(part))
        elif part.get("mimeType") == "multipart/alternative":
            chunks.append(_body_text(part))
    return "\n".join(chunk for chunk in chunks if chunk)


def _parse_date(value: str) -> datetime | None:
    if not value:
        return None
    try:
        parsed = email.utils.parsedate_to_datetime(value)
    except (TypeError, ValueError):
        return None
    if parsed is not None and timezone.is_naive(parsed):
        parsed = timezone.make_aware(parsed, timezone.utc)
    return parsed


def _message_from_resource(resource: dict, *, include_body: bool) -> GmailMessage:
    payload = resource.get("payload", {})
    text = _body_text(payload) if include_body else ""
    if include_body and not text:
        text = str(resource.get("snippet", ""))
    return GmailMessage(
        id=str(resource.get("id", "")),
        subject=_header(payload, "Subject")[:500],
        snippet=str(resource.get("snippet", ""))[:1000],
        received_at=_parse_date(_header(payload, "Date")),
        text=text[:20000],
    )


def list_messages(user, *, max_results: int = 20) -> list[GmailMessage]:
    connection = GmailConnection.objects.filter(user=user).first()
    if connection is None:
        raise GmailError("Gmail is not connected")
    service = _service(connection)
    try:
        response = (
            service.users()
            .messages()
            .list(userId="me", q=FINANCIAL_QUERY, maxResults=max(1, min(max_results, 50)))
            .execute()
        )
        messages = []
        for item in response.get("messages", []):
            resource = (
                service.users()
                .messages()
                .get(userId="me", id=item["id"], format="metadata")
                .execute()
            )
            messages.append(_message_from_resource(resource, include_body=False))
        return messages
    except Exception as exc:
        logger.warning("Gmail message listing failed: %s", type(exc).__name__)
        raise GmailError("Could not read Gmail messages") from exc


def fetch_message(user, message_id: str) -> GmailMessage:
    connection = GmailConnection.objects.filter(user=user).first()
    if connection is None:
        raise GmailError("Gmail is not connected")
    try:
        resource = (
            _service(connection)
            .users()
            .messages()
            .get(userId="me", id=message_id, format="full")
            .execute()
        )
    except Exception as exc:
        logger.warning("Gmail message fetch failed: %s", type(exc).__name__)
        raise GmailError("Could not read the selected Gmail message") from exc
    return _message_from_resource(resource, include_body=True)


def _fallback_extraction(text: str) -> dict:
    amount_match = re.search(r"(?:₹|rs\.?|inr)\s*([\d,]+(?:\.\d{1,2})?)", text, re.I)
    amount_minor = None
    if amount_match:
        try:
            amount_minor = int((Decimal(amount_match.group(1).replace(",", "")) * 100).quantize(1))
        except (InvalidOperation, ValueError):
            amount_minor = None
    received = bool(re.search(r"\b(received|credited|credit)\b", text, re.I))
    reference_match = re.search(
        r"\b(UPI|UTR|RRN|transaction)[\s:/#-]*([A-Za-z0-9-]{4,})", text, re.I
    )
    return {
        "kind": "RECEIPT" if received else "PAYMENT",
        "direction": "RECEIPT" if received else "PAYMENT",
        "party_name": "",
        "amount_minor": amount_minor,
        "reference": reference_match.group(0)[:200] if reference_match else "",
        "confidence": 0.45 if amount_minor else 0.2,
    }


def _validate_extraction(value: dict | None, text: str) -> dict:
    extracted = dict(value or _fallback_extraction(text))
    kind = str(extracted.get("kind", "UNKNOWN")).upper()
    direction = str(extracted.get("direction", "")).upper()
    amount = extracted.get("amount_minor")
    confidence = extracted.get("confidence")
    try:
        amount = int(amount) if amount is not None else None
    except (TypeError, ValueError):
        amount = None
    try:
        confidence = float(confidence) if confidence is not None else None
    except (TypeError, ValueError):
        confidence = None
    if kind not in {"PAYMENT", "RECEIPT", "EXPENSE", "UNKNOWN"}:
        kind = "UNKNOWN"
    if direction not in {"RECEIPT", "PAYMENT"}:
        direction = ""
    if amount is not None and amount <= 0:
        amount = None
    if confidence is not None and not 0 <= confidence <= 1:
        confidence = None
    return {
        "kind": kind,
        "direction": direction,
        "party_name": str(extracted.get("party_name") or "")[:200],
        "amount_minor": amount,
        "reference": str(extracted.get("reference") or "")[:200],
        "confidence": confidence,
    }


def extract_financial_message(message: GmailMessage) -> dict:
    text = f"Subject: {message.subject}\n\n{message.text or message.snippet}"
    adapter = None
    if getattr(settings, "GMAIL_AI_EXTRACTION", False):
        adapter = OpenAICompatibleAdapter()
    else:
        adapter = get_adapter()
    value = None
    if adapter is not None and hasattr(adapter, "extract_with_tool"):
        value = adapter.extract_with_tool(
            text,
            tool_name=EXTRACTION_TOOL["name"],
            tool_description=EXTRACTION_TOOL["description"],
            tool_schema=EXTRACTION_TOOL["parameters"],
        )
    return _validate_extraction(value, text)


def import_message(*, user, business, location, message_id: str) -> GmailImport:
    message = fetch_message(user, message_id)
    extracted = extract_financial_message(message)
    amount = extracted["amount_minor"]
    if amount is None:
        preview = (
            "We found this email but could not confidently read an amount. Review it manually."
        )
    else:
        rupees = Decimal(amount) / 100
        preview = (
            f"{extracted['kind'].title()} · {extracted['party_name'] or 'Party not identified'} · "
            f"₹{rupees:,.2f} · {extracted['reference'] or 'No reference'}. "
            "Review only — nothing has been posted."
        )
    record, _ = GmailImport.objects.update_or_create(
        user=user,
        business=business,
        message_id=message.id,
        defaults={
            "location": location,
            "subject": message.subject,
            "received_at": message.received_at,
            **extracted,
            "preview": preview,
            "status": GmailImport.Status.NEEDS_REVIEW,
        },
    )
    return record
