import pytest

from apps.catalog.models import Product, ProductPack
from apps.common.models import User
from apps.operations.models import StockBalance
from apps.tenancy import rls
from apps.tenancy.models import Business, Location, Membership


def rls_is_enforced(connection) -> bool:
    """Whether row-level security actually applies to the current connection.

    PostgreSQL exempts superusers and roles with BYPASSRLS before consulting any
    policy, so ``FORCE ROW LEVEL SECURITY`` does not bind them. The local and CI
    test databases are created by a superuser (``POSTGRES_USER``), and therefore
    run without RLS; assertions that depend on RLS must state that precondition
    rather than fail. The dedicated app-role connection in ``test_rls.py`` is
    not affected and always exercises the real policy.
    """
    if connection.vendor != "postgresql":
        return False
    with connection.cursor() as cursor:
        cursor.execute("SELECT rolsuper OR rolbypassrls FROM pg_roles WHERE rolname = current_user")
        row = cursor.fetchone()
    return not bool(row and row[0])


@pytest.fixture(autouse=True)
def hermetic_attachment_policy(settings):
    # Most worker/storage tests use the hermetic fake backend. Production
    # defaults require scanning; security-specific tests opt back into that
    # policy explicitly (see test_retention.py).
    settings.ATTACHMENT_QUARANTINE_REQUIRED = False


@pytest.fixture(autouse=True)
def hermetic_cache(settings):
    """Throttle counters stay in-process even when CI configures Redis."""
    settings.CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "dukaan-api-tests",
        }
    }
    from django.core.cache import cache

    cache.clear()
    yield
    cache.clear()


@pytest.fixture(autouse=True)
def tenant_scope(db):
    """Mirror production: FORCE RLS hides everything until the verified
    caller's scope is established on every request.

    Production establishes scope per request (DRF token auth during the
    view, session middleware before it). The test client's
    ``force_authenticate`` is one-shot, so the fixture hooks the per-request
    funnel instead and derives scope from the forced user exactly like the
    real auth class does: user from the verified identity, businesses from
    the membership table, nothing from client input."""
    from django.db import connection
    from rest_framework.test import APIClient

    rls.set_staff_scope(connection)
    original = APIClient.generic

    def generic(self, *args, **kwargs):
        user = getattr(getattr(self, "handler", None), "_force_user", None)
        if user is not None and getattr(user, "is_authenticated", False):
            rls.establish_scope(
                connection,
                user,
                subject=getattr(user, "supabase_user_id", None),
            )
        else:
            rls.clear_tenant_scope(connection)
        try:
            return original(self, *args, **kwargs)
        finally:
            # Requests clear scope when done (as in production). Direct ORM
            # between requests runs as the privileged test operator again.
            rls.set_staff_scope(connection)

    APIClient.generic = generic
    yield
    APIClient.generic = original
    rls.clear_tenant_scope(connection)


@pytest.fixture
def shop():
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
    StockBalance.objects.create(business=business, location=location, product=product, quantity=10)
    return user, business, location, product
