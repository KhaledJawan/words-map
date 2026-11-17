package dev.nefrin.wordsmap.reminder

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import dev.nefrin.wordsmap.data.AppLanguage
import platform.Foundation.NSCalendar
import platform.Foundation.NSCalendarUnitDay
import platform.Foundation.NSCalendarUnitHour
import platform.Foundation.NSCalendarUnitMinute
import platform.Foundation.NSCalendarUnitMonth
import platform.Foundation.NSCalendarUnitWeekday
import platform.Foundation.NSCalendarUnitYear
import platform.Foundation.NSDate
import platform.Foundation.NSDateComponents
import platform.Foundation.NSURL
import platform.UIKit.UIApplication
import platform.UIKit.UIApplicationOpenSettingsURLString
import platform.UserNotifications.UNAuthorizationOptionAlert
import platform.UserNotifications.UNAuthorizationOptionSound
import platform.UserNotifications.UNAuthorizationStatusAuthorized
import platform.UserNotifications.UNAuthorizationStatusEphemeral
import platform.UserNotifications.UNAuthorizationStatusProvisional
import platform.UserNotifications.UNCalendarNotificationTrigger
import platform.UserNotifications.UNMutableNotificationContent
import platform.UserNotifications.UNNotificationRequest
import platform.UserNotifications.UNNotificationSound
import platform.UserNotifications.UNUserNotificationCenter
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

/**
 * The iOS [ReminderScheduler]. iOS shows a planned notification without asking the app, so
 * a day whose words are done must not have one: the reminder is planned as one notification
 * per day for the next [DAYS_AHEAD] days, today left out once its words are done. Every app
 * start plans them again; after four weeks without opening the app they stop, rather than
 * nag someone who has stopped learning.
 */
class IosReminderScheduler : ReminderScheduler {
    private val center get() = UNUserNotificationCenter.currentNotificationCenter()

    override fun schedule(schedule: ReminderSchedule?, language: AppLanguage, words: ReminderWords) {
        // Earlier builds planned one repeating notification per weekday.
        val legacy = (1..7).map { "daily-reminder-$it" }
        center.removePendingNotificationRequestsWithIdentifiers(legacy + (0 until DAYS_AHEAD).map(::requestId))
        if (schedule == null) return
        val calendar = NSCalendar.currentCalendar
        val now = NSDate()
        val clock = calendar.components(NSCalendarUnitHour or NSCalendarUnitMinute, fromDate = now)
        val nowMinute = (clock.hour * 60 + clock.minute).toInt()
        for (offset in 0 until DAYS_AHEAD) {
            if (offset == 0 && (words.leftToday == 0 || nowMinute >= schedule.minuteOfDay)) continue
            val date = calendar.dateByAddingUnit(NSCalendarUnitDay, offset.toLong(), toDate = now, options = 0u) ?: continue
            val dayParts = calendar.components(NSCalendarUnitYear or NSCalendarUnitMonth or NSCalendarUnitDay or NSCalendarUnitWeekday, fromDate = date)
            // Apple counts from Sunday = 1; ISO from Monday = 1.
            val isoWeekday = (dayParts.weekday.toInt() + 5) % 7 + 1
            if (isoWeekday !in schedule.days) continue
            val (title, text) = reminderTexts(language, if (offset == 0) words.leftToday else words.perDay, words.perDay)
            val content = UNMutableNotificationContent().apply {
                setTitle(title)
                setBody(text)
                setSound(UNNotificationSound.defaultSound)
            }
            val time = NSDateComponents().apply {
                setYear(dayParts.year)
                setMonth(dayParts.month)
                setDay(dayParts.day)
                setHour(schedule.hour.toLong())
                setMinute(schedule.minute.toLong())
            }
            val trigger = UNCalendarNotificationTrigger.triggerWithDateMatchingComponents(time, repeats = false)
            center.addNotificationRequest(
                UNNotificationRequest.requestWithIdentifier(requestId(offset), content, trigger),
                withCompletionHandler = null,
            )
        }
    }

    private fun requestId(slot: Int) = "practice-reminder-$slot"

    private companion object {
        // iOS keeps at most 64 planned notifications per app.
        const val DAYS_AHEAD = 28
    }
}

/**
 * Set by the screenshot hook of debug builds, so the reminder settings show without the
 * permission question, which a simulator cannot answer unattended.
 */
internal var notificationsAllowedForScreenshots = false

@Composable
actual fun rememberNotificationPermission(): NotificationPermission = remember { IosNotificationPermission() }

private class IosNotificationPermission : NotificationPermission {
    private val center get() = UNUserNotificationCenter.currentNotificationCenter()

    override suspend fun isGranted(): Boolean = notificationsAllowedForScreenshots || suspendCoroutine { continuation ->
        center.getNotificationSettingsWithCompletionHandler { settings ->
            val status = settings?.authorizationStatus
            continuation.resume(
                status == UNAuthorizationStatusAuthorized || status == UNAuthorizationStatusProvisional ||
                    status == UNAuthorizationStatusEphemeral,
            )
        }
    }

    // iOS asks only once; after that the answer can only be changed in the Settings app.
    override suspend fun request(): Boolean = suspendCoroutine { continuation ->
        center.requestAuthorizationWithOptions(UNAuthorizationOptionAlert or UNAuthorizationOptionSound) { granted, _ ->
            continuation.resume(granted)
        }
    }

    override fun openSettings() {
        val url = NSURL.URLWithString(UIApplicationOpenSettingsURLString) ?: return
        UIApplication.sharedApplication.openURL(url, options = emptyMap<Any?, Any>(), completionHandler = null)
    }

    // iOS delivers calendar notifications on the minute.
    override fun isExactTimeAllowed(): Boolean = true

    override fun allowExactTime() = Unit
}
