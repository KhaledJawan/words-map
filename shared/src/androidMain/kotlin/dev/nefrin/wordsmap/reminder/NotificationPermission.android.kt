package dev.nefrin.wordsmap.reminder

import android.Manifest
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.compose.ManagedActivityResultLauncher
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.core.app.NotificationManagerCompat
import kotlinx.coroutines.CompletableDeferred

@Composable
actual fun rememberNotificationPermission(): NotificationPermission {
    val context = LocalContext.current
    val permission = remember(context) { AndroidNotificationPermission(context) }
    permission.launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        permission.answer?.complete(granted)
    }
    return permission
}

/** Android 13 and later ask at runtime; earlier versions allow notifications unless the user blocked them. */
private class AndroidNotificationPermission(private val context: Context) : NotificationPermission {
    lateinit var launcher: ManagedActivityResultLauncher<String, Boolean>
    var answer: CompletableDeferred<Boolean>? = null

    override suspend fun isGranted(): Boolean = NotificationManagerCompat.from(context).areNotificationsEnabled()

    override suspend fun request(): Boolean {
        if (isGranted()) return true
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return false
        val pending = CompletableDeferred<Boolean>()
        answer = pending
        // After two refusals Android answers "no" at once, without showing the question.
        launcher.launch(Manifest.permission.POST_NOTIFICATIONS)
        return pending.await() && isGranted()
    }

    override fun openSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", context.packageName, null))
        }
        runCatching { context.startActivity(intent) }
    }

    override fun isExactTimeAllowed(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S || context.getSystemService(AlarmManager::class.java)?.canScheduleExactAlarms() != false

    override fun allowExactTime() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        runCatching {
            context.startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.fromParts("package", context.packageName, null)))
        }
    }
}
