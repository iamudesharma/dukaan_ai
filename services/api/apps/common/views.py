import uuid

from django.db import connection
from django.http import JsonResponse
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework.permissions import AllowAny
from rest_framework.views import APIView

from .serializers import BootstrapSerializer, HealthSerializer, MeSerializer


class HealthView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    @extend_schema(
        summary="Check API process health",
        responses={200: HealthSerializer},
        auth=[],
    )
    def get(self, request):
        return JsonResponse({"status": "ok"})


class ReadyView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    @extend_schema(
        summary="Check database readiness",
        responses={200: HealthSerializer, 503: HealthSerializer},
        auth=[],
    )
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                cursor.fetchone()
        except Exception:
            return JsonResponse({"status": "unavailable"}, status=503)
        return JsonResponse({"status": "ready"})


class MeView(APIView):
    @extend_schema(summary="Get the current user and memberships", responses=MeSerializer)
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


class BootstrapView(APIView):
    @extend_schema(
        summary="Get the selected business bootstrap context",
        parameters=[
            OpenApiParameter(
                name="business_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=False,
                description="Business to select; defaults to the caller's first active membership.",
            )
        ],
        responses=BootstrapSerializer,
    )
    def get(self, request):
        from apps.common.exceptions import OnboardingRequired
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
            raise OnboardingRequired("Create a business to get started")
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
