# DukaanAI web console

The web console is the owner/manager surface for oversight, reconciliation, imports, reports, team access, and the same review-before-recording assistant flow used by mobile.

## Local development

From the repository root:

```sh
cp apps/web/.env.example apps/web/.env.local
npm ci
npm run dev:web
```

`VITE_DEMO_MODE=true` uses local, clearly labelled sample data. Set it to `false` for Django/Supabase integration and provide `VITE_API_URL`, `VITE_SUPABASE_URL`, and `VITE_SUPABASE_ANON_KEY`.

## Safety boundaries

- Browser clients use Supabase only for authentication. Business data goes through Django.
- Mutating requests carry idempotency keys.
- Assistant interpretation creates a proposal only; the confirmation call performs the write.
- Offline capture is stored in IndexedDB as a local draft and is never posted automatically.
- Money crossing the API boundary is integer paise; rupee conversion is display-only.
- No Supabase service-role key, database URL, OpenAI key, or provider secret belongs in this app.

Run `npm run lint:web`, `npm run test:web`, and `npm run build:web` before release.
