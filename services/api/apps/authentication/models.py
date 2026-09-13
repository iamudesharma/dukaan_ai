import hashlib

from django.conf import settings
from django.db import models


class PhoneOTP(models.Model):
    phone_e164 = models.CharField(max_length=20, db_index=True)
    otp_hash = models.CharField(max_length=128)
    expires_at = models.DateTimeField()
    attempts = models.PositiveIntegerField(default=0)
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [models.Index(fields=["phone_e164", "created_at"])]

    def __str__(self) -> str:
        return f"OTP for {self.phone_e164}"

    @staticmethod
    def hash_otp(otp: str) -> str:
        return hashlib.sha256(otp.encode()).hexdigest()

    def verify(self, otp: str) -> bool:
        return not self.is_used and self.otp_hash == self.hash_otp(otp)


class BlacklistedToken(models.Model):
    token_jti = models.CharField(max_length=64, unique=True, db_index=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="blacklisted_tokens"
    )
    expires_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"Blacklisted token {self.token_jti}"


class SessionRevocation(models.Model):
    """Forces every session of a user to re-authenticate.

    JWTs are stateless, so individual refresh tokens cannot be enumerated.
    Instead this records the moment before which no token is honored: any
    access or refresh token with ``iat`` at or before ``revoked_at`` is
    rejected. Set by "sign out everywhere" and by membership revocation."""

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="session_revocation"
    )
    revoked_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f"Session revocation for {self.user_id}"


class DeviceToken(models.Model):
    """Push-notification device registration for one user.

    Identity-scoped like the other authentication tables (no business_id,
    no tenant rows), so no RLS policy applies. Tokens are never listed
    across users: every query filters to the caller.
    """

    class Platform(models.TextChoices):
        ANDROID = "ANDROID", "Android"
        IOS = "IOS", "iOS"
        WEB = "WEB", "Web"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="device_tokens"
    )
    token = models.CharField(max_length=255, unique=True, db_index=True)
    platform = models.CharField(max_length=10, choices=Platform.choices, default=Platform.ANDROID)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [models.Index(fields=["user", "is_active"])]

    def __str__(self) -> str:
        return f"Device token for {self.user_id} ({self.platform})"
