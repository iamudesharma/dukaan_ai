import uuid

from django.shortcuts import get_object_or_404
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.pagination import StandardResultsPagination
from apps.tenancy.access import require_membership
from apps.tenancy.models import Membership

from .models import ImportJob
from .serializers import (
    ImportConfirmResponseSerializer,
    ImportConfirmSerializer,
    ImportDryRunSerializer,
    ImportJobListSerializer,
    ImportJobSerializer,
    ImportUploadSerializer,
)
from .services import IMPORT_ROLES, confirm_import, create_import_job


class ImportUploadView(APIView):
    parser_classes = [MultiPartParser, FormParser]
    permission_classes = [IsAuthenticated]
    kind = ImportJob.Kind.PRODUCT

    @extend_schema(
        summary="Upload a CSV for validation or import",
        description=(
            "Set dry_run=true to return a validation and duplicate-action preview without writes."
        ),
        request=ImportUploadSerializer,
        responses={200: ImportDryRunSerializer, 201: ImportJobSerializer},
    )
    def post(self, request):
        serializer = ImportUploadSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated = serializer.validated_data
        job, dry_run = create_import_job(
            actor=request.user,
            kind=self.kind,
            business_id=validated["business_id"],
            uploaded=validated["file"],
            dry_run=validated["dry_run"],
            duplicate_strategy=validated["duplicate_strategy"],
        )
        if dry_run is not None:
            return Response(dry_run, status=status.HTTP_200_OK)
        return Response(ImportJobSerializer(job).data, status=status.HTTP_201_CREATED)


class ProductImportUploadView(ImportUploadView):
    kind = ImportJob.Kind.PRODUCT


class PartyImportUploadView(ImportUploadView):
    kind = ImportJob.Kind.PARTY


class ImportJobListView(APIView):
    permission_classes = [IsAuthenticated]
    pagination_class = StandardResultsPagination

    @extend_schema(
        operation_id="imports_list",
        summary="List import jobs for a business",
        parameters=[
            OpenApiParameter(
                name="business_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=True,
            )
        ],
        responses=ImportJobListSerializer,
    )
    def get(self, request):
        raw_business_id = request.query_params.get("business_id")
        if not raw_business_id:
            return Response(
                {"error": {"code": "validation_error", "detail": "business_id is required."}},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            business_id = str(uuid.UUID(raw_business_id))
        except (AttributeError, TypeError, ValueError):
            return Response(
                {
                    "error": {
                        "code": "validation_error",
                        "detail": {"business_id": "Enter a valid UUID."},
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        require_membership(request.user, business_id, roles=IMPORT_ROLES)
        queryset = ImportJob.objects.filter(business_id=business_id).order_by("-created_at")
        paginator = self.pagination_class()
        page = paginator.paginate_queryset(queryset, request, view=self)
        serializer = ImportJobSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class ImportJobDetailView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        operation_id="imports_retrieve",
        summary="Get an import job",
        responses=ImportJobSerializer,
    )
    def get(self, request, job_id):
        job = _accessible_job(request, job_id)
        return Response(ImportJobSerializer(job).data)


class ImportConfirmView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        operation_id="imports_confirm_create",
        summary="Confirm and apply a validated import",
        request=ImportConfirmSerializer,
        parameters=[
            OpenApiParameter(
                name="Idempotency-Key",
                type=str,
                location=OpenApiParameter.HEADER,
                required=False,
                description=(
                    "Optional retry key; must match idempotency_key when both are supplied."
                ),
            )
        ],
        responses=ImportConfirmResponseSerializer,
    )
    def post(self, request, job_id):
        job = _accessible_job(request, job_id)
        serializer = ImportConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        body_key = serializer.validated_data.get("idempotency_key", "")
        header_key = request.headers.get("Idempotency-Key", "").strip()
        if len(header_key) > 128:
            return Response(
                {
                    "error": {
                        "code": "validation_error",
                        "detail": "Idempotency-Key must be at most 128 characters.",
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        if body_key and header_key and body_key != header_key:
            return Response(
                {
                    "error": {
                        "code": "validation_error",
                        "detail": "Idempotency-Key header and body value must match.",
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        key = body_key or header_key or f"import-{job.pk}"
        confirmed, replayed = confirm_import(
            job_id=job.pk,
            actor=request.user,
            idempotency_key=key,
        )
        response = Response(
            {"job": ImportJobSerializer(confirmed).data, "replayed": replayed},
            status=status.HTTP_200_OK,
        )
        response.headers["Idempotent-Replay"] = str(replayed).lower()
        return response


def _accessible_job(request, job_id) -> ImportJob:
    job = get_object_or_404(ImportJob, pk=job_id)
    require_membership(
        request.user,
        job.business_id,
        roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
    )
    return job
