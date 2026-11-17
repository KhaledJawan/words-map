package dev.nefrin.wordsmap.ui.lessons

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.data.CombinationsLesson
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ColorTopBar
import dev.nefrin.wordsmap.ui.components.ContentBlock
import dev.nefrin.wordsmap.ui.components.ContentDirection
import dev.nefrin.wordsmap.ui.components.SectionTitle
import dev.nefrin.wordsmap.ui.theme.appColors

@Composable
fun CombinationsLessonScreen(
    lesson: CombinationsLesson,
    vocabulary: Vocabulary,
    viewModel: AppViewModel,
    onBack: () -> Unit,
) {
    val language = viewModel.targetLanguage
    Column(Modifier.fillMaxSize()) {
        val accent = MaterialTheme.colorScheme.secondary
        ColorTopBar(
            title = lesson.title.resolve(language).ifEmpty { stringResource(Strings.lesson_combinations) },
            color = accent,
            onBack = onBack,
        )
        ContentDirection(lesson.title, language) {
            LazyColumn(
                modifier = Modifier.fillMaxSize().windowInsetsPadding(WindowInsets.navigationBars),
                contentPadding = PaddingValues(16.dp),
            ) {
                explanations(lesson.explanations, language)
                if (lesson.rules.isNotEmpty()) {
                    item {
                        SectionTitle(stringResource(Strings.lesson_combinations))
                        Spacer(Modifier.height(10.dp))
                    }
                    items(lesson.rules) { rule ->
                        val description = rule.description.resolve(language)
                        ContentBlock(Modifier.padding(bottom = 12.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(
                                    modifier = Modifier
                                        .size(44.dp)
                                        .background(accent.copy(alpha = 0.12f), RoundedCornerShape(14.dp)),
                                    contentAlignment = Alignment.Center,
                                ) {
                                    Text(
                                        text = rule.badge,
                                        color = accent,
                                        style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Black),
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis,
                                    )
                                }
                                Spacer(Modifier.width(12.dp))
                                Text(
                                    text = rule.title.resolve(language).ifEmpty { rule.id },
                                    modifier = Modifier.weight(1f),
                                    color = appColors.heading,
                                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Black),
                                )
                            }
                            if (description.isNotEmpty()) {
                                Spacer(Modifier.height(10.dp))
                                Text(description, style = MaterialTheme.typography.bodyMedium)
                            }
                            if (rule.examples.isNotEmpty()) {
                                Spacer(Modifier.height(12.dp))
                                LessonWordChips(rule.examples, vocabulary, viewModel)
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
}
