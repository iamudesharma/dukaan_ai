from io import StringIO

import pytest
from django.core.management import call_command
from django.core.management.base import CommandError


def test_run_scheduled_dispatches_then_purges(monkeypatch):
    commands = []
    monkeypatch.setattr(
        "apps.tenancy.management.commands.run_scheduled.call_command",
        lambda name, **kwargs: commands.append((name, kwargs)),
    )

    call_command("run_scheduled", "--purge-limit", "25", stdout=StringIO())

    assert commands == [
        ("dispatch_scheduled", {}),
        ("purge_expired_attachments", {"limit": 25}),
    ]


def test_run_scheduled_can_skip_retention(monkeypatch):
    commands = []
    monkeypatch.setattr(
        "apps.tenancy.management.commands.run_scheduled.call_command",
        lambda name, **kwargs: commands.append((name, kwargs)),
    )

    call_command("run_scheduled", "--skip-purge", stdout=StringIO())

    assert commands == [("dispatch_scheduled", {})]


@pytest.mark.parametrize("limit", [0, -1])
def test_run_scheduled_rejects_invalid_retention_limit(limit):
    with pytest.raises(CommandError, match="must be positive"):
        call_command("run_scheduled", f"--purge-limit={limit}", stdout=StringIO())
