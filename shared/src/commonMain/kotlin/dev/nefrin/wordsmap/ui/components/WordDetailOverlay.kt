package dev.nefrin.wordsmap.ui.components

import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableIntState
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.VerbTense
import dev.nefrin.wordsmap.data.Word
import dev.nefrin.wordsmap.platform.PlainDialogWindow
import dev.nefrin.wordsmap.platform.fullScreenDialogProperties
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_bookmark
import dev.nefrin.wordsmap.resources.ic_bookmark_plus
import dev.nefrin.wordsmap.resources.ic_pencil
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.theme.Palette
import org.jetbrains.compose.resources.painterResource

/** Counts the overlays that want the screen behind them blurred. The app root reads it. */
val LocalBackdropBlur = staticCompositionLocalOf<MutableIntState> { mutableIntStateOf(0) }

/** The texts of one word card, already resolved to the languages they are shown in. */
class WordDetail(
    /** Small grey line above the word, such as "A1.1 • Daily life". */
    val label: String,
    val word: String,
    val translation: String,
    val article: String? = null,
    val plural: String? = null,
    val note: String? = null,
    val example: String? = null,
    /** The conjugation of a verb; shown behind one button per tense. */
    val tenses: List<VerbTense> = emptyList(),
)

/** The card texts of [this] word for a learner of [source] who reads [target]. */
@Composable
@ReadOnlyComposable
fun Word.toDetail(source: AppLanguage, target: AppLanguage): WordDetail {
    // Article and plural describe the German word, so they only go with German text.
    val german = source == AppLanguage.DE
    return WordDetail(
        label = listOfNotNull(level, categoryLabels(categories)).joinToString(" • "),
        word = displayText(source),
        translation = translation(source, target),
        article = article.takeIf { german },
        plural = plural.takeIf { german },
        example = exampleIn(source).ifEmpty { null },
        tenses = if (german) tenses else emptyList(),
    )
}

private const val FADE_MILLIS = 220
private val rightToLeftScript = Regex("[\\u0590-\\u08FF\\uFB1D-\\uFDFD\\uFE70-\\uFEFC]")

/**
 * The word card, centred over the blurred and dimmed screen.
 *
 * @param bookmarked whether the word is bookmarked, or null to hide the bookmark button
 * @param onEdit shows a pencil button that fades the card out and then calls it; for the learner's own words
 */
@Composable
fun WordDetailOverlay(
    detail: WordDetail,
    bookmarked: Boolean?,
    onToggleBookmark: () -> Unit,
    onDismiss: () -> Unit,
    onEdit: (() -> Unit)? = null,
) {
    var visible by remember { mutableStateOf(false) }
    var editAfterwards by remember { mutableStateOf(false) }
    val progress by animateFloatAsState(
        targetValue = if (visible) 1f else 0f,
        animationSpec = tween(FADE_MILLIS),
        finishedListener = {
            if (it == 0f) {
                onDismiss()
                if (editAfterwards) onEdit?.invoke()
            }
        },
        label = "wordDetailFade",
    )
    LaunchedEffect(Unit) { visible = true }

    // The screen behind is blurred for as long as the card is fading in or shown.
    val blur = LocalBackdropBlur.current
    val blurred = visible
    DisposableEffect(blurred) {
        if (blurred) blur.intValue++
        onDispose { if (blurred) blur.intValue-- }
    }

    Dialog(
        onDismissRequest = { visible = false },
        properties = fullScreenDialogProperties(),
    ) {
        // The dialog only carries the card above bottom sheets; the dimming is drawn here.
        PlainDialogWindow()
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxSize()
                .graphicsLayer { alpha = progress }
                .background(Color.Black.copy(alpha = 0.29f))
                .clickable(interactionSource = null, indication = null) { visible = false }
                .systemBarsPadding(),
            contentAlignment = Alignment.Center,
        ) {
            Box(
                modifier = Modifier
                    .padding(horizontal = 20.dp)
                    .widthIn(max = 560.dp)
                    .heightIn(max = maxHeight * 0.82f)
                    .verticalScroll(rememberScrollState())
                    // Taps on the card must not fall through and close it.
                    .clickable(interactionSource = null, indication = null) {},
            ) {
                WordDetailCard(
                    detail = detail,
                    bookmarked = bookmarked,
                    onToggleBookmark = onToggleBookmark,
                    onEdit = onEdit?.let {
                        {
                            editAfterwards = true
                            visible = false
                        }
                    },
                )
            }
        }
    }
}

// The card is white with dark text in both themes, as in the original app.
@Composable
private fun WordDetailCard(detail: WordDetail, bookmarked: Boolean?, onToggleBookmark: () -> Unit, onEdit: (() -> Unit)?) {
    val headline = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold, color = Palette.Ink)
    ProvideDirection(LayoutDirection.Ltr) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 12.dp)
                .softShadow(SoftShadows.card, cornerRadius = 22.dp)
                .clip(RoundedCornerShape(22.dp))
                .background(Color.White)
                .animateContentSize()
                .padding(18.dp),
        ) {
            Row(verticalAlignment = Alignment.Top) {
                Text(
                    text = detail.label,
                    modifier = Modifier.weight(1f),
                    color = Palette.Grey600,
                    style = MaterialTheme.typography.labelMedium,
                )
                if (onEdit != null) {
                    Box(
                        modifier = Modifier
                            .size(28.dp)
                            .clip(CircleShape)
                            .clickable(onClick = onEdit),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(
                            painter = painterResource(Res.drawable.ic_pencil),
                            contentDescription = stringResource(Strings.common_edit),
                            modifier = Modifier.size(20.dp),
                            tint = Palette.Grey600,
                        )
                    }
                }
                if (bookmarked != null) {
                    Box(
                        modifier = Modifier
                            .size(28.dp)
                            .clip(CircleShape)
                            .clickable(onClick = onToggleBookmark),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(
                            painter = painterResource(if (bookmarked) Res.drawable.ic_bookmark else Res.drawable.ic_bookmark_plus),
                            contentDescription = stringResource(if (bookmarked) Strings.bookmark_remove else Strings.bookmark_add),
                            modifier = Modifier.size(22.dp),
                            tint = if (bookmarked) MaterialTheme.colorScheme.primary else Palette.Grey500,
                        )
                    }
                }
            }
            Spacer(Modifier.height(10.dp))
            BoxWithConstraints(Modifier.fillMaxWidth()) {
                if (maxWidth < 420.dp) {
                    Column {
                        WordText(detail, headline)
                        Spacer(Modifier.height(8.dp))
                        Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.CenterEnd) {
                            TranslationText(detail, headline)
                        }
                    }
                } else {
                    Row(verticalAlignment = Alignment.Top) {
                        Box(Modifier.weight(3f)) { WordText(detail, headline) }
                        Spacer(Modifier.width(12.dp))
                        Box(Modifier.weight(2f), contentAlignment = Alignment.TopEnd) {
                            TranslationText(detail, headline)
                        }
                    }
                }
            }
            if (!detail.plural.isNullOrBlank()) {
                Spacer(Modifier.height(8.dp))
                Text("Pl. ${detail.plural}", color = Palette.Grey600, style = MaterialTheme.typography.bodyMedium)
            }
            if (!detail.example.isNullOrBlank()) {
                Spacer(Modifier.height(12.dp))
                Text(detail.example, color = Palette.Grey700, style = MaterialTheme.typography.bodyMedium)
            }
            if (detail.tenses.isNotEmpty()) {
                Spacer(Modifier.height(14.dp))
                VerbForms(detail.tenses)
            }
        }
    }
}

/** One button per tense; a tap shows that tense's table, a second tap hides it. */
@Composable
private fun VerbForms(tenses: List<VerbTense>) {
    var open by rememberSaveable { mutableStateOf<String?>(null) }
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        for (tense in tenses) {
            val selected = tense.name == open
            Text(
                text = tense.name,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(if (selected) MaterialTheme.colorScheme.primary else Palette.Grey100)
                    .border(1.dp, if (selected) MaterialTheme.colorScheme.primary else Palette.Grey300, CircleShape)
                    .clickable { open = if (selected) null else tense.name }
                    .padding(horizontal = 12.dp, vertical = 6.dp),
                color = if (selected) Color.White else Palette.Ink,
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
            )
        }
    }
    tenses.firstOrNull { it.name == open }?.let { tense ->
        Spacer(Modifier.height(10.dp))
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(Palette.LightBackground, RoundedCornerShape(14.dp))
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
        ) {
            for ((person, form) in tense.rows) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = person,
                        modifier = Modifier.width(84.dp),
                        color = Palette.Grey600,
                        style = MaterialTheme.typography.bodyMedium,
                    )
                    Text(
                        text = form,
                        color = Palette.Ink,
                        style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold),
                    )
                }
            }
        }
    }
}

@Composable
private fun WordText(detail: WordDetail, style: TextStyle) {
    val singleToken = detail.word.isSingleToken()
    Text(
        text = buildAnnotatedString {
            if (!detail.article.isNullOrBlank()) {
                withStyle(SpanStyle(fontWeight = FontWeight.Normal, color = Palette.Grey600)) {
                    append(detail.article)
                    append(' ')
                }
            }
            append(detail.word)
        },
        style = style.copy(textDirection = detail.word.direction()),
        maxLines = if (singleToken) 1 else 2,
        softWrap = !singleToken,
        overflow = TextOverflow.Ellipsis,
    )
}

@Composable
private fun TranslationText(detail: WordDetail, style: TextStyle) {
    val singleToken = detail.translation.isSingleToken()
    Column(horizontalAlignment = Alignment.End) {
        Text(
            text = detail.translation,
            style = style.copy(textDirection = detail.translation.direction()),
            // "Start" of right-to-left text is the right edge, so both cases end up on the right.
            textAlign = if (detail.translation.isRightToLeft()) TextAlign.Start else TextAlign.End,
            maxLines = if (singleToken) 1 else 2,
            softWrap = !singleToken,
            overflow = TextOverflow.Ellipsis,
        )
        if (!detail.note.isNullOrBlank()) {
            Spacer(Modifier.height(4.dp))
            Text(
                text = detail.note,
                color = Color.Black.copy(alpha = 0.65f),
                style = MaterialTheme.typography.bodyMedium.copy(textDirection = detail.note.direction()),
                textAlign = if (detail.note.isRightToLeft()) TextAlign.Start else TextAlign.End,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}

private fun String.isSingleToken(): Boolean = trim().none { it.isWhitespace() }

private fun String.isRightToLeft(): Boolean = rightToLeftScript.containsMatchIn(this)

private fun String.direction(): TextDirection = if (isRightToLeft()) TextDirection.Rtl else TextDirection.Ltr

/** The direction [text] reads in: right to left when it has Arabic-script or Hebrew letters. */
internal fun textDirectionOf(text: String): TextDirection = text.direction()
