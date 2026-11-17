package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Test

class GrammarSearchTest {
    private fun lesson(
        id: String,
        vararg titles: Pair<String, String>,
        description: Map<String, String> = emptyMap(),
        keywords: List<String> = emptyList(),
    ) = GrammarLesson(
        id = id,
        chapterId = id.substringBefore('/'),
        cover = null,
        title = LocalizedText(mapOf(*titles)),
        description = LocalizedText(description),
        fullDescription = LocalizedText.Empty,
        examples = emptyList(),
        questions = emptyList(),
        searchNames = (titles.map { it.second } + keywords).joinToString("\n") { normalizeForSearch(it) },
    )

    private val grammar: Grammar = Library(
        listOf(
            LibraryChapter(
                "a1",
                listOf(
                    lesson(
                        "a1/adverbien", "de" to "Adverbien", "en" to "Adverbs", "fa" to "قیدها",
                        description = mapOf("de" to "Wann etwas passiert.", "en" to "When something happens."),
                    ),
                ),
            ),
            LibraryChapter(
                "a2",
                listOf(lesson("a2/praepositionen", "de" to "Präpositionen", "fa" to "حرف‌های اضافه", keywords = listOf("Straße"))),
            ),
            LibraryChapter("b2", listOf(lesson("b2/passiv", "de" to "Passiv", "en" to "The passive voice"))),
            LibraryChapter("c1", emptyList()),
        ),
    )

    private fun found(query: String, language: AppLanguage = AppLanguage.EN, chapterId: String? = null) =
        grammar.search(query, language, chapterId).map { it.id }

    @Test
    fun `finds a lesson by its title in any language, ignoring case`() {
        assertEquals(listOf("a1/adverbien"), found("adverb"))
        assertEquals(listOf("a1/adverbien"), found("ADVERBIEN"))
        assertEquals(listOf("a1/adverbien"), found("قید"))
    }

    @Test
    fun `umlauts and sharp s can be typed plainly`() {
        assertEquals(listOf("a2/praepositionen"), found("praposition"))
        assertEquals(listOf("a2/praepositionen"), found("Präposition"))
        assertEquals(listOf("a2/praepositionen"), found("strasse"))
    }

    @Test
    fun `Farsi matches with or without the zero-width joiner and with Arabic letter forms`() {
        assertEquals(listOf("a2/praepositionen"), found("حرفهای اضافه"))
        assertEquals(listOf("a2/praepositionen"), found("حرف‌هاي"))
    }

    @Test
    fun `descriptions are searched only in the language on screen`() {
        // "pass" is in the German description of the adverbs lesson ("passiert").
        assertEquals(listOf("b2/passiv"), found("pass", AppLanguage.EN))
        assertEquals(listOf("a1/adverbien", "b2/passiv"), found("pass", AppLanguage.DE))
        assertEquals(listOf("a1/adverbien"), found("happens", AppLanguage.EN))
        assertEquals(emptyList<String>(), found("happens", AppLanguage.DE))
    }

    @Test
    fun `a description missing in the reader's language is searched in its fallback`() {
        assertEquals(listOf("a1/adverbien"), found("happens", AppLanguage.FA))
    }

    @Test
    fun `a search inside a chapter only lists that chapter`() {
        assertEquals(listOf("b2/passiv"), found("pass", AppLanguage.DE, chapterId = "b2"))
        assertEquals(emptyList<String>(), found("adverb", chapterId = "b2"))
    }

    @Test
    fun `a blank query finds nothing`() {
        assertEquals(emptyList<String>(), found("   "))
        assertEquals(emptyList<String>(), found("xyz"))
    }

    @Test
    fun `lessons are looked up by id across chapters`() {
        assertEquals("b2/passiv", grammar.item("b2/passiv")?.id)
        assertEquals(null, grammar.item("b2/missing"))
        assertEquals(3, grammar.itemCount)
    }
}
