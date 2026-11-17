package dev.nefrin.wordsmap.ui.grammar

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.MultiParagraphIntrinsics
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.data.CalloutKind
import dev.nefrin.wordsmap.data.LessonBlock
import dev.nefrin.wordsmap.data.hasRightToLeftScript
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.StringRes
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_alert_triangle
import dev.nefrin.wordsmap.resources.ic_book_marked
import dev.nefrin.wordsmap.resources.ic_info
import dev.nefrin.wordsmap.resources.ic_lightbulb
import dev.nefrin.wordsmap.resources.ic_list_checks
import dev.nefrin.wordsmap.resources.ic_quote
import dev.nefrin.wordsmap.resources.ic_star
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.lessonText
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource
import kotlin.math.ceil
import kotlin.math.floor

/** Color, icon and label of each kind of card. */
private class CalloutStyle(val color: Color, val icon: DrawableResource, val label: StringRes)

private fun styleOf(kind: CalloutKind) = when (kind) {
    CalloutKind.NOTE -> CalloutStyle(Palette.PrimaryBlue, Res.drawable.ic_info, Strings.callout_note)
    CalloutKind.TIP -> CalloutStyle(Palette.Success, Res.drawable.ic_lightbulb, Strings.callout_tip)
    CalloutKind.IMPORTANT -> CalloutStyle(Palette.AccentOrange, Res.drawable.ic_star, Strings.callout_important)
    CalloutKind.WARNING -> CalloutStyle(Palette.Failure, Res.drawable.ic_alert_triangle, Strings.callout_warning)
    CalloutKind.RULE -> CalloutStyle(Palette.GrammarIndigo, Res.drawable.ic_book_marked, Strings.callout_rule)
    CalloutKind.EXAMPLE -> CalloutStyle(Palette.TextsTeal, Res.drawable.ic_quote, Strings.callout_example)
    CalloutKind.SUMMARY -> CalloutStyle(Color(0xFF5E6B7A), Res.drawable.ic_list_checks, Strings.callout_summary)
}

/** Farsi and Pashto lines read right to left, German ones left to right, whatever the page language. */
private fun directionOf(text: String) = if (hasRightToLeftScript(text)) TextDirection.Rtl else TextDirection.Ltr

private fun layoutOf(text: String) = if (hasRightToLeftScript(text)) LayoutDirection.Rtl else LayoutDirection.Ltr

/** One block of a lesson text: a heading, a paragraph, a list, a table or a card. */
@Composable
fun LessonBlockView(block: LessonBlock, accent: Color, modifier: Modifier = Modifier) {
    val strong = SpanStyle(fontWeight = FontWeight.Bold, color = appColors.heading)
    val code = SpanStyle(fontWeight = FontWeight.SemiBold, color = accent)
    Column(modifier.fillMaxWidth()) {
        BlockContent(block, accent, strong, code, example = false)
    }
}

@Composable
private fun BlockContent(block: LessonBlock, accent: Color, strong: SpanStyle, code: SpanStyle, example: Boolean) {
    val body = MaterialTheme.typography.bodyLarge
    when (block) {
        is LessonBlock.Heading -> Text(
            text = lessonText(block.text, strong, code),
            modifier = Modifier.fillMaxWidth().padding(top = 6.dp),
            color = appColors.heading,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold, textDirection = directionOf(block.text)),
        )
        is LessonBlock.Paragraph -> Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            for (line in block.text.lines()) {
                // In an example, German sentences stand out and their translations are quieter.
                val german = example && !hasRightToLeftScript(line)
                Text(
                    text = lessonText(line, strong, code),
                    modifier = Modifier.fillMaxWidth(),
                    color = when {
                        german -> appColors.heading
                        example -> appColors.textMuted
                        else -> appColors.text
                    },
                    style = body.copy(
                        fontWeight = if (german) FontWeight.SemiBold else FontWeight.Normal,
                        textDirection = directionOf(line),
                    ),
                )
            }
        }
        is LessonBlock.Bullets -> Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            block.items.forEachIndexed { index, item ->
                ProvideDirection(layoutOf(item)) {
                    Row(Modifier.fillMaxWidth()) {
                        Text(
                            text = if (block.numbered) "${index + 1}." else "•",
                            modifier = Modifier.width(22.dp),
                            color = accent,
                            style = body.copy(fontWeight = FontWeight.Bold),
                        )
                        Text(
                            text = lessonText(item, strong, code),
                            modifier = Modifier.weight(1f),
                            color = appColors.text,
                            style = body.copy(textDirection = directionOf(item)),
                        )
                    }
                }
            }
        }
        is LessonBlock.Table -> LessonTable(block, accent, strong, code)
        is LessonBlock.Callout -> CalloutCard(block, strong, code)
    }
}

private val CellPadding = 10.dp
private val CompactCellPadding = 6.dp

/** Column widths of a table, and whether it needs the small type or sideways scrolling to fit. */
private class TableFit(val widths: List<Dp>, val compact: Boolean, val scrolls: Boolean)

@Composable
private fun LessonTable(table: LessonBlock.Table, accent: Color, strong: SpanStyle, code: SpanStyle) {
    val shape = RoundedCornerShape(14.dp)
    val normalStyle = MaterialTheme.typography.bodyMedium.copy(textDirection = TextDirection.Content)
    val compactStyle = MaterialTheme.typography.bodySmall.copy(textDirection = TextDirection.Content)
    // The first column stands on the side the header is read from.
    ProvideDirection(layoutOf(table.header.joinToString(" "))) {
        BoxWithConstraints(
            Modifier
                .fillMaxWidth()
                .clip(shape)
                .background(MaterialTheme.colorScheme.surface)
                .border(1.dp, appColors.divider.copy(alpha = 0.5f), shape),
        ) {
            val measurer = rememberTextMeasurer()
            val density = LocalDensity.current
            val available = maxWidth
            val fit = remember(table, available, normalStyle, compactStyle, density, strong, code) {
                fitTable(table, available, density, normalStyle, compactStyle) { text, style ->
                    measurer.measure(lessonText(text, strong, code), style).multiParagraph.intrinsics
                }
            }
            val cellStyle = if (fit.compact) compactStyle else normalStyle
            val padding = if (fit.compact) CompactCellPadding else CellPadding
            val scroll = if (fit.scrolls) Modifier.horizontalScroll(rememberScrollState()) else Modifier
            Column(scroll.width(fit.widths.fold(0.dp) { sum, width -> sum + width })) {
                TableRow(table.header, fit.widths, padding, cellStyle.copy(fontWeight = FontWeight.Bold), appColors.heading, Modifier.background(accent.copy(alpha = 0.12f)), strong, code)
                table.rows.forEach { row ->
                    HorizontalDivider(color = appColors.divider.copy(alpha = 0.35f))
                    TableRow(row, fit.widths, padding, cellStyle, appColors.text, Modifier, strong, code)
                }
            }
        }
    }
}

@Composable
private fun TableRow(
    cells: List<String>,
    widths: List<Dp>,
    padding: Dp,
    style: TextStyle,
    color: Color,
    modifier: Modifier,
    strong: SpanStyle,
    code: SpanStyle,
) {
    Row(modifier.height(IntrinsicSize.Min)) {
        cells.forEachIndexed { index, cell ->
            Text(
                text = lessonText(cell, strong, code),
                modifier = Modifier.width(widths.getOrElse(index) { widths.last() }).padding(horizontal = padding, vertical = 9.dp),
                color = color,
                style = style,
            )
        }
    }
}

/**
 * Sizes the columns so that no word is broken in the middle. Equal columns are kept when
 * they already manage that; otherwise every column gets its longest word and the rest of
 * the width goes to the columns with the longest texts. A table too wide even for that is
 * set in smaller type and, if it still does not fit, scrolls sideways.
 */
private fun fitTable(
    table: LessonBlock.Table,
    available: Dp,
    density: Density,
    normalStyle: TextStyle,
    compactStyle: TextStyle,
    intrinsics: (String, TextStyle) -> MultiParagraphIntrinsics,
): TableFit {
    val columns = maxOf(table.header.size, table.rows.maxOfOrNull { it.size } ?: 0).coerceAtLeast(1)
    // A pixel to spare, so rounding never pushes the last column out.
    val space = with(density) { available.toPx() } - 1f

    fun bounds(style: TextStyle, padding: Dp): Pair<FloatArray, FloatArray> {
        val extra = with(density) { padding.toPx() } * 2
        val shortest = FloatArray(columns)
        val longest = FloatArray(columns)
        (listOf(table.header to style.copy(fontWeight = FontWeight.Bold)) + table.rows.map { it to style }).forEach { (cells, cellStyle) ->
            cells.forEachIndexed { column, cell ->
                val size = intrinsics(cell, cellStyle)
                // Rounded up with a pixel to spare: a cell even a fraction too narrow breaks its longest word.
                shortest[column] = maxOf(shortest[column], ceil(size.minIntrinsicWidth + extra) + 1f)
                longest[column] = maxOf(longest[column], ceil(size.maxIntrinsicWidth + extra) + 1f)
            }
        }
        return shortest to longest
    }

    // Whole pixels, rounded down so the columns never add up to more than the space. A column
    // still keeps its longest word, which is a whole number of pixels already.
    fun widths(pixels: List<Float>) = pixels.map { with(density) { floor(it).toDp() } }

    val (shortest, longest) = bounds(normalStyle, CellPadding)
    if (shortest.all { it <= space / columns }) return TableFit(widths(List(columns) { space / columns }), compact = false, scrolls = false)
    if (shortest.sum() <= space) return TableFit(widths(share(shortest, longest, space)), compact = false, scrolls = false)
    val (compactShortest, compactLongest) = bounds(compactStyle, CompactCellPadding)
    if (compactShortest.sum() <= space) return TableFit(widths(share(compactShortest, compactLongest, space)), compact = true, scrolls = false)
    return TableFit(widths(compactShortest.toList()), compact = true, scrolls = true)
}

// Starts every column at its longest word and hands out the rest of [space] by how much
// more each column could use; whatever is left after that is spread evenly.
private fun share(shortest: FloatArray, longest: FloatArray, space: Float): List<Float> {
    val spare = space - shortest.sum()
    val wanted = shortest.indices.map { longest[it] - shortest[it] }
    val totalWanted = wanted.sum()
    return if (totalWanted <= spare) {
        val even = (spare - totalWanted) / shortest.size
        shortest.indices.map { longest[it] + even }
    } else {
        shortest.indices.map { shortest[it] + spare * wanted[it] / totalWanted }
    }
}

/** A highlighted card: a colored stripe, an icon and label, then its content. */
@Composable
private fun CalloutCard(callout: LessonBlock.Callout, strong: SpanStyle, code: SpanStyle) {
    val style = styleOf(callout.kind)
    val tint = style.color.copy(alpha = if (appColors.isDark) 0.18f else 0.09f)
    Row(
        Modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Min)
            .clip(RoundedCornerShape(16.dp))
            .background(tint),
    ) {
        Box(Modifier.width(4.dp).fillMaxHeight().background(style.color))
        Column(Modifier.weight(1f).padding(horizontal = 14.dp, vertical = 12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(painterResource(style.icon), contentDescription = null, modifier = Modifier.size(18.dp), tint = style.color)
                Spacer(Modifier.width(8.dp))
                Text(
                    text = stringResource(style.label),
                    color = style.color,
                    style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
                )
            }
            Spacer(Modifier.height(8.dp))
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                for (block in callout.blocks) {
                    BlockContent(block, style.color, strong, code.copy(color = style.color), example = callout.kind == CalloutKind.EXAMPLE)
                }
            }
        }
    }
}
