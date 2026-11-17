package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class LessonMarkdownTest {
    private val lesson = parseLessonMarkdown(
        """
        # ضمایر شخصی در آلمانی

        **Personalpronomen** کلماتی هستند که به‌جای اسم استفاده می‌شوند.

        ## ۱. ضمایر شخصی

        | آلمانی | فارسی | مثال |
        | --- | --- | --- |
        | ich | من | Ich lerne. |
        | du | تو |

        - `du`: صحبت با یک دوست

        - `ihr`: صحبت با چند دوست

        > [!NOTE]
        > ضمیر رسمی `Sie` همیشه با حرف بزرگ نوشته می‌شود.

        > [!EXAMPLE]
        > Peter kommt aus Berlin.
        > Er kommt aus Berlin.

        ## Quiz

        1. Maria ist Lehrerin. ___ arbeitet in Berlin.
           - [ ] Er
           - [x] Sie
           - [ ] Es
        2. Ohne richtige Antwort?
           - [ ] a
           - [ ] b

        نتیجه: 0 از ۴

        > [!SUMMARY]
        > خلاصه درس.
        """.trimIndent(),
    )

    @Test
    fun `the first line is the heading and the text is split into blocks`() {
        assertEquals("ضمایر شخصی در آلمانی", lesson.heading)
        val kinds = lesson.blocks.map { it::class.simpleName }
        assertEquals(listOf("Paragraph", "Heading", "Table", "Bullets", "Callout", "Callout", "Callout"), kinds)
    }

    @Test
    fun `tables drop the separator row and fill short rows`() {
        val table = lesson.blocks.filterIsInstance<LessonBlock.Table>().single()
        assertEquals(listOf("آلمانی", "فارسی", "مثال"), table.header)
        assertEquals(listOf(listOf("ich", "من", "Ich lerne."), listOf("du", "تو", "")), table.rows)
    }

    @Test
    fun `list items with empty lines between them form one list`() {
        val list = lesson.blocks.filterIsInstance<LessonBlock.Bullets>().single()
        assertEquals(listOf("`du`: صحبت با یک دوست", "`ihr`: صحبت با چند دوست"), list.items)
    }

    @Test
    fun `cards keep their kind, and a card after the quiz still belongs to the lesson`() {
        val cards = lesson.blocks.filterIsInstance<LessonBlock.Callout>()
        assertEquals(listOf(CalloutKind.NOTE, CalloutKind.EXAMPLE, CalloutKind.SUMMARY), cards.map { it.kind })
        assertEquals(LessonBlock.Paragraph("Peter kommt aus Berlin.\nEr kommt aus Berlin."), cards[1].blocks.single())
    }

    @Test
    fun `quiz questions put the right answer first and skip questions without one`() {
        val question = lesson.questions.single()
        assertEquals("Maria ist Lehrerin. ___ arbeitet in Berlin.", question.question.resolveOrAny(AppLanguage.EN))
        assertEquals(listOf("Sie", "Er", "Es"), question.answers.map { it.resolveOrAny(AppLanguage.EN) })
    }

    @Test
    fun `questions can also be written with question marks, stars and explanations`() {
        val quiz = parseLessonMarkdown(
            """
            ## Quiz

            ? Maria ist Lehrerin. ___ arbeitet in Berlin.
            - Er
            * Sie
            - Es
            ! Maria اسم مونث است؛ بنابراین از `sie` استفاده می‌کنیم.

            ? Ohne Erklärung?
            * ja
            - nein

            > [!SUMMARY]
            > Zusammenfassung
            """.trimIndent(),
        )
        assertEquals(2, quiz.questions.size)
        val first = quiz.questions.first()
        assertEquals(listOf("Sie", "Er", "Es"), first.answers.map { it.resolveOrAny(AppLanguage.EN) })
        assertEquals("Maria اسم مونث است؛ بنابراین از `sie` استفاده می‌کنیم.", first.explanation.resolveOrAny(AppLanguage.FA))
        assertTrue(quiz.questions.last().explanation.isEmpty)
        assertEquals(CalloutKind.SUMMARY, (quiz.blocks.single() as LessonBlock.Callout).kind)
    }

    @Test
    fun `cards with empty lines between their lines and questions in numbered headings are understood`() {
        val lesson = parseLessonMarkdown(
            """
            > [!RULE]

            > Regel

            > [!EXAMPLE]

            > **Ich stehe auf.**

            > من بلند می‌شوم.

            ## Quiz

            ### 1. Welche Form ist richtig?

            - Ich aufstehe.

            * Ich stehe auf.

            ! `aufstehen` ist trennbar.

            ### 2. Noch eine?

            * ja

            - nein
            """.trimIndent(),
        )
        val cards = lesson.blocks.map { it as LessonBlock.Callout }
        assertEquals(listOf(CalloutKind.RULE, CalloutKind.EXAMPLE), cards.map { it.kind })
        assertEquals(listOf(LessonBlock.Paragraph("Regel")), cards[0].blocks)
        assertEquals(2, cards[1].blocks.size)
        assertEquals(listOf("Welche Form ist richtig?", "Noch eine?"), lesson.questions.map { it.question.resolveOrAny(AppLanguage.EN) })
        assertEquals("Ich stehe auf.", lesson.questions[0].answers[0].resolveOrAny(AppLanguage.EN))
    }

    @Test
    fun `an unknown card kind becomes a note and plain quotes are notes too`() {
        val blocks = parseLessonMarkdown("> [!FUNNY]\n> Hallo\n\n## Weiter\n\n> Nur ein Zitat").blocks.filterIsInstance<LessonBlock.Callout>()
        assertEquals(listOf(CalloutKind.NOTE, CalloutKind.NOTE), blocks.map { it.kind })
        assertTrue(hasRightToLeftScript("سلام Welt"))
    }
}
