from rest_framework.routers import DefaultRouter

from .views import ProposalViewSet

router = DefaultRouter()
router.register("proposals", ProposalViewSet, basename="assistant-proposal")
urlpatterns = router.urls
