package dev.nefrin.wordsmap.data

/**
 * The content of a grammar lesson, read from a Markdown file such as
 * `gramatik/a1/01-ich-du-er-sie-es-wir.fa.md`. The format is described in tools/GRAMMAR_PROMPT.md.
 */
class LessonDocument(
    /** The `# ` line: the name of the topic in the language of the file. */
    val heading: String?,
    val blocks: List<LessonBlock>,
    /** The questions of the `## Quiz` section, right answer first. */
    val questions: List<QuizQuestion>,
)

sealed interface LessonBlock {
    data class Heading(val text: String) : LessonBlock
    data class Paragraph(val text: String) : LessonBlock
    data class Bullets(val items: List<String>, val numbered: Boolean = false) : LessonBlock
    data class Table(val header: List<String>, val rows: List<List<String>>) : LessonBlock

    /** A highlighted card: `> [!NOTE]` and the `>` lines below it. */
    data class Callout(val kind: CalloutKind, val blocks: List<LessonBlock>) : LessonBlock
}

enum class CalloutKind { NOTE, TIP, IMPORTANT, WARNING, RULE, EXAMPLE, SUMMARY }

private val headingLine = Regex("^(#{1,6})\\s+(.+?)\\s*#*$")
private val bulletLine = Regex("^\\s*[-*+•]\\s+(.+)$")
private val numberedLine = Regex("^\\s*([0-9۰-۹]+)[.)]\\s+(.+)$")
private val optionLine = Regex("^\\s*[-*+]\\s*\\[([ xX])]\\s*(.+)$")
private val questionLine = Regex("^\\s*[?؟]\\s*(.+)$")
private val plainOption = Regex("^\\s*([-*+])\\s+(.+)$")
private val explanationLine = Regex("^\\s*!\\s*(.+)$")
private val calloutMarker = Regex("^\\[!([A-Za-z]+)]\\s*(.*)$")
private val calloutStart = Regex("^>\\s*\\[![A-Za-z]+].*")
// "### 3. Welche …?": some writers put each quiz question in a numbered heading.
private val numberedHeading = Regex("^[0-9۰-۹]+[.)]\\s*(.+)$")
private val separatorCell = Regex("^:?-{2,}:?$")
private val ruleLine = Regex("^\\s*([-*_])\\s*(\\1\\s*){2,}$")

private val rightToLeftScript = Regex("[\\u0590-\\u08FF\\uFB1D-\\uFDFD\\uFE70-\\uFEFC]")

// The quiz heading, also in the words another writer might use for it.
private val quizNames = setOf("quiz", "questions", "fragen", "übung", "test", "تمرین", "آزمون", "پوښتنې", "ازموینه")

/** Reads a lesson file. Lines the format does not know are kept as ordinary text. */
fun parseLessonMarkdown(markdown: String): LessonDocument {
    val lines = markdown.replace("\r\n", "\n").replace('\r', '\n').lines()
    var heading: String? = null
    val body = mutableListOf<String>()
    val quiz = mutableListOf<String>()
    var inQuiz = false
    for (line in lines) {
        val title = headingLine.matchEntire(line.trim())
        when {
            title != null && title.groupValues[1].length == 1 && heading == null && body.none { it.isNotBlank() } ->
                heading = title.groupValues[2]
            title != null && title.groupValues[2].trim().trimEnd(':').lowercase() in quizNames -> inQuiz = true
            inQuiz && title != null && numberedHeading.matches(title.groupValues[2]) ->
                quiz += "? " + numberedHeading.matchEntire(title.groupValues[2])!!.groupValues[1]
            // A heading or a card after the questions, such as a summary, belongs to the lesson again.
            inQuiz && (title != null || line.trimStart().startsWith(">")) -> {
                inQuiz = false
                body += line
            }
            inQuiz -> quiz += line
            else -> body += line
        }
    }
    return LessonDocument(heading, parseBlocks(body), parseQuiz(quiz))
}

private fun parseBlocks(lines: List<String>): List<LessonBlock> {
    val blocks = mutableListOf<LessonBlock>()
    var i = 0
    fun nextNonBlank(from: Int): Int {
        var j = from
        while (j < lines.size && lines[j].isBlank()) j++
        return j
    }
    while (i < lines.size) {
        val line = lines[i]
        val trimmed = line.trim()
        val title = headingLine.matchEntire(trimmed)
        when {
            trimmed.isEmpty() || ruleLine.matches(trimmed) || trimmed.startsWith("```") -> i++
            title != null -> {
                blocks += LessonBlock.Heading(title.groupValues[2])
                i++
            }
            trimmed.startsWith(">") -> {
                val inner = mutableListOf<String>()
                while (i < lines.size) {
                    val current = lines[i].trim()
                    if (current.startsWith(">")) {
                        inner += current.removePrefix(">").removePrefix(" ")
                        i++
                        continue
                    }
                    // Some writers leave an empty line between the lines of a card. The card goes on
                    // when its next line is a card line, unless that line starts another card.
                    val next = nextNonBlank(i)
                    if (current.isEmpty() && next < lines.size && lines[next].trim().startsWith(">") &&
                        !calloutStart.matches(lines[next].trim())
                    ) {
                        inner += ""
                        i = next
                        continue
                    }
                    break
                }
                val marker = calloutMarker.matchEntire(inner.first().trim())
                val kind = marker?.groupValues?.get(1)?.uppercase()?.let { name -> CalloutKind.entries.firstOrNull { it.name == name } }
                    ?: CalloutKind.NOTE
                val content = if (marker != null) listOf(marker.groupValues[2]) + inner.drop(1) else inner
                blocks += LessonBlock.Callout(kind, parseBlocks(content))
            }
            trimmed.startsWith("|") -> {
                val rows = mutableListOf<List<String>>()
                while (i < lines.size && lines[i].trim().startsWith("|")) {
                    val cells = lines[i].trim().trim('|').split("|").map { it.trim() }
                    if (!cells.all { separatorCell.matches(it) }) rows += cells
                    i++
                }
                if (rows.isNotEmpty()) {
                    val width = rows.maxOf { it.size }
                    val padded = rows.map { it + List(width - it.size) { "" } }
                    blocks += LessonBlock.Table(padded.first(), padded.drop(1))
                }
            }
            bulletLine.matches(line) || numberedLine.matches(line) -> {
                val numbered = !bulletLine.matches(line)
                val pattern = if (numbered) numberedLine else bulletLine
                val items = mutableListOf<String>()
                // Items may have empty lines between them and still form one list.
                while (true) {
                    val match = pattern.matchEntire(lines.getOrNull(i) ?: break) ?: break
                    items += match.groupValues.last().trim()
                    i++
                    val next = nextNonBlank(i)
                    if (next < lines.size && pattern.matches(lines[next])) i = next else break
                }
                blocks += LessonBlock.Bullets(items, numbered)
            }
            else -> {
                val paragraph = mutableListOf<String>()
                while (i < lines.size) {
                    val current = lines[i]
                    val currentTrimmed = current.trim()
                    if (currentTrimmed.isEmpty() || headingLine.matches(currentTrimmed) || currentTrimmed.startsWith(">") ||
                        currentTrimmed.startsWith("|") || bulletLine.matches(current) || numberedLine.matches(current)
                    ) break
                    paragraph += currentTrimmed
                    i++
                }
                blocks += LessonBlock.Paragraph(paragraph.joinToString("\n"))
            }
        }
    }
    return blocks
}

/**
 * The questions, in either of two forms. A numbered line with its answers as `- [ ]` lines and
 * the right one as `- [x]`; or a `? ` line with `- ` wrong answers and a `* ` right one. In
 * both, a `! ` line explains the answer. A question needs at least two answers and exactly
 * one right answer.
 */
private fun parseQuiz(lines: List<String>): List<QuizQuestion> {
    class Draft(var text: String) {
        val answers = mutableListOf<Pair<String, Boolean>>()
        var explanation = ""
    }
    val drafts = mutableListOf<Draft>()
    for (line in lines) {
        if (line.isBlank()) continue
        val current = drafts.lastOrNull()
        val option = optionLine.matchEntire(line)
        val asked = questionLine.matchEntire(line) ?: numberedLine.matchEntire(line)
        val explained = explanationLine.matchEntire(line)
        val plain = plainOption.matchEntire(line)
        when {
            option != null && current != null -> current.answers += option.groupValues[2].trim() to option.groupValues[1].isNotBlank()
            asked != null -> drafts += Draft(asked.groupValues.last().trim())
            explained != null && current != null ->
                current.explanation = listOf(current.explanation, explained.groupValues[1].trim()).filter { it.isNotEmpty() }.joinToString("\n")
            plain != null && current != null -> current.answers += plain.groupValues[2].trim() to (plain.groupValues[1] == "*")
            // A question may continue on the next line; other text after the answers is ignored.
            current != null && current.answers.isEmpty() -> current.text += "\n" + line.trim()
        }
    }
    return drafts.mapNotNull { draft ->
        val right = draft.answers.filter { it.second }
        if (draft.answers.size < 2 || right.size != 1) return@mapNotNull null
        // A wrong answer written like the right one (or twice) would be shown twice.
        val answers = (right + draft.answers.filterNot { it.second }).distinctBy { it.first }
        val explanation = if (draft.explanation.isBlank()) LocalizedText.Empty else textOf(draft.explanation)
        QuizQuestion(textOf(draft.text), answers.map { textOf(it.first) }, explanation)
    }
}

/** Text of the lesson file as a [LocalizedText]: Farsi when written in that script, else German. */
private fun textOf(text: String) = LocalizedText(mapOf((if (rightToLeftScript.containsMatchIn(text)) "fa" else "de") to text))

/** Whether [text] contains letters written right to left, such as Farsi or Pashto. */
fun hasRightToLeftScript(text: String): Boolean = rightToLeftScript.containsMatchIn(text)
