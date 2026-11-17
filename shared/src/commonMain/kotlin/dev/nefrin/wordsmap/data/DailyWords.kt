package dev.nefrin.wordsmap.data

import androidx.compose.runtime.Immutable
import kotlin.random.Random

/** Where the words of the day come from. */
@Immutable
sealed interface LearnSource {
    /** Any word of the app, at every level. */
    data object Random : LearnSource

    /** The words of one chapter, such as "A1.1". */
    data class Level(val level: String) : LearnSource

    /** The words carrying one category tag, such as "food_drink". */
    data class Category(val tag: String) : LearnSource

    /** The verbs or the small words, at every level. */
    data class Group(val group: WordGroup) : LearnSource

    /** The words bookmarked now. */
    data object Bookmarks : LearnSource

    /** The learner's own words: all of them, or those of one of their categories. */
    data class Mine(val listId: String?) : LearnSource

    /** How the source is saved: "random", "level:A1.1", "category:food_drink", "mine:list-…" … */
    val key: String
        get() = when (this) {
            Random -> "random"
            is Level -> "level:$level"
            is Category -> "category:$tag"
            is Group -> "group:${group.key}"
            Bookmarks -> "bookmarks"
            is Mine -> if (listId == null) "mine" else "mine:$listId"
        }

    /**
     * Whether the day's words are drawn at random. A chapter, a category or the learner's own
     * words are worked through in their order instead, the way one reads through them.
     */
    val drawsAtRandom: Boolean get() = this == Random || this == Bookmarks

    companion object {
        val Default: LearnSource = Random

        fun fromKey(key: String?): LearnSource? {
            if (key == null) return null
            val name = key.substringBefore(':')
            val value = key.substringAfter(':', "")
            return when (name) {
                "random" -> Random
                "bookmarks" -> Bookmarks
                "level" -> value.takeIf { it.isNotEmpty() }?.let(::Level)
                "category" -> value.takeIf { it.isNotEmpty() }?.let(::Category)
                "group" -> WordGroup.entries.firstOrNull { it.key == value }?.let(::Group)
                "mine" -> Mine(value.ifEmpty { null })
                else -> null
            }
        }
    }
}

object DailyWords {
    /** The choices for the number of words a day. */
    val countOptions = listOf(5, 10, 15, 20, 30, 50)
    const val DEFAULT_COUNT = 10

    /** How many days of finished daily words are kept for the streak. */
    const val KEPT_DAYS = 400

    /**
     * Picks [count] words of [pool] for a day. Words not learned yet come first: at random
     * when [atRandom], otherwise in the order of the pool. When fewer than [count] are left,
     * learned words come back for review, at random.
     */
    fun pick(pool: List<String>, learned: Set<String>, count: Int, atRandom: Boolean, random: Random): List<String> {
        if (count <= 0) return emptyList()
        val words = pool.distinct()
        val fresh = words.filter { it !in learned }
        val picked = (if (atRandom) fresh.shuffled(random) else fresh).take(count)
        if (picked.size == count) return picked
        return picked + words.filter { it in learned }.shuffled(random).take(count - picked.size)
    }

    /**
     * Days in a row with the daily words done, counted back from [today]. A day not done yet
     * does not break the streak while it lasts: it counts from yesterday then.
     */
    fun streak(doneDays: Set<Long>, today: Long): Int {
        var day = if (today in doneDays) today else today - 1
        var days = 0
        while (day in doneDays) {
            days++
            day--
        }
        return days
    }
}
