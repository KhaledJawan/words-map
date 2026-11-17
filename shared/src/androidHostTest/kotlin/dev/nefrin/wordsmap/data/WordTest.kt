package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Test

class WordTest {
    private fun word(vararg texts: Pair<String, String>) = Word(
        id = "w",
        level = "A1.1",
        categories = emptyList(),
        texts = mapOf(*texts),
        examples = emptyMap(),
        article = null,
        plural = null,
    )

    @Test
    fun `shows the word in the requested language`() {
        val word = word("de" to "Haus", "en" to "house", "fa" to "خانه")
        assertEquals("Haus", word.displayText(AppLanguage.DE))
        assertEquals("خانه", word.translation(AppLanguage.DE, AppLanguage.FA))
    }

    @Test
    fun `falls back to the first language that has the word`() {
        val word = word("en" to "house", "fa" to "خانه")
        assertEquals("house", word.displayText(AppLanguage.DE))
        assertEquals("—", word().displayText(AppLanguage.DE))
    }

    @Test
    fun `does not repeat the word as its own meaning when another language differs`() {
        // French is missing, so both sides would fall back to the German text.
        val word = word("de" to "Haus", "tr" to "ev")
        assertEquals("ev", word.translation(AppLanguage.DE, AppLanguage.FR))
    }

    @Test
    fun `keeps an identical translation when it really is the same word`() {
        val word = word("de" to "Computer", "en" to "Computer", "fa" to "کامپیوتر")
        assertEquals("Computer", word.translation(AppLanguage.DE, AppLanguage.EN))
    }
}
