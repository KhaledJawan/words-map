package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class JsonTest {

    @Test
    fun `numbers are read from numbers and numeric strings`() {
        val json = parseJsonObject("""{"number": 12, "order": "3", "float": 4.0, "text": "x", "none": null}""")
        assertEquals(12, json.int("number"))
        assertEquals(3, json.int("order"))
        assertEquals(4, json.int("float"))
        assertEquals(7, json.int("text", 7))
        assertEquals(7, json.int("none", 7))
        assertEquals(7, json.int("missing", 7))
    }

    @Test
    fun `strings are forgiving`() {
        val json = parseJsonObject("""{"title": "Hallo", "number": 5, "none": null, "list": ["a", " ", 2, null, {"x": 1}]}""")
        assertEquals("Hallo", json.string("title"))
        assertEquals("5", json.string("number"))
        assertEquals("", json.string("none"))
        assertEquals("", json.string("missing"))
        assertEquals(listOf("a", "2"), json.array("list").strings())
        assertEquals(1, json.array("list").objects().size)
    }

    @Test
    fun `localized text reads objects and bare German strings`() {
        val json = parseJsonObject("""{"title": {" EN ": " Hello ", "fa": "", "de": "Hallo"}, "plain": "Guten Tag", "number": 5}""")
        val title = LocalizedText.from(json["title"])
        assertEquals("Hello", title.textIn(AppLanguage.EN))
        assertEquals("Hallo", title.textIn(AppLanguage.DE))
        assertEquals("", title.textIn(AppLanguage.FA))
        assertEquals("Guten Tag", LocalizedText.from(json["plain"]).textIn(AppLanguage.DE))
        assertTrue(LocalizedText.from(json["number"]).isEmpty)
        assertTrue(LocalizedText.from(null).isEmpty)
    }

    @Test
    fun `suffixed keys keep the file's order`() {
        val json = parseJsonObject("""{"title_fa": "سلام", "title_en": "Hi", "other": "x"}""")
        val title = LocalizedText.fromSuffixedKeys(json, "title")
        assertEquals(listOf("سلام", "Hi"), title.all.toList())
    }
}
