# Rust document-extractor OCR

DukaanAI does not run OCR locally and does not install OCR packages. Image and
PDF extraction is delegated to the Rust `doc-extractor` HTTP service in
`/Volumes/AppleExpanded/Code/doc_ocr_rust`.

The service is configured to use the provisioned **OCRia-nano-1** model
(`ocr_provider: "ocria"`), the smaller 8.1M-parameter/75 MB OCR pipeline. Model
weights live in the Rust service's LiteParse cache and are never downloaded by a
DukaanAI request. OCRia-nano-1 has its own model licence; verify commercial-use
terms before public launch.

## Configuration

```sh
OCR_ENABLED=true
OCR_API_URL=http://127.0.0.1:8790
OCR_API_TOKEN=
OCR_PROVIDER=ocria
OCR_LANGUAGES=eng+hin
OCR_REQUEST_TIMEOUT_SECONDS=120
OCR_POLL_TIMEOUT_SECONDS=300
OCR_POLL_INTERVAL_SECONDS=1
OCR_MAX_RESULT_BYTES=2097152
```

For a protected service, set `OCR_API_TOKEN`; DukaanAI sends it as a Bearer
token. Production should use a private service URL and TLS where available.

## Request flow

1. The client uploads raw JPEG, PNG, or PDF bytes to DukaanAI.
2. The Celery worker sends the bytes to `POST /v1/extractions` with OCR enabled,
   OCRia selected, English+Hindi languages, and text output.
3. PDF requests are limited to pages `1-5`.
4. The worker polls `GET /v1/extractions/{id}` until the Rust job completes.
5. It reads `GET /v1/extractions/{id}/result?format=text`.
6. It best-effort deletes the remote job so customer documents are not retained.
7. Recognized text feeds the existing reviewable proposal pipeline.

No OCR text is logged. Missing service configuration, HTTP errors, timeouts,
failed jobs, malformed responses, oversized output, and empty recognition fail
closed with a durable blocking question.

## Local verification

Start the Rust service if it is not already running:

```sh
cd /Volumes/AppleExpanded/Code/doc_ocr_rust
DOC_PORT=8790 ./run.sh
```

Confirm the smaller model is provisioned:

```sh
curl -s http://127.0.0.1:8790/v1/capabilities
```

The response should include:

```json
"ocr": {
  "default_provider": "ocria",
  "ocria_nano": {
    "available": true,
    "models_pulled": true,
    "model": "ocria-nano-1"
  }
}
```

Run the DukaanAI tests:

```sh
cd services/api
uv run --locked pytest tests/test_image_ocr.py
```

The Docker API/worker image intentionally contains no Tesseract, Poppler, OCR
model, or Python OCR package.
