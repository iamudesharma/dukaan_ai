# End-to-end smoke tests

There are two separate smoke suites. The browser suite is hermetic and safe for
routine local/CI use. The Android suite is **live and non-hermetic**: it creates
accounts, a tenant, catalog rows, invitations, and posted sales in the API it is
pointed at.

## Browser: Playwright + Chromium

From the repository root:

```bash
npm ci
npx playwright install chromium
npm run test:e2e
```

Interactive mode:

```bash
npm run test:e2e:ui
```

`playwright.config.ts` starts the real Vite web app on
`http://127.0.0.1:4173` with `VITE_API_URL=http://127.0.0.1:8000`. Outside CI,
an already-running server on port 4173 is reused. The tests do not need Django
or any other service.

Every browser context intercepts all requests. Vite assets are served normally,
`/api/v1/*` is answered by the stateful mock in `e2e/support/mock-api.ts`, and
any other origin is blocked. Unexpected API routes and external requests fail
the test. Tokens and passwords in the suite are fake test-only values.

Coverage:

- password signup and owner onboarding;
- owner navigation and authenticated workspace bootstrap;
- manual sale review, explicit posting, and invoice PDF download;
- CSV dry-run, snapshot preparation, and separate confirmation;
- invitation issuance/acceptance and cashier privacy, including hidden manager
  navigation, reports/team route denial, no supplier/wholesale data, and no
  manager API requests;
- all-device session revocation, local token clearing, and return to sign-in.

Failed runs retain traces, screenshots, and videos under `test-results/`.
Playwright HTML reports are written under `playwright-report/` in CI. The
required web/API-contract CI job installs Chromium and runs this suite.

## Android: live app smoke

**Do not point this test at production.** It intentionally writes real data and
does not delete the tenant afterward. Use a disposable local/staging API and a
dedicated emulator. The test clears the emulator app's saved session at startup.

The test body is gated by `--dart-define=DUKAAN_E2E=true`. Without that flag it
is skipped and makes no live requests.

Prerequisites:

- Flutter and Android tooling installed;
- `integration_test` is declared under `dev_dependencies` in `apps/mobile/pubspec.yaml`
  (`sdk: flutter`), as required by the Flutter device-test runner;
- a disposable API reachable from the emulator, with migrations applied;
- the API, database, Redis/Celery, and any configured AI/OCR services running;
- an internet-capable emulator that can reach the host machine.

Start the emulator and wait until ADB reports it online:

```bash
flutter emulators --launch Medium_Phone_API_33
adb wait-for-device
adb devices
```

Run from `apps/mobile` (the command below assumes `emulator-5554`):

```bash
flutter test integration_test/app_smoke_test.dart \
  -d emulator-5554 \
  --dart-define=DUKAAN_API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=DUKAAN_E2E=true
```

The Android debug manifest permits cleartext traffic for the local emulator.
The release manifest does not; do not weaken release network security to run
this test.

The smoke test uses the real app, secure session store, repository, Dio client,
and API. It:

1. generates random phone numbers and strong passwords (never hardcoded and
   never printed);
2. signs up and onboards an owner through the UI;
3. creates a product, opening stock, a customer, and a supplier through the real
   repository;
4. records a fully paid manual sale through the UI, asserting that review alone
   leaves the ledger unchanged;
5. interprets an assistant sale through the UI, asserts that the proposal is
   review-only, then explicitly confirms it and verifies one additional sale;
6. creates a second random account, invites/accepts it as a cashier, signs in as
   that cashier, and verifies retail-only and manager-hidden screens plus direct
   manager-route denial.

At startup the test prints a line beginning `DUKAAN_E2E_CLEANUP` containing only
the generated owner/cashier usernames, phone numbers, and business name. Use that
identity to purge the disposable tenant after the run. Passwords, JWTs, refresh
tokens, and invitation tokens are never printed.

Static checks (these do not run the live body):

```bash
cd apps/mobile
flutter analyze
dart analyze integration_test/app_smoke_test.dart
```

A live failure can leave partially created data. Always use the printed cleanup
identity rather than retrying against a shared tenant.
