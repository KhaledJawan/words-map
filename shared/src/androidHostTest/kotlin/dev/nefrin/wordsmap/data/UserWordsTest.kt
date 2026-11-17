package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class UserWordsTest {
    @Test
    fun `words and categories are saved and read back`() {
        val words = listOf(
            UserWord("mine-1", "Kühlschrank", "fridge", article = "der", plural = "Kühlschränke", example = "Der \"Kühlschrank\" ist leer.", listId = "list-1"),
            UserWord("mine-2", "zwar … aber", "admittedly … but"),
        )
        assertEquals(words, UserWordsJson.decodeWords(UserWordsJson.encodeWords(words)))
        val lists = listOf(UserList("list-1", "Küche"), UserList("list-2", "کار"))
        assertEquals(lists, UserWordsJson.decodeLists(UserWordsJson.encodeLists(lists)))
    }

    @Test
    fun `damaged saved data gives no words instead of an error`() {
        assertEquals(emptyList<UserWord>(), UserWordsJson.decodeWords("not json"))
        assertEquals(emptyList<UserWord>(), UserWordsJson.decodeWords(null))
        // An entry without text is skipped; the others stay.
        assertEquals(1, UserWordsJson.decodeWords("""[{"id":"mine-1"},{"id":"mine-2","text":"Haus","translation":"house"}]""").size)
    }

    @Test
    fun `an article typed in front of the word becomes the article`() {
        val word = UserWord("mine-1", "  die   Brücke ", " bridge ", plural = " ").tidy()
        assertEquals("Brücke", word.text)
        assertEquals("die", word.article)
        assertEquals("bridge", word.translation)
        assertNull(word.plural)
        // A word that only starts like an article stays as it is.
        assertEquals("Derby", UserWord("mine-2", "Derby", "derby").tidy().text)
    }

    @Test
    fun `own words are told apart from the app's words`() {
        assertTrue(isUserWordId(newUserWordId()))
        assertFalse(isUserWordId("wA1-1-0002"))
        assertTrue(newUserWordId() != newUserWordId())
    }

    @Test
    fun `an own word reads as a word of the current pair`() {
        val word = UserWord("mine-1", "Tisch", "میز", article = "der").asWord(AppLanguage.DE, AppLanguage.FA)
        assertEquals("Tisch", word.displayText(AppLanguage.DE))
        assertEquals("میز", word.translation(AppLanguage.DE, AppLanguage.FA))
    }

    @Test
    fun `the search looks in the word and its meaning`() {
        val word = UserWord("mine-1", "Kühlschrank", "fridge")
        assertTrue(word.matches(normalizeForSearch("kühl")))
        assertTrue(word.matches(normalizeForSearch("FRIDGE")))
        assertFalse(word.matches(normalizeForSearch("tisch")))
    }
}
