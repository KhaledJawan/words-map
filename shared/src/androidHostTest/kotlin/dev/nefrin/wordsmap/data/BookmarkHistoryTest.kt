package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Test

class BookmarkHistoryTest {
    @Test
    fun `the history starts as the bookmarks of earlier versions`() {
        val prefs = AppPreferences(MapStore())
        prefs.bookmarkedWordIds = setOf("wA1-1-0002", "wA1-1-0001")
        assertEquals(listOf("wA1-1-0001", "wA1-1-0002"), prefs.bookmarkHistory)
    }

    @Test
    fun `the history keeps its order, including words no longer bookmarked`() {
        val prefs = AppPreferences(MapStore())
        prefs.bookmarkedWordIds = setOf("wB1-1-0010")
        prefs.bookmarkHistory = listOf("wB1-1-0010", "wA2-1-0003", "wA1-1-0001")
        assertEquals(listOf("wB1-1-0010", "wA2-1-0003", "wA1-1-0001"), prefs.bookmarkHistory)
        prefs.bookmarkHistory = emptyList()
        assertEquals(emptyList<String>(), prefs.bookmarkHistory)
    }

    private class MapStore : KeyValueStore {
        private val values = mutableMapOf<String, Any>()
        override fun getString(key: String) = values[key] as String?
        override fun putString(key: String, value: String?) {
            if (value == null) values.remove(key) else values[key] = value
        }
        override fun getBoolean(key: String, default: Boolean) = values[key] as Boolean? ?: default
        override fun putBoolean(key: String, value: Boolean) { values[key] = value }
        @Suppress("UNCHECKED_CAST")
        override fun getStringSet(key: String) = values[key] as Set<String>?
        override fun putStringSet(key: String, value: Set<String>) { values[key] = value }
    }
}
