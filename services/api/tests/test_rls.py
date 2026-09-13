"""Direct Row Level Security tests: raw SQL as the application role.

These tests bypass the ORM and the application layer entirely. They open a
dedicated connection as the least-privilege application role and prove the
database itself enforces tenant isolation:

- with no scope, the role sees zero tenant rows (fail closed);
- with one business in scope, it sees exactly that business's rows;
- writes outside the scope are rejected by the database, including for the
  table owner (FORCE RLS);
- child tables (lines, packs, revisions, allocations) inherit isolation;
- the membership self-read lets a connection bootstrap its own business
  list without seeing other tenants.

Requires PostgreSQL plus the ``dukaan_app`` role (see compose/infra docs).
Skipped on SQLite, which has no RLS equivalent.
"""

import os
import uuid

import pytest
from django.conf import settings
from django.db import DatabaseError, connection
from django.db.utils import load_backend

from apps.catalog.models import Product, ProductPack
from apps.common.models import User
from apps.operations.models import Sale
from apps.tenancy import rls
from apps.tenancy.models import Business, Location, Membership

pytestmark = pytest.mark.django_db(transaction=True)

requires_postgres = pytest.mark.skipif(
    connection.vendor != "postgresql", reason="RLS is a PostgreSQL control"
)


def _app_role() -> str:
    return getattr(settings, "DUKAAN_APP_DB_ROLE", rls.DEFAULT_APP_ROLE)


@pytest.fixture
def two_tenants():
    users = [User.objects.create_user(username=f"rls-user-{n}") for n in range(2)]
    businesses = [Business.objects.create(name=f"RLS shop {n}") for n in range(2)]
    for business in businesses:
        Location.objects.create(business=business, code="MAIN", name="Main")
    for user, business in zip(users, businesses, strict=True):
        Membership.objects.create(user=user, business=business, role="OWNER")
    for business in businesses:
        product = Product.objects.create(business=business, name="shirt")
        ProductPack.objects.create(
            product=product,
            name="piece",
            conversion_factor=1,
            retail_price_minor=80000,
            wholesale_price_minor=75000,
        )
    return users, businesses


@pytest.fixture
def app_connection():
    """Dedicated connection as the least-privilege application role."""
    params = dict(connection.settings_dict)
    params["USER"] = _app_role()
    params["PASSWORD"] = os.environ.get("DUKAAN_APP_DB_PASSWORD", "app_local_only")
    wrapper = load_backend(params["ENGINE"]).DatabaseWrapper(params, "rls_probe")
    try:
        yield wrapper
    finally:
        wrapper.close()


@requires_postgres
def test_app_role_sees_nothing_without_scope(two_tenants, app_connection):
    with app_connection.cursor() as cursor:
        for table in ("tenancy_business", "operations_sale", "catalog_product"):
            cursor.execute(f"SELECT count(*) FROM {table}")
            assert cursor.fetchone()[0] == 0


@requires_postgres
def test_app_role_sees_only_scoped_business(two_tenants, app_connection):
    users, businesses = two_tenants
    rls.set_tenant_scope(app_connection, user_id=users[0].pk, business_ids=[str(businesses[0].pk)])
    with app_connection.cursor() as cursor:
        cursor.execute("SELECT id FROM tenancy_business")
        assert [str(row[0]) for row in cursor.fetchall()] == [str(businesses[0].pk)]
        cursor.execute(
            "SELECT count(*) FROM catalog_product WHERE business_id = %s",
            [str(businesses[1].pk)],
        )
        assert cursor.fetchone()[0] == 0


def _smuggle_product(cursor, business_id, name: str, sku: str):
    """INSERT a fully-valid product row into another business.

    Copies an existing in-scope row so the statement stays valid as columns
    are added; only the RLS policy may reject it.
    """
    cursor.execute("SELECT * FROM catalog_product LIMIT 1")
    columns = [column[0] for column in cursor.description]
    template = cursor.fetchone()
    assert template is not None
    values = dict(zip(columns, template, strict=True))
    values["id"] = str(uuid.uuid4())
    values["business_id"] = str(business_id)
    values["name"] = name
    values["sku"] = sku
    placeholders = ", ".join(["%s"] * len(columns))
    cursor.execute(
        f"INSERT INTO catalog_product ({', '.join(columns)}) VALUES ({placeholders})",
        [values[column] for column in columns],
    )


@requires_postgres
def test_cross_tenant_write_is_rejected(two_tenants, app_connection):
    users, businesses = two_tenants
    rls.set_tenant_scope(app_connection, user_id=users[0].pk, business_ids=[str(businesses[0].pk)])
    with app_connection.cursor() as cursor:
        with pytest.raises(DatabaseError, match="row-level security policy"):
            _smuggle_product(cursor, businesses[1].pk, "smuggled", "SMUGGLED")


@requires_postgres
def test_owner_writes_outside_scope_are_rejected(two_tenants):
    """FORCE RLS binds table owners too: the migration role cannot smuggle
    rows into a business outside its connection scope."""
    _, businesses = two_tenants
    params = dict(connection.settings_dict)
    wrapper = load_backend(params["ENGINE"]).DatabaseWrapper(params, "rls_owner_probe")
    try:
        with wrapper.cursor() as cursor:
            cursor.execute("SELECT rolbypassrls FROM pg_roles WHERE rolname = CURRENT_USER")
            if cursor.fetchone()[0]:
                pytest.skip("Migration role bypasses RLS; FORCE RLS is proven in CI as owner")
        rls.set_tenant_scope(wrapper, business_ids=[str(businesses[0].pk)])
        with wrapper.cursor() as cursor:
            with pytest.raises(DatabaseError, match="row-level security policy"):
                _smuggle_product(cursor, businesses[1].pk, "owner-smuggled", "OWNER-SMUGGLED")
    finally:
        wrapper.close()


@requires_postgres
def test_child_rows_inherit_parent_isolation(two_tenants, app_connection):
    users, businesses = two_tenants
    rls.set_tenant_scope(app_connection, user_id=users[0].pk, business_ids=[str(businesses[0].pk)])
    with app_connection.cursor() as cursor:
        cursor.execute("SELECT count(*) FROM catalog_productpack")
        assert cursor.fetchone()[0] == 1
        foreign_pack = ProductPack.objects.filter(product__business=businesses[1]).values_list(
            "pk", flat=True
        )[0]
        cursor.execute(
            "SELECT count(*) FROM catalog_productpack WHERE id = %s",
            [str(foreign_pack)],
        )
        assert cursor.fetchone()[0] == 0


@requires_postgres
def test_self_membership_bootstrap_is_scoped(two_tenants, app_connection):
    users, businesses = two_tenants
    rls.set_tenant_scope(app_connection, user_id=users[0].pk, business_ids=[])
    with app_connection.cursor() as cursor:
        cursor.execute("SELECT count(*) FROM tenancy_business")
        assert cursor.fetchone()[0] == 0
    # Bootstrap derives exactly the caller's own business from the
    # membership table and finalises the scope to it.
    assert rls.active_business_ids(app_connection, users[0]) == [str(businesses[0].pk)]
    with app_connection.cursor() as cursor:
        cursor.execute("SELECT count(*) FROM tenancy_business")
        assert cursor.fetchone()[0] == 1
        cursor.execute(
            "SELECT count(*) FROM tenancy_membership WHERE user_id != %s",
            [str(users[0].pk)],
        )
        assert cursor.fetchone()[0] == 0


@requires_postgres
def test_sale_lines_are_scoped_with_their_sale(shop, app_connection):
    user, business, location, _ = shop
    from apps.assistant.services import confirm, interpret

    sale, _ = confirm(
        proposal=interpret(
            actor=user,
            business=business,
            location=location,
            input_type="TEXT",
            locale="en",
            content="Ramesh bought 3 shirts for \u20b92,400, paid \u20b91,500, \u20b9900 pending.",
        ),
        actor=user,
        version=1,
        idempotency_key="rls-lines",
    )
    rls.set_tenant_scope(app_connection, user_id=user.pk, business_ids=[str(business.pk)])
    with app_connection.cursor() as cursor:
        cursor.execute("SELECT count(*) FROM operations_sale")
        assert cursor.fetchone()[0] == 1
        cursor.execute("SELECT count(*) FROM operations_saleline")
        assert cursor.fetchone()[0] == 1
    other = Business.objects.create(name="RLS other")
    rls.set_tenant_scope(app_connection, user_id=user.pk, business_ids=[str(other.pk)])
    with app_connection.cursor() as cursor:
        cursor.execute("SELECT count(*) FROM operations_sale")
        assert cursor.fetchone()[0] == 0
        cursor.execute("SELECT count(*) FROM operations_saleline")
        assert cursor.fetchone()[0] == 0
    assert Sale.objects.filter(pk=sale.pk).exists()


PHASE_TABLES = (
    "tenancy_invitation",
    "tenancy_notificationpreference",
    "operations_reminder",
    "operations_exportjob",
    "operations_attachment",
)


@pytest.fixture
def phase_rows(two_tenants):
    """One row per Phase 2-4 table in each tenant."""
    from datetime import timedelta

    from django.utils import timezone

    from apps.catalog.models import Party
    from apps.operations.models import Attachment, ExportJob, Reminder
    from apps.tenancy.models import Invitation, NotificationPreference

    users, businesses = two_tenants
    parties = {}
    for user, business in zip(users, businesses, strict=True):
        location = business.locations.get()
        party = Party.objects.create(business=business, name="RLS party", kind="CUSTOMER")
        parties[business.pk] = party
        Invitation.objects.create(
            business=business,
            phone_e164="+910000000000",
            role="CASHIER",
            invited_by=user,
            expires_at=timezone.now() + timedelta(days=7),
        )
        NotificationPreference.objects.create(business=business, user=user)
        Reminder.objects.create(
            business=business,
            location=location,
            party=party,
            channel="SHARE",
            message="RLS reminder",
            requested_by=user,
        )
        ExportJob.objects.create(
            business=business, requested_by=user, report="sales", format="CSV", params={}
        )
        Attachment.objects.create(
            business=business, kind="upload-photo", uploaded_by=user, status="READY"
        )
    return users, businesses, parties


@requires_postgres
def test_phase_tables_are_fail_closed_without_scope(phase_rows, app_connection):
    with app_connection.cursor() as cursor:
        for table in PHASE_TABLES:
            cursor.execute(f"SELECT count(*) FROM {table}")
            assert cursor.fetchone()[0] == 0, table


@requires_postgres
def test_phase_tables_show_only_scoped_business(phase_rows, app_connection):
    users, businesses, _ = phase_rows
    rls.set_tenant_scope(app_connection, user_id=users[0].pk, business_ids=[str(businesses[0].pk)])
    with app_connection.cursor() as cursor:
        for table in PHASE_TABLES:
            cursor.execute(f"SELECT count(*) FROM {table}")
            assert cursor.fetchone()[0] == 1, table
            cursor.execute(
                f"SELECT count(*) FROM {table} WHERE business_id = %s",
                [str(businesses[1].pk)],
            )
            assert cursor.fetchone()[0] == 0, table


@requires_postgres
def test_phase_table_cross_tenant_write_is_rejected(phase_rows, app_connection):
    """Copy a valid in-scope reminder row; retargeting it must fail at the DB."""
    users, businesses, parties = phase_rows
    rls.set_tenant_scope(app_connection, user_id=users[0].pk, business_ids=[str(businesses[0].pk)])
    with app_connection.cursor() as cursor:
        cursor.execute("SELECT * FROM operations_reminder LIMIT 1")
        columns = [column[0] for column in cursor.description]
        template = cursor.fetchone()
        assert template is not None
        values = dict(zip(columns, template, strict=True))
        values["id"] = str(uuid.uuid4())
        values["business_id"] = str(businesses[1].pk)
        values["party_id"] = str(parties[businesses[1].pk].pk)
        placeholders = ", ".join(["%s"] * len(columns))
        with pytest.raises(DatabaseError, match="row-level security policy"):
            cursor.execute(
                f"INSERT INTO operations_reminder ({', '.join(columns)}) VALUES ({placeholders})",
                [values[column] for column in columns],
            )


@requires_postgres
def test_phase_table_scoped_write_succeeds(phase_rows, app_connection):
    """The app role keeps its grants on new tables: in-scope writes work."""
    users, businesses, parties = phase_rows
    rls.set_tenant_scope(app_connection, user_id=users[0].pk, business_ids=[str(businesses[0].pk)])
    with app_connection.cursor() as cursor:
        cursor.execute("SELECT * FROM operations_reminder LIMIT 1")
        columns = [column[0] for column in cursor.description]
        template = cursor.fetchone()
        values = dict(zip(columns, template, strict=True))
        values["id"] = str(uuid.uuid4())
        placeholders = ", ".join(["%s"] * len(columns))
        cursor.execute(
            f"INSERT INTO operations_reminder ({', '.join(columns)}) VALUES ({placeholders})",
            [values[column] for column in columns],
        )
        cursor.execute("SELECT count(*) FROM operations_reminder")
        assert cursor.fetchone()[0] == 2
