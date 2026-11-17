package dev.nefrin.wordsmap.ui.theme

import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

/** The palette of the original WordMap app. */
object Palette {
    val LightBackground = Color(0xFFF2F2F7)
    val DarkBackground = Color(0xFF121214)
    val DarkSurface = Color(0xFF1C1C20)

    val PrimaryBlue = Color(0xFF4A90E2)
    val AccentOrange = Color(0xFFFF9500)
    val GrammarIndigo = Color(0xFF5856D6)
    val TextsTeal = Color(0xFF2A9D8F)
    val Success = Color(0xFF4CAF50)
    val Failure = Color(0xFFE5534B)
    val BookmarkBlue = Color(0xFF4BA8FF)

    val Grey100 = Color(0xFFF5F5F5)
    val Grey300 = Color(0xFFE0E0E0)
    val Grey400 = Color(0xFFBDBDBD)
    val Grey500 = Color(0xFF9E9E9E)
    val Grey600 = Color(0xFF757575)
    val Grey700 = Color(0xFF616161)
    val DividerDark = Color(0xFF2E2E2E)
    val Ink = Color(0xDD000000)
}

/** Colors the Material scheme has no slot for. */
@Immutable
class AppColors(
    val isDark: Boolean,
    /** Titles and list rows. */
    val heading: Color,
    /** Running text. */
    val text: Color,
    /** Captions and subtitles. */
    val textMuted: Color,
    val divider: Color,
    /** Grammar accent for text and icons on the page background. */
    val grammarAccent: Color,
    /** Texts accent for text and icons on the page background. */
    val textsAccent: Color,
    /** Round buttons and pills of the home header, and their text and icons. */
    val headerButton: Color,
    val onHeaderButton: Color,
    /** Word chips: unseen, viewed (dimmed, with an outline in the dark) and bookmarked. */
    val chip: Color,
    val chipText: Color,
    val chipViewed: Color,
    val chipViewedText: Color,
    val chipViewedBorder: Color,
    val chipBookmarked: Color,
    val chipBookmarkedText: Color,
    /** Unselected tiles of the chapter picker. */
    val tile: Color,
    val tileBorder: Color,
    val tileText: Color,
)

val LightAppColors = AppColors(
    isDark = false,
    heading = Palette.Ink,
    text = Palette.Ink,
    textMuted = Color(0x8A000000),
    divider = Palette.Grey300,
    grammarAccent = Palette.GrammarIndigo,
    textsAccent = Palette.TextsTeal,
    headerButton = Color.Black,
    onHeaderButton = Color.White,
    chip = Color.White,
    chipText = Color(0xFF111111),
    chipViewed = Palette.LightBackground,
    chipViewedText = Color(0xFFAAAAAA),
    chipViewedBorder = Color.Transparent,
    chipBookmarked = Color.White,
    chipBookmarkedText = Palette.BookmarkBlue,
    tile = Palette.Grey100,
    tileBorder = Palette.Grey300,
    tileText = Palette.Ink,
)

val DarkAppColors = AppColors(
    isDark = true,
    heading = Color.White,
    text = Color(0xB3FFFFFF),
    textMuted = Color(0xB3FFFFFF),
    divider = Palette.DividerDark,
    grammarAccent = Color(0xFF9B99F5),
    textsAccent = Color(0xFF5CC9BC),
    // Raised grey instead of black, so chips and buttons stand out from the dark page.
    headerButton = Color(0xFF2E2E34),
    onHeaderButton = Color.White,
    chip = Color(0xFF2A2A30),
    chipText = Color(0xFFF2F2F7),
    chipViewed = Color.Transparent,
    chipViewedText = Color.White.copy(alpha = 0.42f),
    chipViewedBorder = Color(0xFF34343B),
    chipBookmarked = Color(0xFF173452),
    chipBookmarkedText = Color(0xFF7CC4FF),
    tile = Color(0xFF26262C),
    tileBorder = Color(0xFF34343B),
    tileText = Color(0xFFF2F2F7),
)

val LocalAppColors = staticCompositionLocalOf { LightAppColors }
