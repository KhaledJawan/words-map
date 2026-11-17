package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Test

class WordGroupsTest {
    private fun word(id: String, level: String, tags: List<String> = emptyList(), conjugated: Boolean = false) = Word(
        id = id,
        level = level,
        categories = tags,
        texts = mapOf("de" to id),
        examples = emptyMap(),
        article = null,
        plural = null,
        tenses = if (conjugated) listOf(VerbTense("Präsens", listOf("ich" to id))) else emptyList(),
    )

    private val vocabulary = Vocabulary(
        levels = listOf("A1.1", "A1.2", "A2.1", "B1.1"),
        byLevel = mapOf(
            "A1.1" to listOf(
                word("kommen", "A1.1", conjugated = true),
                word("Haus", "A1.1", listOf("noun")),
                word("nicht", "A1.1", listOf("a1_core", "negation")),
                word("Bis bald!", "A1.1", listOf("conversation_phrases", "adverb")),
            ),
            "A1.2" to listOf(word("können", "A1.2", listOf("modal_verb")), word("mit", "A1.2", listOf("preposition"))),
            "A2.1" to listOf(word("Tisch", "A2.1", listOf("noun")), word("in bar bezahlen", "A2.1", listOf("preposition"))),
            "B1.1" to listOf(
                word("sich bewerben", "B1.1", listOf("verb", "reflexive_verb"), conjugated = true),
                word("weder … noch", "B1.1", listOf("conjunction")),
                word("unter der Bedingung, dass …", "B1.1", listOf("conjunction")),
                word("hingegen", "B1.1", listOf("adverb")),
            ),
        ),
    )

    @Test
    fun `verbs are the conjugated words and the words tagged as verbs`() {
        assertEquals(listOf("kommen", "können", "sich bewerben"), vocabulary.wordsIn(WordGroup.VERBS).map { it.id })
    }

    @Test
    fun `small words are single adverbs, conjunctions, prepositions and negations, or pairs`() {
        assertEquals(listOf("nicht", "mit", "weder … noch", "hingegen"), vocabulary.wordsIn(WordGroup.SMALL_WORDS).map { it.id })
    }

    @Test
    fun `only levels that have words of a group can be picked, in order`() {
        assertEquals(listOf("A1", "B1"), vocabulary.bandsOf(WordGroup.VERBS))
        assertEquals(listOf("A1", "B1"), vocabulary.bandsOf(WordGroup.SMALL_WORDS))
    }

    @Test
    fun `a group is filtered by level, or all of it is shown`() {
        assertEquals(listOf("kommen", "können"), vocabulary.wordsIn(WordGroup.VERBS, "A1").map { it.id })
        assertEquals(emptyList<String>(), vocabulary.wordsIn(WordGroup.VERBS, "A2").map { it.id })
        assertEquals(3, vocabulary.wordsIn(WordGroup.VERBS, null).size)
        assertEquals(listOf("weder … noch", "hingegen"), vocabulary.wordsIn(WordGroup.SMALL_WORDS, "B1").map { it.id })
        assertEquals("B2", bandOf("B2.2"))
    }
}
