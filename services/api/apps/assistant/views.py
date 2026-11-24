import uuid

from django.conf import settings
from django.db import transaction
from django.db.models import Q
from drf_spectacular.utils import OpenApiParameter, extend_schema, extend_schema_view
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import APIException, PermissionDenied, ValidationError
from rest_framework.response import Response

from apps.common.pagination import StandardResultsPagination
from apps.operations.models import Expense, Purchase
from apps.operations.serializers import (
    ExpenseSerializer,
    PurchaseSerializer,
    SaleSerializer,
)
from apps.tenancy.access import require_membership

from .models import AssistantProposal, Attachment
from .serializers import (
    AssistantProposalSerializer,
    AttachmentSerializer,
    CancelSerializer,
    ConfirmSerializer,
    FromAudioSerializer,
    FromImageSerializer,
    InterpretSerializer,
    PresignSerializer,
    ReviseSerializer,
)
from .services import confirm, interpret, revise
from .storage import IMAGE_MIMES, StorageError, get_storage_backend, storage_path_for
from .tasks import (
    READING_IMAGE_BLOCKER,
    TRANSCRIBING_BLOCKER,
    ocr_attachment,
    transcribe_attachment,
)

PROPOSAL_ID_PATH_PARAMETER = OpenApiParameter(
    name="id", type=uuid.UUID, location=OpenApiParameter.PATH, required=True
)


@extend_schema_view(retrieve=extend_schema(parameters=[PROPOSAL_ID_PATH_PARAMETER]))
class ProposalViewSet(mixins.ListModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    serializer_class = AssistantProposalSerializer
    pagination_class = StandardResultsPagination

    def get_queryset(self):
        return (
            AssistantProposal.objects.filter(
                actor=self.request.user,
                business__is_active=True,
                business__memberships__user=self.request.user,
                business__memberships__is_active=True,
            )
            .filter(
                Q(business__memberships__role="OWNER")
                | Q(
                    location__memberships__user=self.request.user,
                    location__memberships__is_active=True,
                )
            )
            .filter(location__is_active=True)
            .distinct()
            .order_by("-created_at")
        )

    def get_object(self):
        proposal = super().get_object()
        require_membership(
            self.request.user, proposal.business_id, location_id=proposal.location_id
        )
        return proposal

    @extend_schema(parameters=[PROPOSAL_ID_PATH_PARAMETER])
    @action(detail=True, methods=["post"])
    def revise(self, request, pk=None):
        proposal = self.get_object()
        serializer = ReviseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        result = revise(proposal=proposal, actor=request.user, **serializer.validated_data)
        return Response(AssistantProposalSerializer(result).data)

    @extend_schema(parameters=[PROPOSAL_ID_PATH_PARAMETER])
    @action(detail=True, methods=["get"])
    def revisions(self, request, pk=None):
        proposal = self.get_object()
        return Response(list(proposal.revisions.values("version", "snapshot", "created_at")))

    def create(self, request):
        serializer = InterpretSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        proposal = interpret(actor=request.user, **serializer.validated_data)
        return Response(AssistantProposalSerializer(proposal).data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=["post"], url_path="from-audio")
    @transaction.atomic
    def from_audio(self, request):
        """Create a voice proposal from an uploaded attachment and queue
        transcription. Returns immediately (201 for a new proposal, 200 for
        a reused open one); the client polls until the transcript lands.

        Client retries are safe: re-POSTing the same attachment returns the
        still-open proposal instead of minting duplicates, and the worker
        ignores redelivery after a transcript is stored.
        """
        from django.utils import timezone

        serializer = FromAudioSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        attachment = serializer.validated_data["attachment"]
        business = serializer.validated_data["business"]
        location = serializer.validated_data["location"]
        locale = serializer.validated_data["locale"]
        if attachment.kind != Attachment.Kind.VOICE:
            from rest_framework.exceptions import ValidationError

            raise ValidationError("Only voice attachments can start transcription")
        if attachment.business_id != business.id:
            from rest_framework.exceptions import ValidationError

            raise ValidationError("Attachment does not belong to this business")
        if attachment.owner_id != request.user.id:
            raise PermissionDenied("Only the uploader can transcribe this recording")
        require_membership(request.user, business.id, location_id=location.id)
        if location.business_id != business.id:
            from rest_framework.exceptions import ValidationError

            raise ValidationError("Location does not belong to the business")

        existing = attachment.proposal
        if (
            existing is not None
            and existing.actor_id == request.user.id
            and existing.business_id == business.id
            and existing.location_id == location.id
            and existing.status in {AssistantProposal.Status.DRAFT, AssistantProposal.Status.READY}
        ):
            proposal = existing
            created = False
        else:
            from datetime import timedelta

            proposal = AssistantProposal.objects.create(
                business=business,
                location=location,
                actor=request.user,
                input_type=AssistantProposal.InputType.VOICE,
                locale=locale,
                content="",
                command_type="UNSUPPORTED",
                payload={},
                preview="",
                warnings=[],
                blocking_questions=[TRANSCRIBING_BLOCKER],
                status=AssistantProposal.Status.DRAFT,
                expires_at=timezone.now() + timedelta(hours=24),
            )
            from .services import _record_revision

            _record_revision(proposal)
            attachment.proposal = proposal
            attachment.save(update_fields=["proposal", "updated_at"])
            created = True
        try:
            transcribe_attachment.delay(str(attachment.id))
        except Exception as exc:
            from rest_framework.exceptions import APIException

            raise APIException(
                "Transcription could not be queued. Please send the recording again."
            ) from exc
        return Response(
            AssistantProposalSerializer(proposal).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    @action(detail=False, methods=["post"], url_path="from-image")
    @transaction.atomic
    def from_image(self, request):
        """Create/reuse an IMAGE proposal and queue local OCR.

        The attachment must be the caller's own JPEG, PNG, or PDF upload in
        the selected business. Location access and business/location linkage
        are checked before anything is queued. Retrying with the same open
        attachment reuses its proposal; the worker safely ignores redelivery
        once recognized text has been applied.
        """
        from datetime import timedelta

        from django.utils import timezone

        serializer = FromImageSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        attachment = Attachment.objects.select_for_update().get(
            pk=serializer.validated_data["attachment"].pk
        )
        business = serializer.validated_data["business"]
        location = serializer.validated_data["location"]
        locale = serializer.validated_data["locale"]
        if attachment.kind != Attachment.Kind.IMAGE:
            raise ValidationError("Only image or PDF attachments can start OCR")
        if attachment.mime.lower() not in IMAGE_MIMES:
            raise ValidationError("Only JPEG, PNG, and PDF attachments can start OCR")
        if attachment.business_id != business.id:
            raise ValidationError("Attachment does not belong to this business")
        if attachment.owner_id != request.user.id:
            raise PermissionDenied("Only the uploader can read this image or PDF")
        if location.business_id != business.id:
            raise ValidationError("Location does not belong to the business")
        require_membership(request.user, business.id, location_id=location.id)

        existing = attachment.proposal
        if (
            existing is not None
            and existing.actor_id == request.user.id
            and existing.business_id == business.id
            and existing.location_id == location.id
            and existing.input_type == AssistantProposal.InputType.IMAGE
            and existing.status in {AssistantProposal.Status.DRAFT, AssistantProposal.Status.READY}
        ):
            proposal = existing
            created = False
        else:
            proposal = AssistantProposal.objects.create(
                business=business,
                location=location,
                actor=request.user,
                input_type=AssistantProposal.InputType.IMAGE,
                locale=locale,
                content="",
                command_type="UNSUPPORTED",
                payload={},
                preview="",
                warnings=[],
                blocking_questions=[READING_IMAGE_BLOCKER],
                status=AssistantProposal.Status.DRAFT,
                expires_at=timezone.now() + timedelta(hours=24),
            )
            from .services import _record_revision

            _record_revision(proposal)
            attachment.proposal = proposal
            attachment.save(update_fields=["proposal", "updated_at"])
            created = True
        try:
            ocr_attachment.delay(str(attachment.id))
        except Exception as exc:
            raise APIException("OCR could not be queued. Please attach the image again.") from exc
        proposal.refresh_from_db()
        return Response(
            AssistantProposalSerializer(proposal).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    @extend_schema(parameters=[PROPOSAL_ID_PATH_PARAMETER])
    @action(detail=True, methods=["post"])
    def confirm(self, request, pk=None):
        proposal = self.get_object()
        serializer = ConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        instance, replayed = confirm(
            proposal=proposal, actor=request.user, **serializer.validated_data
        )
        if isinstance(instance, Purchase):
            result = PurchaseSerializer(instance).data
        elif isinstance(instance, Expense):
            result = ExpenseSerializer(instance).data
        else:
            result = SaleSerializer(instance).data
        return Response(
            {
                "proposal": AssistantProposalSerializer(
                    AssistantProposal.objects.get(pk=proposal.pk)
                ).data,
                "result": result,
            },
            headers={"Idempotent-Replay": str(replayed).lower()},
        )

    @extend_schema(parameters=[PROPOSAL_ID_PATH_PARAMETER])
    @action(detail=True, methods=["post"])
    @transaction.atomic
    def cancel(self, request, pk=None):
        proposal = AssistantProposal.objects.select_for_update().get(pk=self.get_object().pk)
        if proposal.actor_id != request.user.id:
            raise PermissionDenied()
        serializer = CancelSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        if proposal.version != serializer.validated_data["version"]:
            from apps.operations.services import DomainConflict

            raise DomainConflict(
                "The proposal changed; review the latest version", "stale_proposal_version"
            )
        if proposal.status not in {AssistantProposal.Status.DRAFT, AssistantProposal.Status.READY}:
            from apps.operations.services import DomainConflict

            raise DomainConflict("Only an open proposal can be cancelled", "proposal_not_open")
        proposal.status = AssistantProposal.Status.CANCELLED
        proposal.save(update_fields=["status", "updated_at"])
        return Response(AssistantProposalSerializer(proposal).data)


class AttachmentViewSet(viewsets.GenericViewSet):
    serializer_class = AttachmentSerializer

    def get_queryset(self):
        return (
            Attachment.objects.filter(
                owner=self.request.user,
                business__is_active=True,
                business__memberships__user=self.request.user,
                business__memberships__is_active=True,
            )
            .distinct()
            .order_by("-created_at")
        )

    @action(detail=False, methods=["post"], url_path="upload")
    def upload(self, request):
        """Upload a small voice file through Django for local/private storage.

        Production clients can still use direct presigned uploads. This route
        makes the project-local storage backend usable without a second public
        file server.
        """
        serializer = PresignSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        uploaded = request.FILES.get("file")
        if uploaded is None:
            from rest_framework.exceptions import ValidationError

            raise ValidationError("A file is required")
        if uploaded.size > int(getattr(settings, "ATTACHMENT_MAX_BYTES", 8 * 1024 * 1024)):
            from rest_framework.exceptions import ValidationError

            raise ValidationError("File exceeds the upload limit")
        if uploaded.size != serializer.validated_data["size_bytes"]:
            from rest_framework.exceptions import ValidationError

            raise ValidationError("Declared file size does not match the upload")

        business = serializer.validated_data["business"]
        require_membership(request.user, business.id)
        kind = serializer.validated_data["kind"]
        mime = serializer.validated_data["mime"]
        attachment = Attachment.objects.create(
            business=business,
            owner=request.user,
            kind=kind,
            mime=mime,
            size_bytes=uploaded.size,
            sha256=serializer.validated_data.get("sha256") or "",
            storage_path="pending",
        )
        attachment.storage_path = storage_path_for(
            business_id=business.id,
            kind=kind,
            attachment_id=attachment.id,
            mime=mime,
        )
        backend = get_storage_backend()
        if not hasattr(backend, "store_bytes"):
            attachment.delete()
            from rest_framework.exceptions import ValidationError

            raise ValidationError("Use the presigned upload flow for this storage backend")
        try:
            backend.store_bytes(attachment.storage_path, uploaded.read())
        except StorageError as exc:
            attachment.delete()
            from rest_framework.exceptions import APIException

            raise APIException("Upload could not be stored") from exc
        attachment.status = Attachment.Status.READY
        attachment.save(update_fields=["storage_path", "status", "updated_at"])
        return Response(AttachmentSerializer(attachment).data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=["post"], url_path="presign")
    def presign(self, request):
        """Mint a short-lived upload ticket for one voice/image file.

        Bytes go straight from the device to private object storage; the
        server only records identity and tenancy up front. Transcription
        (Phase 1) verifies the object server-side before trusting it.
        """
        serializer = PresignSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        business = serializer.validated_data["business"]
        require_membership(request.user, business.id)
        kind = serializer.validated_data["kind"]
        mime = serializer.validated_data["mime"]
        attachment = Attachment.objects.create(
            business=business,
            owner=request.user,
            kind=kind,
            mime=mime,
            size_bytes=serializer.validated_data["size_bytes"],
            sha256=serializer.validated_data.get("sha256") or "",
            storage_path="pending",
        )
        attachment.storage_path = storage_path_for(
            business_id=business.id,
            kind=kind,
            attachment_id=attachment.id,
            mime=mime,
        )
        attachment.save(update_fields=["storage_path", "updated_at"])
        try:
            ticket = get_storage_backend().presign_upload(
                path=attachment.storage_path,
                mime=mime,
                size_bytes=attachment.size_bytes,
            )
        except StorageError as exc:
            attachment.status = Attachment.Status.FAILED
            attachment.save(update_fields=["status", "updated_at"])
            from rest_framework.exceptions import APIException

            raise APIException(f"Upload could not be prepared: {exc}") from exc
        return Response(
            {
                "attachment": AttachmentSerializer(attachment).data,
                "upload_url": ticket.upload_url,
                "upload_headers": ticket.headers,
                "expires_at": ticket.expires_at,
            },
            status=status.HTTP_201_CREATED,
        )
