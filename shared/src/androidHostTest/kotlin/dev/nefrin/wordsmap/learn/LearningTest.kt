package dev.nefrin.wordsmap.learn

import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.data.DailyWords
import dev.nefrin.wordsmap.data.KeyValueStore
import dev.nefrin.wordsmap.data.LearnSource
import dev.nefrin.wordsmap.data.WordGroup
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.random.Random

class DailyWordsTest {
    private val pool = (1..10).map { "w$it" }

    @Test
    fun `words not learned come first, in the order of the pool`() {
        val picked = DailyWords.pick(pool, learned = setOf("w1", "w3"), count = 3, atRandom = false, random = Random(1))
        assertEquals(listOf("w2", "w4", "w5"), picked)
    }

    @Test
    fun `at random the words are still all new`() {
        val picked = DailyWords.pick(pool, learned = setOf("w1", "w2"), count = 5, atRandom = true, random = Random(7))
        assertEquals(5, picked.size)
        assertTrue(picked.none { it == "w1" || it == "w2" })
        assertEquals(picked.size, picked.toSet().size)
    }

    @Test
    fun `once the new words run out, learned ones come back for review`() {
        val learned = pool.toSet() - "w9"
        val picked = DailyWords.pick(pool, learned, count = 4, atRandom = false, random = Random(3))
        assertEquals("w9", picked.first())
        assertEquals(4, picked.toSet().size)
    }

    @Test
    fun `a small pool gives what it has`() {
        assertEquals(listOf("a", "b"), DailyWords.pick(listOf("a", "b", "a"), emptySet(), count = 10, atRandom = false, random = Random(0)))
        assertEquals(emptyList<String>(), DailyWords.pick(emptyList(), emptySet(), count = 10, atRandom = true, random = Random(0)))
    }

    @Test
    fun `the streak counts days in a row and waits for today`() {
        assertEquals(3, DailyWords.streak(setOf(10L, 9L, 8L, 6L), today = 10))
        // Today not done yet: yesterday's streak still stands.
        assertEquals(3, DailyWords.streak(setOf(9L, 8L, 7L), today = 10))
        // A day missed breaks it.
        assertEquals(0, DailyWords.streak(setOf(8L, 7L), today = 10))
        assertEquals(0, DailyWords.streak(emptySet(), today = 10))
    }

    @Test
    fun `sources are saved and read back`() {
        val sources = listOf(
            LearnSource.Random, LearnSource.Bookmarks, LearnSource.Level("A1.2"), LearnSource.Category("food_drink"),
            LearnSource.Group(WordGroup.VERBS), LearnSource.Mine(null), LearnSource.Mine("list-abc"),
        )
        for (source in sources) assertEquals(source, LearnSource.fromKey(source.key))
        assertNull(LearnSource.fromKey("level:"))
        assertNull(LearnSource.fromKey("something"))
    }
}

class CardSessionTest {
    @Test
    fun `cards not known come again until every card is known`() {
        val session = CardSession(listOf("a", "b", "c"), total = 3, random = Random(1))
        session.answer(knew = true)
        session.answer(knew = false)
        session.answer(knew = false)
        assertTrue(session.roundDone)
        assertEquals(1, session.known)
        assertEquals(setOf("b", "c"), session.again.toSet())

        session.nextRound()
        assertEquals(2, session.round)
        assertEquals(2, session.roundSize)
        assertEquals(setOf("b", "c"), session.queue.toSet())
        session.answer(knew = true)
        session.answer(knew = true)
        assertTrue(session.finished)
        assertFalse(session.roundDone)
        assertEquals(3, session.known)
    }

    @Test
    fun `undo puts the last card back on top`() {
        val session = CardSession(listOf("a", "b"), total = 2)
        session.answer(knew = false)
        session.answer(knew = true)
        assertEquals(true, session.lastAnswerKnew())

        val undone = session.undo()
        assertEquals("b", undone?.card)
        assertEquals(listOf("b"), session.queue)
        assertEquals(0, session.known)

        session.undo()
        assertEquals(listOf("a", "b"), session.queue)
        assertTrue(session.again.isEmpty())
        assertFalse(session.canUndo)
        assertNull(session.undo())
    }

    @Test
    fun `cards known before the sitting count as known`() {
        val session = CardSession(listOf("c"), total = 3)
        assertEquals(2, session.known)
    }
}

class LearningTest {
    private val pool = (1..30).map { "w$it" }
    private var today = 100L
    private var progressCalls = 0

    private fun learning(prefs: AppPreferences, words: List<String> = pool) = Learning(
        prefs = prefs,
        pool = { words },
        exists = { true },
        onProgress = { progressCalls++ },
        random = Random(5),
        clock = { today },
    )

    private fun prefs(source: LearnSource = LearnSource.Level("A1.1"), perDay: Int = 5) = AppPreferences(MapStore()).apply {
        learnSource = source
        learnWordsPerDay = perDay
    }

    @Test
    fun `a day picks its words once and keeps them`() {
        val prefs = prefs()
        val first = learning(prefs).apply { refresh() }
        assertEquals(listOf("w1", "w2", "w3", "w4", "w5"), first.todayIds)

        // Opened again the same day, as after a restart: the same words.
        val again = learning(prefs).apply { refresh() }
        assertEquals(first.todayIds, again.todayIds)
    }

    @Test
    fun `knowing every word finishes the day and the next day brings new words`() {
        val prefs = prefs()
        val learning = learning(prefs).apply { refresh() }
        learning.start()
        repeat(4) { learning.answer(knew = true) }
        learning.answer(knew = false)
        assertFalse(learning.doneToday)
        assertEquals(1, prefs.wordsLeftOn(today))

        learning.nextRound()
        learning.answer(knew = true)
        assertTrue(learning.doneToday)
        assertEquals(1, learning.streak)
        assertEquals(0, prefs.wordsLeftOn(today))
        assertEquals(5, learning.learnedIds.size)

        today++
        learning.refresh()
        assertEquals(listOf("w6", "w7", "w8", "w9", "w10"), learning.todayIds)
        assertFalse(learning.doneToday)
        assertEquals(1, learning.streak)
        assertEquals(5, prefs.wordsLeftOn(today))
    }

    @Test
    fun `a sitting left half way goes on with the open words`() {
        val prefs = prefs()
        learning(prefs).apply {
            refresh()
            start()
            answer(knew = true)
            answer(knew = true)
            endSession()
        }
        val later = learning(prefs).apply { refresh() }
        assertEquals(2, later.knownCount)
        later.start()
        assertEquals(3, later.session?.queue?.size)
        assertEquals(2, later.session?.known)
    }

    @Test
    fun `undo takes back a word learned by mistake`() {
        val prefs = prefs()
        val learning = learning(prefs).apply { refresh() }
        learning.start()
        learning.answer(knew = true)
        assertEquals(1, prefs.learnedWordIds.size)
        learning.undo()
        assertEquals(0, prefs.learnedWordIds.size)
        assertEquals(0, learning.knownCount)
    }

    @Test
    fun `changing the daily count keeps the known words`() {
        val prefs = prefs()
        val learning = learning(prefs).apply { refresh() }
        learning.start()
        repeat(3) { learning.answer(knew = true) }

        learning.changeWordsPerDay(10)
        assertEquals(10, learning.todayIds.size)
        assertEquals(3, learning.knownCount)

        // Fewer words than already known: today is done.
        learning.changeWordsPerDay(2)
        assertEquals(3, learning.todayIds.size)
        assertTrue(learning.doneToday)
    }

    @Test
    fun `a small source takes in words added during the day`() {
        val prefs = prefs(source = LearnSource.Mine(null), perDay = 5)
        val words = mutableListOf("mine-1", "mine-2")
        val learning = Learning(prefs, pool = { words.toList() }, exists = { it in words }, onProgress = {}, random = Random(1), clock = { today })
        learning.refresh()
        assertEquals(listOf("mine-1", "mine-2"), learning.todayIds)

        words += "mine-3"
        learning.wordsChanged()
        assertEquals(listOf("mine-1", "mine-2", "mine-3"), learning.todayIds)

        words.remove("mine-1")
        learning.wordsChanged()
        assertEquals(listOf("mine-2", "mine-3"), learning.todayIds)
    }

    @Test
    fun `a word bookmarked during a sitting joins once the sitting ends`() {
        val prefs = prefs(source = LearnSource.Bookmarks, perDay = 5)
        val bookmarks = mutableListOf("w1", "w2")
        val learning = Learning(prefs, pool = { bookmarks.toList() }, exists = { true }, onProgress = {}, random = Random(1), clock = { today })
        learning.refresh()
        learning.start()

        // Bookmarked from its card: the cards on screen stay as they are.
        bookmarks += "w3"
        learning.wordsChanged()
        assertEquals(setOf("w1", "w2"), learning.todayIds.toSet())
        assertEquals(2, learning.session?.queue?.size)

        learning.endSession()
        assertEquals(setOf("w1", "w2", "w3"), learning.todayIds.toSet())
    }

    @Test
    fun `the chapter counts its learned words and the ones to go`() {
        val prefs = prefs()
        val learning = learning(prefs).apply { refresh() }
        assertEquals(SourceProgress(learned = 0, total = 30), learning.sourceProgress)

        learning.start()
        repeat(3) { learning.answer(knew = true) }
        learning.answer(knew = false)
        assertEquals(SourceProgress(learned = 3, total = 30), learning.sourceProgress)
        assertEquals(27, learning.sourceProgress.left)

        // Words learned in another chapter don't count here.
        val other = learning(prefs, words = listOf("w1", "x1", "x2")).apply { refresh() }
        assertEquals(SourceProgress(learned = 1, total = 3), other.sourceProgress)
    }

    @Test
    fun `a review changes nothing`() {
        val prefs = prefs()
        val learning = learning(prefs).apply { refresh() }
        learning.startReview()
        repeat(5) { learning.answer(knew = true) }
        assertTrue(learning.session?.finished == true)
        assertEquals(0, learning.knownCount)
        assertFalse(learning.doneToday)
    }

    @Test
    fun `more words after the day is done keep it done`() {
        val prefs = prefs()
        val learning = learning(prefs).apply { refresh() }
        learning.start()
        repeat(5) { learning.answer(knew = true) }
        learning.learnMore()
        assertEquals(listOf("w6", "w7", "w8", "w9", "w10"), learning.todayIds)
        assertTrue(learning.doneToday)
        assertEquals(0, prefs.wordsLeftOn(today))
    }
}

internal class MapStore : KeyValueStore {
    private val values = mutableMapOf<String, Any>()
    override fun getString(key: String) = values[key] as String?
    override fun putString(key: String, value: String?) {
        if (value == null) values.remove(key) else values[key] = value
    }
    override fun getBoolean(key: String, default: Boolean) = values[key] as Boolean? ?: default
    override fun putBoolean(key: String, value: Boolean) {
        values[key] = value
    }
    @Suppress("UNCHECKED_CAST")
    override fun getStringSet(key: String) = values[key] as Set<String>?
    override fun putStringSet(key: String, value: Set<String>) {
        values[key] = value
    }
}
