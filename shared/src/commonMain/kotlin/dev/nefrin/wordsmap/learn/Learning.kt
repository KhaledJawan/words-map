package dev.nefrin.wordsmap.learn

import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.data.DailyWords
import dev.nefrin.wordsmap.data.LearnSource
import dev.nefrin.wordsmap.platform.localEpochDay
import kotlin.random.Random

/**
 * The daily words: which words today brings, how many of them are known, the streak, and the
 * sitting with the cards. Progress is saved after every card, so a sitting left half way
 * goes on where it stopped, and a new day brings new words.
 *
 * @param pool the ids of the words a source stands for, in their order
 * @param exists whether a word is still there; the learner's own words can be deleted
 * @param onProgress called when the reminder may need to change: words were picked or done
 */
@Stable
class Learning(
    private val prefs: AppPreferences,
    private val pool: (LearnSource) -> List<String>,
    private val exists: (String) -> Boolean,
    private val onProgress: () -> Unit,
    private val random: Random = Random.Default,
    private val clock: () -> Long = ::localEpochDay,
) {
    var source: LearnSource by mutableStateOf(prefs.learnSource)
        private set
    var wordsPerDay: Int by mutableIntStateOf(prefs.learnWordsPerDay)
        private set

    /** The words of [day], in the order they were picked. */
    var todayIds: List<String> by mutableStateOf(emptyList())
        private set
    var knownToday: Set<String> by mutableStateOf(emptySet())
        private set
    var learnedIds: Set<String> by mutableStateOf(prefs.learnedWordIds)
        private set
    var doneDays: Set<Long> by mutableStateOf(prefs.learnDoneDays)
        private set

    /** The day the words are for, as a local epoch day. */
    var day: Long by mutableLongStateOf(clock())
        private set

    /** The sitting on screen, or null while none is. */
    var session: CardSession? by mutableStateOf(null)
        private set

    // Own words or bookmarks changed during the sitting; see wordsChanged.
    private var changedDuringSession = false

    // Words this app run marked learned, so an undo can take that back too.
    private val newlyLearned = mutableSetOf<String>()

    /** Whether all of today's words were known at some point today. */
    val doneToday: Boolean get() = day in doneDays

    val streak: Int get() = DailyWords.streak(doneDays, day)

    val knownCount: Int get() = todayIds.count { it in knownToday }

    /**
     * The words of the chosen source, and how many of them are learned: known on a card at
     * least once. Reads the pool, so the screen keeps it in a derived state.
     */
    val sourceProgress: SourceProgress
        get() {
            val ids = pool(source).toSet()
            return SourceProgress(learned = ids.count { it in learnedIds }, total = ids.size)
        }

    val leftCount: Int get() = todayIds.size - knownCount

    /** Brings the words up to date: today's words after midnight, new ones the source gained. */
    fun refresh() {
        day = clock()
        val saved = prefs.learnTodayIds.filter(exists)
        if (prefs.learnDay == day && saved.isNotEmpty()) {
            todayIds = saved
            knownToday = prefs.learnKnownToday.filterTo(mutableSetOf()) { it in saved }
            topUp()
        } else {
            pickToday()
        }
        markDoneIfKnown()
    }

    fun changeSource(newSource: LearnSource) {
        if (newSource == source) return
        source = newSource
        prefs.learnSource = newSource
        session = null
        day = clock()
        pickToday()
        markDoneIfKnown()
    }

    /** Sets the words of a day. Today keeps the words already known and gains or loses open ones. */
    fun changeWordsPerDay(count: Int) {
        if (count == wordsPerDay) return
        wordsPerDay = count
        prefs.learnWordsPerDay = count
        session = null
        val known = todayIds.filter { it in knownToday }
        val open = todayIds.filter { it !in knownToday }
        todayIds = (known + open).take(maxOf(count, known.size))
        save()
        topUp()
        markDoneIfKnown()
        onProgress()
    }

    /**
     * The own words or bookmarks changed: drops deleted words and takes in new ones. During a
     * sitting, as when a card is bookmarked, this waits until it ends, so the cards on screen
     * stay today's words.
     */
    fun wordsChanged() {
        if (session != null) {
            changedDuringSession = true
            return
        }
        val kept = todayIds.filter(exists)
        if (kept.size != todayIds.size) {
            todayIds = kept
            knownToday = knownToday.filterTo(mutableSetOf()) { it in kept }
            save()
        }
        topUp()
        markDoneIfKnown()
    }

    /** Opens a sitting with today's open words. */
    fun start() {
        if (clock() != day) refresh()
        val open = todayIds.filter { it !in knownToday }
        session = CardSession(open.shuffled(random), total = todayIds.size, random = random)
    }

    /** Goes through all of today's words once more; nothing it shows changes the progress. */
    fun startReview() {
        session = CardSession(todayIds.shuffled(random), total = todayIds.size, review = true, random = random)
    }

    /** Picks new words for today, after today's are done, and starts on them. */
    fun learnMore() {
        pickToday(exclude = todayIds.toSet())
        start()
    }

    fun answer(knew: Boolean) {
        val sitting = session ?: return
        val card = sitting.answer(knew) ?: return
        if (sitting.review || !knew) return
        knownToday = knownToday + card
        prefs.learnKnownToday = knownToday
        if (card !in learnedIds) {
            learnedIds = learnedIds + card
            newlyLearned += card
            prefs.learnedWordIds = learnedIds
        }
        markDoneIfKnown()
    }

    fun undo() {
        val sitting = session ?: return
        val answer = sitting.undo() ?: return
        if (sitting.review || !answer.knew) return
        knownToday = knownToday - answer.card
        prefs.learnKnownToday = knownToday
        if (newlyLearned.remove(answer.card)) {
            learnedIds = learnedIds - answer.card
            prefs.learnedWordIds = learnedIds
        }
    }

    fun nextRound() {
        session?.nextRound()
    }

    /** Leaves the sitting; the words still open stay for later today. */
    fun endSession() {
        if (session == null) return
        session = null
        if (changedDuringSession) {
            changedDuringSession = false
            wordsChanged()
        }
        onProgress()
    }

    private fun pickToday(exclude: Set<String> = emptySet()) {
        todayIds = DailyWords.pick(
            pool = pool(source).filter { it !in exclude },
            learned = learnedIds,
            count = wordsPerDay,
            atRandom = source.drawsAtRandom,
            random = random,
        )
        knownToday = emptySet()
        save()
        onProgress()
    }

    // A small source, such as the learner's own words, can gain words during the day.
    private fun topUp() {
        val missing = wordsPerDay - todayIds.size
        if (missing <= 0) return
        val taken = todayIds.toSet()
        val more = DailyWords.pick(pool(source).filter { it !in taken }, learnedIds, missing, source.drawsAtRandom, random)
        if (more.isEmpty()) return
        todayIds = todayIds + more
        save()
    }

    private fun markDoneIfKnown() {
        if (doneToday || todayIds.isEmpty() || todayIds.any { it !in knownToday }) return
        doneDays = doneDays.filterTo(mutableSetOf()) { it > day - DailyWords.KEPT_DAYS } + day
        prefs.learnDoneDays = doneDays
        onProgress()
    }

    private fun save() {
        prefs.learnDay = day
        prefs.learnTodayIds = todayIds
        prefs.learnKnownToday = knownToday
    }
}

/** Of the [total] words of a source, [learned] are learned. */
data class SourceProgress(val learned: Int, val total: Int) {
    val left: Int get() = total - learned
}
