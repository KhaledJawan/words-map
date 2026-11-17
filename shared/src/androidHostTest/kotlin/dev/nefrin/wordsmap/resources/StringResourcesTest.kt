package dev.nefrin.wordsmap.resources

import dev.nefrin.wordsmap.data.AppLanguage
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class StringResourcesTest {

    @Test
    fun `a text is shown in the language asked for`() {
        assertEquals("Home", Strings.tab_home.resolve(AppLanguage.EN))
        assertEquals("خانه", Strings.tab_home.resolve(AppLanguage.FA))
    }

    @Test
    fun `a language without translations falls back to English`() {
        assertEquals(Strings.tab_home.resolve(AppLanguage.EN), Strings.tab_home.resolve(AppLanguage.TR))
    }

    @Test
    fun `xml entities are decoded`() {
        assertEquals("Notifications & Reminders", Strings.settings_notifications_title.resolve(AppLanguage.EN))
    }

    @Test
    fun `placeholders are filled by position`() {
        assertEquals("3 of 8 correct", formatText("%1\$s of %2\$s correct", arrayOf(3, 8)))
        assertEquals("8 before 3", formatText("%2\$s before %1\$s", arrayOf(3, 8)))
        assertEquals("a b, 100%", formatText("%s %s, 100%%", arrayOf("a", "b")))
    }

    @Test
    fun `a missing argument leaves its placeholder`() {
        assertEquals("%2\$s of 3", formatText("%2\$s of %1\$s", arrayOf(3)))
    }

    @Test
    fun `the content index lists folders and files`() {
        val grammar = AppAssets.list("gramatik")
        assertTrue(grammar.containsAll(listOf("a1", "a2", "b1", "_example", "README.md")))
        assertTrue("a1_1.json" in AppAssets.list("words"))
        assertTrue(AppAssets.list("gramatik/a1").any { it.startsWith("01-") && it.endsWith(".json") })
        assertEquals(emptyList<String>(), AppAssets.list("no-such-folder"))
    }
}
