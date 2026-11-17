package dev.nefrin.wordsmap.learn

import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import kotlin.random.Random

/**
 * One sitting with the cards. Each round shows the cards still open, one at a time; a card
 * swiped right ("I know it") is done, a card swiped left comes back in the next round, in a
 * new order. The sitting ends once every card has been swiped right.
 *
 * @param cards the cards still open, in the order they are shown
 * @param total how many cards the day has, open or not
 * @param review whether this is one more pass through cards already known, which changes nothing
 */
@Stable
class CardSession(
    cards: List<String>,
    val total: Int,
    val review: Boolean = false,
    private val random: Random = Random.Default,
) {
    /** The cards still to come in this round; the first is on top. */
    var queue: List<String> by mutableStateOf(cards)
        private set

    /** The cards swiped left in this round; the next round shows them again. */
    var again: List<String> by mutableStateOf(emptyList())
        private set

    var round: Int by mutableIntStateOf(1)
        private set

    /** How many cards the current round started with. */
    var roundSize: Int by mutableIntStateOf(cards.size)
        private set

    /** Cards of the day known by now, including those known before this sitting. */
    var known: Int by mutableIntStateOf(total - cards.size)
        private set

    // The answers of this round, newest last, so they can be taken back.
    private var answers: List<Answer> by mutableStateOf(emptyList())

    val current: String? get() = queue.firstOrNull()

    val canUndo: Boolean get() = answers.isNotEmpty()

    /** The round is over and some cards were not known: [nextRound] shows them again. */
    val roundDone: Boolean get() = queue.isEmpty() && again.isNotEmpty()

    /** Every card has been swiped right. */
    val finished: Boolean get() = queue.isEmpty() && again.isEmpty()

    /** Answers the card on top; returns it, or null when there is none. */
    fun answer(knew: Boolean): String? {
        val card = queue.firstOrNull() ?: return null
        queue = queue.drop(1)
        if (knew) known++ else again = again + card
        answers = answers + Answer(card, knew)
        return card
    }

    /** Whether the answer [undo] would take back was "I know it"; null when there is none. */
    fun lastAnswerKnew(): Boolean? = answers.lastOrNull()?.knew

    /** Takes the last answer of this round back and puts its card on top again. */
    fun undo(): Answer? {
        val last = answers.lastOrNull() ?: return null
        answers = answers.dropLast(1)
        if (last.knew) known-- else again = again.dropLast(1)
        queue = listOf(last.card) + queue
        return last
    }

    /** Starts the next round with the cards that were not known, in a new order. */
    fun nextRound() {
        if (!roundDone) return
        queue = again.shuffled(random)
        roundSize = queue.size
        again = emptyList()
        answers = emptyList()
        round++
    }

    class Answer(val card: String, val knew: Boolean)
}
