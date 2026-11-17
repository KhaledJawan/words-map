package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Test

class WordLookupTest {
    private fun word(
        id: String,
        german: String,
        english: String = "",
        plural: String? = null,
        tenses: List<VerbTense> = emptyList(),
    ) = Word(
        id = id,
        level = "A1.1",
        categories = emptyList(),
        texts = buildMap {
            put("de", german)
            if (english.isNotEmpty()) put("en", english)
        },
        examples = emptyMap(),
        article = null,
        plural = plural,
        tenses = tenses,
    )

    private val kommen = listOf(
        VerbTense("Präsens", listOf("ich" to "komme", "er/sie/es" to "kommt", "wir" to "kommen")),
        VerbTense("Präteritum", listOf("ich" to "kam", "wir" to "kamen")),
        VerbTense("Perfekt", listOf("ich" to "bin gekommen", "wir" to "sind gekommen")),
    )

    private val index = GermanWordIndex(
        Vocabulary(
            levels = listOf("A1.1"),
            byLevel = mapOf(
                "A1.1" to listOf(
                    word("uhr", "Uhr", "clock"),
                    word("rund", "rund um die Uhr", "around the clock"),
                    word("chef", "der/die Vorgesetzte", "supervisor"),
                    word("medien", "Medien (Pl.)", "media"),
                    word("bewerben", "sich bewerben", "to apply"),
                    word("frau", "Frau", "woman", plural = "Frauen"),
                    word("wohnen", "wohnen", "to live"),
                    word("freund", "Freund", "friend"),
                    word("gefallen", "jmdm. einen Gefallen tun", "to do someone a favour"),
                    word("haus", "Haus", "die"),
                    word("kommen", "kommen (aus)", "to come from", tenses = kommen),
                    word("anfangen", "anfangen", "to begin", tenses = listOf(
                        VerbTense("Präsens", listOf("ich" to "fange an")),
                        VerbTense("Perfekt", listOf("ich" to "habe angefangen")),
                    )),
                ),
            ),
        ),
    )

    /** The word id of every match in [text], with the words it covers. */
    private fun found(text: String): List<Pair<String, String>> {
        val tokens = tokenize(text)
        return index.findAll(tokens).map { match ->
            match.word.id to (match.firstToken..match.lastToken).joinToString(" ") { tokens[it].text }
        }
    }

    @Test
    fun `words are split off punctuation and keep their place`() {
        val tokens = tokenize("„Hallo“, sagt Omid. Geht's per E-Mail?")
        assertEquals(listOf("Hallo", "sagt", "Omid", "Geht's", "per", "E-Mail"), tokens.map { it.text })
        assertEquals(TextToken("Hallo", 1, 6), tokens.first())
    }

    @Test
    fun `a phrase wins over the single words in it`() {
        assertEquals(listOf("rund" to "rund um die Uhr"), found("Wir arbeiten rund um die Uhr."))
        assertEquals(listOf("uhr" to "Uhr"), found("Die Uhr ist neu."))
    }

    @Test
    fun `notes, slashes, articles and sich are not needed in the text`() {
        assertEquals(listOf("chef" to "Vorgesetzte"), found("Meine Vorgesetzte ist nett."))
        assertEquals(listOf("medien" to "Medien"), found("Die Medien berichten."))
        assertEquals(listOf("bewerben" to "bewerben"), found("Ich will mich bewerben."))
    }

    @Test
    fun `plurals and simple forms lead to the dictionary word`() {
        assertEquals(listOf("frau" to "Frauen"), found("Zwei Frauen."))
        assertEquals(listOf("wohnen" to "wohnt"), found("Er wohnt hier."))
        assertEquals(listOf("freund" to "Freunde"), found("Viele Freunde."))
    }

    @Test
    fun `only the German side of the vocabulary is searched`() {
        // "die" is the English text of the Haus entry, not a German word of the vocabulary.
        assertEquals(emptyList<Pair<String, String>>(), found("die clock house"))
    }

    @Test
    fun `words that are not in the vocabulary are left out`() {
        assertEquals(emptyList<Pair<String, String>>(), found("Omid lebt in Afghanistan."))
    }

    @Test
    fun `conjugated verb forms lead to the verb`() {
        assertEquals(listOf("kommen" to "kam"), found("Er kam gestern."))
        assertEquals(listOf("kommen" to "kamen"), found("Sie kamen spät."))
        // A whole Perfekt form is one match, and the participle is found on its own too.
        assertEquals(listOf("kommen" to "sind gekommen"), found("Wir sind gekommen."))
        assertEquals(listOf("kommen" to "gekommen"), found("Er ist gestern gekommen."))
        assertEquals(listOf("anfangen" to "fange an"), found("Ich fange an."))
        assertEquals(listOf("anfangen" to "angefangen"), found("Hast du schon angefangen?"))
    }

    @Test
    fun `dictionary forms of an inflected word`() {
        assert("wohnen" in dictionaryForms("wohnt"))
        assert("arbeiten" in dictionaryForms("gearbeitet"))
        assert("klein" in dictionaryForms("kleinen"))
        assertEquals(emptyList<String>(), dictionaryForms("wie"))
    }
}
