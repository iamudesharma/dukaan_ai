import json
from unittest.mock import MagicMock

from apps.assistant.adapter import OpenAICompatibleAdapter


def test_tool_calling_returns_validated_json_arguments(monkeypatch):
    adapter = OpenAICompatibleAdapter(
        api_base="https://ai.test/v1",
        model="test-model",
    )
    payload = {
        "choices": [
            {
                "message": {
                    "tool_calls": [
                        {
                            "function": {
                                "name": "record_financial_email",
                                "arguments": json.dumps(
                                    {
                                        "kind": "PAYMENT",
                                        "direction": "RECEIPT",
                                        "party_name": "Ramesh",
                                        "amount_minor": 150000,
                                        "reference": "UPI-123",
                                        "confidence": 0.91,
                                    }
                                ),
                            }
                        }
                    ]
                }
            }
        ]
    }
    adapter._post = MagicMock(return_value=payload)

    result = adapter.extract_with_tool(
        "Ramesh paid 1500 by UPI",
        tool_name="record_financial_email",
        tool_description="Extract a payment",
        tool_schema={"type": "object", "properties": {"amount_minor": {"type": "integer"}}},
    )

    assert result["amount_minor"] == 150000
    body = adapter._post.call_args.args[0]
    assert body["tool_choice"]["function"]["name"] == "record_financial_email"
    assert body["tools"][0]["function"]["name"] == "record_financial_email"


def test_tool_calling_fails_closed_on_bad_payload(monkeypatch):
    adapter = OpenAICompatibleAdapter(api_base="https://ai.test/v1", model="test-model")
    adapter._post = MagicMock(return_value={"choices": []})

    assert (
        adapter.extract_with_tool(
            "unparseable",
            tool_name="record_financial_email",
            tool_description="Extract a payment",
            tool_schema={"type": "object"},
        )
        is None
    )
