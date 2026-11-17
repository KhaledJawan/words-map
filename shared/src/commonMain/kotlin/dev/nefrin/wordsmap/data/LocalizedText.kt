package dev.nefrin.wordsmap.data

import androidx.compose.runtime.Immutable
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive

/** A piece of content written in several languages, keyed by language code. */
@Immutable
class LocalizedText(private val values: Map<String, String>) {

    val isEmpty: Boolean get() = values.isEmpty()

    val all: Collection<String> get() = values.values

    fun textIn(language: AppLanguage): String = values[language.code].orEmpty()

    /** Text for [language]. Pashto falls back to Farsi, and every language falls back to English. */
    fun resolve(language: AppLanguage): String = values[codeFor(language)].orEmpty()

    /** Like [resolve], but never empty while at least one language has text. */
    fun resolveOrAny(language: AppLanguage): String = values[resolvedCode(language)].orEmpty()

    /** Code of the language [resolveOrAny] takes its text from, or null when there is no text at all. */
    fun resolvedCode(language: AppLanguage): String? =
        codeFor(language) ?: "de".takeIf { it in values } ?: values.keys.firstOrNull()

    private fun codeFor(language: AppLanguage): String? = when {
        language.code in values -> language.code
        language == AppLanguage.PS && "fa" in values -> "fa"
        "en" in values -> "en"
        else -> null
    }

    companion object {
        val Empty = LocalizedText(emptyMap())

        /** Reads `{"en": "…", "fa": "…"}`. A bare string counts as German. */
        fun from(value: JsonElement?): LocalizedText = when {
            value is JsonObject -> LocalizedText(
                buildMap {
                    for (key in value.keys) {
                        val text = value.string(key).trim()
                        if (text.isNotEmpty()) put(key.trim().lowercase(), text)
                    }
                },
            )
            value is JsonPrimitive && value.isString -> if (value.content.isBlank()) Empty else LocalizedText(mapOf("de" to value.content.trim()))
            else -> Empty
        }

        /** Reads sibling keys of [json] such as `title_en` and `title_fa` for the prefix `title`. */
        fun fromSuffixedKeys(json: JsonObject, prefix: String): LocalizedText = LocalizedText(
            buildMap {
                for (key in json.keys) {
                    if (!key.startsWith("${prefix}_")) continue
                    val text = json.string(key).trim()
                    if (text.isNotEmpty()) put(key.removePrefix("${prefix}_"), text)
                }
            },
        )
    }
}
