package dev.nefrin.wordsmap.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_book_open
import dev.nefrin.wordsmap.resources.ic_check
import dev.nefrin.wordsmap.resources.ic_chevrons_up_down
import dev.nefrin.wordsmap.resources.ic_languages
import dev.nefrin.wordsmap.resources.ic_sparkles
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

/** Sheet for choosing the learning language and the language of the meanings. */
@Composable
fun WordPairSheet(
    source: AppLanguage,
    target: AppLanguage,
    onApply: (source: AppLanguage, target: AppLanguage) -> Unit,
    onDismiss: () -> Unit,
) {
    val options = AppLanguage.wordLanguages
    var pickedSource by rememberSaveable { mutableStateOf(source) }
    var pickedTarget by rememberSaveable { mutableStateOf(target) }
    val tint = MaterialTheme.colorScheme.surfaceContainerHighest.copy(alpha = 0.55f)

    AppBottomSheet(onDismiss = onDismiss) { sheet ->
        Column(Modifier.padding(start = 16.dp, end = 16.dp, bottom = 16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(painterResource(Res.drawable.ic_languages), null, tint = MaterialTheme.colorScheme.primary)
                Spacer(Modifier.width(8.dp))
                SectionTitle(stringResource(Strings.word_pair))
            }
            Spacer(Modifier.height(6.dp))
            Text(
                text = stringResource(Strings.word_pair_description),
                color = appColors.textMuted.copy(alpha = appColors.textMuted.alpha * 0.8f),
                style = MaterialTheme.typography.bodySmall,
            )
            Spacer(Modifier.height(16.dp))
            LanguageDropdown(
                label = stringResource(Strings.word_pair_learn_in),
                icon = Res.drawable.ic_book_open,
                value = pickedSource,
                options = options,
                onChange = { language ->
                    pickedSource = language
                    if (pickedTarget == language) pickedTarget = options.first { it != language }
                },
            )
            Spacer(Modifier.height(12.dp))
            LanguageDropdown(
                label = stringResource(Strings.word_pair_translate_to),
                icon = Res.drawable.ic_languages,
                value = pickedTarget,
                options = options - pickedSource,
                onChange = { pickedTarget = it },
            )
            Spacer(Modifier.height(14.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(tint, RoundedCornerShape(12.dp))
                    .padding(horizontal = 14.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(
                    painter = painterResource(Res.drawable.ic_sparkles),
                    contentDescription = null,
                    modifier = Modifier.size(16.dp),
                    tint = MaterialTheme.colorScheme.primary,
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    text = "${pickedSource.nativeName}  ->  ${pickedTarget.nativeName}",
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold),
                )
            }
            Spacer(Modifier.height(14.dp))
            Row {
                PillButton(
                    text = stringResource(Strings.common_cancel),
                    background = tint,
                    contentColor = appColors.heading,
                    onClick = { sheet.close() },
                    modifier = Modifier.weight(1f),
                )
                Spacer(Modifier.width(10.dp))
                PillButton(
                    text = stringResource(Strings.common_apply),
                    icon = Res.drawable.ic_check,
                    background = appColors.headerButton,
                    contentColor = appColors.onHeaderButton,
                    onClick = {
                        onApply(pickedSource, pickedTarget)
                        sheet.close()
                    },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

/** "Deutsch -> English": how a word pair is written everywhere in the app. */
fun wordPairLabel(source: AppLanguage, target: AppLanguage): String = "${source.nativeName} -> ${target.nativeName}"

/** Fully rounded button, at least 44dp tall. */
@Composable
fun PillButton(
    text: String,
    background: Color,
    contentColor: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: DrawableResource? = null,
) {
    Row(
        modifier = modifier
            .heightIn(min = 44.dp)
            .clip(CircleShape)
            .background(background)
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Icon(painterResource(icon), null, modifier = Modifier.size(16.dp), tint = contentColor)
            Spacer(Modifier.width(8.dp))
        }
        Text(
            text = text,
            color = contentColor,
            style = MaterialTheme.typography.labelLarge,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

@Composable
private fun LanguageDropdown(
    label: String,
    icon: DrawableResource,
    value: AppLanguage,
    options: List<AppLanguage>,
    onChange: (AppLanguage) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    val shape = RoundedCornerShape(14.dp)
    Column {
        Text(
            text = label,
            color = appColors.heading,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
        )
        Spacer(Modifier.height(8.dp))
        Box {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp)
                    .clip(shape)
                    .background(MaterialTheme.colorScheme.surfaceContainerHighest.copy(alpha = 0.45f))
                    .border(1.dp, appColors.divider.copy(alpha = 0.2f), shape)
                    .clickable { expanded = true }
                    .padding(horizontal = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(painterResource(icon), null, tint = MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(Modifier.width(12.dp))
                Text(
                    text = value.nativeName,
                    modifier = Modifier.weight(1f),
                    color = appColors.heading,
                    style = MaterialTheme.typography.bodyLarge,
                )
                Icon(painterResource(Res.drawable.ic_chevrons_up_down), null, tint = appColors.textMuted)
            }
            DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                for (language in options) {
                    DropdownMenuItem(
                        text = { Text(language.nativeName, color = appColors.heading) },
                        onClick = {
                            expanded = false
                            onChange(language)
                        },
                    )
                }
            }
        }
    }
}
