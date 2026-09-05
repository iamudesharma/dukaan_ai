# DukaanAI mobile

Flutter Android client for the DukaanAI MVP. The app is deliberately usable in
demo mode while the API is unavailable, but production builds fail closed to
the configured API and never silently turn financial writes into demo writes.

## Run

```sh
flutter pub get
flutter run --dart-define=DUKAAN_DEMO_MODE=true
```

Android emulator API build:

```sh
flutter run \
  --dart-define=DUKAAN_DEMO_MODE=false \
  --dart-define=DUKAAN_API_BASE_URL=http://10.0.2.2:8000/api/v1/
```

Production must provide `DUKAAN_API_BASE_URL`. `DUKAAN_DEV_USER_ID` is an
optional local-development header only; authentication tokens are kept in
platform secure storage and no API secret is embedded in the application.

Offline actions are saved as local drafts in Drift. They are never submitted,
numbered as invoices, or replayed automatically. The user must reconnect,
review, and explicitly confirm each write.

