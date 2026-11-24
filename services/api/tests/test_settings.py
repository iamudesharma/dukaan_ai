import runpy
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

import pytest
from django.conf import settings
from django.core.exceptions import ImproperlyConfigured

SETTINGS_FILE = Path(settings.BASE_DIR) / "config" / "settings.py"
OPERATOR_URL = "postgresql://operator:secret@db.example/dukaan?sslmode=require"
APP_URL = "postgresql://dukaan_app:app-secret@db.example/dukaan?sslmode=require"


def _load_settings(monkeypatch, **values):
    for name in (
        "DATABASE_URL",
        "DUKAAN_APP_DATABASE_URL",
        "DUKAAN_USE_APP_DB_ROLE",
        "REDIS_URL",
        "CELERY_BROKER_URL",
        "DJANGO_DEBUG",
        "SENTRY_DSN",
    ):
        monkeypatch.delenv(name, raising=False)
    for name, value in values.items():
        monkeypatch.setenv(name, value)
    return runpy.run_path(str(SETTINGS_FILE))


def test_no_database_url_keeps_local_sqlite(monkeypatch):
    loaded = _load_settings(monkeypatch)
    database = loaded["DATABASES"]["default"]
    assert database["ENGINE"] == "django.db.backends.sqlite3"
    assert database["NAME"] == loaded["BASE_DIR"] / "db.sqlite3"


def test_operator_url_is_the_default_when_runtime_role_is_disabled(monkeypatch):
    loaded = _load_settings(
        monkeypatch,
        DATABASE_URL=OPERATOR_URL,
        DUKAAN_APP_DATABASE_URL=APP_URL,
        DUKAAN_USE_APP_DB_ROLE="false",
    )
    database = loaded["DATABASES"]["default"]
    assert database["ENGINE"] == "django.db.backends.postgresql"
    assert database["USER"] == "operator"
    assert database["NAME"] == "dukaan"


def test_runtime_role_selects_the_separate_app_url(monkeypatch):
    loaded = _load_settings(
        monkeypatch,
        DATABASE_URL=OPERATOR_URL,
        DUKAAN_APP_DATABASE_URL=APP_URL,
        DUKAAN_USE_APP_DB_ROLE="true",
    )
    database = loaded["DATABASES"]["default"]
    assert database["USER"] == "dukaan_app"
    assert database["PASSWORD"] == "app-secret"
    assert database["NAME"] == "dukaan"


def test_runtime_role_fails_closed_without_an_app_url(monkeypatch):
    with pytest.raises(ImproperlyConfigured, match="DUKAAN_APP_DATABASE_URL"):
        _load_settings(
            monkeypatch,
            DATABASE_URL=OPERATOR_URL,
            DUKAAN_USE_APP_DB_ROLE="true",
        )


def test_production_redis_url_configures_shared_cache(monkeypatch):
    loaded = _load_settings(
        monkeypatch,
        DJANGO_DEBUG="false",
        REDIS_URL="redis://cache.example:6379/2",
    )
    assert loaded["CACHES"]["default"]["BACKEND"] == "django_redis.cache.RedisCache"
    assert loaded["CACHES"]["default"]["LOCATION"] == "redis://cache.example:6379/2"


def test_development_redis_url_keeps_cache_local(monkeypatch):
    loaded = _load_settings(
        monkeypatch,
        DJANGO_DEBUG="true",
        REDIS_URL="redis://cache.example:6379/2",
    )
    assert loaded["CACHES"]["default"]["BACKEND"] == (
        "django.core.cache.backends.locmem.LocMemCache"
    )


def test_production_without_redis_url_keeps_cache_local(monkeypatch):
    loaded = _load_settings(monkeypatch, DJANGO_DEBUG="false")
    assert loaded["CACHES"]["default"]["BACKEND"] == (
        "django.core.cache.backends.locmem.LocMemCache"
    )


def test_hosted_redis_broker_requires_tls_certificate_verification(monkeypatch):
    loaded = _load_settings(
        monkeypatch,
        CELERY_BROKER_URL="rediss://default:secret@redis.example.com:6379/0",
    )
    query = parse_qs(urlsplit(loaded["CELERY_BROKER_URL"]).query)
    assert query["ssl_cert_reqs"] == ["required"]
    assert Path(query["ssl_ca_certs"][0]).is_file()
