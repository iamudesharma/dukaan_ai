import hashlib
from decimal import Decimal
from unittest.mock import patch

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.db import connection
from django.db.models import BinaryField, FileField
from django.urls import include, path
from rest_framework.test import APIClient

from apps.catalog.models import Party, Product, ProductPack
from apps.common.models import User
from apps.imports.models import ImportJob
from apps.tenancy.models import AuditEvent, Business, Location, Membership, OutboxEvent

pytestmark = pytest.mark.django_db

# The imports app owns its URLconf. The parent API URLconf is intentionally
# outside this change's edit boundary, so mount the app exactly as production
# will mount it for these endpoint tests.
urlpatterns = [path("api/v1/", include("apps.imports.urls"))]


@pytest.fixture(autouse=True)
def use_import_urls(settings):
    settings.ROOT_URLCONF = __name__


@pytest.fixture
def shop():
    """Minimal catalog tenant; imports do not depend on inventory balances."""
    user = User.objects.create_user(username="owner")
    business = Business.objects.create(name="Test shop")
    location = Location.objects.create(business=business, code="MAIN", name="Main")
    Membership.objects.create(user=user, business=business, role="OWNER")
    product = Product.objects.create(business=business, name="shirt")
    ProductPack.objects.create(
        product=product,
        name="piece",
        conversion_factor=1,
        retail_price_minor=80000,
        wholesale_price_minor=75000,
    )
    return user, business, location, product


@pytest.fixture
def client(shop):
    api = APIClient()
    api.force_authenticate(shop[0])
    return api


def _file(content, filename="data.csv"):
    if isinstance(content, str):
        content = content.encode("utf-8")
    return SimpleUploadedFile(filename, content, content_type="text/csv")


def _upload(client, business, kind, content, **options):
    payload = {
        "business_id": str(business.pk),
        "file": _file(content, options.pop("filename", f"{kind.lower()}.csv")),
        **options,
    }
    return client.post(f"/api/v1/imports/{kind}/", payload, format="multipart")


def _confirm(client, job, key="confirm-1", *, header=False):
    if header:
        return client.post(
            f"/api/v1/imports/{job.pk}/confirm/",
            {},
            format="json",
            headers={"Idempotency-Key": key},
        )
    return client.post(
        f"/api/v1/imports/{job.pk}/confirm/",
        {"idempotency_key": key},
        format="json",
    )


PRODUCT_CSV = (
    "name,sku,base_unit,hsn_sac,gst_bps,low_stock_threshold,"
    "pack_name,pack_conversion,retail_price_minor,wholesale_price_minor\n"
    "Blue shirt,SHIRT-BLUE,PIECE,6205,1200,3.500,piece,1,79900,74900\n"
    "Sugar,SUGAR-1,KILOGRAM,1701,500,2.250,kg,1,5500,5000\n"
)
PARTY_CSV = """name,kind,phone,gstin,state,address
Ramesh Traders,BOTH,+919876543210,27ABCDE1234F1Z5,27,12 Market Road
Walk-in Customer,CUSTOMER,,,,
"""


def test_valid_product_import_confirms_with_pack_and_audit(shop, client):
    _, business, _, _ = shop

    uploaded = _upload(client, business, "products", PRODUCT_CSV, filename="../catalog.csv")

    assert uploaded.status_code == 201
    body = uploaded.json()
    assert body["status"] == "READY"
    assert body["row_count"] == body["valid_row_count"] == 2
    assert body["error_count"] == 0
    assert body["original_filename"] == "catalog.csv"
    job = ImportJob.objects.get(pk=body["id"])
    assert job.file_sha256 == hashlib.sha256(PRODUCT_CSV.encode()).hexdigest()
    assert job.file_size_bytes == len(PRODUCT_CSV.encode())
    assert not any(
        isinstance(field, BinaryField | FileField) for field in ImportJob._meta.get_fields()
    )
    assert Product.objects.filter(business=business).count() == 1  # only the shop fixture product

    confirmed = _confirm(client, job, header=True)
    assert confirmed.status_code == 200
    assert confirmed.headers["Idempotent-Replay"] == "false"
    assert confirmed.json()["job"]["created_count"] == 2
    shirt = Product.objects.get(business=business, sku="SHIRT-BLUE")
    assert shirt.name == "Blue shirt"
    assert shirt.hsn_sac == "6205"
    assert shirt.tax_rate_bps == 1200
    assert shirt.low_stock_threshold == Decimal("3.500")
    pack = shirt.packs.get()
    assert pack.conversion_factor == Decimal("1")
    assert pack.retail_price_minor == 79900
    assert pack.wholesale_price_minor == 74900
    job.refresh_from_db()
    assert job.status == "COMPLETED"
    assert job.confirmed_by_id == shop[0].pk
    assert job.confirmed_at is not None

    event = AuditEvent.objects.get(business=business, event_type="import.confirmed")
    assert event.aggregate_id == job.pk
    assert event.metadata["created_count"] == 2
    outbox = OutboxEvent.objects.get(business=business, topic="import.confirmed")
    assert outbox.payload["id"] == str(job.pk)


def test_valid_party_import_confirms(shop, client):
    _, business, _, _ = shop
    uploaded = _upload(client, business, "parties", PARTY_CSV)
    assert uploaded.status_code == 201
    job = ImportJob.objects.get(pk=uploaded.json()["id"])

    response = _confirm(client, job, key="party-import")

    assert response.status_code == 200
    trader = Party.objects.get(business=business, gstin="27ABCDE1234F1Z5")
    assert trader.name == "Ramesh Traders"
    assert trader.kind == Party.Kind.BOTH
    assert trader.phone_e164 == "+919876543210"
    assert trader.state_code == "27"
    assert trader.address == "12 Market Road"
    assert Party.objects.filter(business=business, name="Walk-in Customer").exists()


def test_dry_run_reports_duplicate_plan_without_writes(shop, client):
    _, business, _, product = shop
    product.sku = "EXISTING"
    product.save(update_fields=["sku", "updated_at"])
    content = """name,sku
Updated shirt,existing
New shirt,NEW
"""

    response = _upload(client, business, "products", content, dry_run="true")

    assert response.status_code == 200
    body = response.json()
    assert body["dry_run"] is True
    assert body["created_count"] == 1
    assert body["updated_count"] == 1
    assert body["preview"] == [{"row": 2, "action": "UPDATE"}, {"row": 3, "action": "CREATE"}]
    assert ImportJob.objects.count() == 0
    product.refresh_from_db()
    assert product.name == "shirt"
    assert not Product.objects.filter(business=business, sku="NEW").exists()
    assert AuditEvent.objects.count() == 0
    assert OutboxEvent.objects.count() == 0


def test_dry_run_returns_row_errors_without_creating_job(shop, client):
    _, business, _, _ = shop
    response = _upload(
        client,
        business,
        "products",
        "name,gst_bps\nGood,100\nBad,not-a-number\n",
        dry_run=True,
    )
    assert response.status_code == 200
    assert response.json()["error_count"] == 1
    assert response.json()["errors"][0]["row"] == 3
    assert ImportJob.objects.count() == 0
    assert Product.objects.filter(business=business).count() == 1


@pytest.mark.parametrize(
    ("kind", "content"),
    [
        ("products", "sku\nSKU\n"),
        ("products", "name,unknown\nShirt,x\n"),
        ("products", "name,name\nShirt,Shirt\n"),
        ("products", "name,pack_name\nShirt,piece\n"),
        ("parties", "name\nRamesh\n"),
        ("parties", "name,kind,extra\nRamesh,CUSTOMER,x\n"),
    ],
)
def test_invalid_headers_are_rejected(shop, client, kind, content):
    _, business, _, _ = shop
    response = _upload(client, business, kind, content)
    assert response.status_code == 400
    assert "headers" in response.json()["error"]["detail"]
    assert ImportJob.objects.count() == 0


def test_non_utf8_and_malformed_csv_are_rejected(shop, client):
    _, business, _, _ = shop
    invalid_utf8 = _upload(client, business, "products", b"name\n\xff\n")
    assert invalid_utf8.status_code == 400
    assert "UTF-8" in str(invalid_utf8.json()["error"]["detail"]["file"])

    malformed = _upload(client, business, "products", 'name\n"unterminated\n')
    assert malformed.status_code == 400
    assert "malformed" in str(malformed.json()["error"]["detail"]["file"]).lower()
    assert ImportJob.objects.count() == 0


def test_invalid_product_rows_are_reported_and_block_confirmation(shop, client):
    _, business, _, _ = shop
    content = (
        "name,sku,gst_bps,low_stock_threshold,pack_name,pack_conversion,"
        "retail_price_minor,wholesale_price_minor\n"
        "Good,GOOD,500,1.250,piece,1,100,90\n"
        "Bad tax,BAD,10001,-1,piece,0,-5,90\n"
        "Wrong columns,ONLY-TWO\n"
    )
    response = _upload(client, business, "products", content)
    assert response.status_code == 201
    body = response.json()
    assert body["status"] == "INVALID"
    assert body["row_count"] == 3
    assert body["valid_row_count"] == 1
    assert body["error_count"] == 2
    errors = {item["row"]: item["errors"] for item in body["errors"]}
    assert "gst_bps" in errors[3]
    assert "low_stock_threshold" in errors[3]
    assert "pack_conversion" in errors[3]
    assert "retail_price_minor" in errors[3]
    assert "_row" in errors[4]
    job = ImportJob.objects.get(pk=body["id"])

    confirmed = _confirm(client, job)
    assert confirmed.status_code == 409
    assert Product.objects.filter(business=business, sku__in=["GOOD", "BAD"]).exists() is False
    assert AuditEvent.objects.filter(event_type="import.confirmed").count() == 0


def test_invalid_party_rows_are_reported(shop, client):
    _, business, _, _ = shop
    content = """name,kind,phone,gstin,state
Good,CUSTOMER,+919876543210,27ABCDE1234F1Z5,27
Bad,UNKNOWN,12345,invalid,XX
"""
    response = _upload(client, business, "parties", content)
    assert response.status_code == 201
    body = response.json()
    assert body["status"] == "INVALID"
    assert body["valid_row_count"] == 1
    errors = body["errors"][0]["errors"]
    assert set(errors) == {"kind", "phone", "gstin", "state"}


def test_product_duplicate_update_is_last_row_wins(shop, client):
    _, business, _, _ = shop
    existing = Product.objects.create(business=business, name="Old", sku="DUP")
    old_pack = ProductPack.objects.create(
        product=existing,
        name="piece",
        conversion_factor=1,
        retail_price_minor=1,
        wholesale_price_minor=1,
    )
    content = """name,sku,pack_name,pack_conversion,retail_price_minor,wholesale_price_minor
First,DUP,piece,1,100,90
Last,DUP,piece,1,200,180
"""
    job = ImportJob.objects.get(pk=_upload(client, business, "products", content).json()["id"])

    response = _confirm(client, job)

    assert response.status_code == 200
    assert response.json()["job"]["updated_count"] == 2
    assert Product.objects.filter(business=business, sku="DUP").count() == 1
    existing.refresh_from_db()
    old_pack.refresh_from_db()
    assert existing.name == "Last"
    assert old_pack.retail_price_minor == 200
    assert old_pack.wholesale_price_minor == 180


def test_product_duplicate_skip_is_first_row_wins(shop, client):
    _, business, _, _ = shop
    Product.objects.create(business=business, name="Existing", sku="EXISTING")
    content = """name,sku
Changed,EXISTING
First new,NEW
Second new,new
"""
    response = _upload(client, business, "products", content, duplicate_strategy="skip")
    job = ImportJob.objects.get(pk=response.json()["id"])

    confirmed = _confirm(client, job)

    assert confirmed.status_code == 200
    counts = confirmed.json()["job"]
    assert counts["created_count"] == 1
    assert counts["skipped_count"] == 2
    assert Product.objects.get(business=business, sku="EXISTING").name == "Existing"
    assert Product.objects.get(business=business, sku="NEW").name == "First new"


def test_party_duplicates_update_by_gstin_and_skip_by_phone(shop, client):
    _, business, _, _ = shop
    existing = Party.objects.create(
        business=business,
        name="Old trader",
        kind=Party.Kind.SUPPLIER,
        gstin="27ABCDE1234F1Z5",
    )
    content = """name,kind,phone,gstin
First trader,BOTH,+919876543210,27ABCDE1234F1Z5
Last trader,CUSTOMER,+919876543210,27ABCDE1234F1Z5
New supplier,SUPPLIER,+919999999999,
New supplier skipped,SUPPLIER,+919999999999,
"""
    uploaded = _upload(client, business, "parties", content, duplicate_strategy="SKIP")
    job = ImportJob.objects.get(pk=uploaded.json()["id"])

    response = _confirm(client, job)

    assert response.status_code == 200
    assert response.json()["job"]["skipped_count"] == 3
    existing.refresh_from_db()
    assert existing.name == "Old trader"
    assert Party.objects.get(business=business, phone_e164="+919999999999").name == "New supplier"


def test_party_duplicate_update_uses_gstin_then_phone_then_name(shop, client):
    _, business, _, _ = shop
    existing = Party.objects.create(
        business=business,
        name="Old",
        kind=Party.Kind.SUPPLIER,
        phone_e164="+919876543210",
    )
    content = """name,kind,phone,gstin
Updated,CUSTOMER,+919876543210,
"""
    job = ImportJob.objects.get(pk=_upload(client, business, "parties", content).json()["id"])
    response = _confirm(client, job)
    assert response.status_code == 200
    existing.refresh_from_db()
    assert existing.name == "Updated"
    assert existing.kind == Party.Kind.CUSTOMER


def test_confirm_is_idempotent_and_rejects_key_reuse(shop, client):
    _, business, _, _ = shop
    first = ImportJob.objects.get(
        pk=_upload(client, business, "parties", "name,kind\nOne,CUSTOMER\n").json()["id"]
    )
    second = ImportJob.objects.get(
        pk=_upload(client, business, "parties", "name,kind\nTwo,CUSTOMER\n").json()["id"]
    )

    initial = _confirm(client, first, key="stable")
    replay = _confirm(client, first, key="stable")
    different = _confirm(client, first, key="different")
    reused = _confirm(client, second, key="stable")

    assert initial.status_code == replay.status_code == 200
    assert replay.json()["replayed"] is True
    assert replay.headers["Idempotent-Replay"] == "true"
    assert different.status_code == reused.status_code == 409
    assert Party.objects.filter(business=business).count() == 1
    assert AuditEvent.objects.filter(event_type="import.confirmed").count() == 1
    assert OutboxEvent.objects.filter(topic="import.confirmed").count() == 1


def test_confirm_rolls_back_all_rows_and_events_on_failure(shop, client):
    _, business, _, _ = shop
    content = "name,kind\nFirst,CUSTOMER\nSecond,CUSTOMER\n"
    job = ImportJob.objects.get(pk=_upload(client, business, "parties", content).json()["id"])
    from apps.imports.services import _apply_party_row

    calls = 0

    def fail_second(*args, **kwargs):
        nonlocal calls
        calls += 1
        if calls == 2:
            raise RuntimeError("injected write failure")
        return _apply_party_row(*args, **kwargs)

    with patch("apps.imports.services._apply_party_row", side_effect=fail_second):
        with pytest.raises(RuntimeError, match="injected"):
            _confirm(client, job)

    job.refresh_from_db()
    assert job.status == "READY"
    assert Party.objects.filter(business=business).count() == 0
    assert AuditEvent.objects.filter(event_type="import.confirmed").count() == 0
    assert OutboxEvent.objects.filter(topic="import.confirmed").count() == 0


def test_upload_size_and_row_limits_are_strict(shop, client, settings):
    _, business, _, _ = shop
    settings.IMPORT_MAX_BYTES = 32
    too_large = _upload(client, business, "products", "name\n" + "x" * 40 + "\n")
    assert too_large.status_code == 413
    assert ImportJob.objects.count() == 0

    settings.IMPORT_MAX_BYTES = 1024
    settings.IMPORT_MAX_ROWS = 1
    too_many = _upload(client, business, "products", "name\nOne\nTwo\n")
    assert too_many.status_code == 413
    assert ImportJob.objects.count() == 0


def test_cashier_and_nonmember_cannot_upload_or_confirm(shop):
    user, business, _, _ = shop
    membership = Membership.objects.get(user=user, business=business)
    membership.role = Membership.Role.CASHIER
    membership.save(update_fields=["role", "updated_at"])
    cashier = APIClient()
    cashier.force_authenticate(user)
    response = _upload(cashier, business, "products", "name\nForbidden\n")
    assert response.status_code == 403
    assert ImportJob.objects.count() == 0

    job = ImportJob.objects.create(
        business=business,
        user=user,
        kind=ImportJob.Kind.PARTY,
        row_count=1,
        valid_row_count=1,
        rows=[
            {
                "_row": 2,
                "name": "Existing",
                "kind": "CUSTOMER",
                "phone": "",
                "gstin": "",
                "state": "",
                "address": "",
            }
        ],
        original_filename="parties.csv",
        file_sha256="a" * 64,
        file_size_bytes=10,
    )
    assert _confirm(cashier, job).status_code == 403

    outsider = User.objects.create_user(username="outsider")
    other = Business.objects.create(name="Other")
    Membership.objects.create(user=outsider, business=other, role="OWNER")
    outsider_client = APIClient()
    outsider_client.force_authenticate(outsider)
    assert (
        _upload(outsider_client, business, "parties", "name,kind\nNo,CUSTOMER\n").status_code == 403
    )
    assert _confirm(outsider_client, job).status_code in {403, 404}


def test_manager_can_upload_and_confirm(shop):
    user, business, _, _ = shop
    membership = Membership.objects.get(user=user, business=business)
    membership.role = Membership.Role.MANAGER
    membership.save(update_fields=["role", "updated_at"])
    client = APIClient()
    client.force_authenticate(user)
    uploaded = _upload(client, business, "parties", "name,kind\nManager customer,CUSTOMER\n")
    assert uploaded.status_code == 201
    job = ImportJob.objects.get(pk=uploaded.json()["id"])
    assert _confirm(client, job).status_code == 200


def test_tenant_isolation_for_jobs_and_catalog_duplicates(shop, client):
    _, business, _, _ = shop
    other_user = User.objects.create_user(username="other-owner")
    other = Business.objects.create(name="Other shop")
    Membership.objects.create(user=other_user, business=other, role="OWNER")
    foreign_product = Product.objects.create(business=other, name="Foreign", sku="SHARED")
    foreign_job = ImportJob.objects.create(
        business=other,
        user=other_user,
        kind=ImportJob.Kind.PRODUCT,
        row_count=1,
        valid_row_count=1,
        rows=[
            {
                "_row": 2,
                "name": "Foreign update",
                "sku": "SHARED",
                "base_unit": "PIECE",
                "hsn_sac": "",
                "gst_bps": 0,
                "low_stock_threshold": "0",
                "pack": None,
            }
        ],
        original_filename="foreign.csv",
        file_sha256="b" * 64,
        file_size_bytes=10,
    )

    assert client.get(f"/api/v1/imports/{foreign_job.pk}/").status_code in {403, 404}
    assert _confirm(client, foreign_job).status_code in {403, 404}
    assert client.get("/api/v1/imports/", {"business_id": str(other.pk)}).status_code == 403

    local_job = ImportJob.objects.get(
        pk=_upload(client, business, "products", "name,sku\nLocal,SHARED\n").json()["id"]
    )
    assert _confirm(client, local_job).status_code == 200
    foreign_product.refresh_from_db()
    assert foreign_product.name == "Foreign"
    assert Product.objects.get(business=business, sku="SHARED").name == "Local"


def test_unauthenticated_upload_is_rejected(shop):
    _, business, _, _ = shop
    response = _upload(APIClient(), business, "products", "name\nNo\n")
    assert response.status_code == 401


@pytest.mark.skipif(connection.vendor != "postgresql", reason="RLS is a PostgreSQL control")
def test_import_job_table_is_force_protected():
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT c.relrowsecurity, c.relforcerowsecurity FROM pg_class c "
            "JOIN pg_namespace n ON n.oid = c.relnamespace "
            "WHERE c.relname = 'imports_importjob' AND n.nspname = current_schema()"
        )
        rowsecurity, force = cursor.fetchone()
        cursor.execute("SELECT count(*) FROM pg_policies WHERE tablename = 'imports_importjob'")
        (policies,) = cursor.fetchone()
    assert rowsecurity and force
    assert policies >= 1
