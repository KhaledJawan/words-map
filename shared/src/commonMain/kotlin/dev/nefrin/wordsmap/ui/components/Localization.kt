package dev.nefrin.wordsmap.ui.components

import androidx.compose.material3.LocalTextStyle
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.unit.LayoutDirection
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.LocalizedText
import dev.nefrin.wordsmap.resources.LocalStringsLanguage

/**
 * Shows [content] in [language]: its interface texts and its layout direction. The theme
 * applies the app language with it; every interface text stays in that language.
 *
 * Bottom sheets and dialogs start a new window and must apply it again inside.
 */
@Composable
fun LocalizedScope(language: AppLanguage, content: @Composable () -> Unit) {
    CompositionLocalProvider(LocalStringsLanguage provides language) {
        ProvideDirection(if (language.isRtl) LayoutDirection.Rtl else LayoutDirection.Ltr, content)
    }
}

/**
 * Lays out lesson content in the direction of the language [text] is shown in for [language]
 * (the "Translate To" language), so a Farsi lesson reads right to left inside an English
 * app. Only the direction changes: buttons and headings inside stay in the app language.
 */
@Composable
fun ContentDirection(text: LocalizedText, language: AppLanguage, content: @Composable () -> Unit) {
    val rtl = text.directionFor(language) == TextDirection.Rtl
    ProvideDirection(if (rtl) LayoutDirection.Rtl else LayoutDirection.Ltr, content)
}

/**
 * Lays [content] out in [direction] and makes its texts start from that side.
 *
 * Without the second part a text picks its side from its first letter, so a Farsi sentence
 * that begins with a German word would be set left to right and read scrambled.
 */
@Composable
fun ProvideDirection(direction: LayoutDirection, content: @Composable () -> Unit) {
    val textDirection = if (direction == LayoutDirection.Rtl) TextDirection.Rtl else TextDirection.Ltr
    CompositionLocalProvider(
        LocalLayoutDirection provides direction,
        LocalTextStyle provides LocalTextStyle.current.copy(textDirection = textDirection),
        content = content,
    )
}
