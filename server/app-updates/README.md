# WordsMap app updates

A Cloudflare Worker on **wordsmap.nefrin.dev**. It tells the WordsMap apps which release is the newest, so they can offer the update through Google Play or the App Store.

| Path | What it does |
| --- | --- |
| `GET /api/app-updates` | The newest Android and iOS release (from `src/releases.json`). |
| `GET /api/app-updates?platform=android&build=27` | The same. The asking platform's entry also has `updateAvailable` and `updateRequired` worked out for that build. |
| `/`, `/privacy`, `/de`, `/de/privacy` | Redirect to the privacy policy on nefrin.dev, which the stores link to. |

## Publishing a new release

Do this **after** the release is live in its store. If you raise the build first, the app tells people about an update their store can't give them yet. The app copes with that, but it's a poor experience.

1. Edit `src/releases.json`, for the platform that was released:
   - `latestVersion`: the version name, for example `"2.3.0"`.
   - `latestBuild`: the Android `versionCode` (`app/build.gradle.kts`) or the iOS `CURRENT_PROJECT_VERSION` (`iosApp/Configuration/Config.xcconfig`).
   - `releaseNotes`: `en` is required; `de`, `fa` and `ps` are shown when the app runs in that language.
   - `minimumSupportedBuild`: leave it at `0` unless an old build really must stop working. Builds below it get the update dialog without "Later". It can never be above `latestBuild`.
2. Run `npm test`. It checks `releases.json` and the code.
3. Run `npm run deploy`. It runs the tests again, then deploys.

Android and iOS are independent: each has its own build numbers, and you can publish one without the other.

The first time on a computer, run `npm install`, then `npx wrangler login`.

## What the apps do with it

- They check when the app starts and whenever it comes back to the screen, at most every 4 hours, or 15 minutes after a failed check. They also check when the phone gets a connection back after a failed check, and when the user taps "Check for updates" in Settings. The check runs in the background, and only one runs at a time.
- They decide by **build numbers**, never by comparing version names as text.
- **Optional update** (`latestBuild` above the installed build): a dialog with "Update now" and "Later". After "Later", that build doesn't show a dialog again; Settings still offers it.
- **Required update** (installed build below `minimumSupportedBuild`): no "Later", but only when the store is known to have the update. Otherwise, for example offline, during a rollout or outside the store's region, the dialog has "Continue for now", so nobody is locked out.
- **Android:**
  - The app asks Google Play whether this phone can get the update. While Play doesn't offer it yet (a staged rollout), no dialog appears and Settings says it's on its way.
  - "Update now" uses Play's in-app update: a download in the background with "Restart" when it's ready, or Play's full-screen flow for required updates.
  - A copy not installed from Play opens the Play page instead.
- **iOS:** the app asks Apple's lookup service whether the store in the user's region has the version, and "Update now" opens the App Store page.
- The last answer is kept, so Settings knows about an update while offline. A broken answer is ignored. Store addresses other than play.google.com and apps.apple.com are never opened.

## Testing a change

```
npm test                  # checks releases.json and the request handling
npx wrangler dev          # serves it at http://localhost:8787
curl "http://localhost:8787/api/app-updates?platform=android&build=26"
```

The app side is covered by `shared/src/androidHostTest/.../update/UpdateTest.kt` (`./gradlew :shared:testAndroidHostTest`). In an iOS debug build, `SIMCTL_CHILD_WORDSMAP_SCREEN=update` (or `update-required`) shows the dialog without a server.

Store behavior can't be tested on this computer: Play's in-app updates only work for an app installed from Play (use internal app sharing or an internal testing track), and the App Store lookup only knows released versions.
