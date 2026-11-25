"""Server-side speech-to-text seam for voice proposals (P1).

The phone records audio; this module turns stored bytes into a transcript
that feeds the existing P0 pipeline (``_build_from_content``). Providers:

- ``fake`` (default): returns ``STT_FAKE_TRANSCRIPT`` so local dev and tests
  stay hermetic. An empty fake transcript is an honest empty result, never
  silence replaced by guessing.
- ``whisper``: any OpenAI-compatible ``/audio/transcriptions`` endpoint over
  stdlib urllib (hosted OpenAI or a local server). No new dependencies.
- ``local_whisper``: an already-installed ``whisper-cli`` binary and an
  already-downloaded model file. This provider never downloads model weights.

``TranscriptionError`` is the only failure mode: the worker catches it and
records a retryable blocking question. Transport failures never fall back
to regex parsing — an unheard note stays DRAFT, it is never invented.
"""

from __future__ import annotations

import io
import json
import logging
import secrets
import shutil
import subprocess
import tempfile
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path

from django.conf import settings

from .adapter import redact_for_log

logger = logging.getLogger(__name__)


@dataclass
class Transcript:
    text: str
    engine: str
    confidence: float | None = None


class TranscriptionError(Exception):
    """Speech-to-text failed. ``retryable`` tells the worker whether a later
    pass could succeed (network/rate-limit) or not (auth/config). Either way
    the proposal keeps a blocking question — never a guessed transcript."""

    def __init__(self, message: str, *, retryable: bool = True) -> None:
        super().__init__(message)
        self.retryable = retryable


class Transcriber:
    """One interface for every STT provider. Raises TranscriptionError;
    never returns None, never raises anything else."""

    name = "base"

    def transcribe(
        self, audio_bytes: bytes, locale: str = "hi-IN", mime: str = "audio/m4a"
    ) -> Transcript:
        raise NotImplementedError


class FakeTranscriber(Transcriber):
    """Hermetic stand-in: returns the configured fixture transcript."""

    name = "fake-stt"

    def transcribe(
        self, audio_bytes: bytes, locale: str = "hi-IN", mime: str = "audio/m4a"
    ) -> Transcript:
        text = getattr(settings, "STT_FAKE_TRANSCRIPT", "")
        return Transcript(text=text, engine=self.name, confidence=0.99)


def _locale_to_language(locale: str) -> str | None:
    code = (locale or "").lower().replace("_", "-")
    if code.startswith("hi"):
        return "hi"
    if code.startswith("en"):
        return "en"
    return None


def _multipart_body(
    fields: dict[str, str],
    *,
    file_field: str,
    filename: str,
    file_bytes: bytes,
    file_mime: str,
) -> tuple[bytes, str]:
    boundary = "----dukaanai" + secrets.token_hex(16)
    buf = io.BytesIO()
    for key, value in fields.items():
        buf.write(f"--{boundary}\r\n".encode())
        buf.write(f'Content-Disposition: form-data; name="{key}"\r\n\r\n'.encode())
        buf.write(f"{value}\r\n".encode())
    buf.write(f"--{boundary}\r\n".encode())
    buf.write(
        f'Content-Disposition: form-data; name="{file_field}"; filename="{filename}"\r\n'.encode()
    )
    buf.write(f"Content-Type: {file_mime}\r\n\r\n".encode())
    buf.write(file_bytes)
    buf.write(f"\r\n--{boundary}--\r\n".encode())
    return buf.getvalue(), f"multipart/form-data; boundary={boundary}"


class WhisperTranscriber(Transcriber):
    """OpenAI-compatible ``/audio/transcriptions`` over stdlib urllib.

    ``STT_API_BASE`` empty means hosted OpenAI; a local server (or gateway)
    sets its own root. ``STT_API_KEY`` empty is only valid for local servers
    that need no credential — hosted calls without a key fail closed.
    """

    name = "whisper"

    def __init__(
        self,
        *,
        api_key: str = "",
        api_base: str = "",
        model: str = "",
        timeout_seconds: int = 60,
    ) -> None:
        self.api_key = api_key or getattr(settings, "STT_API_KEY", "")
        self.api_base = (
            api_base or getattr(settings, "STT_API_BASE", "") or "https://api.openai.com/v1"
        ).rstrip("/")
        self.model = model or getattr(settings, "STT_MODEL", "whisper-1")
        try:
            self.timeout_seconds = int(getattr(settings, "STT_TIMEOUT_SECONDS", timeout_seconds))
        except (TypeError, ValueError):
            self.timeout_seconds = timeout_seconds

    @property
    def endpoint(self) -> str:
        return f"{self.api_base}/audio/transcriptions"

    def transcribe(
        self, audio_bytes: bytes, locale: str = "hi-IN", mime: str = "audio/m4a"
    ) -> Transcript:
        if not audio_bytes:
            raise TranscriptionError("Empty audio bytes", retryable=False)
        fields = {"model": self.model, "response_format": "json"}
        language = _locale_to_language(locale)
        if language:
            fields["language"] = language
        body, content_type = _multipart_body(
            fields,
            file_field="file",
            filename=f"voice.{mime.split('/')[-1] or 'm4a'}",
            file_bytes=audio_bytes,
            file_mime=mime,
        )
        headers = {"Content-Type": content_type}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        elif "openai.com" in self.api_base:
            raise TranscriptionError(
                "STT_API_KEY is not configured for the hosted Whisper endpoint.",
                retryable=False,
            )
        request = urllib.request.Request(self.endpoint, data=body, headers=headers, method="POST")
        try:
            with urllib.request.urlopen(request, timeout=self.timeout_seconds) as response:
                raw = response.read().decode()
        except urllib.error.HTTPError as exc:
            detail = ""
            try:
                detail = exc.read().decode()[:300]
            except Exception:
                pass
            logger.warning(
                "STT request failed: HTTP %s %s",
                exc.code,
                redact_for_log(detail, limit=200),
            )
            if exc.code in {401, 403}:
                raise TranscriptionError(
                    "The STT provider rejected the credential in STT_API_KEY.",
                    retryable=False,
                ) from exc
            if exc.code == 404:
                raise TranscriptionError(
                    f"No transcription endpoint at {self.endpoint} "
                    "(check STT_API_BASE and STT_MODEL).",
                    retryable=False,
                ) from exc
            raise TranscriptionError(
                f"The STT provider returned HTTP {exc.code}.", retryable=True
            ) from exc
        except Exception as exc:
            logger.warning("STT request failed: %s", type(exc).__name__)
            raise TranscriptionError(
                f"The STT service could not be reached at {self.api_base} ({type(exc).__name__}).",
                retryable=True,
            ) from exc
        try:
            data = json.loads(raw)
            text = data.get("text", "")
        except (ValueError, AttributeError) as exc:
            logger.warning("STT returned non-JSON: %s", redact_for_log(raw[:300]))
            raise TranscriptionError(
                "The STT provider returned an unparseable response.", retryable=False
            ) from exc
        if not isinstance(text, str):
            raise TranscriptionError(
                "The STT provider returned an invalid transcript.", retryable=False
            )
        return Transcript(text=text, engine=self.model, confidence=None)


class LocalWhisperCppTranscriber(Transcriber):
    """Transcribe with a local whisper.cpp CLI and an existing model file.

    No model name is passed to a downloader and no weights are fetched at
    runtime. Both the binary and model must already exist at the configured
    paths. Audio is converted to 16 kHz mono WAV with ffmpeg because whisper.cpp
    does not accept the M4A files produced by the mobile recorder.
    """

    name = "local-whisper.cpp"

    def __init__(
        self,
        *,
        binary: str = "",
        model_path: str = "",
        ffmpeg_binary: str = "",
        threads: int = 4,
        timeout_seconds: int = 180,
    ) -> None:
        self.binary = binary or getattr(settings, "STT_LOCAL_BINARY", "whisper-cli")
        self.model_path = Path(
            model_path or getattr(settings, "STT_LOCAL_MODEL_PATH", "")
        ).expanduser()
        self.ffmpeg_binary = ffmpeg_binary or getattr(settings, "STT_LOCAL_FFMPEG", "ffmpeg")
        try:
            self.threads = int(getattr(settings, "STT_LOCAL_THREADS", threads))
        except (TypeError, ValueError):
            self.threads = threads
        try:
            self.timeout_seconds = int(
                getattr(settings, "STT_LOCAL_TIMEOUT_SECONDS", timeout_seconds)
            )
        except (TypeError, ValueError):
            self.timeout_seconds = timeout_seconds

    def _require_local_files(self) -> None:
        if not self.model_path.is_file():
            raise TranscriptionError(
                "The local speech model is missing. Set STT_LOCAL_MODEL_PATH to an "
                "already-downloaded model; DukaanAI will not download one.",
                retryable=False,
            )
        if shutil.which(self.binary) is None:
            raise TranscriptionError(
                f"Local transcription binary {self.binary!r} is not installed.",
                retryable=False,
            )
        if shutil.which(self.ffmpeg_binary) is None:
            raise TranscriptionError(
                f"Audio converter {self.ffmpeg_binary!r} is not installed.",
                retryable=False,
            )

    def transcribe(
        self, audio_bytes: bytes, locale: str = "hi-IN", mime: str = "audio/m4a"
    ) -> Transcript:
        if not audio_bytes:
            raise TranscriptionError("Empty audio bytes", retryable=False)
        self._require_local_files()
        language = _locale_to_language(locale) or "auto"
        extension = {
            "audio/m4a": "m4a",
            "audio/mp4": "m4a",
            "audio/x-m4a": "m4a",
            "audio/wav": "wav",
        }.get(mime, "audio")

        with tempfile.TemporaryDirectory(prefix="dukaan-stt-") as directory:
            root = Path(directory)
            source = root / f"input.{extension}"
            wav = root / "input.wav"
            output = root / "transcript"
            source.write_bytes(audio_bytes)

            try:
                converted = subprocess.run(
                    [
                        self.ffmpeg_binary,
                        "-y",
                        "-loglevel",
                        "error",
                        "-i",
                        str(source),
                        "-ar",
                        "16000",
                        "-ac",
                        "1",
                        "-c:a",
                        "pcm_s16le",
                        str(wav),
                    ],
                    capture_output=True,
                    text=True,
                    timeout=self.timeout_seconds,
                    check=False,
                )
            except (OSError, subprocess.TimeoutExpired) as exc:
                raise TranscriptionError("Local audio conversion failed") from exc
            if converted.returncode != 0:
                raise TranscriptionError("Local audio conversion failed", retryable=False)

            try:
                result = subprocess.run(
                    [
                        self.binary,
                        "-m",
                        str(self.model_path),
                        "-f",
                        str(wav),
                        "-l",
                        language,
                        "-t",
                        str(self.threads),
                        "-oj",
                        "-of",
                        str(output),
                        "-np",
                        "-nt",
                        "--no-gpu",
                    ],
                    capture_output=True,
                    text=True,
                    timeout=self.timeout_seconds,
                    check=False,
                )
            except (OSError, subprocess.TimeoutExpired) as exc:
                raise TranscriptionError("Local transcription timed out or failed") from exc
            if result.returncode != 0:
                logger.warning("Local whisper.cpp failed with exit code %s", result.returncode)
                raise TranscriptionError("Local transcription failed", retryable=False)

            try:
                payload = json.loads(output.with_suffix(".json").read_text())
                segments = payload["transcription"]
                text = " ".join(
                    str(segment.get("text", "")).strip()
                    for segment in segments
                    if isinstance(segment, dict)
                ).strip()
            except (OSError, ValueError, KeyError, TypeError) as exc:
                raise TranscriptionError(
                    "Local transcription returned an unreadable result", retryable=False
                ) from exc

        return Transcript(text=text, engine=self.name, confidence=None)


def get_transcriber() -> Transcriber:
    """Factory honoring ``STT_PROVIDER``. Unknown names fail closed to the
    fake transcriber (empty transcript → retryable blocker, never a guess)."""
    provider = str(getattr(settings, "STT_PROVIDER", "fake") or "fake").lower()
    if provider in {"whisper", "openai"}:
        return WhisperTranscriber()
    if provider in {"local_whisper", "whisper_cpp", "local"}:
        return LocalWhisperCppTranscriber()
    if provider != "fake":
        logger.warning("Unknown STT_PROVIDER=%s; using fake transcriber", provider)
    return FakeTranscriber()
