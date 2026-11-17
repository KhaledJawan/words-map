# Store screenshots

Both scripts take the same screens: 01 home, 02 Learn tab, 03 flashcards, 04 word card,
05 My words, 06 bookmarks, 07 a grammar lesson, 08 a reading text with highlights, 09 lessons
and 10 the Learn tab in Farsi. Play takes 8 phone screenshots (01–08), the App Store 10.

The debug builds open a screen when they are started with its name (`openForScreenshot` in
`shared/.../Screenshots.kt`), and every shot starts from the same app data, written by
`demo_state.py`: a few bookmarks (`bookmark_ids.txt`), progress in chapter A1.1, a 6-day
streak, a reminder at 19:00 and two categories of the learner's own words.

**App Store** (iOS simulators):

    xcodebuild -project iosApp/iosApp.xcodeproj -scheme iosApp -configuration Debug -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,id=69F1177E-E36F-466E-8C17-C4C3A97CF5F6' build
    zsh tools/store_screenshots/app_store.sh <raw folder>

It shoots on iPhone 17 Pro, 17 Pro Max, 16 Plus and 16 (edit the device ids at the end if
they change). Save the raw shots as RGB into `release/app-store-screenshots/<slot>/`; the
6.5-inch slot is the 16 Plus shot resized to 1284×2778. App Store Connect rejects RGBA files.

**Play Store** (Android emulator, set to 1080×1920 by the script, debug APK):

    ./gradlew :app:assembleDebug
    bash tools/store_screenshots/play_store.sh <raw folder> app/build/outputs/apk/debug/app-debug.apk

The debug APK has the Play id com.merlinict.wordmap, so use an emulator, not a phone with
the real app: the script clears the app's data. Save 01–08 as RGB into
`release/play-store-screenshots/`.
