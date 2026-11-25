from datetime import UTC, datetime, timedelta

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import IntegrityError, connection, transaction
from django.utils import timezone
from drf_spectacular.utils import extend_schema
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken

from apps.tenancy.rls import establish_scope

from .models import BlacklistedToken, SessionVersion
from .otp import OTPService, TooManyRequests
from .serializers import (
    AuthCapabilitiesSerializer,
    AuthTokenResponseSerializer,
    LoginSerializer,
    LogoutRequestSerializer,
    MessageResponseSerializer,
    OtpResponseSerializer,
    OtpSendSerializer,
    OtpVerifySerializer,
    PasswordChangeSerializer,
    PasswordResetConfirmSerializer,
    PasswordResetRequestSerializer,
    RefreshRequestSerializer,
    RefreshResponseSerializer,
    SessionRevokeAllRequestSerializer,
    SessionRevokeAllResponseSerializer,
    SignupSerializer,
)
from .sms import SmsDeliveryError

User = get_user_model()


def _tokens_for(user: User) -> dict:
    refresh = RefreshToken.for_user(user)
    refresh["token_version"] = SessionVersion.current_for(user)
    return {
        "access": str(refresh.access_token),
        "refresh": str(refresh),
    }


def _onboarding_required(user: User) -> bool:
    """True until the user owns or joins at least one active business."""
    return not user.memberships.filter(is_active=True, business__is_active=True).exists()


def _otp_delivery_unavailable() -> bool:
    """Codes cannot be delivered and are not being handed back to the caller."""
    return not settings.SMS_ENABLED and not settings.OTP_EXPOSE_DEV_CODE


def _otp_response(otp: str, phone: str, payload: dict) -> dict:
    response = {"detail": "Verification code sent.", "phone": phone, **payload}
    if settings.OTP_EXPOSE_DEV_CODE and not settings.SMS_ENABLED:
        response["dev_otp"] = otp
    return response


def _delivery_failure() -> Response:
    return Response(
        {
            "detail": "The verification code could not be sent. Please try again.",
            "code": "sms_delivery_failed",
        },
        status=status.HTTP_502_BAD_GATEWAY,
    )


def _send_code(service: OTPService, phone: str, otp: str, record) -> Response | None:
    try:
        sent = service.send(phone, otp)
    except SmsDeliveryError:
        record.delete()
        return _delivery_failure()
    if not sent:
        record.delete()
        return _delivery_failure()
    return None


class AuthCapabilitiesView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Get available authentication methods",
        responses=AuthCapabilitiesSerializer,
        auth=[],
    )
    def get(self, request):
        return Response(
            {
                "password": True,
                "otp": bool(settings.SMS_ENABLED),
                "dev_otp": bool(settings.OTP_EXPOSE_DEV_CODE and not settings.SMS_ENABLED),
            }
        )


class SignupView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Create an account and issue tokens",
        request=SignupSerializer,
        responses={201: AuthTokenResponseSerializer},
        auth=[],
    )
    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            user = serializer.save()
        except IntegrityError:
            return Response(
                {"detail": "An account with this phone number already exists."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        return Response(
            {
                "user": {
                    "id": str(user.id),
                    "phone": user.phone_e164,
                    "display_name": user.display_name,
                },
                "onboarding_required": True,
                **_tokens_for(user),
            },
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Sign in with phone and password",
        request=LoginSerializer,
        responses=AuthTokenResponseSerializer,
        auth=[],
    )
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        # The password is verified above, so the membership lookup below may run
        # under this user's own RLS scope. Without it the row-level policies
        # hide the memberships and every owner would look like a new signup.
        establish_scope(connection, user)
        return Response(
            {
                "user": {
                    "id": str(user.id),
                    "phone": user.phone_e164,
                    "display_name": user.display_name,
                },
                "onboarding_required": _onboarding_required(user),
                **_tokens_for(user),
            }
        )


class OtpSendView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Send a login verification code",
        request=OtpSendSerializer,
        responses=OtpResponseSerializer,
        auth=[],
    )
    def post(self, request):
        serializer = OtpSendSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]

        if _otp_delivery_unavailable():
            return Response(
                {
                    "detail": "Verification codes are not available yet.",
                    "code": "sms_not_configured",
                },
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        service = OTPService()
        try:
            otp, record = service.create(phone)
        except TooManyRequests as exc:
            return Response(
                {"detail": str(exc), "retry_after": exc.retry_after},
                status=status.HTTP_429_TOO_MANY_REQUESTS,
                headers={"Retry-After": str(exc.retry_after)},
            )

        if failure := _send_code(service, phone, otp, record):
            return failure
        return Response(_otp_response(otp, phone, {}))


class OtpVerifyView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Verify an OTP and issue tokens",
        request=OtpVerifySerializer,
        responses=AuthTokenResponseSerializer,
        auth=[],
    )
    def post(self, request):
        serializer = OtpVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]
        otp = serializer.validated_data["otp"]

        service = OTPService()
        if not service.verify(phone, otp):
            return Response(
                {"detail": "Invalid or expired code."}, status=status.HTTP_400_BAD_REQUEST
            )

        user, _ = User.objects.get_or_create(
            phone_e164=phone,
            defaults={"username": f"phone_{phone}", "display_name": ""},
        )
        if not user.is_active:
            return Response(
                {"detail": "This account has been disabled."}, status=status.HTTP_403_FORBIDDEN
            )

        establish_scope(connection, user)
        return Response(
            {
                "user": {
                    "id": str(user.id),
                    "phone": user.phone_e164,
                    "display_name": user.display_name,
                },
                "onboarding_required": _onboarding_required(user),
                **_tokens_for(user),
            }
        )


class RefreshView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Refresh an access token",
        request=RefreshRequestSerializer,
        responses=RefreshResponseSerializer,
        auth=[],
    )
    def post(self, request):
        refresh_token = request.data.get("refresh")
        if not refresh_token:
            return Response(
                {"detail": "Refresh token is required."}, status=status.HTTP_400_BAD_REQUEST
            )
        try:
            token = RefreshToken(refresh_token)
            if token.get("token_type") != "refresh":
                raise TokenError("Invalid token type.")
            jti = token["jti"]
            if BlacklistedToken.objects.filter(token_jti=jti).exists():
                return Response(
                    {"detail": "Token has been revoked."}, status=status.HTTP_401_UNAUTHORIZED
                )
            user = User.objects.get(pk=token["user_id"], is_active=True)
            if not SessionVersion.matches(user, token):
                return Response(
                    {"detail": "Token has been revoked."}, status=status.HTTP_401_UNAUTHORIZED
                )
            return Response({"access": str(token.access_token)})
        except (TokenError, User.DoesNotExist, KeyError, TypeError, ValueError):
            return Response(
                {"detail": "Invalid or expired token."}, status=status.HTTP_401_UNAUTHORIZED
            )


class SessionRevokeAllView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        summary="Revoke every session for the current user",
        description="Requires the current password or a valid verification code.",
        request=SessionRevokeAllRequestSerializer,
        responses=SessionRevokeAllResponseSerializer,
    )
    def post(self, request):
        password = request.data.get("password") or request.data.get("current_password")
        otp = request.data.get("otp")
        password_verified = (
            isinstance(password, str) and bool(password) and request.user.check_password(password)
        )
        otp_verified = False
        if (
            not password_verified
            and isinstance(otp, str)
            and bool(otp)
            and request.user.phone_e164
            and not _otp_delivery_unavailable()
        ):
            otp_verified = OTPService().verify(request.user.phone_e164, otp)

        if not (password_verified or otp_verified):
            return Response(
                {"detail": "Current password or a valid verification code is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        version = SessionVersion.revoke_for(request.user)
        return Response({"detail": "All sessions have been revoked.", "token_version": version})


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        summary="Revoke the current access token and optional refresh token",
        request=LogoutRequestSerializer,
        responses=MessageResponseSerializer,
    )
    def post(self, request):
        refresh_token = request.data.get("refresh")
        if refresh_token:
            try:
                token = RefreshToken(refresh_token)
                exp_timestamp = token["exp"]
                if isinstance(exp_timestamp, int | float):
                    exp_datetime = datetime.fromtimestamp(exp_timestamp, tz=UTC)
                else:
                    exp_datetime = exp_timestamp
                BlacklistedToken.objects.create(
                    token_jti=token["jti"],
                    user=request.user,
                    expires_at=exp_datetime,
                )
            except Exception:
                pass
        access_jti = getattr(request.auth, "get", lambda k: None)("jti")
        if access_jti:
            BlacklistedToken.objects.get_or_create(
                token_jti=access_jti,
                defaults={
                    "user": request.user,
                    "expires_at": timezone.now() + timedelta(minutes=30),
                },
            )
        return Response({"detail": "Signed out."})


class PasswordChangeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        summary="Change the current user's password",
        request=PasswordChangeSerializer,
        responses=MessageResponseSerializer,
    )
    def post(self, request):
        serializer = PasswordChangeSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        with transaction.atomic():
            request.user.set_password(serializer.validated_data["new_password"])
            request.user.save(update_fields=["password"])
            SessionVersion.revoke_for(request.user)
        return Response({"detail": "Password updated."})


class PasswordResetRequestView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Request a password-reset verification code",
        description="Always returns the same message shape to avoid revealing account existence.",
        request=PasswordResetRequestSerializer,
        responses=OtpResponseSerializer,
        auth=[],
    )
    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]

        if _otp_delivery_unavailable():
            return Response(
                {
                    "detail": "Verification codes are not available yet.",
                    "code": "sms_not_configured",
                },
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        if User.objects.filter(phone_e164=phone, is_active=True).exists():
            service = OTPService()
            try:
                otp, record = service.create(phone)
            except TooManyRequests as exc:
                return Response(
                    {"detail": str(exc), "retry_after": exc.retry_after},
                    status=status.HTTP_429_TOO_MANY_REQUESTS,
                    headers={"Retry-After": str(exc.retry_after)},
                )
            if failure := _send_code(service, phone, otp, record):
                return failure
            return Response(_otp_response(otp, phone, {}))

        return Response(
            {"detail": "If this phone is registered, a code will be sent.", "phone": phone}
        )


class PasswordResetConfirmView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Reset a password with a verification code",
        request=PasswordResetConfirmSerializer,
        responses=MessageResponseSerializer,
        auth=[],
    )
    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]
        otp = serializer.validated_data["otp"]

        service = OTPService()
        if not service.verify(phone, otp):
            return Response(
                {"detail": "Invalid or expired code."}, status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = User.objects.get(phone_e164=phone, is_active=True)
        except User.DoesNotExist:
            return Response(
                {"detail": "Invalid or expired code."}, status=status.HTTP_400_BAD_REQUEST
            )

        with transaction.atomic():
            user.set_password(serializer.validated_data["new_password"])
            user.save(update_fields=["password"])
            SessionVersion.revoke_for(user)
        return Response({"detail": "Password has been reset."})
