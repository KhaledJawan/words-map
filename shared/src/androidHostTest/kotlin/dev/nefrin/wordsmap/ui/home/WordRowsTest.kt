package dev.nefrin.wordsmap.ui.home

import org.junit.Assert.assertEquals
import org.junit.Test

class WordRowsTest {

    @Test
    fun `fills each row until the next chip would not fit`() {
        // 40 + 8 + 40 = 88 fits in 100; a third chip would need 136.
        val rows = packRows(intArrayOf(40, 40, 40, 40, 40), spacing = 8, maxWidth = 100)
        assertEquals(listOf(0..1, 2..3, 4..4), rows)
    }

    @Test
    fun `a chip that exactly fills the remaining space stays on the row`() {
        val rows = packRows(intArrayOf(46, 46, 10), spacing = 8, maxWidth = 100)
        assertEquals(listOf(0..1, 2..2), rows)
    }

    @Test
    fun `a chip wider than the row gets a row of its own`() {
        val rows = packRows(intArrayOf(30, 150, 30), spacing = 8, maxWidth = 100)
        assertEquals(listOf(0..0, 1..1, 2..2), rows)
    }

    @Test
    fun `no chips means no rows`() {
        assertEquals(emptyList<IntRange>(), packRows(intArrayOf(), spacing = 8, maxWidth = 100))
    }

    @Test
    fun `every chip lands in exactly one row, in order`() {
        val widths = IntArray(1256) { 30 + (it * 37) % 140 }
        val rows = packRows(widths, spacing = 8, maxWidth = 360)
        assertEquals(widths.indices.toList(), rows.flatMap { it.toList() })
        for (row in rows) {
            val used = row.sumOf { widths[it] } + 8 * (row.count() - 1)
            assert(used <= 360 || row.count() == 1) { "row $row is $used wide" }
        }
    }
}
