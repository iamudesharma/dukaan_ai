# AI interpreter providers

The assistant turns "Ramesh bought 3 shirts for ₹2,400, ₹900 pending" into a proposal.
Anything OpenAI-compatible can do that extraction. This runbook covers wiring a
provider and proving it works.

## How the interpreter is wired

`apps/assistant/adapter.py` owns the provider boundary:

- `AI_PROVIDER=openai_compatible` — any `/chat/completions` endpoint. This is the
  provider to use for hosted gateways **and** local model servers.
- `AI_PROVIDER=fake` — abstains, so the deterministic regex parser handles
  everything. This is the default and needs no network or credential.
- `AI_PROVIDER=chatgpt` — legacy unofficial ChatGPT-session path; see the warning below.

`USE_AI_INTERPRETER=false` disables the interpreter entirely regardless of provider.
AI never writes to the books: it only produces a proposal that a human confirms.

## Configuration

| Variable | Meaning |
| --- | --- |
| `USE_AI_INTERPRETER` | Master switch. `false` uses the deterministic parser only. |
| `AI_PROVIDER` | `fake`, `openai_compatible`, or `chatgpt`. |
| `AI_API_BASE` | Provider root URL, **without** `/chat/completions`. |
| `AI_API_KEY` | Credential. Leave empty for local servers that need none. |
| `AI_MODEL` | Model name as the provider expects it. |
| `AI_TIMEOUT_SECONDS` | Per-request timeout, default 20. |

`AI_API_BASE` is the only required value for `openai_compatible`. When `AI_API_KEY`
is empty no `Authorization` header is sent, which is what local servers expect.

### Local model servers (no credential, no cost)

Run a model locally and point the API at it:

```sh
# Ollama
ollama pull qwen2.5:7b
# then, in .env:
USE_AI_INTERPRETER=true
AI_PROVIDER=openai_compatible
AI_API_BASE=http://localhost:11434/v1
AI_MODEL=qwen2.5:7b
AI_API_KEY=
```

The same pattern covers LM Studio (`http://localhost:1234/v1`), llama.cpp
(`http://localhost:8080/v1`) and vLLM. Because the API runs in a container or on
another host in some setups, confirm `localhost` is reachable from the API process.

### OpenCode Zen

Zen is OpenCode's gateway. Sign in at `https://opencode.ai/auth`, add billing and
copy an API key, then:

```sh
AI_PROVIDER=openai_compatible
AI_API_BASE=https://opencode.ai/zen/v1
AI_MODEL=glm-5.3-flash
AI_API_KEY=<key from opencode.ai/auth>
USE_AI_INTERPRETER=true
```

**Only Zen's `/chat/completions` models work with this adapter.** Zen splits its
catalogue across three wire formats, and the table in the Zen documentation lists
which is which:

| Zen endpoint | Models | Works here? |
| --- | --- | --- |
| `/chat/completions` | DeepSeek, MiniMax, GLM, Kimi, Big Pickle, MiMo, Ling, Nemotron | Yes |
| `/responses` | GPT 5.x/6.x, Grok, Muse Spark | No — different wire format |
| `/messages` | Claude, Qwen | No — Anthropic format |

So `gpt-5.4-mini` or `claude-sonnet-4-5` will fail here even though Zen serves
them. Use a `/chat/completions` model, or add a second adapter for the others.

`GET https://opencode.ai/zen/v1/models` lists the catalogue and needs no key.

Suggested models for this extraction task, cheapest first:

| Model | Price /1M in–out | Notes |
| --- | --- | --- |
| `deepseek-v4-flash` | $0.14 / $0.28 | Cheapest paid; ample for short extraction. |
| `glm-5.3-flash` | $0.15 / $0.50 | Default here; solid multilingual handling. |
| `minimax-m3` | $0.30 / $1.20 | Mid-range. |
| `kimi-k2.6` | $0.95 / $4.00 | Higher quality, higher cost. |

At these prices the cost is negligible: an extraction is a few hundred tokens.

**Do not run real customer data through the free models.** Zen's free tier
(`big-pickle`, `mimo-v2.5-free`, `ling-3.0-flash-fin-free`, the `nemotron-*-free`
models) carries data-handling conditions — the free models may use submissions to
improve the model, and the NVIDIA-hosted ones are explicitly marked "trial use
only — do not submit personal or confidential data". This assistant sends customer
names, product names and amounts, so treat the free tier as unsuitable for real
shops. The paid models above cost a fraction of a rupee per extraction.

### Hosted gateways (credential required)

Set `AI_API_BASE` to the provider's versioned root (for example
`https://api.openai.com/v1`) and `AI_API_KEY` to a key issued for **your own**
account. The key is server-only: it must never appear in a `VITE_*` variable, a
Flutter build, or any client bundle.

OpenCode Zen is an OpenAI-compatible gateway that issues its own API key; see the
Zen documentation for the current base URL and model names, then configure it
exactly like any other hosted gateway.

## Verify the wiring

```sh
cd services/api
uv run --locked python manage.py check_ai            # report the configuration
uv run --locked python manage.py check_ai --call     # send one real extraction
```

`check_ai` exists because the adapter **abstains silently** when it is
unconfigured: the app falls back to the deterministic parser and looks like it is
working, so a missing `AI_API_BASE` is invisible from the UI. `--call` proves the
provider is reachable, the model name is right, and the response parses into a
usable extraction. It never prints the credential.

Common results:

| Output | Meaning |
| --- | --- |
| `AI_API_BASE is empty` | The adapter abstains on every request. Set it. |
| `rejected the credential in AI_API_KEY` | Key missing, wrong, or not valid for that base URL. |
| `No model endpoint at ...` | Wrong `AI_API_BASE` path or unknown `AI_MODEL`. |
| `could not be reached at ...` | Nothing is listening, or a firewall blocks the API process. |

The adapter first asks for OpenAI's JSON mode (`response_format`) and retries once
without it when a server rejects the extension with 400/404/415/422, because
compatible servers vary.

## Typed tool calls

The OpenAI-compatible adapter also exposes `extract_with_tool()` for narrow,
schema-constrained jobs such as Gmail receipt extraction. The model returns a
function argument object; DukaanAI validates every field before storing a
reviewable import. Tool calls never execute writes directly.

For Gmail extraction, set `GMAIL_AI_EXTRACTION=true` and configure
`AI_PROVIDER=openai_compatible`, `AI_API_BASE`, `AI_API_KEY`, and `AI_MODEL`.
This does not require enabling model interpretation for the general assistant.
If the adapter is disabled or unavailable, Gmail import uses a conservative local
parser and marks uncertain results for review.

## Warning: subscription accounts

Do not point `AI_PROVIDER=chatgpt` at a personal ChatGPT subscription, and do not
reuse a CLI tool's login session as a server credential. Those sessions are issued
to a person, not to a service: using them from a backend generally violates the
provider's terms, the session can be revoked at any time, and it would place a
personal credential in server configuration. The legacy `chatgpt` adapter is kept
only so existing deployments do not break; prefer `openai_compatible` with a key
issued for the deployment, or a local model.

Note also that `opencode serve` exposes OpenCode's own API and ACP, **not** an
OpenAI-compatible `/chat/completions` endpoint, so it cannot be used as an
`AI_API_BASE` directly. Run a local model server instead and point OpenCode and
DukaanAI at the same one.
