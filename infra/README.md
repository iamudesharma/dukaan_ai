# Infrastructure

DukaanAI keeps infrastructure intentionally small:

- [`../compose.yaml`](../compose.yaml) starts disposable local Postgres and Valkey with named development volumes.
- [`../render.yaml`](../render.yaml) declares the production Render API, worker, cron dispatcher, and private persistent Key Value topology in Singapore.
- [`../config/env`](../config/env) documents environment contracts without real secrets.
- Supabase supplies production Postgres, Auth, and private Storage; Django migrations own the application schema.

There is deliberately no second production database, file store, Kubernetes layer, or application-managed scheduler in the MVP. The queue is never the only copy of work that matters.

Start with the [local runbook](../docs/runbooks/local-development.md), deploy through the [Render runbook](../docs/runbooks/deploy-render.md), and rehearse [restore](../docs/runbooks/restore.md) before real customer data is accepted.
