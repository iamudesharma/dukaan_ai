from rest_framework.routers import DefaultRouter

from .views import PartyViewSet, ProductViewSet

router = DefaultRouter()
router.register("products", ProductViewSet, basename="product")
router.register("parties", PartyViewSet, basename="party")
urlpatterns = router.urls
