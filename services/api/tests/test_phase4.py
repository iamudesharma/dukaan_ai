"""Phase 4: bill-media uploads, extraction proposals, global search.

Exit: a photo/PDF of a bill becomes a reviewable proposal, and search
returns tenant-scoped results.
"""

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.core.management import call_command
from django.test import override_settings
from rest_framework.test import APIClient
from test_posting import proposal_for

from apps.operations.models import Attachment
from apps.operations.pdf import render_simple_pdf
from apps.tenancy.models import OutboxEvent

pytestmark = pytest.mark.django_db

eager = override_settings(CELERY_TASK_ALWAYS_EAGER=True)


@pytest.fixture(autouse=True)
def _isolated_media(tmp_path, settings):
    settings.MEDIA_ROOT = str(tmp_path / "media")


def make_client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def upload(client, business, name="bill.pdf", mime="application/pdf", content=b"%PDF-1.4 fake"):
    return client.post(
        "/api/v1/attachments/",
        {"business_id": str(business.pk), "file": SimpleUploadedFile(name, content, mime)},
        format="multipart",
    )


def bill_pdf_bytes(sentence: str) -> bytes:
    return render_simple_pdf(title="Bill photo", lines=[sentence])


def test_upload_pdf_and_reject_bad_mime(shop):
    user, business, _, _ = shop
    client = make_client(user)
    created = upload(
        client,
        business,
        content=bill_pdf_bytes("Ramesh bought 3 shirts for Rs 2400, paid Rs 1500."),
    )
    assert created.status_code == 201, created.data
    assert created.data["kind"] == "upload-pdf"
    assert created.data["status"] == "READY"
    attachment = Attachment.objects.get()
    assert attachment.uploaded_by_id == user.pk
    assert attachment.original_name == "bill.pdf"
    bad = upload(client, business, name="notes.txt", mime="text/plain", content=b"hi")
    assert bad.status_code == 400
    listed = client.get("/api/v1/attachments/", {"business_id": str(business.pk)})
    assert listed.status_code == 200
    assert len(listed.data) == 1


def test_presign_returns_direct_upload_shape(shop):
    user, business, _, _ = shop
    client = make_client(user)
    response = client.post(
        "/api/v1/attachments/presign/",
        {"business_id": str(business.pk), "filename": "bill.jpg", "mime_type": "image/jpeg"},
        format="json",
    )
    assert response.status_code == 200, response.data
    assert response.data["mode"] == "direct"
    assert response.data["upload_url"] == "/api/v1/attachments/"
    denied = client.post(
        "/api/v1/attachments/presign/",
        {"business_id": str(business.pk), "filename": "x.txt", "mime_type": "text/plain"},
        format="json",
    )
    assert denied.status_code == 400


@eager
def test_pdf_bill_becomes_ready_proposal(shop):
    user, business, location, _ = shop
    client = make_client(user)
    sentence = "Ramesh bought 3 shirts for Rs 2400, paid Rs 1500, Rs 900 pending."
    created = upload(client, business, content=bill_pdf_bytes(sentence))
    attachment_id = created.data["id"]
    proposed = client.post(
        "/api/v1/assistant/proposals/",
        {
            "business_id": str(business.pk),
            "location_id": str(location.pk),
            "input_type": "IMAGE",
            "content": "",
            "attachment_ids": [attachment_id],
        },
        format="json",
    )
    assert proposed.status_code == 201, proposed.data
    assert proposed.data["status"] == "PROCESSING"
    assert proposed.data["attachments"][0]["name"] == "bill.pdf"
    assert OutboxEvent.objects.filter(topic="proposal.extract").exists()
    call_command("dispatch_scheduled")
    fetched = client.get(f"/api/v1/assistant/proposals/{proposed.data['id']}/")
    assert fetched.status_code == 200, fetched.data
    assert fetched.data["status"] == "READY", fetched.data["blocking_questions"]
    assert fetched.data["command_type"] == "SALE"
    assert any("bill.pdf" in warning for warning in fetched.data["warnings"])
    # Extraction result is persisted on the attachment for audit.
    attachment = Attachment.objects.get()
    assert "Ramesh bought 3 shirts" in attachment.extracted_text
    # Redelivery never re-interprets.
    call_command("dispatch_scheduled")
    again = client.get(f"/api/v1/assistant/proposals/{proposed.data['id']}/")
    assert again.data["status"] == "READY"
    assert again.data["version"] == fetched.data["version"]


@eager
def test_unreadable_photo_needs_description_then_revises(shop):
    user, business, location, _ = shop
    client = make_client(user)
    created = upload(
        client,
        business,
        name="bill.jpg",
        mime="image/jpeg",
        content=b"\xff\xd8\xff\xe0fake-jpeg",
    )
    proposed = client.post(
        "/api/v1/assistant/proposals/",
        {
            "business_id": str(business.pk),
            "location_id": str(location.pk),
            "input_type": "IMAGE",
            "content": "",
            "attachment_ids": [created.data["id"]],
        },
        format="json",
    )
    assert proposed.data["status"] == "PROCESSING"
    call_command("dispatch_scheduled")
    fetched = client.get(f"/api/v1/assistant/proposals/{proposed.data['id']}/")
    assert fetched.data["status"] == "DRAFT"
    assert any("describe the bill" in q for q in fetched.data["blocking_questions"])
    # The shopkeeper describes it; revise re-reads into a confirmable proposal.
    revised = client.post(
        f"/api/v1/assistant/proposals/{proposed.data['id']}/revise/",
        {
            "version": fetched.data["version"],
            "content": "Ramesh bought 3 shirts for Rs 2400, paid Rs 1500, Rs 900 pending.",
        },
        format="json",
    )
    assert revised.status_code == 200, revised.data
    assert revised.data["status"] == "READY"


def test_foreign_attachment_rejected(shop):
    user, business, location, _ = shop
    from django.contrib.auth import get_user_model

    from apps.tenancy.models import Business, Location, Membership

    User = get_user_model()
    other = User.objects.create_user(username="other-media", phone_e164="+917000000003")
    other_business = Business.objects.create(name="Other shop")
    Location.objects.create(business=other_business, code="MAIN", name="Main")
    Membership.objects.create(user=other, business=other_business, role="OWNER")
    foreign = upload(make_client(other), other_business, content=bill_pdf_bytes("x"))
    denied = make_client(user).post(
        "/api/v1/assistant/proposals/",
        {
            "business_id": str(business.pk),
            "location_id": str(location.pk),
            "input_type": "IMAGE",
            "content": "",
            "attachment_ids": [foreign.data["id"]],
        },
        format="json",
    )
    assert denied.status_code == 400
    assert Attachment.objects.filter(uploaded_by=other).count() == 1


def test_search_returns_scoped_results(shop):
    user, business, location, _ = shop
    from apps.assistant.services import confirm

    confirm(proposal=proposal_for(shop), actor=user, version=1, idempotency_key="sale-search")
    client = make_client(user)
    params = {"business_id": str(business.pk), "q": "Ram"}
    response = client.get("/api/v1/search/", params)
    assert response.status_code == 200, response.data
    assert any(party["name"] == "Ramesh" for party in response.data["results"]["parties"])
    assert response.data["results"]["documents"], "posted sale should be searchable"
    assert (
        client.get("/api/v1/search/", {"business_id": str(business.pk), "q": "x"}).status_code
        == 400
    )
    assert (
        client.get(
            "/api/v1/search/",
            {"business_id": str(business.pk), "q": "Ram", "types": "nope"},
        ).status_code
        == 400
    )


def test_search_cashier_and_tenant_rules(shop):
    user, business, _, _ = shop
    from django.contrib.auth import get_user_model

    from apps.tenancy.models import Business, Location, Membership

    User = get_user_model()
    cashier = User.objects.create_user(username="cashier-search", phone_e164="+917000000004")
    Membership.objects.create(user=cashier, business=business, role="CASHIER")
    cashier_client = make_client(cashier)
    response = cashier_client.get(
        "/api/v1/search/", {"business_id": str(business.pk), "q": "26-27"}
    )
    assert response.status_code == 200, response.data
    assert all(doc["kind"] == "SALE" for doc in response.data["results"]["documents"])
    other = User.objects.create_user(username="stranger-search", phone_e164="+917000000005")
    other_business = Business.objects.create(name="Stranger shop")
    Location.objects.create(business=other_business, code="MAIN", name="Main")
    Membership.objects.create(user=other, business=other_business, role="OWNER")
    stranger = make_client(other).get(
        "/api/v1/search/", {"business_id": str(business.pk), "q": "Ram"}
    )
    assert stranger.status_code in (403, 404)
    assert user  # fixture anchor
