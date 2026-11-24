"""Report the active AI interpreter configuration, and optionally call it.

Answers "is my LLM wiring working?" without going through the assistant UI:
the interpreter silently abstains when it is unconfigured, which looks
identical to a deterministic parse in the app.
"""

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError

from apps.assistant.adapter import (
    OpenAICompatibleAdapter,
    get_adapter,
    redact_for_log,
)

DEFAULT_MESSAGE = "Ramesh bought 3 shirts for Rs 2,400, paid Rs 1,500, Rs 900 pending."


def mask(secret: str) -> str:
    """Never print a credential; show only enough to confirm it is loaded."""
    if not secret:
        return "(empty)"
    if len(secret) <= 8:
        return "*" * len(secret)
    return f"{secret[:4]}...{secret[-4:]} ({len(secret)} chars)"


class Command(BaseCommand):
    help = (
        "Show the AI interpreter configuration and, with --call, send one test "
        "extraction through the configured provider."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--call",
            action="store_true",
            help="Actually call the provider. Sends one short request (may cost tokens).",
        )
        parser.add_argument(
            "--message",
            default=DEFAULT_MESSAGE,
            help="Input to interpret when --call is used.",
        )

    def handle(self, *args, **options):
        enabled = bool(getattr(settings, "USE_AI_INTERPRETER", False))
        provider = str(getattr(settings, "AI_PROVIDER", "fake") or "fake")
        model = str(getattr(settings, "AI_MODEL", ""))
        api_base = str(getattr(settings, "AI_API_BASE", "") or "")
        api_key = str(getattr(settings, "AI_API_KEY", "") or "")

        self.stdout.write("Configuration")
        self.stdout.write(f"  USE_AI_INTERPRETER: {enabled}")
        self.stdout.write(f"  AI_PROVIDER:        {provider}")
        self.stdout.write(f"  AI_MODEL:           {model or '(empty)'}")
        self.stdout.write(f"  AI_API_BASE:        {api_base or '(empty)'}")
        self.stdout.write(f"  AI_API_KEY:         {mask(api_key)}")

        if not enabled:
            self.stdout.write(
                "\nThe interpreter is off, so the deterministic parser handles every "
                "request. Set USE_AI_INTERPRETER=true to enable it."
            )
            return

        adapter = get_adapter()
        if adapter is None:
            raise CommandError("USE_AI_INTERPRETER is true but no adapter was built")

        self.stdout.write(f"\nAdapter: {type(adapter).__name__} ({adapter.name})")

        if isinstance(adapter, OpenAICompatibleAdapter) and not adapter._configured():
            raise CommandError(
                "AI_API_BASE is empty, so the adapter abstains on every request. "
                "Set it to the provider's /v1 root, e.g. "
                "https://api.openai.com/v1 or http://localhost:11434/v1"
            )

        if adapter.name == "fake":
            self.stdout.write(
                "\nThe fake adapter never calls a model; it abstains so the "
                "deterministic parser wins. Set AI_PROVIDER to a real provider."
            )
            return

        if not options["call"]:
            self.stdout.write("\nRe-run with --call to send one extraction request.")
            return

        message = options["message"]
        self.stdout.write(f"\nCalling {adapter.name} with: {redact_for_log(message)}")
        extraction = adapter.interpret(message, locale="en-IN")

        if extraction is None:
            self.stdout.write(self.style.WARNING("  The adapter abstained (returned nothing)."))
            return

        self.stdout.write(f"  command_type: {extraction.command_type}")
        self.stdout.write(f"  party_name:   {extraction.party_name}")
        self.stdout.write(f"  total_minor:  {extraction.total_minor}")
        self.stdout.write(f"  paid_minor:   {extraction.paid_minor}")
        for item in extraction.items:
            self.stdout.write(
                f"  item:         {item.product} x {item.quantity} @ {item.unit_price_minor}"
            )
        for question in extraction.blocking_questions:
            self.stdout.write(self.style.ERROR(f"  blocked:      {question}"))
        for warning in extraction.warnings:
            self.stdout.write(self.style.WARNING(f"  warning:      {warning}"))

        if extraction.blocking_questions:
            self.stdout.write(
                self.style.ERROR(
                    "\nThe provider is reachable but did not return a usable "
                    "extraction. Fix the message above before enabling this in the app."
                )
            )
        else:
            self.stdout.write(self.style.SUCCESS("\nThe interpreter is working."))
