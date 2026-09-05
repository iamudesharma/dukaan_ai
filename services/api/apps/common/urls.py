from django.urls import path

from .views import BootstrapView, MeView

urlpatterns = [
    path("me/", MeView.as_view(), name="me"),
    path("bootstrap/", BootstrapView.as_view(), name="bootstrap"),
]
