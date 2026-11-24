from django.apps import AppConfig


class CommonConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.common"

    def ready(self):
        # Importing registers the authentication extension with drf-spectacular.
        from . import openapi  # noqa: F401
