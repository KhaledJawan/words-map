package dev.nefrin.wordsmap.data

import dev.nefrin.wordsmap.reminder.ReminderSchedule

enum class ThemeMode { SYSTEM, LIGHT, DARK }

/**
 * Where the preferences are kept: SharedPreferences on Android, NSUserDefaults on iOS.
 * A null string removes the key.
 */
interface KeyValueStore {
    fun getString(key: String): String?
    fun putString(key: String, value: String?)
    fun getBoolean(key: String, default: Boolean): Boolean
    fun putBoolean(key: String, value: Boolean)
    fun getStringSet(key: String): Set<String>?
    fun putStringSet(key: String, value: Set<String>)
}

/** Everything the app remembers between launches. All of it stays on the device. */
class AppPreferences(private val prefs: KeyValueStore) {

    var appLanguage: AppLanguage
        get() = interfaceLanguage(prefs.getString(KEY_LANGUAGE))
        set(value) = prefs.putString(KEY_LANGUAGE, value.code)

    /** Null until the user picks a pair; the app then learns German through the interface language. */
    var wordPair: WordPair?
        get() {
            val source = AppLanguage.fromCode(prefs.getString(KEY_SOURCE_LANGUAGE))
            val target = AppLanguage.fromCode(prefs.getString(KEY_TARGET_LANGUAGE))
            return if (source != null && target != null && source != target) WordPair(source, target) else null
        }
        set(value) {
            prefs.putString(KEY_SOURCE_LANGUAGE, value?.source?.code)
            prefs.putString(KEY_TARGET_LANGUAGE, value?.target?.code)
        }

    var themeMode: ThemeMode
        get() = ThemeMode.entries.firstOrNull { it.name == prefs.getString(KEY_THEME) } ?: ThemeMode.LIGHT
        set(value) = prefs.putString(KEY_THEME, value.name)

    var appNotifications: Boolean
        get() = prefs.getBoolean(KEY_NOTIFICATIONS, true)
        set(value) = prefs.putBoolean(KEY_NOTIFICATIONS, value)

    var dailyReminder: Boolean
        get() = prefs.getBoolean(KEY_DAILY_REMINDER, false)
        set(value) = prefs.putBoolean(KEY_DAILY_REMINDER, value)

    /** Time and days of the daily reminder, kept while it is switched off. */
    var reminderSchedule: ReminderSchedule
        get() = ReminderSchedule(
            minuteOfDay = prefs.getString(KEY_REMINDER_TIME)?.toIntOrNull()?.takeIf { it in 0 until 24 * 60 }
                ?: ReminderSchedule.Default.minuteOfDay,
            days = prefs.getStringSet(KEY_REMINDER_DAYS)?.mapNotNull { day -> day.toIntOrNull()?.takeIf { it in 1..7 } }?.toSet()
                ?: ReminderSchedule.Default.days,
        )
        set(value) {
            prefs.putString(KEY_REMINDER_TIME, value.minuteOfDay.toString())
            prefs.putStringSet(KEY_REMINDER_DAYS, value.days.map { it.toString() }.toSet())
        }

    /** The reminder to plan on the device, or null when notifications or the reminder are off. */
    val activeReminder: ReminderSchedule?
        get() = reminderSchedule.takeIf { appNotifications && dailyReminder && it.days.isNotEmpty() }

    var lastLevel: String?
        get() = prefs.getString(KEY_LAST_LEVEL)
        set(value) = prefs.putString(KEY_LAST_LEVEL, value)

    /** The word group the home screen was left on, or null when it was showing a level or category. */
    var shownGroup: WordGroup?
        get() = WordGroup.entries.firstOrNull { it.key == prefs.getString(KEY_SHOWN_GROUP) }
            // Earlier builds only had the verbs, saved as a flag.
            ?: WordGroup.VERBS.takeIf { prefs.getBoolean(KEY_SHOWING_VERBS, false) }
        set(value) {
            prefs.putString(KEY_SHOWN_GROUP, value?.key)
            prefs.putBoolean(KEY_SHOWING_VERBS, false)
        }

    /** Level the words of [group] were last filtered by: "A1", or "" for every level; null if never chosen. */
    fun groupLevel(group: WordGroup): String? = prefs.getString(levelKey(group))

    fun setGroupLevel(group: WordGroup, level: String) = prefs.putString(levelKey(group), level)

    // "verbs_level", as earlier builds saved it.
    private fun levelKey(group: WordGroup) = "${group.key}_level"

    /** Category the home screen was left on, or null when it was showing a level. */
    var lastCategory: String?
        get() = prefs.getString(KEY_LAST_CATEGORY)
        set(value) = prefs.putString(KEY_LAST_CATEGORY, value)

    /** Whether reading texts mark the words that have a translation; off until the reader turns it on. */
    var highlightReadingWords: Boolean
        get() = prefs.getBoolean(KEY_HIGHLIGHT_READING_WORDS, false)
        set(value) = prefs.putBoolean(KEY_HIGHLIGHT_READING_WORDS, value)

    var viewedWordIds: Set<String>
        get() = stringSet(KEY_VIEWED)
        set(value) = prefs.putStringSet(KEY_VIEWED, value)

    var bookmarkedWordIds: Set<String>
        get() = stringSet(KEY_BOOKMARKED)
        set(value) = prefs.putStringSet(KEY_BOOKMARKED, value)

    /**
     * Every word bookmarked so far, newest first. A word stays after it is unbookmarked, until
     * it is removed on the Bookmarks page. Starts as the bookmarks of earlier versions.
     */
    var bookmarkHistory: List<String>
        get() = prefs.getString(KEY_BOOKMARK_HISTORY)?.split(',')?.filter { it.isNotEmpty() }
            ?: bookmarkedWordIds.sorted()
        set(value) = prefs.putString(KEY_BOOKMARK_HISTORY, value.joinToString(","))

    var completedLessonIds: Set<String>
        get() = stringSet(KEY_COMPLETED_LESSONS)
        set(value) = prefs.putStringSet(KEY_COMPLETED_LESSONS, value)

    // region My words

    /** The learner's own words, oldest first. */
    var userWords: List<UserWord>
        get() = UserWordsJson.decodeWords(prefs.getString(KEY_USER_WORDS))
        set(value) = prefs.putString(KEY_USER_WORDS, UserWordsJson.encodeWords(value))

    /** The learner's categories for their own words, in the order they were made. */
    var userLists: List<UserList>
        get() = UserWordsJson.decodeLists(prefs.getString(KEY_USER_LISTS))
        set(value) = prefs.putString(KEY_USER_LISTS, UserWordsJson.encodeLists(value))

    /**
     * The learner's words the home screen was left on: "" for all of them, a category id for
     * one category, or null when it was showing something else.
     */
    var shownUserList: String?
        get() = prefs.getString(KEY_SHOWN_USER_LIST)
        set(value) = prefs.putString(KEY_SHOWN_USER_LIST, value)

    // endregion

    // region Daily words

    var learnSource: LearnSource
        get() = LearnSource.fromKey(prefs.getString(KEY_LEARN_SOURCE)) ?: LearnSource.Default
        set(value) = prefs.putString(KEY_LEARN_SOURCE, value.key)

    var learnWordsPerDay: Int
        get() = prefs.getString(KEY_LEARN_PER_DAY)?.toIntOrNull()?.takeIf { it in 1..500 } ?: DailyWords.DEFAULT_COUNT
        set(value) = prefs.putString(KEY_LEARN_PER_DAY, value.toString())

    /** The day [learnTodayIds] were picked for, as a local epoch day. */
    var learnDay: Long?
        get() = prefs.getString(KEY_LEARN_DAY)?.toLongOrNull()
        set(value) = prefs.putString(KEY_LEARN_DAY, value?.toString())

    /** The words of [learnDay], in the order they were picked. */
    var learnTodayIds: List<String>
        get() = prefs.getString(KEY_LEARN_TODAY)?.split(',')?.filter { it.isNotEmpty() }.orEmpty()
        set(value) = prefs.putString(KEY_LEARN_TODAY, value.joinToString(","))

    /** The words of [learnDay] swiped as known so far. */
    var learnKnownToday: Set<String>
        get() = stringSet(KEY_LEARN_KNOWN)
        set(value) = prefs.putStringSet(KEY_LEARN_KNOWN, value)

    /** Every word ever swiped as known; the daily words pick other words first. */
    var learnedWordIds: Set<String>
        get() = stringSet(KEY_LEARNED)
        set(value) = prefs.putStringSet(KEY_LEARNED, value)

    /** The days whose words were all known in the end, as local epoch days. */
    var learnDoneDays: Set<Long>
        get() = stringSet(KEY_LEARN_DONE_DAYS).mapNotNull { it.toLongOrNull() }.toSet()
        set(value) = prefs.putStringSet(KEY_LEARN_DONE_DAYS, value.map { it.toString() }.toSet())

    // The app update check (see AppUpdates). Times are epoch milliseconds.

    /** The server's last valid answer, as it came. */
    var updateRelease: String?
        get() = prefs.getString(KEY_UPDATE_RELEASE)
        set(value) = prefs.putString(KEY_UPDATE_RELEASE, value)

    var updateLastSuccess: Long?
        get() = prefs.getString(KEY_UPDATE_LAST_SUCCESS)?.toLongOrNull()
        set(value) = prefs.putString(KEY_UPDATE_LAST_SUCCESS, value?.toString())

    var updateLastAttempt: Long?
        get() = prefs.getString(KEY_UPDATE_LAST_ATTEMPT)?.toLongOrNull()
        set(value) = prefs.putString(KEY_UPDATE_LAST_ATTEMPT, value?.toString())

    var updateLastFailed: Boolean
        get() = prefs.getBoolean(KEY_UPDATE_LAST_FAILED, false)
        set(value) = prefs.putBoolean(KEY_UPDATE_LAST_FAILED, value)

    /** The newest build whose optional update was put off with "Later". */
    var updateDismissedBuild: Long?
        get() = prefs.getString(KEY_UPDATE_DISMISSED_BUILD)?.toLongOrNull()
        set(value) = prefs.putString(KEY_UPDATE_DISMISSED_BUILD, value?.toString())

    /**
     * How many daily words are still waiting on [today]: none once they were done, and the
     * daily number before today's words are picked.
     */
    fun wordsLeftOn(today: Long): Int {
        if (today in learnDoneDays) return 0
        if (learnDay != today) return learnWordsPerDay
        val known = learnKnownToday
        return learnTodayIds.count { it !in known }
    }

    // endregion

    // A store may hand out a set it still owns, so callers get a copy.
    private fun stringSet(key: String): Set<String> = prefs.getStringSet(key)?.toSet().orEmpty()

    companion object {
        /** Name of the Android SharedPreferences file. */
        const val FILE = "wordsmap"
        private const val KEY_LANGUAGE = "app_language"
        private const val KEY_SOURCE_LANGUAGE = "word_source_language"
        private const val KEY_TARGET_LANGUAGE = "word_target_language"
        private const val KEY_THEME = "theme_mode"
        private const val KEY_NOTIFICATIONS = "app_notifications"
        private const val KEY_DAILY_REMINDER = "daily_reminder"
        private const val KEY_REMINDER_TIME = "reminder_minute_of_day"
        private const val KEY_REMINDER_DAYS = "reminder_days"
        private const val KEY_LAST_LEVEL = "last_level"
        private const val KEY_LAST_CATEGORY = "last_category"
        private const val KEY_SHOWING_VERBS = "showing_verbs"
        private const val KEY_SHOWN_GROUP = "shown_group"
        private const val KEY_VIEWED = "viewed_word_ids"
        private const val KEY_HIGHLIGHT_READING_WORDS = "highlight_reading_words"
        private const val KEY_BOOKMARKED = "bookmarked_word_ids"
        private const val KEY_BOOKMARK_HISTORY = "bookmark_history"
        private const val KEY_COMPLETED_LESSONS = "completed_lesson_ids"
        private const val KEY_USER_WORDS = "user_words"
        private const val KEY_USER_LISTS = "user_word_lists"
        private const val KEY_SHOWN_USER_LIST = "shown_user_list"
        private const val KEY_LEARN_SOURCE = "learn_source"
        private const val KEY_LEARN_PER_DAY = "learn_words_per_day"
        private const val KEY_LEARN_DAY = "learn_day"
        private const val KEY_LEARN_TODAY = "learn_today_ids"
        private const val KEY_LEARN_KNOWN = "learn_known_today"
        private const val KEY_LEARNED = "learned_word_ids"
        private const val KEY_LEARN_DONE_DAYS = "learn_done_days"
        private const val KEY_UPDATE_RELEASE = "update_release"
        private const val KEY_UPDATE_LAST_SUCCESS = "update_last_success"
        private const val KEY_UPDATE_LAST_ATTEMPT = "update_last_attempt"
        private const val KEY_UPDATE_LAST_FAILED = "update_last_failed"
        private const val KEY_UPDATE_DISMISSED_BUILD = "update_dismissed_build"

        private fun interfaceLanguage(code: String?): AppLanguage =
            AppLanguage.fromCode(code)?.takeIf { it in AppLanguage.interfaceLanguages } ?: AppLanguage.EN
    }
}
