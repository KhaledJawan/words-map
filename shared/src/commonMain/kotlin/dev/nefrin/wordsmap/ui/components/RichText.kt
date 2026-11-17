package dev.nefrin.wordsmap.ui.components

import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.withStyle
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.LocalizedText
import dev.nefrin.wordsmap.data.hasRightToLeftScript

private val blankLine = Regex("\\n\\s*\\n")

/** The paragraphs of a lesson text: blocks separated by an empty line. */
fun paragraphsOf(text: String): List<String> = text.split(blankLine).map { it.trim() }.filter { it.isNotEmpty() }

/** Applies [emphasis] to every `**marked**` part of [text] and removes the markers. */
fun emphasized(text: String, emphasis: SpanStyle): AnnotatedString = buildAnnotatedString {
    val parts = text.split("**")
    parts.forEachIndexed { index, part ->
        val marked = index % 2 == 1
        when {
            !marked -> append(part)
            // An opening marker without a closing one is ordinary text.
            index == parts.lastIndex -> append("**$part")
            else -> withStyle(emphasis) { append(part) }
        }
    }
}

/**
 * A line of a lesson text: `**bold**` in [strong], and `code` (German words inside a Farsi
 * text) in [code].
 *
 * In a right-to-left line a German part is isolated as left-to-right text, otherwise the
 * punctuation at its ends lands on the wrong side ("Könnten Sie bitte …?" became
 * "?… Könnten Sie bitte"). Outside such parts an arrow "→" would point back at what it
 * comes from, so it is turned round there.
 */
fun lessonText(text: String, strong: SpanStyle, code: SpanStyle): AnnotatedString = buildAnnotatedString {
    val rightToLeft = hasRightToLeftScript(text)
    fun outside(part: String) = if (rightToLeft) part.replace('→', '←') else part
    val parts = text.split('`')
    parts.forEachIndexed { index, part ->
        when {
            index % 2 == 0 -> append(emphasized(outside(part), strong))
            // An opening backtick without a closing one is ordinary text.
            index == parts.lastIndex -> append("`${outside(part)}")
            rightToLeft && !hasRightToLeftScript(part) -> withStyle(code) { append(LEFT_TO_RIGHT_ISOLATE + part + POP_ISOLATE) }
            else -> withStyle(code) { append(part) }
        }
    }
}

private const val LEFT_TO_RIGHT_ISOLATE = '⁦'
private const val POP_ISOLATE = '⁩'

/**
 * Side a lesson text starts from: that of the language it is actually written in.
 * A lesson without a Farsi text is shown in English, and must then read left to right.
 */
fun LocalizedText.directionFor(language: AppLanguage): TextDirection =
    if (AppLanguage.fromCode(resolvedCode(language))?.isRtl == true) TextDirection.Rtl else TextDirection.Ltr
