package dev.nefrin.wordsmap

import dev.nefrin.wordsmap.update.PublishedRelease
import dev.nefrin.wordsmap.update.StorePages

/**
 * For store screenshots: opens the screen a debug build was started with, so the screenshot
 * scripts (tools/store_screenshots) don't have to tap their way there. Only debug builds call
 * it; on iOS through `WORDSMAP_SCREEN`, on Android through the `wordsmap.screen` extra.
 *
 * Values: bookmarks, lessons, profile, reminder (the settings), learn, learn-session (the
 * cards), my-words, grammar, texts, update, update-required (the update dialog),
 * grammar-chapter:<id>, grammar-lesson:<id>, text:<id>, and word:<id> for the card of a
 * word on the home screen. Anything else opens the home screen.
 */
fun AppViewModel.openForScreenshot(request: String) {
    val (name, id) = request.split(':', limit = 2).let { it[0] to it.getOrElse(1) { "" } }
    when (name) {
        "bookmarks" -> selectedTab = MainTab.BOOKMARKS
        "lessons" -> selectedTab = MainTab.LESSONS
        "learn" -> selectedTab = MainTab.LEARN
        "learn-session" -> {
            selectedTab = MainTab.LEARN
            open(Screen.LearnSession)
        }
        "my-words" -> open(Screen.MyWords(null))
        "profile", "reminder" -> selectedTab = MainTab.PROFILE
        "grammar" -> open(Screen.Grammar)
        "texts" -> open(Screen.Texts)
        "grammar-chapter" -> open(Screen.GrammarChapter(id))
        "grammar-lesson" -> open(Screen.GrammarLesson(id))
        "text" -> open(Screen.Text(id))
        "word" -> startWordId = id
        // The update dialog, optional or (update-required) required.
        "update", "update-required" -> {
            val build = updates.installed.build
            updates.showForScreenshot(
                PublishedRelease(
                    latestVersion = "2.3.0",
                    latestBuild = build + 1,
                    minimumSupportedBuild = if (name == "update-required") build + 1 else 0,
                    releaseNotes = mapOf(
                        "en" to "Faster cards, a new reading text for every level, and fixes.",
                        "fa" to "کارت‌های سریع‌تر، یک متن خواندنی تازه برای هر سطح، و رفع اشکال‌ها.",
                    ),
                    storeUrl = StorePages.of(updates.platform),
                ),
            )
        }
    }
}
