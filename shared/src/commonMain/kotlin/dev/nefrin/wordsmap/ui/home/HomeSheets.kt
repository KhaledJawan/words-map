package dev.nefrin.wordsmap.ui.home

import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
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
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalWindowInfo
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.nefrin.wordsmap.data.LearnSource
import dev.nefrin.wordsmap.data.UserList
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.data.WordGroup
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_badge_link
import dev.nefrin.wordsmap.resources.ic_bookmark
import dev.nefrin.wordsmap.resources.ic_check_circle_2
import dev.nefrin.wordsmap.resources.ic_chevron_left
import dev.nefrin.wordsmap.resources.ic_languages
import dev.nefrin.wordsmap.resources.ic_pencil
import dev.nefrin.wordsmap.resources.ic_plus
import dev.nefrin.wordsmap.resources.ic_shuffle
import dev.nefrin.wordsmap.resources.ic_tag
import dev.nefrin.wordsmap.resources.ic_zap
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.AppBottomSheet
import dev.nefrin.wordsmap.ui.components.PillButton
import dev.nefrin.wordsmap.ui.components.SectionTitle
import dev.nefrin.wordsmap.ui.components.categoryLabel
import dev.nefrin.wordsmap.ui.components.close
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

/** Totals of the level or category on screen. */
@Composable
internal fun CountsSheet(title: String, total: Int, bookmarked: Int, viewed: Int, onDismiss: () -> Unit) {
    AppBottomSheet(onDismiss = onDismiss, showHandle = false, topRadius = 24.dp) {
        Column(
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = title,
                color = appColors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
            )
            Spacer(Modifier.height(16.dp))
            CountRow(stringResource(Strings.total_words), total)
            Spacer(Modifier.height(10.dp))
            CountRow(stringResource(Strings.bookmarked), bookmarked)
            Spacer(Modifier.height(10.dp))
            CountRow(stringResource(Strings.viewed), viewed)
            Spacer(Modifier.height(12.dp))
        }
    }
}

@Composable
private fun CountRow(label: String, count: Int) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, style = MaterialTheme.typography.bodyMedium)
        Text("$count", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
    }
}

/** Name of a word group: "Verbs", "Small words". */
@Composable
internal fun groupLabel(group: WordGroup): String = stringResource(
    when (group) {
        WordGroup.VERBS -> Strings.chapter_verbs
        WordGroup.SMALL_WORDS -> Strings.chapter_small_words
    },
)

internal val WordGroup.icon: DrawableResource
    get() = when (this) {
        WordGroup.VERBS -> Res.drawable.ic_zap
        WordGroup.SMALL_WORDS -> Res.drawable.ic_badge_link
    }

/** What the chapter picker shows: the grid, the categories, or the learner's own categories. */
private enum class PickerView { GRID, CATEGORIES, MINE }

/** What the chapter picker chooses for: the word wall of Home, or the daily cards of Learn. */
internal enum class PickerPurpose { HOME, LEARN }

/**
 * Picks a chapter: a level from the grid, a category from the list behind the "Categories"
 * tile, a word group such as the verbs, or the learner's own words behind the "My words"
 * tile. Home also reaches the word pair sheet here, and adds own words and categories; the
 * cards of Learn can also take random words or the bookmarks.
 *
 * It opens where [selected] is: on the categories when a category is chosen, and on the
 * own categories when own words are.
 */
@Composable
internal fun ChapterPickerSheet(
    vocabulary: Vocabulary,
    purpose: PickerPurpose,
    selected: LearnSource,
    userLists: List<UserList>,
    userWordCount: (listId: String?) -> Int,
    onSelect: (LearnSource) -> Unit,
    onDismiss: () -> Unit,
    wordPair: String? = null,
    onOpenWordPair: () -> Unit = {},
    onAddWord: () -> Unit = {},
    onNewCategory: () -> Unit = {},
    onManageMine: () -> Unit = {},
) {
    val home = purpose == PickerPurpose.HOME
    // Home always opens the own categories, for their buttons that add words and categories.
    val mineHasView = home || userLists.isNotEmpty()
    var view by rememberSaveable {
        mutableStateOf(
            when {
                selected is LearnSource.Category -> PickerView.CATEGORIES
                selected is LearnSource.Mine && mineHasView -> PickerView.MINE
                else -> PickerView.GRID
            },
        )
    }
    val screenHeight = with(LocalDensity.current) { LocalWindowInfo.current.containerSize.height.toDp() }
    // A share of the screen; the grid of Learn, with its two more tiles, takes just the room it needs.
    val heightShare = when (view) {
        PickerView.CATEGORIES -> 0.86f
        PickerView.MINE -> 0.66f
        PickerView.GRID -> if (home) 0.56f else null
    }
    AppBottomSheet(onDismiss = onDismiss, showHandle = false, topRadius = 24.dp) { sheet ->
        val choose = { choice: LearnSource ->
            onSelect(choice)
            sheet.close()
        }
        Box(
            Modifier
                .fillMaxWidth()
                .animateContentSize(tween(220, easing = EaseOut))
                .then(if (heightShare != null) Modifier.height(screenHeight * heightShare) else Modifier)
                .padding(start = 16.dp, end = 16.dp, top = 24.dp, bottom = 24.dp),
        ) {
            when (view) {
                PickerView.CATEGORIES -> CategoryList(
                    vocabulary = vocabulary,
                    selectedTag = (selected as? LearnSource.Category)?.tag,
                    onBack = { view = PickerView.GRID },
                    onSelect = { tag -> choose(LearnSource.Category(tag)) },
                )
                PickerView.MINE -> MineList(
                    lists = userLists,
                    hasWords = userWordCount(null) > 0,
                    selected = selected as? LearnSource.Mine,
                    countOf = userWordCount,
                    onBack = { view = PickerView.GRID },
                    onSelect = { listId -> choose(LearnSource.Mine(listId)) },
                    onManage = if (home) ({ sheet.close(then = onManageMine) }) else null,
                    onAddWord = if (home) ({ sheet.close(then = onAddWord) }) else null,
                    onNewCategory = if (home) ({ sheet.close(then = onNewCategory) }) else null,
                )
                PickerView.GRID -> LevelGrid(
                    title = stringResource(if (home) Strings.choose_chapter else Strings.learn_source_title),
                    tiles = buildList {
                        vocabulary.levels.forEach { add(PickerChoice.Level(it)) }
                        add(PickerChoice.Categories)
                        WordGroup.entries.filter { vocabulary.wordsIn(it).isNotEmpty() }.forEach { add(PickerChoice.Group(it)) }
                        add(PickerChoice.Mine)
                        if (!home) {
                            add(PickerChoice.Bookmarks)
                            add(PickerChoice.Random)
                        }
                    },
                    selected = selected,
                    wordPair = wordPair,
                    onChoose = { tile ->
                        when (tile) {
                            is PickerChoice.Level -> choose(LearnSource.Level(tile.level))
                            PickerChoice.Categories -> view = PickerView.CATEGORIES
                            is PickerChoice.Group -> choose(LearnSource.Group(tile.group))
                            PickerChoice.Mine -> if (mineHasView) view = PickerView.MINE else choose(LearnSource.Mine(null))
                            PickerChoice.Bookmarks -> choose(LearnSource.Bookmarks)
                            PickerChoice.Random -> choose(LearnSource.Random)
                        }
                    },
                    onOpenWordPair = { sheet.close(then = onOpenWordPair) },
                )
            }
        }
    }
}

/** A tile of the chapter grid. */
private sealed interface PickerChoice {
    data class Level(val level: String) : PickerChoice
    data object Categories : PickerChoice
    data class Group(val group: WordGroup) : PickerChoice
    data object Mine : PickerChoice
    data object Bookmarks : PickerChoice
    data object Random : PickerChoice
}

private fun PickerChoice.isSelected(selected: LearnSource): Boolean = when (this) {
    is PickerChoice.Level -> selected == LearnSource.Level(level)
    PickerChoice.Categories -> selected is LearnSource.Category
    is PickerChoice.Group -> selected is LearnSource.Group && selected.group == group
    PickerChoice.Mine -> selected is LearnSource.Mine
    PickerChoice.Bookmarks -> selected == LearnSource.Bookmarks
    PickerChoice.Random -> selected == LearnSource.Random
}

@Composable
private fun LevelGrid(
    title: String,
    tiles: List<PickerChoice>,
    selected: LearnSource,
    wordPair: String?,
    onChoose: (PickerChoice) -> Unit,
    onOpenWordPair: () -> Unit,
) {
    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = title,
            color = appColors.heading,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
        )
        Spacer(Modifier.height(12.dp))
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            for (row in tiles.chunked(3)) {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    for (tile in row) {
                        PickerTile(
                            selected = tile.isSelected(selected),
                            onClick = { onChoose(tile) },
                            modifier = Modifier.weight(1f),
                        ) { textColor ->
                            val icon = when (tile) {
                                is PickerChoice.Level -> null
                                PickerChoice.Categories -> Res.drawable.ic_tag
                                is PickerChoice.Group -> tile.group.icon
                                PickerChoice.Mine -> Res.drawable.ic_pencil
                                PickerChoice.Bookmarks -> Res.drawable.ic_bookmark
                                PickerChoice.Random -> Res.drawable.ic_shuffle
                            }
                            if (icon != null) {
                                Icon(painterResource(icon), null, Modifier.size(16.dp), tint = textColor)
                                Spacer(Modifier.width(6.dp))
                            }
                            Text(
                                text = when (tile) {
                                    is PickerChoice.Level -> tile.level
                                    PickerChoice.Categories -> stringResource(Strings.chapter_categories)
                                    is PickerChoice.Group -> groupLabel(tile.group)
                                    PickerChoice.Mine -> stringResource(Strings.my_words)
                                    PickerChoice.Bookmarks -> stringResource(Strings.tab_bookmarks)
                                    PickerChoice.Random -> stringResource(Strings.learn_source_random)
                                },
                                color = textColor,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                                // A long name, such as "Kleine Wörter", gets smaller instead of cut off.
                                autoSize = TextAutoSize.StepBased(minFontSize = 10.sp, maxFontSize = 14.sp, stepSize = 0.5.sp),
                                style = MaterialTheme.typography.bodyMedium.copy(
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.SemiBold,
                                ),
                            )
                        }
                    }
                    repeat(3 - row.size) { Spacer(Modifier.weight(1f)) }
                }
            }
        }
        if (wordPair != null) {
            Spacer(Modifier.height(14.dp))
            PillButton(
                text = "${stringResource(Strings.word_pair)}: $wordPair",
                icon = Res.drawable.ic_languages,
                background = appColors.headerButton,
                contentColor = appColors.onHeaderButton,
                onClick = onOpenWordPair,
                modifier = Modifier.widthIn(max = 230.dp),
            )
        }
    }
}

@Composable
internal fun PickerTile(
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable (textColor: Color) -> Unit,
) {
    val shape = RoundedCornerShape(14.dp)
    val primary = MaterialTheme.colorScheme.primary
    Row(
        modifier = modifier
            .aspectRatio(2.4f)
            .clip(shape)
            .background(if (selected) primary else appColors.tile)
            .border(1.dp, if (selected) primary else appColors.tileBorder, shape)
            .clickable(onClick = onClick)
            .padding(horizontal = 6.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        content(if (selected) Color.White else appColors.tileText)
    }
}

@Composable
internal fun CategoryList(
    vocabulary: Vocabulary,
    selectedTag: String?,
    onBack: () -> Unit,
    onSelect: (String) -> Unit,
) {
    val labels = vocabulary.byCategory.keys.associateWith { categoryLabel(it) }
    val tags = remember(labels) { labels.keys.sortedBy { labels.getValue(it) } }
    // Opens on the chosen category, with two rows above it, instead of at the top of the list.
    val listState = rememberLazyListState(initialFirstVisibleItemIndex = (tags.indexOf(selectedTag) - 2).coerceAtLeast(0))
    Column {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(
                    painter = painterResource(Res.drawable.ic_chevron_left),
                    contentDescription = stringResource(Strings.common_back),
                    tint = appColors.heading,
                )
            }
            Spacer(Modifier.width(4.dp))
            SectionTitle(stringResource(Strings.choose_category), Modifier.weight(1f))
        }
        Spacer(Modifier.height(10.dp))
        LazyColumn(state = listState, verticalArrangement = Arrangement.spacedBy(6.dp)) {
            items(tags, key = { it }) { tag ->
                val selected = tag == selectedTag
                val primary = MaterialTheme.colorScheme.primary
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(min = 56.dp)
                        .clip(RoundedCornerShape(14.dp))
                        .background(if (selected) primary.copy(alpha = 0.10f) else Color.Transparent)
                        .clickable { onSelect(tag) }
                        .padding(start = 16.dp, end = 24.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        painter = painterResource(if (selected) Res.drawable.ic_check_circle_2 else Res.drawable.ic_tag),
                        contentDescription = null,
                        tint = if (selected) primary else MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(Modifier.width(16.dp))
                    Text(
                        text = labels.getValue(tag),
                        modifier = Modifier.weight(1f),
                        color = appColors.heading,
                        style = MaterialTheme.typography.bodyLarge,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                    Spacer(Modifier.width(16.dp))
                    Text(
                        text = "${vocabulary.wordsInCategory(tag).size}",
                        modifier = Modifier
                            .background(appColors.heading.copy(alpha = 0.07f), CircleShape)
                            .padding(horizontal = 10.dp, vertical = 6.dp),
                        color = appColors.heading,
                        style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold),
                    )
                }
            }
        }
    }
}

/**
 * The learner's own categories, behind the "My words" tile: all words first, then one row
 * each. On Home it also has the buttons that add a word or a category, and the way to the
 * page that manages them.
 */
@Composable
private fun MineList(
    lists: List<UserList>,
    hasWords: Boolean,
    selected: LearnSource.Mine?,
    countOf: (String?) -> Int,
    onBack: () -> Unit,
    onSelect: (String?) -> Unit,
    onManage: (() -> Unit)?,
    onAddWord: (() -> Unit)?,
    onNewCategory: (() -> Unit)?,
) {
    val selectedRow = if (selected?.listId == null) 0 else lists.indexOfFirst { it.id == selected.listId } + 1
    val listState = rememberLazyListState(initialFirstVisibleItemIndex = (selectedRow - 2).coerceAtLeast(0))
    Column(Modifier.fillMaxSize()) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(
                    painter = painterResource(Res.drawable.ic_chevron_left),
                    contentDescription = stringResource(Strings.common_back),
                    tint = appColors.heading,
                )
            }
            Spacer(Modifier.width(4.dp))
            SectionTitle(stringResource(Strings.my_words), Modifier.weight(1f))
            if (onManage != null) {
                Text(
                    text = stringResource(Strings.my_words_manage),
                    modifier = Modifier
                        .clip(CircleShape)
                        .clickable(onClick = onManage)
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    color = MaterialTheme.colorScheme.primary,
                    style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
                )
            }
        }
        Spacer(Modifier.height(10.dp))
        LazyColumn(Modifier.weight(1f), state = listState, verticalArrangement = Arrangement.spacedBy(6.dp)) {
            item(key = "all") {
                ListChoiceRow(
                    icon = Res.drawable.ic_pencil,
                    title = stringResource(Strings.my_words_all),
                    count = countOf(null),
                    selected = selected != null && selected.listId == null,
                    onClick = { onSelect(null) },
                )
            }
            items(lists, key = { it.id }) { list ->
                ListChoiceRow(
                    icon = Res.drawable.ic_tag,
                    title = list.name,
                    count = countOf(list.id),
                    selected = selected?.listId == list.id,
                    onClick = { onSelect(list.id) },
                )
            }
            // What own words are for, until there are some.
            if (!hasWords && onAddWord != null) {
                item(key = "hint") {
                    Text(
                        text = stringResource(Strings.my_words_empty_text),
                        modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp),
                        color = appColors.textMuted,
                        style = MaterialTheme.typography.bodyMedium,
                    )
                }
            }
        }
        if (onAddWord != null && onNewCategory != null) {
            Spacer(Modifier.height(12.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                PillButton(
                    text = stringResource(Strings.my_words_add),
                    icon = Res.drawable.ic_plus,
                    background = appColors.headerButton,
                    contentColor = appColors.onHeaderButton,
                    onClick = onAddWord,
                    modifier = Modifier.weight(1f).heightIn(min = 48.dp),
                )
                PillButton(
                    text = stringResource(Strings.my_words_new_list),
                    icon = Res.drawable.ic_tag,
                    background = appColors.tile,
                    contentColor = appColors.tileText,
                    onClick = onNewCategory,
                    modifier = Modifier.weight(1f).heightIn(min = 48.dp).border(1.dp, appColors.tileBorder, CircleShape),
                )
            }
        }
    }
}

@Composable
private fun ListChoiceRow(icon: DrawableResource, title: String, count: Int, selected: Boolean, onClick: () -> Unit) {
    val primary = MaterialTheme.colorScheme.primary
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 56.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(if (selected) primary.copy(alpha = 0.10f) else Color.Transparent)
            .clickable(onClick = onClick)
            .padding(start = 16.dp, end = 24.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            painter = painterResource(if (selected) Res.drawable.ic_check_circle_2 else icon),
            contentDescription = null,
            tint = if (selected) primary else MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(Modifier.width(16.dp))
        Text(
            text = title,
            modifier = Modifier.weight(1f),
            color = appColors.heading,
            style = MaterialTheme.typography.bodyLarge,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
        Spacer(Modifier.width(16.dp))
        Text(
            text = "$count",
            modifier = Modifier
                .background(appColors.heading.copy(alpha = 0.07f), CircleShape)
                .padding(horizontal = 10.dp, vertical = 6.dp),
            color = appColors.heading,
            style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold),
        )
    }
}
