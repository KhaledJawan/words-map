package dev.nefrin.wordsmap.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_arrow_back
import dev.nefrin.wordsmap.resources.ic_check_circle_2
import dev.nefrin.wordsmap.resources.ic_chevron_right
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

/** Solid colored bar of the lesson screens, with a centred title and a back arrow. */
@Composable
fun ColorTopBar(title: String, color: Color, onBack: () -> Unit) {
    Box(
        Modifier
            .fillMaxWidth()
            .background(color)
            .statusBarsPadding()
            .height(56.dp),
    ) {
        IconButton(onClick = onBack, modifier = Modifier.align(Alignment.CenterStart).padding(start = 4.dp)) {
            Icon(
                painter = painterResource(Res.drawable.ic_arrow_back),
                contentDescription = stringResource(Strings.common_back),
                tint = Color.White,
            )
        }
        Text(
            text = title,
            modifier = Modifier.align(Alignment.Center).padding(horizontal = 56.dp),
            color = Color.White,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.ExtraBold),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

/** Heading above a group of blocks inside a lesson. */
@Composable
fun SectionTitle(text: String, modifier: Modifier = Modifier) {
    Text(
        text = text,
        modifier = modifier,
        color = appColors.heading,
        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.ExtraBold),
    )
}

/** Rounded surface that holds one piece of lesson content. */
@Composable
fun ContentBlock(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 18.dp,
    onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(cornerRadius))
            .background(MaterialTheme.colorScheme.surface)
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)
            .padding(14.dp),
        content = content,
    )
}

/** Large gradient card of the Lessons tab. */
@Composable
fun LessonCard(
    icon: DrawableResource,
    title: String,
    subtitle: String,
    color: Color,
    completed: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    fadeTo: Float = 0.8f,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .softShadow(SoftShadows.lessonCard, cornerRadius = 22.dp)
            .clip(RoundedCornerShape(22.dp))
            .background(Brush.linearGradient(listOf(color, color.copy(alpha = fadeTo))))
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(52.dp)
                .background(Color.White.copy(alpha = 0.16f), RoundedCornerShape(18.dp)),
            contentAlignment = Alignment.Center,
        ) {
            Icon(painterResource(icon), contentDescription = null, modifier = Modifier.size(26.dp), tint = Color.White)
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(
                text = title,
                color = Color.White,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.ExtraBold),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
            if (subtitle.isNotEmpty()) {
                Spacer(Modifier.height(4.dp))
                Text(
                    text = subtitle,
                    color = Color.White.copy(alpha = 0.8f),
                    style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.SemiBold),
                )
            }
        }
        Spacer(Modifier.width(10.dp))
        Icon(
            painter = painterResource(if (completed) Res.drawable.ic_check_circle_2 else Res.drawable.ic_chevron_right),
            contentDescription = null,
            tint = Color.White,
        )
    }
}

/** Centred one-line message for empty and failed states. */
@Composable
fun CenteredMessage(text: String, modifier: Modifier = Modifier) {
    Box(modifier.fillMaxSize().padding(24.dp), contentAlignment = Alignment.Center) {
        Text(text, color = appColors.textMuted, style = MaterialTheme.typography.bodyLarge, textAlign = TextAlign.Center)
    }
}
