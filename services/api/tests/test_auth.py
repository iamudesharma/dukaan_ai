import pytest
from django.contrib.auth import get_user_model
from django.test import override_settings
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import AccessToken, RefreshToken

from apps.authentication.models import BlacklistedToken, PhoneOTP, SessionVersion

User = get_user_model()


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def user(db):
    return User.objects.create_user(
        username="phone_+919876543210",
        phone_e164="+919876543210",
        password="SecurePass123!",
        display_name="Test User",
    )


@pytest.mark.django_db
class TestSignup:
    def test_signup_creates_user(self, api_client):
        response = api_client.post(
            "/api/v1/auth/signup/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert "access" in response.data
        assert "refresh" in response.data
        assert response.data["user"]["phone"] == "+919876543210"
        assert User.objects.filter(phone_e164="+919876543210").exists()

    def test_signup_requires_onboarding(self, api_client):
        response = api_client.post(
            "/api/v1/auth/signup/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["onboarding_required"] is True

    def test_signup_rejects_phone_of_disabled_account(self, api_client, db):
        User.objects.create_user(
            username="phone_+919876543210",
            phone_e164="+919876543210",
            password="SecurePass123!",
            is_active=False,
        )
        response = api_client.post(
            "/api/v1/auth/signup/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_signup_rejects_common_password(self, api_client):
        response = api_client.post(
            "/api/v1/auth/signup/",
            {"phone": "+919876543210", "password": "password123"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert not User.objects.filter(phone_e164="+919876543210").exists()

    def test_signup_duplicate_phone(self, api_client, user):
        response = api_client.post(
            "/api/v1/auth/signup/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_signup_invalid_phone(self, api_client):
        response = api_client.post(
            "/api/v1/auth/signup/",
            {"phone": "12345", "password": "SecurePass123!"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_signup_weak_password(self, api_client):
        response = api_client.post(
            "/api/v1/auth/signup/",
            {"phone": "+919876543210", "password": "123"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestLogin:
    def test_login_success(self, api_client, user):
        response = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert "access" in response.data
        assert "refresh" in response.data

    def test_login_wrong_password(self, api_client, user):
        response = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "WrongPass123!"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_login_unknown_phone(self, api_client):
        response = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919999999999", "password": "SecurePass123!"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestOTP:
    @override_settings(SMS_ENABLED=False, OTP_EXPOSE_DEV_CODE=False)
    def test_send_otp_unavailable_without_sms(self, api_client):
        response = api_client.post(
            "/api/v1/auth/otp/send/",
            {"phone": "+919876543210"},
        )
        assert response.status_code == status.HTTP_503_SERVICE_UNAVAILABLE
        assert response.data["code"] == "sms_not_configured"
        assert not PhoneOTP.objects.filter(phone_e164="+919876543210").exists()

    @override_settings(OTP_EXPOSE_DEV_CODE=True)
    def test_send_otp(self, api_client):
        response = api_client.post(
            "/api/v1/auth/otp/send/",
            {"phone": "+919876543210"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert PhoneOTP.objects.filter(phone_e164="+919876543210", is_used=False).exists()

    @override_settings(OTP_EXPOSE_DEV_CODE=True)
    def test_send_otp_returns_dev_code(self, api_client):
        response = api_client.post(
            "/api/v1/auth/otp/send/",
            {"phone": "+919876543210"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert "dev_otp" in response.data
        assert len(response.data["dev_otp"]) == 6

    @override_settings(OTP_EXPOSE_DEV_CODE=True)
    def test_verify_otp_success(self, api_client):
        send_response = api_client.post(
            "/api/v1/auth/otp/send/",
            {"phone": "+919876543210"},
        )
        otp = send_response.data["dev_otp"]
        response = api_client.post(
            "/api/v1/auth/otp/verify/",
            {"phone": "+919876543210", "otp": otp},
        )
        assert response.status_code == status.HTTP_200_OK
        assert "access" in response.data
        assert "refresh" in response.data
        assert response.data["onboarding_required"] is True

    @override_settings(OTP_EXPOSE_DEV_CODE=True)
    def test_verify_otp_invalid(self, api_client):
        api_client.post(
            "/api/v1/auth/otp/send/",
            {"phone": "+919876543210"},
        )
        response = api_client.post(
            "/api/v1/auth/otp/verify/",
            {"phone": "+919876543210", "otp": "000000"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestPasswordReset:
    @override_settings(SMS_ENABLED=False, OTP_EXPOSE_DEV_CODE=False)
    def test_request_unavailable_without_sms(self, api_client, user):
        response = api_client.post(
            "/api/v1/auth/password/reset/",
            {"phone": "+919876543210"},
        )
        assert response.status_code == status.HTTP_503_SERVICE_UNAVAILABLE
        assert response.data["code"] == "sms_not_configured"

    @override_settings(OTP_EXPOSE_DEV_CODE=True)
    def test_request_returns_dev_code_for_known_phone(self, api_client, user):
        response = api_client.post(
            "/api/v1/auth/password/reset/",
            {"phone": "+919876543210"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data["dev_otp"]) == 6

    @override_settings(OTP_EXPOSE_DEV_CODE=True)
    def test_request_hides_unknown_phone(self, api_client, db):
        response = api_client.post(
            "/api/v1/auth/password/reset/",
            {"phone": "+919999999999"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert "dev_otp" not in response.data

    @override_settings(OTP_EXPOSE_DEV_CODE=True)
    def test_reset_throttle_sends_retry_after(self, api_client, user):
        api_client.post("/api/v1/auth/password/reset/", {"phone": "+919876543210"})
        response = api_client.post(
            "/api/v1/auth/password/reset/",
            {"phone": "+919876543210"},
        )
        assert response.status_code == status.HTTP_429_TOO_MANY_REQUESTS
        assert response.headers["Retry-After"]


@pytest.mark.django_db
class TestTokenRefresh:
    def test_refresh_token(self, api_client, user):
        refresh = RefreshToken.for_user(user)
        response = api_client.post(
            "/api/v1/auth/refresh/",
            {"refresh": str(refresh)},
        )
        assert response.status_code == status.HTTP_200_OK
        assert "access" in response.data

    def test_refresh_invalid_token(self, api_client):
        response = api_client.post(
            "/api/v1/auth/refresh/",
            {"refresh": "invalid-token"},
        )
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
class TestLogout:
    def test_logout_blacklists_token(self, api_client, user):
        refresh = RefreshToken.for_user(user)
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")
        response = api_client.post(
            "/api/v1/auth/logout/",
            {"refresh": str(refresh)},
        )
        assert response.status_code == status.HTTP_200_OK
        assert BlacklistedToken.objects.filter(token_jti=refresh["jti"]).exists()

    def test_logout_then_token_rejected(self, api_client, user):
        refresh = RefreshToken.for_user(user)
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")
        logout_response = api_client.post(
            "/api/v1/auth/logout/",
            {"refresh": str(refresh)},
        )
        assert logout_response.status_code == status.HTTP_200_OK
        response = api_client.get("/api/v1/me/")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
class TestPasswordChange:
    def test_change_password(self, api_client, user):
        api_client.credentials(
            HTTP_AUTHORIZATION=f"Bearer {RefreshToken.for_user(user).access_token}"
        )
        response = api_client.post(
            "/api/v1/auth/password/change/",
            {"old_password": "SecurePass123!", "new_password": "NewSecurePass456!"},
        )
        assert response.status_code == status.HTTP_200_OK
        user.refresh_from_db()
        assert user.check_password("NewSecurePass456!")

    def test_change_password_wrong_old(self, api_client, user):
        api_client.credentials(
            HTTP_AUTHORIZATION=f"Bearer {RefreshToken.for_user(user).access_token}"
        )
        response = api_client.post(
            "/api/v1/auth/password/change/",
            {"old_password": "WrongPass123!", "new_password": "NewSecurePass456!"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_change_password_revokes_existing_sessions(self, api_client, user):
        tokens = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        ).data
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens['access']}")
        response = api_client.post(
            "/api/v1/auth/password/change/",
            {"old_password": "SecurePass123!", "new_password": "NewSecurePass456!"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert SessionVersion.current_for(user) == 1

        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens['access']}")
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_401_UNAUTHORIZED
        api_client.credentials()
        assert (
            api_client.post("/api/v1/auth/refresh/", {"refresh": tokens["refresh"]}).status_code
            == status.HTTP_401_UNAUTHORIZED
        )

        new_login = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "NewSecurePass456!"},
        )
        assert new_login.status_code == status.HTTP_200_OK
        assert AccessToken(new_login.data["access"])["token_version"] == 1


@pytest.mark.django_db
class TestSessionRevocation:
    def test_revoke_all_invalidates_access_and_refresh_tokens(self, api_client, user):
        first = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        ).data
        second = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        ).data
        assert AccessToken(first["access"])["token_version"] == 0
        assert RefreshToken(first["refresh"])["token_version"] == 0

        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {first['access']}")
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_200_OK
        rejected = api_client.post(
            "/api/v1/auth/sessions/revoke-all/", {"password": "WrongPass123!"}
        )
        assert rejected.status_code == status.HTTP_400_BAD_REQUEST
        assert SessionVersion.current_for(user) == 0

        response = api_client.post(
            "/api/v1/auth/sessions/revoke-all/", {"password": "SecurePass123!"}
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["token_version"] == 1
        assert SessionVersion.current_for(user) == 1

        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {first['access']}")
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_401_UNAUTHORIZED
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {second['access']}")
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_401_UNAUTHORIZED
        api_client.credentials()
        for refresh in (first["refresh"], second["refresh"]):
            assert (
                api_client.post("/api/v1/auth/refresh/", {"refresh": refresh}).status_code
                == status.HTTP_401_UNAUTHORIZED
            )

        new_login = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        )
        assert new_login.status_code == status.HTTP_200_OK
        assert AccessToken(new_login.data["access"])["token_version"] == 1
        refreshed = api_client.post("/api/v1/auth/refresh/", {"refresh": new_login.data["refresh"]})
        assert refreshed.status_code == status.HTTP_200_OK
        assert AccessToken(refreshed.data["access"])["token_version"] == 1
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {new_login.data['access']}")
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_200_OK

    def test_legacy_version_zero_tokens_work_until_revocation(self, api_client, user):
        refresh = RefreshToken.for_user(user)
        assert "token_version" not in refresh
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_200_OK
        api_client.credentials()
        assert (
            api_client.post("/api/v1/auth/refresh/", {"refresh": str(refresh)}).status_code
            == status.HTTP_200_OK
        )

        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")
        assert (
            api_client.post(
                "/api/v1/auth/sessions/revoke-all/", {"password": "SecurePass123!"}
            ).status_code
            == status.HTTP_200_OK
        )
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_401_UNAUTHORIZED
        api_client.credentials()
        assert (
            api_client.post("/api/v1/auth/refresh/", {"refresh": str(refresh)}).status_code
            == status.HTTP_401_UNAUTHORIZED
        )

    @override_settings(SMS_ENABLED=False, OTP_EXPOSE_DEV_CODE=True)
    def test_revoke_all_accepts_otp_reverification(self, api_client, user):
        tokens = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        ).data
        otp = api_client.post("/api/v1/auth/otp/send/", {"phone": "+919876543210"}).data["dev_otp"]
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens['access']}")
        response = api_client.post("/api/v1/auth/sessions/revoke-all/", {"otp": otp})
        assert response.status_code == status.HTTP_200_OK
        assert SessionVersion.current_for(user) == 1
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_401_UNAUTHORIZED

    @override_settings(SMS_ENABLED=False, OTP_EXPOSE_DEV_CODE=False)
    def test_revoke_all_rejects_otp_when_unavailable(self, api_client, user):
        tokens = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        ).data
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens['access']}")
        response = api_client.post("/api/v1/auth/sessions/revoke-all/", {"otp": "123456"})
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert SessionVersion.current_for(user) == 0

    def test_revoke_all_requires_authentication(self, api_client):
        response = api_client.post(
            "/api/v1/auth/sessions/revoke-all/", {"password": "SecurePass123!"}
        )
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
class TestPasswordResetRevocation:
    @override_settings(SMS_ENABLED=False, OTP_EXPOSE_DEV_CODE=True)
    def test_password_reset_revokes_existing_sessions(self, api_client, user):
        tokens = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "SecurePass123!"},
        ).data
        otp = api_client.post("/api/v1/auth/password/reset/", {"phone": "+919876543210"}).data[
            "dev_otp"
        ]
        response = api_client.post(
            "/api/v1/auth/password/reset/confirm/",
            {
                "phone": "+919876543210",
                "otp": otp,
                "new_password": "ResetSecurePass789!",
            },
        )
        assert response.status_code == status.HTTP_200_OK
        assert SessionVersion.current_for(user) == 1

        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens['access']}")
        assert api_client.get("/api/v1/me/").status_code == status.HTTP_401_UNAUTHORIZED
        api_client.credentials()
        assert (
            api_client.post("/api/v1/auth/refresh/", {"refresh": tokens["refresh"]}).status_code
            == status.HTTP_401_UNAUTHORIZED
        )
        new_login = api_client.post(
            "/api/v1/auth/login/",
            {"phone": "+919876543210", "password": "ResetSecurePass789!"},
        )
        assert new_login.status_code == status.HTTP_200_OK
        assert AccessToken(new_login.data["access"])["token_version"] == 1
