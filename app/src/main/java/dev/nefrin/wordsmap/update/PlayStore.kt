package dev.nefrin.wordsmap.update

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.IntentSenderRequest
import androidx.core.content.pm.PackageInfoCompat
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.ActivityResult
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

/**
 * Google Play, through its official in-app updates. An optional update downloads while the
 * app stays in use ("flexible") and installs with a restart; a required one uses Play's
 * full-screen flow ("immediate"). Play decides whether this phone can have the update yet.
 *
 * A copy not installed by Play (a test build, say) cannot be updated by Play inside the app;
 * its "Update" opens the Play page. Nothing is ever downloaded or installed by the app itself.
 *
 * One instance per process, so the activity and the view model share it.
 */
class PlayStore private constructor(context: Context) : AppStore {
    private val context = context.applicationContext
    private val manager = AppUpdateManagerFactory.create(this.context)
    private val scope = MainScope()
    private val main = Handler(Looper.getMainLooper())

    override val platform = UpdatePlatform.ANDROID

    override val installed: InstalledVersion = packageInfo().let { info ->
        InstalledVersion(name = info?.versionName.orEmpty(), build = info?.let(PackageInfoCompat::getLongVersionCode) ?: 0L)
    }

    /** Whether Google Play installed this copy: only then can Play update it in the app. */
    private val fromPlay: Boolean = installerPackage() == PLAY_STORE

    private val downloadState = MutableStateFlow<UpdateDownload?>(null)
    override val download: StateFlow<UpdateDownload?> = downloadState.asStateFlow()

    // The activity's launcher for Play's update screens, while an activity is there.
    private var launcher: ActivityResultLauncher<IntentSenderRequest>? = null

    private var onOnline: () -> Unit = {}
    private var watchingNetwork = false

    private val installState = InstallStateUpdatedListener { state ->
        downloadState.value = when (state.installStatus()) {
            InstallStatus.PENDING -> UpdateDownload.Running(null)
            InstallStatus.DOWNLOADING -> UpdateDownload.Running(share(state.bytesDownloaded(), state.totalBytesToDownload()))
            InstallStatus.DOWNLOADED -> UpdateDownload.Ready
            InstallStatus.INSTALLING -> UpdateDownload.Ready
            InstallStatus.FAILED -> UpdateDownload.Failed
            InstallStatus.CANCELED, InstallStatus.INSTALLED -> null
            else -> downloadState.value
        }
    }

    init {
        // Also hears a download that went on in Play while the app was closed.
        if (fromPlay) manager.registerListener(installState)
    }

    /** Called by the activity when it is created; its launcher shows Play's update screens. */
    fun attach(launcher: ActivityResultLauncher<IntentSenderRequest>) {
        this.launcher = launcher
    }

    fun detach(launcher: ActivityResultLauncher<IntentSenderRequest>) {
        if (this.launcher === launcher) this.launcher = null
    }

    /** The answer of Play's update screen. */
    fun onFlowResult(resultCode: Int) {
        when (resultCode) {
            // Turned down: the update is offered again later, as Settings still shows it.
            Activity.RESULT_CANCELED -> if (downloadState.value is UpdateDownload.Running) downloadState.value = null
            ActivityResult.RESULT_IN_APP_UPDATE_FAILED -> downloadState.value = UpdateDownload.Failed
        }
    }

    override suspend fun check(release: PublishedRelease): StoreOffer {
        if (!fromPlay) return StoreOffer.Unknown
        val info = updateInfo() ?: return StoreOffer.Unknown
        return when (info.updateAvailability()) {
            UpdateAvailability.UPDATE_AVAILABLE, UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS -> StoreOffer.Available(
                inApp = info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE) || info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE),
            )
            UpdateAvailability.UPDATE_NOT_AVAILABLE -> StoreOffer.NotYet
            else -> StoreOffer.Unknown
        }
    }

    override fun startUpdate(release: PublishedRelease, offer: StoreOffer, required: Boolean) {
        if (offer !is StoreOffer.Available || !offer.inApp || !fromPlay) {
            openStorePage(release.storeUrl)
            return
        }
        scope.launch {
            // An update info can start one flow only, so a fresh one is asked for.
            val info = updateInfo()
            val launcher = launcher
            val type = info?.let { pickType(it, required) }
            val started = info != null && launcher != null && type != null && try {
                manager.startUpdateFlowForResult(info, launcher, AppUpdateOptions.newBuilder(type).build())
            } catch (error: Exception) {
                Log.w(TAG, "Play's update flow could not start", error)
                false
            }
            if (started && type == AppUpdateType.FLEXIBLE) downloadState.value = UpdateDownload.Running(null)
            if (!started) openStorePage(release.storeUrl)
        }
    }

    override fun installDownloaded() {
        manager.completeUpdate().addOnFailureListener { error ->
            Log.w(TAG, "The downloaded update could not be installed", error)
            downloadState.value = UpdateDownload.Failed
        }
    }

    override fun clearFailedDownload() {
        if (downloadState.value == UpdateDownload.Failed) downloadState.value = null
    }

    override fun resumeInterrupted() {
        if (!fromPlay) return
        scope.launch {
            val info = updateInfo() ?: return@launch
            when {
                info.installStatus() == InstallStatus.DOWNLOADED -> downloadState.value = UpdateDownload.Ready
                info.installStatus() == InstallStatus.DOWNLOADING || info.installStatus() == InstallStatus.PENDING ->
                    downloadState.value = UpdateDownload.Running(share(info.bytesDownloaded(), info.totalBytesToDownload()))
                // A required update was left during Play's full-screen flow: Play asks to show it again.
                info.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS -> launcher?.let { launcher ->
                    runCatching { manager.startUpdateFlowForResult(info, launcher, AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build()) }
                }
            }
        }
    }

    override fun watchConnectivity(onOnline: () -> Unit) {
        this.onOnline = onOnline
        if (watchingNetwork) return
        val connectivity = context.getSystemService(ConnectivityManager::class.java) ?: return
        watchingNetwork = runCatching {
            connectivity.registerDefaultNetworkCallback(object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    main.post { this@PlayStore.onOnline() }
                }
            })
        }.isSuccess
    }

    private fun pickType(info: AppUpdateInfo, required: Boolean): Int? = when {
        required && info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE) -> AppUpdateType.IMMEDIATE
        info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE) -> AppUpdateType.FLEXIBLE
        info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE) -> AppUpdateType.IMMEDIATE
        else -> null
    }

    private suspend fun updateInfo(): AppUpdateInfo? = suspendCancellableCoroutine { continuation ->
        manager.appUpdateInfo
            .addOnSuccessListener { continuation.resume(it) }
            .addOnFailureListener { error ->
                Log.w(TAG, "Play could not be asked for updates", error)
                continuation.resume(null)
            }
    }

    /** The Play app's page of WordsMap, or the Play website when the Play app is missing. */
    private fun openStorePage(url: String) {
        val page = Uri.parse(url.takeIf { StorePages.isOfficial(it, UpdatePlatform.ANDROID) } ?: StorePages.PLAY)
        val intent = Intent(Intent.ACTION_VIEW, page).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val opened = runCatching { context.startActivity(Intent(intent).setPackage(PLAY_STORE)) }.isSuccess ||
            runCatching { context.startActivity(intent) }.isSuccess
        if (!opened) Log.w(TAG, "No app can open the Play page")
    }

    @Suppress("DEPRECATION")
    private fun packageInfo() = try {
        context.packageManager.getPackageInfo(context.packageName, 0)
    } catch (error: PackageManager.NameNotFoundException) {
        null
    }

    @Suppress("DEPRECATION")
    private fun installerPackage(): String? = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            context.packageManager.getInstallSourceInfo(context.packageName).installingPackageName
        } else {
            context.packageManager.getInstallerPackageName(context.packageName)
        }
    } catch (error: Exception) {
        null
    }

    private fun share(done: Long, total: Long): Float? = if (total > 0) (done.toFloat() / total).coerceIn(0f, 1f) else null

    companion object {
        private const val TAG = "PlayStore"
        private const val PLAY_STORE = "com.android.vending"

        @Volatile
        private var instance: PlayStore? = null

        fun get(context: Context): PlayStore = instance ?: synchronized(this) {
            instance ?: PlayStore(context).also { instance = it }
        }
    }
}
