# WordsMap

Learn German from A1 to C1, with explanations in English, Farsi or Pashto: 3,600+ words with
meanings, verb tables, grammar lessons, reading texts and daily flashcards.

- Google Play: `com.merlinict.wordmap`
- App Store: `dev.nefrin.wordsmap`

The app is Kotlin Multiplatform with Compose Multiplatform, for Android and iOS. The earlier
Flutter version is in this repository's history.

## Layout

- `shared/`: the whole app (UI, data, learning, reminders, update check), and the words, grammar
  lessons and reading texts in `shared/src/commonMain/composeResources/files/`
- `app/`: the Android shell
- `iosApp/`: the Xcode project for iOS
- `server/app-updates/`: the Cloudflare Worker that tells the apps about new versions
- `tools/`: scripts for adding words and lessons, the app icon and store screenshots

## Build

Android (needs JDK 17+):

    ./gradlew :app:assembleDebug
    ./gradlew :app:bundleRelease   # needs the upload key in keystore/, which is not in git

iOS: open `iosApp/iosApp.xcodeproj` in Xcode, or see `tools/build_ios_release.sh`.

Tests:

    ./gradlew :shared:testAndroidHostTest
