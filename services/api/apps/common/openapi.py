"""OpenAPI extensions for API behavior shared across DukaanAI apps."""

from drf_spectacular.extensions import OpenApiAuthenticationExtension

from apps.assistant.models import AssistantProposal, Attachment
from apps.common.authentication import CustomJWTAuthentication
from apps.imports.models import ImportJob
from apps.integrations.models import GmailImport, NotificationDevice, Reminder
from apps.operations.models import Payment
from apps.tenancy.models import Invitation

# drf-spectacular's dotted override loader cannot traverse nested Django choice
# classes. Expose stable module-level choice lists after Django's app registry
# has loaded, and reference those from SPECTACULAR_SETTINGS.
PAYMENT_METHOD_CHOICES = Payment.Method.choices
PAYMENT_DIRECTION_CHOICES = Payment.Direction.choices
ASSISTANT_PROPOSAL_STATUS_CHOICES = AssistantProposal.Status.choices
ATTACHMENT_STATUS_CHOICES = Attachment.Status.choices
ATTACHMENT_KIND_CHOICES = Attachment.Kind.choices
IMPORT_JOB_STATUS_CHOICES = ImportJob.Status.choices
IMPORT_JOB_KIND_CHOICES = ImportJob.Kind.choices
GMAIL_IMPORT_STATUS_CHOICES = GmailImport.Status.choices
NOTIFICATION_DEVICE_STATUS_CHOICES = NotificationDevice.Status.choices
REMINDER_STATUS_CHOICES = Reminder.Status.choices
REMINDER_KIND_CHOICES = Reminder.Kind.choices
INVITATION_STATUS_CHOICES = Invitation.Status.choices


def normalize_nullable_enums(result, generator, request, public):
    """Inline nullable enum unions so client generators do not emit duplicate types."""

    def walk(node):
        if isinstance(node, list):
            for item in node:
                walk(item)
            return
        if not isinstance(node, dict):
            return
        one_of = node.get("oneOf")
        if isinstance(one_of, list) and len(one_of) == 2:
            refs = [item.get("$ref") for item in one_of if isinstance(item, dict)]
            names = [ref.rsplit("/", 1)[-1] for ref in refs if ref]
            if "NullEnum" in names and len(names) == 2:
                enum_name = next(name for name in names if name != "NullEnum")
                enum_schema = result.get("components", {}).get("schemas", {}).get(enum_name)
                if isinstance(enum_schema, dict):
                    node.clear()
                    node.update(enum_schema)
                    node["nullable"] = True
        for value in list(node.values()):
            walk(value)

    walk(result)
    return result


class CustomJWTAuthenticationExtension(OpenApiAuthenticationExtension):
    """Describe the production bearer token used by the custom JWT authenticator."""

    target_class = CustomJWTAuthentication
    name = "bearerAuth"

    def get_security_definition(self, auto_schema):
        return {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Access JWT issued by signup, login, OTP verification, or refresh.",
        }
