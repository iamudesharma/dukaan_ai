import io
import json
import urllib.error
from decimal import Decimal
from unittest.mock import MagicMock, patch
from urllib.error import URLError

import pytest
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.assistant.adapter import (
    COMMAND_EXPENSE,
    COMMAND_PURCHASE,
    COMMAND_SALE,
    Extraction,
    FakeAdapter,
    ItemCandidate,
    OpenAICompatibleAdapter,
    get_adapter,
    parse_extraction_payload,
)
from apps.assistant.chatgpt import ChatGPTService, interpret_with_ai
from apps.assistant.services import _parse_sale, confirm, interpret
from apps.operations.models import Expense, Purchase, Sale
from apps.tenancy.models import Business, Location, Membership

User = get_user_model()


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def user(db):
    return User.objects.create_user(
        username="phone_+919876543210",
        phone_e164="+919876543210",
        password="SecurePass123!",
    )


@pytest.fixture
def business(db, user):
    biz = Business.objects.create(name="Test Shop")
    Location.objects.create(business=biz, code="MAIN", name="Main Store")
    Membership.objects.create(user=user, business=biz, role="OWNER", is_active=True)
    return biz


@pytest.fixture
def location(db, business):
    return business.locations.first()


def _mock_adapter(extraction):
    adapter = MagicMock()
    adapter.interpret.return_value = extraction
    return adapter


class TestExtractionContract:
    def test_parse_valid_sale(self):
        result = parse_extraction_payload(
            {
                "command_type": "SALE",
                "party_name": "Ramesh",
                "items": [{"product": "shirt", "quantity": 3, "unit_price_minor": 80000}],
                "total_minor": 240000,
                "paid_minor": 150000,
                "warnings": [],
                "blocking_questions": [],
            },
            model="test",
        )
        assert result.command_type == "SALE"
        assert result.party_name == "Ramesh"
        assert result.total_minor == 240000
        assert result.is_actionable

    def test_parse_rejects_negative_amount(self):
        result = parse_extraction_payload(
            {"command_type": "SALE", "total_minor": -5, "paid_minor": 0}
        )
        assert result.command_type == "UNKNOWN"
        assert result.blocking_questions

    def test_parse_rejects_unknown_command(self):
        result = parse_extraction_payload({"command_type": "REFUND"})
        assert result.command_type == "UNKNOWN"
        assert result.blocking_questions

    def test_parse_unknown_without_question_gets_one(self):
        result = parse_extraction_payload({"command_type": "UNKNOWN"})
        assert result.command_type == "UNKNOWN"
        assert result.blocking_questions

    def test_parse_supports_all_commands(self):
        for command in ("SALE", "PURCHASE", "PAYMENT", "EXPENSE", "TRANSFER"):
            assert parse_extraction_payload({"command_type": command}).command_type == command

    def test_get_adapter_disabled_returns_none(self, settings):
        settings.USE_AI_INTERPRETER = False
        assert get_adapter() is None

    def test_fake_adapter_abstains(self):
        assert FakeAdapter().interpret("anything") is None

    def test_unconfigured_openai_adapter_abstains(self, settings):
        settings.AI_API_KEY = ""
        settings.AI_API_BASE = ""
        assert OpenAICompatibleAdapter().interpret("hi") is None


class TestOpenAICompatibleAdapter:
    """Keyless local servers and hosted gateways must both work."""

    @staticmethod
    def _reply(payload: dict) -> MagicMock:
        """A urlopen() context manager returning the given JSON body."""
        response = MagicMock()
        response.read.return_value = json.dumps(
            {"choices": [{"message": {"content": json.dumps(payload)}}]}
        ).encode()
        context = MagicMock()
        context.__enter__.return_value = response
        return context

    def test_local_endpoint_needs_no_api_key(self, settings):
        settings.AI_API_BASE = "http://localhost:11434/v1"
        settings.AI_API_KEY = ""
        adapter = OpenAICompatibleAdapter()

        assert adapter._configured()
        with patch(
            "urllib.request.urlopen",
            return_value=self._reply(
                {
                    "command_type": "SALE",
                    "party_name": "Ramesh",
                    "items": [],
                    "total_minor": 240000,
                    "paid_minor": 0,
                    "warnings": [],
                    "blocking_questions": [],
                }
            ),
        ) as urlopen:
            result = adapter.interpret("Ramesh bought 3 shirts for 2400")

        assert result.command_type == "SALE"
        # No credential configured, so no Authorization header is sent.
        headers = urlopen.call_args.args[0].headers
        assert "Authorization" not in headers

    def test_api_key_is_sent_when_configured(self, settings):
        settings.AI_API_BASE = "https://api.openai.com/v1"
        settings.AI_API_KEY = "sk-test-key"
        adapter = OpenAICompatibleAdapter()

        with patch(
            "urllib.request.urlopen",
            return_value=self._reply(
                {
                    "command_type": "UNKNOWN",
                    "items": [],
                    "total_minor": 0,
                    "paid_minor": 0,
                    "warnings": [],
                    "blocking_questions": ["nothing to do"],
                }
            ),
        ) as urlopen:
            adapter.interpret("hello")

        request = urlopen.call_args.args[0]
        assert request.headers["Authorization"] == "Bearer sk-test-key"
        assert request.full_url == "https://api.openai.com/v1/chat/completions"

    def test_retries_without_json_mode_when_the_server_rejects_it(self, settings):
        settings.AI_API_BASE = "http://localhost:11434/v1"
        adapter = OpenAICompatibleAdapter()
        rejection = urllib.error.HTTPError(
            adapter.endpoint, 400, "Bad Request", {}, io.BytesIO(b"response_format unsupported")
        )
        accepted = self._reply(
            {
                "command_type": "SALE",
                "items": [{"product": "shirt", "quantity": 3}],
                "total_minor": 240000,
                "paid_minor": 0,
                "warnings": [],
                "blocking_questions": [],
            }
        )

        with patch("urllib.request.urlopen", side_effect=[rejection, accepted]) as urlopen:
            result = adapter.interpret("Ramesh bought 3 shirts")

        assert result.command_type == "SALE"
        assert urlopen.call_count == 2
        first, second = (json.loads(call.args[0].data) for call in urlopen.call_args_list)
        assert "response_format" in first
        assert "response_format" not in second

    def test_auth_failure_names_the_credential(self, settings):
        settings.AI_API_BASE = "https://api.openai.com/v1"
        adapter = OpenAICompatibleAdapter()
        rejected = urllib.error.HTTPError(
            adapter.endpoint, 401, "Unauthorized", {}, io.BytesIO(b"{}")
        )

        with patch("urllib.request.urlopen", side_effect=rejected):
            result = adapter.interpret("hello")

        assert not result.is_actionable
        assert "AI_API_KEY" in result.blocking_questions[0]

    def test_unreachable_host_names_the_base_url(self, settings):
        settings.AI_API_BASE = "http://localhost:11434/v1"
        adapter = OpenAICompatibleAdapter()

        with patch("urllib.request.urlopen", side_effect=URLError("connection refused")):
            result = adapter.interpret("hello")

        assert not result.is_actionable
        assert "http://localhost:11434/v1" in result.blocking_questions[0]

    def test_trailing_slash_on_base_url_is_tolerated(self, settings):
        settings.AI_API_BASE = "http://localhost:11434/v1/"
        assert OpenAICompatibleAdapter().endpoint == "http://localhost:11434/v1/chat/completions"


class TestChatGPTService:
    def test_parse_valid_json_response(self):
        service = ChatGPTService(session_token="fake-token")
        response = (
            'Here is the result:\n```json\n{"command_type": "SALE", '
            '"party_name": "Ramesh", "items": [{"product": "shirt", '
            '"quantity": 3, "unit_price_minor": 80000}], '
            '"total_minor": 240000, "paid_minor": 150000, '
            '"warnings": [], "blocking_questions": []}\n```'
        )
        result = service._parse_response(response)
        assert result.command_type == "SALE"
        assert result.party_name == "Ramesh"
        assert result.total_minor == 240000
        assert result.is_actionable

    def test_parse_invalid_json_returns_unknown(self):
        service = ChatGPTService(session_token="fake-token")
        result = service._parse_response("I cannot understand this.")
        assert result.command_type == "UNKNOWN"
        assert not result.is_actionable

    def test_interpret_returns_extraction(self):
        service = ChatGPTService(session_token="fake-token")
        mock_client = MagicMock()
        mock_client.ask.return_value = (
            '{"command_type": "SALE", "total_minor": 240000, '
            '"paid_minor": 150000, "items": [], "warnings": [], '
            '"blocking_questions": []}'
        )
        with patch.object(service, "_get_client", return_value=mock_client):
            result = service.interpret("Ramesh bought 3 shirts for 2400")
            assert result.command_type == "SALE"
            assert result.total_minor == 240000

    def test_interpret_handles_client_error(self):
        service = ChatGPTService(session_token="fake-token")
        mock_client = MagicMock()
        mock_client.ask.side_effect = Exception("API error")
        with patch.object(service, "_get_client", return_value=mock_client):
            result = service.interpret("test")
            assert not result.is_actionable
            assert result.blocking_questions

    def test_missing_client_fails_closed(self):
        service = ChatGPTService(session_token="fake-token")
        with patch.object(service, "_get_client", return_value=None):
            result = service.interpret("test")
            assert result.command_type == "UNKNOWN"
            assert result.blocking_questions


class TestInterpretWithAI:
    def test_returns_none_when_disabled(self, settings):
        settings.USE_AI_INTERPRETER = False
        assert interpret_with_ai("test") is None


@pytest.mark.django_db
class TestAssistantWithAI:
    def test_deterministic_parser_accepts_spoken_rupees(self, shop, settings):
        settings.USE_AI_INTERPRETER = False
        _user, business, location, _product = shop

        payload, preview, warnings, blockers = _parse_sale(
            "Ramesh bought 3 shirts for 2400 rupees, paid 1500 rupees, 900 pending",
            business,
            location,
        )

        assert not blockers
        assert payload["lines"][0]["quantity"] == "3"
        assert payload["paid_amount_minor"] == 150000
        assert "2400" in preview

    def test_interpret_uses_fallback_when_ai_disabled(self, api_client, user, business, location):
        refresh = RefreshToken.for_user(user)
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")
        response = api_client.post(
            "/api/v1/assistant/proposals/",
            {
                "business_id": str(business.id),
                "location_id": str(location.id),
                "input_type": "TEXT",
                "content": "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.",
                "locale": "en-IN",
            },
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["command_type"] in ("SALE", "UNSUPPORTED")

    def test_ai_sale_resolves_to_postable_payload(self, shop):
        user, business, location, _ = shop
        extraction = Extraction(
            command_type=COMMAND_SALE,
            party_name="Ramesh",
            items=[ItemCandidate(product="shirt", quantity=Decimal("3"))],
            total_minor=240000,
            paid_minor=150000,
        )
        with patch(
            "apps.assistant.services.get_adapter",
            return_value=_mock_adapter(extraction),
        ):
            proposal = interpret(
                actor=user,
                business=business,
                location=location,
                input_type="TEXT",
                locale="en-IN",
                content="Ramesh bought 3 shirts, total 2400, paid 1500",
            )
        assert proposal.command_type == "SALE"
        assert proposal.status == "READY"
        assert proposal.payload["lines"][0]["unit_price_minor"] == 80000
        assert proposal.payload["paid_amount_minor"] == 150000
        sale, replayed = confirm(
            proposal=proposal, actor=user, version=1, idempotency_key="ai-sale-1"
        )
        assert not replayed
        assert isinstance(sale, Sale)
        assert (sale.grand_total_minor, sale.paid_total_minor, sale.due_total_minor) == (
            240000,
            150000,
            90000,
        )

    def test_ai_purchase_confirms_end_to_end(self, shop):
        user, business, location, _ = shop
        extraction = Extraction(
            command_type=COMMAND_PURCHASE,
            party_name="Sharma Suppliers",
            items=[ItemCandidate(product="shirt", quantity=Decimal("5"))],
            total_minor=400000,
            paid_minor=0,
        )
        with patch(
            "apps.assistant.services.get_adapter",
            return_value=_mock_adapter(extraction),
        ):
            proposal = interpret(
                actor=user,
                business=business,
                location=location,
                input_type="TEXT",
                locale="en-IN",
                content="Bought 5 shirts from Sharma Suppliers for 4000",
            )
        assert proposal.command_type == "PURCHASE"
        assert proposal.status == "READY"
        purchase, _ = confirm(
            proposal=proposal, actor=user, version=1, idempotency_key="ai-purchase-1"
        )
        assert isinstance(purchase, Purchase)
        assert purchase.grand_total_minor == 400000

    def test_ai_expense_confirms_end_to_end(self, shop):
        user, business, location, _ = shop
        extraction = Extraction(
            command_type=COMMAND_EXPENSE,
            expense_category="electricity",
            amount_minor=120000,
        )
        with patch(
            "apps.assistant.services.get_adapter",
            return_value=_mock_adapter(extraction),
        ):
            proposal = interpret(
                actor=user,
                business=business,
                location=location,
                input_type="TEXT",
                locale="en-IN",
                content="Paid 1200 for electricity",
            )
        assert proposal.command_type == "EXPENSE"
        assert proposal.status == "READY"
        expense, _ = confirm(
            proposal=proposal, actor=user, version=1, idempotency_key="ai-expense-1"
        )
        assert isinstance(expense, Expense)
        assert expense.total_minor == 120000

    def test_ai_payment_stays_unconfirmable_with_guidance(self, shop):
        user, business, location, _ = shop
        extraction = Extraction(
            command_type="PAYMENT",
            party_name="Ramesh",
            amount_minor=90000,
            direction="RECEIPT",
        )
        with patch(
            "apps.assistant.services.get_adapter",
            return_value=_mock_adapter(extraction),
        ):
            proposal = interpret(
                actor=user,
                business=business,
                location=location,
                input_type="TEXT",
                locale="en-IN",
                content="Ramesh paid 900",
            )
        assert proposal.command_type == "UNSUPPORTED"
        assert proposal.status == "DRAFT"
        assert proposal.blocking_questions

    def test_ai_failure_is_surfaced_not_silently_reparsed(self, shop):
        user, business, location, _ = shop
        extraction = Extraction(
            command_type="UNKNOWN", blocking_questions=["The AI service is unavailable."]
        )
        with patch(
            "apps.assistant.services.get_adapter",
            return_value=_mock_adapter(extraction),
        ):
            proposal = interpret(
                actor=user,
                business=business,
                location=location,
                input_type="TEXT",
                locale="en-IN",
                content="Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.",
            )
        assert proposal.command_type == "UNSUPPORTED"
        assert proposal.status == "DRAFT"
        assert proposal.blocking_questions == ["The AI service is unavailable."]

    def test_list_endpoints_return_bounded_pages(self, shop):
        user, business, location, _ = shop
        interpret(
            actor=user,
            business=business,
            location=location,
            input_type="TEXT",
            locale="en-IN",
            content="Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending.",
        )
        client = APIClient()
        client.force_authenticate(user)
        proposals = client.get("/api/v1/assistant/proposals/").json()
        assert proposals["count"] == 1
        assert len(proposals["results"]) == 1
        products = client.get("/api/v1/products/", {"business_id": str(business.pk)}).json()
        assert products["count"] == 1
        assert len(products["results"]) == 1
