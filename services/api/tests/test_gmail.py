from datetime import UTC, datetime
from unittest.mock import MagicMock

import pytest
from django.contrib.auth import get_user_model
from django.db import connection
from django.test import override_settings
from rest_framework import status
from rest_framework.test import APIClient

from apps.assistant.adapter import OpenAICompatibleAdapter
from apps.integrations.encryption import decrypt_token, encrypt_token
from apps.integrations.models import GmailConnection, GmailImport
from apps.integrations.services import (
    GmailMessage,
    extract_financial_message,
    import_message,
    issue_state,
    resolve_state,
)

User = get_user_model()


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def user(db):
    return User.objects.create_user(
        username="gmail_owner",
        phone_e164="+919876543210",
        password="SecurePass123!",
    )


@pytest.mark.django_db
def test_gmail_oauth_state_round_trip(user):
    state = issue_state(user)
    assert resolve_state(state) == str(user.id)


def test_gmail_tokens_are_encrypted_at_rest(settings):
    settings.SECRET_KEY = "a-test-secret-that-is-long-enough-for-fernet-derivation"
    ciphertext = encrypt_token("refresh-token")
    assert ciphertext != "refresh-token"
    assert decrypt_token(ciphertext) == "refresh-token"


def test_financial_email_fallback_extracts_amount_and_direction():
    message = GmailMessage(
        id="m1",
        subject="Payment received",
        snippet="",
        received_at=None,
        text="You received Rs 1,500.00 via UPI/123456789 from Ramesh.",
    )
    result = extract_financial_message(message)
    assert result["amount_minor"] == 150000
    assert result["direction"] == "RECEIPT"
    assert "UPI/123456789" in result["reference"]


def test_financial_email_uses_ai_tool_calling(monkeypatch):
    adapter = OpenAICompatibleAdapter(api_base="https://ai.test/v1", model="test")
    adapter.extract_with_tool = MagicMock(
        return_value={
            "kind": "PAYMENT",
            "direction": "PAYMENT",
            "party_name": "Supplier",
            "amount_minor": 250000,
            "reference": "NEFT-1",
            "confidence": 0.93,
        }
    )
    monkeypatch.setattr("apps.integrations.services.get_adapter", lambda: adapter)

    result = extract_financial_message(
        GmailMessage(
            id="m1",
            subject="Supplier payment",
            snippet="",
            received_at=None,
            text="Paid supplier 2500 by NEFT.",
        )
    )

    assert result["amount_minor"] == 250000
    assert result["party_name"] == "Supplier"
    assert adapter.extract_with_tool.call_args.kwargs["tool_name"] == "record_financial_email"


@override_settings(GMAIL_AI_EXTRACTION=True)
def test_financial_email_can_use_gmail_specific_ai_flag(monkeypatch):
    adapter = OpenAICompatibleAdapter(api_base="https://ai.test/v1", model="test")
    adapter.extract_with_tool = MagicMock(
        return_value={
            "kind": "EXPENSE",
            "direction": "",
            "party_name": "Electricity board",
            "amount_minor": 120000,
            "reference": "BILL-1",
            "confidence": 0.88,
        }
    )
    monkeypatch.setattr("apps.integrations.services.OpenAICompatibleAdapter", lambda: adapter)

    result = extract_financial_message(
        GmailMessage(
            id="m1",
            subject="Electricity bill",
            snippet="",
            received_at=None,
            text="Electricity bill paid 1200.",
        )
    )

    assert result["kind"] == "EXPENSE"
    assert result["amount_minor"] == 120000
    adapter.extract_with_tool.assert_called_once()


@pytest.mark.django_db
def test_import_message_creates_review_only_record(shop, monkeypatch):
    user, business, location, _product = shop
    message = GmailMessage(
        id="gmail-1",
        subject="Payment received",
        snippet="Rs 500 received",
        received_at=datetime(2026, 1, 1, tzinfo=UTC),
        text="You received Rs 500 from Ramesh.",
    )
    monkeypatch.setattr("apps.integrations.services.fetch_message", lambda *args, **kwargs: message)
    monkeypatch.setattr(
        "apps.integrations.services.extract_financial_message",
        lambda message: {
            "kind": "RECEIPT",
            "direction": "RECEIPT",
            "party_name": "Ramesh",
            "amount_minor": 50000,
            "reference": "UPI-1",
            "confidence": 0.9,
        },
    )

    record = import_message(
        user=user,
        business=business,
        location=location,
        message_id="gmail-1",
    )

    assert record.status == GmailImport.Status.NEEDS_REVIEW
    assert record.amount_minor == 50000
    assert "nothing has been posted" in record.preview


@pytest.mark.django_db(transaction=True)
@pytest.mark.skipif(
    connection.vendor != "postgresql",
    reason="RLS is a PostgreSQL control",
)
def test_gmail_import_table_is_force_protected():
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT c.relrowsecurity, c.relforcerowsecurity FROM pg_class c "
            "JOIN pg_namespace n ON n.oid = c.relnamespace "
            "WHERE c.relname = 'integrations_gmailimport' AND n.nspname = current_schema()"
        )
        rowsecurity, force = cursor.fetchone()
        cursor.execute(
            "SELECT count(*) FROM pg_policies WHERE tablename = 'integrations_gmailimport'"
        )
        (policies,) = cursor.fetchone()
    assert rowsecurity and force
    assert policies >= 1


@pytest.mark.django_db
@override_settings(GMAIL_ENABLED=False)
def test_gmail_connect_fails_closed_when_disabled(api_client, user):
    api_client.force_authenticate(user=user)
    response = api_client.get("/api/v1/integrations/gmail/connect/")
    assert response.status_code == status.HTTP_503_SERVICE_UNAVAILABLE


@pytest.mark.django_db
def test_gmail_status_and_disconnect(api_client, user, monkeypatch):
    api_client.force_authenticate(user=user)
    reply = MagicMock()
    reply.__enter__.return_value.read.return_value = b""
    monkeypatch.setattr(
        "apps.integrations.services.urllib.request.urlopen",
        lambda request, timeout: reply,
    )
    assert api_client.get("/api/v1/integrations/gmail/status/").data["connected"] is False

    GmailConnection.objects.create(
        user=user,
        email="owner@example.com",
        access_token_ciphertext=encrypt_token("access"),
        refresh_token_ciphertext=encrypt_token("refresh"),
    )
    response = api_client.get("/api/v1/integrations/gmail/status/")
    assert response.data == {"connected": True, "email": "owner@example.com"}

    response = api_client.delete("/api/v1/integrations/gmail/")
    assert response.status_code == status.HTTP_204_NO_CONTENT
    assert not GmailConnection.objects.filter(user=user).exists()


@pytest.mark.django_db
def test_gmail_messages_endpoint_returns_metadata(api_client, user, monkeypatch):
    api_client.force_authenticate(user=user)
    monkeypatch.setattr(
        "apps.integrations.views.list_messages",
        lambda user, max_results: [
            GmailMessage(
                id="m1",
                subject="Receipt",
                snippet="Payment received",
                received_at=datetime(2026, 1, 1, tzinfo=UTC),
                text="",
            )
        ],
    )
    response = api_client.get("/api/v1/integrations/gmail/messages/?max_results=5")
    assert response.status_code == status.HTTP_200_OK
    assert response.data["results"][0]["subject"] == "Receipt"
