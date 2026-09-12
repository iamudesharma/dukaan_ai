from __future__ import annotations

import json
import logging
import re
from dataclasses import dataclass, field

from django.conf import settings

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are DukaanAI, a business assistant for Indian shop owners.
Extract structured sale, purchase, payment, or expense information from natural
language input in Hindi, Hinglish, or English.

Respond ONLY with valid JSON in this exact format:
{
  "command_type": "SALE|PURCHASE|PAYMENT|EXPENSE",
  "customer_name": "string or null",
  "items": [{"product": "string", "quantity": number, "unit_price_minor": number}],
  "total_minor": number,
  "paid_minor": number,
  "warnings": ["string"],
  "blocking_questions": ["string"]
}

Rules:
- All amounts are in paise (1 rupee = 100 paise). Convert ₹2,400 to 240000.
- If information is missing, use blocking_questions to ask for it.
- If the input is unclear, set command_type to "UNKNOWN" and explain in blocking_questions.
- quantity should be a number (can be decimal for weights like 2.5).
- unit_price_minor is price per unit in paise."""


@dataclass
class Interpretation:
    command_type: str = "UNKNOWN"
    customer_name: str | None = None
    items: list[dict] = field(default_factory=list)
    total_minor: int = 0
    paid_minor: int = 0
    warnings: list[str] = field(default_factory=list)
    blocking_questions: list[str] = field(default_factory=list)
    raw_response: str = ""

    @property
    def is_valid(self) -> bool:
        return self.command_type != "UNKNOWN" and not self.blocking_questions


class ChatGPTService:
    def __init__(self, session_token: str | None = None):
        self.session_token = session_token or settings.CHATGPT_SESSION_TOKEN
        self._client = None

    def _get_client(self):
        if self._client is not None:
            return self._client
        try:
            from revChatGPT.V3 import Chatbot

            self._client = Chatbot(api_key="", engine="gpt-4o-mini")
        except ImportError:
            logger.warning("revChatGPT not installed; AI interpreter unavailable")
            return None
        return self._client

    def interpret(self, user_message: str, locale: str = "en-IN") -> Interpretation:
        client = self._get_client()
        if client is None:
            return Interpretation(blocking_questions=["AI interpreter is not available"])

        prompt = f"{SYSTEM_PROMPT}\n\nUser input ({locale}): {user_message}"
        try:
            response = client.ask(prompt)
        except Exception as exc:
            logger.exception("ChatGPT request failed")
            return Interpretation(blocking_questions=[f"AI request failed: {exc}"])

        return self._parse_response(response)

    def _parse_response(self, response: str) -> Interpretation:
        text = response.strip()
        match = re.search(r"\{[\s\S]*\}", text)
        if match:
            text = match.group(0)

        try:
            data = json.loads(text)
        except json.JSONDecodeError:
            logger.warning("ChatGPT returned non-JSON: %s", response[:200])
            return Interpretation(
                raw_response=response,
                blocking_questions=["AI returned an unparseable response"],
            )

        return Interpretation(
            command_type=data.get("command_type", "UNKNOWN"),
            customer_name=data.get("customer_name"),
            items=data.get("items", []),
            total_minor=int(data.get("total_minor", 0)),
            paid_minor=int(data.get("paid_minor", 0)),
            warnings=data.get("warnings", []),
            blocking_questions=data.get("blocking_questions", []),
            raw_response=response,
        )


def interpret_with_ai(user_message: str, locale: str = "en-IN") -> Interpretation | None:
    if not settings.USE_AI_INTERPRETER:
        return None
    service = ChatGPTService()
    return service.interpret(user_message, locale)
