from rest_framework.routers import DefaultRouter

from .views import (
    AuditEventViewSet,
    BusinessViewSet,
    GSTRegistrationViewSet,
    InvitationViewSet,
    LocationViewSet,
    MembershipViewSet,
)

router = DefaultRouter()
router.register("businesses", BusinessViewSet, basename="business")
router.register("locations", LocationViewSet, basename="location")
router.register("gst-registrations", GSTRegistrationViewSet, basename="gst-registration")
router.register("memberships", MembershipViewSet, basename="membership")
router.register("audit-events", AuditEventViewSet, basename="audit-event")
router.register("invitations", InvitationViewSet, basename="invitation")
urlpatterns = router.urls
