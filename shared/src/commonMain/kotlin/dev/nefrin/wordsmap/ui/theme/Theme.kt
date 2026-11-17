package dev.nefrin.wordsmap.ui.theme

import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.graphics.Color
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.ui.components.LocalizedScope

// The original app used only a primary, a secondary and a surface color; every container
// role resolved to the surface. The schemes below keep that, so components look the same.
private val LightColors = lightColorScheme(
    primary = Palette.PrimaryBlue,
    onPrimary = Color.White,
    primaryContainer = Palette.PrimaryBlue,
    onPrimaryContainer = Color.White,
    secondary = Palette.AccentOrange,
    onSecondary = Color.Black,
    secondaryContainer = Palette.AccentOrange,
    onSecondaryContainer = Color.Black,
    tertiary = Palette.GrammarIndigo,
    onTertiary = Color.White,
    background = Palette.LightBackground,
    onBackground = Palette.Ink,
    surface = Color.White,
    onSurface = Palette.Ink,
    surfaceVariant = Color.White,
    onSurfaceVariant = Color.Black,
    surfaceContainerLowest = Color.White,
    surfaceContainerLow = Color.White,
    surfaceContainer = Color.White,
    surfaceContainerHigh = Color.White,
    surfaceContainerHighest = Color.White,
    outline = Color.Black,
    outlineVariant = Palette.Grey300,
    error = Color(0xFFB00020),
)

private val DarkColors = darkColorScheme(
    primary = Palette.PrimaryBlue,
    onPrimary = Color.Black,
    primaryContainer = Palette.PrimaryBlue,
    onPrimaryContainer = Color.Black,
    secondary = Palette.AccentOrange,
    onSecondary = Color.Black,
    secondaryContainer = Palette.AccentOrange,
    onSecondaryContainer = Color.Black,
    tertiary = Palette.GrammarIndigo,
    onTertiary = Color.White,
    background = Palette.DarkBackground,
    onBackground = DarkAppColors.text,
    surface = Palette.DarkSurface,
    onSurface = DarkAppColors.text,
    surfaceVariant = Palette.DarkSurface,
    onSurfaceVariant = Color.White,
    surfaceContainerLowest = Palette.DarkSurface,
    surfaceContainerLow = Palette.DarkSurface,
    surfaceContainer = Palette.DarkSurface,
    surfaceContainerHigh = Palette.DarkSurface,
    surfaceContainerHighest = Palette.DarkSurface,
    outline = Color.White,
    outlineVariant = Palette.DividerDark,
    error = Color(0xFFCF6679),
)

@Composable
fun WordsMapTheme(darkTheme: Boolean, language: AppLanguage, content: @Composable () -> Unit) {
    val typography = appTypography(language.isRtl)
    val colors = if (darkTheme) DarkAppColors else LightAppColors
    MaterialTheme(colorScheme = if (darkTheme) DarkColors else LightColors, typography = typography) {
        CompositionLocalProvider(
            LocalAppColors provides colors,
            LocalContentColor provides colors.text,
        ) {
            LocalizedScope(language, content)
        }
    }
}

val appColors: AppColors
    @Composable @ReadOnlyComposable get() = LocalAppColors.current
