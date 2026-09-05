from unittest.mock import patch

import pytest
from django.contrib.auth import get_user_model
from django.utils import timezone
from datetime import timedelta
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.authentication.models import BlacklistedToken, PhoneOTP

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
    def test_send_otp(self, api_client):
        response = api_client.post(
            "/api/v1/auth/otp/send/",
            {"phone": "+919876543210"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert PhoneOTP.objects.filter(phone_e164="+919876543210", is_used=False).exists()

    def test_send_otp_returns_dev_code(self, api_client):
        response = api_client.post(
            "/api/v1/auth/otp/send/",
            {"phone": "+919876543210"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert "dev_otp" in response.data
        assert len(response.data["dev_otp"]) == 6

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
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {RefreshToken.for_user(user).access_token}")
        response = api_client.post(
            "/api/v1/auth/password/change/",
            {"old_password": "SecurePass123!", "new_password": "NewSecurePass456!"},
        )
        assert response.status_code == status.HTTP_200_OK
        user.refresh_from_db()
        assert user.check_password("NewSecurePass456!")

    def test_change_password_wrong_old(self, api_client, user):
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {RefreshToken.for_user(user).access_token}")
        response = api_client.post(
            "/api/v1/auth/password/change/",
            {"old_password": "WrongPass123!", "new_password": "NewSecurePass456!"},
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
