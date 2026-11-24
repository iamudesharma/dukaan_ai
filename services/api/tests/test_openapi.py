from drf_spectacular.drainage import GENERATOR_STATS, reset_generator_stats
from drf_spectacular.generators import SchemaGenerator
from drf_spectacular.validation import validate_schema

CRITICAL_OPERATIONS = {
    "/healthz/": {"get"},
    "/readyz/": {"get"},
    "/api/v1/me/": {"get"},
    "/api/v1/bootstrap/": {"get"},
    "/api/v1/auth/logout/": {"post"},
    "/api/v1/auth/sessions/revoke-all/": {"post"},
    "/api/v1/auth/password/reset/": {"post"},
    "/api/v1/auth/password/reset/confirm/": {"post"},
    "/api/v1/imports/products/": {"post"},
    "/api/v1/imports/parties/": {"post"},
    "/api/v1/imports/": {"get"},
    "/api/v1/imports/{job_id}/": {"get"},
    "/api/v1/imports/{job_id}/confirm/": {"post"},
    "/api/v1/integrations/gmail/status/": {"get"},
    "/api/v1/integrations/gmail/connect/": {"get"},
    "/api/v1/integrations/gmail/callback/": {"get"},
    "/api/v1/integrations/gmail/": {"delete"},
    "/api/v1/integrations/gmail/messages/": {"get"},
    "/api/v1/integrations/gmail/import/": {"post"},
    "/api/v1/integrations/gmail/imports/": {"get"},
    "/api/v1/integrations/notifications/devices/": {"get", "post"},
    "/api/v1/integrations/notifications/devices/{device_id}/": {"delete"},
    "/api/v1/integrations/notifications/reminders/": {"get", "post"},
    "/api/v1/integrations/notifications/reminders/{reminder_id}/": {"get", "patch", "delete"},
    "/api/v1/invoices/sales/{sale_id}/pdf/": {"get"},
    "/api/v1/payments/allocation-review/": {"get"},
    "/api/v1/payments/{id}/reallocate/": {"post"},
    "/api/v1/stock/adjustments/": {"post"},
    "/api/v1/party-ledger/opening-balances/": {"post"},
    "/api/v1/reports/dashboard/": {"get"},
    "/api/v1/reports/stock/": {"get"},
    "/api/v1/reports/valuation/": {"get"},
    "/api/v1/reports/party-ledger/": {"get"},
}


def test_openapi_schema_covers_mounted_operations_and_bearer_auth():
    reset_generator_stats()
    generator = SchemaGenerator()
    schema = generator.get_schema(public=True)

    validate_schema(schema)
    assert not GENERATOR_STATS, {
        "warnings": dict(GENERATOR_STATS._warn_cache),
        "errors": dict(GENERATOR_STATS._error_cache),
    }

    # Every mounted application operation must survive schema generation. The
    # schema and Swagger views are intentionally omitted by SERVE_INCLUDE_SCHEMA.
    for path, _, method, _ in generator.inspector.get_api_endpoints():
        if path in {"/api/schema/", "/api/docs/"}:
            continue
        openapi_path = path.replace("{pk}", "{id}")
        assert method.lower() in schema["paths"].get(openapi_path, {}), (path, method)

    for path, methods in CRITICAL_OPERATIONS.items():
        assert path in schema["paths"], path
        assert methods <= schema["paths"][path].keys(), path

    security_scheme = schema["components"]["securitySchemes"]["bearerAuth"]
    assert security_scheme["type"] == "http"
    assert security_scheme["scheme"] == "bearer"
    assert security_scheme["bearerFormat"] == "JWT"

    protected = schema["paths"]["/api/v1/auth/sessions/revoke-all/"]["post"]
    assert protected["security"] == [{"bearerAuth": []}]
    public = schema["paths"]["/api/v1/auth/login/"]["post"]
    assert not public.get("security")

    payment_create = schema["paths"]["/api/v1/payments/"]["post"]
    assert payment_create["requestBody"]["content"]["application/json"]["schema"] == {
        "$ref": "#/components/schemas/PaymentCreate"
    }
    allocation_review = schema["paths"]["/api/v1/payments/allocation-review/"]["get"]
    assert allocation_review["responses"]["200"]["content"]["application/json"]["schema"] == {
        "$ref": "#/components/schemas/PaymentAllocationReview"
    }
    reallocate = schema["paths"]["/api/v1/payments/{id}/reallocate/"]["post"]
    assert reallocate["requestBody"]["content"]["application/json"]["schema"] == {
        "$ref": "#/components/schemas/PaymentReallocation"
    }
    allocation_input = schema["components"]["schemas"]["PaymentAllocationInput"]
    document_type = allocation_input["properties"]["document_type"]
    assert document_type["nullable"] is True
    assert {"SALE", "PURCHASE"} <= set(document_type["enum"])
    assert "oneOf" not in document_type

    upload = schema["paths"]["/api/v1/imports/products/"]["post"]
    assert "multipart/form-data" in upload["requestBody"]["content"]
    assert set(upload["responses"]) == {"200", "201"}

    invoice_pdf = schema["paths"]["/api/v1/invoices/sales/{sale_id}/pdf/"]["get"]
    pdf_schema = invoice_pdf["responses"]["200"]["content"]["application/pdf"]["schema"]
    assert pdf_schema == {"type": "string", "format": "binary"}

    operation_ids = [
        operation["operationId"]
        for operations in schema["paths"].values()
        for operation in operations.values()
    ]
    assert len(operation_ids) == len(set(operation_ids))
