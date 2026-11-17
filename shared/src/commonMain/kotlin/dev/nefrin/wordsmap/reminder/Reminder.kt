package dev.nefrin.wordsmap.reminder

import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.resolve

/**
 * When the daily reminder comes: [minuteOfDay] minutes after midnight, on the [days] of the
 * week, as ISO numbers (1 = Monday … 7 = Sunday). Days left out are skipped, such as the
 * weekend.
 */
@Immutable
data class ReminderSchedule(val minuteOfDay: Int, val days: Set<Int>) {
    val hour: Int get() = minuteOfDay / 60
    val minute: Int get() = minuteOfDay % 60

    /** "07:30". */
    val timeLabel: String get() = "${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}"

    /**
     * Days from today until the next reminder, at ISO weekday [today] and [nowMinute] minutes
     * after midnight: 0 when it still comes today, up to 7 when today's time has passed and
     * today is the only chosen day. Null when no day is chosen.
     */
    fun daysUntilNext(today: Int, nowMinute: Int): Int? {
        val first = if (nowMinute < minuteOfDay) 0 else 1
        return (first..7).firstOrNull { offset -> (today - 1 + offset) % 7 + 1 in days }
    }

    companion object {
        val Default = ReminderSchedule(minuteOfDay = 19 * 60, days = (1..7).toSet())
    }
}

/**
 * What the reminder says: how many of the daily words are still open today ([leftToday],
 * 0 once they are done, so today brings no reminder) and how many a day brings ([perDay]).
 */
@Immutable
data class ReminderWords(val leftToday: Int, val perDay: Int)

/** Title and text of the reminder in [language], for [left] of [perDay] daily words still open. */
fun reminderTexts(language: AppLanguage, left: Int, perDay: Int): Pair<String, String> {
    val text = if (left in 1 until perDay) {
        Strings.reminder_text_left.resolve(language, left.toString())
    } else {
        Strings.reminder_text.resolve(language, perDay.toString())
    }
    return Strings.reminder_title.resolve(language) to text
}

/** Plans the daily reminder on the device. It comes only on days whose words are not done. */
interface ReminderScheduler {
    /** Plans the reminder at [schedule], with its texts in [language]; null cancels it. */
    fun schedule(schedule: ReminderSchedule?, language: AppLanguage, words: ReminderWords)
}

/** The permission to show notifications. */
interface NotificationPermission {
    /** Whether the app may show notifications now. */
    suspend fun isGranted(): Boolean

    /** Asks the user when needed; true when the app may show notifications afterwards. */
    suspend fun request(): Boolean

    /** Opens the system settings where notifications can be allowed again. */
    fun openSettings()

    /**
     * Whether a reminder comes on the minute. Android asks the user for that ("Alarms &
     * reminders"); without it a reminder can come up to an hour late. Always true on iOS.
     */
    fun isExactTimeAllowed(): Boolean

    /** Opens the system screen where exact timing can be allowed. */
    fun allowExactTime()
}

@Composable
expect fun rememberNotificationPermission(): NotificationPermission
