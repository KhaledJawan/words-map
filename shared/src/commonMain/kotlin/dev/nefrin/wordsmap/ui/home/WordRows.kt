package dev.nefrin.wordsmap.ui.home

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.Dp
import dev.nefrin.wordsmap.ui.components.WordChipDefaults

/**
 * Splits items of the given [widths] into consecutive rows that fit [maxWidth], with
 * [spacing] between neighbours. An item wider than [maxWidth] gets a row of its own.
 */
internal fun packRows(widths: IntArray, spacing: Int, maxWidth: Int): List<IntRange> {
    val rows = mutableListOf<IntRange>()
    var start = 0
    var used = 0
    for (index in widths.indices) {
        val needed = if (index == start) widths[index] else used + spacing + widths[index]
        if (index > start && needed > maxWidth) {
            rows += start until index
            start = index
            used = widths[index]
        } else {
            used = needed
        }
    }
    if (start < widths.size) rows += start until widths.size
    return rows
}

/**
 * Lays [texts] out as wrapped rows of word chips, [maxWidth] wide, and returns the index
 * range of each row. Knowing the rows up front lets the list compose only what is on screen;
 * a category can hold more than a thousand words.
 */
@Composable
internal fun rememberWordRows(texts: List<String>, maxWidth: Dp): List<IntRange> {
    val measurer = rememberTextMeasurer(cacheSize = 0)
    val style = WordChipDefaults.textStyle
    val density = LocalDensity.current
    // Words come back when the level or category changes; their widths do not.
    val textWidths = remember(style, density) { HashMap<String, Int>() }
    return remember(texts, maxWidth, style, density) {
        with(density) {
            val limit = maxWidth.roundToPx()
            val widths = IntArray(texts.size) { index ->
                val text = texts[index]
                val textWidth = textWidths.getOrPut(text) {
                    measurer.measure(text, style, softWrap = false, maxLines = 1).size.width
                }
                // One spare pixel, so rounding during layout never pushes a chip out of its row.
                minOf(textWidth + 2 * WordChipDefaults.horizontalPadding(text).roundToPx() + 1, limit)
            }
            packRows(widths, WordChipDefaults.Spacing.roundToPx(), limit)
        }
    }
}
