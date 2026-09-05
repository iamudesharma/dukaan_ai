import uuid

from django.contrib.auth.models import AbstractUser
from django.db import models


class UUIDModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    supabase_user_id = models.UUIDField(unique=True, null=True, blank=True)
    phone_e164 = models.CharField(max_length=20, blank=True)
    display_name = models.CharField(max_length=120, blank=True)

    def __str__(self) -> str:
        return self.display_name or self.phone_e164 or self.username
