package dev.nefrin.wordsmap.data

import androidx.compose.runtime.Immutable
import dev.nefrin.wordsmap.resources.AppAssets
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject

/** One tense of a verb: its German name and the form for each person, in display order. */
@Immutable
class VerbTense(val name: String, val rows: List<Pair<String, String>>)

@Immutable
class Word(
    val id: String,
    val level: String,
    val categories: List<String>,
    private val texts: Map<String, String>,
    private val examples: Map<String, String>,
    /** German article of a noun: der, die or das. */
    val article: String?,
    val plural: String?,
    /** The conjugation of a verb, in display order. Empty for every other word. */
    val tenses: List<VerbTense> = emptyList(),
) {
    val allTexts: Collection<String> get() = texts.values

    /** Whether the word is a verb: it has a conjugation, or carries a verb tag. */
    val isVerb: Boolean get() = tenses.isNotEmpty() || categories.any { it in verbTags }

    fun textIn(language: AppLanguage): String = texts[language.code].orEmpty()

    fun exampleIn(language: AppLanguage): String = examples[language.code].orEmpty()

    /** The word in [language], or in the first other language that has it. */
    fun displayText(language: AppLanguage): String =
        textIn(language).ifEmpty { firstText(AppLanguage.wordLanguages - language) }.ifEmpty { "—" }

    /** The meaning shown next to [displayText] of [source]; avoids repeating the same text when it can. */
    fun translation(source: AppLanguage, target: AppLanguage): String {
        val translated = displayText(target)
        if (translated != displayText(source)) return translated
        return firstText(AppLanguage.wordLanguages - source).ifEmpty { "—" }
    }

    private fun firstText(languages: List<AppLanguage>): String =
        languages.firstNotNullOfOrNull { texts[it.code] } ?: texts.values.firstOrNull().orEmpty()
}

private val verbTags = setOf("verb", "modal_verb", "separable_verb", "reflexive_verb", "irregular_verb")

private val smallWordTags = setOf("adverb", "conjunction", "preposition", "negation")

/** A kind of word with its own tile on the home screen, which can be filtered by CEFR level. */
enum class WordGroup(internal val key: String) {
    VERBS("verbs"),

    /** Adverbs, conjunctions, prepositions and negation: "schon", "hingegen", "weder … noch". */
    SMALL_WORDS("small_words"),
}

fun Word.belongsTo(group: WordGroup): Boolean = when (group) {
    WordGroup.VERBS -> isVerb
    WordGroup.SMALL_WORDS -> !isVerb && categories.any { it in smallWordTags } && isSingleWordOrPair()
}

// One word, or a pair such as "weder … noch"; not a phrase that merely contains one ("in bar bezahlen", "Bis bald!").
private fun Word.isSingleWordOrPair(): Boolean {
    val german = textIn(AppLanguage.DE)
    return if ('…' in german) german.none { it in ",!?" } else german.none { it == ' ' || it in "!?" }
}

/** The CEFR level a chapter belongs to: "A1.2" → "A1". */
fun bandOf(level: String): String = level.substringBefore('.')

/** Every word of the app, grouped by level (A1.1 … B2.2), by category tag and by [WordGroup]. */
class Vocabulary(val levels: List<String>, private val byLevel: Map<String, List<Word>>) {

    val all: List<Word> = levels.flatMap { byLevel.getValue(it) }

    private val byGroup: Map<WordGroup, List<Word>> = WordGroup.entries.associateWith { group -> all.filter { it.belongsTo(group) } }

    private val bandsByGroup: Map<WordGroup, List<String>> = byGroup.mapValues { (_, words) -> words.map { bandOf(it.level) }.distinct() }

    val byCategory: Map<String, List<Word>> = buildMap<String, MutableList<Word>> {
        for (word in all) for (tag in word.categories) getOrPut(tag) { mutableListOf() }.add(word)
    }

    private val index: Map<String, Word> = buildMap {
        for (word in all) {
            getOrPut(word.id.lowercase()) { word }
            for (text in word.allTexts) getOrPut(text.lowercase()) { word }
        }
    }

    fun wordsInLevel(level: String): List<Word> = byLevel[level].orEmpty()

    fun wordsInCategory(tag: String): List<Word> = byCategory[tag].orEmpty()

    /** The words of [group] at one CEFR level such as "B1", or at every level when [band] is null. */
    fun wordsIn(group: WordGroup, band: String? = null): List<Word> {
        val words = byGroup.getValue(group)
        return if (band == null) words else words.filter { bandOf(it.level) == band }
    }

    /** The CEFR levels that have words of [group], in order: A1, A2, B1 … */
    fun bandsOf(group: WordGroup): List<String> = bandsByGroup.getValue(group)

    /** Finds a word by its id or by its text in any language, ignoring case. */
    fun find(key: String): Word? = index[key.trim().lowercase()]
}

object VocabularyRepository {
    private const val FOLDER = "words"
    private val levelFile = Regex("^([a-z])(\\d)_(\\d+)\\.json$", RegexOption.IGNORE_CASE)

    /** Reads every `words/<level>.json` file; `a1_1.json` holds level A1.1. */
    suspend fun load(): Vocabulary {
        val files = AppAssets.list(FOLDER).sorted().mapNotNull { name ->
            levelFile.matchEntire(name)?.let { match ->
                val (band, major, minor) = match.destructured
                "${band.uppercase()}$major.$minor" to name
            }
        }
        check(files.isNotEmpty()) { "No word files in $FOLDER" }
        val byLevel = files.associate { (level, name) ->
            level to parseWords(parseJsonArray(AppAssets.readText("$FOLDER/$name")), level)
        }
        return Vocabulary(files.map { it.first }, byLevel)
    }

    private fun parseWords(array: JsonArray, level: String): List<Word> = array.map { element ->
        val json = element.jsonObject
        Word(
            id = checkNotNull(json["id"].text) { "A word of $level has no id" },
            level = level,
            categories = json.array("category").strings(),
            texts = json.obj("words").texts(),
            examples = json.obj("examples").texts(),
            article = json.string("article").ifBlank { null },
            plural = json.string("plural").ifBlank { null },
            tenses = orderedTenses(json.obj("forms").tables()),
        )
    }

    private fun JsonObject?.tables(): Map<String, Map<String, String>> = buildMap {
        val json = this@tables ?: return@buildMap
        for (tense in json.keys) put(tense.trim(), json.obj(tense).texts())
    }

    private fun JsonObject?.texts(): Map<String, String> = buildMap {
        val json = this@texts ?: return@buildMap
        for (key in json.keys) {
            val text = json.string(key).trim()
            if (text.isNotEmpty()) put(key, text)
        }
    }
}

private val tenseOrder = listOf(
    "Präsens", "Präteritum", "Perfekt", "Plusquamperfekt", "Futur I", "Futur II",
    "Konjunktiv I", "Konjunktiv II", "Imperativ",
)
private val personOrder = listOf("ich", "du", "er/sie/es", "wir", "ihr", "sie/Sie", "Sie")

/**
 * Puts the tenses of a verb in the usual teaching order, and the persons from "ich" to
 * "sie/Sie". Tenses and persons the app does not know are kept, after the known ones.
 */
internal fun orderedTenses(tables: Map<String, Map<String, String>>): List<VerbTense> =
    tables.entries
        .filter { (_, rows) -> rows.values.any { it.isNotBlank() } }
        .sortedBy { (name, _) -> tenseOrder.indexOf(name).let { if (it < 0) tenseOrder.size else it } }
        .map { (name, rows) ->
            VerbTense(
                name = name,
                rows = rows.entries
                    .filter { it.value.isNotBlank() }
                    .sortedBy { (person, _) -> personOrder.indexOf(person).let { if (it < 0) personOrder.size else it } }
                    .map { it.key to it.value.trim() },
            )
        }
