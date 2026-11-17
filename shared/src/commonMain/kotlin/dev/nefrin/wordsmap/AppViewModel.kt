package dev.nefrin.wordsmap

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.data.GermanWordIndex
import dev.nefrin.wordsmap.data.Grammar
import dev.nefrin.wordsmap.data.LearnSource
import dev.nefrin.wordsmap.data.GrammarRepository
import dev.nefrin.wordsmap.data.Lessons
import dev.nefrin.wordsmap.data.LessonsRepository
import dev.nefrin.wordsmap.data.Texts
import dev.nefrin.wordsmap.data.TextsRepository
import dev.nefrin.wordsmap.data.ThemeMode
import dev.nefrin.wordsmap.data.UserList
import dev.nefrin.wordsmap.data.UserWord
import dev.nefrin.wordsmap.data.asWord
import dev.nefrin.wordsmap.data.isUserWordId
import dev.nefrin.wordsmap.data.newUserListId
import dev.nefrin.wordsmap.data.newUserWordId
import dev.nefrin.wordsmap.data.tidy
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.data.VocabularyRepository
import dev.nefrin.wordsmap.data.Word
import dev.nefrin.wordsmap.data.WordGroup
import dev.nefrin.wordsmap.data.WordPair
import dev.nefrin.wordsmap.data.WordSearch
import dev.nefrin.wordsmap.data.bandOf
import dev.nefrin.wordsmap.learn.Learning
import dev.nefrin.wordsmap.platform.Log
import dev.nefrin.wordsmap.platform.localEpochDay
import dev.nefrin.wordsmap.reminder.ReminderSchedule
import dev.nefrin.wordsmap.reminder.ReminderScheduler
import dev.nefrin.wordsmap.reminder.ReminderWords
import dev.nefrin.wordsmap.update.AppStore
import dev.nefrin.wordsmap.update.AppUpdates
import dev.nefrin.wordsmap.update.UpdateServer
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

sealed interface ContentState {
    data object Loading : ContentState
    data object Failed : ContentState
    class Ready(
        val vocabulary: Vocabulary,
        val grammar: Grammar,
        val texts: Texts,
        /** Finds vocabulary words inside the reading texts. */
        val wordIndex: GermanWordIndex,
        /** The word search on the home screen. */
        val wordSearch: WordSearch,
    ) : ContentState
}

sealed interface LessonsState {
    data object Loading : LessonsState
    data object Failed : LessonsState
    class Ready(val lessons: Lessons) : LessonsState
}

/**
 * What the home screen lists: one level, every word carrying one category tag, a word group
 * such as the verbs, or the learner's own words.
 */
sealed interface WordsScope {
    data class Level(val level: String) : WordsScope
    data class Category(val tag: String) : WordsScope

    /** The words of [group] at one CEFR level such as "A1", or at every level when [band] is null. */
    data class Group(val group: WordGroup, val band: String?) : WordsScope

    /** The learner's own words: those of one of their categories, or all when [listId] is null. */
    data class Mine(val listId: String?) : WordsScope
}

enum class MainTab { HOME, LEARN, BOOKMARKS, LESSONS, PROFILE }

sealed interface Screen {
    /** Name under which the screen's scroll position and inputs are kept while it is in the back stack. */
    val key: String

    /** Whether the screen sits on the page background; the lesson screens have a colored top bar instead. */
    val onPageBackground: Boolean get() = false

    data object Main : Screen {
        override val key = "main"
        override val onPageBackground = true
    }

    /** The cards of the daily words. */
    data object LearnSession : Screen {
        override val key = "learn-session"
        override val onPageBackground = true
    }

    /** The learner's own words, starting on one of their categories, or on all when [listId] is null. */
    data class MyWords(val listId: String?) : Screen {
        override val key get() = "my-words:${listId.orEmpty()}"
        override val onPageBackground get() = true
    }

    data object Alphabet : Screen {
        override val key = "alphabet"
    }

    data object Combinations : Screen {
        override val key = "combinations"
    }

    data object Grammar : Screen {
        override val key = "grammar"
    }

    data class GrammarChapter(val chapterId: String) : Screen {
        override val key get() = "grammar-chapter:$chapterId"
    }

    data class GrammarLesson(val lessonId: String) : Screen {
        override val key get() = "grammar-lesson:$lessonId"
    }

    data object Texts : Screen {
        override val key = "texts"
    }

    data class TextsChapter(val chapterId: String) : Screen {
        override val key get() = "texts-chapter:$chapterId"
    }

    data class Text(val textId: String) : Screen {
        override val key get() = "text:$textId"
    }
}

class AppViewModel(
    private val prefs: AppPreferences,
    private val reminders: ReminderScheduler,
    store: AppStore,
) : ViewModel() {

    var content: ContentState by mutableStateOf(ContentState.Loading)
        private set

    var appLanguage by mutableStateOf(prefs.appLanguage)
        private set
    var wordPair by mutableStateOf(prefs.wordPair)
        private set
    var themeMode by mutableStateOf(prefs.themeMode)
        private set
    var highlightReadingWords by mutableStateOf(prefs.highlightReadingWords)
        private set
    var appNotifications by mutableStateOf(prefs.appNotifications)
        private set
    var dailyReminder by mutableStateOf(prefs.dailyReminder)
        private set
    var reminderSchedule by mutableStateOf(prefs.reminderSchedule)
        private set

    /** Language shown on the word chips. */
    val sourceLanguage: AppLanguage get() = wordPair?.source ?: AppLanguage.DE

    /** Language of the meanings, and of everything in the Lessons tab. */
    val targetLanguage: AppLanguage get() = wordPair?.target ?: appLanguage

    var viewedIds by mutableStateOf(prefs.viewedWordIds)
        private set
    var bookmarkedIds by mutableStateOf(prefs.bookmarkedWordIds)
        private set

    /** What the Bookmarks page lists: every word bookmarked so far, newest first. */
    var bookmarkHistory by mutableStateOf(prefs.bookmarkHistory.let { it + (bookmarkedIds - it.toSet()) })
        private set
    var completedLessonIds by mutableStateOf(prefs.completedLessonIds)
        private set

    /** The learner's own words, oldest first, and their categories. */
    var userWords: List<UserWord> by mutableStateOf(prefs.userWords)
        private set
    var userLists: List<UserList> by mutableStateOf(prefs.userLists)
        private set

    /** The daily words and their cards. */
    val learning = Learning(prefs, pool = ::learnPool, exists = ::wordExists, onProgress = ::planReminder)

    /** Newer versions of the app, from the WordsMap server and the platform's store. */
    val updates = AppUpdates(prefs, UpdateServer(), store, viewModelScope)

    var scope: WordsScope by mutableStateOf(WordsScope.Level(""))
        private set

    /** Words of [scope], ordered once when the scope is opened or refreshed. */
    var visibleWords: List<Word> by mutableStateOf(emptyList())
        private set

    var lessons: LessonsState by mutableStateOf(LessonsState.Loading)
        private set

    val backStack = mutableStateListOf<Screen>(Screen.Main)
    var selectedTab by mutableStateOf(MainTab.HOME)

    /** A word whose card the home screen opens when it first appears; set only for App Store screenshots. */
    var startWordId: String? = null

    private var saveProgressJob: Job? = null
    private var lessonsJob: Job? = null

    init {
        // Plans the reminder again on every start, so it survives updates and cleared alarms.
        planReminder()
        // A check that failed offline is tried again once the phone is online. The checks on
        // start and on every return to the app come from the screen (see WordsMapApp).
        store.watchConnectivity(updates::onOnline)
        viewModelScope.launch {
            content = try {
                withContext(Dispatchers.IO) {
                    val vocabulary = VocabularyRepository.load()
                    val wordIndex = GermanWordIndex(vocabulary)
                    ContentState.Ready(
                        vocabulary = vocabulary,
                        grammar = GrammarRepository.load(),
                        texts = TextsRepository.load(),
                        wordIndex = wordIndex,
                        wordSearch = WordSearch(vocabulary, wordIndex),
                    )
                }
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                Log.e(TAG, "Could not load the vocabulary", error)
                ContentState.Failed
            }
            (content as? ContentState.Ready)?.let {
                restoreScope(it.vocabulary)
                learning.refresh()
            }
        }
        loadLessons()
    }

    // region Words

    fun selectLevel(level: String) {
        prefs.lastLevel = level
        prefs.lastCategory = null
        prefs.shownGroup = null
        prefs.shownUserList = null
        showScope(WordsScope.Level(level))
    }

    fun selectCategory(tag: String) {
        prefs.lastCategory = tag
        prefs.shownGroup = null
        prefs.shownUserList = null
        showScope(WordsScope.Category(tag))
    }

    /** Shows the learner's own words: one of their categories, or all of them when [listId] is null. */
    fun selectMine(listId: String?) {
        prefs.shownGroup = null
        prefs.shownUserList = listId.orEmpty()
        showScope(WordsScope.Mine(listId))
    }

    /**
     * Shows a word group, at the level picked for it last time, or else at the level of the
     * group or chapter on screen.
     */
    fun openGroup(group: WordGroup) {
        val vocabulary = (content as? ContentState.Ready)?.vocabulary ?: return
        val current = scope
        val saved = prefs.groupLevel(group)
        val band = when {
            current is WordsScope.Group && current.group == group -> current.band
            saved != null -> saved.ifEmpty { null }
            current is WordsScope.Group -> current.band
            current is WordsScope.Level -> bandOf(current.level)
            else -> null
        }
        selectGroup(group, band?.takeIf { it in vocabulary.bandsOf(group) })
    }

    /** Shows the words of [group] at one CEFR level, or at every level when [band] is null. */
    fun selectGroup(group: WordGroup, band: String?) {
        prefs.shownGroup = group
        prefs.shownUserList = null
        prefs.setGroupLevel(group, band.orEmpty())
        showScope(WordsScope.Group(group, band))
    }

    /** Re-applies the display order: bookmarked words first, viewed words last. */
    fun refreshOrder() = showScope(scope)

    fun markViewed(word: Word) = markViewed(word.id)

    fun markViewed(id: String) {
        if (id in viewedIds) return
        viewedIds = viewedIds + id
        saveProgressSoon()
    }

    /** Bookmarks [word] or takes the bookmark away; either way it stays on the Bookmarks page. */
    fun toggleBookmark(word: Word) {
        if (word.id in bookmarkedIds) {
            bookmarkedIds = bookmarkedIds - word.id
        } else {
            bookmarkedIds = bookmarkedIds + word.id
            bookmarkHistory = listOf(word.id) + (bookmarkHistory - word.id)
        }
        saveProgressSoon()
        if (learning.source == LearnSource.Bookmarks) learning.wordsChanged()
    }

    /** Takes [word] off the Bookmarks page for good, and its bookmark with it. */
    fun removeFromBookmarks(word: Word) {
        bookmarkedIds = bookmarkedIds - word.id
        bookmarkHistory = bookmarkHistory - word.id
        saveProgressSoon()
    }

    // endregion

    // region My words

    fun userWord(id: String): UserWord? = userWords.firstOrNull { it.id == id }

    fun userList(id: String?): UserList? = id?.let { userLists.firstOrNull { list -> list.id == it } }

    /** The learner's words of one category, or all of them when [listId] is null, newest first. */
    fun userWordsIn(listId: String?): List<UserWord> =
        userWords.filter { listId == null || it.listId == listId }.asReversed()

    /** Adds a new word, or saves the changes to one that has [UserWord.id] already. */
    fun saveUserWord(word: UserWord) {
        val clean = word.tidy().let { if (it.id.isEmpty()) it.copy(id = newUserWordId()) else it }
        if (clean.text.isEmpty() || clean.translation.isEmpty()) return
        val index = userWords.indexOfFirst { it.id == clean.id }
        userWords = if (index < 0) userWords + clean else userWords.toMutableList().also { it[index] = clean }
        userWordsChanged()
    }

    fun deleteUserWord(id: String) {
        userWords = userWords.filterNot { it.id == id }
        viewedIds = viewedIds - id
        bookmarkedIds = bookmarkedIds - id
        saveProgressSoon()
        userWordsChanged()
    }

    /** Makes a category for the learner's words and returns it. */
    fun addUserList(name: String): UserList? {
        val clean = name.trim().ifEmpty { return null }
        userLists.firstOrNull { it.name.equals(clean, ignoreCase = true) }?.let { return it }
        val list = UserList(newUserListId(), clean)
        userLists = userLists + list
        prefs.userLists = userLists
        return list
    }

    fun renameUserList(id: String, name: String) {
        val clean = name.trim().ifEmpty { return }
        userLists = userLists.map { if (it.id == id) it.copy(name = clean) else it }
        prefs.userLists = userLists
    }

    /** Deletes a category; its words stay, without a category. */
    fun deleteUserList(id: String) {
        userLists = userLists.filterNot { it.id == id }
        prefs.userLists = userLists
        userWords = userWords.map { if (it.listId == id) it.copy(listId = null) else it }
        if (scope == WordsScope.Mine(id)) selectMine(null)
        val source = learning.source
        if (source is LearnSource.Mine && source.listId == id) learning.changeSource(LearnSource.Mine(null))
        userWordsChanged()
    }

    private fun userWordsChanged() {
        prefs.userWords = userWords
        if (scope is WordsScope.Mine) showScope(scope)
        if (learning.source is LearnSource.Mine) learning.wordsChanged()
    }

    // endregion

    // region Daily words

    /** Opens a sitting with today's open words. */
    fun startLearning() {
        learning.start()
        open(Screen.LearnSession)
    }

    /** Goes through today's words once more, after they are done. */
    fun reviewToday() {
        learning.startReview()
        open(Screen.LearnSession)
    }

    /** Shows the Learn tab, as a tap on the daily reminder does. */
    fun openLearn() {
        while (backStack.size > 1) back()
        selectedTab = MainTab.LEARN
    }

    private fun learnPool(source: LearnSource): List<String> {
        val vocabulary = (content as? ContentState.Ready)?.vocabulary ?: return emptyList()
        return when (source) {
            LearnSource.Random -> vocabulary.all.map { it.id }
            is LearnSource.Level -> vocabulary.wordsInLevel(source.level).map { it.id }
            is LearnSource.Category -> vocabulary.wordsInCategory(source.tag).map { it.id }
            is LearnSource.Group -> vocabulary.wordsIn(source.group).map { it.id }
            LearnSource.Bookmarks -> bookmarkHistory.filter { it in bookmarkedIds && vocabulary.find(it) != null }
            is LearnSource.Mine -> userWords.filter { source.listId == null || it.listId == source.listId }.map { it.id }
        }
    }

    private fun wordExists(id: String): Boolean =
        if (isUserWordId(id)) userWords.any { it.id == id } else (content as? ContentState.Ready)?.vocabulary?.find(id) != null

    private fun restoreScope(vocabulary: Vocabulary) {
        val category = prefs.lastCategory?.takeIf { it in vocabulary.byCategory }
        val level = prefs.lastLevel?.takeIf { it in vocabulary.levels } ?: vocabulary.levels.first()
        val group = prefs.shownGroup
        val mine = prefs.shownUserList
        showScope(
            when {
                group != null -> WordsScope.Group(group, prefs.groupLevel(group)?.takeIf { it in vocabulary.bandsOf(group) })
                mine != null -> WordsScope.Mine(mine.ifEmpty { null }?.takeIf { id -> userLists.any { it.id == id } })
                category != null -> WordsScope.Category(category)
                else -> WordsScope.Level(level)
            },
        )
    }

    private fun showScope(newScope: WordsScope) {
        val vocabulary = (content as? ContentState.Ready)?.vocabulary ?: return
        val words = when (newScope) {
            is WordsScope.Level -> vocabulary.wordsInLevel(newScope.level)
            is WordsScope.Category -> vocabulary.wordsInCategory(newScope.tag)
            is WordsScope.Group -> vocabulary.wordsIn(newScope.group, newScope.band)
            is WordsScope.Mine -> userWords
                .filter { newScope.listId == null || it.listId == newScope.listId }
                .asReversed()
                .map { it.asWord(sourceLanguage, targetLanguage) }
        }
        val (bookmarked, others) = words.partition { it.id in bookmarkedIds }
        val (viewed, fresh) = others.partition { it.id in viewedIds }
        scope = newScope
        visibleWords = bookmarked + fresh + viewed
    }

    private fun saveProgressSoon() {
        saveProgressJob?.cancel()
        saveProgressJob = viewModelScope.launch {
            delay(SAVE_DELAY_MILLIS)
            saveProgress()
        }
    }

    private fun saveProgress() {
        prefs.viewedWordIds = viewedIds
        prefs.bookmarkedWordIds = bookmarkedIds
        prefs.bookmarkHistory = bookmarkHistory
    }

    override fun onCleared() {
        if (saveProgressJob?.isActive == true) saveProgress()
    }

    // endregion

    // region Settings

    fun changeAppLanguage(language: AppLanguage) {
        prefs.appLanguage = language
        appLanguage = language
        // The reminder's texts are in the app language.
        planReminder()
    }

    fun changeWordPair(source: AppLanguage, target: AppLanguage) {
        val previousSource = sourceLanguage
        val pair = WordPair(source, target)
        prefs.wordPair = pair
        wordPair = pair
        if (source != previousSource) loadLessons()
        // The learner's words are shown in the languages of the pair.
        if (scope is WordsScope.Mine) showScope(scope)
    }

    /** Makes German the learned language; the translation language stays unless it is German too. */
    fun learnGerman() {
        val target = targetLanguage.takeIf { it != AppLanguage.DE }
            ?: appLanguage.takeIf { it != AppLanguage.DE }
            ?: AppLanguage.EN
        changeWordPair(AppLanguage.DE, target)
    }

    fun changeThemeMode(mode: ThemeMode) {
        prefs.themeMode = mode
        themeMode = mode
    }

    fun toggleReadingHighlights() {
        highlightReadingWords = !highlightReadingWords
        prefs.highlightReadingWords = highlightReadingWords
    }

    /** Turns notifications on or off; the screen asks for the permission before turning them on. */
    fun changeAppNotifications(enabled: Boolean) {
        prefs.appNotifications = enabled
        appNotifications = enabled
        planReminder()
    }

    /** Turns the daily reminder on or off; turning it on also turns notifications on. */
    fun changeDailyReminder(enabled: Boolean) {
        if (enabled) {
            prefs.appNotifications = true
            appNotifications = true
        }
        prefs.dailyReminder = enabled
        dailyReminder = enabled
        planReminder()
    }

    fun changeReminderTime(minuteOfDay: Int) = changeReminderSchedule(reminderSchedule.copy(minuteOfDay = minuteOfDay))

    /** Skips [day] (ISO 1 = Monday … 7 = Sunday) or brings it back; the last chosen day stays. */
    fun toggleReminderDay(day: Int) {
        val days = reminderSchedule.days
        if (day in days && days.size == 1) return
        changeReminderSchedule(reminderSchedule.copy(days = if (day in days) days - day else days + day))
    }

    private fun changeReminderSchedule(schedule: ReminderSchedule) {
        prefs.reminderSchedule = schedule
        reminderSchedule = schedule
        planReminder()
    }

    /** Plans the reminder again, for example once exact timing has been allowed. */
    fun refreshReminder() = planReminder()

    private fun planReminder() {
        val words = ReminderWords(leftToday = prefs.wordsLeftOn(localEpochDay()), perDay = prefs.learnWordsPerDay)
        reminders.schedule(prefs.activeReminder, prefs.appLanguage, words)
    }

    // endregion

    // region Lessons

    fun completeLesson(lessonId: String) {
        completedLessonIds = completedLessonIds + lessonId
        prefs.completedLessonIds = completedLessonIds
    }

    private fun loadLessons() {
        val language = sourceLanguage
        lessonsJob?.cancel()
        lessons = LessonsState.Loading
        lessonsJob = viewModelScope.launch {
            lessons = try {
                LessonsState.Ready(withContext(Dispatchers.IO) { LessonsRepository.load(language) })
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                Log.e(TAG, "Could not load the lessons for ${language.code}", error)
                LessonsState.Failed
            }
        }
    }

    // endregion

    // region Navigation

    fun open(screen: Screen) {
        if (backStack.last() != screen) backStack.add(screen)
    }

    /** Leaves the current screen and returns it, or returns null when already on the main screen. */
    fun back(): Screen? {
        if (backStack.size <= 1) return null
        val left = backStack.removeAt(backStack.lastIndex)
        if (left == Screen.LearnSession) learning.endSession()
        return left
    }

    // endregion

    private companion object {
        const val TAG = "AppViewModel"
        const val SAVE_DELAY_MILLIS = 400L
    }
}
