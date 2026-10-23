# ikuku

I-Kuku

## Local development

### Prerequisites

- **Flutter** (stable, Dart SDK `^3.8.1`). On macOS: `brew install --cask flutter`
- **Chrome**, the quickest target to run against; it needs no extra tooling
- **iOS / macOS targets:** full Xcode from the App Store (Command Line Tools alone are not enough) plus CocoaPods (`brew install cocoapods`). After installing Xcode, run:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```
- **Android target:** Android Studio (`brew install --cask android-studio`). Open it once to install the SDK and create an emulator, then run `flutter doctor --android-licenses`.

Run `flutter doctor` to see which targets are ready.

### Running the app

```bash
flutter pub get
cp .env.example .env         # then fill in the Supabase values
flutter run -d chrome --dart-define-from-file=.env   # or: flutter devices, then -d <device-id>
```

### Developing without Supabase

Debug builds can run against a development backend built into the app instead of Supabase. It answers the same API calls from data kept on the device, and comes seeded with a developer account and a sample farm:

| Email | Password |
| --- | --- |
| `dev@ikuku.test` | `ikuku-dev-123` |

```bash
flutter run --dart-define=IKUKU_DEV_BACKEND=true
```

- The sign-in screen has a **Sign in as dev account** button.
- Changes are kept between launches. To start again from the seed, add `--dart-define=IKUKU_DEV_RESET=true`; this also clears the app's local data.
- The **DEV** tab on the left edge of the screen takes the app offline and back, for trying offline behavior on simulators and emulators, which have no airplane mode.
- The account exists only on your device and is never created in Supabase. Release builds refuse to start with `IKUKU_DEV_BACKEND`, and without the flag the dev backend isn't compiled in.
- The financial summary is a rough version of the server's, photos aren't uploaded, and the one-time code for deleting an account is `123456`.

In VS Code, use the **mobile-app (dev backend)** launch configuration.

### Checks

```bash
flutter analyze
flutter test
```

The offline flow can also be checked end to end on a simulator or emulator. It signs in as the dev account, adds a batch offline and checks it uploads once back online; screenshots of each step are saved to `build/integration_test/screenshots/`:

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/offline_flow_test.dart -d <device-id> \
  --dart-define=IKUKU_DEV_BACKEND=true --dart-define=IKUKU_DEV_RESET=true
```

### Backend

The app talks to a hosted Supabase project. Its URL and anon key are read at build time from `.env` (gitignored) via `--dart-define-from-file=.env`; ask a maintainer for the values.

The Smart Tips feature downloads a Gemma model (several hundred MB) from Hugging Face the first time it runs.
