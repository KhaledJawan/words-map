package dev.nefrin.wordsmap.reminder

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import dev.nefrin.wordsmap.R
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.data.SharedPreferencesStore
import dev.nefrin.wordsmap.platform.localEpochDay
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.resolve

/**
 * Shows the daily reminder when its alarm goes off, unless the day's words are already
 * done, and plans the next one. The earlier
 * alarm of a reminder ([ACTION_PREPARE]) only plans it again, which then sets the alarm
 * clock. Alarms do not survive a restart or a change of the clock, so those plan the
 * reminder again too.
 */
class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prefs = AppPreferences(SharedPreferencesStore(context))
        val schedule = prefs.activeReminder
        val scheduler = AndroidReminderScheduler(context)
        // Changing the time or days plans again and drops the old alarm, so this one is current.
        if (intent.action == ACTION_REMIND && schedule != null) {
            val left = prefs.wordsLeftOn(localEpochDay())
            if (left > 0) showReminder(context, prefs.appLanguage, left, prefs.learnWordsPerDay)
            scheduler.markShown()
        }
        scheduler.schedule(schedule, prefs.appLanguage, ReminderWords(prefs.wordsLeftOn(localEpochDay()), prefs.learnWordsPerDay))
    }

    private fun showReminder(context: Context, language: AppLanguage, left: Int, perDay: Int) {
        val notifications = NotificationManagerCompat.from(context)
        val allowed = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        if (!allowed || !notifications.areNotificationsEnabled()) return

        notifications.createNotificationChannel(
            NotificationChannelCompat.Builder(CHANNEL_ID, NotificationManagerCompat.IMPORTANCE_DEFAULT)
                .setName(Strings.settings_daily_reminder.resolve(language))
                .build(),
        )
        val (title, text) = reminderTexts(language, left, perDay)
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setColor(ContextCompat.getColor(context, R.color.reminder_accent))
            .setContentTitle(title)
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setContentIntent(AndroidReminderScheduler.openApp(context))
            .setAutoCancel(true)
            .build()
        notifications.notify(NOTIFICATION_ID, notification)
    }

    companion object {
        const val ACTION_REMIND = "dev.nefrin.wordsmap.action.REMIND"
        const val ACTION_PREPARE = "dev.nefrin.wordsmap.action.PREPARE_REMINDER"
        private const val CHANNEL_ID = "daily_reminder"
        private const val NOTIFICATION_ID = 1
    }
}
