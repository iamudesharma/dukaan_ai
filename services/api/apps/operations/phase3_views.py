"""Phase 3 views: activity feed, reminders, async exports, invoice PDFs."""

from django.db import transaction
from django.db.models import Q, Sum
from django.http import FileResponse
from django.utils import timezone
from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework.exceptions import NotFound, ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.catalog.models import Party
from apps.tenancy.access import accessible_location_ids, require_membership
from apps.tenancy.models import (
    AuditEvent,
    Business,
    IdempotencyRecord,
    Location,
    Membership,
    OutboxEvent,
)

from .models import Attachment, ExportJob, Reminder, Sale
from .phase3_serializers import (
    ActivitySerializer,
    AttachmentSerializer,
    ExportCreateSerializer,
    ExportJobSerializer,
    ReminderCreateSerializer,
    ReminderSerializer,
)
from .reports import MANAGER_REPORTS

# Activity kind groups map UI filter chips to event_type prefixes.
KIND_GROUPS = {
    "transactions": ("sale.", "purchase.", "payment.", "expense.", "transfer.", "stock.", "party."),
    "team": ("membership.", "invitation.", "auth."),
    "assistant": ("assistant.",),
}


def _manager_of(request, business_id):
    return require_membership(
        request.user, business_id, roles=[Membership.Role.OWNER, Membership.Role.MANAGER]
    )


def _member_or_404(request, business_id):
    """Membership check for single-object reads: hide existence across tenants."""
    from rest_framework.exceptions import PermissionDenied

    try:
        return require_membership(request.user, business_id)
    except PermissionDenied as exc:
        raise NotFound("Not found") from exc


class ActivityView(APIView):
    """Newest-first audit feed over append-only AuditEvent."""

    @extend_schema(
        parameters=[
            OpenApiParameter("business_id", OpenApiTypes.UUID, required=True),
            OpenApiParameter("kind", OpenApiTypes.STR, required=False),
            OpenApiParameter("location_id", OpenApiTypes.UUID, required=False),
        ],
        tags=["activity"],
    )
    def get(self, request):
        business_id = request.query_params.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        membership = _manager_of(request, business_id)
        events = AuditEvent.objects.filter(business_id=business_id).select_related("actor")
        location_id = request.query_params.get("location_id")
        if location_id:
            require_membership(request.user, business_id, location_id=location_id)
            events = events.filter(location_id=location_id)
        else:
            events = events.filter(location_id__in=list(accessible_location_ids(membership)))
        kind = request.query_params.get("kind")
        if kind and kind != "all":
            prefixes = KIND_GROUPS.get(kind, (kind,))
            query = None
            from django.db.models import Q

            for prefix in prefixes:
                clause = Q(event_type__startswith=prefix)
                query = clause if query is None else query | clause
            events = events.filter(query)
        actor = request.query_params.get("actor")
        if actor:
            events = events.filter(actor_id=actor)
        start = request.query_params.get("from")
        end = request.query_params.get("to")
        if start:
            events = events.filter(created_at__date__gte=start)
        if end:
            events = events.filter(created_at__date__lte=end)
        try:
            limit = min(int(request.query_params.get("limit", 50)), 200)
            offset = max(int(request.query_params.get("offset", 0)), 0)
        except ValueError:
            raise ValidationError("limit/offset must be integers") from None
        total = events.count()
        rows = list(events.order_by("-created_at")[offset : offset + limit])
        payload = [
            {
                "id": str(event.pk),
                "event_type": event.event_type,
                "aggregate_type": event.aggregate_type,
                "aggregate_id": str(event.aggregate_id),
                "actor_id": str(event.actor_id) if event.actor_id else None,
                "actor_name": (
                    (event.actor.display_name or event.actor.username) if event.actor else None
                ),
                "location_id": str(event.location_id) if event.location_id else None,
                "source": event.source,
                "metadata": event.metadata or {},
                "created_at": event.created_at,
            }
            for event in rows
        ]
        return Response({"results": ActivitySerializer(payload, many=True).data, "count": total})


def _reminder_message(*, party_name: str, business_name: str, amount_minor: int) -> str:
    rupees = amount_minor / 100
    return (
        f"Namaste {party_name}, Rs {rupees:,.2f} is due at {business_name}. "
        "Please pay at your convenience. Thank you!"
    )


class ReminderListCreateView(APIView):
    def get(self, request):
        business_id = request.query_params.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        require_membership(request.user, business_id)
        reminders = Reminder.objects.filter(business_id=business_id).select_related("party")
        status_value = request.query_params.get("status")
        if status_value:
            reminders = reminders.filter(status=status_value)
        reminders = reminders.order_by("-created_at")[:200]
        return Response(ReminderSerializer(reminders, many=True).data)

    @extend_schema(
        request=ReminderCreateSerializer, responses=ReminderSerializer, tags=["reminders"]
    )
    @transaction.atomic
    def post(self, request):
        serializer = ReminderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        business_id = str(data["business_id"])
        membership = require_membership(request.user, business_id)
        party = data["party_id"]
        if str(party.business_id) != business_id:
            raise ValidationError("Party does not belong to the business")
        channel = data.get("channel") or Reminder.Channel.SHARE
        if channel != Reminder.Channel.SHARE and not (party.phone_e164 or "").strip():
            raise ValidationError("This party has no phone number; use manual share instead")
        location = None
        location_id = data.get("location_id")
        if location_id:
            require_membership(request.user, business_id, location_id=str(location_id))
            location = Location.objects.filter(pk=location_id, business_id=business_id).first()
            if location is None:
                raise ValidationError("Unknown location")
        else:
            location_ids = list(accessible_location_ids(membership))
            location = Location.objects.filter(pk__in=location_ids, business_id=business_id).first()
        idempotency_key = request.data.get("idempotency_key") or request.headers.get(
            "Idempotency-Key"
        )
        if idempotency_key:
            existing = IdempotencyRecord.objects.filter(
                business_id=business_id,
                actor=request.user,
                scope="reminder.post",
                key=idempotency_key,
            ).first()
            if existing:
                reminder = Reminder.objects.get(pk=existing.result_id)
                return Response(ReminderSerializer(reminder).data, status=200)
        due = (
            party.ledger_entries.filter(business_id=business_id).aggregate(v=Sum("amount_minor"))[
                "v"
            ]
            or 0
        )
        business = Business.objects.get(pk=business_id)
        message = (data.get("message") or "").strip() or _reminder_message(
            party_name=party.name, business_name=business.name, amount_minor=due
        )
        reminder = Reminder.objects.create(
            business=business,
            location=location,
            party=party,
            channel=channel,
            message=message,
            amount_minor=due,
            status=Reminder.Status.PENDING,
            requested_by=request.user,
        )
        OutboxEvent.objects.get_or_create(
            dedupe_key=f"reminder.send:{reminder.pk}",
            defaults={
                "business": business,
                "topic": "reminder.send",
                "payload": {"reminder_id": str(reminder.pk)},
                "available_at": timezone.now(),
            },
        )
        if idempotency_key:
            IdempotencyRecord.objects.create(
                business=business,
                actor=request.user,
                scope="reminder.post",
                key=idempotency_key,
                result_type="operations.reminder",
                result_id=reminder.pk,
            )
        replayed = False
        return Response(
            ReminderSerializer(reminder).data,
            status=201,
            headers={"Idempotent-Replay": str(replayed).lower()},
        )


class ReminderDetailView(APIView):
    def get(self, request, pk):
        try:
            reminder = Reminder.objects.select_related("party").get(pk=pk)
        except Reminder.DoesNotExist:
            raise NotFound("Reminder not found") from None
        _member_or_404(request, str(reminder.business_id))
        return Response(ReminderSerializer(reminder).data)


class ReminderSuggestionsView(APIView):
    """Computed follow-ups: overdue receivables first, then low stock."""

    def get(self, request):
        business_id = request.query_params.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        membership = require_membership(request.user, business_id)
        location_ids = list(accessible_location_ids(membership))
        suggestions = []
        dues = (
            Party.objects.filter(business_id=business_id, is_active=True)
            .annotate(
                balance=Sum(
                    "ledger_entries__amount_minor",
                    filter=Q(ledger_entries__location_id__in=location_ids),
                )
            )
            .filter(balance__gt=0)
            .order_by("-balance")[:10]
        )
        business = Business.objects.get(pk=business_id)
        for party in dues:
            balance = int(party.balance or 0)
            suggestions.append(
                {
                    "type": "OVERDUE",
                    "party_id": str(party.pk),
                    "party_name": party.name,
                    "amount_minor": balance,
                    "message": _reminder_message(
                        party_name=party.name,
                        business_name=business.name,
                        amount_minor=balance,
                    ),
                }
            )
        return Response({"results": suggestions})


class ExportListCreateView(APIView):
    def get(self, request):
        business_id = request.query_params.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        require_membership(request.user, business_id)
        jobs = ExportJob.objects.filter(business_id=business_id).order_by("-created_at")[:100]
        return Response(ExportJobSerializer(jobs, many=True).data)

    @extend_schema(request=ExportCreateSerializer, responses=ExportJobSerializer, tags=["exports"])
    @transaction.atomic
    def post(self, request):
        serializer = ExportCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        business_id = str(data["business_id"])
        membership = require_membership(request.user, business_id)
        if data["report"] in MANAGER_REPORTS:
            require_membership(
                request.user,
                business_id,
                roles=[Membership.Role.OWNER, Membership.Role.MANAGER],
            )
        business = Business.objects.get(pk=business_id)
        location_ids = list(accessible_location_ids(membership))
        if data.get("location_id"):
            require_membership(request.user, business_id, location_id=str(data["location_id"]))
            location_ids = [str(data["location_id"])]
        idempotency_key = request.data.get("idempotency_key") or request.headers.get(
            "Idempotency-Key"
        )
        if idempotency_key:
            existing = IdempotencyRecord.objects.filter(
                business_id=business_id,
                actor=request.user,
                scope="export.post",
                key=idempotency_key,
            ).first()
            if existing:
                job = ExportJob.objects.get(pk=existing.result_id)
                return Response(ExportJobSerializer(job).data, status=200)
        params = {
            "location_ids": [str(value) for value in location_ids],
            "group_by": data.get("group_by") or "day",
        }
        if data.get("location_id"):
            params["location_id"] = str(data["location_id"])
        if data.get("from_date"):
            params["from"] = str(data["from_date"])
        if data.get("to_date"):
            params["to"] = str(data["to_date"])
        job = ExportJob.objects.create(
            business=business,
            requested_by=request.user,
            report=data["report"],
            format=data["format"],
            params=params,
        )
        OutboxEvent.objects.get_or_create(
            dedupe_key=f"export.run:{job.pk}",
            defaults={
                "business": business,
                "topic": "export.run",
                "payload": {"export_id": str(job.pk)},
                "available_at": timezone.now(),
            },
        )
        if idempotency_key:
            IdempotencyRecord.objects.create(
                business=business,
                actor=request.user,
                scope="export.post",
                key=idempotency_key,
                result_type="operations.exportjob",
                result_id=job.pk,
            )
        return Response(ExportJobSerializer(job).data, status=202)


class ExportDetailView(APIView):
    def get(self, request, pk):
        try:
            job = ExportJob.objects.get(pk=pk)
        except ExportJob.DoesNotExist:
            raise NotFound("Export not found") from None
        _member_or_404(request, str(job.business_id))
        if (
            request.query_params.get("download")
            and job.status == ExportJob.Status.READY
            and job.file
        ):
            content_type = (
                "text/csv; charset=utf-8"
                if job.format == ExportJob.Format.CSV
                else "application/pdf"
            )
            suffix = "csv" if job.format == ExportJob.Format.CSV else "pdf"
            return FileResponse(
                job.file.open("rb"),
                content_type=content_type,
                as_attachment=True,
                filename=f"{job.report}-{job.pk}.{suffix}",
            )
        return Response(ExportJobSerializer(job).data)


class SaleInvoiceView(APIView):
    """Get-or-create the invoice PDF for a posted sale (idempotent)."""

    @extend_schema(responses=AttachmentSerializer, tags=["attachments"])
    @transaction.atomic
    def post(self, request, pk):
        try:
            sale = Sale.objects.select_related("business").get(pk=pk)
        except Sale.DoesNotExist:
            raise NotFound("Sale not found") from None
        require_membership(request.user, str(sale.business_id))
        attachment, created = Attachment.objects.get_or_create(
            business=sale.business,
            kind="sale-invoice",
            sale=sale,
            defaults={"status": Attachment.Status.PENDING},
        )
        if created:
            OutboxEvent.objects.get_or_create(
                dedupe_key=f"invoice.generate:{attachment.pk}",
                defaults={
                    "business": sale.business,
                    "topic": "invoice.generate",
                    "payload": {"attachment_id": str(attachment.pk)},
                    "available_at": timezone.now(),
                },
            )
            return Response(AttachmentSerializer(attachment).data, status=202)
        return Response(AttachmentSerializer(attachment).data, status=200)


class AttachmentDetailView(APIView):
    def get(self, request, pk):
        try:
            attachment = Attachment.objects.get(pk=pk)
        except Attachment.DoesNotExist:
            raise NotFound("Attachment not found") from None
        _member_or_404(request, str(attachment.business_id))
        if (
            request.query_params.get("download")
            and attachment.status == Attachment.Status.READY
            and attachment.file
        ):
            filename = (
                attachment.original_name or f"invoice-{attachment.sale_id or attachment.pk}.pdf"
            )
            return FileResponse(
                attachment.file.open("rb"),
                content_type=attachment.mime_type or "application/pdf",
                as_attachment=True,
                filename=filename,
            )
        from .phase3_serializers import AttachmentSerializer as _Serializer

        return Response(_Serializer(attachment).data)
