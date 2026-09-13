from __future__ import annotations

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import connection
from rest_framework import exceptions
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import TokenError

from apps.authentication.models import BlacklistedToken, SessionRevocation

User = get_user_model()


def _token_issued_at(validated_token):
    """Unix timestamp a token was issued at, or None when absent."""
    issued_at = validated_token.get("iat")
    if isinstance(issued_at, int | float):
        return float(issued_at)
    return None


def is_session_revoked(user, validated_token) -> bool:
    """True when the user revoked all sessions after this token was issued.

    Fail closed: a token without an ``iat`` claim is rejected whenever any
    revocation record exists for the user."""
    revocation = (
        SessionRevocation.objects.filter(user=user).values_list("revoked_at", flat=True).first()
    )
    if revocation is None:
        return False
    issued_at = _token_issued_at(validated_token)
    if issued_at is None:
        return True
    return issued_at <= revocation.timestamp()


class CustomJWTAuthentication(JWTAuthentication):
    def authenticate(self, request):
        dev_user_id = request.headers.get("X-Dev-User-ID")
        if settings.DEV_AUTH_ENABLED and dev_user_id:
            return self._authenticate_dev_user(dev_user_id)

        header = self.get_header(request)
        if header is None:
            return None

        raw_token = self.get_raw_token(header)
        if raw_token is None:
            return None

        try:
            validated_token = self.get_validated_token(raw_token)
        except TokenError as exc:
            raise exceptions.AuthenticationFailed(str(exc)) from exc

        jti = validated_token.get("jti")
        if jti and BlacklistedToken.objects.filter(token_jti=jti).exists():
            raise exceptions.AuthenticationFailed("Token has been revoked")

        user = self.get_user(validated_token)
        if not user.is_active:
            raise exceptions.AuthenticationFailed("User is disabled")
        if is_session_revoked(user, validated_token):
            raise exceptions.AuthenticationFailed("Session has been revoked")

        from apps.tenancy import rls

        rls.establish_scope(connection, user)
        return user, validated_token

    def _authenticate_dev_user(self, dev_user_id):
        from apps.tenancy import rls

        try:
            user = User.objects.get(pk=dev_user_id, is_active=True)
        except (User.DoesNotExist, ValueError):
            raise exceptions.AuthenticationFailed("Unknown development user") from None
        rls.establish_scope(connection, user)
        return user, None
