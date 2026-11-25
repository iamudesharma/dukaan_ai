"""Endpoint-scoped DRF throttles backed by Django's configured cache.

The classes are installed globally so new assistant/upload actions inherit a
limit without each feature app having to repeat throttle configuration. A
request can consume more than one bucket (for example an upload is both an
``uploads`` and a general ``write``), which keeps expensive paths tighter than
ordinary CRUD.
"""

from django.core.exceptions import ImproperlyConfigured
from rest_framework.settings import api_settings
from rest_framework.throttling import UserRateThrottle

SAFE_METHODS = {"GET", "HEAD", "OPTIONS"}
UPLOAD_URL_NAMES = {
    "assistant-attachment-presign",
    "assistant-attachment-upload",
}
UPLOAD_PATH_SUFFIXES = (
    "/attachments/presign/",
    "/attachments/upload/",
)


def _path(request) -> str:
    return request.path.rstrip("/") + "/"


def _url_name(request) -> str:
    match = getattr(request, "resolver_match", None)
    return getattr(match, "url_name", "") or ""


class EndpointScopedRateThrottle(UserRateThrottle):
    """A scoped throttle that participates only on its endpoint family."""

    scope = ""

    def get_rate(self):
        # Read through api_settings so override_settings (and runtime config
        # reloads) takes effect instead of DRF's import-time class snapshot.
        try:
            return api_settings.DEFAULT_THROTTLE_RATES[self.scope]
        except KeyError as exc:
            raise ImproperlyConfigured(
                f"No default throttle rate set for {self.scope!r} scope"
            ) from exc

    def applies_to(self, request, view) -> bool:
        raise NotImplementedError

    def allow_request(self, request, view):
        if not self.applies_to(request, view):
            return True
        return super().allow_request(request, view)


class AuthRateThrottle(EndpointScopedRateThrottle):
    scope = "auth"

    def applies_to(self, request, view) -> bool:
        return request.method not in SAFE_METHODS and _path(request).startswith("/api/v1/auth/")


class AssistantRateThrottle(EndpointScopedRateThrottle):
    scope = "assistant"

    def applies_to(self, request, view) -> bool:
        return _path(request).startswith("/api/v1/assistant/") or _url_name(request).startswith(
            "assistant-"
        )


class UploadRateThrottle(EndpointScopedRateThrottle):
    scope = "uploads"

    def applies_to(self, request, view) -> bool:
        return request.method not in SAFE_METHODS and (
            _url_name(request) in UPLOAD_URL_NAMES or _path(request).endswith(UPLOAD_PATH_SUFFIXES)
        )


class WriteRateThrottle(EndpointScopedRateThrottle):
    scope = "write"

    def applies_to(self, request, view) -> bool:
        return request.method not in SAFE_METHODS and _path(request).startswith("/api/")


class ReadRateThrottle(EndpointScopedRateThrottle):
    scope = "read"

    def applies_to(self, request, view) -> bool:
        return request.method in SAFE_METHODS and _path(request).startswith("/api/")
