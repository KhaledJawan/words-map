package dev.nefrin.wordsmap.reminder

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import platform.UserNotifications.UNNotificationResponse
import platform.UserNotifications.UNUserNotificationCenter
import platform.UserNotifications.UNUserNotificationCenterDelegateProtocol
import platform.darwin.NSObject

/**
 * Notices a tap on the reminder, so the app can open on the daily words. iOS hands a tap
 * that launched the app only to a delegate set before launching ends, so the app delegate
 * installs it with [installReminderTaps].
 */
object ReminderTaps {
    /** Set when the reminder was tapped and the app has not shown the daily words since. */
    var pending: Boolean by mutableStateOf(false)

    // The notification center keeps its delegate weakly.
    private var delegate: TapDelegate? = null

    internal fun install() {
        if (delegate != null) return
        val handler = TapDelegate { pending = true }
        delegate = handler
        UNUserNotificationCenter.currentNotificationCenter().delegate = handler
    }
}

/** Called by the app delegate when the app finishes launching. */
@Suppress("unused") // Called from Swift.
fun installReminderTaps() = ReminderTaps.install()

private class TapDelegate(private val onTap: () -> Unit) : NSObject(), UNUserNotificationCenterDelegateProtocol {
    override fun userNotificationCenter(
        center: UNUserNotificationCenter,
        didReceiveNotificationResponse: UNNotificationResponse,
        withCompletionHandler: () -> Unit,
    ) {
        onTap()
        withCompletionHandler()
    }
}
