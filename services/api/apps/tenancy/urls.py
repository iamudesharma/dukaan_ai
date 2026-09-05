from rest_framework.routers import DefaultRouter

from .views import BusinessViewSet, GSTRegistrationViewSet, LocationViewSet, MembershipViewSet

router = DefaultRouter()
router.register("businesses", BusinessViewSet, basename="business")
router.register("locations", LocationViewSet, basename="location")
router.register("gst-registrations", GSTRegistrationViewSet, basename="gst-registration")
router.register("memberships", MembershipViewSet, basename="membership")
urlpatterns = router.urls
