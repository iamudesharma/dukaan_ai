import pytest
from rest_framework.test import APIClient

from apps.common.models import User
from apps.tenancy.models import Business, Location, Membership


@pytest.mark.django_db
def test_bootstrap_only_returns_assigned_locations():
    user = User.objects.create_user(username="cashier")
    business = Business.objects.create(name="Shop")
    allowed = Location.objects.create(business=business, code="A", name="Assigned")
    Location.objects.create(business=business, code="B", name="Private")
    member = Membership.objects.create(user=user, business=business, role="CASHIER")
    member.locations.add(allowed)
    client = APIClient()
    client.force_authenticate(user)
    response = client.get("/api/v1/bootstrap/")
    assert response.status_code == 200
    assert [row["id"] for row in response.json()["locations"]] == [str(allowed.pk)]
    assert "*" not in response.json()["permissions"]
