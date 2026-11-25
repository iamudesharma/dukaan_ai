"""Phase-1 voice transcription: provider seam, worker task, from-audio endpoint."""

import urllib.request
from datetime import timedelta
from unittest.mock import patch

import pytest
from django.test import override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.assistant.models import AssistantProposal, Attachment
from apps.assistant.tasks import transcribe_attachment
from apps.assistant.transcription import (
    FakeTranscriber,
    Transcriber,
    TranscriptionError,
    WhisperTranscriber,
    get_transcriber,
)
from apps.operations.models import Sale

pytestmark = pytest.mark.django_db

RAMESH_SENTENCE = "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending."


def _voice_attachment(user, business, **overrides):
    params = {
        "business": business,
        "owner": user,
        "kind": Attachment.Kind.VOICE,
        "mime": "audio/m4a",
        "size_bytes": 1024,
        "storage_path": f"{business.id}/voice/test-note.m4a",
        "status": Attachment.Status.PENDING,
    }
    params.update(overrides)
    return Attachment.objects.create(**params)


def _auth_client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


@pytest.fixture
def stored_audio():
    """Stage bytes on the fake backend: the fake is per-instance in memory,
    so without this the worker would (correctly) report fetch-failed."""
    with patch(
        "apps.assistant.storage.FakeStorageBackend.download_bytes",
        lambda self, path: b"fake-audio-bytes",
    ):
        yield b"fake-audio-bytes"


class TestTranscribeTaskEndToEnd:
    @override_settings(STT_FAKE_TRANSCRIPT=RAMESH_SENTENCE)
    def test_fake_transcript_becomes_ready_sale(self, shop, stored_audio):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        proposal = AssistantProposal.objects.create(
            business=business,
            location=location,
            actor=user,
            input_type=AssistantProposal.InputType.VOICE,
            locale="en-IN",
            content="",
            command_type="UNSUPPORTED",
            payload={},
            preview="",
            warnings=[],
            blocking_questions=["Your voice note is being transcribed."],
            status=AssistantProposal.Status.DRAFT,
            expires_at=timezone.now() + timedelta(hours=24),
        )
        attachment.proposal = proposal
        attachment.save(update_fields=["proposal", "updated_at"])

        assert transcribe_attachment.run(str(attachment.id)) == "processed"

        proposal.refresh_from_db()
        attachment.refresh_from_db()
        assert proposal.content == RAMESH_SENTENCE
        assert proposal.command_type == "SALE"
        assert proposal.status == "READY"
        assert proposal.version == 2
        assert proposal.revisions.count() == 1
        assert attachment.status == Attachment.Status.READY
        assert any("Voice transcript" in w for w in proposal.warnings)

    @override_settings(STT_FAKE_TRANSCRIPT=RAMESH_SENTENCE)
    def test_confirm_posts_sale_from_transcript(self, shop, stored_audio):
        from apps.assistant.services import confirm

        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        proposal = AssistantProposal.objects.create(
            business=business,
            location=location,
            actor=user,
            input_type=AssistantProposal.InputType.VOICE,
            locale="en-IN",
            content="",
            command_type="UNSUPPORTED",
            payload={},
            preview="",
            warnings=[],
            blocking_questions=["Your voice note is being transcribed."],
            status=AssistantProposal.Status.DRAFT,
            expires_at=timezone.now() + timedelta(hours=24),
        )
        attachment.proposal = proposal
        attachment.save(update_fields=["proposal", "updated_at"])
        transcribe_attachment.run(str(attachment.id))
        proposal.refresh_from_db()
        sale, replayed = confirm(
            proposal=proposal, actor=user, version=2, idempotency_key="voice-sale-1"
        )
        assert not replayed
        assert isinstance(sale, Sale)
        assert (sale.grand_total_minor, sale.paid_total_minor, sale.due_total_minor) == (
            240000,
            150000,
            90000,
        )

    @override_settings(STT_FAKE_TRANSCRIPT=RAMESH_SENTENCE)
    def test_redelivery_after_success_is_noop(self, shop, stored_audio):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        proposal = AssistantProposal.objects.create(
            business=business,
            location=location,
            actor=user,
            input_type=AssistantProposal.InputType.VOICE,
            locale="en-IN",
            content="",
            command_type="UNSUPPORTED",
            payload={},
            preview="",
            warnings=[],
            blocking_questions=["Your voice note is being transcribed."],
            status=AssistantProposal.Status.DRAFT,
            expires_at=timezone.now() + timedelta(hours=24),
        )
        attachment.proposal = proposal
        attachment.save(update_fields=["proposal", "updated_at"])
        assert transcribe_attachment.run(str(attachment.id)) == "processed"
        assert transcribe_attachment.run(str(attachment.id)) == "already-processed"
        proposal.refresh_from_db()
        assert proposal.version == 2
        assert proposal.revisions.count() == 1

    @override_settings(STT_FAKE_TRANSCRIPT=RAMESH_SENTENCE)
    def test_retry_after_failure_reprocesses(self, shop, stored_audio):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        proposal = AssistantProposal.objects.create(
            business=business,
            location=location,
            actor=user,
            input_type=AssistantProposal.InputType.VOICE,
            locale="en-IN",
            content="",
            command_type="UNSUPPORTED",
            payload={},
            preview="",
            warnings=[],
            blocking_questions=["Your voice note is being transcribed."],
            status=AssistantProposal.Status.DRAFT,
            expires_at=timezone.now() + timedelta(hours=24),
        )
        attachment.proposal = proposal
        attachment.save(update_fields=["proposal", "updated_at"])
        with patch(
            "apps.assistant.transcription.get_transcriber",
            side_effect=TranscriptionError("boom"),
        ):
            assert transcribe_attachment.run(str(attachment.id)) == "transcription-failed"
        proposal.refresh_from_db()
        assert proposal.status == "DRAFT"
        assert proposal.content == ""
        assert transcribe_attachment.run(str(attachment.id)) == "processed"
        proposal.refresh_from_db()
        assert proposal.status == "READY"


class TestTranscribeTaskFailures:
    def test_provider_outage_stays_draft_with_blocker(self, shop, stored_audio):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        proposal = AssistantProposal.objects.create(
            business=business,
            location=location,
            actor=user,
            input_type=AssistantProposal.InputType.VOICE,
            locale="en-IN",
            content="",
            command_type="UNSUPPORTED",
            payload={},
            preview="",
            warnings=[],
            blocking_questions=["Your voice note is being transcribed."],
            status=AssistantProposal.Status.DRAFT,
            expires_at=timezone.now() + timedelta(hours=24),
        )
        attachment.proposal = proposal
        attachment.save(update_fields=["proposal", "updated_at"])
        with patch(
            "apps.assistant.transcription.get_transcriber",
            side_effect=TranscriptionError("provider down"),
        ):
            assert transcribe_attachment.run(str(attachment.id)) == "transcription-failed"
        proposal.refresh_from_db()
        attachment.refresh_from_db()
        # Surfaced, never silently re-parsed: no payload, no content, still ours.
        assert proposal.status == "DRAFT"
        assert proposal.command_type == "UNSUPPORTED"
        assert proposal.payload == {}
        assert proposal.content == ""
        assert proposal.blocking_questions == [
            "Voice transcription failed. Please try sending it again."
        ]
        assert attachment.status == Attachment.Status.PENDING

    @override_settings(STT_FAKE_TRANSCRIPT="")
    def test_empty_transcript_needs_rerecording(self, shop, stored_audio):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        proposal = AssistantProposal.objects.create(
            business=business,
            location=location,
            actor=user,
            input_type=AssistantProposal.InputType.VOICE,
            locale="en-IN",
            content="",
            command_type="UNSUPPORTED",
            payload={},
            preview="",
            warnings=[],
            blocking_questions=["Your voice note is being transcribed."],
            status=AssistantProposal.Status.DRAFT,
            expires_at=timezone.now() + timedelta(hours=24),
        )
        attachment.proposal = proposal
        attachment.save(update_fields=["proposal", "updated_at"])
        assert transcribe_attachment.run(str(attachment.id)) == "empty-transcript"
        proposal.refresh_from_db()
        assert proposal.status == "DRAFT"
        assert "hear anything" in proposal.blocking_questions[0]

    def test_missing_object_is_retryable_blocker(self, shop):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        proposal = AssistantProposal.objects.create(
            business=business,
            location=location,
            actor=user,
            input_type=AssistantProposal.InputType.VOICE,
            locale="en-IN",
            content="",
            command_type="UNSUPPORTED",
            payload={},
            preview="",
            warnings=[],
            blocking_questions=["Your voice note is being transcribed."],
            status=AssistantProposal.Status.DRAFT,
            expires_at=timezone.now() + timedelta(hours=24),
        )
        attachment.proposal = proposal
        attachment.save(update_fields=["proposal", "updated_at"])
        # Fake backend holds nothing: the client's "upload finished" claim
        # is verified server-side instead of trusted.
        assert transcribe_attachment.run(str(attachment.id)) == "fetch-failed"
        proposal.refresh_from_db()
        assert proposal.status == "DRAFT"
        assert "fetch your voice note" in proposal.blocking_questions[0]

    def test_missing_attachment_acknowledges(self, shop):
        import uuid

        assert transcribe_attachment.run(str(uuid.uuid4())) == "missing"

    def test_non_voice_attachment_fails_closed(self, shop):
        user, business, _, _ = shop
        attachment = _voice_attachment(
            user, business, kind=Attachment.Kind.IMAGE, mime="image/jpeg"
        )
        assert transcribe_attachment.run(str(attachment.id)) == "wrong-kind"
        attachment.refresh_from_db()
        assert attachment.status == Attachment.Status.FAILED


class TestTranscriberSeam:
    def test_fake_returns_configured_transcript(self, settings):
        settings.STT_FAKE_TRANSCRIPT = "hello"
        result = FakeTranscriber().transcribe(b"bytes", "hi-IN")
        assert result.text == "hello"
        assert result.engine == "fake-stt"
        assert result.confidence is not None

    def test_unknown_provider_falls_back_to_fake(self, settings):
        settings.STT_PROVIDER = "deepgram"
        assert isinstance(get_transcriber(), FakeTranscriber)

    def test_whisper_without_key_fails_closed(self, settings):
        settings.STT_API_KEY = ""
        settings.STT_API_BASE = "https://api.openai.com/v1"
        with pytest.raises(TranscriptionError):
            WhisperTranscriber().transcribe(b"bytes", "hi-IN")

    def test_whisper_parses_text(self, settings, monkeypatch):
        settings.STT_API_KEY = "sk-test"
        settings.STT_API_BASE = "https://api.openai.com/v1"

        class Reply:
            def __enter__(self):
                return self

            def __exit__(self, *args):
                return False

            def read(self):
                return b'{"text": "ramesh ne shirt liya"}'

        monkeypatch.setattr(urllib.request, "urlopen", lambda *a, **k: Reply())
        result = WhisperTranscriber().transcribe(b"bytes", "hi-IN")
        assert result.text == "ramesh ne shirt liya"

    def test_whisper_non_json_fails_closed(self, settings, monkeypatch):
        settings.STT_API_KEY = "sk-test"
        settings.STT_API_BASE = "https://api.openai.com/v1"

        class Reply:
            def __enter__(self):
                return self

            def __exit__(self, *args):
                return False

            def read(self):
                return b"not json"

        monkeypatch.setattr(urllib.request, "urlopen", lambda *a, **k: Reply())
        with pytest.raises(TranscriptionError):
            WhisperTranscriber().transcribe(b"bytes", "hi-IN")

    def test_base_transcriber_is_abstract(self):
        with pytest.raises(NotImplementedError):
            Transcriber().transcribe(b"bytes", "hi-IN")


class TestFromAudioEndpoint:
    def test_creates_draft_and_queues_task(self, shop):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        client = _auth_client(user)
        with patch("apps.assistant.views.transcribe_attachment.delay") as delay:
            response = client.post(
                "/api/v1/assistant/proposals/from-audio/",
                {
                    "attachment_id": str(attachment.id),
                    "business_id": str(business.id),
                    "location_id": str(location.id),
                    "locale": "hi-IN",
                },
                format="json",
            )
        assert response.status_code == status.HTTP_201_CREATED
        body = response.json()
        assert body["input_type"] == "VOICE"
        assert body["status"] == "DRAFT"
        assert body["blocking_questions"] == ["Your voice note is being transcribed."]
        assert body["content"] == ""
        attachment.refresh_from_db()
        assert str(attachment.proposal_id) == body["id"]
        delay.assert_called_once_with(str(attachment.id))

    def test_client_retry_reuses_open_proposal(self, shop):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        client = _auth_client(user)
        payload = {
            "attachment_id": str(attachment.id),
            "business_id": str(business.id),
            "location_id": str(location.id),
            "locale": "hi-IN",
        }
        with patch("apps.assistant.views.transcribe_attachment.delay"):
            first = client.post("/api/v1/assistant/proposals/from-audio/", payload, format="json")
            second = client.post("/api/v1/assistant/proposals/from-audio/", payload, format="json")
        assert first.status_code == status.HTTP_201_CREATED
        assert second.status_code == status.HTTP_200_OK
        assert first.json()["id"] == second.json()["id"]
        assert AssistantProposal.objects.count() == 1

    def test_non_voice_attachment_rejected(self, shop):
        user, business, location, _ = shop
        attachment = _voice_attachment(
            user, business, kind=Attachment.Kind.IMAGE, mime="image/jpeg"
        )
        client = _auth_client(user)
        response = client.post(
            "/api/v1/assistant/proposals/from-audio/",
            {
                "attachment_id": str(attachment.id),
                "business_id": str(business.id),
                "location_id": str(location.id),
            },
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_other_users_recording_is_forbidden(self, shop, db):
        from apps.common.models import User
        from apps.tenancy.models import Membership

        _, business, location, _ = shop
        intruder = User.objects.create_user(username="intruder")
        Membership.objects.create(user=intruder, business=business, role="OWNER")
        attachment = _voice_attachment(shop[0], business)
        client = _auth_client(intruder)
        response = client.post(
            "/api/v1/assistant/proposals/from-audio/",
            {
                "attachment_id": str(attachment.id),
                "business_id": str(business.id),
                "location_id": str(location.id),
            },
            format="json",
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_unauthenticated_is_rejected(self, shop):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        response = APIClient().post(
            "/api/v1/assistant/proposals/from-audio/",
            {
                "attachment_id": str(attachment.id),
                "business_id": str(business.id),
                "location_id": str(location.id),
            },
            format="json",
        )
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_broker_outage_rolls_back_and_errors(self, shop):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        client = _auth_client(user)
        with patch(
            "apps.assistant.views.transcribe_attachment.delay",
            side_effect=RuntimeError("broker down"),
        ):
            response = client.post(
                "/api/v1/assistant/proposals/from-audio/",
                {
                    "attachment_id": str(attachment.id),
                    "business_id": str(business.id),
                    "location_id": str(location.id),
                },
                format="json",
            )
        assert response.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        # The endpoint is atomic: nothing persists, so the client re-POSTs
        # from scratch and the retry path mints exactly one proposal.
        assert AssistantProposal.objects.filter(input_type="VOICE").count() == 0


class TestFromAudioEagerRunsInline:
    @override_settings(CELERY_TASK_ALWAYS_EAGER=True, STT_FAKE_TRANSCRIPT=RAMESH_SENTENCE)
    def test_eager_worker_applies_transcript_before_response(self, shop):
        user, business, location, _ = shop
        attachment = _voice_attachment(user, business)
        client = _auth_client(user)

        def download(self, path):
            assert path == attachment.storage_path
            return b"fake-audio-bytes"

        with (
            patch("apps.assistant.storage.FakeStorageBackend.download_bytes", download),
            patch("apps.assistant.views.transcribe_attachment.delay") as delay,
        ):
            # The endpoint always enqueues; here we run the worker inline to
            # prove the full loop without a broker.
            response = client.post(
                "/api/v1/assistant/proposals/from-audio/",
                {
                    "attachment_id": str(attachment.id),
                    "business_id": str(business.id),
                    "location_id": str(location.id),
                    "locale": "en-IN",
                },
                format="json",
            )
            assert response.status_code == status.HTTP_201_CREATED
            assert delay.call_count == 1
            assert transcribe_attachment.run(str(attachment.id)) == "processed"
        proposal = AssistantProposal.objects.get(pk=response.json()["id"])
        assert proposal.status == "READY"
        assert proposal.content == RAMESH_SENTENCE
