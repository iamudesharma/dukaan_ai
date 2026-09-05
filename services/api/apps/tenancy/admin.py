from django.contrib import admin

from .models import (
    AuditEvent,
    Business,
    GSTRegistration,
    IdempotencyRecord,
    Location,
    Membership,
    OutboxEvent,
)

admin.site.register(
    [Business, GSTRegistration, Location, Membership, IdempotencyRecord, AuditEvent, OutboxEvent]
)
