package dev.nefrin.wordsmap.ui.update

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import dev.nefrin.wordsmap.platform.formatDateTime
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_chevron_right
import dev.nefrin.wordsmap.resources.ic_layers
import dev.nefrin.wordsmap.resources.ic_rotate
import dev.nefrin.wordsmap.resources.ic_smartphone
import dev.nefrin.wordsmap.resources.ic_x
import dev.nefrin.wordsmap.resources.splash_logo
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.profile.SectionDivider
import dev.nefrin.wordsmap.ui.profile.SettingsSection
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import dev.nefrin.wordsmap.update.AppUpdates
import dev.nefrin.wordsmap.update.InstalledVersion
import dev.nefrin.wordsmap.update.StoreOffer
import dev.nefrin.wordsmap.update.UpdateDownload
import dev.nefrin.wordsmap.update.UpdateNeed
import dev.nefrin.wordsmap.update.UpdatePrompt
import dev.nefrin.wordsmap.update.UpdateStatus
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

/**
 * What the update check shows over the whole app: the update dialog, and the progress of a
 * Google Play download with its "Restart" once it is done. [language] picks the release notes.
 */
@Composable
fun BoxScope.UpdateLayer(updates: AppUpdates, language: String) {
    val download by updates.download.collectAsState()
    DownloadBanner(
        download = download,
        onInstall = updates::installDownloaded,
        onRetry = {
            updates.clearFailedDownload()
            updates.update()
        },
        onDismissFailed = updates::clearFailedDownload,
        modifier = Modifier.align(Alignment.BottomCenter),
    )
    updates.prompt?.let { prompt ->
        UpdateDialog(
            prompt = prompt,
            installed = updates.installed,
            language = language,
            onUpdate = updates::update,
            onLater = updates::later,
        )
    }
}

@Composable
private fun UpdateDialog(
    prompt: UpdatePrompt,
    installed: InstalledVersion,
    language: String,
    onUpdate: () -> Unit,
    onLater: () -> Unit,
) {
    val colors = appColors
    Dialog(
        onDismissRequest = { if (!prompt.blocking) onLater() },
        properties = DialogProperties(
            dismissOnBackPress = !prompt.blocking,
            dismissOnClickOutside = !prompt.blocking,
            usePlatformDefaultWidth = false,
        ),
    ) {
        Column(
            modifier = Modifier
                .padding(24.dp)
                .widthIn(max = 420.dp)
                .fillMaxWidth()
                .clip(RoundedCornerShape(24.dp))
                .background(MaterialTheme.colorScheme.surface)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 22.dp, vertical = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            AppIcon()
            Spacer(Modifier.height(16.dp))
            Text(
                text = stringResource(if (prompt.required) Strings.update_title_required else Strings.update_title),
                modifier = Modifier.semantics { heading() },
                color = colors.heading,
                style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.ExtraBold),
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(16.dp))
            VersionChange(installed.name, prompt.release.latestVersion)
            if (prompt.required) {
                Spacer(Modifier.height(16.dp))
                Text(
                    text = stringResource(if (prompt.blocking) Strings.update_required_text else Strings.update_required_soft_text),
                    color = colors.heading,
                    style = MaterialTheme.typography.bodyMedium,
                    textAlign = TextAlign.Center,
                )
            }
            prompt.release.notesIn(language)?.let { notes ->
                Spacer(Modifier.height(18.dp))
                Text(
                    text = stringResource(Strings.update_whats_new),
                    modifier = Modifier.fillMaxWidth(),
                    color = colors.textMuted,
                    style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
                )
                Spacer(Modifier.height(6.dp))
                Text(
                    text = notes,
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(14.dp))
                        .background(colors.tile)
                        .padding(horizontal = 14.dp, vertical = 12.dp),
                    color = colors.text,
                    style = MaterialTheme.typography.bodyMedium.copy(textDirection = TextDirection.Content),
                )
            }
            Spacer(Modifier.height(22.dp))
            PillButton(stringResource(Strings.update_now), primary = true, onClick = onUpdate, modifier = Modifier.fillMaxWidth())
            if (!prompt.blocking) {
                Spacer(Modifier.height(8.dp))
                PillButton(
                    text = stringResource(if (prompt.required) Strings.update_continue else Strings.update_later),
                    primary = false,
                    onClick = onLater,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }
}

/** The app icon: the logo on its dark green, as on the home screen. */
@Composable
private fun AppIcon() {
    Box(
        modifier = Modifier
            .size(72.dp)
            .clip(RoundedCornerShape(20.dp))
            .background(Color(0xFF031918))
            .clearAndSetSemantics {},
        contentAlignment = Alignment.Center,
    ) {
        // The logo is drawn like an adaptive icon layer: 108 units, of which the middle 72 show.
        Image(painterResource(Res.drawable.splash_logo), contentDescription = null, modifier = Modifier.requiredSize(108.dp))
    }
}

/** "2.2.0 > 2.3.0", with what each one is: the installed version and the new one. */
@Composable
private fun VersionChange(installed: String, latest: String) {
    val colors = appColors
    val installedLabel = stringResource(Strings.update_installed)
    val newLabel = stringResource(Strings.update_new)
    // Old on the left, new on the right, in every language.
    ProvideDirection(LayoutDirection.Ltr) {
        Row(
            modifier = Modifier.semantics(mergeDescendants = true) { contentDescription = "$installedLabel $installed, $newLabel $latest" },
            verticalAlignment = Alignment.Bottom,
        ) {
            VersionPill(installedLabel, installed, background = colors.tile, content = colors.tileText)
            Icon(
                painter = painterResource(Res.drawable.ic_chevron_right),
                contentDescription = null,
                modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp).size(20.dp),
                tint = colors.textMuted,
            )
            VersionPill(newLabel, latest, background = colors.headerButton, content = colors.onHeaderButton)
        }
    }
}

@Composable
private fun VersionPill(label: String, version: String, background: Color, content: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(label, color = appColors.textMuted, style = MaterialTheme.typography.labelMedium)
        Spacer(Modifier.height(4.dp))
        Text(
            text = version.ifEmpty { "–" },
            modifier = Modifier.clip(CircleShape).background(background).padding(horizontal = 14.dp, vertical = 7.dp),
            color = content,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold, textDirection = TextDirection.Ltr),
        )
    }
}

/** The app's black pill, or a grey one for the second choice. */
@Composable
private fun PillButton(
    text: String,
    primary: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: DrawableResource? = null,
    enabled: Boolean = true,
) {
    val colors = appColors
    val content = if (primary) colors.onHeaderButton else colors.tileText
    Row(
        modifier = modifier
            .heightIn(min = 50.dp)
            .alpha(if (enabled) 1f else 0.45f)
            .clip(CircleShape)
            .background(if (primary) colors.headerButton else colors.tile)
            .then(if (primary) Modifier else Modifier.border(1.dp, colors.tileBorder, CircleShape))
            .clickable(enabled = enabled, role = Role.Button, onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Icon(painterResource(icon), contentDescription = null, modifier = Modifier.size(18.dp), tint = content)
            Spacer(Modifier.width(8.dp))
        }
        Text(
            text = text,
            color = content,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.ExtraBold, fontSize = 15.sp),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            autoSize = TextAutoSize.StepBased(minFontSize = 11.sp, maxFontSize = 15.sp, stepSize = 0.5.sp),
        )
    }
}

/**
 * A Google Play download inside the app: its progress while the app stays in use, then the
 * button that installs it. Hidden while there is none.
 */
@Composable
private fun DownloadBanner(
    download: UpdateDownload?,
    onInstall: () -> Unit,
    onRetry: () -> Unit,
    onDismissFailed: () -> Unit,
    modifier: Modifier = Modifier,
) {
    // A hidden progress comes back once the download is ready.
    var hidden by remember(download is UpdateDownload.Running) { mutableStateOf(false) }
    val colors = appColors
    AnimatedVisibility(
        visible = download != null && !hidden,
        modifier = modifier,
        enter = slideInVertically { it } + fadeIn(),
        exit = slideOutVertically { it } + fadeOut(),
    ) {
        val shown = download ?: return@AnimatedVisibility
        Column(
            modifier = Modifier
                .navigationBarsPadding()
                // Above the bottom bar of the tabs.
                .padding(start = 16.dp, end = 16.dp, bottom = 92.dp)
                .widthIn(max = 520.dp)
                .fillMaxWidth()
                .clip(RoundedCornerShape(20.dp))
                .background(colors.headerButton)
                .semantics { liveRegion = LiveRegionMode.Polite }
                .padding(start = 18.dp, end = 8.dp, top = 10.dp, bottom = 10.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = stringResource(
                        when (shown) {
                            is UpdateDownload.Running -> Strings.update_downloading
                            UpdateDownload.Ready -> Strings.update_ready
                            UpdateDownload.Failed -> Strings.update_failed
                        },
                    ),
                    modifier = Modifier.weight(1f),
                    color = colors.onHeaderButton,
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold),
                )
                when (shown) {
                    is UpdateDownload.Running -> shown.fraction?.let { fraction ->
                        Text(
                            text = "⁦${(fraction * 100).toInt()}%⁩",
                            modifier = Modifier.padding(horizontal = 8.dp),
                            color = colors.onHeaderButton.copy(alpha = 0.8f),
                            style = MaterialTheme.typography.labelLarge,
                        )
                    }
                    UpdateDownload.Ready -> BannerAction(stringResource(Strings.update_restart), onInstall)
                    UpdateDownload.Failed -> BannerAction(stringResource(Strings.update_retry), onRetry)
                }
                if (shown != UpdateDownload.Ready) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .clickable(role = Role.Button) { if (shown == UpdateDownload.Failed) onDismissFailed() else hidden = true },
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(
                            painter = painterResource(Res.drawable.ic_x),
                            contentDescription = stringResource(Strings.common_close),
                            modifier = Modifier.size(18.dp),
                            tint = colors.onHeaderButton.copy(alpha = 0.8f),
                        )
                    }
                }
            }
            if (shown is UpdateDownload.Running) {
                Spacer(Modifier.height(6.dp))
                Bar(shown.fraction ?: 0f, colors.onHeaderButton, Modifier.padding(end = 10.dp, bottom = 4.dp))
            }
        }
    }
}

@Composable
private fun BannerAction(text: String, onClick: () -> Unit) {
    Text(
        text = text,
        modifier = Modifier
            .padding(start = 8.dp)
            .clip(CircleShape)
            .background(appColors.onHeaderButton)
            .clickable(role = Role.Button, onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp),
        color = appColors.headerButton,
        style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.ExtraBold),
    )
}

@Composable
private fun Bar(fraction: Float, color: Color, modifier: Modifier = Modifier) {
    val shown by animateFloatAsState(fraction.coerceIn(0f, 1f), tween(300), label = "updateDownload")
    Box(modifier.fillMaxWidth().height(4.dp).clip(CircleShape).background(color.copy(alpha = 0.2f))) {
        Box(Modifier.fillMaxWidth(shown).fillMaxHeight().clip(CircleShape).background(color))
    }
}

/**
 * The "App updates" section of Settings: the installed version and build, the last check,
 * what it found, and the buttons to check again and to update.
 */
@Composable
fun UpdatesSection(updates: AppUpdates, language: String) {
    val colors = appColors
    val download by updates.download.collectAsState()
    val installed = updates.installed
    val latest = updates.release?.latestVersion.orEmpty()
    val checking = updates.status == UpdateStatus.CHECKING
    SettingsSection(stringResource(Strings.settings_updates)) {
        InfoRow(Res.drawable.ic_smartphone, stringResource(Strings.update_version), installed.name.ifEmpty { "–" })
        SectionDivider()
        InfoRow(Res.drawable.ic_layers, stringResource(Strings.update_build), installed.build.toString())
        SectionDivider()
        InfoRow(
            icon = Res.drawable.ic_rotate,
            label = stringResource(Strings.update_last_checked),
            value = updates.lastChecked?.let { formatDateTime(it, language) } ?: stringResource(Strings.update_never),
        )
        SectionDivider()
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 56.dp)
                .semantics(mergeDescendants = true) { liveRegion = LiveRegionMode.Polite }
                .padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(Modifier.size(24.dp), contentAlignment = Alignment.Center) {
                if (checking) {
                    CircularProgressIndicator(Modifier.size(18.dp), strokeWidth = 2.dp, color = MaterialTheme.colorScheme.primary)
                } else {
                    Box(Modifier.size(10.dp).clip(CircleShape).background(statusColor(updates)))
                }
            }
            Spacer(Modifier.width(16.dp))
            Column(Modifier.weight(1f)) {
                Text(stringResource(Strings.update_status), color = colors.heading, style = MaterialTheme.typography.bodyLarge)
                Text(
                    text = statusText(updates, latest),
                    color = colors.textMuted,
                    style = MaterialTheme.typography.bodyMedium.copy(fontSize = 13.sp),
                )
                // After a failed check, what the last one found still counts.
                if (updates.status == UpdateStatus.FAILED && updates.need != UpdateNeed.NONE) {
                    Text(
                        text = needText(updates, latest),
                        color = colors.textMuted,
                        style = MaterialTheme.typography.bodyMedium.copy(fontSize = 13.sp),
                    )
                }
            }
        }
        val running = download as? UpdateDownload.Running
        if (running != null) {
            Bar(running.fraction ?: 0f, MaterialTheme.colorScheme.primary, Modifier.padding(start = 56.dp, end = 16.dp, bottom = 12.dp))
        }
        SectionDivider()
        val canUpdate = updates.need != UpdateNeed.NONE && updates.offer != StoreOffer.NotYet && download == null
        Row(Modifier.fillMaxWidth().padding(16.dp), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            when {
                download == UpdateDownload.Ready -> PillButton(
                    text = stringResource(Strings.update_restart),
                    primary = true,
                    onClick = updates::installDownloaded,
                    modifier = Modifier.weight(1f),
                )
                canUpdate -> PillButton(
                    text = stringResource(Strings.update_now),
                    primary = true,
                    onClick = updates::update,
                    modifier = Modifier.weight(1f),
                )
            }
            PillButton(
                text = stringResource(Strings.update_check),
                primary = !canUpdate && download != UpdateDownload.Ready,
                onClick = updates::checkNow,
                modifier = Modifier.weight(1f),
                icon = Res.drawable.ic_rotate,
                enabled = !checking,
            )
        }
    }
}

@Composable
private fun InfoRow(icon: DrawableResource, label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 52.dp)
            .semantics(mergeDescendants = true) {}
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(painterResource(icon), contentDescription = null, tint = MaterialTheme.colorScheme.primary)
        Spacer(Modifier.width(16.dp))
        Text(label, modifier = Modifier.weight(1f), color = appColors.heading, style = MaterialTheme.typography.bodyLarge)
        Spacer(Modifier.width(12.dp))
        Text(
            text = value,
            color = appColors.textMuted,
            style = MaterialTheme.typography.bodyMedium.copy(textDirection = TextDirection.Content),
            textAlign = TextAlign.End,
        )
    }
}

@Composable
private fun statusText(updates: AppUpdates, latest: String): String = when (updates.status) {
    UpdateStatus.NOT_CHECKED -> stringResource(Strings.update_status_not_checked)
    UpdateStatus.CHECKING -> stringResource(Strings.update_status_checking)
    UpdateStatus.UP_TO_DATE -> stringResource(Strings.update_status_up_to_date)
    UpdateStatus.FAILED -> stringResource(Strings.update_status_failed)
    UpdateStatus.AVAILABLE, UpdateStatus.REQUIRED -> needText(updates, latest)
}

@Composable
private fun needText(updates: AppUpdates, latest: String): String = when {
    updates.offer == StoreOffer.NotYet -> stringResource(Strings.update_status_not_yet, latest)
    updates.need == UpdateNeed.REQUIRED -> stringResource(Strings.update_status_required, latest)
    else -> stringResource(Strings.update_status_available, latest)
}

@Composable
private fun statusColor(updates: AppUpdates): Color = when (updates.status) {
    UpdateStatus.UP_TO_DATE -> Palette.Success
    UpdateStatus.AVAILABLE -> MaterialTheme.colorScheme.primary
    UpdateStatus.REQUIRED -> Palette.AccentOrange
    UpdateStatus.FAILED -> Palette.Failure
    UpdateStatus.NOT_CHECKED, UpdateStatus.CHECKING -> Palette.Grey400
}
