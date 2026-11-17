package dev.nefrin.wordsmap.update

import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.platform.Log
import dev.nefrin.wordsmap.platform.currentTimeMillis
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

/** Where the update check stands, as Settings shows it. */
enum class UpdateStatus { NOT_CHECKED, CHECKING, UP_TO_DATE, AVAILABLE, REQUIRED, FAILED }

/**
 * The update dialog. [blocking] only for a required update the store is known to have:
 * otherwise the user can go on, so nobody is shut out by an update their store does not
 * offer yet, or while offline.
 */
data class UpdatePrompt(val release: PublishedRelease, val required: Boolean, val blocking: Boolean)

/**
 * Finds out whether a newer WordsMap is out, and leads to it.
 *
 * The WordsMap server publishes the newest build and the oldest one still supported for each
 * platform; the store says whether it has that update for this phone. The check runs in the
 * background on every start and every return to the app (at most every few hours), when the
 * phone comes back online after a failed check, and when the user asks. Only one runs at a
 * time. The last answer is kept, so Settings knows about an update while offline.
 */
@Stable
class AppUpdates(
    private val prefs: AppPreferences,
    private val server: ReleaseSource,
    private val store: AppStore,
    private val scope: CoroutineScope,
    private val clock: () -> Long = ::currentTimeMillis,
) {
    val platform: UpdatePlatform get() = store.platform
    val installed: InstalledVersion get() = store.installed

    /** The newest release the server published, kept from earlier runs. */
    var release: PublishedRelease? by mutableStateOf(cachedRelease())
        private set

    var need: UpdateNeed by mutableStateOf(release?.let { updateNeed(installed, it) } ?: UpdateNeed.NONE)
        private set

    /** What the store said at the last check. */
    var offer: StoreOffer by mutableStateOf(StoreOffer.Unknown)
        private set

    var status: UpdateStatus by mutableStateOf(statusFor(need, checked = release != null))
        private set

    /** When the server last answered, in epoch milliseconds. */
    var lastChecked: Long? by mutableStateOf(prefs.updateLastSuccess)
        private set

    /** The dialog to show, if any. */
    var prompt: UpdatePrompt? by mutableStateOf(null)
        private set

    val download: StateFlow<UpdateDownload?> get() = store.download

    private var job: Job? = null

    /** On every start and every return to the app: asks the server only when it is due. */
    fun checkAutomatically() {
        store.resumeInterrupted()
        val now = clock()
        val lastAttempt = prefs.updateLastAttempt ?: 0L
        val due = when {
            // The clock was set back: the times saved say nothing.
            now < lastAttempt -> true
            prefs.updateLastFailed -> now - lastAttempt >= RETRY_AFTER_MILLIS
            else -> now - (prefs.updateLastSuccess ?: 0L) >= CHECK_EVERY_MILLIS
        }
        if (due) check(manual = false)
    }

    /** The "Check for updates" button. */
    fun checkNow() = check(manual = true)

    /** The phone is online again: tries again if the last check failed. */
    fun onOnline() {
        if (prefs.updateLastFailed && job?.isActive != true) check(manual = false)
    }

    /** "Later": no dialog for this optional update again; Settings still offers it. */
    fun later() {
        val shown = prompt ?: return
        if (!shown.required) prefs.updateDismissedBuild = shown.release.latestBuild
        prompt = null
    }

    /** "Update now", from the dialog or from Settings. */
    fun update() {
        val target = prompt?.release ?: release ?: return
        if (prompt?.blocking != true) prompt = null
        store.startUpdate(target, offer, required = need == UpdateNeed.REQUIRED)
    }

    fun installDownloaded() = store.installDownloaded()

    /** Debug builds only, for screenshots: shows what a check finding [release] in the store would show. */
    internal fun showForScreenshot(release: PublishedRelease) {
        this.release = release
        need = updateNeed(installed, release)
        offer = StoreOffer.Available(inApp = false)
        status = statusFor(need, checked = true)
        prompt = promptFor(release, manual = true)
    }

    fun clearFailedDownload() = store.clearFailedDownload()

    private fun check(manual: Boolean) {
        if (job?.isActive == true) return
        status = UpdateStatus.CHECKING
        job = scope.launch {
            prefs.updateLastAttempt = clock()
            val fresh = try {
                val text = server.fetch(store.platform, installed.build)
                ReleaseConfig.parse(text, store.platform).also { prefs.updateRelease = text }
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                // Offline, a timeout, a server error or an answer that does not fit: what was
                // known before stays, and nothing is shown.
                Log.w(TAG, "Update check failed", error)
                prefs.updateLastFailed = true
                status = UpdateStatus.FAILED
                return@launch
            }
            prefs.updateLastFailed = false
            val now = clock()
            prefs.updateLastSuccess = now
            lastChecked = now
            release = fresh
            need = updateNeed(installed, fresh)
            offer = if (need == UpdateNeed.NONE) StoreOffer.Unknown else checkStore(fresh)
            status = statusFor(need, checked = true)
            prompt = promptFor(fresh, manual)
        }
    }

    private suspend fun checkStore(release: PublishedRelease): StoreOffer = try {
        store.check(release)
    } catch (error: CancellationException) {
        throw error
    } catch (error: Exception) {
        Log.w(TAG, "The store could not be asked", error)
        StoreOffer.Unknown
    }

    private fun promptFor(release: PublishedRelease, manual: Boolean): UpdatePrompt? {
        // A download in the app shows its own progress.
        if (store.download.value != null) return null
        return when (need) {
            UpdateNeed.NONE -> null
            UpdateNeed.REQUIRED -> UpdatePrompt(release, required = true, blocking = offer is StoreOffer.Available)
            UpdateNeed.OPTIONAL -> when {
                // The store does not have it for this phone yet; Settings says it is coming.
                offer == StoreOffer.NotYet -> null
                manual -> UpdatePrompt(release, required = false, blocking = false)
                release.latestBuild <= (prefs.updateDismissedBuild ?: 0L) -> null
                else -> UpdatePrompt(release, required = false, blocking = false)
            }
        }
    }

    private fun cachedRelease(): PublishedRelease? = prefs.updateRelease?.let { text ->
        try {
            ReleaseConfig.parse(text, store.platform)
        } catch (error: InvalidReleaseConfig) {
            null
        }
    }

    private fun statusFor(need: UpdateNeed, checked: Boolean): UpdateStatus = when {
        !checked -> UpdateStatus.NOT_CHECKED
        need == UpdateNeed.REQUIRED -> UpdateStatus.REQUIRED
        need == UpdateNeed.OPTIONAL -> UpdateStatus.AVAILABLE
        else -> UpdateStatus.UP_TO_DATE
    }

    companion object {
        private const val TAG = "AppUpdates"

        /** How often the start of the app or a return to it asks the server. */
        const val CHECK_EVERY_MILLIS = 4 * 60 * 60 * 1000L

        /** How soon after a failed check the next start or return tries again. */
        const val RETRY_AFTER_MILLIS = 15 * 60 * 1000L
    }
}
