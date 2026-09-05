import pytest

from apps.catalog.models import Product, ProductPack
from apps.common.models import User
from apps.operations.models import StockBalance
from apps.tenancy import rls
from apps.tenancy.models import Business, Location, Membership


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
