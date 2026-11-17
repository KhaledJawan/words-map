package dev.nefrin.wordsmap.data

import androidx.compose.runtime.Immutable
import dev.nefrin.wordsmap.platform.currentTimeMillis
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.addJsonObject
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.put
import kotlin.random.Random

/**
 * A word the learner added themselves: [text] in the language they learn, [translation] in
 * the one they read. It is shown as typed, whatever the word pair is.
 */
@Immutable
data class UserWord(
    val id: String,
    val text: String,
    val translation: String,
    /** German article (der, die, das), when the learner gave one. */
    val article: String? = null,
    val plural: String? = null,
    val example: String? = null,
    /** The learner's category the word is in, or null for none. */
    val listId: String? = null,
)

/** A category the learner made for their own words, such as "Work" or "Holiday in Berlin". */
@Immutable
data class UserList(val id: String, val name: String)

private const val USER_WORD_PREFIX = "mine-"
private const val USER_LIST_PREFIX = "list-"

/** Whether [id] belongs to one of the learner's own words rather than to a word of the app. */
fun isUserWordId(id: String): Boolean = id.startsWith(USER_WORD_PREFIX)

fun newUserWordId(): String = USER_WORD_PREFIX + uniqueSuffix()

fun newUserListId(): String = USER_LIST_PREFIX + uniqueSuffix()

// The time keeps ids in creation order; the random part keeps two made in one millisecond apart.
private fun uniqueSuffix(): String =
    currentTimeMillis().toString(36) + Random.nextInt(36 * 36 * 36 * 36).toString(36).padStart(4, '0')

private val germanArticle = Regex("^(der|die|das)\\s+(.+)$", RegexOption.IGNORE_CASE)

/**
 * Cleans what the learner typed: trims every field, drops empty ones, and takes a German
 * article typed in front of the word ("der Tisch") into the article, unless one is set.
 */
fun UserWord.tidy(): UserWord {
    val word = text.trim().replace(Regex("\\s+"), " ")
    val typedArticle = germanArticle.matchEntire(word).takeIf { article.isNullOrBlank() }
    return copy(
        text = typedArticle?.groupValues?.get(2) ?: word,
        translation = translation.trim(),
        article = (typedArticle?.groupValues?.get(1)?.lowercase() ?: article?.trim())?.ifEmpty { null },
        plural = plural?.trim()?.ifEmpty { null },
        example = example?.trim()?.ifEmpty { null },
    )
}

/**
 * The word seen as a vocabulary word, in the languages of the current word pair, so that the
 * word wall, the search results and the word card treat it like any other.
 */
fun UserWord.asWord(source: AppLanguage, target: AppLanguage): Word = Word(
    id = id,
    level = "",
    categories = emptyList(),
    texts = mapOf(source.code to text, target.code to translation),
    examples = example?.let { mapOf(source.code to it) }.orEmpty(),
    article = article,
    plural = plural,
)

/** Whether [query] (already normalized with [normalizeForSearch]) is in the word or its meaning. */
fun UserWord.matches(query: String): Boolean =
    query.isEmpty() || listOfNotNull(text, translation, plural).any { normalizeForSearch(it).contains(query) }

/** The learner's words and categories as JSON text, the way [AppPreferences] keeps them. */
internal object UserWordsJson {

    fun encodeWords(words: List<UserWord>): String = buildJsonArray {
        for (word in words) {
            addJsonObject {
                put("id", word.id)
                put("text", word.text)
                put("translation", word.translation)
                word.article?.let { put("article", it) }
                word.plural?.let { put("plural", it) }
                word.example?.let { put("example", it) }
                word.listId?.let { put("list", it) }
            }
        }
    }.toString()

    /** Reads what [encodeWords] wrote; a damaged entry is skipped, a damaged file gives no words. */
    fun decodeWords(json: String?): List<UserWord> = objects(json).mapNotNull { item ->
        val id = item.string("id")
        val text = item.string("text")
        if (id.isEmpty() || text.isEmpty()) return@mapNotNull null
        UserWord(
            id = id,
            text = text,
            translation = item.string("translation"),
            article = item.string("article").ifEmpty { null },
            plural = item.string("plural").ifEmpty { null },
            example = item.string("example").ifEmpty { null },
            listId = item.string("list").ifEmpty { null },
        )
    }

    fun encodeLists(lists: List<UserList>): String = buildJsonArray {
        for (list in lists) {
            addJsonObject {
                put("id", list.id)
                put("name", list.name)
            }
        }
    }.toString()

    fun decodeLists(json: String?): List<UserList> = objects(json).mapNotNull { item ->
        val id = item.string("id")
        val name = item.string("name")
        if (id.isEmpty() || name.isEmpty()) null else UserList(id, name)
    }

    private fun objects(json: String?): List<JsonObject> =
        if (json.isNullOrBlank()) emptyList() else runCatching { parseJsonArray(json).objects() }.getOrDefault(emptyList())
}
