"""Legacy ChatGPT provider, now one :class:`AssistantAdapter` implementation.

Kept for deployments that still set ``AI_PROVIDER=chatgpt``. New deployments
should use ``AI_PROVIDER=openai_compatible`` with a server-only ``AI_API_KEY``.
"""

from __future__ import annotations

import json
import logging
import re

from django.conf import settings

from .adapter import (
    AssistantAdapter,
    Extraction,
    parse_extraction_payload,
    redact_for_log,
)

logger = logging.getLogger(__name__)

# Back-compat: SYSTEM_PROMPT lives on the adapter boundary now.
from .adapter import SYSTEM_PROMPT  # noqa: E402,F401

# Back-compat alias: historical name for an extraction result.
Interpretation = Extraction


class ChatGPTService(AssistantAdapter):
    name = "chatgpt"

    def __init__(self, session_token: str | None = None):
        # getattr: older settings files lack this key; fail to "unavailable"
        # rather than crashing the request path with AttributeError.
        self.session_token = session_token or getattr(settings, "CHATGPT_SESSION_TOKEN", "")
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

    def interpret(self, user_message: str, locale: str = "en-IN") -> Extraction | None:
        client = self._get_client()
        if client is None:
            return Extraction(blocking_questions=["AI interpreter is not available"])

        prompt = f"{SYSTEM_PROMPT}\n\nUser input ({locale}): {user_message}"
        try:
            response = client.ask(prompt)
        except Exception:
            logger.exception("ChatGPT request failed")
            return Extraction(blocking_questions=["The AI service is unavailable."])

        return self._parse_response(response)

    def _parse_response(self, response: str) -> Extraction:
        text = response.strip()
        match = re.search(r"\{[\s\S]*\}", text)
        if match:
            text = match.group(0)
        try:
            data = json.loads(text)
        except json.JSONDecodeError:
            logger.warning("ChatGPT returned non-JSON: %s", redact_for_log(response))
            return Extraction(
                blocking_questions=["AI returned an unparseable response"],
                raw_response=redact_for_log(response, limit=500),
                model=self.name,
            )
        return parse_extraction_payload(data, raw_response="", model=self.name)


def interpret_with_ai(user_message: str, locale: str = "en-IN") -> Extraction | None:
    if not settings.USE_AI_INTERPRETER:
        return None
    service = ChatGPTService()
    return service.interpret(user_message, locale)
