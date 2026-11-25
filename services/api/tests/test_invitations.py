import json
from datetime import timedelta

import pytest
from conftest import rls_is_enforced
from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import connection
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.tenancy import rls
from apps.tenancy.models import AuditEvent, Business, Invitation, Location, Membership
from apps.tenancy.serializers import InvitationSerializer

User = get_user_model()

pytestmark = pytest.mark.django_db


@pytest.fixture
def invitation_context(db):
    owner = User.objects.create_user(
        username="invite-owner",
        phone_e164="+919876500001",
        password="OwnerPass123!",
    )
    invitee = User.objects.create_user(
        username="invitee",
        phone_e164="+919876500002",
        password="InviteePass123!",
    )
    other_owner = User.objects.create_user(
        username="other-owner",
        phone_e164="+919876500003",
        password="OtherPass123!",
    )
    manager = User.objects.create_user(
        username="invite-manager",
        phone_e164="+919876500004",
        password="ManagerPass123!",
    )
    business = Business.objects.create(name="Invitation shop")
    other_business = Business.objects.create(name="Other shop")
    location = Location.objects.create(business=business, code="MAIN", name="Main")
    second_location = Location.objects.create(business=business, code="BACK", name="Back office")
    other_location = Location.objects.create(
        business=other_business, code="MAIN", name="Other main"
    )
    Membership.objects.create(user=owner, business=business, role=Membership.Role.OWNER)
    Membership.objects.create(user=manager, business=business, role=Membership.Role.MANAGER)
    Membership.objects.create(user=other_owner, business=other_business, role=Membership.Role.OWNER)
    return {
        "owner": owner,
        "invitee": invitee,
        "other_owner": other_owner,
        "manager": manager,
        "business": business,
        "other_business": other_business,
        "location": location,
        "second_location": second_location,
        "other_location": other_location,
    }


def _client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def _create_invitation(client, context, **overrides):
    payload = {
        "business": str(context["business"].pk),
        "invitee_phone": context["invitee"].phone_e164,
        "role": Membership.Role.CASHIER,
        "locations": [str(context["location"].pk)],
    }
    payload.update(overrides)
    response = client.post("/api/v1/invitations/", payload)
    assert response.status_code == status.HTTP_201_CREATED, response.data
    return response


def _expected_audit_metadata(invitation, *, membership=None):
    metadata = {
        "invitation_id": str(invitation.pk),
        "status": invitation.status,
        "role": invitation.role,
        "location_ids": sorted(str(location.pk) for location in invitation.locations.all()),
        "expires_at": invitation.expires_at.isoformat(),
    }
    if membership is not None:
        metadata["membership_id"] = str(membership.pk)
    return metadata


def _assert_safe_audit_metadata(audit, raw_token, token_hash):
    payload = json.dumps(audit.metadata, sort_keys=True)
    assert raw_token not in payload
    assert token_hash not in payload
    assert "token" not in audit.metadata
    assert "token_hash" not in audit.metadata


def test_owner_creates_hashed_invitation_with_one_time_token(invitation_context):
    client = _client(invitation_context["owner"])
    response = _create_invitation(client, invitation_context)

    invitation = Invitation.objects.get(pk=response.data["id"])
    raw_token = response.data["token"]
    assert invitation.token_hash == Invitation.hash_token(raw_token)
    assert invitation.token_hash != raw_token
    assert invitation.inviter == invitation_context["owner"]
    assert invitation.status == Invitation.Status.PENDING
    assert invitation.expires_at > timezone.now() + timedelta(days=6)
    assert list(invitation.locations.all()) == [invitation_context["location"]]
    assert "token_hash" not in response.data

    audit = AuditEvent.objects.get(
        business=invitation.business,
        event_type=Invitation.AuditEventType.CREATED,
        aggregate_id=invitation.pk,
    )
    assert audit.actor == invitation_context["owner"]
    assert audit.aggregate_type == "tenancy.invitation"
    assert audit.source == "API"
    assert audit.location is None
    assert audit.metadata == _expected_audit_metadata(invitation)
    _assert_safe_audit_metadata(audit, raw_token, invitation.token_hash)


def test_list_never_exposes_invitation_token(invitation_context):
    owner_client = _client(invitation_context["owner"])
    created = _create_invitation(owner_client, invitation_context)
    response = owner_client.get(
        f"/api/v1/invitations/?business_id={invitation_context['business'].pk}"
    )

    assert response.status_code == status.HTTP_200_OK
    assert len(response.data) == 1
    assert response.data[0]["id"] == created.data["id"]
    assert "token" not in response.data[0]
    assert "token_hash" not in response.data[0]
    assert owner_client.get("/api/v1/invitations/").data == []


def test_invited_user_accepts_with_role_and_locations(invitation_context):
    owner_client = _client(invitation_context["owner"])
    token = _create_invitation(
        owner_client,
        invitation_context,
        role=Membership.Role.MANAGER,
        locations=[
            str(invitation_context["location"].pk),
            str(invitation_context["second_location"].pk),
        ],
    ).data["token"]

    response = _client(invitation_context["invitee"]).post(
        "/api/v1/invitations/accept/", {"token": token}
    )
    assert response.status_code == status.HTTP_200_OK, response.data
    assert response.data["status"] == Invitation.Status.ACCEPTED
    assert "token" not in response.data
    assert "token_hash" not in response.data

    membership = Membership.objects.get(
        user=invitation_context["invitee"], business=invitation_context["business"]
    )
    assert membership.role == Membership.Role.MANAGER
    assert set(membership.locations.all()) == {
        invitation_context["location"],
        invitation_context["second_location"],
    }
    invitation = Invitation.objects.get(pk=response.data["id"])
    assert invitation.accepted_by == invitation_context["invitee"]
    assert invitation.accepted_at is not None

    audit = AuditEvent.objects.get(
        business=invitation.business,
        event_type=Invitation.AuditEventType.ACCEPTED,
        aggregate_id=invitation.pk,
    )
    assert audit.actor == invitation_context["invitee"]
    assert audit.aggregate_type == "tenancy.invitation"
    assert audit.metadata == _expected_audit_metadata(invitation, membership=membership)
    _assert_safe_audit_metadata(audit, token, invitation.token_hash)
    owner_feed = owner_client.get(
        "/api/v1/audit-events/", {"business_id": str(invitation.business_id)}
    )
    assert owner_feed.status_code == status.HTTP_200_OK
    assert [event["event_type"] for event in owner_feed.data] == [
        Invitation.AuditEventType.ACCEPTED,
        Invitation.AuditEventType.CREATED,
    ]
    feed_payload = json.dumps(owner_feed.data)
    assert token not in feed_payload
    assert invitation.token_hash not in feed_payload

    replay = _client(invitation_context["invitee"]).post(
        "/api/v1/invitations/accept/", {"token": token}
    )
    assert replay.status_code == status.HTTP_400_BAD_REQUEST
    assert AuditEvent.objects.filter(event_type=Invitation.AuditEventType.ACCEPTED).count() == 1
    assert (
        owner_client.post(f"/api/v1/invitations/{invitation.pk}/revoke/").status_code
        == status.HTTP_400_BAD_REQUEST
    )
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.REVOKED).exists()


def test_expired_invitation_cannot_be_accepted(invitation_context):
    owner_client = _client(invitation_context["owner"])
    token = _create_invitation(owner_client, invitation_context).data["token"]
    invitation = Invitation.objects.get(token_hash=Invitation.hash_token(token))
    invitation.expires_at = timezone.now() - timedelta(minutes=1)
    invitation.save(update_fields=["expires_at"])

    response = _client(invitation_context["invitee"]).post(
        "/api/v1/invitations/accept/", {"token": token}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert not Membership.objects.filter(
        user=invitation_context["invitee"], business=invitation_context["business"]
    ).exists()
    assert InvitationSerializer(invitation).data["status"] == Invitation.Status.EXPIRED
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.ACCEPTED).exists()


def test_wrong_phone_cannot_accept_invitation(invitation_context):
    owner_client = _client(invitation_context["owner"])
    token = _create_invitation(owner_client, invitation_context).data["token"]

    response = _client(invitation_context["other_owner"]).post(
        "/api/v1/invitations/accept/", {"token": token}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert not Membership.objects.filter(
        user=invitation_context["other_owner"], business=invitation_context["business"]
    ).exists()
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.ACCEPTED).exists()


def test_owner_revokes_invitation_and_token_stops_working(invitation_context):
    owner_client = _client(invitation_context["owner"])
    created = _create_invitation(owner_client, invitation_context)
    response = owner_client.post(f"/api/v1/invitations/{created.data['id']}/revoke/")

    assert response.status_code == status.HTTP_200_OK
    assert response.data["status"] == Invitation.Status.REVOKED
    assert "token" not in response.data
    assert "token_hash" not in response.data
    invitation = Invitation.objects.get(pk=created.data["id"])
    audit = AuditEvent.objects.get(
        business=invitation.business,
        event_type=Invitation.AuditEventType.REVOKED,
        aggregate_id=invitation.pk,
    )
    assert audit.actor == invitation_context["owner"]
    assert audit.metadata == _expected_audit_metadata(invitation)
    _assert_safe_audit_metadata(audit, created.data["token"], invitation.token_hash)
    owner_feed = owner_client.get(
        "/api/v1/audit-events/", {"business_id": str(invitation.business_id)}
    )
    assert owner_feed.status_code == status.HTTP_200_OK
    assert [event["event_type"] for event in owner_feed.data] == [
        Invitation.AuditEventType.REVOKED,
        Invitation.AuditEventType.CREATED,
    ]
    feed_payload = json.dumps(owner_feed.data)
    assert created.data["token"] not in feed_payload
    assert invitation.token_hash not in feed_payload

    rejected = _client(invitation_context["invitee"]).post(
        "/api/v1/invitations/accept/", {"token": created.data["token"]}
    )
    assert rejected.status_code == status.HTTP_400_BAD_REQUEST
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.ACCEPTED).exists()


def test_non_owner_cannot_create_list_or_revoke(invitation_context):
    owner_client = _client(invitation_context["owner"])
    created = _create_invitation(owner_client, invitation_context)
    manager_client = _client(invitation_context["manager"])
    payload = {
        "business": str(invitation_context["business"].pk),
        "invitee_phone": invitation_context["invitee"].phone_e164,
        "role": Membership.Role.CASHIER,
        "locations": [str(invitation_context["location"].pk)],
    }

    assert (
        manager_client.post("/api/v1/invitations/", payload).status_code
        == status.HTTP_403_FORBIDDEN
    )
    assert (
        manager_client.get(
            f"/api/v1/invitations/?business_id={invitation_context['business'].pk}"
        ).status_code
        == status.HTTP_403_FORBIDDEN
    )
    assert (
        manager_client.post(f"/api/v1/invitations/{created.data['id']}/revoke/").status_code
        == status.HTTP_403_FORBIDDEN
    )
    assert list(
        AuditEvent.objects.filter(business=invitation_context["business"]).values_list(
            "event_type", flat=True
        )
    ) == [Invitation.AuditEventType.CREATED]


def test_cross_tenant_owner_cannot_manage_invitations(invitation_context):
    owner_client = _client(invitation_context["owner"])
    created = _create_invitation(owner_client, invitation_context)
    other_client = _client(invitation_context["other_owner"])
    business_id = invitation_context["business"].pk

    assert other_client.get(f"/api/v1/invitations/?business_id={business_id}").status_code in {
        status.HTTP_403_FORBIDDEN,
        status.HTTP_404_NOT_FOUND,
    }
    assert other_client.post(f"/api/v1/invitations/{created.data['id']}/revoke/").status_code in {
        status.HTTP_403_FORBIDDEN,
        status.HTTP_404_NOT_FOUND,
    }
    assert other_client.post(
        "/api/v1/invitations/",
        {
            "business": str(business_id),
            "invitee_phone": invitation_context["invitee"].phone_e164,
            "role": Membership.Role.CASHIER,
            "locations": [],
        },
    ).status_code in {status.HTTP_400_BAD_REQUEST, status.HTTP_403_FORBIDDEN}

    assert list(
        AuditEvent.objects.filter(business=invitation_context["business"]).values_list(
            "event_type", flat=True
        )
    ) == [Invitation.AuditEventType.CREATED]
    assert not AuditEvent.objects.filter(business=invitation_context["other_business"]).exists()
    assert other_client.get(
        "/api/v1/audit-events/", {"business_id": str(business_id)}
    ).status_code in {status.HTTP_403_FORBIDDEN, status.HTTP_404_NOT_FOUND}

    owner_feed = owner_client.get("/api/v1/audit-events/", {"business_id": str(business_id)})
    assert owner_feed.status_code == status.HTTP_200_OK
    assert [event["event_type"] for event in owner_feed.data] == [Invitation.AuditEventType.CREATED]
    invitation = Invitation.objects.get(pk=created.data["id"])
    feed_payload = json.dumps(owner_feed.data)
    assert created.data["token"] not in feed_payload
    assert invitation.token_hash not in feed_payload
    assert (
        other_client.get(
            "/api/v1/audit-events/",
            {"business_id": str(invitation_context["other_business"].pk)},
        ).data
        == []
    )


def test_invalid_role_and_cross_tenant_location_are_rejected(invitation_context):
    client = _client(invitation_context["owner"])
    base = {
        "business": str(invitation_context["business"].pk),
        "invitee_phone": invitation_context["invitee"].phone_e164,
        "role": Membership.Role.CASHIER,
        "locations": [str(invitation_context["location"].pk)],
    }
    assert (
        client.post("/api/v1/invitations/", {**base, "role": "SUPERADMIN"}).status_code
        == status.HTTP_400_BAD_REQUEST
    )
    assert (
        client.post(
            "/api/v1/invitations/",
            {**base, "locations": [str(invitation_context["other_location"].pk)]},
        ).status_code
        == status.HTTP_400_BAD_REQUEST
    )
    assert Invitation.objects.count() == 0
    assert AuditEvent.objects.count() == 0


def test_deactivated_location_invalidates_acceptance(invitation_context):
    owner_client = _client(invitation_context["owner"])
    token = _create_invitation(owner_client, invitation_context).data["token"]
    location = invitation_context["location"]
    location.is_active = False
    location.save(update_fields=["is_active"])

    response = _client(invitation_context["invitee"]).post(
        "/api/v1/invitations/accept/", {"token": token}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert not Membership.objects.filter(
        user=invitation_context["invitee"], business=invitation_context["business"]
    ).exists()
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.ACCEPTED).exists()


def test_existing_membership_cannot_be_created_again(invitation_context):
    Membership.objects.create(
        user=invitation_context["invitee"],
        business=invitation_context["business"],
        role=Membership.Role.CASHIER,
    )
    owner_client = _client(invitation_context["owner"])
    token = _create_invitation(owner_client, invitation_context).data["token"]

    response = _client(invitation_context["invitee"]).post(
        "/api/v1/invitations/accept/", {"token": token}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert (
        Membership.objects.filter(
            user=invitation_context["invitee"], business=invitation_context["business"]
        ).count()
        == 1
    )
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.ACCEPTED).exists()


def test_accept_requires_authentication(invitation_context):
    owner_client = _client(invitation_context["owner"])
    token = _create_invitation(owner_client, invitation_context).data["token"]
    response = APIClient().post("/api/v1/invitations/accept/", {"token": token})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.ACCEPTED).exists()


def test_audit_failure_rolls_back_invitation_creation(invitation_context, monkeypatch):
    client = _client(invitation_context["owner"])

    def fail_audit(*args, **kwargs):
        raise RuntimeError("audit unavailable")

    monkeypatch.setattr(Invitation, "record_audit", fail_audit)
    with pytest.raises(RuntimeError, match="audit unavailable"):
        _create_invitation(client, invitation_context)
    assert Invitation.objects.count() == 0
    assert AuditEvent.objects.count() == 0


def test_audit_failure_rolls_back_invitation_acceptance(invitation_context, monkeypatch):
    owner_client = _client(invitation_context["owner"])
    token = _create_invitation(owner_client, invitation_context).data["token"]
    invitation = Invitation.objects.get(token_hash=Invitation.hash_token(token))

    def fail_audit(*args, **kwargs):
        raise RuntimeError("audit unavailable")

    monkeypatch.setattr(Invitation, "record_audit", fail_audit)
    with pytest.raises(RuntimeError, match="audit unavailable"):
        _client(invitation_context["invitee"]).post("/api/v1/invitations/accept/", {"token": token})
    invitation.refresh_from_db()
    assert invitation.status == Invitation.Status.PENDING
    assert invitation.accepted_by is None
    assert not Membership.objects.filter(
        user=invitation_context["invitee"], business=invitation_context["business"]
    ).exists()
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.ACCEPTED).exists()
    assert AuditEvent.objects.filter(event_type=Invitation.AuditEventType.CREATED).count() == 1


def test_audit_failure_rolls_back_invitation_revocation(invitation_context, monkeypatch):
    owner_client = _client(invitation_context["owner"])
    created = _create_invitation(owner_client, invitation_context)
    invitation = Invitation.objects.get(pk=created.data["id"])

    def fail_audit(*args, **kwargs):
        raise RuntimeError("audit unavailable")

    monkeypatch.setattr(Invitation, "record_audit", fail_audit)
    with pytest.raises(RuntimeError, match="audit unavailable"):
        owner_client.post(f"/api/v1/invitations/{invitation.pk}/revoke/")
    invitation.refresh_from_db()
    assert invitation.status == Invitation.Status.PENDING
    assert invitation.revoked_at is None
    assert not AuditEvent.objects.filter(event_type=Invitation.AuditEventType.REVOKED).exists()
    assert AuditEvent.objects.filter(event_type=Invitation.AuditEventType.CREATED).count() == 1


@pytest.mark.skipif(connection.vendor != "postgresql", reason="RLS is a PostgreSQL control")
def test_invitation_tables_have_rls_and_runtime_grants(invitation_context):
    tables = (
        "tenancy_invitation",
        "tenancy_invitation_locations",
        "tenancy_membership_locations",
        "tenancy_auditevent",
    )
    with connection.cursor() as cursor:
        for table in tables:
            cursor.execute(
                "SELECT relrowsecurity, relforcerowsecurity FROM pg_class WHERE oid = %s::regclass",
                [table],
            )
            assert cursor.fetchone() == (True, True)
            cursor.execute(
                "SELECT 1 FROM pg_policies WHERE tablename = %s "
                "AND policyname = 'tenant_isolation'",
                [table],
            )
            assert cursor.fetchone() is not None

        role = getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)
        cursor.execute("SELECT 1 FROM pg_roles WHERE rolname = %s", [role])
        if cursor.fetchone() is not None:
            for table in (*tables, "authentication_sessionversion"):
                cursor.execute(
                    "SELECT has_table_privilege(%s, %s, 'SELECT')",
                    [role, table],
                )
                assert cursor.fetchone()[0], f"{role} needs SELECT on {table}"
            cursor.execute(
                "SELECT has_sequence_privilege(%s, %s, 'USAGE')",
                [role, "authentication_sessionversion_id_seq"],
            )
            assert cursor.fetchone()[0], f"{role} needs USAGE on the session version sequence"


@pytest.mark.skipif(connection.vendor != "postgresql", reason="RLS is a PostgreSQL control")
def test_invitation_bootstrap_read_is_limited_to_invited_phone(invitation_context):
    if not rls_is_enforced(connection):
        pytest.skip("connected role bypasses RLS")
    owner_client = _client(invitation_context["owner"])
    own_invitation = _create_invitation(owner_client, invitation_context)
    Invitation.create_with_token(
        business=invitation_context["other_business"],
        invitee_phone="+919876599999",
        role=Membership.Role.CASHIER,
        inviter=invitation_context["other_owner"],
    )

    rls.set_tenant_scope(
        connection,
        user_id=invitation_context["invitee"].pk,
        business_ids=[],
    )
    try:
        visible = Invitation.objects.values_list("pk", flat=True)
        assert [str(pk) for pk in visible] == [str(own_invitation.data["id"])]
    finally:
        rls.set_staff_scope(connection)
