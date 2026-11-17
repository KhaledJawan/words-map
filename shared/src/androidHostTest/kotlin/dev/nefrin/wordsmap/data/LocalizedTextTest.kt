package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Test

class LocalizedTextTest {
    private val text = LocalizedText(mapOf("de" to "Adverbien", "en" to "Adverbs", "fa" to "قیدها"))

    @Test
    fun `uses the requested language when it exists`() {
        assertEquals("قیدها", text.resolve(AppLanguage.FA))
        assertEquals("Adverbien", text.resolve(AppLanguage.DE))
    }

    @Test
    fun `Pashto falls back to Farsi before English`() {
        assertEquals("قیدها", text.resolve(AppLanguage.PS))
        assertEquals("Adverbs", LocalizedText(mapOf("en" to "Adverbs")).resolve(AppLanguage.PS))
    }

    @Test
    fun `other languages fall back to English`() {
        assertEquals("Adverbs", text.resolve(AppLanguage.TR))
        assertEquals("Adverbs", text.resolve(AppLanguage.FR))
    }

    @Test
    fun `resolve is empty without English, resolveOrAny still finds a text`() {
        val germanOnly = LocalizedText(mapOf("de" to "Adverbien"))
        assertEquals("", germanOnly.resolve(AppLanguage.EN))
        assertEquals("Adverbien", germanOnly.resolveOrAny(AppLanguage.EN))
        assertEquals("", LocalizedText.Empty.resolveOrAny(AppLanguage.EN))
    }
}
