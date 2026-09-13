import json

from django.db import connection
from django.http import JsonResponse
from rest_framework.permissions import AllowAny
from rest_framework.views import APIView


class HealthView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, request):
        return JsonResponse({"status": "ok"})


class ReadyView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                cursor.fetchone()
        except Exception:
            return JsonResponse({"status": "unavailable"}, status=503)
        return JsonResponse({"status": "ready"})


class MeView(APIView):
    def get(self, request):
        memberships = request.user.memberships.filter(is_active=True).select_related("business")
        return JsonResponse(
            {
                "id": str(request.user.id),
                "phone": request.user.phone_e164,
                "display_name": request.user.display_name,
                "memberships": [
                    {
                        "business_id": str(m.business_id),
                        "business_name": m.business.name,
                        "role": m.role,
                    }
                    for m in memberships
                ],
            }
        )

    def patch(self, request):
        try:
            data = json.loads(request.body or "{}")
        except ValueError:
            return JsonResponse({"detail": "Invalid JSON."}, status=400)
        display_name = data.get("display_name", "")
        if not isinstance(display_name, str) or len(display_name) > 120:
            return JsonResponse(
                {"detail": "Display name must be at most 120 characters."}, status=400
            )
        request.user.display_name = display_name.strip()
        request.user.save(update_fields=["display_name"])
        return JsonResponse(
            {
                "id": str(request.user.id),
                "phone": request.user.phone_e164,
                "display_name": request.user.display_name,
            }
        )


class BootstrapView(APIView):
    def get(self, request):
        from rest_framework.exceptions import NotFound

        from apps.tenancy.access import accessible_location_ids, require_membership
        from apps.tenancy.models import Location

        memberships = (
            request.user.memberships.filter(is_active=True, business__is_active=True)
            .select_related("business")
            .order_by("created_at")
        )
        business_id = request.query_params.get("business_id")
        membership = (
            require_membership(request.user, business_id) if business_id else memberships.first()
        )
        if membership is None:
            raise NotFound("Create a business to get started", code="onboarding_required")
        business = membership.business
        locations = Location.objects.filter(pk__in=accessible_location_ids(membership))
        return JsonResponse(
            {
                "user": {
                    "id": str(request.user.pk),
                    "name": request.user.display_name or request.user.username,
                    "phone": request.user.phone_e164,
                    "role": membership.role,
                },
                "business": {
                    "id": str(business.pk),
                    "name": business.name,
                    "legal_name": business.legal_name,
                    "currency": business.currency,
                    "timezone": business.timezone,
                },
                "locations": [
                    {
                        "id": str(location.pk),
                        "name": location.name,
                        "code": location.code,
                        "state_code": location.state_code,
                    }
                    for location in locations
                ],
                "permissions": ["*"]
                if membership.role == "OWNER"
                else (
                    ["sales", "receipts", "stock", "customers"]
                    if membership.role == "CASHIER"
                    else ["operations", "reports"]
                ),
            }
        )
