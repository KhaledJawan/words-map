package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Test

class WordSearchTest {
    private fun word(
        id: String,
        german: String,
        english: String,
        farsi: String = "",
        plural: String? = null,
        tenses: List<VerbTense> = emptyList(),
    ) = Word(
        id = id,
        level = "A1.1",
        categories = emptyList(),
        texts = buildMap {
            put("de", german)
            put("en", english)
            if (farsi.isNotEmpty()) put("fa", farsi)
        },
        examples = emptyMap(),
        article = null,
        plural = plural,
        tenses = tenses,
    )

    private val vocabulary = Vocabulary(
        levels = listOf("A1.1"),
        byLevel = mapOf(
            "A1.1" to listOf(
                word("hausaufgabe", "Hausaufgabe", "homework"),
                word("haus", "Haus", "house", farsi = "خانه", plural = "Häuser"),
                word("kommen", "kommen (aus)", "to come from", tenses = listOf(VerbTense("Präteritum", listOf("ich" to "kam")))),
                word("muede", "müde", "tired / exhausted"),
                word("tisch", "Tisch", "table"),
            ),
        ),
    )
    private val search = WordSearch(vocabulary, GermanWordIndex(vocabulary))

    private fun found(query: String) = search.find(query).map { it.id }

    @Test
    fun `an exact match comes before words that only start with the query`() {
        assertEquals(listOf("haus", "hausaufgabe"), found("haus"))
    }

    @Test
    fun `words are found by their translation in any language`() {
        assertEquals(listOf("haus"), found("House"))
        assertEquals(listOf("haus"), found("خانه"))
        assertEquals(listOf("muede"), found("exhausted"))
    }

    @Test
    fun `other German forms, umlauts and articles are understood`() {
        assertEquals(listOf("kommen"), found("kam"))
        assertEquals(listOf("haus"), found("Häuser"))
        assertEquals(listOf("muede"), found("mude"))
        assertEquals(listOf("tisch"), found("der Tisch"))
        assertEquals(listOf("kommen"), found("kommen"))
    }

    @Test
    fun `short queries only match the start of words, and blank ones nothing`() {
        assertEquals(listOf("tisch"), found("ta"))
        assertEquals(emptyList<String>(), found("  "))
        assertEquals(listOf("hausaufgabe"), found("aufgabe"))
    }
}
