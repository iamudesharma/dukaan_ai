from decimal import Decimal

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.catalog.models import Product, ProductPack
from apps.common.models import User
from apps.operations.models import StockBalance, StockMovement
from apps.tenancy.models import Business, Location, Membership


class Command(BaseCommand):
    help = "Create a local-only demo shop and opening inventory, safely on repeated runs."

    @transaction.atomic
    def handle(self, *args, **options):
        from django.db import connection

        from apps.tenancy import rls

        if not settings.DEBUG or not settings.DEV_AUTH_ENABLED:
            raise CommandError("Demo seed requires DEBUG and DEV_AUTH_ENABLED")
        # Seeding runs outside any request scope; operate as the privileged
        # local operator so FORCE RLS does not hide the rows being built.
        rls.set_staff_scope(connection)
        user, _ = User.objects.get_or_create(username="dukaan-demo-owner")
        membership = Membership.objects.filter(user=user, role="OWNER").first()
        if membership:
            business = membership.business
        else:
            business = Business.objects.create(name="Sharma Garments")
            Membership.objects.create(user=user, business=business, role="OWNER")
        location, _ = Location.objects.get_or_create(
            business=business, code="MAIN", defaults={"name": "Main shop", "state_code": "07"}
        )
        product, _ = Product.objects.get_or_create(
            business=business, sku="SHIRT-001", defaults={"name": "shirt"}
        )
        pack, _ = ProductPack.objects.get_or_create(
            product=product,
            name="piece",
            defaults={
                "conversion_factor": Decimal("1"),
                "retail_price_minor": 80000,
                "wholesale_price_minor": 75000,
            },
        )
        balance, created = StockBalance.objects.get_or_create(
            business=business,
            location=location,
            product=product,
            defaults={"quantity": Decimal("20")},
        )
        if created:
            StockMovement.objects.create(
                business=business,
                location=location,
                product=product,
                pack=pack,
                movement_type="OPENING",
                quantity=balance.quantity,
                source_type="DEMO_SEED",
                source_id=balance.pk,
                occurred_at=timezone.now(),
            )
        self.stdout.write(f"Demo user: {user.pk}\nBusiness: {business.pk}\nLocation: {location.pk}")
