package dev.nefrin.wordsmap.resources

import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import dev.nefrin.wordsmap.data.AppLanguage
import kotlin.jvm.JvmInline

/** One interface text; the generated [Strings] lists them all. */
@JvmInline
value class StringRes internal constructor(internal val index: Int)

/** Language the texts below it are shown in; set by `LocalizedScope`. */
val LocalStringsLanguage = staticCompositionLocalOf { AppLanguage.EN }

/** [res] in [language], or in English when it is not translated. */
fun StringRes.resolve(language: AppLanguage): String =
    translatedStrings[language.code]?.get(index) ?: defaultStrings[index]

/** [res] in [language], with `%1$s`, `%2$s` … replaced by [args]. */
fun StringRes.resolve(language: AppLanguage, vararg args: Any): String = formatText(resolve(language), args)

/** [res] in the language of the surrounding `LocalizedScope`. */
@Composable
@ReadOnlyComposable
fun stringResource(res: StringRes): String = res.resolve(LocalStringsLanguage.current)

/** [res] with `%1$s`, `%2$s` … (or plain `%s`) replaced by [args]. */
@Composable
@ReadOnlyComposable
fun stringResource(res: StringRes, vararg args: Any): String = formatText(stringResource(res), args)

private val placeholder = Regex("%(?:(\\d+)\\$)?s|%%")

internal fun formatText(text: String, args: Array<out Any>): String {
    var next = 0
    return placeholder.replace(text) { match ->
        if (match.value == "%%") return@replace "%"
        val position = match.groupValues[1].toIntOrNull()?.minus(1) ?: next++
        args.getOrNull(position)?.toString() ?: match.value
    }
}
