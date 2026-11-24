"""doc-extractor OCR seam, Celery worker, and from-image endpoint."""

import json
import urllib.error
from datetime import timedelta
from decimal import Decimal
from unittest.mock import Mock, patch

import pytest
from django.test import override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.assistant.adapter import COMMAND_EXPENSE, COMMAND_PURCHASE, Extraction, ItemCandidate
from apps.assistant.models import AssistantProposal, Attachment
from apps.assistant.ocr import OCRError, OCRResult, get_ocr_engine
from apps.assistant.services import _record_revision
from apps.assistant.tasks import (
    OCR_EMPTY_BLOCKER,
    OCR_FAILED_BLOCKER,
    OCR_OVERSIZE_BLOCKER,
    OCR_TIMEOUT_BLOCKER,
    OCR_UNAVAILABLE_BLOCKER,
    READING_IMAGE_BLOCKER,
    ocr_attachment,
)
from apps.common.models import User
from apps.operations.models import Expense, Purchase, Sale
from apps.tenancy.models import Business, Location, Membership

RAMESH_SENTENCE = "Ramesh bought 3 shirts for ₹2,400, paid ₹1,500, ₹900 pending."
IMAGE_URL = "/api/v1/assistant/proposals/from-image/"
OCR_ENGINE = "doc-extractor/ocria-nano-1"


class _HTTPResponse:
    def __init__(self, body=b"", *, status_code=200, headers=None):
        self.body = body.encode("utf-8") if isinstance(body, str) else body
        self.status = status_code
        self.headers = headers or {}
        self.read_sizes = []
        self.closed = False

    def read(self, size=-1):
        self.read_sizes.append(size)
        return self.body if size is None or size < 0 else self.body[:size]

    def close(self):
        self.closed = True


def _json_response(payload, *, status_code=200):
    return _HTTPResponse(json.dumps(payload).encode("utf-8"), status_code=status_code)


def _mock_http(monkeypatch, responses):
    urlopen = Mock(side_effect=responses)
    monkeypatch.setattr("apps.assistant.ocr.urllib.request.urlopen", urlopen)
    return urlopen


def _request_headers(request):
    return {name.lower(): value for name, value in request.header_items()}


def _multipart_fields(request):
    content_type = _request_headers(request)["content-type"]
    boundary = content_type.split("boundary=", 1)[1].encode("ascii")
    fields = {}
    for part in request.data.split(b"--" + boundary):
        if not part or part in {b"--", b"--\r\n"}:
            continue
        part = part.removeprefix(b"\r\n").removesuffix(b"\r\n")
        raw_headers, separator, body = part.partition(b"\r\n\r\n")
        assert separator
        disposition = next(
            line for line in raw_headers.split(b"\r\n") if line.startswith(b"Content-Disposition:")
        )
        name = disposition.split(b'name="', 1)[1].split(b'"', 1)[0].decode("ascii")
        fields[name] = {"headers": raw_headers, "body": body}
    return fields


def _image_attachment(user, business, **overrides):
    params = {
        "business": business,
        "owner": user,
        "kind": Attachment.Kind.IMAGE,
        "mime": "image/jpeg",
        "size_bytes": 1024,
        "storage_path": f"{business.id}/image/test-upload.jpg",
        "status": Attachment.Status.PENDING,
    }
    params.update(overrides)
    return Attachment.objects.create(**params)


def _image_proposal(shop, attachment, **overrides):
    user, business, location, _ = shop
    params = {
        "business": business,
        "location": location,
        "actor": user,
        "input_type": AssistantProposal.InputType.IMAGE,
        "locale": "en-IN",
        "content": "",
        "command_type": "UNSUPPORTED",
        "payload": {},
        "preview": "",
        "warnings": [],
        "blocking_questions": [READING_IMAGE_BLOCKER],
        "status": AssistantProposal.Status.DRAFT,
        "expires_at": timezone.now() + timedelta(hours=24),
    }
    params.update(overrides)
    proposal = AssistantProposal.objects.create(**params)
    attachment.proposal = proposal
    attachment.save(update_fields=["proposal", "updated_at"])
    _record_revision(proposal)
    return proposal


def _auth_client(user):
    client = APIClient()
    client.force_authenticate(user)
    return client


def _image_payload(attachment, business, location, **overrides):
    payload = {
        "attachment_id": str(attachment.id),
        "business_id": str(business.id),
        "location_id": str(location.id),
        "locale": "en-IN",
    }
    payload.update(overrides)
    return payload


@pytest.fixture
def ocr_settings(settings):
    settings.OCR_ENABLED = True
    settings.OCR_API_URL = "http://127.0.0.1:8790/"
    settings.OCR_API_TOKEN = "test-token"
    settings.OCR_PROVIDER = "ocria"
    settings.OCR_LANGUAGES = "eng+hin"
    settings.OCR_REQUEST_TIMEOUT_SECONDS = 17
    settings.OCR_POLL_TIMEOUT_SECONDS = 30
    settings.OCR_POLL_INTERVAL_SECONDS = 0.001
    settings.OCR_MAX_RESULT_BYTES = 2 * 1024 * 1024
    settings.ATTACHMENT_MAX_BYTES = 8 * 1024 * 1024
    return settings


@pytest.fixture
def stored_document():
    with patch(
        "apps.assistant.storage.FakeStorageBackend.download_bytes",
        lambda self, path: b"document-bytes",
    ):
        yield b"document-bytes"


class TestOCRSeam:
    @pytest.mark.parametrize(
        ("mime", "extension"),
        [("image/jpeg", "jpg"), ("image/png; charset=binary", "png")],
    )
    def test_image_posts_multipart_options_and_bearer_auth(
        self, ocr_settings, monkeypatch, mime, extension
    ):
        upload = _json_response({"id": "job-1", "state": "queued"}, status_code=202)
        completed = _json_response({"id": "job-1", "state": "completed", "total": 1})
        result = _HTTPResponse("  Ramesh bought 3 shirts  \n")
        deleted = _HTTPResponse(status_code=204)
        urlopen = _mock_http(monkeypatch, [upload, completed, result, deleted])

        recognized = get_ocr_engine().recognize(b"image-bytes", mime=mime)

        assert recognized == OCRResult(
            text="Ramesh bought 3 shirts", engine=OCR_ENGINE, page_count=1
        )
        assert urlopen.call_count == 4
        calls = urlopen.call_args_list
        assert [call.args[0].get_method() for call in calls] == ["POST", "GET", "GET", "DELETE"]
        assert [call.args[0].full_url for call in calls] == [
            "http://127.0.0.1:8790/v1/extractions",
            "http://127.0.0.1:8790/v1/extractions/job-1",
            "http://127.0.0.1:8790/v1/extractions/job-1/result?format=text",
            "http://127.0.0.1:8790/v1/extractions/job-1",
        ]
        assert all(call.kwargs["timeout"] == 17 for call in calls)
        assert all(
            _request_headers(call.args[0])["authorization"] == "Bearer test-token" for call in calls
        )

        upload_request = calls[0].args[0]
        fields = _multipart_fields(upload_request)
        assert set(fields) == {"file", "options"}
        assert fields["file"]["body"] == b"image-bytes"
        assert f'filename="document.{extension}"'.encode() in fields["file"]["headers"]
        assert f"Content-Type: {mime.split(';', 1)[0]}".encode() in fields["file"]["headers"]
        assert json.loads(fields["options"]["body"]) == {
            "ocr": True,
            "ocr_provider": "ocria",
            "languages": "eng+hin",
            "result_format": "text",
            "vision": False,
            "interpret_diagrams": False,
        }
        assert upload.closed and completed.closed and result.closed and deleted.closed

    @pytest.mark.parametrize(("total", "expected_pages"), [(12, 5), (3, 3), (None, 1), (0, 1)])
    def test_pdf_options_cap_pages_and_completed_total_drives_page_count(
        self, ocr_settings, monkeypatch, total, expected_pages
    ):
        completed = {"id": "pdf-job", "state": "completed"}
        if total is not None:
            completed["total"] = total
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "pdf-job"}, status_code=202),
                _json_response(completed),
                _HTTPResponse("PDF text"),
                _HTTPResponse(status_code=204),
            ],
        )

        result = get_ocr_engine().recognize(b"pdf-bytes", mime="application/pdf")

        assert result.text == "PDF text"
        assert result.page_count == expected_pages
        fields = _multipart_fields(urlopen.call_args_list[0].args[0])
        assert json.loads(fields["options"]["body"])["pages"] == "1-5"

    def test_polls_active_jobs_before_reading_result(self, ocr_settings, monkeypatch):
        sleep = Mock()
        monkeypatch.setattr("apps.assistant.ocr.time.sleep", sleep)
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response({"id": "job-1", "state": "running", "total": 1}),
                _json_response({"id": "job-1", "state": "queued", "total": 1}),
                _json_response({"id": "job-1", "state": "completed", "total": 1}),
                _HTTPResponse("done"),
                _HTTPResponse(status_code=204),
            ],
        )

        assert get_ocr_engine().recognize(b"image", mime="image/png").text == "done"

        assert sleep.call_count == 2
        assert [call.args[0].get_method() for call in urlopen.call_args_list] == [
            "POST",
            "GET",
            "GET",
            "GET",
            "GET",
            "DELETE",
        ]

    def test_empty_token_omits_authorization(self, ocr_settings, monkeypatch):
        ocr_settings.OCR_API_TOKEN = ""
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response({"state": "completed", "total": 1}),
                _HTTPResponse("text"),
                _HTTPResponse(status_code=204),
            ],
        )

        get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert all(
            "authorization" not in _request_headers(call.args[0]) for call in urlopen.call_args_list
        )

    def test_successful_empty_text_is_returned_for_worker_blocker(self, ocr_settings, monkeypatch):
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response({"state": "completed", "total": 1}),
                _HTTPResponse(" \n"),
                _HTTPResponse(status_code=204),
            ],
        )

        result = get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert result.text == ""
        assert urlopen.call_args_list[-1].args[0].get_method() == "DELETE"

    @pytest.mark.parametrize(
        ("state", "code"),
        [("failed", "job-failed"), ("cancelled", "job-cancelled")],
    )
    def test_terminal_failure_is_rejected_and_remote_job_is_deleted(
        self, ocr_settings, monkeypatch, state, code
    ):
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response(
                    {
                        "id": "job-1",
                        "state": state,
                        "error": {"code": "private-error", "message": "customer-secret.jpg"},
                    }
                ),
                _HTTPResponse(status_code=204),
            ],
        )

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == code
        assert raised.value.retryable is False
        assert [call.args[0].get_method() for call in urlopen.call_args_list] == [
            "POST",
            "GET",
            "DELETE",
        ]
        assert "customer-secret.jpg" not in str(raised.value)

    @pytest.mark.parametrize(
        "job_fields",
        [
            {"warnings": ["OCRia-nano-1 unavailable (model missing); OCR used Tesseract instead"]},
            {
                "unit_failures": [
                    {"code": "provider_error", "message": "OCRia fell back to Tesseract"}
                ]
            },
        ],
    )
    def test_tesseract_fallback_is_rejected_before_result_read(
        self, ocr_settings, monkeypatch, job_fields
    ):
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response({"id": "job-1", "state": "completed", "total": 1, **job_fields}),
                _HTTPResponse(status_code=204),
            ],
        )

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "unavailable"
        assert raised.value.retryable is False
        assert [call.args[0].get_method() for call in urlopen.call_args_list] == [
            "POST",
            "GET",
            "DELETE",
        ]

    def test_unrelated_completed_warning_does_not_reject_result(self, ocr_settings, monkeypatch):
        _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response(
                    {
                        "state": "completed",
                        "total": 1,
                        "warnings": ["Layout confidence is uncalibrated"],
                    }
                ),
                _HTTPResponse("text"),
                _HTTPResponse(status_code=204),
            ],
        )

        assert get_ocr_engine().recognize(b"image", mime="image/jpeg").text == "text"

    def test_request_timeout_is_retryable(self, ocr_settings, monkeypatch):
        urlopen = _mock_http(monkeypatch, [TimeoutError("private-timeout-detail")])

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "timeout"
        assert raised.value.retryable is True
        assert "private-timeout-detail" not in str(raised.value)
        assert urlopen.call_count == 1

    def test_poll_timeout_deletes_remote_job(self, ocr_settings, monkeypatch):
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response({"state": "running", "total": 1}),
                _HTTPResponse(status_code=204),
            ],
        )

        with (
            patch("apps.assistant.ocr.time.monotonic", side_effect=[0.0, 0.0, 31.0]),
            pytest.raises(OCRError) as raised,
        ):
            get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "timeout"
        assert raised.value.retryable is True
        assert urlopen.call_args_list[-1].args[0].get_method() == "DELETE"

    @pytest.mark.parametrize(("status_code", "retryable"), [(400, False), (429, True), (503, True)])
    def test_http_errors_are_safe_and_classified(
        self, ocr_settings, monkeypatch, caplog, status_code, retryable
    ):
        error = urllib.error.HTTPError(
            "http://127.0.0.1:8790/v1/extractions",
            status_code,
            "private HTTP detail",
            {},
            _HTTPResponse(b"private-response-body"),
        )
        urlopen = _mock_http(monkeypatch, [error])

        with caplog.at_level("WARNING", logger="apps.assistant.ocr"):
            with pytest.raises(OCRError) as raised:
                get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "http-error"
        assert raised.value.retryable is retryable
        assert "private HTTP detail" not in str(raised.value)
        assert "private-response-body" not in caplog.text
        assert "test-token" not in caplog.text
        assert urlopen.call_count == 1

    def test_http_200_error_payload_is_not_treated_as_a_job(
        self, ocr_settings, monkeypatch, caplog
    ):
        _mock_http(
            monkeypatch,
            [
                _HTTPResponse(
                    json.dumps(
                        {"error": {"code": "invalid_options", "message": "customer-secret.jpg"}}
                    )
                )
            ],
        )

        with caplog.at_level("WARNING", logger="apps.assistant.ocr"):
            with pytest.raises(OCRError) as raised:
                get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "service-error"
        assert raised.value.retryable is False
        assert "customer-secret.jpg" not in str(raised.value)
        assert "customer-secret.jpg" not in caplog.text

    def test_malformed_poll_response_is_rejected_and_cleaned_up(self, ocr_settings, monkeypatch):
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _HTTPResponse(b"not-json"),
                _HTTPResponse(status_code=204),
            ],
        )

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "malformed-response"
        assert raised.value.retryable is False
        assert urlopen.call_args_list[-1].args[0].get_method() == "DELETE"

    def test_result_size_cap_uses_bounded_read_and_cleans_up(self, ocr_settings, monkeypatch):
        ocr_settings.OCR_MAX_RESULT_BYTES = 4
        oversized_result = _HTTPResponse(b"12345")
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response({"state": "completed", "total": 1}),
                oversized_result,
                _HTTPResponse(status_code=204),
            ],
        )

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "response-too-large"
        assert raised.value.retryable is False
        assert oversized_result.read_sizes == [5]
        assert urlopen.call_args_list[-1].args[0].get_method() == "DELETE"

    def test_invalid_utf8_result_is_rejected_and_cleaned_up(self, ocr_settings, monkeypatch):
        urlopen = _mock_http(
            monkeypatch,
            [
                _json_response({"id": "job-1"}, status_code=202),
                _json_response({"state": "completed", "total": 1}),
                _HTTPResponse(b"\xff"),
                _HTTPResponse(status_code=204),
            ],
        )

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "malformed-response"
        assert urlopen.call_args_list[-1].args[0].get_method() == "DELETE"

    def test_attachment_limit_is_enforced_before_upload(self, ocr_settings, monkeypatch):
        ocr_settings.ATTACHMENT_MAX_BYTES = 4
        urlopen = _mock_http(monkeypatch, [])

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"12345", mime="image/jpeg")

        assert raised.value.code == "oversize"
        assert raised.value.retryable is False
        urlopen.assert_not_called()

    def test_empty_document_is_rejected_before_upload(self, ocr_settings, monkeypatch):
        urlopen = _mock_http(monkeypatch, [])

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"", mime="image/jpeg")

        assert raised.value.code == "empty-document"
        assert raised.value.retryable is False
        urlopen.assert_not_called()

    def test_unsupported_mime_is_rejected_before_upload(self, ocr_settings, monkeypatch):
        urlopen = _mock_http(monkeypatch, [])

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"document", mime="text/plain")

        assert raised.value.code == "unsupported"
        assert raised.value.retryable is False
        urlopen.assert_not_called()

    def test_disabled_ocr_does_not_call_service(self, ocr_settings, monkeypatch):
        ocr_settings.OCR_ENABLED = False
        urlopen = _mock_http(monkeypatch, [])

        with pytest.raises(OCRError) as raised:
            get_ocr_engine().recognize(b"image", mime="image/jpeg")

        assert raised.value.code == "disabled"
        assert raised.value.retryable is False
        urlopen.assert_not_called()

    def test_missing_api_url_is_unavailable(self, ocr_settings):
        ocr_settings.OCR_API_URL = ""

        with pytest.raises(OCRError) as raised:
            get_ocr_engine()

        assert raised.value.code == "unavailable"
        assert raised.value.retryable is False

    @pytest.mark.parametrize(
        "base_url",
        ["ftp://127.0.0.1:8790", "/relative/ocr", "http://", "http://127.0.0.1:8790?x=1"],
    )
    def test_api_url_must_be_http_or_https_base_url(self, ocr_settings, base_url):
        ocr_settings.OCR_API_URL = base_url

        with pytest.raises(OCRError) as raised:
            get_ocr_engine()

        assert raised.value.code == "unavailable"
        assert raised.value.retryable is False

    def test_cleanup_failure_does_not_replace_success(self, ocr_settings, monkeypatch):
        urlopen = Mock(
            side_effect=[
                _json_response({"id": "job-1"}, status_code=202),
                _json_response({"state": "completed", "total": 1}),
                _HTTPResponse("text"),
                TimeoutError("cleanup timeout"),
            ]
        )
        monkeypatch.setattr("apps.assistant.ocr.urllib.request.urlopen", urlopen)

        assert get_ocr_engine().recognize(b"image", mime="image/jpeg").text == "text"
        assert urlopen.call_args_list[-1].args[0].get_method() == "DELETE"


@pytest.mark.django_db
class TestOCRTask:
    @override_settings(USE_AI_INTERPRETER=False)
    def test_image_text_becomes_reviewable_sale_and_redelivery_is_noop(self, shop, stored_document):
        attachment = _image_attachment(shop[0], shop[1])
        proposal = _image_proposal(shop, attachment)
        original_snapshot = proposal.revisions.get(version=1).snapshot
        engine = Mock()
        engine.recognize.return_value = OCRResult(
            text=RAMESH_SENTENCE, engine=OCR_ENGINE, page_count=1
        )

        with patch("apps.assistant.ocr.get_ocr_engine", return_value=engine):
            assert ocr_attachment.run(str(attachment.id)) == "processed"
            engine.recognize.assert_called_once_with(b"document-bytes", mime="image/jpeg")
            engine.recognize.reset_mock()
            assert ocr_attachment.run(str(attachment.id)) == "already-processed"
            engine.recognize.assert_not_called()

        proposal.refresh_from_db()
        attachment.refresh_from_db()
        assert proposal.content == RAMESH_SENTENCE
        assert proposal.command_type == "SALE"
        assert proposal.status == AssistantProposal.Status.READY
        assert proposal.payload["paid_amount_minor"] == 150000
        assert proposal.version == 2
        assert proposal.revisions.count() == 2
        assert proposal.revisions.get(version=1).snapshot == original_snapshot
        assert proposal.revisions.get(version=2).snapshot["content"] == RAMESH_SENTENCE
        assert any("OCR text" in warning for warning in proposal.warnings)
        assert attachment.status == Attachment.Status.READY
        assert not Sale.objects.exists()

    @pytest.mark.parametrize(
        ("command_type", "extraction", "expected_payload_key"),
        [
            (
                COMMAND_PURCHASE,
                Extraction(
                    command_type=COMMAND_PURCHASE,
                    party_name="Mohan",
                    items=[
                        ItemCandidate(
                            product="shirt", quantity=Decimal("3"), unit_price_minor=80000
                        )
                    ],
                    total_minor=240000,
                    paid_minor=150000,
                ),
                "supplier_id",
            ),
            (
                COMMAND_EXPENSE,
                Extraction(
                    command_type=COMMAND_EXPENSE,
                    expense_category="electricity",
                    amount_minor=50000,
                ),
                "amount_minor",
            ),
        ],
    )
    def test_ocr_text_uses_existing_purchase_and_expense_pipeline(
        self, shop, stored_document, command_type, extraction, expected_payload_key
    ):
        attachment = _image_attachment(shop[0], shop[1])
        proposal = _image_proposal(shop, attachment)
        adapter = Mock()
        adapter.interpret.return_value = extraction
        engine = Mock()
        engine.recognize.return_value = OCRResult(
            text="scanned document", engine=OCR_ENGINE, page_count=1
        )

        with (
            patch("apps.assistant.services.get_adapter", return_value=adapter),
            patch("apps.assistant.ocr.get_ocr_engine", return_value=engine),
        ):
            assert ocr_attachment.run(str(attachment.id)) == "processed"

        proposal.refresh_from_db()
        assert proposal.content == "scanned document"
        assert proposal.command_type == command_type
        assert proposal.status == AssistantProposal.Status.READY
        assert expected_payload_key in proposal.payload
        adapter.interpret.assert_called_once_with("scanned document", "en-IN")
        assert not Purchase.objects.exists()
        assert not Expense.objects.exists()

    def test_unavailable_engine_records_durable_blocker(self, shop, stored_document):
        attachment = _image_attachment(shop[0], shop[1])
        proposal = _image_proposal(shop, attachment)
        engine = Mock()
        engine.recognize.side_effect = OCRError(
            "provider unavailable", code="unavailable", retryable=False
        )

        with patch("apps.assistant.ocr.get_ocr_engine", return_value=engine):
            assert ocr_attachment.run(str(attachment.id)) == "ocr-unavailable"

        proposal.refresh_from_db()
        attachment.refresh_from_db()
        assert proposal.status == AssistantProposal.Status.DRAFT
        assert proposal.content == ""
        assert proposal.payload == {}
        assert proposal.blocking_questions == [OCR_UNAVAILABLE_BLOCKER]
        assert proposal.version == 2
        assert proposal.revisions.get(version=2).snapshot["blocking_questions"] == [
            OCR_UNAVAILABLE_BLOCKER
        ]
        assert attachment.status == Attachment.Status.PENDING

    def test_timeout_records_durable_blocker(self, shop, stored_document):
        attachment = _image_attachment(shop[0], shop[1])
        proposal = _image_proposal(shop, attachment)
        engine = Mock()
        engine.recognize.side_effect = OCRError("request timed out", code="timeout")

        with patch("apps.assistant.ocr.get_ocr_engine", return_value=engine):
            assert ocr_attachment.run(str(attachment.id)) == "ocr-failed"

        proposal.refresh_from_db()
        assert proposal.blocking_questions == [OCR_TIMEOUT_BLOCKER]
        assert proposal.content == ""
        assert proposal.status == AssistantProposal.Status.DRAFT

    def test_empty_text_is_not_sent_to_parser(self, shop, stored_document):
        attachment = _image_attachment(shop[0], shop[1])
        proposal = _image_proposal(shop, attachment)
        engine = Mock()
        engine.recognize.return_value = OCRResult(text="", engine=OCR_ENGINE, page_count=1)

        with (
            patch("apps.assistant.ocr.get_ocr_engine", return_value=engine),
            patch("apps.assistant.services._build_from_content") as build,
        ):
            assert ocr_attachment.run(str(attachment.id)) == "empty-text"

        proposal.refresh_from_db()
        assert proposal.blocking_questions == [OCR_EMPTY_BLOCKER]
        assert proposal.content == ""
        assert proposal.payload == {}
        build.assert_not_called()

    @pytest.mark.parametrize("declared_oversize", [True, False])
    @override_settings(ATTACHMENT_MAX_BYTES=8)
    def test_oversize_is_rejected_even_if_storage_metadata_lies(self, shop, declared_oversize):
        attachment = _image_attachment(shop[0], shop[1], size_bytes=9 if declared_oversize else 1)
        proposal = _image_proposal(shop, attachment)

        with patch(
            "apps.assistant.storage.FakeStorageBackend.download_bytes",
            return_value=b"123456789",
        ) as download:
            assert ocr_attachment.run(str(attachment.id)) == "oversize-image"

        proposal.refresh_from_db()
        attachment.refresh_from_db()
        assert proposal.blocking_questions == [OCR_OVERSIZE_BLOCKER]
        assert proposal.content == ""
        assert attachment.status == Attachment.Status.FAILED
        if declared_oversize:
            download.assert_not_called()
        else:
            download.assert_called_once_with(attachment.storage_path)

    def test_failed_run_can_be_retried_without_guessing(self, shop, stored_document):
        attachment = _image_attachment(shop[0], shop[1])
        proposal = _image_proposal(shop, attachment)
        engine = Mock()
        engine.recognize.side_effect = [
            OCRError("engine down", code="network-error"),
            OCRResult(text=RAMESH_SENTENCE, engine=OCR_ENGINE, page_count=1),
        ]

        with patch("apps.assistant.ocr.get_ocr_engine", return_value=engine):
            assert ocr_attachment.run(str(attachment.id)) == "ocr-failed"
            assert ocr_attachment.run(str(attachment.id)) == "processed"

        proposal.refresh_from_db()
        assert proposal.content == RAMESH_SENTENCE
        assert proposal.status == AssistantProposal.Status.READY
        assert proposal.version == 3
        assert proposal.revisions.count() == 3
        assert proposal.revisions.get(version=2).snapshot["blocking_questions"] == [
            OCR_FAILED_BLOCKER
        ]

    def test_cross_owner_proposal_link_is_rejected(self, shop, stored_document):
        user, business, _, _ = shop
        other_user = User.objects.create_user(username="other-ocr-actor")
        attachment = _image_attachment(user, business)
        proposal = _image_proposal(shop, attachment, actor=other_user)
        engine = Mock()

        with patch("apps.assistant.ocr.get_ocr_engine", return_value=engine):
            assert ocr_attachment.run(str(attachment.id)) == "wrong-scope"

        proposal.refresh_from_db()
        assert proposal.content == ""
        assert proposal.version == 1
        engine.recognize.assert_not_called()

    def test_terminal_proposal_and_wrong_kind_are_acknowledged(self, shop, stored_document):
        attachment = _image_attachment(shop[0], shop[1])
        proposal = _image_proposal(shop, attachment, status=AssistantProposal.Status.CANCELLED)
        assert ocr_attachment.run(str(attachment.id)) == "skipped"
        assert proposal.revisions.count() == 1

        voice = _image_attachment(
            shop[0],
            shop[1],
            kind=Attachment.Kind.VOICE,
            mime="audio/m4a",
            storage_path=f"{shop[1].id}/voice/not-an-image.m4a",
        )
        assert ocr_attachment.run(str(voice.id)) == "wrong-kind"
        voice.refresh_from_db()
        assert voice.status == Attachment.Status.FAILED


@pytest.mark.django_db
class TestFromImageEndpoint:
    @pytest.mark.parametrize("mime", ["image/jpeg", "image/png", "application/pdf"])
    def test_creates_draft_and_queues_ocr(self, shop, mime):
        user, business, location, _ = shop
        attachment = _image_attachment(user, business, mime=mime)
        client = _auth_client(user)

        with patch("apps.assistant.views.ocr_attachment.delay") as delay:
            response = client.post(
                IMAGE_URL, _image_payload(attachment, business, location), format="json"
            )

        assert response.status_code == status.HTTP_201_CREATED
        body = response.json()
        assert body["input_type"] == "IMAGE"
        assert body["status"] == "DRAFT"
        assert body["content"] == ""
        assert body["blocking_questions"] == [READING_IMAGE_BLOCKER]
        attachment.refresh_from_db()
        assert str(attachment.proposal_id) == body["id"]
        assert attachment.proposal.revisions.get(version=1).snapshot["content"] == ""
        delay.assert_called_once_with(str(attachment.id))

    def test_retry_reuses_open_image_proposal(self, shop):
        user, business, location, _ = shop
        attachment = _image_attachment(user, business)
        client = _auth_client(user)
        payload = _image_payload(attachment, business, location)

        with patch("apps.assistant.views.ocr_attachment.delay") as delay:
            first = client.post(IMAGE_URL, payload, format="json")
            second = client.post(IMAGE_URL, payload, format="json")

        assert first.status_code == status.HTTP_201_CREATED
        assert second.status_code == status.HTTP_200_OK
        assert first.json()["id"] == second.json()["id"]
        assert AssistantProposal.objects.filter(input_type="IMAGE").count() == 1
        assert delay.call_count == 2

    def test_voice_and_unsupported_mime_are_rejected(self, shop):
        user, business, location, _ = shop
        voice = _image_attachment(
            user,
            business,
            kind=Attachment.Kind.VOICE,
            mime="audio/m4a",
            storage_path=f"{business.id}/voice/input.m4a",
        )
        unsupported = _image_attachment(
            user,
            business,
            mime="image/gif",
            storage_path=f"{business.id}/image/input.gif",
        )
        client = _auth_client(user)

        for attachment in (voice, unsupported):
            with patch("apps.assistant.views.ocr_attachment.delay") as delay:
                response = client.post(
                    IMAGE_URL, _image_payload(attachment, business, location), format="json"
                )
            assert response.status_code == status.HTTP_400_BAD_REQUEST
            delay.assert_not_called()
        assert not AssistantProposal.objects.filter(input_type="IMAGE").exists()

    def test_attachment_from_another_business_is_rejected(self, shop):
        user, business, location, _ = shop
        other = Business.objects.create(name="Other business")
        attachment = _image_attachment(user, other)
        client = _auth_client(user)

        with patch("apps.assistant.views.ocr_attachment.delay") as delay:
            response = client.post(
                IMAGE_URL, _image_payload(attachment, business, location), format="json"
            )

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        delay.assert_not_called()

    def test_other_users_attachment_is_forbidden(self, shop):
        _, business, location, _ = shop
        intruder = User.objects.create_user(username="ocr-intruder")
        Membership.objects.create(user=intruder, business=business, role="OWNER")
        attachment = _image_attachment(shop[0], business)
        client = _auth_client(intruder)

        with patch("apps.assistant.views.ocr_attachment.delay") as delay:
            response = client.post(
                IMAGE_URL, _image_payload(attachment, business, location), format="json"
            )

        assert response.status_code == status.HTTP_403_FORBIDDEN
        delay.assert_not_called()

    def test_location_from_another_business_is_rejected(self, shop):
        user, business, _, _ = shop
        other = Business.objects.create(name="Other location business")
        other_location = Location.objects.create(business=other, code="MAIN", name="Main")
        attachment = _image_attachment(user, business)
        client = _auth_client(user)

        with patch("apps.assistant.views.ocr_attachment.delay") as delay:
            response = client.post(
                IMAGE_URL, _image_payload(attachment, business, other_location), format="json"
            )

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        delay.assert_not_called()

    def test_cashier_without_location_access_is_forbidden(self, shop):
        user, business, location, _ = shop
        Membership.objects.filter(user=user, business=business).update(role="CASHIER")
        attachment = _image_attachment(user, business)
        client = _auth_client(user)

        with patch("apps.assistant.views.ocr_attachment.delay") as delay:
            response = client.post(
                IMAGE_URL, _image_payload(attachment, business, location), format="json"
            )

        assert response.status_code == status.HTTP_403_FORBIDDEN
        delay.assert_not_called()

    def test_unauthenticated_is_rejected(self, shop):
        user, business, location, _ = shop
        attachment = _image_attachment(user, business)
        response = APIClient().post(
            IMAGE_URL, _image_payload(attachment, business, location), format="json"
        )
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_broker_outage_rolls_back_proposal_and_link(self, shop):
        user, business, location, _ = shop
        attachment = _image_attachment(user, business)
        client = _auth_client(user)

        with patch(
            "apps.assistant.views.ocr_attachment.delay", side_effect=RuntimeError("broker down")
        ):
            response = client.post(
                IMAGE_URL, _image_payload(attachment, business, location), format="json"
            )

        assert response.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert not AssistantProposal.objects.filter(input_type="IMAGE").exists()
        attachment.refresh_from_db()
        assert attachment.proposal_id is None

    @override_settings(USE_AI_INTERPRETER=False)
    def test_inline_worker_applies_text_before_response(self, shop, stored_document):
        user, business, location, _ = shop
        attachment = _image_attachment(user, business)
        client = _auth_client(user)
        engine = Mock()
        engine.recognize.return_value = OCRResult(
            text=RAMESH_SENTENCE, engine=OCR_ENGINE, page_count=1
        )

        with (
            patch("apps.assistant.ocr.get_ocr_engine", return_value=engine),
            patch(
                "apps.assistant.views.ocr_attachment.delay",
                side_effect=lambda attachment_id: ocr_attachment.run(attachment_id),
            ) as delay,
        ):
            response = client.post(
                IMAGE_URL, _image_payload(attachment, business, location), format="json"
            )

        assert response.status_code == status.HTTP_201_CREATED
        assert response.json()["status"] == "READY"
        assert response.json()["content"] == RAMESH_SENTENCE
        delay.assert_called_once_with(str(attachment.id))
