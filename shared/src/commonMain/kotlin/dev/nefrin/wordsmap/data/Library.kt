package dev.nefrin.wordsmap.data

import dev.nefrin.wordsmap.platform.Log
import dev.nefrin.wordsmap.platform.decomposeAccents
import dev.nefrin.wordsmap.resources.AppAssets
import kotlinx.coroutines.CancellationException
import kotlinx.serialization.json.JsonObject

/**
 * A multiple-choice question. In the file the right answer is written first; the app shuffles
 * them. The [explanation] says why the right answer is right, and is shown once answered.
 */
class QuizQuestion(
    val question: LocalizedText,
    val answers: List<LocalizedText>,
    val explanation: LocalizedText = LocalizedText.Empty,
)

/** A lesson file of a [Library]: a grammar lesson or a reading text. */
interface LibraryItem {
    /** Chapter folder and file name without extension, for example `a1/adverbien`. */
    val id: String
    val chapterId: String
    val title: LocalizedText
    val description: LocalizedText
    val questions: List<QuizQuestion>

    /** Number of the lesson in its book, shown in front of it; null when it has none. */
    val number: Int? get() = null

    /** What the lesson teaches, such as "Personalpronomen"; empty when it has no such name. */
    val topic: LocalizedText get() = LocalizedText.Empty

    /** Title, topic, number and keywords in every language, normalized with [normalizeForSearch]. */
    val searchNames: String

    /**
     * Whether a search for [normalizedQuery] should list this item. Names match in any
     * language, so the German name always works; the description only in [language], the
     * one on screen, or a hit could not be explained by anything the user sees.
     */
    fun matches(normalizedQuery: String, language: AppLanguage): Boolean =
        normalizedQuery in searchNames || normalizedQuery in normalizeForSearch(description.resolveOrAny(language))
}

class GrammarLesson(
    override val id: String,
    override val chapterId: String,
    /** Asset path of the cover photo, or null when the lesson has none. */
    val cover: String?,
    override val title: LocalizedText,
    override val description: LocalizedText,
    val fullDescription: LocalizedText,
    /** Each example holds the German sentence under `de` and its translations under their codes. */
    val examples: List<LocalizedText>,
    override val questions: List<QuizQuestion>,
    override val searchNames: String,
    override val number: Int? = null,
    override val topic: LocalizedText = LocalizedText.Empty,
    /** Asset paths of the lesson's Markdown files by language; read with [parseLessonMarkdown] when the lesson opens. */
    val content: LocalizedText = LocalizedText.Empty,
) : LibraryItem

class ReadingText(
    override val id: String,
    override val chapterId: String,
    override val title: LocalizedText,
    override val description: LocalizedText,
    /** The text to read, usually German only. */
    val text: LocalizedText,
    override val questions: List<QuizQuestion>,
    override val searchNames: String,
) : LibraryItem

class LibraryChapter<T : LibraryItem>(val id: String, val items: List<T>) {
    /** Level name shown to the user, such as "A1". */
    val label: String get() = id.uppercase()
}

/** Items sorted into level chapters: the grammar lessons, or the reading texts. */
class Library<T : LibraryItem>(val chapters: List<LibraryChapter<T>>) {
    val itemCount: Int get() = chapters.sumOf { it.items.size }

    fun chapter(id: String): LibraryChapter<T>? = chapters.firstOrNull { it.id == id }

    fun item(id: String): T? = chapters.firstNotNullOfOrNull { chapter -> chapter.items.firstOrNull { it.id == id } }

    /** Items matching [query], for a reader of [language]. See [LibraryItem.matches]. */
    fun search(query: String, language: AppLanguage, chapterId: String? = null): List<T> {
        val normalized = normalizeForSearch(query)
        if (normalized.isEmpty()) return emptyList()
        return chapters
            .filter { chapterId == null || it.id == chapterId }
            .flatMap { chapter -> chapter.items.filter { it.matches(normalized, language) } }
    }
}

typealias Grammar = Library<GrammarLesson>
typealias Texts = Library<ReadingText>

/** One lesson file, handed to the parser of a library. */
class LibraryFile(
    val json: JsonObject,
    val chapterId: String,
    private val folderPath: String,
    private val fileName: String,
    private val siblings: List<String>,
) {
    val id: String get() = "$chapterId/${fileName.substringBeforeLast('.')}"

    /** Asset path of [name] when it is a file next to this one. */
    fun siblingPath(name: String): String? = name.trim().takeIf { it in siblings }?.let { "$folderPath/$it" }

    /**
     * The Markdown files of this lesson, one per language, keyed by language code:
     * `01-personalpronomen.fa.md` next to `01-personalpronomen.json` is the Farsi text.
     */
    fun markdownFiles(): LocalizedText {
        val stem = fileName.substringBeforeLast('.')
        val pattern = Regex("^${Regex.escape(stem)}\\.([a-z]{2})\\.md$", RegexOption.IGNORE_CASE)
        return LocalizedText(
            siblings.mapNotNull { name -> pattern.matchEntire(name)?.let { it.groupValues[1].lowercase() to "$folderPath/$name" } }.toMap(),
        )
    }

    fun text(key: String): LocalizedText = LocalizedText.from(json[key])

    fun searchNames(vararg names: LocalizedText, extra: List<String> = emptyList()): String =
        (names.flatMap { it.all } + extra + json.array("keywords").strings()).joinToString("\n") { normalizeForSearch(it) }

    fun questions(): List<QuizQuestion> = json.array("questions").let { array ->
        if (array == null) return emptyList()
        array.map { it as? JsonObject }.mapNotNull { question ->
            val answers = question?.array("answers")?.map { LocalizedText.from(it) }
                ?.filterNot { it.isEmpty }
                .orEmpty()
            val text = LocalizedText.from(question?.get("question"))
            if (text.isEmpty || answers.size < 2) {
                Log.w(TAG, "Skipping a question of $id: it needs a question and at least two answers")
                null
            } else {
                QuizQuestion(text, answers)
            }
        }
    }

    private companion object {
        const val TAG = "LibraryFile"
    }
}

/**
 * Reads a library from `composeResources/files/<folder>/<chapter>/<lesson>.json`.
 *
 * Nothing is registered in code: a chapter is a folder and a lesson is a JSON file inside it.
 * The chapters A1 to C1 always exist; any other folder is added after them.
 */
object LibraryLoader {
    private const val TAG = "LibraryLoader"
    private val standardChapters = listOf("a1", "a2", "b1", "b2", "c1")

    suspend fun <T : LibraryItem> load(folder: String, parse: (LibraryFile) -> T): Library<T> {
        // Folder names by chapter id. Files such as README.md are not chapters, and folders
        // starting with "_", such as the _example folder, are left out.
        val folders = AppAssets.list(folder)
            .filter { '.' !in it && !it.startsWith("_") }
            .associateBy { it.lowercase() }
        val chapterIds = standardChapters + (folders.keys - standardChapters.toSet()).sorted()
        return Library(
            chapterIds.map { id ->
                LibraryChapter(id, folders[id]?.let { loadChapter("$folder/$it", id, parse) }.orEmpty())
            },
        )
    }

    private suspend fun <T : LibraryItem> loadChapter(
        path: String,
        chapterId: String,
        parse: (LibraryFile) -> T,
    ): List<T> {
        val files = AppAssets.list(path)
        return files.filter { it.endsWith(".json", ignoreCase = true) && !it.startsWith("_") }.sorted().mapNotNull { name ->
            try {
                val json = parseJsonObject(AppAssets.readText("$path/$name"))
                // Lessons are listed by "order", or else by their number in the book.
                json.int("order", json.int("number", Int.MAX_VALUE)) to parse(LibraryFile(json, chapterId, path, name, files))
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                // One broken file must not hide the rest of the chapter.
                Log.w(TAG, "Skipping $path/$name", error)
                null
            }
        }.sortedBy { it.first }.map { it.second }
    }
}

object GrammarRepository {
    const val FOLDER = "gramatik"

    suspend fun load(): Grammar = LibraryLoader.load(FOLDER) { file ->
        val title = file.text("title")
        val topic = file.text("topic")
        val number = file.json.int("number").takeIf { it > 0 }
        val coverName = file.json.string("cover")
        val cover = coverName.takeIf { it.isNotBlank() }?.let(file::siblingPath)
        if (cover == null && coverName.isNotBlank()) Log.w("GrammarRepository", "Cover $coverName of ${file.id} is missing")
        GrammarLesson(
            id = file.id,
            chapterId = file.chapterId,
            cover = cover,
            title = title,
            description = file.text("description"),
            fullDescription = file.text("full_description"),
            examples = file.json.array("examples").orEmpty().map { LocalizedText.from(it) }.filterNot { it.isEmpty },
            questions = file.questions(),
            searchNames = file.searchNames(title, topic, extra = listOfNotNull(number?.toString())),
            number = number,
            topic = topic,
            content = file.markdownFiles(),
        )
    }
}

object TextsRepository {
    const val FOLDER = "reading"

    suspend fun load(): Texts = LibraryLoader.load(FOLDER) { file ->
        val title = file.text("title")
        ReadingText(
            id = file.id,
            chapterId = file.chapterId,
            title = title,
            description = file.text("description"),
            text = file.text("text"),
            questions = file.questions(),
            searchNames = file.searchNames(title),
        )
    }
}

/** Lower-cases [text] and strips accents and Arabic-script variants, so "praposition" finds "Präposition". */
fun normalizeForSearch(text: String): String =
    decomposeAccents(text.trim().lowercase())
        .filterNot { it.category == CharCategory.NON_SPACING_MARK }
        .replace('ي', 'ی')
        .replace('ك', 'ک')
        .replace("‌", "")
        .replace("ß", "ss")
