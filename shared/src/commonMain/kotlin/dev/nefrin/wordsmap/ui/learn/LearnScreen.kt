package dev.nefrin.wordsmap.ui.learn

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.LifecycleResumeEffect
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.Screen
import dev.nefrin.wordsmap.data.DailyWords
import dev.nefrin.wordsmap.data.LearnSource
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.learn.SourceProgress
import dev.nefrin.wordsmap.reminder.rememberNotificationPermission
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_alarm_clock
import dev.nefrin.wordsmap.resources.ic_check
import dev.nefrin.wordsmap.resources.ic_chevron_right
import dev.nefrin.wordsmap.resources.ic_flame
import dev.nefrin.wordsmap.resources.ic_list_checks
import dev.nefrin.wordsmap.resources.ic_play
import dev.nefrin.wordsmap.resources.ic_plus
import dev.nefrin.wordsmap.resources.ic_repeat
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.AppBottomSheet
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.SoftShadows
import dev.nefrin.wordsmap.ui.components.categoryLabel
import dev.nefrin.wordsmap.ui.components.softShadow
import dev.nefrin.wordsmap.ui.home.ChapterPickerSheet
import dev.nefrin.wordsmap.ui.home.PickerPurpose
import dev.nefrin.wordsmap.ui.home.ScopeButton
import dev.nefrin.wordsmap.ui.home.groupLabel
import dev.nefrin.wordsmap.ui.profile.ExactTimeHint
import dev.nefrin.wordsmap.ui.profile.NotificationsBlockedSheet
import dev.nefrin.wordsmap.ui.profile.ReminderTimeRow
import dev.nefrin.wordsmap.ui.profile.ReminderTimeSheet
import dev.nefrin.wordsmap.ui.profile.SectionDivider
import dev.nefrin.wordsmap.ui.profile.SwitchRow
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import kotlinx.coroutines.launch
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

private enum class LearnSheet { NONE, SOURCE, PLAN, PROGRESS }

/** Sheets that open over the daily plan, which stays open below them. */
private enum class PlanSheet { NONE, REMINDER_TIME, NOTIFICATIONS_BLOCKED }

/**
 * The Learn tab, built like Home: the streak and the chapter the cards come from in the
 * header, today's cards as a deck in the middle with one button into them, and the daily
 * plan (how many words, the reminder) behind a small button below.
 */
@Composable
fun LearnScreen(viewModel: AppViewModel, vocabulary: Vocabulary) {
    val learning = viewModel.learning
    var sheet by rememberSaveable { mutableStateOf(LearnSheet.NONE) }
    var planSheet by rememberSaveable { mutableStateOf(PlanSheet.NONE) }

    // A new day brings new words; look on every return to the tab.
    LifecycleResumeEffect(learning) {
        learning.refresh()
        onPauseOrDispose {}
    }

    // The reminder switch works as in the settings: it asks for the permission first.
    val permission = rememberNotificationPermission()
    val scope = rememberCoroutineScope()
    var allowed by remember { mutableStateOf(true) }
    var exactAllowed by remember { mutableStateOf(true) }
    LifecycleResumeEffect(permission) {
        val check = scope.launch { allowed = permission.isGranted() }
        exactAllowed = permission.isExactTimeAllowed()
        // Exact timing may have just been allowed in the settings.
        viewModel.refreshReminder()
        onPauseOrDispose { check.cancel() }
    }
    val reminderOn = viewModel.appNotifications && viewModel.dailyReminder && allowed

    val total = learning.todayIds.size
    val known = learning.knownCount
    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        BoxWithConstraints(Modifier.fillMaxWidth().padding(start = 16.dp, top = 16.dp, end = 16.dp, bottom = 8.dp)) {
            val interfaceDirection = LocalLayoutDirection.current
            val sourceButtonMaxWidth = maxWidth * 0.62f
            // The header keeps its sides in every language, like the one of Home.
            ProvideDirection(LayoutDirection.Ltr) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    StreakBadge(streak = learning.streak, onClick = { sheet = LearnSheet.PROGRESS })
                    Spacer(Modifier.weight(1f))
                    ScopeButton(
                        label = learnSourceLabel(learning.source, viewModel),
                        large = learning.source is LearnSource.Level,
                        labelDirection = interfaceDirection,
                        maxWidth = sourceButtonMaxWidth,
                        onClick = { sheet = LearnSheet.SOURCE },
                    )
                }
            }
        }
        Column(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp, vertical = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            // Reads every word of the source; worked out again only when the words or the progress change.
            val progress by remember(learning) { derivedStateOf { learning.sourceProgress } }
            if (progress.total > 0) {
                SourceProgressPanel(
                    label = learnSourceLabel(learning.source, viewModel),
                    progress = progress,
                    modifier = Modifier.widthIn(max = 420.dp),
                )
                Spacer(Modifier.height(28.dp))
            }
            TodayDeck(total = total, known = known, modifier = Modifier.widthIn(max = 420.dp))
            Spacer(Modifier.height(36.dp))
            val done = total > 0 && known >= total
            Row(Modifier.widthIn(max = 420.dp).fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                when {
                    total == 0 -> DeckButton(
                        text = stringResource(Strings.learn_choose_words),
                        icon = Res.drawable.ic_list_checks,
                        onClick = { sheet = LearnSheet.SOURCE },
                        modifier = Modifier.weight(1f),
                    )
                    done -> {
                        DeckButton(
                            text = stringResource(Strings.learn_more, learning.wordsPerDay.toString()),
                            icon = Res.drawable.ic_plus,
                            onClick = {
                                learning.learnMore()
                                viewModel.open(Screen.LearnSession)
                            },
                            modifier = Modifier.weight(1f),
                        )
                        DeckButton(
                            text = stringResource(Strings.learn_review),
                            icon = Res.drawable.ic_repeat,
                            onClick = viewModel::reviewToday,
                            modifier = Modifier.weight(1f),
                            secondary = true,
                        )
                    }
                    else -> DeckButton(
                        text = stringResource(if (known == 0) Strings.learn_start else Strings.learn_continue),
                        icon = Res.drawable.ic_play,
                        onClick = viewModel::startLearning,
                        modifier = Modifier.weight(1f),
                    )
                }
            }
            Spacer(Modifier.height(18.dp))
            PlanButton(
                wordsPerDay = learning.wordsPerDay,
                reminder = if (reminderOn) viewModel.reminderSchedule.timeLabel else null,
                onClick = { sheet = LearnSheet.PLAN },
            )
        }
    }

    when (sheet) {
        LearnSheet.NONE -> Unit
        LearnSheet.SOURCE -> ChapterPickerSheet(
            vocabulary = vocabulary,
            purpose = PickerPurpose.LEARN,
            selected = learning.source,
            userLists = viewModel.userLists,
            userWordCount = { listId -> viewModel.userWords.count { listId == null || it.listId == listId } },
            onSelect = learning::changeSource,
            onDismiss = { sheet = LearnSheet.NONE },
        )
        LearnSheet.PROGRESS -> ProgressSheet(
            streak = learning.streak,
            learned = learning.learnedIds.size,
            known = known,
            total = total,
            onDismiss = { sheet = LearnSheet.NONE },
        )
        LearnSheet.PLAN -> AppBottomSheet(onDismiss = { sheet = LearnSheet.NONE }, showHandle = false, topRadius = 24.dp) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(start = 16.dp, end = 16.dp, top = 24.dp, bottom = 24.dp),
            ) {
                Text(
                    text = stringResource(Strings.learn_plan),
                    modifier = Modifier.fillMaxWidth(),
                    color = appColors.heading,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    textAlign = TextAlign.Center,
                )
                Spacer(Modifier.height(16.dp))
                PlanGroup {
                    WordsPerDay(selected = learning.wordsPerDay, onSelect = learning::changeWordsPerDay)
                    SectionDivider()
                    SwitchRow(
                        icon = Res.drawable.ic_alarm_clock,
                        title = stringResource(Strings.settings_daily_reminder),
                        checked = reminderOn,
                        onCheckedChange = { on ->
                            if (!on) {
                                viewModel.changeDailyReminder(false)
                            } else {
                                scope.launch {
                                    allowed = permission.request()
                                    if (allowed) viewModel.changeDailyReminder(true) else planSheet = PlanSheet.NOTIFICATIONS_BLOCKED
                                }
                            }
                        },
                    )
                    if (reminderOn) {
                        ReminderTimeRow(viewModel.reminderSchedule, onClick = { planSheet = PlanSheet.REMINDER_TIME })
                        if (!exactAllowed) ExactTimeHint(onAllow = permission::allowExactTime)
                        Text(
                            text = stringResource(Strings.learn_reminder_hint),
                            modifier = Modifier.padding(start = 56.dp, end = 16.dp, bottom = 14.dp),
                            color = appColors.textMuted,
                            style = MaterialTheme.typography.bodySmall,
                        )
                    }
                }
            }
        }
    }
    when (planSheet) {
        PlanSheet.NONE -> Unit
        PlanSheet.REMINDER_TIME -> ReminderTimeSheet(
            schedule = viewModel.reminderSchedule,
            onApply = viewModel::changeReminderTime,
            onDismiss = { planSheet = PlanSheet.NONE },
        )
        PlanSheet.NOTIFICATIONS_BLOCKED -> NotificationsBlockedSheet(
            onOpenSettings = permission::openSettings,
            onDismiss = { planSheet = PlanSheet.NONE },
        )
    }
}

/** Black circle of the header with the flame and the days in a row; opens the progress. */
@Composable
private fun StreakBadge(streak: Int, onClick: () -> Unit) {
    val fill = appColors.headerButton
    val label = if (streak == 1) stringResource(Strings.learn_streak_day) else stringResource(Strings.learn_streak_days, streak.toString())
    Column(
        modifier = Modifier
            .sizeIn(minWidth = 44.dp, minHeight = 44.dp)
            .drawBehind { drawCircle(fill, radius = size.minDimension / 2) }
            .clip(CircleShape)
            .clickable(role = Role.Button, onClick = onClick)
            .semantics { contentDescription = label }
            .padding(6.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(painterResource(Res.drawable.ic_flame), contentDescription = null, modifier = Modifier.size(14.dp), tint = Palette.AccentOrange)
        Text(
            text = "$streak",
            color = appColors.onHeaderButton,
            style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Bold, lineHeight = 14.sp),
        )
    }
}

/**
 * Today's cards as a small deck: two cards peek out below the one on top, which shows how
 * many of the day's words are known.
 */
@Composable
private fun TodayDeck(total: Int, known: Int, modifier: Modifier = Modifier) {
    val colors = appColors
    val front = if (colors.isDark) Color(0xFF2A2A30) else Color.White
    val behind = if (colors.isDark) Color(0xFF222227) else Color.White
    val shape = RoundedCornerShape(24.dp)
    val cardHeight = 236.dp
    val peek = 12.dp
    Box(modifier.fillMaxWidth().height(cardHeight + peek * 2)) {
        for (depth in 2 downTo 1) {
            Box(
                Modifier
                    .fillMaxWidth()
                    .height(cardHeight)
                    .offset(y = peek * depth)
                    .padding(horizontal = 14.dp * depth)
                    .softShadow(if (colors.isDark) emptyList() else SoftShadows.listCard, cornerRadius = 24.dp)
                    .clip(shape)
                    .background(behind)
                    .border(1.dp, colors.tileBorder.copy(alpha = if (colors.isDark) 1f else 0.6f), shape),
            )
        }
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .height(cardHeight)
                .softShadow(if (colors.isDark) emptyList() else SoftShadows.lessonCard, cornerRadius = 24.dp)
                .clip(shape)
                .background(front)
                .then(if (colors.isDark) Modifier.border(1.dp, colors.tileBorder, shape) else Modifier)
                .padding(horizontal = 24.dp, vertical = 22.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            val done = total > 0 && known >= total
            Text(
                text = stringResource(if (done) Strings.learn_done_title else Strings.learn_today),
                color = colors.textMuted,
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
            )
            Box(Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
                when {
                    total == 0 -> Text(
                        text = stringResource(Strings.learn_empty),
                        color = colors.heading,
                        style = MaterialTheme.typography.bodyLarge,
                        textAlign = TextAlign.Center,
                    )
                    done -> Box(
                        Modifier.size(72.dp).background(Palette.Success.copy(alpha = if (colors.isDark) 0.22f else 0.13f), CircleShape),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(painterResource(Res.drawable.ic_check), contentDescription = null, modifier = Modifier.size(38.dp), tint = Palette.Success)
                    }
                    else -> KnownCount(known = known, total = total)
                }
            }
            if (total > 0) {
                Text(
                    text = when {
                        done -> stringResource(Strings.learn_done_text, total.toString())
                        total - known == 1 -> stringResource(Strings.learn_word_to_go)
                        else -> stringResource(Strings.learn_words_to_go, (total - known).toString())
                    },
                    color = colors.heading,
                    style = MaterialTheme.typography.bodyMedium,
                    textAlign = TextAlign.Center,
                )
                Spacer(Modifier.height(14.dp))
                ProgressBar(known.toFloat() / total)
            }
        }
    }
}

/**
 * The chosen chapter as a whole: its name and the share learned, a bar, and how many of its
 * words are learned and how many are still to go.
 */
@Composable
private fun SourceProgressPanel(label: String, progress: SourceProgress, modifier: Modifier = Modifier) {
    val colors = appColors
    val shape = RoundedCornerShape(18.dp)
    val percent = progress.learned * 100 / progress.total
    Column(
        modifier
            .fillMaxWidth()
            .clip(shape)
            .background(MaterialTheme.colorScheme.surface)
            .border(1.dp, colors.divider.copy(alpha = 0.14f), shape)
            .padding(horizontal = 18.dp, vertical = 16.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = label,
                modifier = Modifier.weight(1f),
                color = colors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.ExtraBold, textDirection = TextDirection.Content),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.width(12.dp))
            Text(
                text = "⁦$percent%⁩",
                color = colors.textMuted,
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
            )
        }
        Spacer(Modifier.height(12.dp))
        ProgressBar(progress.learned.toFloat() / progress.total)
        Spacer(Modifier.height(10.dp))
        Row {
            Text(
                text = stringResource(Strings.learn_chapter_learned, progress.learned.toString()),
                modifier = Modifier.weight(1f),
                color = colors.heading,
                style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold),
            )
            Text(
                text = if (progress.left == 0) {
                    stringResource(Strings.learn_chapter_all)
                } else {
                    stringResource(Strings.learn_chapter_left, progress.left.toString())
                },
                color = colors.textMuted,
                style = MaterialTheme.typography.bodyMedium,
            )
        }
    }
}

/** "4/10": the known words big, the day's words beside them. */
@Composable
private fun KnownCount(known: Int, total: Int) {
    // Reads left to right in every language.
    ProvideDirection(LayoutDirection.Ltr) {
        Row(Modifier.semantics(mergeDescendants = true) {}, verticalAlignment = Alignment.Bottom) {
            Text(
                text = "$known",
                color = appColors.heading,
                style = MaterialTheme.typography.displayMedium.copy(fontWeight = FontWeight.ExtraBold, textDirection = TextDirection.Ltr),
            )
            Text(
                text = "/$total",
                modifier = Modifier.padding(bottom = 8.dp, start = 2.dp),
                color = appColors.textMuted,
                style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold, textDirection = TextDirection.Ltr),
            )
        }
    }
}

@Composable
private fun ProgressBar(progress: Float) {
    val shown by animateFloatAsState(progress.coerceIn(0f, 1f), tween(500), label = "todayProgress")
    Box(
        Modifier
            .fillMaxWidth()
            .height(6.dp)
            .clip(CircleShape)
            .background(appColors.heading.copy(alpha = 0.08f)),
    ) {
        Box(Modifier.fillMaxWidth(shown).fillMaxHeight().clip(CircleShape).background(Palette.Success))
    }
}

/** The black pill under the deck; [secondary] makes it a grey one beside it. */
@Composable
private fun DeckButton(
    text: String,
    icon: DrawableResource,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    secondary: Boolean = false,
) {
    val colors = appColors
    val content = if (secondary) colors.tileText else colors.onHeaderButton
    Row(
        modifier = modifier
            .heightIn(min = 54.dp)
            .clip(CircleShape)
            .background(if (secondary) colors.tile else colors.headerButton)
            .then(if (secondary) Modifier.border(1.dp, colors.tileBorder, CircleShape) else Modifier)
            .clickable(role = Role.Button, onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(painterResource(icon), contentDescription = null, modifier = Modifier.size(18.dp), tint = content)
        Spacer(Modifier.width(8.dp))
        Text(
            text = text,
            color = content,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.ExtraBold, fontSize = 16.sp),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            // Two buttons share the width; a long translation gets smaller rather than cut.
            autoSize = TextAutoSize.StepBased(minFontSize = 11.sp, maxFontSize = 16.sp, stepSize = 0.5.sp),
        )
    }
}

/** "10 words a day · 19:00": the daily plan in one line; opens it. */
@Composable
private fun PlanButton(wordsPerDay: Int, reminder: String?, onClick: () -> Unit) {
    val colors = appColors
    Row(
        modifier = Modifier
            .clip(CircleShape)
            .clickable(role = Role.Button, onClickLabel = stringResource(Strings.learn_plan), onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        PlanPart(Res.drawable.ic_list_checks, stringResource(Strings.learn_per_day_count, wordsPerDay.toString()))
        Text("  ·  ", color = colors.textMuted, style = MaterialTheme.typography.bodyMedium)
        PlanPart(Res.drawable.ic_alarm_clock, reminder ?: stringResource(Strings.learn_reminder_off))
        Spacer(Modifier.width(4.dp))
        Icon(painterResource(Res.drawable.ic_chevron_right), contentDescription = null, modifier = Modifier.size(16.dp), tint = colors.textMuted)
    }
}

@Composable
private fun PlanPart(icon: DrawableResource, text: String) {
    Icon(painterResource(icon), contentDescription = null, modifier = Modifier.size(16.dp), tint = appColors.textMuted)
    Spacer(Modifier.width(6.dp))
    Text(
        text = text,
        color = appColors.textMuted,
        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold, textDirection = TextDirection.Content),
        maxLines = 1,
    )
}

/** A group of rows with the look of the settings sections, without their title. */
@Composable
private fun PlanGroup(content: @Composable () -> Unit) {
    val shape = RoundedCornerShape(18.dp)
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

/** "Words per day" with the counts to choose from; the chosen one is black, like the app's buttons. */
@Composable
private fun WordsPerDay(selected: Int, onSelect: (Int) -> Unit) {
    val colors = appColors
    // A count saved by an earlier choice that is no longer offered still shows as chosen.
    val options = (DailyWords.countOptions + selected).distinct().sorted()
    Column(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, top = 14.dp, bottom = 14.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(painterResource(Res.drawable.ic_list_checks), contentDescription = null, tint = MaterialTheme.colorScheme.primary)
            Spacer(Modifier.width(16.dp))
            Text(stringResource(Strings.learn_per_day), color = colors.heading, style = MaterialTheme.typography.bodyLarge)
        }
        Spacer(Modifier.height(12.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            for (count in options) {
                val isSelected = count == selected
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(40.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (isSelected) colors.headerButton else colors.tile)
                        .border(1.dp, if (isSelected) colors.headerButton else colors.tileBorder, RoundedCornerShape(12.dp))
                        .clickable(role = Role.RadioButton) { onSelect(count) },
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = "$count",
                        color = if (isSelected) colors.onHeaderButton else colors.tileText,
                        style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
                    )
                }
            }
        }
    }
}

/** The streak, the words learned so far and today's progress, from the streak badge. */
@Composable
private fun ProgressSheet(streak: Int, learned: Int, known: Int, total: Int, onDismiss: () -> Unit) {
    AppBottomSheet(onDismiss = onDismiss, showHandle = false, topRadius = 24.dp) {
        Column(
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = stringResource(Strings.learn_progress),
                color = appColors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
            )
            Spacer(Modifier.height(16.dp))
            ProgressRow(stringResource(Strings.learn_streak), "$streak", 0.dp)
            ProgressRow(stringResource(Strings.learn_learned), "$learned", 10.dp)
            // "4 / 10" reads left to right in every language.
            ProgressRow(stringResource(Strings.learn_known_today), "⁦$known / $total⁩", 10.dp)
            Spacer(Modifier.height(12.dp))
        }
    }
}

@Composable
private fun ProgressRow(label: String, value: String, top: Dp) {
    Row(Modifier.fillMaxWidth().padding(top = top), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, style = MaterialTheme.typography.bodyMedium)
        Text(value, style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
    }
}

/** Name of a source of daily words for the header pill: "Random words", "A1.2", "Food & drink", "Work". */
@Composable
internal fun learnSourceLabel(source: LearnSource, viewModel: AppViewModel): String = when (source) {
    LearnSource.Random -> stringResource(Strings.learn_source_random)
    is LearnSource.Level -> source.level
    is LearnSource.Category -> categoryLabel(source.tag)
    is LearnSource.Group -> groupLabel(source.group)
    LearnSource.Bookmarks -> stringResource(Strings.tab_bookmarks)
    is LearnSource.Mine -> viewModel.userList(source.listId)?.name ?: stringResource(Strings.my_words)
}
