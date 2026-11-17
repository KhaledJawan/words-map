package dev.nefrin.wordsmap.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.nefrin.wordsmap.ui.theme.appColors

object WordChipDefaults {
    val VerticalMargin = 3.dp
    val Spacing = 8.dp

    val textStyle: TextStyle
        @Composable get() = MaterialTheme.typography.titleMedium.copy(
            fontSize = 14.sp,
            lineHeight = 21.sp,
            fontWeight = FontWeight.SemiBold,
        )

    /** Short words get more room on each side, so chips do not look cramped or bloated. */
    fun horizontalPadding(text: String): Dp = when {
        text.length <= 4 -> 20.dp
        text.length <= 7 -> 16.dp
        text.length <= 12 -> 12.dp
        else -> 10.dp
    }
}

/**
 * A word as a pill. White when unseen, blue text once bookmarked, greyed out once viewed.
 * A bookmark wins over viewed.
 */
@Composable
fun WordChip(
    text: String,
    bookmarked: Boolean,
    viewed: Boolean,
    rightToLeft: Boolean,
    onClick: () -> Unit,
    onLongClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val colors = appColors
    val background: Color
    val textColor: Color
    val shadows: List<SoftShadow>
    var border = Color.Transparent
    when {
        bookmarked -> {
            background = colors.chipBookmarked
            textColor = colors.chipBookmarkedText
            shadows = SoftShadows.bookmarked
        }
        viewed -> {
            background = colors.chipViewed
            textColor = colors.chipViewedText
            border = colors.chipViewedBorder
            shadows = emptyList()
        }
        else -> {
            background = colors.chip
            textColor = colors.chipText
            shadows = SoftShadows.card
        }
    }
    Text(
        text = text,
        modifier = modifier
            .padding(vertical = WordChipDefaults.VerticalMargin)
            // Shadows do not show on a dark page; the chip colors carry the difference there.
            .softShadow(if (colors.isDark) emptyList() else shadows)
            .clip(CircleShape)
            .background(background)
            .then(if (border != Color.Transparent) Modifier.border(1.dp, border, CircleShape) else Modifier)
            .combinedClickable(onClick = onClick, onLongClick = onLongClick)
            .padding(horizontal = WordChipDefaults.horizontalPadding(text), vertical = 10.dp),
        color = textColor,
        textAlign = TextAlign.Center,
        overflow = TextOverflow.Ellipsis,
        softWrap = false,
        maxLines = 1,
        style = WordChipDefaults.textStyle.copy(
            textDirection = if (rightToLeft) TextDirection.Rtl else TextDirection.Ltr,
        ),
    )
}
