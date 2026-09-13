from django.db import transaction
from django.db.models import Q
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response

from apps.operations.serializers import (
    ExpenseSerializer,
    PaymentSerializer,
    PurchaseSerializer,
    SaleSerializer,
)
from apps.tenancy.access import require_membership

from .models import AssistantProposal
from .serializers import (
    AssistantProposalSerializer,
    CancelSerializer,
    ConfirmSerializer,
    InterpretSerializer,
    ReviseSerializer,
)
from .services import confirm, interpret, revise


class ProposalViewSet(mixins.ListModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    serializer_class = AssistantProposalSerializer

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

    @action(detail=True, methods=["post"])
    def revise(self, request, pk=None):
        proposal = self.get_object()
        serializer = ReviseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        result = revise(proposal=proposal, actor=request.user, **serializer.validated_data)
        return Response(AssistantProposalSerializer(result).data)

    @action(detail=True, methods=["get"])
    def revisions(self, request, pk=None):
        proposal = self.get_object()
        return Response(list(proposal.revisions.values("version", "snapshot", "created_at")))

    def create(self, request):
        serializer = InterpretSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        proposal = interpret(actor=request.user, **serializer.validated_data)
        return Response(AssistantProposalSerializer(proposal).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"])
    def confirm(self, request, pk=None):
        proposal = self.get_object()
        serializer = ConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        instance, replayed = confirm(
            proposal=proposal, actor=request.user, **serializer.validated_data
        )
        result_serializers = {
            "operations.sale": SaleSerializer,
            "operations.purchase": PurchaseSerializer,
            "operations.payment": PaymentSerializer,
            "operations.expense": ExpenseSerializer,
        }
        # confirm() saves the proposal in the same transaction; re-read it.
        confirmed = AssistantProposal.objects.get(pk=proposal.pk)
        result_serializer = result_serializers.get(confirmed.confirmed_result_type, SaleSerializer)
        return Response(
            {
                "proposal": AssistantProposalSerializer(confirmed).data,
                "result": result_serializer(instance).data,
            },
            headers={"Idempotent-Replay": str(replayed).lower()},
        )

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
