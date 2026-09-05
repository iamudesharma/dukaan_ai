from __future__ import annotations

import uuid

import jwt
from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import connection, transaction
from rest_framework import authentication, exceptions

User = get_user_model()


class SupabaseJWTAuthentication(authentication.BaseAuthentication):
    keyword = "Bearer"

    def authenticate(self, request):
        from apps.tenancy import rls

        dev_user_id = request.headers.get("X-Dev-User-ID")
        if settings.DEV_AUTH_ENABLED and dev_user_id:
            try:
                user = User.objects.get(pk=dev_user_id, is_active=True)
            except (User.DoesNotExist, ValueError):
                raise exceptions.AuthenticationFailed("Unknown development user") from None
            # The development header names the user directly; scope still
            # comes from the membership table, never from the client.
            rls.establish_scope(connection, user)
            return user, None

        header = authentication.get_authorization_header(request).decode("utf-8")
        if not header:
            return None
        parts = header.split()
        if len(parts) != 2 or parts[0].lower() != self.keyword.lower():
            raise exceptions.AuthenticationFailed("Invalid authorization header")

        claims = self._decode(parts[1])
        subject = claims.get("sub")
        if not subject:
            raise exceptions.AuthenticationFailed("Token has no subject")
        try:
            subject_uuid = uuid.UUID(subject)
        except (TypeError, ValueError):
            raise exceptions.AuthenticationFailed("Invalid token subject") from None

        with transaction.atomic():
            user, _ = User.objects.get_or_create(
                supabase_user_id=subject_uuid,
                defaults={
                    "username": f"sb_{subject_uuid.hex}",
                    "phone_e164": claims.get("phone", ""),
                    "display_name": claims.get("user_metadata", {}).get("name", ""),
                },
            )
        if not user.is_active:
            raise exceptions.AuthenticationFailed("User is disabled")
        # DRF authentication runs inside the view, after Django middleware,
        # so the request scope is established here from the verified token.
        # Subject first (self-bootstrap read), then the membership-derived
        # business list; nothing is trusted from client payloads.
        rls.establish_scope(connection, user, subject=subject_uuid)
        return user, claims

    @staticmethod
    def _decode(token: str) -> dict:
        options = {"require": ["exp", "sub"]}
        kwargs = {
            "audience": settings.SUPABASE_JWT_AUDIENCE,
            "issuer": settings.SUPABASE_JWT_ISSUER or None,
            "options": options,
        }
        try:
            if settings.SUPABASE_JWT_SECRET:
                return jwt.decode(
                    token, settings.SUPABASE_JWT_SECRET, algorithms=["HS256"], **kwargs
                )
            if settings.SUPABASE_JWKS_URL:
                key = jwt.PyJWKClient(settings.SUPABASE_JWKS_URL).get_signing_key_from_jwt(token)
                return jwt.decode(token, key.key, algorithms=["ES256", "RS256"], **kwargs)
        except jwt.PyJWTError as exc:
            raise exceptions.AuthenticationFailed("Invalid or expired token") from exc
        raise exceptions.AuthenticationFailed("Supabase JWT verification is not configured")
