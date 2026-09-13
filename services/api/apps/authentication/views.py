from datetime import UTC, datetime, timedelta

from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import BlacklistedToken, SessionRevocation
from .otp import OTPService, TooManyRequests
from .serializers import (
    LoginSerializer,
    OtpSendSerializer,
    OtpVerifySerializer,
    PasswordChangeSerializer,
    PasswordResetConfirmSerializer,
    PasswordResetRequestSerializer,
    SignupSerializer,
)

User = get_user_model()


def _tokens_for(user: User) -> dict:
    refresh = RefreshToken.for_user(user)
    return {
        "access": str(refresh.access_token),
        "refresh": str(refresh),
    }


class SignupView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(
            {
                "user": {
                    "id": str(user.id),
                    "phone": user.phone_e164,
                    "display_name": user.display_name,
                },
                **_tokens_for(user),
            },
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        return Response(
            {"user": {"id": str(user.id), "phone": user.phone_e164}, **_tokens_for(user)}
        )


class OtpSendView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    def post(self, request):
        serializer = OtpSendSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]

        service = OTPService()
        try:
            otp, _ = service.create(phone)
        except TooManyRequests as exc:
            return Response(
                {"detail": str(exc), "retry_after": exc.retry_after},
                status=status.HTTP_429_TOO_MANY_REQUESTS,
                headers={"Retry-After": str(exc.retry_after)},
            )
        service.send(phone, otp)

        response = {"detail": "Verification code sent.", "phone": phone}
        if True:
            response["dev_otp"] = otp
        return Response(response)


class OtpVerifyView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

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

        return Response(
            {"user": {"id": str(user.id), "phone": user.phone_e164}, **_tokens_for(user)}
        )


class RefreshView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    def post(self, request):
        refresh_token = request.data.get("refresh")
        if not refresh_token:
            return Response(
                {"detail": "Refresh token is required."}, status=status.HTTP_400_BAD_REQUEST
            )
        try:
            token = RefreshToken(refresh_token)
            jti = token["jti"]
            if BlacklistedToken.objects.filter(token_jti=jti).exists():
                return Response(
                    {"detail": "Token has been revoked."}, status=status.HTTP_401_UNAUTHORIZED
                )
            from apps.common.authentication import is_session_revoked

            try:
                token_user = User.objects.get(pk=token["user_id"])
            except (User.DoesNotExist, KeyError):
                token_user = None
            if token_user is None or is_session_revoked(token_user, token):
                return Response(
                    {"detail": "Session has been revoked."}, status=status.HTTP_401_UNAUTHORIZED
                )
            return Response({"access": str(token.access_token)})
        except Exception:
            return Response(
                {"detail": "Invalid or expired token."}, status=status.HTTP_401_UNAUTHORIZED
            )


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

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


class LogoutAllView(APIView):
    """Revoke every session for the caller on all devices.

    Records a revocation timestamp; access and refresh tokens issued at or
    before it are rejected everywhere (see SessionRevocation). The presented
    tokens are additionally blacklisted so they fail fast with a clear code."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        now = timezone.now()
        SessionRevocation.objects.update_or_create(user=request.user, defaults={"revoked_at": now})
        refresh_token = request.data.get("refresh")
        if refresh_token:
            try:
                token = RefreshToken(refresh_token)
                exp_timestamp = token["exp"]
                if isinstance(exp_timestamp, int | float):
                    exp_datetime = datetime.fromtimestamp(exp_timestamp, tz=UTC)
                else:
                    exp_datetime = exp_timestamp
                BlacklistedToken.objects.get_or_create(
                    token_jti=token["jti"],
                    defaults={"user": request.user, "expires_at": exp_datetime},
                )
            except Exception:
                pass
        access_jti = getattr(request.auth, "get", lambda k: None)("jti")
        if access_jti:
            BlacklistedToken.objects.get_or_create(
                token_jti=access_jti,
                defaults={"user": request.user, "expires_at": now + timedelta(minutes=30)},
            )
        return Response({"detail": "Signed out everywhere."})


class PasswordChangeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PasswordChangeSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        request.user.set_password(serializer.validated_data["new_password"])
        request.user.save(update_fields=["password"])
        return Response({"detail": "Password updated."})


class PasswordResetRequestView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]

        if User.objects.filter(phone_e164=phone, is_active=True).exists():
            service = OTPService()
            try:
                otp, _ = service.create(phone)
            except TooManyRequests as exc:
                return Response(
                    {"detail": str(exc), "retry_after": exc.retry_after},
                    status=status.HTTP_429_TOO_MANY_REQUESTS,
                )
            service.send(phone, otp)
            response = {"detail": "Verification code sent.", "phone": phone}
            if True:
                response["dev_otp"] = otp
            return Response(response)

        return Response(
            {"detail": "If this phone is registered, a code will be sent.", "phone": phone}
        )


class PasswordResetConfirmView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

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

        user.set_password(serializer.validated_data["new_password"])
        user.save(update_fields=["password"])
        return Response({"detail": "Password has been reset."})
