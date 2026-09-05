from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

from apps.common.views import HealthView, ReadyView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("healthz/", HealthView.as_view(), name="health"),
    path("readyz/", ReadyView.as_view(), name="ready"),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="docs"),
    path("api/v1/", include("apps.common.urls")),
    path("api/v1/", include("apps.authentication.urls")),
    path("api/v1/", include("apps.tenancy.urls")),
    path("api/v1/", include("apps.catalog.urls")),
    path("api/v1/", include("apps.operations.urls")),
    path("api/v1/assistant/", include("apps.assistant.urls")),
]
