from django.urls import path

from .views import (
    DeviceTokenDetailView,
    DeviceTokenView,
    LoginView,
    LogoutAllView,
    LogoutView,
    OtpSendView,
    OtpVerifyView,
    PasswordChangeView,
    PasswordResetConfirmView,
    PasswordResetRequestView,
    RefreshView,
    SignupView,
)

urlpatterns = [
    path("auth/signup/", SignupView.as_view(), name="auth-signup"),
    path("auth/login/", LoginView.as_view(), name="auth-login"),
    path("auth/otp/send/", OtpSendView.as_view(), name="auth-otp-send"),
    path("auth/otp/verify/", OtpVerifyView.as_view(), name="auth-otp-verify"),
    path("auth/refresh/", RefreshView.as_view(), name="auth-refresh"),
    path("auth/logout/", LogoutView.as_view(), name="auth-logout"),
    path("auth/logout-all/", LogoutAllView.as_view(), name="auth-logout-all"),
    path("auth/password/change/", PasswordChangeView.as_view(), name="auth-password-change"),
    path("auth/password/reset/", PasswordResetRequestView.as_view(), name="auth-password-reset"),
    path(
        "auth/password/reset/confirm/",
        PasswordResetConfirmView.as_view(),
        name="auth-password-reset-confirm",
    ),
    path("devices/", DeviceTokenView.as_view(), name="devices"),
    path("devices/<int:pk>/", DeviceTokenDetailView.as_view(), name="device-detail"),
]
