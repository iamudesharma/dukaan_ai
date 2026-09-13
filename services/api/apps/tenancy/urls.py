from rest_framework.routers import DefaultRouter

from .views import (
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
router.register("invitations", InvitationViewSet, basename="invitation")
urlpatterns = router.urls

# Router-generated invitation routes (explicit for discoverability):
#   GET/POST /api/v1/invitations/?business_id=
#   GET      /api/v1/invitations/{id}/
#   POST     /api/v1/invitations/{id}/accept/   {token}
#   POST     /api/v1/invitations/{id}/revoke/
#   POST     /api/v1/memberships/{id}/revoke/
