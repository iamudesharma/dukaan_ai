from django.urls import path

from .views import (
    ImportConfirmView,
    ImportJobDetailView,
    ImportJobListView,
    PartyImportUploadView,
    ProductImportUploadView,
)

urlpatterns = [
    path("imports/products/", ProductImportUploadView.as_view(), name="import-products-upload"),
    path("imports/parties/", PartyImportUploadView.as_view(), name="import-parties-upload"),
    path("imports/", ImportJobListView.as_view(), name="import-job-list"),
    path("imports/<uuid:job_id>/", ImportJobDetailView.as_view(), name="import-job-detail"),
    path("imports/<uuid:job_id>/confirm/", ImportConfirmView.as_view(), name="import-confirm"),
]
