from rest_framework.exceptions import NotFound
from rest_framework.views import exception_handler


class OnboardingRequired(NotFound):
    """The caller is authenticated but belongs to no active business yet.

    A distinct class (rather than a ``code=`` argument) because the error
    envelope below reads the exception's class-level code.
    """

    default_code = "onboarding_required"


def api_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is not None:
        detail = response.data
        response.data = {
            "error": {
                "code": getattr(exc, "default_code", "request_error"),
                "detail": detail,
            }
        }
    return response
