"""Notification device authorization, durable reminders, and FCM delivery."""

import json
import urllib.error
from datetime import date, timedelta
from types import SimpleNamespace
from unittest.mock import Mock

import pytest
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.common.models import User
from apps.integrations import push
from apps.integrations.models import NotificationDelivery, NotificationDevice, Reminder
from apps.integrations.notifications import REMINDER_TOPIC, schedule_reminder
from apps.integrations.push import FCMError, FCMv1Sender
from apps.operations.models import Payment, Sale
from apps.tenancy.models import Business, Location, Membership, OutboxEvent
from apps.tenancy.tasks import process_outbox_event

pytestmark = pytest.mark.django_db

DEVICES_URL = "/api/v1/integrations/notifications/devices/"
REMINDERS_URL = "/api/v1/integrations/notifications/reminders/"


@pytest.fixture
def notification_scope():
    user = User.objects.create_user(username="notification-owner")
    business = Business.objects.create(name="Notification shop")
    location = Location.objects.create(business=business, code="MAIN", name="Main")
    Membership.objects.create(user=user, business=business, role=Membership.Role.OWNER)
    return user, business, location


def _client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def _device_payload(business, location=None, **overrides):
    payload = {
        "business_id": str(business.id),
        "fcm_token": "notification-token-1234",
        "platform": "ANDROID",
        "metadata": {"app_version": "1.0"},
    }
    if location is not None:
        payload["location_id"] = str(location.id)
    payload.update(overrides)
    return payload


def _reminder_payload(business, location=None, **overrides):
    payload = {
        "business_id": str(business.id),
        "title": "Stock check",
        "body": "Review today's closing stock.",
        "scheduled_at": (timezone.now() + timedelta(hours=1)).isoformat(),
        "dedupe_key": "stock-check-1",
    }
    if location is not None:
        payload["location_id"] = str(location.id)
    payload.update(overrides)
    return payload


def _due_reminder(user, business, location, *, token="notification-token-1234"):
    device = NotificationDevice.objects.create(
        user=user,
        business=business,
        location=location,
        fcm_token=token,
    )
    reminder, _ = schedule_reminder(
        user=user,
        business=business,
        location=location,
        title="Payment reminder",
        body="A payment is due.",
        scheduled_at=timezone.now() - timedelta(minutes=1),
        dedupe_key=f"due-{token}",
    )
    event = OutboxEvent.objects.get(topic=REMINDER_TOPIC, dedupe_key=f"reminder:{reminder.id}")
    return device, reminder, event


class _Response:
    def __init__(self, payload: dict, status_code=200):
        self.body = json.dumps(payload).encode()
        self.status = status_code

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def getcode(self):
        return self.status

    def read(self, size=-1):
        return self.body if size < 0 else self.body[:size]


class TestDeviceEndpoints:
    def test_register_list_and_unregister_are_user_scoped(self, notification_scope):
        user, business, location = notification_scope
        client = _client(user)
        response = client.post(DEVICES_URL, _device_payload(business, location), format="json")
        assert response.status_code == status.HTTP_201_CREATED
        device = NotificationDevice.objects.get()
        assert device.user_id == user.id
        assert device.location_id == location.id
        assert "notification-token-1234" not in response.text
        assert response.json()["token_suffix"] == "…1234"

        listed = client.get(DEVICES_URL)
        assert listed.status_code == status.HTTP_200_OK
        assert len(listed.json()) == 1
        assert "fcm_token" not in listed.json()[0]

        unregistered = client.delete(f"{DEVICES_URL}{device.id}/")
        assert unregistered.status_code == status.HTTP_204_NO_CONTENT
        device.refresh_from_db()
        assert device.status == NotificationDevice.Status.DISABLED
        assert device.unregistered_at is not None

    def test_registration_replay_reuses_token_row(self, notification_scope):
        user, business, location = notification_scope
        client = _client(user)
        payload = _device_payload(business, location)
        assert client.post(DEVICES_URL, payload, format="json").status_code == 201
        replay = client.post(DEVICES_URL, payload, format="json")
        assert replay.status_code == status.HTTP_200_OK
        assert NotificationDevice.objects.count() == 1

    def test_device_token_cannot_be_reassigned_to_another_user(self, notification_scope):
        user, business, location = notification_scope
        other = User.objects.create_user(username="other-device-user")
        membership = Membership.objects.create(
            user=other, business=business, role=Membership.Role.CASHIER
        )
        membership.locations.add(location)
        assert (
            _client(user)
            .post(DEVICES_URL, _device_payload(business, location), format="json")
            .status_code
            == status.HTTP_201_CREATED
        )

        response = _client(other).post(
            DEVICES_URL, _device_payload(business, location), format="json"
        )

        assert response.status_code == status.HTTP_409_CONFLICT
        device = NotificationDevice.objects.get()
        assert device.user_id == user.id

    def test_cross_tenant_and_location_mismatch_are_rejected(self, notification_scope):
        user, business, location = notification_scope
        other = User.objects.create_user(username="other-notification-user")
        other_business = Business.objects.create(name="Other")
        other_location = Location.objects.create(business=other_business, code="MAIN", name="Main")
        Membership.objects.create(user=other, business=other_business, role="OWNER")

        response = _client(other).post(
            DEVICES_URL, _device_payload(business, location), format="json"
        )
        assert response.status_code in {status.HTTP_403_FORBIDDEN, status.HTTP_404_NOT_FOUND}
        assert NotificationDevice.objects.count() == 0

        mismatch = _client(user).post(
            DEVICES_URL,
            _device_payload(business, other_location, fcm_token="mismatch-token-1234"),
            format="json",
        )
        assert mismatch.status_code == status.HTTP_400_BAD_REQUEST
        assert NotificationDevice.objects.count() == 0

    def test_unauthenticated_and_foreign_unregister_are_rejected(self, notification_scope):
        user, business, location = notification_scope
        assert (
            APIClient()
            .post(DEVICES_URL, _device_payload(business, location), format="json")
            .status_code
            == status.HTTP_401_UNAUTHORIZED
        )
        device = NotificationDevice.objects.create(
            user=user, business=business, location=location, fcm_token="foreign-token-1234"
        )
        other = User.objects.create_user(username="foreign-device-user")
        Membership.objects.create(user=other, business=business, role="OWNER")
        response = _client(other).delete(f"{DEVICES_URL}{device.id}/")
        assert response.status_code == status.HTTP_404_NOT_FOUND
        device.refresh_from_db()
        assert device.status == NotificationDevice.Status.ACTIVE


class TestReminderEndpoints:
    def test_create_is_durable_idempotent_and_never_sends_inline(
        self, notification_scope, settings, monkeypatch
    ):
        user, business, location = notification_scope
        settings.FCM_ENABLED = True
        sender = Mock()
        monkeypatch.setattr("apps.integrations.notifications.get_fcm_sender", lambda: sender)
        client = _client(user)
        payload = _reminder_payload(business, location)

        first = client.post(REMINDERS_URL, payload, format="json")
        replay = client.post(REMINDERS_URL, payload, format="json")

        assert first.status_code == status.HTTP_201_CREATED
        assert replay.status_code == status.HTTP_200_OK
        assert first.json()["id"] == replay.json()["id"]
        assert Reminder.objects.count() == 1
        event = OutboxEvent.objects.get(topic=REMINDER_TOPIC)
        assert event.payload == {"reminder_id": str(first.json()["id"])}
        assert event.available_at == Reminder.objects.get().scheduled_at
        assert process_outbox_event.run(str(event.id)) == "not-due"
        assert not NotificationDelivery.objects.exists()
        sender.send.assert_not_called()

    def test_list_detail_update_and_cancel(self, notification_scope):
        user, business, location = notification_scope
        client = _client(user)
        created = client.post(REMINDERS_URL, _reminder_payload(business, location), format="json")
        reminder = Reminder.objects.get()
        assert created.status_code == status.HTTP_201_CREATED
        assert client.get(REMINDERS_URL).json()[0]["id"] == str(reminder.id)
        assert client.get(f"{REMINDERS_URL}{reminder.id}/").status_code == 200

        new_time = timezone.now() + timedelta(hours=3)
        updated = client.patch(
            f"{REMINDERS_URL}{reminder.id}/",
            {"title": "Updated stock check", "scheduled_at": new_time.isoformat()},
            format="json",
        )
        assert updated.status_code == 200
        reminder.refresh_from_db()
        event = OutboxEvent.objects.get(topic=REMINDER_TOPIC)
        assert reminder.title == "Updated stock check"
        assert event.available_at == new_time

        cancelled = client.delete(f"{REMINDERS_URL}{reminder.id}/")
        assert cancelled.status_code == status.HTTP_204_NO_CONTENT
        reminder.refresh_from_db()
        assert reminder.status == Reminder.Status.CANCELLED
        assert process_outbox_event.run(str(event.id)) == "not-due"
        event.available_at = timezone.now() - timedelta(seconds=1)
        event.save(update_fields=["available_at", "updated_at"])
        assert process_outbox_event.run(str(event.id)) == "processed"
        assert not NotificationDelivery.objects.exists()

    def test_past_reminder_and_cross_user_access_are_rejected(self, notification_scope):
        user, business, location = notification_scope
        client = _client(user)
        past = client.post(
            REMINDERS_URL,
            _reminder_payload(
                business,
                location,
                scheduled_at=(timezone.now() - timedelta(minutes=1)).isoformat(),
                dedupe_key="past",
            ),
            format="json",
        )
        assert past.status_code == status.HTTP_400_BAD_REQUEST
        created = client.post(REMINDERS_URL, _reminder_payload(business, location), format="json")
        reminder = Reminder.objects.get()

        other = User.objects.create_user(username="other-reminder-user")
        Membership.objects.create(user=other, business=business, role="OWNER")
        other_client = _client(other)
        assert other_client.get(REMINDERS_URL).json() == []
        assert other_client.get(f"{REMINDERS_URL}{reminder.id}/").status_code == 404
        assert other_client.delete(f"{REMINDERS_URL}{reminder.id}/").status_code == 404
        reminder.refresh_from_db()
        assert reminder.status == Reminder.Status.SCHEDULED
        assert created.status_code == 201

    def test_cashier_requires_assigned_location(self, notification_scope):
        user, business, location = notification_scope
        Membership.objects.filter(user=user, business=business).update(role="CASHIER")
        response = _client(user).post(
            REMINDERS_URL, _reminder_payload(business, location), format="json"
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN
        assert Reminder.objects.count() == 0

        membership = Membership.objects.get(user=user, business=business)
        membership.locations.add(location)
        allowed = _client(user).post(
            REMINDERS_URL, _reminder_payload(business, location), format="json"
        )
        assert allowed.status_code == status.HTTP_201_CREATED


class TestFCMSender:
    def test_disabled_and_misconfigured_fail_closed(self, settings, monkeypatch):
        urlopen = Mock()
        monkeypatch.setattr(push.urllib.request, "urlopen", urlopen)
        settings.FCM_ENABLED = False
        with pytest.raises(FCMError) as disabled:
            FCMv1Sender().send(token="token", title="Title", body="Body", dedupe_key="event")
        assert disabled.value.code == "disabled"

        settings.FCM_ENABLED = True
        settings.FCM_PROJECT_ID = ""
        with pytest.raises(FCMError) as missing:
            FCMv1Sender().send(token="token", title="Title", body="Body", dedupe_key="event")
        assert missing.value.code == "misconfigured"
        urlopen.assert_not_called()

    @pytest.mark.parametrize(
        "setting_name", ["FCM_SERVICE_ACCOUNTCOUNT_JSON", "FCM_SERVICE_ACCOUNT_JSON"]
    )
    def test_service_account_setting_aliases(self, settings, setting_name):
        settings.FCM_PROJECT_ID = "dukaan-project"
        settings.FCM_SERVICE_ACCOUNTCOUNT_JSON = ""
        settings.FCM_SERVICE_ACCOUNT_JSON = ""
        setattr(
            settings,
            setting_name,
            json.dumps(
                {
                    "project_id": "dukaan-project",
                    "client_email": "sender@example.invalid",
                    "private_key": "private-key-value",
                }
            ),
        )
        credentials = SimpleNamespace(valid=True, token="oauth-token")
        factory = Mock(return_value=credentials)
        settings.FCM_ENABLED = True
        with pytest.MonkeyPatch.context() as patcher:
            patcher.setattr(push.service_account.Credentials, "from_service_account_info", factory)
            project_id, result = push._credentials()
        assert project_id == "dukaan-project"
        assert result.token == "oauth-token"
        assert factory.call_args.kwargs["scopes"] == [push.FCM_SCOPE]

    def test_http_v1_payload_and_response(self, settings, monkeypatch):
        settings.FCM_ENABLED = True
        monkeypatch.setattr(
            push, "_credentials", lambda: ("dukaan-project", SimpleNamespace(token="oauth-token"))
        )
        urlopen = Mock(return_value=_Response({"name": "projects/p/messages/1"}))
        monkeypatch.setattr(push.urllib.request, "urlopen", urlopen)

        result = FCMv1Sender().send(
            token="device-token",
            title="Sale posted",
            body="INV-1 was posted.",
            dedupe_key="sale-posted-1",
            data={"reminder_id": "r-1"},
        )

        assert result == "projects/p/messages/1"
        request = urlopen.call_args.args[0]
        assert request.full_url == (
            "https://fcm.googleapis.com/v1/projects/dukaan-project/messages:send"
        )
        assert request.get_header("Authorization") == "Bearer oauth-token"
        payload = json.loads(request.data)
        assert payload["message"]["token"] == "device-token"
        assert payload["message"]["notification"] == {
            "title": "Sale posted",
            "body": "INV-1 was posted.",
        }
        assert payload["message"]["data"] == {"reminder_id": "r-1"}

    @pytest.mark.parametrize("http_status,retryable", [(404, False), (429, True), (503, True)])
    def test_http_errors_are_classified(self, settings, monkeypatch, http_status, retryable):
        settings.FCM_ENABLED = True
        monkeypatch.setattr(
            push, "_credentials", lambda: ("project", SimpleNamespace(token="oauth-token"))
        )

        def fail(*args, **kwargs):
            raise urllib.error.HTTPError("https://fcm.invalid", http_status, "secret", {}, None)

        monkeypatch.setattr(push.urllib.request, "urlopen", fail)
        with pytest.raises(FCMError) as raised:
            FCMv1Sender().send(
                token="private-token", title="Title", body="Body", dedupe_key="event"
            )
        assert raised.value.retryable is retryable
        assert "private-token" not in str(raised.value)
        assert "secret" not in str(raised.value)


class TestOutboxNotifications:
    def test_disabled_fcm_skips_without_network(self, notification_scope, settings, monkeypatch):
        user, business, location = notification_scope
        settings.FCM_ENABLED = False
        _, reminder, event = _due_reminder(user, business, location)
        urlopen = Mock()
        monkeypatch.setattr(push.urllib.request, "urlopen", urlopen)

        assert process_outbox_event.run(str(event.id)) == "processed"

        reminder.refresh_from_db()
        event.refresh_from_db()
        delivery = NotificationDelivery.objects.get()
        assert reminder.status == Reminder.Status.SKIPPED
        assert delivery.status == NotificationDelivery.Status.SKIPPED
        assert event.status == OutboxEvent.Status.PROCESSED
        urlopen.assert_not_called()

    def test_retry_preserves_partial_work_and_redelivery_is_idempotent(
        self, notification_scope, settings, monkeypatch
    ):
        user, business, location = notification_scope
        settings.FCM_ENABLED = True
        _, reminder, event = _due_reminder(user, business, location)
        sender = Mock()
        sender.send.side_effect = [
            FCMError("FCM could not be reached.", code="network", retryable=True),
            "projects/p/messages/1",
        ]
        monkeypatch.setattr("apps.integrations.notifications.get_fcm_sender", lambda: sender)

        assert process_outbox_event.run(str(event.id)) == "retry"
        event.refresh_from_db()
        delivery = NotificationDelivery.objects.get()
        assert event.status == OutboxEvent.Status.PENDING
        assert event.available_at > timezone.now()
        assert delivery.status == NotificationDelivery.Status.PENDING
        assert delivery.attempts == 1

        event.available_at = timezone.now() - timedelta(seconds=1)
        event.save(update_fields=["available_at", "updated_at"])
        assert process_outbox_event.run(str(event.id)) == "processed"
        assert process_outbox_event.run(str(event.id)) == "already-processed"
        reminder.refresh_from_db()
        delivery.refresh_from_db()
        assert reminder.status == Reminder.Status.SENT
        assert delivery.status == NotificationDelivery.Status.SENT
        assert delivery.attempts == 2
        assert sender.send.call_count == 2
        assert NotificationDelivery.objects.count() == 1

    def test_retry_does_not_resend_a_successful_device(
        self, notification_scope, settings, monkeypatch
    ):
        user, business, location = notification_scope
        settings.FCM_ENABLED = True
        first_device, reminder, event = _due_reminder(
            user, business, location, token="first-device-token"
        )
        second_device = NotificationDevice.objects.create(
            user=user,
            business=business,
            location=location,
            fcm_token="second-device-token",
        )
        sender = Mock()
        sender.send.side_effect = [
            "projects/p/messages/1",
            FCMError("FCM could not be reached.", code="network", retryable=True),
            "projects/p/messages/2",
        ]
        monkeypatch.setattr("apps.integrations.notifications.get_fcm_sender", lambda: sender)

        assert process_outbox_event.run(str(event.id)) == "retry"
        first_delivery = NotificationDelivery.objects.get(device=first_device)
        second_delivery = NotificationDelivery.objects.get(device=second_device)
        assert first_delivery.status == NotificationDelivery.Status.SENT
        assert second_delivery.status == NotificationDelivery.Status.PENDING

        event.available_at = timezone.now() - timedelta(seconds=1)
        event.save(update_fields=["available_at", "updated_at"])
        assert process_outbox_event.run(str(event.id)) == "processed"

        first_delivery.refresh_from_db()
        second_delivery.refresh_from_db()
        reminder.refresh_from_db()
        assert first_delivery.attempts == 1
        assert second_delivery.attempts == 2
        assert reminder.status == Reminder.Status.SENT
        assert sender.send.call_count == 3

    @pytest.mark.parametrize(
        "topic,expected_title", [("sale.posted", "Sale posted"), ("sale.reversed", "Sale reversed")]
    )
    def test_domain_handlers_enqueue_concise_notification_once(
        self, notification_scope, topic, expected_title, monkeypatch
    ):
        user, business, location = notification_scope
        sale = Sale.objects.create(
            business=business,
            location=location,
            number="INV-NOTIFY-1",
            financial_year="2026-27",
            sequence_number=1,
            document_date=date.today(),
            posted_at=timezone.now(),
            created_by=user,
            idempotency_key="notify-sale-1",
            grand_total_minor=10000,
        )
        source = OutboxEvent.objects.create(
            business=business,
            topic=topic,
            dedupe_key=f"{topic}:{sale.id}",
            payload={"type": "operations.sale", "id": str(sale.id)},
            available_at=timezone.now(),
        )
        sender = Mock()
        monkeypatch.setattr("apps.integrations.notifications.get_fcm_sender", lambda: sender)

        assert process_outbox_event.run(str(source.id)) == "processed"

        reminder = Reminder.objects.get()
        child = OutboxEvent.objects.get(topic=REMINDER_TOPIC)
        expected_action = "posted" if topic.endswith("posted") else "reversed"
        assert reminder.title == expected_title
        assert reminder.body == f"Sale INV-NOTIFY-1 was {expected_action}."
        assert reminder.kind == Reminder.Kind.DOMAIN
        assert reminder.dedupe_key == f"domain:{source.dedupe_key}"
        assert child.payload == {"reminder_id": str(reminder.id)}
        sender.send.assert_not_called()

    def test_payment_event_without_document_number_is_concise(self, notification_scope):
        user, business, location = notification_scope
        payment = Payment.objects.create(
            business=business,
            location=location,
            direction=Payment.Direction.RECEIPT,
            method=Payment.Method.CASH,
            amount_minor=10000,
            payment_date=date.today(),
            created_by=user,
            idempotency_key="notify-payment-1",
        )
        source = OutboxEvent.objects.create(
            business=business,
            topic="payment.posted",
            dedupe_key=f"payment.posted:{payment.id}",
            payload={"type": "operations.payment", "id": str(payment.id)},
            available_at=timezone.now(),
        )

        assert process_outbox_event.run(str(source.id)) == "processed"

        reminder = Reminder.objects.get()
        assert reminder.title == "Payment posted"
        assert reminder.body == "Payment was posted."
