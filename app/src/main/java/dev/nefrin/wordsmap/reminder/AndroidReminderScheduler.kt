package dev.nefrin.wordsmap.reminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.content.edit
import dev.nefrin.wordsmap.MainActivity
import dev.nefrin.wordsmap.data.AppLanguage
import java.util.Calendar

/**
 * The Android [ReminderScheduler]. It plans one reminder at a time; when that one has been
 * shown, [ReminderReceiver] plans the next.
 *
 * Phone makers hold back apps' exact alarms to save battery (OnePlus by up to an hour,
 * even with "Alarms & reminders" allowed), but they always deliver alarm-clock alarms on
 * time. An alarm clock puts an alarm icon in the status bar, though, so the reminder is
 * planned in two steps: a normal alarm [LEAD_MILLIS] before it, and only then the alarm
 * clock for the minute itself. Without "Alarms & reminders" only the normal alarm is
 * possible, and the reminder may come late.
 *
 * The planned reminder is remembered until it is shown. Planning again (on every app start,
 * for example) keeps it, so opening the app just after its time does not skip it.
 */
class AndroidReminderScheduler(context: Context) : ReminderScheduler {
    private val context = context.applicationContext
    private val state = this.context.getSharedPreferences(STATE_FILE, Context.MODE_PRIVATE)

    // The receiver reads the language and the words left when the reminder is due, and shows
    // nothing on a day whose words are done; so neither is needed here.
    override fun schedule(schedule: ReminderSchedule?, language: AppLanguage, words: ReminderWords) {
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        alarms.cancel(alarmIntent(ReminderReceiver.ACTION_PREPARE))
        alarms.cancel(alarmIntent(ReminderReceiver.ACTION_REMIND))
        if (schedule == null) {
            state.edit { remove(KEY_DUE) }
            return
        }
        val now = Calendar.getInstance()
        val due = listOfNotNull(keptReminder(schedule, now.timeInMillis), nextReminder(schedule, now)).minOrNull() ?: return
        state.edit { putLong(KEY_DUE, due) }
        val remind = alarmIntent(ReminderReceiver.ACTION_REMIND)
        when {
            !canBeExact(alarms) -> alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, due, remind)
            due - now.timeInMillis > LEAD_MILLIS -> alarms.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                due - LEAD_MILLIS,
                alarmIntent(ReminderReceiver.ACTION_PREPARE),
            )
            // A time that has just passed goes off at once.
            else -> alarms.setAlarmClock(AlarmManager.AlarmClockInfo(due, openApp(context)), remind)
        }
    }

    /** Called once the planned reminder is shown, so that planning moves on to the next one. */
    fun markShown() = state.edit { putLong(KEY_SHOWN, state.getLong(KEY_DUE, 0L)) }

    /** The reminder planned earlier, if it is not shown yet, still fits [schedule] and is at most [GRACE_MILLIS] overdue. */
    private fun keptReminder(schedule: ReminderSchedule, now: Long): Long? {
        val due = state.getLong(KEY_DUE, 0L)
        if (due == 0L || due == state.getLong(KEY_SHOWN, 0L) || due < now - GRACE_MILLIS) return null
        val time = Calendar.getInstance().apply { timeInMillis = due }
        val fits = isoWeekday(time) in schedule.days &&
            time.get(Calendar.HOUR_OF_DAY) == schedule.hour && time.get(Calendar.MINUTE) == schedule.minute
        return due.takeIf { fits }
    }

    private fun alarmIntent(action: String): PendingIntent = PendingIntent.getBroadcast(
        context,
        0,
        Intent(context, ReminderReceiver::class.java).setAction(action),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    companion object {
        private const val STATE_FILE = "reminder_alarm"
        private const val KEY_DUE = "due"
        private const val KEY_SHOWN = "shown"

        /** How long before the reminder the alarm clock is set; more than the hour alarms can be held back. */
        private const val LEAD_MILLIS = 75 * 60 * 1000L

        /** How late a planned reminder still comes, for example after the phone was off. */
        private const val GRACE_MILLIS = 60 * 60 * 1000L

        /** When the next reminder of [schedule] is due after [now], in epoch milliseconds. */
        fun nextReminder(schedule: ReminderSchedule, now: Calendar): Long? {
            val today = isoWeekday(now)
            val nowMinute = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
            val days = schedule.daysUntilNext(today, nowMinute) ?: return null
            return (now.clone() as Calendar).apply {
                add(Calendar.DAY_OF_YEAR, days)
                set(Calendar.HOUR_OF_DAY, schedule.hour)
                set(Calendar.MINUTE, schedule.minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }.timeInMillis
        }

        fun canBeExact(alarms: AlarmManager): Boolean =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()

        /** 1 = Monday … 7 = Sunday; [Calendar] counts from Sunday = 1. */
        fun isoWeekday(time: Calendar): Int = (time.get(Calendar.DAY_OF_WEEK) + 5) % 7 + 1

        /** Opens the app on the daily words, from the notification or from the alarm shown in the status bar. */
        fun openApp(context: Context): PendingIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java)
                .putExtra(MainActivity.EXTRA_OPEN_LEARN, true)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
