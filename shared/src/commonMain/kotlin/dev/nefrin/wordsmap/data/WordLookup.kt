package dev.nefrin.wordsmap.data

/** A word of a text and where it stands: characters [start] until, not including, [end]. */
data class TextToken(val text: String, val start: Int, val end: Int)

/** A vocabulary [word] found in a text, covering the tokens [firstToken]..[lastToken]. */
data class WordMatch(val word: Word, val firstToken: Int, val lastToken: Int)

// Letters, with hyphens and apostrophes allowed inside a word ("E-Mail", "geht's").
private val wordPattern = Regex("[\\p{L}\\p{M}]+(?:[-'’][\\p{L}\\p{M}]+)*")

/** The words of [text], without punctuation, in order. */
fun tokenize(text: String): List<TextToken> =
    wordPattern.findAll(text).map { TextToken(it.value, it.range.first, it.range.last + 1) }.toList()

/**
 * Finds vocabulary words in German text. Only the German side of the vocabulary is used,
 * so a German word can never be mistaken for an English or French one.
 */
class GermanWordIndex(vocabulary: Vocabulary) {
    private val singleWords = HashMap<String, Word>()
    private val phrases = HashMap<String, Word>()

    init {
        // Earlier levels come first and win when two entries share a form.
        for (word in vocabulary.all) {
            for (variant in variantsOf(word)) {
                val keys = tokenize(variant).map { it.text.key() }
                when (keys.size) {
                    0 -> Unit
                    1 -> singleWords.getOrPut(keys[0]) { word }
                    in 2..MAX_PHRASE_WORDS -> phrases.getOrPut(keys.joinToString(" ")) { word }
                }
            }
        }
    }

    /**
     * Every vocabulary word in [tokens], read from left to right. A phrase such as
     * "rund um die Uhr" wins over its single words. Tokens that match nothing are left out.
     */
    fun findAll(tokens: List<TextToken>): List<WordMatch> {
        val keys = tokens.map { it.text.key() }
        val matches = mutableListOf<WordMatch>()
        var index = 0
        while (index < keys.size) {
            val match = phraseAt(keys, index) ?: wordAt(keys, index)
            if (match != null) {
                matches += match
                index = match.lastToken + 1
            } else {
                index++
            }
        }
        return matches
    }

    private fun phraseAt(keys: List<String>, start: Int): WordMatch? {
        for (length in minOf(MAX_PHRASE_WORDS, keys.size - start) downTo 2) {
            val word = phrases[keys.subList(start, start + length).joinToString(" ")] ?: continue
            return WordMatch(word, start, start + length - 1)
        }
        return null
    }

    private fun wordAt(keys: List<String>, index: Int): WordMatch? {
        val key = keys[index]
        val word = singleWords[key] ?: dictionaryForms(key).firstNotNullOfOrNull { singleWords[it] } ?: return null
        return WordMatch(word, index, index)
    }

    private companion object {
        const val MAX_PHRASE_WORDS = 5
    }
}

private fun String.key(): String = lowercase()

private val bracketed = Regex("\\([^)]*\\)")
private val slashChoice = Regex("(\\S+)/(\\S+)")
private val leadingArticle = Regex("^(der|die|das)\\s+", RegexOption.IGNORE_CASE)
private val leadingSich = Regex("^sich\\s+", RegexOption.IGNORE_CASE)

/**
 * The forms under which a word can appear in a text: its German entry without notes such
 * as "(Pl.)", each choice of "der/die Vorgesetzte" or "dir/Ihnen", without a leading
 * article or "sich", its plural, and the conjugated forms of a verb.
 */
internal fun variantsOf(word: Word): Set<String> {
    val german = word.textIn(AppLanguage.DE).replace(bracketed, " ").replace(Regex("\\s+"), " ").trim()
    if (german.isEmpty()) return emptySet()
    var choices = listOf(german)
    // Each "a/b" becomes one variant with a and one with b. Word parts such as "Ab-" or "-in" are dropped.
    repeat(3) {
        choices = choices.flatMap { text ->
            val choice = slashChoice.find(text) ?: return@flatMap listOf(text)
            listOf(choice.groupValues[1], choice.groupValues[2])
                .filterNot { it.endsWith("-") || it.startsWith("-") }
                .map { text.replaceRange(choice.range, it) }
        }
    }
    val variants = LinkedHashSet<String>()
    for (choice in choices) {
        variants += choice
        variants += choice.replace(leadingArticle, "").replace(leadingSich, "")
    }
    word.plural?.let { variants += it }
    // Verb forms: "kam", "ist gekommen", and the participle on its own, since it often
    // stands apart from its auxiliary ("ist gestern gekommen").
    for (tense in word.tenses) {
        for ((_, form) in tense.rows) {
            variants += form
            if (tense.name == "Perfekt" || tense.name == "Plusquamperfekt") {
                tokenize(form).lastOrNull()?.let { variants += it.text }
            }
        }
    }
    return variants.filter { it.isNotBlank() }.toSet()
}

/**
 * Dictionary forms an inflected German word may come from, most likely first:
 * "Freunde" → "freund", "kleinen" → "klein", "wohnt" → "wohnen", "gearbeitet" → "arbeiten".
 * These are guesses; only forms that exist in the vocabulary are ever used.
 */
internal fun dictionaryForms(key: String): List<String> {
    val forms = LinkedHashSet<String>()
    // Nouns and adjectives: Freunde, Kindern, kleinen, schönes.
    for (ending in listOf("en", "em", "er", "es", "e", "n", "s")) {
        if (key.endsWith(ending) && key.length - ending.length >= 3) forms += key.dropLast(ending.length)
    }
    // Verbs: wohnt, wohnst, wohnte, wohnten, arbeitet, arbeitest. Stems shorter than three
    // letters are left alone, or "wie" would turn into "Wien".
    for (ending in listOf("test", "tet", "ten", "te", "est", "et", "st", "t", "e")) {
        if (key.endsWith(ending) && key.length - ending.length >= 3) {
            val stem = key.dropLast(ending.length)
            forms += stem + "en"
            forms += stem + "n"
        }
    }
    // Participles: gewohnt, gearbeitet, geschlafen.
    if (key.startsWith("ge") && key.length > 5) {
        val rest = key.drop(2)
        when {
            rest.endsWith("et") -> forms += rest.dropLast(2) + "en"
            rest.endsWith("t") -> forms += rest.dropLast(1) + "en"
            rest.endsWith("en") -> forms += rest
        }
    }
    forms -= key
    return forms.toList()
}
