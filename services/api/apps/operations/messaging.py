"""Reminder delivery adapter with durable status.

Production SMS/WhatsApp providers sit behind this module (DLT registration
is a launch gate, not a Phase 3 blocker). Until provider credentials exist
the adapter logs and returns a deterministic dev message id so the worker
path — outbox claim, deliver, mark SENT — is fully exercised. Failures
raise so the outbox row retries with backoff instead of marking SENT.
"""

from __future__ import annotations

import hashlib
import logging

logger = logging.getLogger(__name__)


class TransientDeliveryError(Exception):
    """The provider is temporarily unavailable; retry with backoff."""


def send_reminder(*, channel: str, phone: str, message: str) -> str:
    """Deliver one reminder; returns the provider message id."""
    if channel == "SHARE":
        # Manual share: nothing leaves the server; the message text itself
        # is the deliverable the client copies into WhatsApp/SMS.
        digest = hashlib.sha256(f"{phone}:{message}".encode()).hexdigest()[:16]
        logger.info("Reminder share prepared phone=%s id=%s", phone, digest)
        return f"share-{digest}"
    if not phone:
        raise TransientDeliveryError("No phone number for reminder delivery")
    digest = hashlib.sha256(f"{channel}:{phone}:{message}".encode()).hexdigest()[:16]
    # Dev fallback: log instead of calling a provider.
    logger.info("Reminder sent via %s phone=%s id=%s", channel, phone, digest)
    return f"dev-{digest}"
