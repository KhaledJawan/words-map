package dev.nefrin.wordsmap.ui.profile

import dev.nefrin.wordsmap.ui.update.UpdatesSection
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.lifecycle.compose.LifecycleResumeEffect
import dev.nefrin.wordsmap.reminder.rememberNotificationPermission
import kotlinx.coroutines.launch
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.ThemeMode
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.StringRes
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_alarm_clock
import dev.nefrin.wordsmap.resources.ic_bell
import dev.nefrin.wordsmap.resources.ic_check
import dev.nefrin.wordsmap.resources.ic_chevron_right
import dev.nefrin.wordsmap.resources.ic_globe
import dev.nefrin.wordsmap.resources.ic_info
import dev.nefrin.wordsmap.resources.ic_languages
import dev.nefrin.wordsmap.resources.ic_moon
import dev.nefrin.wordsmap.resources.ic_palette
import dev.nefrin.wordsmap.resources.ic_smartphone
import dev.nefrin.wordsmap.resources.ic_sun
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.AppBottomSheet
import dev.nefrin.wordsmap.ui.components.WordPairSheet
import dev.nefrin.wordsmap.ui.components.wordPairLabel
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

private enum class ProfileSheet { NONE, LANGUAGE, WORD_PAIR, THEME, REMINDER_TIME, NOTIFICATIONS_BLOCKED }

private const val PRIVACY_POLICY_URL = "https://nefrin.dev/wordsmap/privacy"

/** The Profile tab. There is no account; it holds the app's settings. */
@Composable
fun ProfileScreen(viewModel: AppViewModel) {
    var sheet by rememberSaveable { mutableStateOf(ProfileSheet.NONE) }
    val permission = rememberNotificationPermission()
    val scope = rememberCoroutineScope()
    // Notifications can be blocked in the phone settings at any time; look again on every return.
    var allowed by remember { mutableStateOf(true) }
    var exactAllowed by remember { mutableStateOf(true) }
    LifecycleResumeEffect(permission) {
        val check = scope.launch { allowed = permission.isGranted() }
        exactAllowed = permission.isExactTimeAllowed()
        // Exact timing may have just been allowed in the settings.
        viewModel.refreshReminder()
        onPauseOrDispose { check.cancel() }
    }
    // Asks for the permission first; when it is refused, explains where to allow it.
    val whenAllowed = { turnOn: () -> Unit ->
        scope.launch {
            allowed = permission.request()
            if (allowed) turnOn() else sheet = ProfileSheet.NOTIFICATIONS_BLOCKED
        }
        Unit
    }
    val notificationsOn = viewModel.appNotifications && allowed
    val reminderOn = notificationsOn && viewModel.dailyReminder

    Column(
        Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 20.dp),
    ) {
        Text(
            text = stringResource(Strings.settings_title),
            color = appColors.heading,
            style = MaterialTheme.typography.titleLarge,
        )
        Spacer(Modifier.height(20.dp))
        SettingsSection(stringResource(Strings.settings_language)) {
            SettingsRow(
                icon = Res.drawable.ic_globe,
                title = stringResource(Strings.settings_app_language),
                subtitle = viewModel.appLanguage.nativeName,
                onClick = { sheet = ProfileSheet.LANGUAGE },
            )
            SectionDivider()
            SettingsRow(
                icon = Res.drawable.ic_languages,
                title = stringResource(Strings.word_pair),
                subtitle = wordPairLabel(viewModel.sourceLanguage, viewModel.targetLanguage),
                onClick = { sheet = ProfileSheet.WORD_PAIR },
            )
        }
        Spacer(Modifier.height(18.dp))
        SettingsSection(stringResource(Strings.settings_theme)) {
            SettingsRow(
                icon = Res.drawable.ic_palette,
                title = stringResource(Strings.settings_theme),
                subtitle = stringResource(viewModel.themeMode.label),
                onClick = { sheet = ProfileSheet.THEME },
            )
        }
        Spacer(Modifier.height(18.dp))
        SettingsSection(stringResource(Strings.settings_notifications_title)) {
            SwitchRow(
                icon = Res.drawable.ic_bell,
                title = stringResource(Strings.settings_notifications),
                checked = notificationsOn,
                onCheckedChange = { on ->
                    if (on) whenAllowed { viewModel.changeAppNotifications(true) } else viewModel.changeAppNotifications(false)
                },
            )
            SectionDivider()
            SwitchRow(
                icon = Res.drawable.ic_alarm_clock,
                title = stringResource(Strings.settings_daily_reminder),
                checked = reminderOn,
                onCheckedChange = { on ->
                    if (on) whenAllowed { viewModel.changeDailyReminder(true) } else viewModel.changeDailyReminder(false)
                },
            )
            if (reminderOn) {
                ReminderTimeRow(viewModel.reminderSchedule, onClick = { sheet = ProfileSheet.REMINDER_TIME })
                ReminderDays(
                    days = viewModel.reminderSchedule.days,
                    weekStartsOnSaturday = viewModel.appLanguage.isRtl,
                    onToggle = viewModel::toggleReminderDay,
                )
                if (!exactAllowed) ExactTimeHint(onAllow = permission::allowExactTime)
            }
        }
        Spacer(Modifier.height(18.dp))
        UpdatesSection(viewModel.updates, language = viewModel.appLanguage.code)
        Spacer(Modifier.height(18.dp))
        SettingsSection(stringResource(Strings.settings_about)) {
            // The stores require the privacy policy to be reachable from inside the app.
            val uriHandler = LocalUriHandler.current
            SettingsRow(
                icon = Res.drawable.ic_info,
                title = stringResource(Strings.settings_privacy_policy),
                onClick = { runCatching { uriHandler.openUri(PRIVACY_POLICY_URL) } },
            )
        }
        Spacer(Modifier.height(12.dp))
    }

    when (sheet) {
        ProfileSheet.NONE -> Unit
        ProfileSheet.LANGUAGE -> ChoiceSheet(
            title = stringResource(Strings.settings_select_language),
            options = AppLanguage.interfaceLanguages,
            selected = viewModel.appLanguage,
            icon = { Res.drawable.ic_globe },
            label = { it.nativeName },
            onSelect = viewModel::changeAppLanguage,
            onDismiss = { sheet = ProfileSheet.NONE },
        )
        ProfileSheet.WORD_PAIR -> WordPairSheet(
            source = viewModel.sourceLanguage,
            target = viewModel.targetLanguage,
            onApply = viewModel::changeWordPair,
            onDismiss = { sheet = ProfileSheet.NONE },
        )
        ProfileSheet.THEME -> ChoiceSheet(
            title = stringResource(Strings.settings_theme),
            options = ThemeMode.entries,
            selected = viewModel.themeMode,
            icon = { it.icon },
            label = { stringResource(it.label) },
            onSelect = viewModel::changeThemeMode,
            onDismiss = { sheet = ProfileSheet.NONE },
        )
        ProfileSheet.REMINDER_TIME -> ReminderTimeSheet(
            schedule = viewModel.reminderSchedule,
            onApply = viewModel::changeReminderTime,
            onDismiss = { sheet = ProfileSheet.NONE },
        )
        ProfileSheet.NOTIFICATIONS_BLOCKED -> NotificationsBlockedSheet(
            onOpenSettings = permission::openSettings,
            onDismiss = { sheet = ProfileSheet.NONE },
        )
    }
}

private val ThemeMode.label: StringRes
    get() = when (this) {
        ThemeMode.SYSTEM -> Strings.settings_theme_system
        ThemeMode.LIGHT -> Strings.settings_theme_light
        ThemeMode.DARK -> Strings.settings_theme_dark
    }

private val ThemeMode.icon: DrawableResource
    get() = when (this) {
        ThemeMode.SYSTEM -> Res.drawable.ic_smartphone
        ThemeMode.LIGHT -> Res.drawable.ic_sun
        ThemeMode.DARK -> Res.drawable.ic_moon
    }

@Composable
internal fun SettingsSection(title: String, content: @Composable () -> Unit) {
    val shape = RoundedCornerShape(18.dp)
    Text(
        text = title,
        modifier = Modifier.padding(start = 4.dp, bottom = 8.dp),
        color = appColors.heading.copy(alpha = appColors.heading.alpha * 0.75f),
        style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
    )
    Column(
        Modifier
            .fillMaxWidth()
            .clip(shape)
            .background(MaterialTheme.colorScheme.surface)
            .border(1.dp, appColors.divider.copy(alpha = 0.14f), shape),
    ) {
        content()
    }
}

@Composable
internal fun SectionDivider() {
    Box(Modifier.fillMaxWidth().height(1.dp).background(appColors.divider.copy(alpha = 0.12f)))
}

@Composable
internal fun SettingsRow(
    icon: DrawableResource,
    title: String,
    onClick: () -> Unit,
    subtitle: String? = null,
    trailingIcon: DrawableResource? = Res.drawable.ic_chevron_right,
) {
    val accent = MaterialTheme.colorScheme.primary
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .heightIn(min = if (subtitle == null) 56.dp else 72.dp)
            .padding(start = 16.dp, end = 24.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(painterResource(icon), contentDescription = null, tint = accent)
        Spacer(Modifier.width(16.dp))
        Column(Modifier.weight(1f)) {
            Text(title, color = appColors.heading, style = MaterialTheme.typography.bodyLarge)
            if (subtitle != null) {
                Text(
                    text = subtitle,
                    color = appColors.textMuted,
                    style = MaterialTheme.typography.bodyMedium.copy(fontSize = 13.sp),
                )
            }
        }
        if (trailingIcon != null) {
            Spacer(Modifier.width(16.dp))
            Icon(painterResource(trailingIcon), contentDescription = null, tint = accent)
        }
    }
}

@Composable
internal fun SwitchRow(icon: DrawableResource, title: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .toggleable(value = checked, role = Role.Switch, onValueChange = onCheckedChange)
            .heightIn(min = 56.dp)
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(painterResource(icon), contentDescription = null, tint = MaterialTheme.colorScheme.primary)
        Spacer(Modifier.width(16.dp))
        Text(title, modifier = Modifier.weight(1f), color = appColors.heading, style = MaterialTheme.typography.bodyLarge)
        Spacer(Modifier.width(16.dp))
        // The row is the control; the switch only shows the state.
        Switch(checked = checked, onCheckedChange = null)
    }
}

/** Sheet listing [options] with a check mark on the [selected] one. */
@Composable
private fun <T> ChoiceSheet(
    title: String,
    options: List<T>,
    selected: T,
    icon: (T) -> DrawableResource,
    label: @Composable (T) -> String,
    onSelect: (T) -> Unit,
    onDismiss: () -> Unit,
) {
    AppBottomSheet(onDismiss = onDismiss) { sheet ->
        Text(
            text = title,
            modifier = Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 12.dp),
            color = appColors.heading,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
        )
        for (option in options) {
            SettingsRow(
                icon = icon(option),
                title = label(option),
                trailingIcon = if (option == selected) Res.drawable.ic_check else null,
                // Applied once the sheet is gone: changing the language restarts the screen.
                onClick = { sheet.close(then = { onSelect(option) }) },
            )
        }
        Spacer(Modifier.height(12.dp))
    }
}
