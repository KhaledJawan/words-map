package dev.nefrin.wordsmap.ui.components

import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithCache
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.platform.blurredPaint
import dev.nefrin.wordsmap.ui.theme.Palette

/** A blurred box shadow: [blur] radius, grown by [spread] and moved down by [offsetY]. */
class SoftShadow(val color: Color, val blur: Dp, val offsetY: Dp, val spread: Dp = 0.dp)

object SoftShadows {
    /** Under white cards and unseen word chips. */
    val card = listOf(
        SoftShadow(Color.Black.copy(alpha = 0.06f), blur = 10.dp, offsetY = 3.dp, spread = 1.dp),
        SoftShadow(Color.Black.copy(alpha = 0.02f), blur = 16.dp, offsetY = 7.dp, spread = 1.dp),
    )

    /** Under bookmarked word chips. */
    val bookmarked = listOf(
        SoftShadow(Palette.BookmarkBlue.copy(alpha = 0.10f), blur = 11.dp, offsetY = 3.dp, spread = 1.dp),
        SoftShadow(Palette.BookmarkBlue.copy(alpha = 0.04f), blur = 16.dp, offsetY = 7.dp, spread = 1.dp),
    )

    /** Under the gradient cards of the Lessons tab. */
    val lessonCard = listOf(SoftShadow(Color.Black.copy(alpha = 0.08f), blur = 18.dp, offsetY = 6.dp))

    /** Under the level cards of the grammar screen. */
    val listCard = listOf(SoftShadow(Color.Black.copy(alpha = 0.05f), blur = 12.dp, offsetY = 3.dp))
}

/**
 * Draws [shadows] behind a rounded box. Elevation shadows depend on where a view sits on
 * screen; these look the same everywhere, like the original design.
 *
 * @param cornerRadius corner radius of the box, or null for fully rounded ends
 */
fun Modifier.softShadow(shadows: List<SoftShadow>, cornerRadius: Dp? = null): Modifier =
    if (shadows.isEmpty()) this else drawWithCache {
        val paints = shadows.map { shadow -> blurredPaint(shadow.color, shadow.blur.toPx()) }
        onDrawBehind {
            drawIntoCanvas { canvas ->
                shadows.forEachIndexed { index, shadow ->
                    val spread = shadow.spread.toPx()
                    val top = shadow.offsetY.toPx() - spread
                    val radius = (cornerRadius?.toPx() ?: (size.height / 2)) + spread
                    canvas.drawRoundRect(
                        -spread, top, size.width + spread, top + size.height + 2 * spread,
                        radius, radius, paints[index],
                    )
                }
            }
        }
    }
