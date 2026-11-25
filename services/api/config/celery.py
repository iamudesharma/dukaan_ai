import os

from celery import Celery
from django.conf import settings

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
# Celery reads CELERY_BROKER_URL directly from the environment. Normalize it
# before constructing the app so hosted rediss:// brokers require certificate
# verification instead of Celery's insecure default.
os.environ["CELERY_BROKER_URL"] = settings.CELERY_BROKER_URL
app = Celery("dukaanai")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
