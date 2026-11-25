import uuid
from urllib.parse import urlencode

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import IntegrityError, transaction
from django.db.models import Q
from django.shortcuts import get_object_or_404, redirect
from django.utils import timezone
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.tenancy.access import require_membership
from apps.tenancy.models import AuditEvent, OutboxEvent

from .models import GmailConnection, GmailImport, NotificationDevice, Reminder
from .notifications import REMINDER_TOPIC, schedule_reminder
from .serializers import (
    GmailConnectSerializer,
    GmailImportResultSerializer,
    GmailImportSerializer,
    GmailImportsSerializer,
    GmailMessagesSerializer,
    GmailStatusSerializer,
    NotificationDeviceRegistrationSerializer,
    NotificationDeviceSerializer,
    ReminderCreateSerializer,
    ReminderSerializer,
    ReminderUpdateSerializer,
)
from .services import (
    GmailError,
    authorization_url,
    complete_authorization,
    disconnect_gmail,
    import_message,
    list_messages,
    resolve_state,
)

User = get_user_model()


def _web_redirect(**params) -> redirect:
    base = getattr(settings, "GMAIL_WEB_REDIRECT_URL", "http://127.0.0.1:4173/settings")
    separator = "&" if "?" in base else "?"
    return redirect(f"{base}{separator}{urlencode(params)}")


class GmailStatusView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="Get the current user's Gmail connection status", responses=GmailStatusSerializer
    )
    def get(self, request):
        connection = GmailConnection.objects.filter(user=request.user).first()
        return Response(
            {
                "connected": connection is not None,
                "email": connection.email if connection else None,
            }
        )


class GmailConnectView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(summary="Start Gmail OAuth authorization", responses=GmailConnectSerializer)
    def get(self, request):
        try:
            return Response({"authorization_url": authorization_url(request.user)})
        except GmailError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class GmailCallbackView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []

    @extend_schema(
        summary="Complete Gmail OAuth authorization",
        parameters=[
            OpenApiParameter(name="code", type=str, required=False),
            OpenApiParameter(name="state", type=str, required=True),
            OpenApiParameter(name="error", type=str, required=False),
        ],
        responses={302: None},
        auth=[],
    )
    def get(self, request):
        if request.query_params.get("error"):
            return _web_redirect(gmail="denied")
        try:
            user_id = resolve_state(request.query_params.get("state", ""))
            user = User.objects.get(pk=user_id, is_active=True)
            complete_authorization(request.query_params.get("code", ""), user)
        except (GmailError, User.DoesNotExist):
            return _web_redirect(gmail="error")
        return _web_redirect(gmail="connected")


class GmailDisconnectView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(summary="Disconnect the current user's Gmail account", responses={204: None})
    def delete(self, request):
        disconnect_gmail(request.user)
        return Response(status=status.HTTP_204_NO_CONTENT)


class GmailMessagesView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="List recent financial Gmail messages",
        parameters=[
            OpenApiParameter(
                name="max_results",
                type=int,
                location=OpenApiParameter.QUERY,
                required=False,
                description="Clamped to 1-50; invalid values default to 20.",
            )
        ],
        responses=GmailMessagesSerializer,
    )
    def get(self, request):
        try:
            max_results = int(request.query_params.get("max_results", "20"))
        except ValueError:
            max_results = 20
        try:
            messages = list_messages(request.user, max_results=max_results)
        except GmailError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_502_BAD_GATEWAY)
        return Response(
            {
                "results": [
                    {
                        "id": message.id,
                        "subject": message.subject,
                        "snippet": message.snippet,
                        "received_at": message.received_at,
                    }
                    for message in messages
                ]
            }
        )


class GmailImportView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="Extract a reviewable financial fact from one Gmail message",
        request=GmailImportSerializer,
        responses={201: GmailImportResultSerializer},
    )
    def post(self, request):
        serializer = GmailImportSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        business = serializer.validated_data["business"]
        location = serializer.validated_data["location"]
        require_membership(request.user, business.id, location_id=location.id)
        try:
            record = import_message(
                user=request.user,
                business=business,
                location=location,
                message_id=serializer.validated_data["message_id"],
            )
        except GmailError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_502_BAD_GATEWAY)
        return Response(GmailImportResultSerializer(record).data, status=status.HTTP_201_CREATED)


class GmailImportsView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="List Gmail financial facts for a business",
        parameters=[
            OpenApiParameter(
                name="business_id",
                type=uuid.UUID,
                location=OpenApiParameter.QUERY,
                required=True,
            )
        ],
        responses=GmailImportsSerializer,
    )
    def get(self, request):
        business_id = request.query_params.get("business_id")
        if not business_id:
            return Response(
                {"detail": "business_id is required"}, status=status.HTTP_400_BAD_REQUEST
            )
        require_membership(request.user, business_id)
        records = GmailImport.objects.filter(business_id=business_id).order_by("-created_at")[:50]
        return Response({"results": GmailImportResultSerializer(records, many=True).data})


def _notification_audit(request, *, business, location, event_type, aggregate_id, metadata=None):
    AuditEvent.objects.create(
        business=business,
        location=location,
        actor=request.user,
        event_type=event_type,
        aggregate_type="integrations.notification",
        aggregate_id=aggregate_id,
        source="API",
        metadata=metadata or {},
    )


class NotificationDeviceListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="List the current user's notification devices",
        responses=NotificationDeviceSerializer(many=True),
    )
    def get(self, request):
        devices = (
            NotificationDevice.objects.filter(
                user=request.user,
                business__is_active=True,
                business__memberships__user=request.user,
                business__memberships__is_active=True,
            )
            .distinct()
            .order_by("-created_at")
        )
        return Response(NotificationDeviceSerializer(devices, many=True).data)

    @extend_schema(
        summary="Register or refresh a notification device",
        request=NotificationDeviceRegistrationSerializer,
        responses={200: NotificationDeviceSerializer, 201: NotificationDeviceSerializer},
    )
    @transaction.atomic
    def post(self, request):
        serializer = NotificationDeviceRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        business = serializer.validated_data["business"]
        location = serializer.validated_data.get("location")
        require_membership(
            request.user,
            business.id,
            location_id=location.id if location is not None else None,
        )
        now = timezone.now()
        token = serializer.validated_data["fcm_token"]
        existing = NotificationDevice.objects.filter(fcm_token=token).first()
        if existing is not None and existing.user_id != request.user.id:
            return Response(
                {"detail": "This notification token is already registered."},
                status=status.HTTP_409_CONFLICT,
            )
        try:
            with transaction.atomic():
                device, created = NotificationDevice.objects.update_or_create(
                    fcm_token=token,
                    defaults={
                        "user": request.user,
                        "business": business,
                        "location": location,
                        "platform": serializer.validated_data["platform"],
                        "status": NotificationDevice.Status.ACTIVE,
                        "last_seen_at": now,
                        "unregistered_at": None,
                        "metadata": serializer.validated_data.get("metadata", {}),
                    },
                )
        except IntegrityError:
            # A token owned by a different tenant can be hidden by RLS while
            # still conflicting with the global uniqueness constraint.
            return Response(
                {"detail": "This notification token is already registered."},
                status=status.HTTP_409_CONFLICT,
            )
        _notification_audit(
            request,
            business=business,
            location=location,
            event_type="notification.device_registered",
            aggregate_id=device.id,
            metadata={"platform": device.platform, "replayed": not created},
        )
        return Response(
            NotificationDeviceSerializer(device).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )


class NotificationDeviceUnregisterView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="Disable a notification device",
        responses={204: None},
    )
    @transaction.atomic
    def delete(self, request, device_id):
        device = get_object_or_404(NotificationDevice, pk=device_id, user=request.user)
        require_membership(
            request.user,
            device.business_id,
            location_id=device.location_id,
        )
        if device.status == NotificationDevice.Status.ACTIVE:
            device.status = NotificationDevice.Status.DISABLED
            device.unregistered_at = timezone.now()
            device.save(update_fields=["status", "unregistered_at", "updated_at"])
        _notification_audit(
            request,
            business=device.business,
            location=device.location,
            event_type="notification.device_unregistered",
            aggregate_id=device.id,
        )
        return Response(status=status.HTTP_204_NO_CONTENT)


class ReminderListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        operation_id="notifications_reminders_list",
        summary="List the current user's reminders",
        responses=ReminderSerializer(many=True),
    )
    def get(self, request):
        reminders = (
            Reminder.objects.filter(
                user=request.user,
                business__is_active=True,
                business__memberships__user=request.user,
                business__memberships__is_active=True,
            )
            .filter(
                Q(business__memberships__role="OWNER")
                | Q(
                    location__memberships__user=request.user,
                    location__memberships__is_active=True,
                )
                | Q(location__isnull=True)
            )
            .distinct()
            .order_by("scheduled_at", "-created_at")[:100]
        )
        return Response(ReminderSerializer(reminders, many=True).data)

    @extend_schema(
        operation_id="notifications_reminders_create",
        summary="Schedule a durable reminder",
        request=ReminderCreateSerializer,
        responses={200: ReminderSerializer, 201: ReminderSerializer},
    )
    @transaction.atomic
    def post(self, request):
        serializer = ReminderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        business = serializer.validated_data["business"]
        location = serializer.validated_data.get("location")
        require_membership(
            request.user,
            business.id,
            location_id=location.id if location is not None else None,
        )
        reminder, created = schedule_reminder(
            user=request.user,
            business=business,
            location=location,
            title=serializer.validated_data["title"],
            body=serializer.validated_data["body"],
            scheduled_at=serializer.validated_data["scheduled_at"],
            dedupe_key=serializer.validated_data.get("dedupe_key") or str(uuid.uuid4()),
            data=serializer.validated_data.get("data", {}),
            metadata={"source": "API"},
        )
        if created:
            _notification_audit(
                request,
                business=business,
                location=location,
                event_type="notification.reminder_created",
                aggregate_id=reminder.id,
                metadata={"scheduled_at": reminder.scheduled_at.isoformat()},
            )
        return Response(
            ReminderSerializer(reminder).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )


class ReminderDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get_object(self, request, reminder_id):
        reminder = get_object_or_404(Reminder, pk=reminder_id, user=request.user)
        require_membership(
            request.user,
            reminder.business_id,
            location_id=reminder.location_id,
        )
        return reminder

    @extend_schema(
        operation_id="notifications_reminders_retrieve",
        summary="Get a scheduled reminder",
        responses=ReminderSerializer,
    )
    def get(self, request, reminder_id):
        return Response(ReminderSerializer(self.get_object(request, reminder_id)).data)

    @extend_schema(
        operation_id="notifications_reminders_update",
        summary="Update a scheduled reminder",
        request=ReminderUpdateSerializer,
        responses=ReminderSerializer,
    )
    @transaction.atomic
    def patch(self, request, reminder_id):
        reminder = Reminder.objects.select_for_update().get(
            pk=self.get_object(request, reminder_id).pk
        )
        if reminder.status != Reminder.Status.SCHEDULED:
            return Response(
                {"detail": "Only scheduled reminders can be updated"},
                status=status.HTTP_409_CONFLICT,
            )
        serializer = ReminderUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        event = (
            OutboxEvent.objects.select_for_update()
            .filter(dedupe_key=f"reminder:{reminder.id}")
            .first()
        )
        if event is not None and event.status != OutboxEvent.Status.PENDING:
            return Response(
                {"detail": "Reminder delivery has already started"},
                status=status.HTTP_409_CONFLICT,
            )
        for field, value in serializer.validated_data.items():
            setattr(reminder, field, value)
        reminder.save(update_fields=[*serializer.validated_data, "updated_at"])
        if event is None:
            OutboxEvent.objects.create(
                business=reminder.business,
                topic=REMINDER_TOPIC,
                dedupe_key=f"reminder:{reminder.id}",
                payload={"reminder_id": str(reminder.id)},
                available_at=reminder.scheduled_at,
            )
        else:
            event.available_at = reminder.scheduled_at
            event.save(update_fields=["available_at", "updated_at"])
        _notification_audit(
            request,
            business=reminder.business,
            location=reminder.location,
            event_type="notification.reminder_updated",
            aggregate_id=reminder.id,
            metadata={"scheduled_at": reminder.scheduled_at.isoformat()},
        )
        return Response(ReminderSerializer(reminder).data)

    @extend_schema(
        operation_id="notifications_reminders_destroy",
        summary="Cancel a scheduled reminder",
        responses={204: None},
    )
    @transaction.atomic
    def delete(self, request, reminder_id):
        reminder = Reminder.objects.select_for_update().get(
            pk=self.get_object(request, reminder_id).pk
        )
        if reminder.status != Reminder.Status.SCHEDULED:
            return Response(
                {"detail": "Only scheduled reminders can be cancelled"},
                status=status.HTTP_409_CONFLICT,
            )
        reminder.status = Reminder.Status.CANCELLED
        reminder.cancelled_at = timezone.now()
        reminder.save(update_fields=["status", "cancelled_at", "updated_at"])
        _notification_audit(
            request,
            business=reminder.business,
            location=reminder.location,
            event_type="notification.reminder_cancelled",
            aggregate_id=reminder.id,
        )
        return Response(status=status.HTTP_204_NO_CONTENT)
