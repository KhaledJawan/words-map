package dev.nefrin.wordsmap.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TimePicker
import androidx.compose.material3.TimePickerDefaults
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.reminder.ReminderSchedule
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_bell
import dev.nefrin.wordsmap.resources.ic_check
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.AppBottomSheet
import dev.nefrin.wordsmap.ui.components.PillButton
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.close
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.painterResource

// The reminder's own rows start under the text of the "Daily reminder" row, past its icon.
private val SubRowStart = 56.dp

private val weekdayNames = listOf(
    Strings.weekday_1, Strings.weekday_2, Strings.weekday_3, Strings.weekday_4,
    Strings.weekday_5, Strings.weekday_6, Strings.weekday_7,
)
private val weekdayShortNames = listOf(
    Strings.weekday_short_1, Strings.weekday_short_2, Strings.weekday_short_3, Strings.weekday_short_4,
    Strings.weekday_short_5, Strings.weekday_short_6, Strings.weekday_short_7,
)

/** "Time … 19:00": opens the clock. */
@Composable
internal fun ReminderTimeRow(schedule: ReminderSchedule, onClick: () -> Unit) {
    val primary = MaterialTheme.colorScheme.primary
    SectionDivider()
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .heightIn(min = 52.dp)
            .padding(start = SubRowStart, end = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = stringResource(Strings.settings_reminder_time),
            modifier = Modifier.weight(1f),
            color = appColors.heading,
            style = MaterialTheme.typography.bodyLarge,
        )
        Text(
            text = schedule.timeLabel,
            modifier = Modifier
                .clip(CircleShape)
                .background(primary.copy(alpha = if (appColors.isDark) 0.24f else 0.12f))
                .padding(horizontal = 14.dp, vertical = 6.dp),
            color = primary,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold, textDirection = TextDirection.Ltr),
        )
    }
}

/**
 * The days of the week as round buttons: marked days get the reminder, the others are
 * skipped. The week starts on Saturday in Farsi and Pashto, on Monday otherwise.
 */
@Composable
internal fun ReminderDays(days: Set<Int>, weekStartsOnSaturday: Boolean, onToggle: (Int) -> Unit) {
    val order = if (weekStartsOnSaturday) listOf(6, 7, 1, 2, 3, 4, 5) else (1..7).toList()
    SectionDivider()
    Column(Modifier.fillMaxWidth().padding(start = SubRowStart, end = 16.dp, top = 12.dp, bottom = 14.dp)) {
        Text(
            text = stringResource(Strings.settings_reminder_days),
            color = appColors.heading,
            style = MaterialTheme.typography.bodyLarge,
        )
        Spacer(Modifier.height(10.dp))
        BoxWithConstraints(Modifier.fillMaxWidth()) {
            val size = minOf(40.dp, (maxWidth - 6.dp * 6) / 7)
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                for (day in order) DayButton(day, selected = day in days, size = size, onToggle = onToggle)
            }
        }
        Spacer(Modifier.height(10.dp))
        Text(
            text = stringResource(Strings.settings_reminder_days_hint),
            color = appColors.textMuted,
            style = MaterialTheme.typography.bodySmall,
        )
    }
}

@Composable
private fun DayButton(day: Int, selected: Boolean, size: Dp, onToggle: (Int) -> Unit) {
    val primary = MaterialTheme.colorScheme.primary
    val name = stringResource(weekdayNames[day - 1])
    Box(
        modifier = Modifier
            .size(size)
            .clip(CircleShape)
            .background(if (selected) primary else appColors.tile)
            .border(1.dp, if (selected) primary else appColors.tileBorder, CircleShape)
            .toggleable(value = selected, role = Role.Checkbox, onValueChange = { onToggle(day) })
            .semantics { contentDescription = name },
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = stringResource(weekdayShortNames[day - 1]),
            // The full day name above is what a screen reader says.
            modifier = Modifier.clearAndSetSemantics {},
            color = if (selected) Color.White else appColors.textMuted,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
            maxLines = 1,
        )
    }
}

/** Android only: the reminder can come late until exact timing is allowed. */
@Composable
internal fun ExactTimeHint(onAllow: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(start = SubRowStart, end = 16.dp, bottom = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = stringResource(Strings.reminder_exact_hint),
            modifier = Modifier.weight(1f),
            color = appColors.textMuted,
            style = MaterialTheme.typography.bodySmall,
        )
        Spacer(Modifier.width(12.dp))
        Text(
            text = stringResource(Strings.reminder_exact_allow),
            modifier = Modifier
                .clip(CircleShape)
                .clickable(role = Role.Button, onClick = onAllow)
                .padding(horizontal = 12.dp, vertical = 8.dp),
            color = MaterialTheme.colorScheme.primary,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
        )
    }
}

/** A 24-hour clock for the reminder time. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun ReminderTimeSheet(schedule: ReminderSchedule, onApply: (minuteOfDay: Int) -> Unit, onDismiss: () -> Unit) {
    val state = rememberTimePickerState(initialHour = schedule.hour, initialMinute = schedule.minute, is24Hour = true)
    val primary = MaterialTheme.colorScheme.primary
    val colors = appColors
    AppBottomSheet(onDismiss = onDismiss) { sheet ->
        Column(
            modifier = Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = stringResource(Strings.reminder_time_title),
                modifier = Modifier.fillMaxWidth().padding(bottom = 16.dp),
                color = colors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
            )
            // A clock reads the same way in every language.
            ProvideDirection(LayoutDirection.Ltr) {
                TimePicker(
                    state = state,
                    colors = TimePickerDefaults.colors(
                        clockDialColor = colors.tile,
                        clockDialSelectedContentColor = Color.White,
                        clockDialUnselectedContentColor = colors.heading,
                        selectorColor = primary,
                        containerColor = MaterialTheme.colorScheme.surface,
                        timeSelectorSelectedContainerColor = primary.copy(alpha = if (colors.isDark) 0.24f else 0.14f),
                        timeSelectorUnselectedContainerColor = colors.tile,
                        timeSelectorSelectedContentColor = primary,
                        timeSelectorUnselectedContentColor = colors.heading,
                    ),
                )
            }
            Spacer(Modifier.height(8.dp))
            Row {
                PillButton(
                    text = stringResource(Strings.common_cancel),
                    background = colors.tile,
                    contentColor = colors.heading,
                    onClick = { sheet.close() },
                    modifier = Modifier.weight(1f),
                )
                Spacer(Modifier.width(10.dp))
                PillButton(
                    text = stringResource(Strings.common_apply),
                    icon = Res.drawable.ic_check,
                    background = colors.headerButton,
                    contentColor = colors.onHeaderButton,
                    onClick = {
                        onApply(state.hour * 60 + state.minute)
                        sheet.close()
                    },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

/** Shown when the phone does not allow the app's notifications: where to allow them. */
@Composable
internal fun NotificationsBlockedSheet(onOpenSettings: () -> Unit, onDismiss: () -> Unit) {
    val colors = appColors
    AppBottomSheet(onDismiss = onDismiss) { sheet ->
        Column(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(painterResource(Res.drawable.ic_bell), contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                Spacer(Modifier.width(10.dp))
                Text(
                    text = stringResource(Strings.notifications_blocked_title),
                    color = colors.heading,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                )
            }
            Spacer(Modifier.height(8.dp))
            Text(
                text = stringResource(Strings.notifications_blocked_text),
                color = colors.textMuted,
                style = MaterialTheme.typography.bodyMedium,
            )
            Spacer(Modifier.height(18.dp))
            Row {
                PillButton(
                    text = stringResource(Strings.common_close),
                    background = colors.tile,
                    contentColor = colors.heading,
                    onClick = { sheet.close() },
                    modifier = Modifier.weight(1f),
                )
                Spacer(Modifier.width(10.dp))
                PillButton(
                    text = stringResource(Strings.notifications_open_settings),
                    background = colors.headerButton,
                    contentColor = colors.onHeaderButton,
                    onClick = { sheet.close(then = onOpenSettings) },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}
