from django.contrib import admin

from .models import (
    AuditEvent,
    Business,
    GSTRegistration,
    IdempotencyRecord,
    Invitation,
    Location,
    Membership,
    NotificationPreference,
    OutboxEvent,
)

admin.site.register(
    [
        Business,
        GSTRegistration,
        Location,
        Membership,
        Invitation,
        NotificationPreference,
        IdempotencyRecord,
        AuditEvent,
        OutboxEvent,
    ]
)
