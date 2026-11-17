package dev.nefrin.wordsmap.ui.grammar

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.GrammarLesson
import dev.nefrin.wordsmap.data.LessonDocument
import dev.nefrin.wordsmap.data.parseLessonMarkdown
import dev.nefrin.wordsmap.platform.Log
import dev.nefrin.wordsmap.resources.AppAssets
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ColorTopBar
import dev.nefrin.wordsmap.ui.components.ContentBlock
import dev.nefrin.wordsmap.ui.components.ContentDirection
import dev.nefrin.wordsmap.ui.components.SectionTitle
import dev.nefrin.wordsmap.ui.components.directionFor
import dev.nefrin.wordsmap.ui.components.emphasized
import dev.nefrin.wordsmap.ui.components.paragraphsOf
import dev.nefrin.wordsmap.ui.library.LibraryKind
import dev.nefrin.wordsmap.ui.library.MarkLearnedButton
import dev.nefrin.wordsmap.ui.library.QuizSection
import dev.nefrin.wordsmap.ui.library.accent
import dev.nefrin.wordsmap.ui.library.quizTitle
import dev.nefrin.wordsmap.ui.theme.appColors
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.withContext

/**
 * One grammar lesson: cover photo, title, short description, the full description, the
 * examples, and at the end the questions that mark it learned.
 */
@Composable
fun GrammarLessonScreen(
    lesson: GrammarLesson,
    language: AppLanguage,
    learned: Boolean,
    onLearned: () -> Unit,
    onBack: () -> Unit,
) {
    val kind = LibraryKind.GRAMMAR
    Column(Modifier.fillMaxSize()) {
        val title = lesson.title.resolveOrAny(language)
        val topic = lesson.topic.resolveOrAny(language)
        val document = rememberLessonDocument(lesson, language)
        val description = lesson.description.resolveOrAny(language)
        val paragraphs = remember(lesson, language) { paragraphsOf(lesson.fullDescription.resolveOrAny(language)) }
        val strong = SpanStyle(fontWeight = FontWeight.Bold, color = appColors.heading)
        val highlight = SpanStyle(color = kind.accent)
        // The topic is the short name of the lesson; the book's title can be a whole sentence.
        ColorTopBar(topic.ifEmpty { title }, kind.color, onBack)
        ContentDirection(if (lesson.content.isEmpty) lesson.fullDescription else lesson.content, language) {
            LazyColumn(
                modifier = Modifier.fillMaxSize().windowInsetsPadding(WindowInsets.navigationBars),
                contentPadding = PaddingValues(16.dp),
            ) {
                item {
                    GrammarCover(lesson, Modifier.fillMaxWidth().aspectRatio(16f / 9f).clip(RoundedCornerShape(22.dp)))
                    Spacer(Modifier.height(16.dp))
                    // As in the book: the number and title, then the topic in the accent color.
                    Text(
                        text = buildAnnotatedString {
                            lesson.number?.let { withStyle(SpanStyle(color = kind.accent)) { append("$it  ") } }
                            append(title)
                        },
                        modifier = Modifier.fillMaxWidth(),
                        color = appColors.heading,
                        style = MaterialTheme.typography.headlineSmall.copy(
                            fontWeight = FontWeight.Bold,
                            textDirection = lesson.title.directionFor(language),
                        ),
                    )
                    if (topic.isNotEmpty()) {
                        Spacer(Modifier.height(4.dp))
                        Text(
                            text = topic,
                            modifier = Modifier.fillMaxWidth(),
                            color = kind.accent,
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontWeight = FontWeight.SemiBold,
                                textDirection = lesson.topic.directionFor(language),
                            ),
                        )
                    }
                    // The topic in the reader's language, from the first line of the lesson text.
                    document?.heading?.let { heading ->
                        Spacer(Modifier.height(2.dp))
                        Text(
                            text = heading,
                            modifier = Modifier.fillMaxWidth(),
                            color = appColors.textMuted,
                            style = MaterialTheme.typography.bodyLarge.copy(textDirection = lesson.content.directionFor(language)),
                        )
                    }
                    if (description.isNotEmpty()) {
                        Spacer(Modifier.height(6.dp))
                        Text(
                            text = description,
                            modifier = Modifier.fillMaxWidth(),
                            color = appColors.textMuted,
                            style = MaterialTheme.typography.bodyLarge.copy(
                                textDirection = lesson.description.directionFor(language),
                            ),
                        )
                    }
                    Spacer(Modifier.height(16.dp))
                }
                if (paragraphs.isNotEmpty()) {
                    item {
                        ContentBlock {
                            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                                val direction = lesson.fullDescription.directionFor(language)
                                for (paragraph in paragraphs) {
                                    Text(
                                        text = emphasized(paragraph, strong),
                                        modifier = Modifier.fillMaxWidth(),
                                        style = MaterialTheme.typography.bodyMedium.copy(textDirection = direction),
                                    )
                                }
                            }
                        }
                        Spacer(Modifier.height(18.dp))
                    }
                }
                if (lesson.examples.isNotEmpty()) {
                    item {
                        SectionTitle(stringResource(Strings.lesson_examples))
                        Spacer(Modifier.height(10.dp))
                    }
                    items(lesson.examples) { example ->
                        val german = example.textIn(AppLanguage.DE).ifEmpty { example.resolveOrAny(language) }
                        val translation = if (language == AppLanguage.DE) "" else example.resolve(language)
                        ContentBlock(Modifier.padding(bottom = 12.dp)) {
                            Text(
                                text = emphasized(german, highlight),
                                modifier = Modifier.fillMaxWidth(),
                                color = appColors.heading,
                                style = MaterialTheme.typography.bodyLarge.copy(
                                    fontWeight = FontWeight.SemiBold,
                                    textDirection = TextDirection.Ltr,
                                ),
                            )
                            if (translation.isNotEmpty() && translation != german) {
                                Spacer(Modifier.height(4.dp))
                                Text(
                                    text = emphasized(translation, highlight),
                                    modifier = Modifier.fillMaxWidth(),
                                    color = appColors.textMuted,
                                    style = MaterialTheme.typography.bodyMedium.copy(
                                        textDirection = example.directionFor(language),
                                    ),
                                )
                            }
                        }
                    }
                }
                items(document?.blocks.orEmpty()) { block ->
                    LessonBlockView(block, kind.accent, Modifier.padding(bottom = 14.dp))
                }
                // Nothing is offered while the lesson text is still being read.
                if (document != null) {
                    item {
                        Spacer(Modifier.height(6.dp))
                        val questions = document.questions.ifEmpty { lesson.questions }
                        if (questions.isNotEmpty()) {
                            QuizSection(questions, language, kind.quizTitle(), kind.color, onPassed = onLearned)
                        } else {
                            MarkLearnedButton(learned, kind.color, onClick = onLearned)
                        }
                    }
                }
            }
        }
    }
}

private val NoDocument = LessonDocument(heading = null, blocks = emptyList(), questions = emptyList())

/**
 * The lesson's Markdown text in [language] (or the language it falls back to), read off the
 * main thread. Null while it is being read; empty when the lesson has no such file.
 */
@Composable
private fun rememberLessonDocument(lesson: GrammarLesson, language: AppLanguage): LessonDocument? {
    val path = lesson.content.resolveOrAny(language).ifEmpty { null }
    val document by produceState<LessonDocument?>(initialValue = if (path == null) NoDocument else null, path) {
        if (path == null) return@produceState
        value = withContext(Dispatchers.IO) {
            try {
                parseLessonMarkdown(AppAssets.readText(path))
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                Log.w("GrammarLessonScreen", "Could not read $path", error)
                NoDocument
            }
        }
    }
    return document
}
