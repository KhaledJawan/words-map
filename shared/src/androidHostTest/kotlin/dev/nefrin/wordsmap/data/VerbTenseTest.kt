package dev.nefrin.wordsmap.data

import org.junit.Assert.assertEquals
import org.junit.Test

class VerbTenseTest {
    @Test
    fun `tenses and persons come in teaching order`() {
        val tenses = orderedTenses(
            mapOf(
                "Imperativ" to mapOf("Sie" to "kommen Sie!", "du" to "komm!"),
                "Perfekt" to mapOf("wir" to "sind gekommen", "ich" to "bin gekommen"),
                "Präsens" to mapOf("sie/Sie" to "kommen", "ich" to "komme", "er/sie/es" to "kommt"),
            ),
        )
        assertEquals(listOf("Präsens", "Perfekt", "Imperativ"), tenses.map { it.name })
        assertEquals(listOf("ich", "er/sie/es", "sie/Sie"), tenses[0].rows.map { it.first })
        assertEquals(listOf("du" to "komm!", "Sie" to "kommen Sie!"), tenses[2].rows)
    }

    @Test
    fun `unknown tenses are kept after the known ones and empty ones are dropped`() {
        val tenses = orderedTenses(
            mapOf(
                "Partizip I" to mapOf("" to "kommend"),
                "Futur II" to mapOf("ich" to " "),
                "Präteritum" to mapOf("ich" to " kam ", "du" to ""),
            ),
        )
        assertEquals(listOf("Präteritum", "Partizip I"), tenses.map { it.name })
        assertEquals(listOf("ich" to "kam"), tenses[0].rows)
    }
}
