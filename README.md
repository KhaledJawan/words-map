# WordMap App

WordMap is a Flutter app for learning vocabulary with CEFR-style levels and
multilingual support.

## What it includes

- Word learning flow by levels (`A1.1` to `B2.2`)
- Local JSON-based vocabulary (`assets/words/*.json`)
- Word translations in multiple languages (`de`, `en`, `fa`, `ps`, `fr`, `tr`)
- Localized app UI (`en`, `fa`, `ps`)
- Lesson content from JSON (`assets/lessons/*.json`)
- Audio playback support and optional audio generation scripts
- Local progress/bookmark persistence via `SharedPreferences`
- Firebase + Google Mobile Ads integration

## Tech stack

- Flutter / Dart (`sdk: ^3.10.3`)
- Provider for app state
- Firebase (`firebase_core`, `firebase_auth`)
- Google Mobile Ads
- Node.js scripts (audio/version utilities)
- Python script (translation utility)

## Project structure

- `lib/`: Flutter app code
- `assets/words/`: vocabulary datasets by level (`a1_1.json`, `a2_2.json`, etc.)
- `assets/lessons/`: lesson content JSON files
- `assets/audio/`: bundled audio assets
- `docs/`: product/app schema notes
- `generate_word_audios_multilang.js`: generate multilingual word audio
- `translate_words_fr_tr.py`: fill missing French/Turkish word translations

## Prerequisites

- Flutter SDK compatible with Dart `^3.10.3`
- Xcode (for iOS builds)
- Android SDK + Android Studio (for Android builds)
- Node.js (for JS helper scripts)
- Python 3 (for translation helper script)

## Setup

```bash
flutter pub get
```

## Run the app

```bash
flutter run
```

## Useful development commands

```bash
flutter analyze
flutter test
```

## Data format (words)

Each file in `assets/words/` is a JSON array. Example item:

```json
{
  "id": "wA2-2-0001",
  "level": "A2.2",
  "category": ["daily_life", "adjective"],
  "words": {
    "de": "anstrengend",
    "en": "exhausting / tiring",
    "fa": "طاقت‌فرسا",
    "ps": "ستړی کوونکی / ستومانه کوونکی",
    "fr": "épuisant",
    "tr": "yorucu"
  },
  "audios": {
    "de": "https://..."
  }
}
```

Level file naming should follow `a1_1.json`, `a1_2.json`, `a2_1.json`, etc.

## Translation utility (FR/TR)

This script fills missing `words.fr` and `words.tr` values in
`assets/words/*.json`.

```bash
python3 translate_words_fr_tr.py \
  --dir assets/words \
  --cache fr_tr_cache.json \
  --batch-size 15
```

API key resolution order:

- `OPENAI_API_KEY` environment variable
- `.secrets/openai_api_key.txt`

## Audio generation utility

Generates word audio files for selected languages and can update JSON audio
paths.

```bash
node generate_word_audios_multilang.js \
  --langs fr \
  --file a2_2.json \
  --out assets/audio/words \
  --no-json-update
```

Required environment variable:

- `ELEVENLABS_API_KEY`

Optional per-language voice variables:

- `ELEVENLABS_VOICE_ID`
- `ELEVENLABS_VOICE_ID_FR`, `ELEVENLABS_VOICE_ID_TR`, etc.

## Release (Android)

1. Update app version in `pubspec.yaml` (`version: x.y.z+build`).
2. Confirm signing config in `android/key.properties` is valid.
3. Build release bundle:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output:

- `build/app/outputs/bundle/release/app-release.aab`

Upload this AAB to Google Play Console.

## Release (iOS)

1. Update iOS version/build in `ios/Runner/Info.plist`
   (`CFBundleShortVersionString`, `CFBundleVersion`).
2. Build IPA:

```bash
flutter clean
flutter pub get
flutter build ipa --release
```

Upload using Xcode Organizer or Transporter to App Store Connect.

## App identifiers

- Android application ID: `com.merlinict.wordmap`
- iOS bundle ID: `com.merlinict.wordmap`

## Notes

- Keep API keys and signing files private.
- If you replace Firebase project config, update:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
