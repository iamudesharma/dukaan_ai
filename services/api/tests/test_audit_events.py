"""The Activity screen reads real audit rows, scoped to the caller's role."""

import pytest
from rest_framework.test import APIClient
from test_posting import proposal_for

from apps.assistant.services import confirm
from apps.tenancy.models import AuditEvent, Business, Membership

pytestmark = pytest.mark.django_db


def test_posted_sale_appears_in_the_audit_feed(shop):
    user, business, _, _ = shop
    sale, _ = confirm(
        proposal=proposal_for(shop), actor=user, version=1, idempotency_key="audit-feed"
    )
    client = APIClient()
    client.force_authenticate(user)

    response = client.get("/api/v1/audit-events/", {"business_id": str(business.pk)})

    assert response.status_code == 200
    events = response.json()
    assert [event["event_type"] for event in events] == ["sale.posted"]
    assert events[0]["aggregate_id"] == str(sale.pk)
    assert events[0]["actor_name"] == (user.display_name or user.username)
    assert events[0]["source"] == "ASSISTANT"


def test_audit_feed_requires_business_id(shop):
    user, _, _, _ = shop
    client = APIClient()
    client.force_authenticate(user)
    assert client.get("/api/v1/audit-events/").json() == []


def test_cashier_cannot_read_the_audit_feed(shop):
    user, business, location, _ = shop
    membership = Membership.objects.get(user=user)
    membership.role = "CASHIER"
    membership.save(update_fields=["role"])
    membership.locations.add(location)
    client = APIClient()
    client.force_authenticate(user)

    response = client.get("/api/v1/audit-events/", {"business_id": str(business.pk)})

    assert response.status_code == 403


def test_audit_feed_excludes_other_businesses(shop):
    user, _, _, _ = shop
    other = Business.objects.create(name="Other business")
    AuditEvent.objects.create(
        business=other,
        event_type="sale.posted",
        aggregate_type="Sale",
        aggregate_id=other.pk,
    )
    client = APIClient()
    client.force_authenticate(user)
    business = Business.objects.get(memberships__user=user)

    response = client.get("/api/v1/audit-events/", {"business_id": str(business.pk)})

    assert response.status_code == 200
    assert response.json() == []
