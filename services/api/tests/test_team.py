"""Team invitations, session revocation, profile and business updates."""

import pytest
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.tenancy.models import Business, Invitation, Location, Membership

User = get_user_model()

pytestmark = pytest.mark.django_db


def make_client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def make_user(username, phone):
    return User.objects.create_user(username=username, phone_e164=phone, password="SecurePass123!")


@pytest.fixture
def owner_client(shop):
    user, _, _, _ = shop
    user.phone_e164 = "+911111111111"
    user.save(update_fields=["phone_e164"])
    return make_client(user)


def invite(client, business, phone="+912222222222", role="MANAGER", locations=()):
    return client.post(
        "/api/v1/invitations/",
        {
            "business": str(business.pk),
            "phone_e164": phone,
            "role": role,
            "locations": [str(location.pk) for location in locations],
        },
        format="json",
    )


def test_invite_create_and_accept_flow(shop, owner_client):
    _, business, location, _ = shop
    response = invite(owner_client, business, locations=[location])
    assert response.status_code == 201, response.data
    assert response.data["status"] == "PENDING"
    token = response.data["token"]
    invitation = Invitation.objects.get()
    assert invitation.locations.count() == 1

    # The token is write-only: listing never exposes it.
    listed = owner_client.get("/api/v1/invitations/", {"business_id": str(business.pk)})
    assert listed.status_code == 200
    assert "token" not in listed.data[0]

    newcomer = make_user("newcomer", "+912222222222")
    newcomer_client = make_client(newcomer)
    # Wrong token fails closed.
    denied = newcomer_client.post(
        f"/api/v1/invitations/{invitation.pk}/accept/",
        {"token": "00000000-0000-0000-0000-000000000000"},
        format="json",
    )
    assert denied.status_code == 403
    accepted = newcomer_client.post(
        f"/api/v1/invitations/{invitation.pk}/accept/",
        {"token": token},
        format="json",
    )
    assert accepted.status_code == 201, accepted.data
    assert accepted.data["role"] == "MANAGER"
    membership = Membership.objects.get(user=newcomer, business=business)
    assert membership.is_active
    assert list(membership.locations.all()) == [location]
    invitation.refresh_from_db()
    assert invitation.status == "ACCEPTED"


def test_invite_validations(shop, owner_client):
    user, business, _, _ = shop
    assert invite(owner_client, business, role="OWNER").status_code == 400
    assert invite(owner_client, business, phone="not-a-phone").status_code == 400
    assert invite(owner_client, business).status_code == 201
    # Duplicate pending invitation is rejected.
    assert invite(owner_client, business).status_code == 400
    # Existing members cannot be invited again.
    existing = make_user("existing", "+913333333333")
    Membership.objects.create(user=existing, business=business, role="CASHIER")
    assert invite(owner_client, business, phone="+913333333333").status_code == 400
    # The owner's own phone is already a member.
    assert invite(owner_client, business, phone="+911111111111").status_code == 400
    # Non-owners cannot invite.
    cashier = make_user("cashier", "+914444444444")
    Membership.objects.create(user=cashier, business=business, role="CASHIER")
    stranger = invite(make_client(cashier), business, phone="+915555555555")
    assert stranger.status_code == 403
    assert user  # fixture anchor


def test_invite_revoke_and_expiry(shop, owner_client):
    _, business, _, _ = shop
    response = invite(owner_client, business)
    invitation = Invitation.objects.get()
    revoked = owner_client.post(f"/api/v1/invitations/{invitation.pk}/revoke/", {}, format="json")
    assert revoked.status_code == 200
    assert revoked.data["status"] == "REVOKED"
    newcomer = make_user("late", "+912222222222")
    late = make_client(newcomer).post(
        f"/api/v1/invitations/{invitation.pk}/accept/",
        {"token": response.data["token"]},
        format="json",
    )
    assert late.status_code == 400


def test_accept_requires_matching_phone(shop, owner_client):
    _, business, _, _ = shop
    response = invite(owner_client, business)
    invitation = Invitation.objects.get()
    other = make_user("other", "+919999999999")
    denied = make_client(other).post(
        f"/api/v1/invitations/{invitation.pk}/accept/",
        {"token": response.data["token"]},
        format="json",
    )
    assert denied.status_code == 403


def test_membership_revoke_signs_member_out(shop, owner_client):
    user, business, _, _ = shop
    member = make_user("member", "+916666666666")
    membership = Membership.objects.create(user=member, business=business, role="MANAGER")
    tokens = RefreshToken.for_user(member)
    member_client = APIClient()
    member_client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens.access_token}")
    assert member_client.get("/api/v1/sales/", {"business_id": str(business.pk)}).status_code == 200
    revoked = owner_client.post(f"/api/v1/memberships/{membership.pk}/revoke/", {}, format="json")
    assert revoked.status_code == 200
    assert revoked.data["is_active"] is False
    # The member's identity token no longer works anywhere.
    assert member_client.get("/api/v1/sales/", {"business_id": str(business.pk)}).status_code == 401
    refresh = APIClient().post("/api/v1/auth/refresh/", {"refresh": str(tokens)}, format="json")
    assert refresh.status_code == 401
    # Owners cannot revoke themselves.
    own = Membership.objects.get(user=user)
    assert (
        owner_client.post(f"/api/v1/memberships/{own.pk}/revoke/", {}, format="json").status_code
        == 400
    )


def test_logout_all_invalidates_every_device(shop):
    user, _, _, _ = shop
    first = RefreshToken.for_user(user)
    second = RefreshToken.for_user(user)
    first_client = APIClient()
    first_client.credentials(HTTP_AUTHORIZATION=f"Bearer {first.access_token}")
    response = first_client.post("/api/v1/auth/logout-all/", {"refresh": str(first)}, format="json")
    assert response.status_code == 200
    second_client = APIClient()
    second_client.credentials(HTTP_AUTHORIZATION=f"Bearer {second.access_token}")
    assert second_client.get("/api/v1/me/").status_code == 401
    assert (
        APIClient()
        .post("/api/v1/auth/refresh/", {"refresh": str(second)}, format="json")
        .status_code
        == 401
    )
    # Tokens issued after the revocation work again.
    from datetime import timedelta

    from django.utils import timezone

    from apps.authentication.models import SessionRevocation

    SessionRevocation.objects.filter(user=user).update(
        revoked_at=timezone.now() - timedelta(seconds=10)
    )
    third = RefreshToken.for_user(user)
    third_client = APIClient()
    third_client.credentials(HTTP_AUTHORIZATION=f"Bearer {third.access_token}")
    assert third_client.get("/api/v1/me/").status_code == 200


def test_patch_me_updates_display_name(shop):
    user, _, _, _ = shop
    client = make_client(user)
    response = client.patch("/api/v1/me/", {"display_name": "Amit"}, format="json")
    assert response.status_code == 200
    assert response.json()["display_name"] == "Amit"
    too_long = client.patch("/api/v1/me/", {"display_name": "x" * 121}, format="json")
    assert too_long.status_code == 400


def test_business_update_and_default_price_mode(shop, owner_client):
    _, business, _, _ = shop
    response = owner_client.patch(
        f"/api/v1/businesses/{business.pk}/",
        {"name": "Renamed shop", "default_price_mode": "WHOLESALE"},
        format="json",
    )
    assert response.status_code == 200, response.data
    assert response.data["name"] == "Renamed shop"
    assert response.data["default_price_mode"] == "WHOLESALE"
    assert (
        owner_client.patch(
            f"/api/v1/businesses/{business.pk}/",
            {"default_price_mode": "BROKEN"},
            format="json",
        ).status_code
        == 400
    )
    # A sale without an explicit price uses the wholesale pack price.
    client = owner_client
    sale = client.post(
        "/api/v1/sales/",
        {
            "business_id": str(business.pk),
            "location_id": str(Location.objects.get(business=business).pk),
            "lines": [
                {
                    "pack_id": str(business.products.first().packs.first().pk),
                    "quantity": "3",
                }
            ],
            "paid_amount_minor": 225000,
            "payment_method": "CASH",
            "idempotency_key": "wholesale-default",
        },
        format="json",
    )
    assert sale.status_code == 201, sale.data
    assert sale.data["price_mode"] == "WHOLESALE"
    assert sale.data["grand_total_minor"] == 225000
    assert Business.objects.exclude(pk=business.pk).count() == 0
