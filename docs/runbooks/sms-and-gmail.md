# SMS, Gmail receipts, and local transcription

This runbook covers the optional provider integrations added to the Django API.
All credentials are server-only. Neither client should ever receive an SMS key,
Google client secret, Supabase service-role key, or provider token into either
client.

## MSG91 OTP SMS

Django creates, hashes, expires, and verifies the OTP. MSG91 only delivers the
already-created code.

1. Complete MSG91 KYC and register the business/header/template on an Indian DLT
   platform.
2. Create an OTP template whose variable name matches `MSG91_OTP_VARIABLE`
   (default `OTP`).
3. Allow the API's outbound IP in MSG91 key security settings.
4. Configure:

   ```sh
   SMS_ENABLED=true
   OTP_EXPOSE_DEV_CODE=false
   SMS_PROVIDER=msg91
   MSG91_AUTH_KEY=...
   MSG91_OTP_TEMPLATE_ID=...
   MSG91_OTP_VARIABLE=OTP
   ```

The sender checks both HTTP status and MSG91's JSON `type`. MSG91 can return an
error payload with HTTP 200; DukaanAI treats that as a failed delivery, removes
the unused OTP row, and returns `502 sms_delivery_failed`.

Local development keeps `SMS_ENABLED=false` and `OTP_EXPOSE_DEV_CODE=true`. The
code is returned only by the local API and must never be enabled in production.

## Gmail payment and receipt reading

Gmail uses the narrow `gmail.readonly` scope. Imports are **review-only**: they
never post a sale, payment, purchase, or expense automatically.

1. Create a Google Cloud project and enable the Gmail API.
2. Configure an OAuth consent screen. Reading Gmail is a sensitive scope and may
   require Google verification before public launch.
3. Create an OAuth **Web application** client.
4. Add the exact callback URI, for example:

   ```text
   http://127.0.0.1:8000/api/v1/integrations/gmail/callback/
   ```

5. Configure:

   ```sh
   GMAIL_ENABLED=true
   GMAIL_AI_EXTRACTION=true
   GMAIL_CLIENT_ID=...
   GMAIL_CLIENT_SECRET=...
   GMAIL_REDIRECT_URI=http://127.0.0.1:8000/api/v1/integrations/gmail/callback/
   GMAIL_WEB_REDIRECT_URL=http://127.0.0.1:4173/settings
   GMAIL_TOKEN_ENCRYPTION_KEY=...
   ```

`GMAIL_TOKEN_ENCRYPTION_KEY` must be a URL-safe base64-encoded 32-byte Fernet
key. If omitted, the key is derived from `DJANGO_SECRET_KEY`; rotating the Django
secret then makes stored Gmail credentials unreadable and users must reconnect.

The web Settings page can connect/disconnect Gmail, list recent financial mail,
and import a message into a reviewable record. Extraction uses the configured
OpenAI-compatible model through a typed function call. If AI is unavailable, a
conservative deterministic amount/direction parser is used and confidence is
low. Missing amounts remain `NEEDS_REVIEW`.

## Local Whisper transcription

Local transcription uses an installed `whisper-cli` and an existing model file.
It never downloads weights.

```sh
STT_PROVIDER=local_whisper
STT_LOCAL_BINARY=whisper-cli
STT_LOCAL_MODEL_PATH=~/Library/ggml-base.bin
STT_LOCAL_FFMPEG=ffmpeg
STT_LOCAL_THREADS=4
STT_LOCAL_TIMEOUT_SECONDS=180
```

The provider converts M4A to 16 kHz mono WAV with ffmpeg, runs whisper.cpp, and
parses its JSON output. A missing model or binary fails closed with a blocking
question; it does not fall back to a guessed transcript.

For local development, set `STORAGE_BACKEND=local`. Voice files are stored under
`services/api/.local_storage/` inside this project and uploaded through the
authenticated Django attachment endpoint. This directory is gitignored.

For production, prefer `STT_PROVIDER=whisper` with an OpenAI-compatible
transcription endpoint unless you package and mount the local model explicitly.
Do not commit model weights or depend on a developer home directory in
production.

## Verification

Apply the new migrations before using Gmail:

```sh
make api-migrate
```

Then run:

```sh
cd services/api
uv run --locked pytest tests/test_sms.py tests/test_gmail.py \
  tests/test_local_transcription.py tests/test_local_storage.py \
  tests/test_ai_tool_calling.py
```

Live provider verification requires real credentials and approved templates.
Unit tests mock provider responses and never send SMS or read a real inbox.
