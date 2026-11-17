package dev.nefrin.wordsmap.ui.texts

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextLinkStyles
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.data.GermanWordIndex
import dev.nefrin.wordsmap.data.Word
import dev.nefrin.wordsmap.data.tokenize
import dev.nefrin.wordsmap.ui.components.emphasized

/** Characters [start] until [end] of a paragraph, which hold a vocabulary word. */
data class TextSpan(val start: Int, val end: Int)

/**
 * A paragraph in which every word of the vocabulary can be tapped. Those words sit on a
 * soft [mark], so readers see which ones have a translation; other words stay ordinary text
 * and ignore taps.
 *
 * The marks are drawn as rounded boxes around the words rather than as text backgrounds,
 * which would fill the whole, taller line and touch the lines above and below.
 *
 * @param selected the span to show in the stronger [highlight], such as the word whose card is open
 */
@Composable
fun TappableParagraph(
    paragraph: String,
    index: GermanWordIndex,
    style: TextStyle,
    color: Color,
    mark: Color,
    highlight: Color,
    selected: TextSpan?,
    onWordTap: (Word, TextSpan) -> Unit,
    modifier: Modifier = Modifier,
) {
    val base = remember(paragraph) { emphasized(paragraph, SpanStyle(fontWeight = FontWeight.Bold)) }
    val matches = remember(base, index) {
        val tokens = tokenize(base.text)
        index.findAll(tokens).map { match ->
            match.word to TextSpan(tokens[match.firstToken].start, tokens[match.lastToken].end)
        }
    }
    // An empty style keeps the words looking like the rest of the text instead of blue links.
    val plain = TextLinkStyles(style = SpanStyle())
    val text = buildAnnotatedString {
        append(base)
        for ((word, span) in matches) {
            addLink(LinkAnnotation.Clickable(tag = word.id, styles = plain) { onWordTap(word, span) }, span.start, span.end)
        }
    }
    var layout by remember { mutableStateOf<TextLayoutResult?>(null) }
    Text(
        text = text,
        modifier = modifier.drawBehind {
            val result = layout ?: return@drawBehind
            // A box a little taller than the letters, centred on the line.
            val halfHeight = style.fontSize.toPx() * 0.66f
            val padding = 2.dp.toPx()
            val corner = CornerRadius(5.dp.toPx())
            for ((_, span) in matches) {
                val fill = if (span == selected) highlight else mark
                if (fill.alpha == 0f) continue
                result.forEachLinePart(span) { left, right, centerY ->
                    drawRoundRect(
                        color = fill,
                        topLeft = Offset(left - padding, centerY - halfHeight),
                        size = Size(right - left + 2 * padding, 2 * halfHeight),
                        cornerRadius = corner,
                    )
                }
            }
        },
        color = color,
        style = style,
        onTextLayout = { layout = it },
    )
}

/** Calls [block] with the left and right edge and the vertical centre of [span] on each line it covers. */
private inline fun TextLayoutResult.forEachLinePart(span: TextSpan, block: (left: Float, right: Float, centerY: Float) -> Unit) {
    if (span.end <= span.start || span.end > layoutInput.text.length) return
    for (line in getLineForOffset(span.start)..getLineForOffset(span.end - 1)) {
        val start = maxOf(span.start, getLineStart(line))
        val end = minOf(span.end, getLineEnd(line, visibleEnd = true))
        if (end <= start) continue
        val first = getBoundingBox(start)
        val last = getBoundingBox(end - 1)
        block(minOf(first.left, last.left), maxOf(first.right, last.right), (getLineTop(line) + getLineBottom(line)) / 2)
    }
}
