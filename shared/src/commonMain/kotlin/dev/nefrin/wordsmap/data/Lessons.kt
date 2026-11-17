package dev.nefrin.wordsmap.data

import dev.nefrin.wordsmap.resources.AppAssets
import kotlinx.serialization.json.JsonObject

class LessonExplanation(val title: LocalizedText, val text: LocalizedText)

class AlphabetLetter(
    val upper: String,
    val lower: String,
    val name: String,
    val hint: LocalizedText,
    /** Keys of example words, looked up with [Vocabulary.find]. */
    val examples: List<String>,
)

class SpecialLetter(
    val symbol: String,
    val name: String,
    val hint: LocalizedText,
    val description: LocalizedText,
)

class AlphabetLesson(
    val id: String,
    val title: LocalizedText,
    val explanations: List<LessonExplanation>,
    val note: LocalizedText,
    val letters: List<AlphabetLetter>,
    val specialLetters: List<SpecialLetter>,
)

class CombinationRule(
    val id: String,
    val title: LocalizedText,
    val description: LocalizedText,
    val examples: List<String>,
) {
    /** Short label for the rule's badge, such as "sch" or "ei". */
    val badge: String
        get() {
            val german = title.textIn(AppLanguage.DE)
            if (german.isNotEmpty() && german.length <= 10) return german
            val parts = id.split('_').filter { it.isNotEmpty() }
            return if (parts.size >= 2) "${parts[0]}/${parts[1]}" else id
        }
}

class CombinationsLesson(
    val id: String,
    val title: LocalizedText,
    val explanations: List<LessonExplanation>,
    val rules: List<CombinationRule>,
)

/** The two reading lessons that belong to one learning language. */
class Lessons(val alphabet: AlphabetLesson, val combinations: CombinationsLesson)

object LessonsRepository {

    /** Reads `lessons/lesson_<language>.json`, the alphabet and letter-combination lessons of [language]. */
    suspend fun load(language: AppLanguage): Lessons {
        val json = parseJsonObject(AppAssets.readText("lessons/lesson_${language.code}.json"))
        return Lessons(
            alphabet = parseAlphabet(checkNotNull(json.obj("alphabet")) { "No alphabet lesson for ${language.code}" }),
            combinations = parseCombinations(checkNotNull(json.obj("combinations")) { "No combinations lesson for ${language.code}" }),
        )
    }

    private fun parseAlphabet(json: JsonObject): AlphabetLesson {
        val block = json.obj("alphabet") ?: JsonObject(emptyMap())
        return AlphabetLesson(
            id = json.string("id"),
            title = LocalizedText.fromSuffixedKeys(json, "title"),
            explanations = parseExplanations(json),
            note = LocalizedText.fromSuffixedKeys(block, "note"),
            letters = block.array("letters").objects().map { letter ->
                AlphabetLetter(
                    upper = letter.string("upper"),
                    lower = letter.string("lower"),
                    name = letter.string("name_de"),
                    hint = hintOf(letter),
                    examples = exampleKeys(letter),
                )
            },
            specialLetters = block.array("special_letters").objects().map { letter ->
                SpecialLetter(
                    symbol = letter.string("symbol"),
                    name = letter.string("name_de"),
                    hint = hintOf(letter),
                    description = LocalizedText.fromSuffixedKeys(letter, "description"),
                )
            },
        )
    }

    private fun parseCombinations(json: JsonObject) = CombinationsLesson(
        id = json.string("id"),
        title = LocalizedText.fromSuffixedKeys(json, "title"),
        explanations = parseExplanations(json),
        rules = json.array("combinations").objects().map { rule ->
            CombinationRule(
                id = rule.string("id"),
                title = LocalizedText.fromSuffixedKeys(rule, "title"),
                description = LocalizedText.fromSuffixedKeys(rule, "description"),
                examples = exampleKeys(rule),
            )
        },
    )

    // The lesson files spell this key "explanition".
    private fun parseExplanations(json: JsonObject): List<LessonExplanation> =
        (json.array("explanition") ?: json.array("explanation")).objects().map {
            LessonExplanation(
                title = LocalizedText.fromSuffixedKeys(it, "title"),
                text = LocalizedText.fromSuffixedKeys(it, "explanation"),
            )
        }

    private fun hintOf(json: JsonObject) = LocalizedText(
        buildMap {
            json.string("fa_hint").takeIf { it.isNotBlank() }?.let { put("fa", it) }
            json.string("ps_hint").takeIf { it.isNotBlank() }?.let { put("ps", it) }
        },
    )

    private fun exampleKeys(json: JsonObject): List<String> =
        json.array("examples").objects().mapNotNull { example ->
            example.obj("word_ref")?.string("key")?.trim()?.takeIf { it.isNotEmpty() }
        }
}
