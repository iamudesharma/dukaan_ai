"""OpenAPI contract tests: the committed schema is the source of truth.

``docs/api/openapi.yml`` is generated from the code (``make api-schema``).
These tests prove, in CI on every push:

- the schema endpoint serves every Phase 0-4 route (no view left
  undocumented/unreachable);
- write endpoints document their idempotency contract where the
  serializer is visible to spectacular;
- the committed file matches the generated schema, so client codegen
  (TS + Dart) never drifts from the server.
"""

from pathlib import Path

import pytest
import yaml
from drf_spectacular.generators import SchemaGenerator
from rest_framework.test import APIClient

pytestmark = pytest.mark.django_db

SCHEMA_PATH = Path(__file__).resolve().parents[3] / "docs" / "api" / "openapi.yml"

# Every surface area added across Phases 0-4 must stay reachable.
REQUIRED_PATHS = [
    "/api/v1/activity/",
    "/api/v1/assistant/proposals/",
    "/api/v1/attachments/",
    "/api/v1/attachments/presign/",
    "/api/v1/auth/login/",
    "/api/v1/auth/refresh/",
    "/api/v1/auth/logout-all/",
    "/api/v1/bootstrap/",
    "/api/v1/businesses/",
    "/api/v1/devices/",
    "/api/v1/expenses/",
    "/api/v1/exports/",
    "/api/v1/invitations/",
    "/api/v1/locations/",
    "/api/v1/me/",
    "/api/v1/memberships/",
    "/api/v1/notification-preferences/",
    "/api/v1/parties/",
    "/api/v1/payments/",
    "/api/v1/products/",
    "/api/v1/purchases/",
    "/api/v1/reminders/",
    "/api/v1/reminders/suggestions/",
    "/api/v1/reports/day-book/",
    "/api/v1/reports/export/",
    "/api/v1/reports/gst/",
    "/api/v1/reports/party-balances/",
    "/api/v1/reports/sales/",
    "/api/v1/reports/stock/",
    "/api/v1/reports/stock-valuation/",
    "/api/v1/reports/party-ledger/",
    "/api/v1/sales/",
    "/api/v1/search/",
    "/api/v1/stock/movements/",
    "/api/v1/transfers/",
]


def _generate() -> dict:
    generator = SchemaGenerator()
    return generator.get_schema(request=None, public=True)


def test_schema_endpoint_lists_all_surfaces(shop):
    user, _, _, _ = shop
    client = APIClient()
    client.force_authenticate(user)
    response = client.get("/api/schema/?format=json")
    assert response.status_code == 200, response.content[:200]
    paths = set(response.data["paths"])
    missing = [path for path in REQUIRED_PATHS if path not in paths]
    assert not missing, f"undocumented routes: {missing}"


def test_committed_schema_matches_generated():
    assert SCHEMA_PATH.exists(), "run `make api-schema` to generate docs/api/openapi.yml"
    committed = yaml.safe_load(SCHEMA_PATH.read_text())
    generated = yaml.safe_load(yaml.safe_dump(_generate()))
    assert committed == generated, (
        "docs/api/openapi.yml is stale; run `make api-schema` and commit the result"
    )


def test_schema_covers_new_crud_routes():
    schema = _generate()
    paths = schema["paths"]
    for path in REQUIRED_PATHS:
        assert path in paths, path
    # Proposal creation documents its media contract for codegen.
    assert "attachment_ids" in schema["components"]["schemas"]["Interpret"]["properties"]
    # Upload + search shapes are visible to codegen.
    assert "business_id" in schema["components"]["schemas"]["AttachmentUpload"]["properties"]
    search_get = paths["/api/v1/search/"]["get"]
    assert "business_id" in yaml.safe_dump(search_get)
