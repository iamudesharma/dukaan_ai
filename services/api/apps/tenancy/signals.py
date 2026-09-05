from django.contrib.auth.signals import user_logged_in, user_logged_out
from django.db import connection
from django.dispatch import receiver

from apps.tenancy import rls


@receiver(user_logged_in)
def establish_session_scope(sender, request, user, **kwargs):
    # Session auth (admin console) verifies credentials before this signal,
    # so the membership-derived scope is trustworthy here as well.
    rls.establish_scope(connection, user)


@receiver(user_logged_out)
def drop_session_scope(sender, request, user, **kwargs):
    rls.clear_tenant_scope(connection)
