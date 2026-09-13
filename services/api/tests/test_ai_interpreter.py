import uuid
from unittest.mock import MagicMock, patch

import pytest
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.assistant.chatgpt import ChatGPTService, Interpretation, interpret_with_ai
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


class TestChatGPTService:
    def test_parse_valid_json_response(self):
        service = ChatGPTService(session_token="fake-token")
        response = (
            'Here is the result:\n```json\n{"command_type": "SALE", "customer_name": "Ramesh", '
            '"items": [{"product": "shirt", "quantity": 3, "unit_price_minor": 80000}], '
            '"total_minor": 240000, "paid_minor": 150000, "warnings": [], '
            '"blocking_questions": []}\n```'
        )
        result = service._parse_response(response)
        assert result.command_type == "SALE"
        assert result.customer_name == "Ramesh"
        assert result.total_minor == 240000
        assert result.is_valid

    def test_parse_invalid_json_returns_unknown(self):
        service = ChatGPTService(session_token="fake-token")
        result = service._parse_response("I cannot understand this.")
        assert result.command_type == "UNKNOWN"
        assert not result.is_valid

    def test_interpret_returns_interpretation(self):
        service = ChatGPTService(session_token="fake-token")
        mock_client = MagicMock()
        mock_client.ask.return_value = (
            '{"command_type": "SALE", "total_minor": 240000, "paid_minor": 150000, '
            '"items": [], "warnings": [], "blocking_questions": []}'
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
            assert not result.is_valid
            assert "AI request failed" in result.blocking_questions[0]


class TestInterpretWithAI:
    def test_returns_none_when_disabled(self):
        with patch("apps.assistant.chatgpt.settings") as mock_settings:
            mock_settings.USE_AI_INTERPRETER = False
            result = interpret_with_ai("test")
            assert result is None

    def test_returns_interpretation_when_enabled(self):
        with patch("apps.assistant.chatgpt.settings") as mock_settings:
            mock_settings.USE_AI_INTERPRETER = True
            mock_service = MagicMock()
            mock_service.interpret.return_value = Interpretation(
                command_type="SALE", total_minor=240000
            )
            with patch("apps.assistant.chatgpt.ChatGPTService", return_value=mock_service):
                result = interpret_with_ai("test")
                assert result is not None
                assert result.command_type == "SALE"


@pytest.mark.django_db
class TestAssistantWithAI:
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

    def test_interpret_with_ai_enabled(self, api_client, user, business, location):
        with patch("apps.assistant.services._interpret_with_ai") as mock_ai:
            mock_ai.return_value = (
                {
                    "business_id": str(business.id),
                    "location_id": str(location.id),
                    "customer_id": None,
                    "new_customer_name": "Ramesh",
                    "lines": [
                        {
                            "pack_id": str(uuid.uuid4()),
                            "quantity": "3",
                            "unit_price_minor": 80000,
                            "discount_minor": 0,
                        }
                    ],
                    "paid_amount_minor": 150000,
                    "total_minor": 240000,
                },
                "Party: Ramesh; 3 × shirt; Total: ₹2400.00; Paid: ₹1500.00",
                [],
                [],
                "SALE",
            )
            refresh = RefreshToken.for_user(user)
            api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")
            response = api_client.post(
                "/api/v1/assistant/proposals/",
                {
                    "business_id": str(business.id),
                    "location_id": str(location.id),
                    "input_type": "TEXT",
                    "content": "Ramesh bought 3 shirts for 2400",
                    "locale": "en-IN",
                },
            )
            assert response.status_code == status.HTTP_201_CREATED
            assert response.data["command_type"] == "SALE"
            assert "Ramesh" in response.data["preview"]
            labels = [fact["label"] for fact in response.data["preview_data"]["facts"]]
            assert "Party" in labels
