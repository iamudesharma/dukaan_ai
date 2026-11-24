"""A brand-new account must be able to reach a working workspace."""

import pytest
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APIClient

from apps.tenancy import rls
from apps.tenancy.models import Business, GSTRegistration, Location, Membership

User = get_user_model()

SIGNUP = {"phone": "+919876543210", "password": "SecurePass123!", "display_name": "New Owner"}


@pytest.fixture
def api_client():
    return APIClient()


def sign_up(api_client):
    response = api_client.post("/api/v1/auth/signup/", SIGNUP)
    assert response.status_code == status.HTTP_201_CREATED
    api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['access']}")
    return response


@pytest.mark.django_db
def test_signup_then_onboarding_creates_a_working_workspace(api_client):
    signup = api_client.post("/api/v1/auth/signup/", SIGNUP)
    assert signup.status_code == status.HTTP_201_CREATED
    assert signup.data["onboarding_required"] is True
    api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {signup.data['access']}")

    me = api_client.get("/api/v1/me/")
    assert me.status_code == status.HTTP_200_OK
    assert me.json()["memberships"] == []

    blocked = api_client.get("/api/v1/bootstrap/")
    assert blocked.status_code == status.HTTP_404_NOT_FOUND
    assert blocked.json()["error"]["code"] == "onboarding_required"

    created = api_client.post(
        "/api/v1/businesses/",
        {
            "name": "Gupta Traders",
            "legal_name": "Gupta Traders Private Limited",
            "location_name": "Karol Bagh",
            "state_code": "07",
            "gstin": "07AAAAA0000A1Z5",
        },
        format="json",
    )
    assert created.status_code == status.HTTP_201_CREATED
    # Onboarding inputs are accepted, never echoed back.
    assert "location_name" not in created.data
    assert "gstin" not in created.data

    bootstrap = api_client.get("/api/v1/bootstrap/")
    assert bootstrap.status_code == status.HTTP_200_OK
    payload = bootstrap.json()
    assert payload["business"]["name"] == "Gupta Traders"
    assert payload["user"]["role"] == "OWNER"
    assert payload["permissions"] == ["*"]
    assert [location["name"] for location in payload["locations"]] == ["Karol Bagh"]

    user = User.objects.get(phone_e164="+919876543210")
    membership = Membership.objects.get(user=user)
    assert membership.business.name == "Gupta Traders"
    location = Location.objects.get(business=membership.business)
    assert (location.code, location.state_code) == ("MAIN", "07")
    registration = GSTRegistration.objects.get(business=membership.business)
    assert registration.gstin == "07AAAAA0000A1Z5"

    login = api_client.post(
        "/api/v1/auth/login/",
        {"phone": "+919876543210", "password": "SecurePass123!"},
    )
    assert login.status_code == status.HTTP_200_OK
    assert login.data["onboarding_required"] is False


@pytest.mark.django_db
def test_business_create_defaults_location_name(api_client):
    sign_up(api_client)
    created = api_client.post("/api/v1/businesses/", {"name": "Corner Store"}, format="json")
    assert created.status_code == status.HTTP_201_CREATED
    business = Business.objects.get(name="Corner Store")
    assert Location.objects.get(business=business).name == "Main Shop"
    assert not GSTRegistration.objects.filter(business=business).exists()


@pytest.mark.django_db
def test_business_scope_is_expanded_before_insert(api_client, monkeypatch):
    sign_up(api_client)
    events = []
    original_save = Business.save
    original_expand = rls.expand_tenant_scope

    def save_business(self, *args, **kwargs):
        events.append("save")
        return original_save(self, *args, **kwargs)

    def expand_business(connection, business_id):
        events.append("expand")
        return original_expand(connection, business_id)

    monkeypatch.setattr(Business, "save", save_business)
    monkeypatch.setattr(rls, "expand_tenant_scope", expand_business)

    created = api_client.post("/api/v1/businesses/", {"name": "Scoped Shop"}, format="json")

    assert created.status_code == status.HTTP_201_CREATED
    assert events[:2] == ["expand", "save"]


@pytest.mark.django_db
def test_business_create_rejects_malformed_gstin(api_client):
    sign_up(api_client)
    created = api_client.post(
        "/api/v1/businesses/",
        {"name": "Corner Store", "gstin": "NOTAGSTIN"},
        format="json",
    )
    assert created.status_code == status.HTTP_400_BAD_REQUEST
    assert not Business.objects.filter(name="Corner Store").exists()


@pytest.mark.django_db
def test_onboarded_owner_cannot_see_another_workspace(api_client):
    sign_up(api_client)
    api_client.post("/api/v1/businesses/", {"name": "Gupta Traders"}, format="json")

    other = APIClient()
    other.post(
        "/api/v1/auth/signup/",
        {"phone": "+919812345678", "password": "SecurePass123!"},
    )
    signup = other.post(
        "/api/v1/auth/login/",
        {"phone": "+919812345678", "password": "SecurePass123!"},
    )
    other.credentials(HTTP_AUTHORIZATION=f"Bearer {signup.data['access']}")

    assert other.get("/api/v1/bootstrap/").status_code == status.HTTP_404_NOT_FOUND
    assert other.get("/api/v1/businesses/").data == []

    business = Business.objects.get(name="Gupta Traders")
    assert other.get(f"/api/v1/locations/?business_id={business.pk}").status_code in {
        status.HTTP_403_FORBIDDEN,
        status.HTTP_404_NOT_FOUND,
    }
