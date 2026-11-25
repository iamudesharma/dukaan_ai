import hashlib
import hmac

from django.conf import settings
from django.db import models, transaction
from django.db.models import F
from django.utils import timezone


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
        return f"{self.phone_e164} ({'used' if self.is_used else 'pending'})"

    @staticmethod
    def hash_otp(otp: str) -> str:
        return hashlib.sha256(otp.encode()).hexdigest()

    def verify(self, otp: str) -> bool:
        return not self.is_used and hmac.compare_digest(self.otp_hash, self.hash_otp(otp))


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
        return f"revoked {self.token_jti}"


class SessionVersion(models.Model):
    """Global token version used to revoke every session for one user.

    Tokens issued before this table existed have no ``token_version`` claim and
    are treated as version 0. The first revocation creates the row at version 1,
    invalidating both those legacy tokens and tokens explicitly issued at 0.
    """

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="session_version"
    )
    version = models.PositiveIntegerField(default=0)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f"{self.user_id} session version {self.version}"

    @classmethod
    def current_for(cls, user) -> int:
        return cls.objects.filter(user=user).values_list("version", flat=True).first() or 0

    @classmethod
    def matches(cls, user, token) -> bool:
        return cls.current_for(user) == token.get("token_version", 0)

    @classmethod
    def revoke_for(cls, user) -> int:
        with transaction.atomic():
            record, _ = cls.objects.select_for_update().get_or_create(user=user)
            cls.objects.filter(pk=record.pk).update(
                version=F("version") + 1, updated_at=timezone.now()
            )
            record.refresh_from_db(fields=["version", "updated_at"])
            return record.version
