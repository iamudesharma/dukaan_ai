from rest_framework.routers import DefaultRouter

from .views import AttachmentViewSet, ProposalViewSet

router = DefaultRouter()
router.register("proposals", ProposalViewSet, basename="assistant-proposal")
router.register("attachments", AttachmentViewSet, basename="assistant-attachment")
urlpatterns = router.urls
