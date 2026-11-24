"""Typed assistant adapter boundary (P0).

AI interprets intent; deterministic code in ``services.py`` validates and
posts. This module owns the provider-independent contract:

- :class:`Extraction` — strict, paise-only candidate fields plus
  uncertainties and provenance. Never written to ledgers directly.
- :class:`AssistantAdapter` — one interface every model provider implements.
- :func:`get_adapter` — server-side factory driven by ``AI_PROVIDER`` /
  ``USE_AI_INTERPRETER``. Client configuration must never carry provider keys.
"""

from __future__ import annotations

import json
import logging
import re
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from decimal import Decimal, InvalidOperation

from django.conf import settings

logger = logging.getLogger(__name__)

COMMAND_SALE = "SALE"
COMMAND_PURCHASE = "PURCHASE"
COMMAND_PAYMENT = "PAYMENT"
COMMAND_EXPENSE = "EXPENSE"
COMMAND_TRANSFER = "TRANSFER"
COMMAND_UNKNOWN = "UNKNOWN"

SUPPORTED_COMMANDS = frozenset(
    {COMMAND_SALE, COMMAND_PURCHASE, COMMAND_PAYMENT, COMMAND_EXPENSE, COMMAND_TRANSFER}
)
CONFIRMABLE_COMMANDS = frozenset({COMMAND_SALE, COMMAND_PURCHASE, COMMAND_EXPENSE})

PROMPT_VERSION = "v1"

SYSTEM_PROMPT = """You are DukaanAI, a business assistant for Indian shops.
Extract sale, purchase, payment, expense, or transfer info from Hindi,
Hinglish, or English input.

Respond ONLY with valid JSON in this exact format:
{
  "command_type": "SALE|PURCHASE|PAYMENT|EXPENSE|TRANSFER|UNKNOWN",
  "party_name": "string or null (customer/seller)",
  "items": [{"product": "string", "quantity": number,
             "unit_price_minor": number|null}],
  "total_minor": number (paise, 0 when unknown),
  "paid_minor": number (paise, 0 when unknown),
  "amount_minor": number (paise; PAYMENT/EXPENSE, 0 when unknown),
  "direction": "RECEIPT|PAYMENT|null (PAYMENT only)",
  "expense_category": "string or null (EXPENSE only)",
  "warnings": ["string"],
  "blocking_questions": ["string"],
  "uncertainties": ["string"]
}

Rules:
- Amounts are integer paise (Rs 1 = 100 paise). Never use floats.
- quantity may be decimal for weights (e.g. 2.5).
- unit_price_minor is per-unit paise or null when not stated.
- Missing info goes in blocking_questions; do not guess totals.
- Unclear or out-of-scope input is UNKNOWN with an explanation.
- Ambiguous matches go in uncertainties for the reviewer."""


@dataclass
class ItemCandidate:
    product: str = ""
    quantity: Decimal = Decimal("0")
    unit_price_minor: int | None = None

    @classmethod
    def from_raw(cls, raw: object) -> ItemCandidate | None:
        if not isinstance(raw, dict):
            return None
        name = raw.get("product", "")
        if not isinstance(name, str) or not name.strip():
            return None
        try:
            quantity = Decimal(str(raw.get("quantity", "0")))
        except (InvalidOperation, ValueError, TypeError):
            return None
        price_raw = raw.get("unit_price_minor")
        price: int | None = None
        if price_raw is not None:
            if isinstance(price_raw, bool) or not isinstance(price_raw, int):
                return None
            if price_raw < 0:
                return None
            price = price_raw
        return cls(product=name.strip(), quantity=quantity, unit_price_minor=price)


@dataclass
class Extraction:
    command_type: str = COMMAND_UNKNOWN
    party_name: str | None = None
    items: list[ItemCandidate] = field(default_factory=list)
    total_minor: int = 0
    paid_minor: int = 0
    amount_minor: int = 0
    direction: str | None = None
    expense_category: str | None = None
    warnings: list[str] = field(default_factory=list)
    blocking_questions: list[str] = field(default_factory=list)
    uncertainties: list[str] = field(default_factory=list)
    raw_response: str = ""
    model: str = ""
    prompt_version: str = PROMPT_VERSION

    @property
    def is_actionable(self) -> bool:
        return self.command_type in SUPPORTED_COMMANDS and not self.blocking_questions

    @property
    def provenance(self) -> dict:
        return {
            "model": self.model,
            "prompt_version": self.prompt_version,
            "command_type": self.command_type,
            "uncertainties": list(self.uncertainties),
        }


def _as_minor(value: object) -> int | None:
    if isinstance(value, bool) or not isinstance(value, int):
        return None
    if value < 0:
        return None
    return value


def _as_str_list(value: object) -> list[str] | None:
    if not isinstance(value, list):
        return None
    cleaned = [str(item) for item in value if str(item).strip()]
    if len(cleaned) != len(value):
        return None
    return cleaned


def parse_extraction_payload(
    data: object, *, raw_response: str = "", model: str = ""
) -> Extraction:
    """Strictly validate one raw provider payload. Never raises: invalid input
    becomes an UNKNOWN extraction with a blocking question (fail closed)."""
    if not isinstance(data, dict):
        return Extraction(
            blocking_questions=["AI returned an unparseable response"],
            raw_response=raw_response,
            model=model,
        )
    command_type = data.get("command_type", COMMAND_UNKNOWN)
    if command_type not in SUPPORTED_COMMANDS and command_type != COMMAND_UNKNOWN:
        return Extraction(
            blocking_questions=[f"AI returned unsupported command '{command_type}'"],
            raw_response=raw_response,
            model=model,
        )
    party_name = data.get("party_name", data.get("customer_name"))
    if party_name is not None and (not isinstance(party_name, str) or not party_name.strip()):
        return Extraction(
            blocking_questions=["AI returned an invalid party name"],
            raw_response=raw_response,
            model=model,
        )
    raw_items = data.get("items", [])
    if not isinstance(raw_items, list):
        return Extraction(
            blocking_questions=["AI returned invalid items"],
            raw_response=raw_response,
            model=model,
        )
    items: list[ItemCandidate] = []
    for raw_item in raw_items:
        # Back-compat: legacy providers sent unit_price_minor per item; keep it.
        item = ItemCandidate.from_raw(raw_item)
        if item is None:
            return Extraction(
                blocking_questions=["AI returned an invalid line item"],
                raw_response=raw_response,
                model=model,
            )
        items.append(item)
    total_minor = _as_minor(data.get("total_minor", 0))
    paid_minor = _as_minor(data.get("paid_minor", 0))
    amount_minor = _as_minor(data.get("amount_minor", 0))
    if total_minor is None or paid_minor is None or amount_minor is None:
        return Extraction(
            blocking_questions=["AI returned an invalid amount"],
            raw_response=raw_response,
            model=model,
        )
    direction = data.get("direction")
    if direction is not None and direction not in {"RECEIPT", "PAYMENT"}:
        return Extraction(
            blocking_questions=["AI returned an invalid payment direction"],
            raw_response=raw_response,
            model=model,
        )
    expense_category = data.get("expense_category")
    if expense_category is not None and (
        not isinstance(expense_category, str) or not expense_category.strip()
    ):
        return Extraction(
            blocking_questions=["AI returned an invalid expense category"],
            raw_response=raw_response,
            model=model,
        )
    warnings = _as_str_list(data.get("warnings", []))
    blockers = _as_str_list(data.get("blocking_questions", []))
    uncertainties = _as_str_list(data.get("uncertainties", []))
    if warnings is None or blockers is None or uncertainties is None:
        return Extraction(
            blocking_questions=["AI returned invalid warnings or questions"],
            raw_response=raw_response,
            model=model,
        )
    if command_type == COMMAND_UNKNOWN and not blockers:
        blockers = ["The request could not be understood as a business command."]
    return Extraction(
        command_type=command_type,
        party_name=party_name.strip() if party_name else None,
        items=items,
        total_minor=total_minor,
        paid_minor=paid_minor,
        amount_minor=amount_minor,
        direction=direction,
        expense_category=expense_category.strip() if expense_category else None,
        warnings=warnings,
        blocking_questions=blockers,
        uncertainties=uncertainties,
        raw_response=raw_response,
        model=model,
    )


def redact_for_log(text: str, *, limit: int = 120) -> str:
    """Truncate and mask long digit runs so logs never carry full amounts/phones."""
    snippet = " ".join(str(text).split())[:limit]
    return re.sub(r"\d{4,}", "****", snippet)


class AssistantAdapter:
    """One interface for every extraction provider. Returns an Extraction, or
    None when the provider has no opinion (caller falls back to deterministic
    parsing). Transport/model failures must return an UNKNOWN Extraction with
    a blocking question — never raise into the request path."""

    name = "base"

    def interpret(self, user_message: str, locale: str = "en-IN") -> Extraction | None:
        raise NotImplementedError


class FakeAdapter(AssistantAdapter):
    """Local-dev adapter with no model: abstains so deterministic parsing wins."""

    name = "fake"

    def interpret(self, user_message: str, locale: str = "en-IN") -> Extraction | None:
        return None


class AIRequestError(Exception):
    """A provider call failed. Carries the HTTP status so callers can tell an
    auth failure from an unreachable host."""

    def __init__(self, message: str, *, status: int | None = None, body: str = "") -> None:
        super().__init__(message)
        self.status = status
        self.body = body


class OpenAICompatibleAdapter(AssistantAdapter):
    """Any OpenAI-compatible ``/chat/completions`` endpoint over stdlib urllib.

    Works against hosted gateways (OpenAI, OpenCode Zen, Groq, OpenRouter) and
    against local model servers (Ollama, LM Studio, llama.cpp, vLLM). Local
    servers usually need no credential, so only ``AI_API_BASE`` is required and
    the Authorization header is omitted when ``AI_API_KEY`` is empty.
    """

    name = "openai_compatible"

    #: OpenAI's JSON mode is an extension; many compatible servers reject it.
    RETRY_WITHOUT_JSON_MODE = frozenset({400, 404, 415, 422})

    def __init__(
        self,
        *,
        api_key: str = "",
        api_base: str = "",
        model: str = "",
        timeout_seconds: int = 20,
        json_mode: bool = True,
    ) -> None:
        self.api_key = api_key or getattr(settings, "AI_API_KEY", "")
        self.api_base = (api_base or getattr(settings, "AI_API_BASE", "")).rstrip("/")
        self.model = model or getattr(settings, "AI_MODEL", "gpt-4o-mini")
        self.json_mode = json_mode
        try:
            self.timeout_seconds = int(getattr(settings, "AI_TIMEOUT_SECONDS", timeout_seconds))
        except (TypeError, ValueError):
            self.timeout_seconds = timeout_seconds

    def _configured(self) -> bool:
        return bool(self.api_base)

    @property
    def endpoint(self) -> str:
        return f"{self.api_base}/chat/completions"

    def _headers(self) -> dict[str, str]:
        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers

    def _post(self, body: dict) -> dict:
        request = urllib.request.Request(
            self.endpoint,
            data=json.dumps(body).encode(),
            headers=self._headers(),
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=self.timeout_seconds) as response:
                return json.loads(response.read().decode())
        except urllib.error.HTTPError as exc:
            detail = ""
            try:
                detail = exc.read().decode()[:500]
            except Exception:
                pass
            raise AIRequestError(f"HTTP {exc.code}", status=exc.code, body=detail) from exc
        except Exception as exc:
            raise AIRequestError(type(exc).__name__) from exc

    def _failure(self, exc: AIRequestError) -> Extraction:
        """Turn a transport failure into an actionable blocking question."""
        if exc.status in {401, 403}:
            detail = "The AI provider rejected the credential in AI_API_KEY."
        elif exc.status == 404:
            detail = f"No model endpoint at {self.endpoint} (check AI_API_BASE and AI_MODEL)."
        elif exc.status == 429:
            detail = "The AI provider is rate limiting requests. Try again shortly."
        elif exc.status is not None:
            detail = f"The AI provider returned HTTP {exc.status} for model '{self.model}'."
        else:
            detail = f"The AI service could not be reached at {self.api_base} ({exc})."
        logger.warning("AI request failed: %s %s", exc, redact_for_log(exc.body, limit=200))
        return Extraction(blocking_questions=[detail], model=self.model)

    def extract_with_tool(
        self,
        user_message: str,
        *,
        tool_name: str,
        tool_description: str,
        tool_schema: dict,
        locale: str = "en-IN",
    ) -> dict | None:
        """Ask an OpenAI-compatible model for one typed function call.

        The returned arguments are still untrusted data. Callers must validate
        them before creating any domain object. Provider/parse failures return
        ``None`` so the caller can fail closed.
        """
        if not self._configured():
            return None
        body = {
            "model": self.model,
            "temperature": 0,
            "messages": [
                {
                    "role": "system",
                    "content": (
                        "Extract financial facts from the supplied text. "
                        "Use the provided function. Do not invent missing values."
                    ),
                },
                {"role": "user", "content": f"Input ({locale}): {user_message}"},
            ],
            "tools": [
                {
                    "type": "function",
                    "function": {
                        "name": tool_name,
                        "description": tool_description,
                        "parameters": tool_schema,
                    },
                }
            ],
            "tool_choice": {"type": "function", "function": {"name": tool_name}},
        }
        try:
            payload = self._post(body)
            arguments = payload["choices"][0]["message"]["tool_calls"][0]["function"]["arguments"]
            parsed = json.loads(arguments)
        except (AIRequestError, KeyError, IndexError, TypeError, ValueError) as exc:
            logger.warning("AI tool call failed: %s", type(exc).__name__)
            return None
        return parsed if isinstance(parsed, dict) else None

    def interpret(self, user_message: str, locale: str = "en-IN") -> Extraction | None:
        if not self._configured():
            logger.warning("AI_API_BASE is empty; abstaining to deterministic parsing")
            return None

        body: dict = {
            "model": self.model,
            "temperature": 0,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": f"Input ({locale}): {user_message}"},
            ],
        }
        if self.json_mode:
            body["response_format"] = {"type": "json_object"}

        try:
            try:
                payload = self._post(body)
            except AIRequestError as exc:
                if self.json_mode and exc.status in self.RETRY_WITHOUT_JSON_MODE:
                    # Compatible servers vary; drop the extension and try once more.
                    logger.info("Provider rejected JSON mode (HTTP %s); retrying", exc.status)
                    body.pop("response_format", None)
                    payload = self._post(body)
                else:
                    raise
        except AIRequestError as exc:  # fail closed: surface, do not silently fall back
            return self._failure(exc)

        try:
            content = payload["choices"][0]["message"]["content"]
            data = json.loads(content)
        except (KeyError, IndexError, TypeError, ValueError):
            logger.warning("AI returned non-JSON: %s", redact_for_log(str(payload)[:500]))
            return Extraction(
                blocking_questions=["AI returned an unparseable response"],
                raw_response=redact_for_log(str(payload), limit=500),
                model=self.model,
            )
        return parse_extraction_payload(data, raw_response="", model=self.model)


def get_adapter() -> AssistantAdapter | None:
    """Factory honoring ``USE_AI_INTERPRETER`` + ``AI_PROVIDER``.

    Returns None when AI is disabled (deterministic parsing wins). Unknown
    provider names fail closed to the fake (abstaining) adapter.
    """
    if not getattr(settings, "USE_AI_INTERPRETER", False):
        return None
    provider = str(getattr(settings, "AI_PROVIDER", "fake") or "fake").lower()
    if provider == "fake":
        return FakeAdapter()
    if provider in {"openai_compatible", "openai", "compatible"}:
        return OpenAICompatibleAdapter()
    if provider == "chatgpt":
        from .chatgpt import ChatGPTService

        return ChatGPTService()
    logger.warning("Unknown AI_PROVIDER=%s; using fake adapter", provider)
    return FakeAdapter()
