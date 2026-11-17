package dev.nefrin.wordsmap.data

/**
 * Finds vocabulary words by their text in any language, best matches first. German words
 * are also found in their other forms: "kam" finds "kommen", "Häuser" finds "Haus".
 */
class WordSearch(vocabulary: Vocabulary, private val germanIndex: GermanWordIndex) {

    // Every text of every word, ready to compare with a query: "kommen (aus)" is kept as
    // "kommen (aus)" and as its meanings "kommen"; "tired / exhausted" as "tired" and "exhausted".
    private val entries: List<Entry> = vocabulary.all.map { word ->
        val texts = (word.allTexts + listOfNotNull(word.plural)).map(::normalizeForSearch).filter { it.isNotEmpty() }
        val german = listOfNotNull(word.textIn(AppLanguage.DE), word.plural).map(::normalizeForSearch).filter { it.isNotEmpty() }
        Entry(word, texts, texts.flatMap(::meaningsOf).toSet(), german)
    }

    /** The words matching [query], at most [limit] of them; empty for a blank query. */
    fun find(query: String, limit: Int = 300): List<Word> {
        val key = normalizeForSearch(query).replace(leadingArticle, "")
        if (key.isEmpty()) return emptyList()
        val ranked = entries.mapNotNull { entry -> rank(entry, key)?.let { it to entry.word } }
            .sortedBy { it.first }
            .map { it.second }
        return (listOfNotNull(otherForm(query)) + ranked).distinctBy { it.id }.take(limit)
    }

    /**
     * 0 for an exact meaning, 1 when a word of a text starts with [key], 2 when [key] is
     * inside the German word, as "aufgabe" is in "Hausaufgabe". Translations are not searched
     * inside words, or "haus" would find "exhausted".
     */
    private fun rank(entry: Entry, key: String): Int? = when {
        key in entry.meanings -> 0
        entry.texts.any { text -> text.startsWith(key) || text.contains(" $key") } -> 1
        // One or two letters are found at the start of words only, or almost everything would match.
        key.length > 2 && entry.german.any { key in it } -> 2
        else -> null
    }

    /** The German word whose other form the whole query is: "kam" → "kommen". */
    private fun otherForm(query: String): Word? {
        val tokens = tokenize(query)
        if (tokens.isEmpty()) return null
        val match = germanIndex.findAll(tokens).singleOrNull() ?: return null
        return match.word.takeIf { match.firstToken == 0 && match.lastToken == tokens.lastIndex }
    }

    private class Entry(val word: Word, val texts: List<String>, val meanings: Set<String>, val german: List<String>)

    private companion object {
        val leadingArticle = Regex("^(der|die|das)\\s+")
        val notes = Regex("\\s*\\([^)]*\\)")

        fun meaningsOf(text: String): List<String> =
            (text.split('/', ',', ';') + text.replace(notes, "")).map { it.replace(notes, "").trim() }.filter { it.isNotEmpty() } + text
    }
}
