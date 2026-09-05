# Environment contracts

- `api.production.example` lists server-only Django, Supabase, queue, and observability values.
- `mobile.production.example` contains the public API base URL compiled into Flutter.
- `web.production.example` contains public browser values for the production `apps/web` console.

Examples are documentation, not secret storage. Real values belong in Render, Supabase, GitHub, or an approved secret manager. A Supabase service-role key, Django secret, database URL, provider token, or Sentry credential must never use a `VITE_*` name or enter a mobile build.

Production, staging, and development use separate projects and credentials. If an environment variable is renamed, change the application, Blueprint, CI, examples, and deployment runbook together.
