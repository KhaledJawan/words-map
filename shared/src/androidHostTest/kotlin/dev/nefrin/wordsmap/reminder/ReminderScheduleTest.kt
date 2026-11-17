package dev.nefrin.wordsmap.reminder

import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.data.KeyValueStore
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ReminderScheduleTest {
    // Monday to Friday at 19:00: Saturday and Sunday are skipped.
    private val weekdays = ReminderSchedule(minuteOfDay = 19 * 60, days = setOf(1, 2, 3, 4, 5))

    @Test
    fun `the reminder still comes today before its time`() {
        assertEquals(0, weekdays.daysUntilNext(today = 3, nowMinute = 8 * 60))
    }

    @Test
    fun `at or after its time the next chosen day follows`() {
        assertEquals(1, weekdays.daysUntilNext(today = 3, nowMinute = 19 * 60))
        assertEquals(1, weekdays.daysUntilNext(today = 3, nowMinute = 22 * 60))
    }

    @Test
    fun `skipped days are passed over`() {
        // Friday evening and the whole weekend lead to Monday.
        assertEquals(3, weekdays.daysUntilNext(today = 5, nowMinute = 20 * 60))
        assertEquals(2, weekdays.daysUntilNext(today = 6, nowMinute = 8 * 60))
        assertEquals(1, weekdays.daysUntilNext(today = 7, nowMinute = 23 * 60))
    }

    @Test
    fun `a single day comes again a week later`() {
        val sundays = ReminderSchedule(minuteOfDay = 9 * 60, days = setOf(7))
        assertEquals(7, sundays.daysUntilNext(today = 7, nowMinute = 10 * 60))
        assertNull(ReminderSchedule(minuteOfDay = 9 * 60, days = emptySet()).daysUntilNext(today = 1, nowMinute = 0))
    }

    @Test
    fun `the time is written with two digits`() {
        assertEquals("07:05", ReminderSchedule(minuteOfDay = 7 * 60 + 5, days = setOf(1)).timeLabel)
    }

    @Test
    fun `the schedule is saved, and only active with notifications and the reminder on`() {
        val prefs = AppPreferences(MapStore())
        assertEquals(ReminderSchedule.Default, prefs.reminderSchedule)
        prefs.reminderSchedule = weekdays
        assertEquals(weekdays, prefs.reminderSchedule)
        assertNull(prefs.activeReminder)
        prefs.dailyReminder = true
        assertEquals(weekdays, prefs.activeReminder)
        prefs.appNotifications = false
        assertNull(prefs.activeReminder)
    }

    private class MapStore : KeyValueStore {
        private val values = mutableMapOf<String, Any>()
        override fun getString(key: String) = values[key] as String?
        override fun putString(key: String, value: String?) {
            if (value == null) values.remove(key) else values[key] = value
        }
        override fun getBoolean(key: String, default: Boolean) = values[key] as Boolean? ?: default
        override fun putBoolean(key: String, value: Boolean) { values[key] = value }
        @Suppress("UNCHECKED_CAST")
        override fun getStringSet(key: String) = values[key] as Set<String>?
        override fun putStringSet(key: String, value: Set<String>) { values[key] = value }
    }
}
