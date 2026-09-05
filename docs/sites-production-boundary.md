# OpenAI Sites production boundary

Reviewed against the official [Sites documentation](https://learn.chatgpt.com/docs/sites) on 2026-09-04.

## Documented limitations

In the overview, the documentation states: “Sites is in public beta.” The “Understand limits and unsupported uses” section also states:

- “Sites doesn't support data residency or inference residency at launch.”
- Sites must not be used to process payment-card data or “enable financial transactions.”

The limitation explicitly covers deployed Sites, code, D1/R2 data and file storage, generated artifacts, and logs. Beta capacity limits can also prevent a high-usage Site from remaining public.

## DukaanAI decision

The original repository-root Vinext/Sites scaffold was a disposable placeholder and has been retired. It must not be restored or deployed to:

- post or alter sales, purchases, payments, credit, expenses, or stock;
- collect payment-card information;
- store production customer/supplier PII, receipts, auth tokens, or business records in D1/R2;
- be presented as the production DukaanAI service.

The production MVP uses the Flutter Android app and the React/Vite console in `apps/web`, both calling Django for every business read and write. The web console is deployed as a conventional static application on Render, with Supabase used directly only for authentication. Any future Sites experiments belong in a separate synthetic-data-only project.

Vinext itself is also described as beta in the [official Cloudflare repository](https://github.com/cloudflare/vinext/blob/main/README.md), reinforcing this boundary.
