from __future__ import annotations

import os
from datetime import timedelta
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

import certifi
import dj_database_url
import sentry_sdk
from corsheaders.defaults import default_headers
from django.core.exceptions import ImproperlyConfigured

BASE_DIR = Path(__file__).resolve().parent.parent


def env_bool(name: str, default: bool = False) -> bool:
    return os.getenv(name, str(default)).strip().lower() in {"1", "true", "yes", "on"}


def secure_redis_broker_url(value: str) -> str:
    """Require certificate verification for hosted rediss:// Celery brokers."""
    if not value.startswith("rediss://"):
        return value
    parts = urlsplit(value)
    query = dict(parse_qsl(parts.query, keep_blank_values=True))
    query.setdefault("ssl_cert_reqs", "required")
    query.setdefault("ssl_ca_certs", certifi.where())
    return urlunsplit((parts.scheme, parts.netloc, parts.path, urlencode(query), parts.fragment))


SECRET_KEY = os.getenv("DJANGO_SECRET_KEY", "unsafe-local-development-key")
DEBUG = env_bool("DJANGO_DEBUG", True)
ALLOWED_HOSTS = [
    v.strip()
    for v in os.getenv("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1,0.0.0.0,testserver").split(",")
    if v.strip()
]

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "corsheaders",
    "rest_framework",
    "rest_framework_simplejwt",
    "drf_spectacular",
    "apps.common",
    "apps.authentication",
    "apps.tenancy",
    "apps.catalog",
    "apps.operations",
    "apps.assistant",
    "apps.integrations",
    "apps.invoices",
    "apps.imports",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "apps.tenancy.middleware.TenantScopeMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ]
        },
    }
]
WSGI_APPLICATION = "config.wsgi.application"
ASGI_APPLICATION = "config.asgi.application"


def database_config_from_env():
    """Select the connection credential for this process.

    Runtime services opt into the least-privilege role with
    ``DUKAAN_USE_APP_DB_ROLE=true``. Migrations and other operator commands
    explicitly set it to false so they keep using the owning ``DATABASE_URL``.
    A missing runtime URL is a startup error rather than a silent fallback to
    the operator credential.
    """
    use_app_role = env_bool("DUKAAN_USE_APP_DB_ROLE", False)
    operator_url = os.getenv("DATABASE_URL", "").strip()
    app_url = os.getenv("DUKAAN_APP_DATABASE_URL", "").strip()
    if use_app_role:
        if not app_url:
            raise ImproperlyConfigured(
                "DUKAAN_USE_APP_DB_ROLE=true requires DUKAAN_APP_DATABASE_URL"
            )
        database_url = app_url
    else:
        database_url = operator_url

    if database_url:
        return dj_database_url.parse(
            database_url,
            conn_max_age=60,
            conn_health_checks=True,
        )
    return {"ENGINE": "django.db.backends.sqlite3", "NAME": BASE_DIR / "db.sqlite3"}


DATABASES = {"default": database_config_from_env()}

REDIS_URL = os.getenv("REDIS_URL", "").strip()
if not DEBUG and REDIS_URL:
    CACHES = {
        "default": {
            "BACKEND": "django_redis.cache.RedisCache",
            "LOCATION": REDIS_URL,
            "KEY_PREFIX": "dukaan-api",
            "TIMEOUT": 300,
        }
    }
else:
    # Local development and tests must never depend on an external Redis.
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "dukaan-api-tests",
        }
    }

AUTH_USER_MODEL = "common.User"
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
        "OPTIONS": {"min_length": 8},
    },
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]
LANGUAGE_CODE = "en-in"
TIME_ZONE = "Asia/Kolkata"
USE_I18N = True
USE_TZ = True
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
STORAGES = {
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
    "staticfiles": {"BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage"},
}
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": ["apps.common.authentication.CustomJWTAuthentication"],
    "DEFAULT_PERMISSION_CLASSES": ["rest_framework.permissions.IsAuthenticated"],
    "DEFAULT_THROTTLE_CLASSES": [
        "apps.common.throttling.AuthRateThrottle",
        "apps.common.throttling.AssistantRateThrottle",
        "apps.common.throttling.UploadRateThrottle",
        "apps.common.throttling.WriteRateThrottle",
        "apps.common.throttling.ReadRateThrottle",
    ],
    "DEFAULT_THROTTLE_RATES": {
        "auth": os.getenv("DUKAAN_THROTTLE_AUTH_RATE", "10/min"),
        "assistant": os.getenv("DUKAAN_THROTTLE_ASSISTANT_RATE", "30/min"),
        "uploads": os.getenv("DUKAAN_THROTTLE_UPLOADS_RATE", "10/min"),
        "write": os.getenv("DUKAAN_THROTTLE_WRITE_RATE", "60/min"),
        "read": os.getenv("DUKAAN_THROTTLE_READ_RATE", "120/min"),
    },
    # Render terminates TLS at one trusted proxy. Keep this at zero unless the
    # deployment actually has exactly the configured number of proxy hops.
    "NUM_PROXIES": int(os.getenv("DRF_NUM_PROXIES", "0" if DEBUG else "1")),
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_RENDERER_CLASSES": ["rest_framework.renderers.JSONRenderer"],
    "EXCEPTION_HANDLER": "apps.common.exceptions.api_exception_handler",
    "COERCE_DECIMAL_TO_STRING": True,
}
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=30),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "ROTATE_REFRESH_TOKENS": False,
    "BLACKLIST_AFTER_ROTATION": False,
    "AUTH_HEADER_TYPES": ("Bearer",),
    "AUTH_TOKEN_CLASSES": ("rest_framework_simplejwt.tokens.AccessToken",),
    "TOKEN_TYPE_CLAIM": "token_type",
    "JTI_CLAIM": "jti",
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
    "TOKEN_OBTAIN_SERIALIZER": "rest_framework_simplejwt.serializers.TokenObtainPairSerializer",
}
SPECTACULAR_SETTINGS = {
    "TITLE": "DukaanAI API",
    "DESCRIPTION": "Tenant-safe operational API for DukaanAI",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "POSTPROCESSING_HOOKS": ["apps.common.openapi.normalize_nullable_enums"],
    # Several models legitimately have a field named ``status``. Stable names
    # keep generated clients from receiving hash-suffixed enum components.
    "ENUM_NAME_OVERRIDES": {
        "DocumentStatusEnum": "apps.operations.models.DocumentStatus.choices",
        "PaymentMethodEnum": "apps.common.openapi.PAYMENT_METHOD_CHOICES",
        "PaymentDirectionEnum": "apps.common.openapi.PAYMENT_DIRECTION_CHOICES",
        "AssistantProposalStatusEnum": "apps.common.openapi.ASSISTANT_PROPOSAL_STATUS_CHOICES",
        "AttachmentStatusEnum": "apps.common.openapi.ATTACHMENT_STATUS_CHOICES",
        "AttachmentKindEnum": "apps.common.openapi.ATTACHMENT_KIND_CHOICES",
        "ImportJobStatusEnum": "apps.common.openapi.IMPORT_JOB_STATUS_CHOICES",
        "ImportJobKindEnum": "apps.common.openapi.IMPORT_JOB_KIND_CHOICES",
        "GmailImportStatusEnum": "apps.common.openapi.GMAIL_IMPORT_STATUS_CHOICES",
        "GmailDirectionEnum": ["RECEIPT", "PAYMENT"],
        "NotificationDeviceStatusEnum": "apps.common.openapi.NOTIFICATION_DEVICE_STATUS_CHOICES",
        "ReminderStatusEnum": "apps.common.openapi.REMINDER_STATUS_CHOICES",
        "ReminderKindEnum": "apps.common.openapi.REMINDER_KIND_CHOICES",
        "InvitationStatusEnum": "apps.common.openapi.INVITATION_STATUS_CHOICES",
    },
}

CORS_ALLOWED_ORIGINS = [
    v.strip() for v in os.getenv("CORS_ALLOWED_ORIGINS", "").split(",") if v.strip()
]
# django-cors-headers' defaults omit the two headers our web client always
# sends, and a browser blocks a request whose headers are not listed here:
#   X-Client        — identifies the client on every call
#   Idempotency-Key — set on every mutating call
# Extend the defaults rather than replacing them, so accept/authorization/
# content-type keep working. See tests/test_cors.py.
CORS_ALLOW_HEADERS = (
    *default_headers,
    "x-client",
    "idempotency-key",
)
CORS_ALLOW_CREDENTIALS = False
CSRF_COOKIE_SECURE = not DEBUG
SESSION_COOKIE_SECURE = not DEBUG
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SECURE_SSL_REDIRECT = env_bool("DJANGO_SECURE_SSL_REDIRECT", not DEBUG)
SECURE_HSTS_SECONDS = int(os.getenv("DJANGO_SECURE_HSTS_SECONDS", "0" if DEBUG else "31536000"))
SECURE_HSTS_INCLUDE_SUBDOMAINS = env_bool("DJANGO_SECURE_HSTS_INCLUDE_SUBDOMAINS", not DEBUG)
SECURE_HSTS_PRELOAD = env_bool("DJANGO_SECURE_HSTS_PRELOAD", not DEBUG)
USE_X_FORWARDED_HOST = env_bool("DJANGO_USE_X_FORWARDED_HOST", not DEBUG)
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_REFERRER_POLICY = "same-origin"

DEV_AUTH_ENABLED = env_bool("DEV_AUTH_ENABLED", DEBUG)
# Verification-code delivery. SMS_ENABLED stays false until a provider is wired
# into OTPService.send(). OTP_EXPOSE_DEV_CODE returns the generated code in the
# API response, which is only ever acceptable for local development.
SMS_ENABLED = env_bool("SMS_ENABLED", False)
OTP_EXPOSE_DEV_CODE = env_bool("OTP_EXPOSE_DEV_CODE", DEV_AUTH_ENABLED)
SMS_PROVIDER = os.getenv("SMS_PROVIDER", "msg91").strip().lower()
MSG91_AUTH_KEY = os.getenv("MSG91_AUTH_KEY", "")
MSG91_OTP_TEMPLATE_ID = os.getenv("MSG91_OTP_TEMPLATE_ID", "")
MSG91_OTP_VARIABLE = os.getenv("MSG91_OTP_VARIABLE", "OTP")
MSG91_API_BASE = os.getenv("MSG91_API_BASE", "https://control.msg91.com/api/v5")
SMS_TIMEOUT_SECONDS = int(os.getenv("SMS_TIMEOUT_SECONDS", "15"))
DUKAAN_APP_DB_ROLE = os.getenv("DUKAAN_APP_DB_ROLE", "dukaan_app")

USE_AI_INTERPRETER = env_bool("USE_AI_INTERPRETER", False)
# Provider-independent adapter selection: fake (abstain to deterministic),
# openai_compatible (server-only AI_API_KEY), or chatgpt (legacy revChatGPT).
AI_PROVIDER = os.getenv("AI_PROVIDER", "fake")
AI_MODEL = os.getenv("AI_MODEL", "gpt-4o-mini")
AI_API_BASE = os.getenv("AI_API_BASE", "")
AI_API_KEY = os.getenv("AI_API_KEY", "")
AI_TIMEOUT_SECONDS = int(os.getenv("AI_TIMEOUT_SECONDS", "20"))
AI_PROMPT_VERSION = os.getenv("AI_PROMPT_VERSION", "v1")
# Legacy unofficial-ChatGPT path (AI_PROVIDER=chatgpt only). Never put this in
# client configuration; server side only.
CHATGPT_SESSION_TOKEN = os.getenv("CHATGPT_SESSION_TOKEN", "")
CHATGPT_SESSION_TIMEOUT = int(os.getenv("CHATGPT_SESSION_TIMEOUT", "3600"))

# Private object storage for voice/image uploads (P1/P2). fake (default)
# keeps local dev and tests hermetic; production sets supabase with the
# server-only service-role key. Bytes never enter Postgres either way.
STORAGE_BACKEND = os.getenv("STORAGE_BACKEND", "fake")
LOCAL_STORAGE_DIR = os.getenv("LOCAL_STORAGE_DIR", str(BASE_DIR / ".local_storage"))
ATTACHMENT_MAX_BYTES = int(os.getenv("ATTACHMENT_MAX_BYTES", str(8 * 1024 * 1024)))
SIGNED_URL_TTL_SECONDS = int(os.getenv("SIGNED_URL_TTL_SECONDS", "900"))

# OCR is provided by the Rust doc-extractor HTTP service. DukaanAI uses only
# Python's standard library client and never downloads or loads OCR models.
OCR_ENABLED = env_bool("OCR_ENABLED", True)
OCR_API_URL = os.getenv("OCR_API_URL", "http://127.0.0.1:8790").rstrip("/")
OCR_API_TOKEN = os.getenv("OCR_API_TOKEN", "")
OCR_PROVIDER = os.getenv("OCR_PROVIDER", "ocria")
OCR_LANGUAGES = os.getenv("OCR_LANGUAGES", "eng+hin")
OCR_REQUEST_TIMEOUT_SECONDS = int(os.getenv("OCR_REQUEST_TIMEOUT_SECONDS", "120"))
OCR_POLL_TIMEOUT_SECONDS = int(os.getenv("OCR_POLL_TIMEOUT_SECONDS", "300"))
OCR_POLL_INTERVAL_SECONDS = int(os.getenv("OCR_POLL_INTERVAL_SECONDS", "1"))
OCR_MAX_RESULT_BYTES = int(os.getenv("OCR_MAX_RESULT_BYTES", str(2 * 1024 * 1024)))

# Server-side speech-to-text for voice proposals (P1). fake (default) returns
# STT_FAKE_TRANSCRIPT so local dev and tests stay hermetic; whisper targets
# any OpenAI-compatible /audio/transcriptions endpoint. Server-only keys.
STT_PROVIDER = os.getenv("STT_PROVIDER", "fake")
STT_MODEL = os.getenv("STT_MODEL", "whisper-1")
STT_API_BASE = os.getenv("STT_API_BASE", "")
STT_API_KEY = os.getenv("STT_API_KEY", "")
STT_TIMEOUT_SECONDS = int(os.getenv("STT_TIMEOUT_SECONDS", "60"))
STT_FAKE_TRANSCRIPT = os.getenv("STT_FAKE_TRANSCRIPT", "")
STT_LOCAL_BINARY = os.getenv("STT_LOCAL_BINARY", "whisper-cli")
STT_LOCAL_MODEL_PATH = os.getenv("STT_LOCAL_MODEL_PATH", "")
STT_LOCAL_FFMPEG = os.getenv("STT_LOCAL_FFMPEG", "ffmpeg")
STT_LOCAL_THREADS = int(os.getenv("STT_LOCAL_THREADS", "4"))
STT_LOCAL_TIMEOUT_SECONDS = int(os.getenv("STT_LOCAL_TIMEOUT_SECONDS", "180"))

# Private Supabase Storage. These values are server-only and are intentionally
# not exposed to either client.
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
SUPABASE_STORAGE_BUCKET = os.getenv("SUPABASE_STORAGE_BUCKET", "business-documents")

# Gmail receipts integration. OAuth uses the narrow read-only scope and tokens
# are encrypted at rest. Configure a Google OAuth Web client before enabling.
GMAIL_ENABLED = env_bool("GMAIL_ENABLED", False)
GMAIL_AI_EXTRACTION = env_bool("GMAIL_AI_EXTRACTION", False)
GMAIL_CLIENT_ID = os.getenv("GMAIL_CLIENT_ID", "")
GMAIL_CLIENT_SECRET = os.getenv("GMAIL_CLIENT_SECRET", "")
GMAIL_REDIRECT_URI = os.getenv(
    "GMAIL_REDIRECT_URI", "http://127.0.0.1:8000/api/v1/integrations/gmail/callback/"
)
GMAIL_WEB_REDIRECT_URL = os.getenv("GMAIL_WEB_REDIRECT_URL", "http://127.0.0.1:4173/settings")
GMAIL_TOKEN_ENCRYPTION_KEY = os.getenv("GMAIL_TOKEN_ENCRYPTION_KEY", "")

# Push notifications and durable reminders. Credentials are server-only.
FCM_ENABLED = env_bool("FCM_ENABLED", False)
FCM_PROJECT_ID = os.getenv("FCM_PROJECT_ID", "")
FCM_SERVICE_ACCOUNT_JSON = os.getenv("FCM_SERVICE_ACCOUNT_JSON", "")

# Attachment quarantine and retention. Configure ATTACHMENT_SCANNER as a
# dotted Python implementation path; never pass upload bytes through a shell.
ATTACHMENT_QUARANTINE_REQUIRED = env_bool("ATTACHMENT_QUARANTINE_REQUIRED", not DEBUG)
ATTACHMENT_QUARANTINE_RETENTION_DAYS = int(os.getenv("ATTACHMENT_QUARANTINE_RETENTION_DAYS", "7"))
ATTACHMENT_RETENTION_DAYS = int(os.getenv("ATTACHMENT_RETENTION_DAYS", "30"))
ATTACHMENT_SCANNER = os.getenv("ATTACHMENT_SCANNER", "")

SENTRY_DSN = os.getenv("SENTRY_DSN", "")
if SENTRY_DSN:
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        environment=os.getenv("SENTRY_ENVIRONMENT", "production"),
        send_default_pii=False,
        traces_sample_rate=float(os.getenv("SENTRY_TRACES_SAMPLE_RATE", "0.05")),
    )

CELERY_BROKER_URL = secure_redis_broker_url(
    os.getenv("CELERY_BROKER_URL", "").strip() or REDIS_URL or ("redis://localhost:6379/0")
)
CELERY_RESULT_BACKEND = None
CELERY_TASK_IGNORE_RESULT = True
CELERY_TASK_ACKS_LATE = True
CELERY_TASK_REJECT_ON_WORKER_LOST = True
CELERY_BROKER_TRANSPORT_OPTIONS = {"visibility_timeout": 3600}
CELERY_TASK_ALWAYS_EAGER = env_bool("CELERY_TASK_ALWAYS_EAGER", False)
CELERY_TIMEZONE = TIME_ZONE
