package dev.nefrin.wordsmap.ui.lessons

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.data.AlphabetLesson
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.LessonExplanation
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_chevron_small
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.AppBottomSheet
import dev.nefrin.wordsmap.ui.components.ColorTopBar
import dev.nefrin.wordsmap.ui.components.ContentBlock
import dev.nefrin.wordsmap.ui.components.ContentDirection
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.SectionTitle
import dev.nefrin.wordsmap.ui.components.close
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.painterResource

/** What the sheet of one tapped letter shows. */
private class LetterInfo(val title: String, val subtitle: String, val detail: String, val examples: List<String>)

@Composable
fun AlphabetLessonScreen(lesson: AlphabetLesson, vocabulary: Vocabulary, viewModel: AppViewModel, onBack: () -> Unit) {
    val language = viewModel.targetLanguage
    var openLetter by remember { mutableStateOf<LetterInfo?>(null) }
    val muted = appColors.textMuted

    Column(Modifier.fillMaxSize()) {
        ColorTopBar(
            title = lesson.title.resolve(language).ifEmpty { stringResource(Strings.lesson_alphabet) },
            color = MaterialTheme.colorScheme.primary,
            onBack = onBack,
        )
        ContentDirection(lesson.title, language) {
            LazyColumn(
                modifier = Modifier.fillMaxSize().windowInsetsPadding(WindowInsets.navigationBars),
                contentPadding = PaddingValues(16.dp),
            ) {
                explanations(lesson.explanations, language)
                if (lesson.letters.isNotEmpty()) {
                    item {
                        SectionTitle(stringResource(Strings.lesson_letters))
                        Spacer(Modifier.height(8.dp))
                        val note = lesson.note.resolve(language)
                        if (note.isNotEmpty()) {
                            Text(
                                text = note,
                                modifier = Modifier.padding(bottom = 10.dp),
                                color = muted,
                                style = MaterialTheme.typography.bodySmall,
                            )
                        }
                    }
                    items(lesson.letters.chunked(4)) { row ->
                        // Letters read left to right, whatever language explains them.
                        ProvideDirection(LayoutDirection.Ltr) {
                            Row(
                                modifier = Modifier.padding(bottom = 10.dp),
                                horizontalArrangement = Arrangement.spacedBy(10.dp),
                            ) {
                                for (letter in row) {
                                    Column(
                                        modifier = Modifier
                                            .weight(1f)
                                            .aspectRatio(1.05f)
                                            .clip(RoundedCornerShape(16.dp))
                                            .background(MaterialTheme.colorScheme.surface)
                                            .clickable {
                                                openLetter = LetterInfo(
                                                    title = if (letter.lower.isEmpty()) letter.upper else "${letter.upper} / ${letter.lower}",
                                                    subtitle = letter.name,
                                                    detail = letter.hint.resolve(language),
                                                    examples = letter.examples,
                                                )
                                            }
                                            .padding(10.dp),
                                        horizontalAlignment = Alignment.CenterHorizontally,
                                        verticalArrangement = Arrangement.Center,
                                    ) {
                                        Text(
                                            text = letter.upper,
                                            color = appColors.heading,
                                            style = MaterialTheme.typography.titleLarge.copy(
                                                fontWeight = FontWeight.Black,
                                                textDirection = TextDirection.Ltr,
                                            ),
                                        )
                                        if (letter.lower.isNotEmpty()) {
                                            Text(
                                                text = letter.lower,
                                                color = muted,
                                                style = MaterialTheme.typography.bodyMedium.copy(textDirection = TextDirection.Ltr),
                                            )
                                        }
                                    }
                                }
                                repeat(4 - row.size) { Spacer(Modifier.weight(1f)) }
                            }
                        }
                    }
                }
                if (lesson.specialLetters.isNotEmpty()) {
                    item {
                        Spacer(Modifier.height(8.dp))
                        SectionTitle(stringResource(Strings.lesson_special_letters))
                        Spacer(Modifier.height(10.dp))
                    }
                    items(lesson.specialLetters) { letter ->
                        val hint = letter.hint.resolve(language)
                        val description = letter.description.resolve(language)
                        ContentBlock(
                            modifier = Modifier.padding(bottom = 12.dp),
                            onClick = {
                                openLetter = LetterInfo(
                                    title = letter.symbol,
                                    subtitle = letter.name,
                                    detail = listOf(hint, description).filter { it.isNotEmpty() }.joinToString("\n\n"),
                                    examples = emptyList(),
                                )
                            },
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                val primary = MaterialTheme.colorScheme.primary
                                Box(
                                    modifier = Modifier
                                        .size(46.dp)
                                        .background(primary.copy(alpha = 0.12f), RoundedCornerShape(14.dp)),
                                    contentAlignment = Alignment.Center,
                                ) {
                                    Text(
                                        text = letter.symbol,
                                        color = primary,
                                        style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Black),
                                    )
                                }
                                Spacer(Modifier.width(12.dp))
                                Column(Modifier.weight(1f)) {
                                    Text(
                                        text = letter.name.ifEmpty { letter.symbol },
                                        color = appColors.heading,
                                        style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.ExtraBold),
                                    )
                                    val summary = hint.ifEmpty { description }
                                    if (summary.isNotEmpty()) {
                                        Spacer(Modifier.height(4.dp))
                                        Text(
                                            text = summary,
                                            color = muted,
                                            style = MaterialTheme.typography.bodySmall,
                                            maxLines = 2,
                                            overflow = TextOverflow.Ellipsis,
                                        )
                                    }
                                }
                                Icon(painterResource(Res.drawable.ic_chevron_small), null, tint = muted.copy(alpha = muted.alpha * 0.8f))
                            }
                        }
                    }
                }
                item {
                    Spacer(Modifier.height(16.dp))
                    CompleteButton(enabled = lesson.id.isNotEmpty()) {
                        viewModel.completeLesson(lesson.id)
                        onBack()
                    }
                }
            }
        }
    }

    openLetter?.let { letter ->
        AppBottomSheet(onDismiss = { openLetter = null }) { sheet ->
            ContentDirection(lesson.title, language) {
                Column(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 16.dp)) {
                    Text(
                        text = letter.title,
                        color = appColors.heading,
                        style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.ExtraBold),
                    )
                    if (letter.subtitle.isNotEmpty()) {
                        Spacer(Modifier.height(6.dp))
                        Text(letter.subtitle, color = muted, style = MaterialTheme.typography.bodyMedium)
                    }
                    if (letter.detail.isNotEmpty()) {
                        Spacer(Modifier.height(12.dp))
                        Text(letter.detail, style = MaterialTheme.typography.bodyMedium)
                    }
                    if (letter.examples.isNotEmpty()) {
                        Spacer(Modifier.height(14.dp))
                        LessonWordChips(letter.examples, vocabulary, viewModel)
                    }
                    Spacer(Modifier.height(12.dp))
                    TextButton(onClick = { sheet.close() }, modifier = Modifier.align(Alignment.End)) {
                        Text(stringResource(Strings.common_close))
                    }
                }
            }
        }
    }
}

/** The "Overview" section shared by the alphabet and the combinations lesson. */
internal fun LazyListScope.explanations(
    explanations: List<LessonExplanation>,
    language: AppLanguage,
) {
    if (explanations.isEmpty()) return
    item {
        SectionTitle(stringResource(Strings.lesson_overview))
        Spacer(Modifier.height(10.dp))
    }
    items(explanations) { block ->
        val title = block.title.resolve(language)
        val text = block.text.resolve(language)
        ContentBlock(Modifier.padding(bottom = 12.dp)) {
            if (title.isNotEmpty()) {
                Text(
                    text = title,
                    color = appColors.heading,
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.ExtraBold),
                )
            }
            if (text.isNotEmpty()) {
                if (title.isNotEmpty()) Spacer(Modifier.height(8.dp))
                Text(text, style = MaterialTheme.typography.bodyMedium)
            }
        }
    }
    item { Spacer(Modifier.height(6.dp)) }
}

/** Full-width button that ends a lesson. */
@Composable
internal fun CompleteButton(enabled: Boolean, onClick: () -> Unit) {
    Button(onClick = onClick, enabled = enabled, modifier = Modifier.fillMaxWidth()) {
        Text(stringResource(Strings.lesson_mark_completed))
    }
}
