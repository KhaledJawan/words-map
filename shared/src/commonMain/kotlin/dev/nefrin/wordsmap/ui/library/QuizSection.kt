package dev.nefrin.wordsmap.ui.library

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.QuizQuestion
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_check
import dev.nefrin.wordsmap.resources.ic_check_circle_2
import dev.nefrin.wordsmap.resources.ic_circle
import dev.nefrin.wordsmap.resources.ic_lightbulb
import dev.nefrin.wordsmap.resources.ic_x
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ContentBlock
import dev.nefrin.wordsmap.ui.components.PillButton
import dev.nefrin.wordsmap.ui.components.directionFor
import dev.nefrin.wordsmap.ui.components.lessonText
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.painterResource
import kotlin.random.Random

/**
 * The questions at the end of a lesson, one at a time. Each answer is checked at once.
 * Answering every question correctly calls [onPassed]; otherwise the learner can try again,
 * with the answers in a new order. The questions keep the order of the file.
 */
@Composable
fun QuizSection(
    questions: List<QuizQuestion>,
    language: AppLanguage,
    title: String,
    accent: Color,
    onPassed: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val seed = rememberSaveable { Random.nextLong() }
    var attempt by rememberSaveable { mutableIntStateOf(0) }
    var current by rememberSaveable { mutableIntStateOf(0) }
    // The answer picked for each question, as its index in the file; -1 while unanswered.
    var picks by rememberSaveable { mutableStateOf(IntArray(questions.size) { -1 }) }
    var finished by rememberSaveable { mutableStateOf(false) }
    val correctCount = picks.count { it == 0 }
    val passed = finished && correctCount == questions.size

    LaunchedEffect(passed) { if (passed) onPassed() }

    ContentBlock(modifier) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = title,
                modifier = Modifier.weight(1f),
                color = appColors.textMuted,
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
            )
            Text(
                text = "${picks.count { it >= 0 }} / ${questions.size}",
                color = appColors.textMuted,
                style = MaterialTheme.typography.labelLarge,
            )
        }
        Spacer(Modifier.height(10.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            for (pick in picks) {
                val color = when (pick) {
                    -1 -> appColors.divider
                    0 -> Palette.Success
                    else -> Palette.Failure
                }
                Box(Modifier.weight(1f).height(4.dp).background(color, CircleShape))
            }
        }
        Spacer(Modifier.height(16.dp))

        if (!finished) {
            val question = questions[current]
            // A new order for every attempt, but a stable one while the question is on screen.
            val order = remember(seed, attempt, current) {
                question.answers.indices.shuffled(Random(seed + attempt * 7919L + current))
            }
            val pick = picks[current]
            Text(
                // German words in `backticks` stand out in the accent color, as in the lesson text.
                text = lessonText(
                    question.question.resolveOrAny(language),
                    strong = SpanStyle(fontWeight = FontWeight.Black),
                    code = SpanStyle(color = accent),
                ),
                modifier = Modifier.fillMaxWidth(),
                color = appColors.heading,
                style = MaterialTheme.typography.titleMedium.copy(
                    fontWeight = FontWeight.ExtraBold,
                    textDirection = question.question.directionFor(language),
                ),
            )
            Spacer(Modifier.height(12.dp))
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                order.forEachIndexed { position, answerIndex ->
                    AnswerRow(
                        letter = 'a' + position,
                        text = question.answers[answerIndex].resolveOrAny(language),
                        textDirection = question.answers[answerIndex].directionFor(language),
                        state = when {
                            pick == -1 -> AnswerState.OPEN
                            answerIndex == 0 -> AnswerState.CORRECT
                            answerIndex == pick -> AnswerState.WRONG
                            else -> AnswerState.OTHER
                        },
                        onClick = { picks = picks.copyOf().also { it[current] = answerIndex } },
                    )
                }
            }
            if (pick >= 0) {
                val explanation = question.explanation.resolveOrAny(language)
                if (explanation.isNotEmpty()) {
                    Spacer(Modifier.height(12.dp))
                    Explanation(explanation, question.explanation.directionFor(language), correct = pick == 0)
                }
                Spacer(Modifier.height(14.dp))
                val last = current == questions.lastIndex
                PillButton(
                    text = stringResource(if (last) Strings.quiz_finish else Strings.quiz_next),
                    background = accent,
                    contentColor = Color.White,
                    onClick = { if (last) finished = true else current++ },
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        } else {
            Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
                Icon(
                    painter = painterResource(if (passed) Res.drawable.ic_check_circle_2 else Res.drawable.ic_circle),
                    contentDescription = null,
                    modifier = Modifier.size(40.dp),
                    tint = if (passed) Palette.Success else Palette.Failure,
                )
                Spacer(Modifier.height(10.dp))
                Text(
                    text = if (passed) {
                        stringResource(Strings.quiz_passed)
                    } else {
                        stringResource(Strings.quiz_failed, correctCount.toString(), questions.size.toString())
                    },
                    color = appColors.heading,
                    style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold),
                    textAlign = TextAlign.Center,
                )
                if (!passed) {
                    Spacer(Modifier.height(14.dp))
                    PillButton(
                        text = stringResource(Strings.quiz_retry),
                        background = accent,
                        contentColor = Color.White,
                        onClick = {
                            attempt++
                            current = 0
                            picks = IntArray(questions.size) { -1 }
                            finished = false
                        },
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            }
        }
    }
}

private enum class AnswerState { OPEN, CORRECT, WRONG, OTHER }

@Composable
private fun AnswerRow(
    letter: Char,
    text: String,
    textDirection: TextDirection,
    state: AnswerState,
    onClick: () -> Unit,
) {
    val shape = RoundedCornerShape(16.dp)
    val tint = when (state) {
        AnswerState.CORRECT -> Palette.Success
        AnswerState.WRONG -> Palette.Failure
        else -> null
    }
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .alpha(if (state == AnswerState.OTHER) 0.55f else 1f)
            .clip(shape)
            .background(tint?.copy(alpha = 0.12f) ?: MaterialTheme.colorScheme.surface)
            .border(1.dp, tint ?: appColors.divider, shape)
            .clickable(enabled = state == AnswerState.OPEN, onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier.size(32.dp).background(tint ?: appColors.divider.copy(alpha = 0.6f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            when (state) {
                AnswerState.CORRECT -> Icon(painterResource(Res.drawable.ic_check), null, Modifier.size(18.dp), tint = Color.White)
                AnswerState.WRONG -> Icon(painterResource(Res.drawable.ic_x), null, Modifier.size(18.dp), tint = Color.White)
                else -> Text(letter.toString(), color = appColors.textMuted, style = MaterialTheme.typography.labelLarge)
            }
        }
        Spacer(Modifier.width(12.dp))
        Text(
            // Answers are often German throughout, so `backticks` only keep their word order, without a highlight.
            text = lessonText(text, strong = SpanStyle(fontWeight = FontWeight.Bold), code = SpanStyle()),
            modifier = Modifier.weight(1f),
            color = appColors.heading,
            style = MaterialTheme.typography.bodyLarge.copy(textDirection = textDirection),
        )
    }
}

/** For a lesson without questions: marks it learned by hand. */
@Composable
fun MarkLearnedButton(learned: Boolean, accent: Color, onClick: () -> Unit, modifier: Modifier = Modifier) {
    PillButton(
        text = stringResource(if (learned) Strings.lesson_learned else Strings.lesson_mark_completed),
        icon = if (learned) Res.drawable.ic_check else null,
        background = if (learned) Palette.Success else accent,
        contentColor = Color.White,
        onClick = { if (!learned) onClick() },
        modifier = modifier.fillMaxWidth(),
    )
}

/** Why the right answer is right; green after a right answer, red after a wrong one. */
@Composable
private fun Explanation(text: String, direction: TextDirection, correct: Boolean) {
    val color = if (correct) Palette.Success else Palette.Failure
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(color.copy(alpha = if (appColors.isDark) 0.18f else 0.09f))
            .padding(12.dp),
    ) {
        Icon(painterResource(Res.drawable.ic_lightbulb), contentDescription = null, modifier = Modifier.size(18.dp), tint = color)
        Spacer(Modifier.width(10.dp))
        Text(
            text = lessonText(
                text,
                strong = SpanStyle(fontWeight = FontWeight.Bold, color = appColors.heading),
                code = SpanStyle(fontWeight = FontWeight.SemiBold, color = color),
            ),
            modifier = Modifier.weight(1f),
            color = appColors.text,
            style = MaterialTheme.typography.bodyMedium.copy(textDirection = direction),
        )
    }
}
