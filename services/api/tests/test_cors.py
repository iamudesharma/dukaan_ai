"""CORS must allow every header the web client sends.

A browser blocks a request whose headers are missing from
``Access-Control-Allow-Headers``, and the failure is invisible to the API: the
preflight still answers 200 and the server log shows only an OPTIONS request.
This happened for real — ``X-Client`` and ``Idempotency-Key`` were absent from
django-cors-headers' defaults, so signup and every mutating call failed in the
browser while curl and the pytest suite passed.
"""

import pytest
from rest_framework.test import APIClient

# Mirrors apps/web/src/lib/api.ts. Keep in step with that file.
WEB_CLIENT_HEADERS = [
    "accept",
    "authorization",
    "content-type",
    "idempotency-key",
    "x-client",
]

ORIGIN = "http://127.0.0.1:4173"


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def allowed_origin(settings):
    """CORS_ALLOWED_ORIGINS comes from the environment, which tests do not set."""
    settings.CORS_ALLOWED_ORIGINS = [ORIGIN]
    return ORIGIN


@pytest.mark.parametrize(
    "path",
    [
        "/api/v1/auth/signup/",
        "/api/v1/sales/",
        "/api/v1/assistant/proposals/",
    ],
)
def test_preflight_allows_every_web_client_header(api_client, allowed_origin, path):
    response = api_client.options(
        path,
        HTTP_ORIGIN=allowed_origin,
        HTTP_ACCESS_CONTROL_REQUEST_METHOD="POST",
        HTTP_ACCESS_CONTROL_REQUEST_HEADERS=",".join(WEB_CLIENT_HEADERS),
    )

    assert response.status_code == 200
    allowed = {
        header.strip().lower()
        for header in response.headers["Access-Control-Allow-Headers"].split(",")
    }
    missing = set(WEB_CLIENT_HEADERS) - allowed
    assert not missing, f"{path} does not allow {sorted(missing)}"


def test_allowed_origin_is_echoed(api_client, allowed_origin):
    response = api_client.options(
        "/api/v1/auth/signup/",
        HTTP_ORIGIN=allowed_origin,
        HTTP_ACCESS_CONTROL_REQUEST_METHOD="POST",
        HTTP_ACCESS_CONTROL_REQUEST_HEADERS="content-type,x-client",
    )

    assert response.headers["Access-Control-Allow-Origin"] == allowed_origin


def test_unknown_origin_is_not_allowed(api_client, allowed_origin):
    response = api_client.options(
        "/api/v1/auth/signup/",
        HTTP_ORIGIN="http://evil.example.com",
        HTTP_ACCESS_CONTROL_REQUEST_METHOD="POST",
        HTTP_ACCESS_CONTROL_REQUEST_HEADERS="content-type",
    )

    assert "Access-Control-Allow-Origin" not in response.headers
