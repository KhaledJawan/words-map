package dev.nefrin.wordsmap.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.inter_variable
import dev.nefrin.wordsmap.resources.vazirmatn_variable
import org.jetbrains.compose.resources.Font
import org.jetbrains.compose.resources.FontResource

// One variable font file per family. Each weight has to name its position on the weight
// axis, otherwise every weight draws the regular instance.
@OptIn(ExperimentalTextApi::class)
@Composable
private fun variableFamily(font: FontResource): FontFamily {
    val fonts = listOf(400, 500, 600, 700, 800, 900).map { weight ->
        Font(
            resource = font,
            weight = FontWeight(weight),
            variationSettings = FontVariation.Settings(FontVariation.weight(weight)),
        )
    }
    return remember(fonts) { FontFamily(fonts) }
}

/** Inter for Latin interfaces, Vazirmatn when the interface is Farsi or Pashto. */
@Composable
fun appTypography(rightToLeft: Boolean): Typography {
    val family = variableFamily(if (rightToLeft) Res.font.vazirmatn_variable else Res.font.inter_variable)
    return remember(family) { typographyOf(family) }
}

private fun typographyOf(family: FontFamily): Typography {
    val base = Typography()
    return Typography(
        displayLarge = base.displayLarge.copy(fontFamily = family),
        displayMedium = base.displayMedium.copy(fontFamily = family),
        displaySmall = base.displaySmall.copy(fontFamily = family),
        headlineLarge = base.headlineLarge.copy(fontFamily = family),
        headlineMedium = base.headlineMedium.copy(fontFamily = family),
        headlineSmall = base.headlineSmall.copy(fontFamily = family),
        titleLarge = base.titleLarge.copy(fontFamily = family, fontWeight = FontWeight.SemiBold),
        titleMedium = base.titleMedium.copy(fontFamily = family),
        titleSmall = base.titleSmall.copy(fontFamily = family),
        bodyLarge = base.bodyLarge.copy(fontFamily = family),
        bodyMedium = base.bodyMedium.copy(fontFamily = family),
        bodySmall = base.bodySmall.copy(fontFamily = family),
        labelLarge = base.labelLarge.copy(fontFamily = family),
        labelMedium = base.labelMedium.copy(fontFamily = family),
        labelSmall = base.labelSmall.copy(fontFamily = family),
    )
}
