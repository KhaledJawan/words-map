## Task AUDIO-01 – Add audio playback to word details (old WordMap)

### Goal

Play the word’s audio (Amazon URL from JSON) when the user taps the play button in the word details overlay, without changing the JSON files.

### Context

- JSON files already contain an `audio` field with a full URL (Amazon S3 or similar).
- The old WordMap project already has:
  - a word model that includes `audio` (or can be extended)
  - a word details UI (overlay / bottom sheet / dialog) that shows word + translations.

### Steps

- Add audio dependency:
  - In `pubspec.yaml`, add:
    - `just_audio: ^0.9.36`
  - Run `flutter pub get`.
- Word model:
  - Ensure the word model in the old project has a `String audio` field mapped from JSON.
  - If the JSON `audio` is missing or empty, treat it as `""`.
- Create shared audio service:
  - Create `lib/core/audio/audio_service.dart` (or similar):
    - Implement a singleton using `just_audio.AudioPlayer`.
    - Methods:
      - `Future<void> playUrl(String url)`:
        - stop current playback
        - setUrl(url)
        - play()
      - `void stop()`
- Integrate with word details overlay:
  - Find the widget that shows word details (the overlay / popup for a single word).
  - Add a visible play button (e.g. an `IconButton` with a speaker icon).
  - If `audio` is a non-empty string:
    - onPressed: call `AudioService.instance.playUrl(word.audio)`.
  - If `audio` is empty:
    - disable the button or show it in a disabled state.
- Optional UX:
  - While audio is playing, show a simple “playing” state:
    - e.g. swap icon to `Icons.equalizer` or show a small animated indicator.
- Validation:
  - Run `flutter analyze` and fix issues.
  - Run the app and confirm:
    - word details overlay opens as before,
    - tapping the play button plays the audio from the JSON `audio` URL.

### Acceptance Criteria

- No changes to JSON files.
- For words with a non-empty `audio` URL, tapping the play button plays audio.
- For words with empty `audio`, the play button is disabled or visually inactive.
- `flutter analyze` passes without new issues.
