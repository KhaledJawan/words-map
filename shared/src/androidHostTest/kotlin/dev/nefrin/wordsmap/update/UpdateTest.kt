package dev.nefrin.wordsmap.update

import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.learn.MapStore
import dev.nefrin.wordsmap.platform.HttpException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.IOException

class VersionCompareTest {
    @Test
    fun `versions compare as numbers, not as text`() {
        assertTrue(compareVersions("2.10.0", "2.9.1")!! > 0)
        assertTrue(compareVersions("10.0", "9.9.9")!! > 0)
        assertTrue(compareVersions("2.2.1", "2.2.0")!! > 0)
        assertTrue(compareVersions("1.0", "2.2.0")!! < 0)
    }

    @Test
    fun `missing parts count as zero and suffixes are left out`() {
        assertEquals(0, compareVersions("2.2", "2.2.0"))
        assertEquals(0, compareVersions("v2.2.0", "2.2.0"))
        assertEquals(0, compareVersions("2.2.0-beta", "2.2.0"))
        assertEquals(0, compareVersions("2.2.0 (27)", "2.2.0"))
    }

    @Test
    fun `what is not a version cannot be compared`() {
        assertNull(compareVersions("", "2.2.0"))
        assertNull(compareVersions("two", "2.2.0"))
        assertNull(compareVersions("2..2", "2.2"))
        assertNull(compareVersions("1.2.3.4.5", "1.2"))
    }
}

class ReleaseConfigTest {
    private val answer = """
        {
          "android": {
            "latestVersion": "2.3.0", "latestBuild": 28, "minimumSupportedBuild": 20,
            "releaseNotes": {"en": "Faster cards.", "de": "Schnellere Karten.", "fa": "کارت‌های سریع‌تر."},
            "storeUrl": "https://play.google.com/store/apps/details?id=com.merlinict.wordmap"
          },
          "ios": {
            "latestVersion": "2.3.1", "latestBuild": 9, "minimumSupportedBuild": 0,
            "releaseNotes": {"en": "Fixes."},
            "storeUrl": "https://apps.apple.com/app/id6823419767"
          }
        }
    """.trimIndent()

    @Test
    fun `each platform reads its own release`() {
        val android = ReleaseConfig.parse(answer, UpdatePlatform.ANDROID)
        assertEquals("2.3.0", android.latestVersion)
        assertEquals(28L, android.latestBuild)
        assertEquals(20L, android.minimumSupportedBuild)
        val ios = ReleaseConfig.parse(answer, UpdatePlatform.IOS)
        assertEquals("2.3.1", ios.latestVersion)
        assertEquals(9L, ios.latestBuild)
        assertEquals("https://apps.apple.com/app/id6823419767", ios.storeUrl)
    }

    @Test
    fun `notes come in the user's language, else in English`() {
        val release = ReleaseConfig.parse(answer, UpdatePlatform.ANDROID)
        assertEquals("کارت‌های سریع‌تر.", release.notesIn("fa"))
        assertEquals("Faster cards.", release.notesIn("ps"))
    }

    @Test
    fun `a broken answer is refused`() {
        val broken = listOf(
            "not json",
            "<html><body>Wi-Fi login</body></html>",
            "[]",
            "{}",
            """{"ios": {"latestVersion": "2.3.0", "latestBuild": 9}}""",
            """{"android": {"latestVersion": "2.3.0", "latestBuild": "28"}}""",
            """{"android": {"latestVersion": "2.3.0", "latestBuild": 28.5}}""",
            """{"android": {"latestVersion": "2.3.0", "latestBuild": -1}}""",
            """{"android": {"latestVersion": "two", "latestBuild": 28}}""",
            """{"android": {"latestBuild": 28}}""",
        )
        for (text in broken) {
            assertTrue(text, runCatching { ReleaseConfig.parse(text, UpdatePlatform.ANDROID) }.exceptionOrNull() is InvalidReleaseConfig)
        }
    }

    @Test
    fun `a minimum above the newest build cannot lock anyone out`() {
        val release = ReleaseConfig.parse(
            """{"android": {"latestVersion": "2.3.0", "latestBuild": 28, "minimumSupportedBuild": 99}}""",
            UpdatePlatform.ANDROID,
        )
        assertEquals(0L, release.minimumSupportedBuild)
        assertEquals(UpdateNeed.OPTIONAL, updateNeed(InstalledVersion("2.2.0", 27), release))
    }

    @Test
    fun `only the official store pages are ever opened`() {
        val strange = listOf(
            "http://play.google.com/store/apps/details?id=com.merlinict.wordmap",
            "https://example.com/wordsmap.apk",
            "https://play.google.com.example.com/x",
            "https://evil.example@play.google.com/x",
            "https://apps.apple.com/app/id6823419767",
        )
        for (url in strange) {
            val release = ReleaseConfig.parse(
                """{"android": {"latestVersion": "2.3.0", "latestBuild": 28, "storeUrl": "$url"}}""",
                UpdatePlatform.ANDROID,
            )
            assertEquals(url, StorePages.PLAY, release.storeUrl)
        }
    }

    @Test
    fun `notes that are not text or too long are cleaned`() {
        val long = "x".repeat(ReleaseConfig.MAX_NOTE_LENGTH + 50)
        val release = ReleaseConfig.parse(
            """{"android": {"latestVersion": "2.3.0", "latestBuild": 28,
               "releaseNotes": {"en": "$long", "de": 5, "<script>": "no", "fa": "  "}}}""",
            UpdatePlatform.ANDROID,
        )
        assertEquals(setOf("en"), release.releaseNotes.keys)
        assertEquals(ReleaseConfig.MAX_NOTE_LENGTH, release.notesIn("en")!!.length)
    }
}

class UpdatePolicyTest {
    private fun release(latest: Long, minimum: Long = 0) = PublishedRelease("2.3.0", latest, minimum, emptyMap(), StorePages.PLAY)

    @Test
    fun `the build number decides`() {
        val installed = InstalledVersion("2.2.0", 27)
        assertEquals(UpdateNeed.NONE, updateNeed(installed, release(latest = 27)))
        assertEquals(UpdateNeed.NONE, updateNeed(installed, release(latest = 26, minimum = 26)))
        assertEquals(UpdateNeed.OPTIONAL, updateNeed(installed, release(latest = 28)))
        assertEquals(UpdateNeed.OPTIONAL, updateNeed(installed, release(latest = 28, minimum = 27)))
        assertEquals(UpdateNeed.REQUIRED, updateNeed(installed, release(latest = 28, minimum = 28)))
    }
}

class AppUpdatesTest {
    private var now = 1_000_000_000L
    private val prefs = AppPreferences(MapStore())
    private val server = FakeServer()
    private val store = FakeStore(installedBuild = 27)

    private fun updates() = AppUpdates(prefs, server, store, CoroutineScope(Dispatchers.Unconfined), clock = { now })

    private fun answer(latest: Long, minimum: Long = 0, version: String = "2.3.0") =
        """{"android": {"latestVersion": "$version", "latestBuild": $latest, "minimumSupportedBuild": $minimum,
           "releaseNotes": {"en": "New things."}, "storeUrl": "${StorePages.PLAY}"}}"""

    @Test
    fun `no update shows nothing`() {
        server.answer = { answer(latest = 27) }
        val updates = updates().apply { checkAutomatically() }
        assertEquals(UpdateStatus.UP_TO_DATE, updates.status)
        assertNull(updates.prompt)
        assertEquals(now, updates.lastChecked)
    }

    @Test
    fun `an optional update asks once, and Later is remembered for that build`() {
        server.answer = { answer(latest = 28) }
        val updates = updates().apply { checkAutomatically() }
        assertEquals(UpdateStatus.AVAILABLE, updates.status)
        assertFalse(updates.prompt!!.blocking)
        updates.later()
        assertNull(updates.prompt)

        // The next run, hours later: the same build is not offered again in a dialog...
        now += AppUpdates.CHECK_EVERY_MILLIS
        val again = updates().apply { checkAutomatically() }
        assertEquals(UpdateStatus.AVAILABLE, again.status)
        assertNull(again.prompt)

        // ...but a newer one is, and asking by hand always shows it.
        server.answer = { answer(latest = 29) }
        now += AppUpdates.CHECK_EVERY_MILLIS
        assertNotNull(updates().apply { checkAutomatically() }.prompt)
        server.answer = { answer(latest = 28) }
        assertNotNull(updates().apply { checkNow() }.prompt)
    }

    @Test
    fun `a required update blocks only when the store has it`() {
        server.answer = { answer(latest = 30, minimum = 29) }
        store.offer = StoreOffer.Available(inApp = true)
        val updates = updates().apply { checkAutomatically() }
        assertEquals(UpdateStatus.REQUIRED, updates.status)
        assertTrue(updates.prompt!!.blocking)
        // Later cannot dismiss it.
        updates.later()
        assertNull(updates.prompt)
        updates.checkNow()
        assertTrue(updates.prompt!!.required)

        // Not in this phone's store yet, or the store cannot tell: the user can go on.
        store.offer = StoreOffer.NotYet
        assertFalse(updates().apply { checkNow() }.prompt!!.blocking)
        store.offer = StoreOffer.Unknown
        assertFalse(updates().apply { checkNow() }.prompt!!.blocking)
    }

    @Test
    fun `Update hands the release to the store`() {
        server.answer = { answer(latest = 30, minimum = 29) }
        store.offer = StoreOffer.Available(inApp = true)
        val updates = updates().apply { checkNow() }
        updates.update()
        assertEquals(listOf(true), store.started)
        // A required, blocking dialog stays until the new version runs.
        assertNotNull(updates.prompt)
    }

    @Test
    fun `offline at start keeps what was known and shows no dialog`() {
        server.answer = { answer(latest = 28) }
        updates().checkAutomatically()

        server.answer = { throw IOException("No network") }
        now += AppUpdates.CHECK_EVERY_MILLIS
        val offline = updates().apply { checkAutomatically() }
        assertEquals(UpdateStatus.FAILED, offline.status)
        assertEquals(UpdateNeed.OPTIONAL, offline.need)
        assertEquals(28L, offline.release!!.latestBuild)
        assertNull(offline.prompt)
    }

    @Test
    fun `a timeout is tried again a little later, not at every return`() {
        server.answer = { throw HttpException("Timed out") }
        val updates = updates().apply { checkAutomatically() }
        assertEquals(UpdateStatus.FAILED, updates.status)
        assertEquals(1, server.calls)

        now += AppUpdates.RETRY_AFTER_MILLIS / 2
        updates.checkAutomatically()
        assertEquals(1, server.calls)

        server.answer = { answer(latest = 27) }
        now += AppUpdates.RETRY_AFTER_MILLIS
        updates.checkAutomatically()
        assertEquals(2, server.calls)
        assertEquals(UpdateStatus.UP_TO_DATE, updates.status)
    }

    @Test
    fun `a malformed answer changes nothing`() {
        server.answer = { answer(latest = 28) }
        updates().checkNow()
        server.answer = { """{"android": {"latestVersion": "oops"}}""" }
        val updates = updates().apply { checkNow() }
        assertEquals(UpdateStatus.FAILED, updates.status)
        assertEquals(28L, updates.release!!.latestBuild)
        assertNull(updates.prompt)
    }

    @Test
    fun `when the store cannot be asked the server's word counts`() {
        server.answer = { answer(latest = 28) }
        store.failing = true
        val updates = updates().apply { checkAutomatically() }
        assertEquals(StoreOffer.Unknown, updates.offer)
        assertNotNull(updates.prompt)
    }

    @Test
    fun `while a release rolls out, Settings knows but no dialog nags`() {
        server.answer = { answer(latest = 28) }
        store.offer = StoreOffer.NotYet
        val updates = updates().apply { checkAutomatically() }
        assertEquals(UpdateStatus.AVAILABLE, updates.status)
        assertEquals(StoreOffer.NotYet, updates.offer)
        assertNull(updates.prompt)
    }

    @Test
    fun `starts and returns close together ask the server once`() {
        server.answer = { answer(latest = 27) }
        repeat(5) { updates().checkAutomatically() }
        assertEquals(1, server.calls)
        now += AppUpdates.CHECK_EVERY_MILLIS
        updates().checkAutomatically()
        assertEquals(2, server.calls)
    }

    @Test
    fun `a check already running is not started twice`() {
        val reply = CompletableDeferred<String>()
        server.answer = { reply.await() }
        val updates = updates()
        updates.checkNow()
        updates.checkNow()
        updates.checkAutomatically()
        assertEquals(UpdateStatus.CHECKING, updates.status)
        reply.complete(answer(latest = 27))
        assertEquals(1, server.calls)
        assertEquals(UpdateStatus.UP_TO_DATE, updates.status)
    }

    @Test
    fun `an interrupted download is picked up instead of asking again`() {
        server.answer = { answer(latest = 28) }
        store.offer = StoreOffer.Available(inApp = true)
        store.download.value = UpdateDownload.Ready
        val updates = updates().apply { checkAutomatically() }
        assertEquals(1, store.resumes)
        // The download shows its own "Restart"; no dialog on top of it.
        assertNull(updates.prompt)
        updates.installDownloaded()
        assertTrue(store.installCalled)
    }

    @Test
    fun `back online after a failed check tries again`() {
        server.answer = { throw IOException("No network") }
        val updates = updates().apply { checkAutomatically() }
        server.answer = { answer(latest = 27) }
        updates.onOnline()
        assertEquals(UpdateStatus.UP_TO_DATE, updates.status)
        updates.onOnline()
        assertEquals(2, server.calls)
    }

    @Test
    fun `a newer Android release says nothing to iOS`() {
        val iosStore = FakeStore(installedBuild = 7, platform = UpdatePlatform.IOS)
        server.answer = {
            """{"android": {"latestVersion": "2.4.0", "latestBuild": 40},
                "ios": {"latestVersion": "2.2.0", "latestBuild": 7}}"""
        }
        val updates = AppUpdates(prefs, server, iosStore, CoroutineScope(Dispatchers.Unconfined), clock = { now })
        updates.checkNow()
        assertEquals(UpdateStatus.UP_TO_DATE, updates.status)
        assertEquals(UpdatePlatform.IOS, server.platforms.single())
    }
}

private class FakeServer : ReleaseSource {
    var answer: suspend () -> String = { error("No answer set") }
    var calls = 0
    val platforms = mutableListOf<UpdatePlatform>()

    override suspend fun fetch(platform: UpdatePlatform, installedBuild: Long): String {
        calls++
        platforms += platform
        return answer()
    }
}

private class FakeStore(installedBuild: Long, override val platform: UpdatePlatform = UpdatePlatform.ANDROID) : AppStore {
    override val installed = InstalledVersion("2.2.0", installedBuild)
    var offer: StoreOffer = StoreOffer.Available(inApp = false)
    var failing = false
    val started = mutableListOf<Boolean>()
    var resumes = 0
    var installCalled = false
    override val download = MutableStateFlow<UpdateDownload?>(null)

    override suspend fun check(release: PublishedRelease): StoreOffer {
        if (failing) throw IOException("Store not reachable")
        return offer
    }

    override fun startUpdate(release: PublishedRelease, offer: StoreOffer, required: Boolean) {
        started += required
    }

    override fun installDownloaded() {
        installCalled = true
    }

    override fun clearFailedDownload() = Unit

    override fun resumeInterrupted() {
        resumes++
    }

    override fun watchConnectivity(onOnline: () -> Unit) = Unit
}
