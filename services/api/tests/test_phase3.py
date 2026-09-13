"""Phase 3: activity feed, reminders, notification prefs, devices, async exports, invoices.

Durability is the point: reminders/exports/invoices persist intent in
Postgres (rows + outbox events) in the same transaction as the request,
so a worker restart never loses them. These tests drive the full path:
request -> outbox PENDING -> dispatcher -> worker -> SENT/READY.
"""

import pytest
from django.core.management import call_command
from django.test import override_settings
from rest_framework.test import APIClient
from test_posting import proposal_for

from apps.operations.models import Attachment, ExportJob, Reminder
from apps.tenancy.models import OutboxEvent

pytestmark = pytest.mark.django_db

eager = override_settings(CELERY_TASK_ALWAYS_EAGER=True)


@pytest.fixture(autouse=True)
def _isolated_media(tmp_path, settings):
    """Keep generated PDFs/CSVs out of the repo checkout."""
    settings.MEDIA_ROOT = str(tmp_path / "media")


def make_client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def test_activity_lists_posting_events_with_kind_filter(shop):
    user, business, location, _ = shop
    confirm_proposal(shop, user)
    client = make_client(user)
    params = {"business_id": str(business.pk)}
    response = client.get("/api/v1/activity/", params)
    assert response.status_code == 200, response.data
    assert response.data["count"] >= 1
    assert any("sale" in row["event_type"] for row in response.data["results"])
    filtered = client.get("/api/v1/activity/", {**params, "kind": "team"})
    assert filtered.status_code == 200
    assert all("sale" not in row["event_type"] for row in filtered.data["results"])
    # Cashiers cannot read the audit feed.
    from django.contrib.auth import get_user_model

    User = get_user_model()
    cashier = User.objects.create_user(username="cashier-activity", phone_e164="+917000000001")
    from apps.tenancy.models import Membership

    Membership.objects.create(user=cashier, business=business, role="CASHIER")
    denied = make_client(cashier).get("/api/v1/activity/", params)
    assert denied.status_code == 403


def confirm_proposal(shop, user):
    from apps.assistant.services import confirm

    proposal = proposal_for(shop)
    return confirm(proposal=proposal, actor=user, version=1, idempotency_key="sale-activity")


def test_notification_preferences_get_and_patch(shop):
    user, business, _, _ = shop
    client = make_client(user)
    params = {"business_id": str(business.pk)}
    fetched = client.get("/api/v1/notification-preferences/", params)
    assert fetched.status_code == 200, fetched.data
    assert fetched.data["push_enabled"] is True
    updated = client.patch(
        "/api/v1/notification-preferences/",
        {"business_id": str(business.pk), "push_enabled": False, "whatsapp_enabled": True},
        format="json",
    )
    assert updated.status_code == 200
    assert updated.data["push_enabled"] is False
    assert updated.data["whatsapp_enabled"] is True


def test_device_register_list_unregister(shop):
    user, _, _, _ = shop
    client = make_client(user)
    created = client.post(
        "/api/v1/devices/", {"token": "fcm-token-1", "platform": "ANDROID"}, format="json"
    )
    assert created.status_code == 201, created.data
    listed = client.get("/api/v1/devices/")
    assert listed.status_code == 200
    assert len(listed.data) == 1
    # Re-registering the same token is idempotent.
    again = client.post(
        "/api/v1/devices/", {"token": "fcm-token-1", "platform": "ANDROID"}, format="json"
    )
    assert again.status_code == 201
    assert make_client(user).get("/api/v1/devices/").data == listed.data
    deleted = client.delete(f"/api/v1/devices/{created.data['id']}/")
    assert deleted.status_code == 200
    assert client.get("/api/v1/devices/").data == []


@eager
def test_reminder_suggestions_and_send_flow(shop):
    user, business, location, _ = shop
    confirm_proposal(shop, user)
    client = make_client(user)
    params = {"business_id": str(business.pk)}
    suggestions = client.get("/api/v1/reminders/suggestions/", params)
    assert suggestions.status_code == 200, suggestions.data
    assert suggestions.data["results"], "posted sale with dues should suggest a reminder"
    top = suggestions.data["results"][0]
    assert top["amount_minor"] > 0
    created = client.post(
        "/api/v1/reminders/",
        {
            "business_id": str(business.pk),
            "party_id": top["party_id"],
            "channel": "SHARE",
            "idempotency_key": "reminder-1",
        },
        format="json",
    )
    assert created.status_code == 201, created.data
    assert created.data["status"] == "PENDING"
    assert created.data["message"]
    reminder = Reminder.objects.get()
    assert OutboxEvent.objects.filter(
        topic="reminder.send", dedupe_key=f"reminder.send:{reminder.pk}"
    ).exists()
    # Same idempotency key replays the same reminder.
    replayed = client.post(
        "/api/v1/reminders/",
        {
            "business_id": str(business.pk),
            "party_id": top["party_id"],
            "channel": "SHARE",
            "idempotency_key": "reminder-1",
        },
        format="json",
    )
    assert replayed.status_code == 200
    assert replayed.data["id"] == created.data["id"]
    assert Reminder.objects.count() == 1
    # Dispatcher + worker deliver it durably.
    call_command("dispatch_scheduled")
    reminder.refresh_from_db()
    assert reminder.status == "SENT"
    assert reminder.provider_message_id
    assert reminder.sent_at is not None
    # Redelivery is idempotent: already SENT stays SENT.
    call_command("dispatch_scheduled")
    reminder.refresh_from_db()
    assert reminder.status == "SENT"
    detail = client.get(f"/api/v1/reminders/{reminder.pk}/")
    assert detail.status_code == 200
    assert detail.data["status"] == "SENT"


@eager
def test_async_csv_export_flow(shop):
    user, business, _, _ = shop
    confirm_proposal(shop, user)
    client = make_client(user)
    created = client.post(
        "/api/v1/exports/",
        {"business_id": str(business.pk), "report": "sales", "format": "CSV"},
        format="json",
    )
    assert created.status_code == 202, created.data
    assert created.data["status"] == "PENDING"
    job = ExportJob.objects.get()
    assert OutboxEvent.objects.filter(
        topic="export.run", dedupe_key=f"export.run:{job.pk}"
    ).exists()
    call_command("dispatch_scheduled")
    job.refresh_from_db()
    assert job.status == "READY", job.error
    assert job.file
    detail = client.get(f"/api/v1/exports/{job.pk}/")
    assert detail.status_code == 200
    assert detail.data["download_url"]
    downloaded = client.get(f"/api/v1/exports/{job.pk}/", {"download": "1"})
    assert downloaded.status_code == 200
    content = b"".join(downloaded.streaming_content).decode("utf-8")
    assert "grand_total_minor" in content


@eager
def test_async_pdf_export_flow(shop):
    user, business, _, _ = shop
    client = make_client(user)
    created = client.post(
        "/api/v1/exports/",
        {"business_id": str(business.pk), "report": "sales", "format": "PDF"},
        format="json",
    )
    assert created.status_code == 202, created.data
    job = ExportJob.objects.get()
    call_command("dispatch_scheduled")
    job.refresh_from_db()
    assert job.status == "READY", job.error
    downloaded = client.get(f"/api/v1/exports/{job.pk}/", {"download": "1"})
    assert downloaded.status_code == 200
    assert downloaded["Content-Type"] == "application/pdf"
    assert b"".join(downloaded.streaming_content).startswith(b"%PDF")


@eager
def test_sale_invoice_pdf_flow_and_tenant_isolation(shop):
    user, business, _, _ = shop
    sale, _ = confirm_proposal(shop, user)
    client = make_client(user)
    created = client.post(f"/api/v1/sales/{sale.pk}/invoice/", {}, format="json")
    assert created.status_code == 202, created.data
    assert created.data["status"] == "PENDING"
    attachment = Attachment.objects.get()
    # Repeat POST is idempotent: same attachment, no duplicate.
    again = client.post(f"/api/v1/sales/{sale.pk}/invoice/", {}, format="json")
    assert again.status_code == 200
    assert again.data["id"] == created.data["id"]
    assert Attachment.objects.count() == 1
    call_command("dispatch_scheduled")
    attachment.refresh_from_db()
    assert attachment.status == "READY", attachment.error
    assert attachment.size_bytes > 0
    detail = client.get(f"/api/v1/attachments/{attachment.pk}/")
    assert detail.status_code == 200
    assert detail.data["download_url"]
    downloaded = client.get(f"/api/v1/attachments/{attachment.pk}/", {"download": "1"})
    assert downloaded.status_code == 200
    assert downloaded["Content-Type"] == "application/pdf"
    assert b"".join(downloaded.streaming_content).startswith(b"%PDF")
    # Another business cannot read or download it.
    from django.contrib.auth import get_user_model

    User = get_user_model()
    other = User.objects.create_user(username="other-invoice", phone_e164="+917000000002")
    from apps.tenancy.models import Business, Location, Membership

    other_business = Business.objects.create(name="Other shop")
    Location.objects.create(business=other_business, code="MAIN", name="Main")
    Membership.objects.create(user=other, business=other_business, role="OWNER")
    other_client = make_client(other)
    assert other_client.get(f"/api/v1/attachments/{attachment.pk}/").status_code == 404
    assert (
        other_client.get(f"/api/v1/attachments/{attachment.pk}/", {"download": "1"}).status_code
        == 404
    )
