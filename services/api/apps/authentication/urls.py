from django.urls import path

from .views import (
    AuthCapabilitiesView,
    LoginView,
    LogoutView,
    OtpSendView,
    OtpVerifyView,
    PasswordChangeView,
    PasswordResetConfirmView,
    PasswordResetRequestView,
    RefreshView,
    SessionRevokeAllView,
    SignupView,
)

urlpatterns = [
    path("auth/capabilities/", AuthCapabilitiesView.as_view(), name="auth-capabilities"),
    path("auth/signup/", SignupView.as_view(), name="auth-signup"),
    path("auth/login/", LoginView.as_view(), name="auth-login"),
    path("auth/otp/send/", OtpSendView.as_view(), name="auth-otp-send"),
    path("auth/otp/verify/", OtpVerifyView.as_view(), name="auth-otp-verify"),
    path("auth/refresh/", RefreshView.as_view(), name="auth-refresh"),
    path("auth/logout/", LogoutView.as_view(), name="auth-logout"),
    path(
        "auth/sessions/revoke-all/",
        SessionRevokeAllView.as_view(),
        name="auth-sessions-revoke-all",
    ),
    path("auth/password/change/", PasswordChangeView.as_view(), name="auth-password-change"),
    path("auth/password/reset/", PasswordResetRequestView.as_view(), name="auth-password-reset"),
    path(
        "auth/password/reset/confirm/",
        PasswordResetConfirmView.as_view(),
        name="auth-password-reset-confirm",
    ),
]
