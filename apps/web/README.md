# DukaanAI web console

The web console is the owner/manager surface for oversight, reconciliation, imports, reports, team access, and the same review-before-recording assistant flow used by mobile.

## Local development

From the repository root:

```sh
cp apps/web/.env.example apps/web/.env.local
npm ci
npm run dev:web
```

`VITE_API_URL` is the only switch: every request, including sign-in and sign-out, goes to that host. A first visit shows password sign-in; OTP appears when the API reports it enabled. A new owner creates an account and then sets up their shop (name, optional GSTIN and state) before the console opens.

## Safety boundaries

- Business data and authentication both go through Django. The browser holds no provider key.
- Mutating requests carry idempotency keys.
- Assistant interpretation creates a proposal only; the confirmation call performs the write.
- Offline capture is stored in IndexedDB as a local draft and is never posted automatically.
- Money crossing the API boundary is integer paise; rupee conversion is display-only.
- No Supabase service-role key, database URL, OpenAI key, or provider secret belongs in this app.

Run `npm run lint:web`, `npm run test:web`, and `npm run build:web` before release.
