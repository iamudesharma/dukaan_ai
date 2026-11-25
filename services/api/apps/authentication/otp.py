import secrets
from datetime import timedelta

from django.conf import settings
from django.utils import timezone

from .models import PhoneOTP
from .sms import get_sms_provider


class OTPService:
    CODE_LENGTH = 6
    EXPIRY_MINUTES = 5
    MAX_ATTEMPTS = 5
    RESEND_SECONDS = 60

    def generate(self) -> str:
        lower = 10 ** (self.CODE_LENGTH - 1)
        return str(lower + secrets.randbelow(10**self.CODE_LENGTH - lower))

    def create(self, phone: str) -> tuple[str, PhoneOTP]:
        last = (
            PhoneOTP.objects.filter(phone_e164=phone, is_used=False).order_by("-created_at").first()
        )
        if last and timezone.now() - last.created_at < timedelta(seconds=self.RESEND_SECONDS):
            wait = self.RESEND_SECONDS - int((timezone.now() - last.created_at).total_seconds())
            raise TooManyRequests(f"Wait {wait}s before requesting a new code.", wait)

        otp = self.generate()
        record = PhoneOTP.objects.create(
            phone_e164=phone,
            otp_hash=PhoneOTP.hash_otp(otp),
            expires_at=timezone.now() + timedelta(minutes=self.EXPIRY_MINUTES),
        )
        return otp, record

    def verify(self, phone: str, otp: str) -> bool:
        record = (
            PhoneOTP.objects.filter(phone_e164=phone, is_used=False, expires_at__gt=timezone.now())
            .order_by("-created_at")
            .first()
        )
        if not record:
            return False

        record.attempts += 1
        if record.attempts >= self.MAX_ATTEMPTS:
            record.is_used = True
            record.save(update_fields=["attempts", "is_used"])
            return False

        if record.verify(otp):
            record.is_used = True
            record.save(update_fields=["attempts", "is_used"])
            return True

        record.save(update_fields=["attempts"])
        return False

    def send(self, phone: str, otp: str) -> bool:
        """Deliver a Django-created code through the configured SMS provider."""
        if settings.OTP_EXPOSE_DEV_CODE and not settings.SMS_ENABLED:
            return True
        if not settings.SMS_ENABLED:
            return False
        get_sms_provider().send_otp(phone, otp)
        return True


class TooManyRequests(Exception):
    def __init__(self, message: str, retry_after: int):
        super().__init__(message)
        self.retry_after = retry_after
