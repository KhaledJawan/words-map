package dev.nefrin.wordsmap.ui.library

import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.graphics.Color
import dev.nefrin.wordsmap.data.LibraryItem
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_badge_article
import dev.nefrin.wordsmap.resources.ic_badge_book
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource

/** The two libraries of the Lessons tab. They share their screens and differ in wording and color. */
enum class LibraryKind(private val completionPrefix: String, val icon: DrawableResource) {
    GRAMMAR("grammar:", Res.drawable.ic_badge_book),
    TEXTS("text:", Res.drawable.ic_badge_article);

    /** Key under which a finished [item] is remembered. */
    fun completionKey(item: LibraryItem): String = completionPrefix + item.id

    /** Top bar and card color. */
    val color: Color
        get() = when (this) {
            GRAMMAR -> Palette.GrammarIndigo
            TEXTS -> Palette.TextsTeal
        }
}

/** Color for text and small marks on the page background. */
val LibraryKind.accent: Color
    @Composable @ReadOnlyComposable get() = when (this) {
        LibraryKind.GRAMMAR -> appColors.grammarAccent
        LibraryKind.TEXTS -> appColors.textsAccent
    }

@Composable
@ReadOnlyComposable
fun LibraryKind.title(): String = stringResource(if (this == LibraryKind.GRAMMAR) Strings.grammar_title else Strings.texts_title)

@Composable
@ReadOnlyComposable
fun LibraryKind.chapterTitle(level: String): String =
    stringResource(if (this == LibraryKind.GRAMMAR) Strings.grammar_level else Strings.texts_level, level)

/** "No lessons yet", "1 lesson" or "5 lessons"; texts are counted the same way. */
@Composable
@ReadOnlyComposable
fun LibraryKind.countLabel(count: Int): String {
    val grammar = this == LibraryKind.GRAMMAR
    return when (count) {
        0 -> stringResource(if (grammar) Strings.grammar_lessons_none else Strings.texts_none)
        1 -> stringResource(if (grammar) Strings.grammar_lessons_one else Strings.texts_one)
        else -> stringResource(if (grammar) Strings.grammar_lessons_count else Strings.texts_count, count.toString())
    }
}

@Composable
@ReadOnlyComposable
fun LibraryKind.searchHint(): String =
    stringResource(if (this == LibraryKind.GRAMMAR) Strings.grammar_search_hint else Strings.texts_search_hint)

@Composable
@ReadOnlyComposable
fun LibraryKind.noResults(): String =
    stringResource(if (this == LibraryKind.GRAMMAR) Strings.grammar_no_results else Strings.texts_no_results)

@Composable
@ReadOnlyComposable
fun LibraryKind.quizTitle(): String =
    stringResource(if (this == LibraryKind.GRAMMAR) Strings.quiz_title_grammar else Strings.quiz_title_text)
