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

### Checks

```bash
flutter analyze
flutter test
```

### Backend

The app talks to a hosted Supabase project. Its URL and anon key are read at build time from `.env` (gitignored) via `--dart-define-from-file=.env`; ask a maintainer for the values.

The Smart Tips feature downloads a Gemma model (several hundred MB) from Hugging Face the first time it runs.
