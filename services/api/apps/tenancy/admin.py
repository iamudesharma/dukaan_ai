from django.contrib import admin

from .models import (
    AuditEvent,
    Business,
    GSTRegistration,
    IdempotencyRecord,
    Invitation,
    Location,
    Membership,
    OutboxEvent,
)

admin.site.register(
    [
        Business,
        GSTRegistration,
        Location,
        Membership,
        Invitation,
        IdempotencyRecord,
        AuditEvent,
        OutboxEvent,
    ]
)
