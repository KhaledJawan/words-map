package dev.nefrin.wordsmap.update

import dev.nefrin.wordsmap.platform.Log
import dev.nefrin.wordsmap.platform.httpGet
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import platform.Foundation.NSBundle
import platform.Foundation.NSLocale
import platform.Foundation.NSURL
import platform.Foundation.countryCode
import platform.Foundation.currentLocale
import platform.Network.nw_path_get_status
import platform.Network.nw_path_monitor_create
import platform.Network.nw_path_monitor_set_queue
import platform.Network.nw_path_monitor_set_update_handler
import platform.Network.nw_path_monitor_start
import platform.Network.nw_path_monitor_t
import platform.Network.nw_path_status_satisfied
import platform.UIKit.UIApplication
import platform.darwin.dispatch_get_main_queue

/**
 * The App Store. iOS apps can only be updated by the App Store, so "Update" opens the app's
 * page there. Apple's lookup service tells whether the store of the user's region has the
 * new version yet.
 */
class AppleAppStore : AppStore {
    override val platform = UpdatePlatform.IOS

    override val installed: InstalledVersion = NSBundle.mainBundle.infoDictionary.let { info ->
        InstalledVersion(
            name = info?.get("CFBundleShortVersionString") as? String ?: "",
            build = (info?.get("CFBundleVersion") as? String)?.trim()?.toLongOrNull() ?: 0L,
        )
    }

    private val bundleId = NSBundle.mainBundle.bundleIdentifier ?: "dev.nefrin.wordsmap"

    // The page in the user's own store, from the lookup.
    private var regionalPage: String? = null

    private val noDownload = MutableStateFlow<UpdateDownload?>(null)
    override val download: StateFlow<UpdateDownload?> = noDownload.asStateFlow()

    private var monitor: nw_path_monitor_t = null
    private var onOnline: () -> Unit = {}

    override suspend fun check(release: PublishedRelease): StoreOffer {
        val country = NSLocale.currentLocale.countryCode?.lowercase()?.takeIf { it.length == 2 && it.all(Char::isLetter) }
        val url = "https://itunes.apple.com/lookup?bundleId=$bundleId" + (country?.let { "&country=$it" } ?: "")
        val result = try {
            val root = Json.parseToJsonElement(httpGet(url, timeoutMillis = 8_000, maxBytes = 512 * 1024)) as? JsonObject
            (root?.get("results") as? JsonArray)?.firstOrNull() as? JsonObject
        } catch (error: CancellationException) {
            throw error
        } catch (error: Exception) {
            Log.w(TAG, "The App Store lookup failed", error)
            return StoreOffer.Unknown
        }
        // Not sold in this region: the page named by the server is still the way to it.
        if (result == null) return StoreOffer.Unknown
        result.text("trackViewUrl")?.takeIf { StorePages.isOfficial(it, UpdatePlatform.IOS) }?.let { regionalPage = it }
        val storeVersion = result.text("version") ?: return StoreOffer.Unknown
        val toLatest = compareVersions(storeVersion, release.latestVersion) ?: return StoreOffer.Unknown
        val toInstalled = compareVersions(storeVersion, installed.name) ?: return StoreOffer.Unknown
        return when {
            toLatest >= 0 -> StoreOffer.Available(inApp = false)
            // The store still has this version or one between: the release has not reached it.
            toInstalled >= 0 -> StoreOffer.NotYet
            // The store names its versions differently from the app; it cannot tell.
            else -> StoreOffer.Unknown
        }
    }

    override fun startUpdate(release: PublishedRelease, offer: StoreOffer, required: Boolean) {
        val page = regionalPage ?: release.storeUrl
        val url = NSURL.URLWithString(page) ?: NSURL.URLWithString(StorePages.APP_STORE) ?: return
        UIApplication.sharedApplication.openURL(url, options = emptyMap<Any?, Any>(), completionHandler = null)
    }

    override fun installDownloaded() = Unit

    override fun clearFailedDownload() = Unit

    override fun resumeInterrupted() = Unit

    override fun watchConnectivity(onOnline: () -> Unit) {
        this.onOnline = onOnline
        if (monitor != null) return
        val pathMonitor = nw_path_monitor_create()
        var wasOnline: Boolean? = null
        nw_path_monitor_set_update_handler(pathMonitor) { path ->
            val online = nw_path_get_status(path) == nw_path_status_satisfied
            if (online && wasOnline == false) this.onOnline()
            wasOnline = online
        }
        nw_path_monitor_set_queue(pathMonitor, dispatch_get_main_queue())
        nw_path_monitor_start(pathMonitor)
        monitor = pathMonitor
    }

    private fun JsonObject.text(key: String): String? = (this[key] as? JsonPrimitive)?.takeIf { it.isString }?.content

    private companion object {
        const val TAG = "AppleAppStore"
    }
}
