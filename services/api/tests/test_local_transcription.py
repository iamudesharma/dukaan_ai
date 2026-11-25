import json
import subprocess
from pathlib import Path

import pytest

from apps.assistant.transcription import LocalWhisperCppTranscriber, TranscriptionError


def _completed(returncode=0):
    return subprocess.CompletedProcess(args=[], returncode=returncode, stdout="", stderr="")


def test_local_whisper_never_downloads_and_parses_json(tmp_path, monkeypatch):
    model = tmp_path / "ggml-base.bin"
    model.write_bytes(b"local model")
    calls = []

    monkeypatch.setattr(
        "apps.assistant.transcription.shutil.which",
        lambda binary: f"/usr/local/bin/{binary}",
    )

    def fake_run(args, **kwargs):
        calls.append(args)
        if args[0] == "ffmpeg":
            Path(args[-1]).write_bytes(b"wav")
            return _completed()
        output = Path(args[args.index("-of") + 1]).with_suffix(".json")
        output.write_text(
            json.dumps(
                {
                    "transcription": [
                        {"text": " Ramesh bought three shirts"},
                        {"text": "for 2400 rupees "},
                    ]
                }
            )
        )
        return _completed()

    monkeypatch.setattr("apps.assistant.transcription.subprocess.run", fake_run)

    transcript = LocalWhisperCppTranscriber(
        binary="whisper-cli",
        model_path=str(model),
        ffmpeg_binary="ffmpeg",
        threads=2,
    ).transcribe(b"audio", locale="hi-IN", mime="audio/m4a")

    assert transcript.text == "Ramesh bought three shirts for 2400 rupees"
    assert transcript.engine == "local-whisper.cpp"
    assert calls[0][0] == "ffmpeg"
    assert calls[1][0] == "whisper-cli"
    assert calls[1][calls[1].index("-m") + 1] == str(model)
    assert calls[1][calls[1].index("-l") + 1] == "hi"
    assert not any("download" in " ".join(call).lower() for call in calls)


def test_local_whisper_fails_closed_when_model_missing(tmp_path, monkeypatch):
    monkeypatch.setattr("apps.assistant.transcription.shutil.which", lambda binary: binary)

    with pytest.raises(TranscriptionError, match="will not download"):
        LocalWhisperCppTranscriber(
            binary="whisper-cli",
            model_path=str(tmp_path / "missing.bin"),
        ).transcribe(b"audio")


def test_local_whisper_reports_conversion_failure(tmp_path, monkeypatch):
    model = tmp_path / "ggml-base.bin"
    model.write_bytes(b"model")
    monkeypatch.setattr(
        "apps.assistant.transcription.shutil.which",
        lambda binary: f"/usr/local/bin/{binary}",
    )
    monkeypatch.setattr(
        "apps.assistant.transcription.subprocess.run",
        lambda args, **kwargs: _completed(returncode=1),
    )

    with pytest.raises(TranscriptionError, match="conversion failed"):
        LocalWhisperCppTranscriber(
            binary="whisper-cli",
            model_path=str(model),
        ).transcribe(b"audio")
