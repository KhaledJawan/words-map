package dev.nefrin.wordsmap.update

import dev.nefrin.wordsmap.platform.httpGet
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.StateFlow

/** What the platform's store says about an update for this phone. */
sealed interface StoreOffer {
    /**
     * The store has a newer version for this phone. [inApp]: Google Play can install it
     * without the user leaving the app.
     */
    data class Available(val inApp: Boolean) : StoreOffer

    /** The store has nothing newer for this phone yet, as while a release rolls out. */
    data object NotYet : StoreOffer

    /** The store could not be asked or cannot tell: offline, installed from elsewhere, not listed in this region. */
    data object Unknown : StoreOffer
}

/** A Google Play download running inside the app (a "flexible" update). */
sealed interface UpdateDownload {
    /** [fraction] of it is done, when its size is known. */
    data class Running(val fraction: Float?) : UpdateDownload

    /** Downloaded; installing it restarts the app. */
    data object Ready : UpdateDownload

    data object Failed : UpdateDownload
}

/**
 * The platform's store, as the update check needs it: Google Play's in-app updates on
 * Android, the App Store on iOS. Updates are only ever installed by the store itself.
 */
interface AppStore {
    val platform: UpdatePlatform
    val installed: InstalledVersion

    /** Asks the store whether it has the update for this phone; [StoreOffer.Unknown] on any failure. */
    suspend fun check(release: PublishedRelease): StoreOffer

    /**
     * Starts the update the official way: Google Play's update flow inside the app when it
     * can, the store page otherwise. [required] asks Play for its full-screen flow.
     */
    fun startUpdate(release: PublishedRelease, offer: StoreOffer, required: Boolean)

    /** The in-app download, while it runs and once it waits to be installed; null otherwise. */
    val download: StateFlow<UpdateDownload?>

    /** Installs a downloaded update. The app restarts into the new version. */
    fun installDownloaded()

    /** Forgets a failed download, so the update can be started again. */
    fun clearFailedDownload()

    /** Picks up an update left half way, for example by leaving the app during the download. */
    fun resumeInterrupted()

    /** Calls [onOnline] when the phone gets a network connection again. Calling it again replaces the callback. */
    fun watchConnectivity(onOnline: () -> Unit)
}

/** Where the published releases come from. */
fun interface ReleaseSource {
    /** The raw answer of the server for [platform], whose installed build is [installedBuild]. */
    suspend fun fetch(platform: UpdatePlatform, installedBuild: Long): String
}

/**
 * The WordsMap server: a Cloudflare Worker at wordsmap.nefrin.dev (server/app-updates).
 * Further [endpoints] are tried in turn when one cannot be reached.
 */
class UpdateServer(private val endpoints: List<String> = ENDPOINTS) : ReleaseSource {
    override suspend fun fetch(platform: UpdatePlatform, installedBuild: Long): String {
        var failure: Exception? = null
        for (endpoint in endpoints) {
            try {
                return httpGet("$endpoint?platform=${platform.key}&build=$installedBuild", TIMEOUT_MILLIS, MAX_BYTES)
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                failure = error
            }
        }
        throw failure ?: IllegalStateException("No update server")
    }

    companion object {
        val ENDPOINTS = listOf("https://wordsmap.nefrin.dev/api/app-updates")
        const val TIMEOUT_MILLIS = 10_000L

        /** The answer is a few hundred bytes; anything far larger is not it. */
        const val MAX_BYTES = 64 * 1024
    }
}
