from django.contrib import admin

from .models import ImportJob


@admin.register(ImportJob)
class ImportJobAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "business",
        "user",
        "kind",
        "status",
        "row_count",
        "error_count",
        "created_at",
    )
    list_filter = ("kind", "status", "duplicate_strategy")
    search_fields = ("original_filename", "file_sha256")
    readonly_fields = (
        "rows",
        "errors",
        "file_sha256",
        "confirmation_key",
        "created_at",
        "updated_at",
        "confirmed_at",
    )
