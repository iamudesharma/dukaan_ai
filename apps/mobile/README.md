# DukaanAI mobile

Flutter Android client for the DukaanAI MVP. It talks to the Django API and
nothing else: there is no sample-data mode, and every recorded entry is the
server's response.

## Run

```sh
flutter pub get
flutter run
```

Android emulator API build (the default base URL already points at the host):

```sh
flutter run --dart-define=DUKAAN_API_BASE_URL=http://10.0.2.2:8000/api/v1/
```

Production must provide `DUKAAN_API_BASE_URL`. That is the only build-time
switch the app has.

## Accounts

A first launch lands on sign-in. New owners sign up with a phone number and
password, then create their shop and its first location before the shell opens.
Access and refresh tokens are kept in platform secure storage; the app refreshes
an expired access token on its own and returns to sign-in if the refresh token
is rejected. No API secret is embedded in the application.

Verification codes are offered only when the API reports OTP support through
`/api/v1/auth/capabilities/`. Configure MSG91 and set `SMS_ENABLED=true` on the
server to enable them; local development can return a dev code without SMS.

## Voice capture

The primary microphone action records an M4A voice note, uploads it through the
authenticated Django attachment endpoint, and polls the resulting proposal while
the server transcribes it. Local development can use the pre-downloaded
whisper.cpp model; production can use an OpenAI-compatible transcription API.
On-device dictation remains available as a fallback.

## Android release builds

Release builds require a real signing key. Create gitignored
`android/key.properties`:

```properties
storeFile=/absolute/path/release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

The same four values can be supplied as environment variables. Release builds
fail when signing is missing; they never fall back to the debug certificate.
Cleartext traffic is disabled in release and allowed only in debug builds.

```sh
flutter build apk --release \
  --dart-define=DUKAAN_API_BASE_URL=https://api.example.com/api/v1/
```

## Offline behaviour

Offline actions are saved as local drafts in Drift. They are never submitted,
numbered as invoices, or replayed automatically. The user must reconnect,
review, and explicitly confirm each write.
