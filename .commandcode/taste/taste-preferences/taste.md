# Taste Preferences
- Prefers a written implementation plan reviewed and approved before code is written — explicitly asks the agent to plan first, then executes only after approval. Confidence: 0.65
- Follow PR template instructions and checklists when committing code — the agent should read the PR template and address its verification items before creating commits. Confidence: 0.85
- Works in a shell with a minimal PATH (`/usr/bin:/bin:/usr/sbin:/sbin`); tooling such as `pod`, `npm`, `uv`, and `flutter` (fvm stable) must be given explicit paths via an `export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$HOME/fvm/versions/stable/bin:..."` prefix in commands. Confidence: 0.6
- Prefers to reuse accounts/tools they already use (e.g. OpenCode, an existing ChatGPT account) for LLM calls instead of provisioning a separate paid API key. Confidence: 0.55
- Expects the Flutter mobile app to be runnable on macOS desktop as a local dev target (asks for `flutter run -d macos`), not only Android emulators — desktop entitlements/config should be kept working. Confidence: 0.6
- Prioritizes shipping real, production-ready behavior over demo/mock scaffolding — wants mock/demo data paths removed so real end users (e.g. account creation) work against the real backend end to end. Confidence: 0.65
- Prefers debugging driven by the running app's own logs — when a process is already running, read its logs to see the actual error instead of poking around source/config broadly (explicitly: don't access everything, it doesn't make sense). Confidence: 0.7
- Wants a single shared design-token source (colors, type, spacing, etc.) consumed by every platform so clients stay visually identical, rather than hand-maintaining parallel styles per platform. Confidence: 0.7
