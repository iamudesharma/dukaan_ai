from django.shortcuts import get_object_or_404
from rest_framework.exceptions import PermissionDenied

from .models import Business, Location, Membership


def require_membership(user, business_id, *, roles=None, location_id=None) -> Membership:
    business = get_object_or_404(Business, pk=business_id, is_active=True)
    try:
        membership = Membership.objects.select_related("business").get(
            user=user,
            business=business,
            is_active=True,
        )
    except Membership.DoesNotExist:
        raise PermissionDenied("You do not have access to this business") from None

    if roles and membership.role not in roles:
        raise PermissionDenied("Your role cannot perform this action")
    if location_id:
        location = get_object_or_404(Location, pk=location_id, business=business, is_active=True)
        if (
            membership.role != Membership.Role.OWNER
            and not membership.locations.filter(pk=location.pk).exists()
        ):
            raise PermissionDenied("You do not have access to this location")
    return membership


def is_cashier(user, business_id) -> bool:
    """Whether the verified user has an active cashier membership.

    Serializers use this as a fallback when they are invoked outside a scoped
    viewset. ViewSets pass their already-loaded membership in serializer context
    to avoid one role lookup per product/pack.
    """
    return Membership.objects.filter(
        user=user,
        business_id=business_id,
        role=Membership.Role.CASHIER,
        is_active=True,
    ).exists()


def accessible_location_ids(membership: Membership):
    if membership.role == Membership.Role.OWNER:
        return Location.objects.filter(business=membership.business, is_active=True).values_list(
            "id", flat=True
        )
    return membership.locations.filter(is_active=True).values_list("id", flat=True)
