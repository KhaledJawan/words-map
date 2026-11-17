package dev.nefrin.wordsmap.ui.texts

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.GermanWordIndex
import dev.nefrin.wordsmap.data.ReadingText
import dev.nefrin.wordsmap.data.Word
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_check
import dev.nefrin.wordsmap.resources.ic_highlighter
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ColorTopBar
import dev.nefrin.wordsmap.ui.components.ContentBlock
import dev.nefrin.wordsmap.ui.components.ContentDirection
import dev.nefrin.wordsmap.ui.components.WordDetailOverlay
import dev.nefrin.wordsmap.ui.components.directionFor
import dev.nefrin.wordsmap.ui.components.paragraphsOf
import dev.nefrin.wordsmap.ui.components.toDetail
import dev.nefrin.wordsmap.ui.library.LibraryKind
import dev.nefrin.wordsmap.ui.library.MarkLearnedButton
import dev.nefrin.wordsmap.ui.library.QuizSection
import dev.nefrin.wordsmap.ui.library.quizTitle
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.painterResource

/**
 * A reading text, followed by the questions that mark it done. Words of the vocabulary can
 * be tapped and open the same word card as the Home screen; with [highlightWords] they are
 * marked, so the reader sees which ones have a translation.
 */
@Composable
fun ReadingTextScreen(
    text: ReadingText,
    language: AppLanguage,
    wordIndex: GermanWordIndex,
    bookmarkedIds: Set<String>,
    onToggleBookmark: (Word) -> Unit,
    highlightWords: Boolean,
    onToggleHighlight: () -> Unit,
    learned: Boolean,
    onLearned: () -> Unit,
    onBack: () -> Unit,
) {
    val kind = LibraryKind.TEXTS
    // The word whose card is open, and where it stands in the text.
    var openWord by remember { mutableStateOf<Pair<Word, Pair<Int, TextSpan>>?>(null) }
    Box(Modifier.fillMaxSize()) {
        val title = text.title.resolveOrAny(language)
        val description = text.description.resolveOrAny(language)
        val paragraphs = remember(text, language) { paragraphsOf(text.text.resolveOrAny(language)) }
        Column(Modifier.fillMaxSize()) {
            ColorTopBar(title, kind.color, onBack)
            ContentDirection(text.text, language) {
                LazyColumn(
                    modifier = Modifier.fillMaxSize().windowInsetsPadding(WindowInsets.navigationBars),
                    contentPadding = PaddingValues(16.dp),
                ) {
                    item {
                        Text(
                            text = title,
                            modifier = Modifier.fillMaxWidth(),
                            color = appColors.heading,
                            style = MaterialTheme.typography.headlineSmall.copy(
                                fontWeight = FontWeight.Bold,
                                textDirection = text.title.directionFor(language),
                            ),
                        )
                        if (description.isNotEmpty()) {
                            Spacer(Modifier.height(6.dp))
                            Text(
                                text = description,
                                modifier = Modifier.fillMaxWidth(),
                                color = appColors.textMuted,
                                style = MaterialTheme.typography.bodyLarge.copy(
                                    textDirection = text.description.directionFor(language),
                                ),
                            )
                        }
                        Spacer(Modifier.height(12.dp))
                        if (paragraphs.isNotEmpty()) {
                            HighlightToggle(on = highlightWords, accent = kind.color, onToggle = onToggleHighlight)
                            Spacer(Modifier.height(12.dp))
                        }
                    }
                    if (paragraphs.isNotEmpty()) {
                        item {
                            ContentBlock {
                                Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                                    val direction = text.text.directionFor(language)
                                    // Longer reading: a little larger and more open than lesson text.
                                    val readingStyle = MaterialTheme.typography.bodyLarge.copy(
                                        fontSize = 17.sp,
                                        lineHeight = 28.sp,
                                        textDirection = direction,
                                    )
                                    paragraphs.forEachIndexed { paragraphIndex, paragraph ->
                                        TappableParagraph(
                                            paragraph = paragraph,
                                            index = wordIndex,
                                            style = readingStyle,
                                            color = appColors.heading,
                                            // Soft enough to keep the text easy to read; stronger for the open word.
                                            mark = if (highlightWords) kind.color.copy(alpha = if (appColors.isDark) 0.22f else 0.12f) else Color.Transparent,
                                            highlight = kind.color.copy(alpha = if (appColors.isDark) 0.5f else 0.32f),
                                            selected = openWord?.second?.takeIf { it.first == paragraphIndex }?.second,
                                            onWordTap = { word, span -> openWord = word to (paragraphIndex to span) },
                                            modifier = Modifier.fillMaxWidth(),
                                        )
                                    }
                                }
                            }
                            Spacer(Modifier.height(18.dp))
                        }
                    }
                    item {
                        if (text.questions.isNotEmpty()) {
                            // The questions can be in another language than the German text.
                            ContentDirection(text.questions.first().question, language) {
                                QuizSection(text.questions, language, kind.quizTitle(), kind.color, onPassed = onLearned)
                            }
                        } else {
                            MarkLearnedButton(learned, kind.color, onClick = onLearned)
                        }
                    }
                }
            }
        }

        openWord?.let { (word, _) ->
            // The texts are German, so the card shows the German word whatever the word pair is.
            WordDetailOverlay(
                detail = word.toDetail(AppLanguage.DE, language),
                bookmarked = word.id in bookmarkedIds,
                onToggleBookmark = { onToggleBookmark(word) },
                onDismiss = { openWord = null },
            )
        }
    }
}

/** Turns the marks on the words that have a translation on or off. */
@Composable
private fun HighlightToggle(on: Boolean, accent: Color, onToggle: () -> Unit) {
    val content = if (on) Color.White else accent
    Row(
        modifier = Modifier
            .clip(CircleShape)
            .background(if (on) accent else accent.copy(alpha = 0.10f))
            .border(1.dp, if (on) accent else accent.copy(alpha = 0.35f), CircleShape)
            .toggleable(value = on, role = Role.Switch, onValueChange = { onToggle() })
            .padding(horizontal = 14.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(painterResource(Res.drawable.ic_highlighter), contentDescription = null, modifier = Modifier.size(18.dp), tint = content)
        Spacer(Modifier.width(8.dp))
        Text(
            text = stringResource(Strings.reading_highlight_words),
            color = content,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
        )
        if (on) {
            Spacer(Modifier.width(6.dp))
            Icon(painterResource(Res.drawable.ic_check), contentDescription = null, modifier = Modifier.size(16.dp), tint = content)
        }
    }
}
