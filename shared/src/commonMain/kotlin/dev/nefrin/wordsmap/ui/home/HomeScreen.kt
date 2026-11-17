package dev.nefrin.wordsmap.ui.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.Screen
import dev.nefrin.wordsmap.WordsScope
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.LearnSource
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.data.Word
import dev.nefrin.wordsmap.data.WordGroup
import dev.nefrin.wordsmap.data.WordSearch
import dev.nefrin.wordsmap.data.asWord
import dev.nefrin.wordsmap.data.isUserWordId
import dev.nefrin.wordsmap.data.matches
import dev.nefrin.wordsmap.data.normalizeForSearch
import dev.nefrin.wordsmap.platform.BackHandler
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_arrow_back
import dev.nefrin.wordsmap.resources.ic_chevron_down
import dev.nefrin.wordsmap.resources.ic_plus
import dev.nefrin.wordsmap.resources.ic_search
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.SearchField
import dev.nefrin.wordsmap.ui.components.WordChip
import dev.nefrin.wordsmap.ui.components.WordChipDefaults
import dev.nefrin.wordsmap.ui.components.WordDetailOverlay
import dev.nefrin.wordsmap.ui.components.WordPairSheet
import dev.nefrin.wordsmap.ui.components.categoryLabel
import dev.nefrin.wordsmap.ui.components.toDetail
import dev.nefrin.wordsmap.ui.components.wordPairLabel
import dev.nefrin.wordsmap.ui.mywords.ListEditorSheet
import dev.nefrin.wordsmap.ui.mywords.NEW_WORD
import dev.nefrin.wordsmap.ui.mywords.UserWordEditor
import dev.nefrin.wordsmap.ui.mywords.toDetail
import dev.nefrin.wordsmap.ui.theme.appColors
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

private enum class HomeSheet { NONE, COUNTS, CHAPTERS, WORD_PAIR, NEW_CATEGORY }

/**
 * The Home tab: the words of one level, category or word group, as a wall of chips. The
 * search button turns the header into a search over every word, shown as the same chips.
 */
@Composable
fun HomeScreen(viewModel: AppViewModel, vocabulary: Vocabulary, wordSearch: WordSearch) {
    var sheet by rememberSaveable { mutableStateOf(HomeSheet.NONE) }
    var openWordId by rememberSaveable { mutableStateOf(viewModel.startWordId.also { viewModel.startWordId = null }) }
    var searching by rememberSaveable { mutableStateOf(false) }
    var query by rememberSaveable { mutableStateOf("") }
    // The learner's own words: the one being changed, or NEW_WORD for a new one.
    var editWordId by rememberSaveable { mutableStateOf<String?>(null) }
    val source = viewModel.sourceLanguage
    val target = viewModel.targetLanguage
    val userWords = viewModel.userWords
    val results = remember(wordSearch, query, userWords, source, target) {
        // The learner's own words come first: they were typed in, so a match is meant.
        val key = normalizeForSearch(query)
        val own = if (key.isEmpty()) emptyList() else userWords.filter { it.matches(key) }.map { it.asWord(source, target) }
        own + wordSearch.find(query)
    }
    val keyboard = LocalSoftwareKeyboardController.current
    val closeSearch = {
        searching = false
        query = ""
    }
    BackHandler(enabled = searching, onBack = closeSearch)

    val scope = viewModel.scope
    val words = viewModel.visibleWords
    val viewedIds = viewModel.viewedIds
    val bookmarkedIds = viewModel.bookmarkedIds
    val scopeLabel = when (scope) {
        is WordsScope.Level -> scope.level
        is WordsScope.Category -> categoryLabel(scope.tag)
        is WordsScope.Group -> groupLabel(scope.group)
        is WordsScope.Mine -> viewModel.userList(scope.listId)?.name ?: stringResource(Strings.my_words)
    }
    val groupLevelLabel = (scope as? WordsScope.Group)?.band ?: stringResource(Strings.verbs_all_levels)

    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        BoxWithConstraints(Modifier.fillMaxWidth().padding(start = 16.dp, top = 16.dp, end = 16.dp, bottom = 8.dp)) {
            val scopeButtonMaxWidth = maxWidth * 0.52f
            val interfaceDirection = LocalLayoutDirection.current
            // The header keeps its sides in every language, like the original.
            ProvideDirection(LayoutDirection.Ltr) {
                if (searching) {
                    val focus = remember { FocusRequester() }
                    LaunchedEffect(Unit) { focus.requestFocus() }
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        CircleButton(Res.drawable.ic_arrow_back, stringResource(Strings.word_search_close), onClick = closeSearch)
                        Spacer(Modifier.width(10.dp))
                        val fieldModifier = Modifier.weight(1f).focusRequester(focus)
                        // The text inside the box follows the interface language.
                        ProvideDirection(interfaceDirection) {
                            SearchField(
                                query = query,
                                hint = stringResource(Strings.word_search_hint),
                                cursor = MaterialTheme.colorScheme.primary,
                                onQueryChange = { query = it },
                                modifier = fieldModifier,
                            )
                        }
                    }
                } else {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        StatsBadge(
                            viewed = words.count { it.id in viewedIds },
                            total = words.size,
                            onClick = { sheet = HomeSheet.COUNTS },
                        )
                        Spacer(Modifier.width(8.dp))
                        CircleButton(Res.drawable.ic_search, stringResource(Strings.word_search), onClick = { searching = true })
                        if (scope is WordsScope.Mine) {
                            Spacer(Modifier.width(8.dp))
                            CircleButton(Res.drawable.ic_plus, stringResource(Strings.my_words_add), onClick = { editWordId = NEW_WORD })
                        }
                        Spacer(Modifier.weight(1f))
                        if (scope is WordsScope.Group) {
                            GroupLevelButton(
                                label = groupLevelLabel,
                                selected = scope.band,
                                bands = vocabulary.bandsOf(scope.group),
                                countOf = { vocabulary.wordsIn(scope.group, it).size },
                                labelDirection = interfaceDirection,
                                onSelect = { band -> viewModel.selectGroup(scope.group, band) },
                            )
                            Spacer(Modifier.width(8.dp))
                        }
                        ScopeButton(
                            label = scopeLabel,
                            large = scope is WordsScope.Level,
                            labelDirection = interfaceDirection,
                            maxWidth = scopeButtonMaxWidth,
                            onClick = { sheet = HomeSheet.CHAPTERS },
                        )
                    }
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        WordWall(
            words = if (searching) results else words,
            source = source,
            viewedIds = viewedIds,
            bookmarkedIds = bookmarkedIds,
            emptyText = stringResource(
                when {
                    searching -> if (query.isBlank()) Strings.word_search_start else Strings.word_search_none
                    scope is WordsScope.Level -> Strings.chapter_empty
                    scope is WordsScope.Category -> Strings.category_empty
                    scope is WordsScope.Mine -> Strings.my_words_home_empty
                    scope is WordsScope.Group && scope.group == WordGroup.SMALL_WORDS -> Strings.small_words_empty
                    else -> Strings.verbs_empty
                },
            ),
            onRefresh = { if (!searching) viewModel.refreshOrder() },
            onOpen = { word ->
                keyboard?.hide()
                viewModel.markViewed(word)
                openWordId = word.id
            },
            // A long press bookmarks a word of the app, and opens one of the learner's own to change it.
            onLongClick = { word -> if (isUserWordId(word.id)) editWordId = word.id else viewModel.toggleBookmark(word) },
            modifier = Modifier.weight(1f),
        )
    }

    when (sheet) {
        HomeSheet.NONE -> Unit
        HomeSheet.COUNTS -> CountsSheet(
            title = when (scope) {
                is WordsScope.Level -> stringResource(Strings.chapter_overview, scopeLabel)
                is WordsScope.Category -> stringResource(Strings.category_overview, scopeLabel)
                is WordsScope.Group -> stringResource(
                    when (scope.group) {
                        WordGroup.VERBS -> Strings.verbs_overview
                        WordGroup.SMALL_WORDS -> Strings.small_words_overview
                    },
                    groupLevelLabel,
                )
                is WordsScope.Mine -> scopeLabel
            },
            total = words.size,
            bookmarked = words.count { it.id in bookmarkedIds },
            viewed = words.count { it.id in viewedIds },
            onDismiss = { sheet = HomeSheet.NONE },
        )
        HomeSheet.CHAPTERS -> ChapterPickerSheet(
            vocabulary = vocabulary,
            purpose = PickerPurpose.HOME,
            selected = scope.asChoice(),
            userLists = viewModel.userLists,
            userWordCount = { listId -> userWords.count { listId == null || it.listId == listId } },
            onSelect = { choice ->
                when (choice) {
                    is LearnSource.Level -> viewModel.selectLevel(choice.level)
                    is LearnSource.Category -> viewModel.selectCategory(choice.tag)
                    is LearnSource.Group -> viewModel.openGroup(choice.group)
                    is LearnSource.Mine -> viewModel.selectMine(choice.listId)
                    // Only the cards of Learn offer these.
                    LearnSource.Random, LearnSource.Bookmarks -> Unit
                }
            },
            onDismiss = { sheet = HomeSheet.NONE },
            wordPair = wordPairLabel(source, viewModel.targetLanguage),
            onOpenWordPair = { sheet = HomeSheet.WORD_PAIR },
            onAddWord = { editWordId = NEW_WORD },
            onNewCategory = { sheet = HomeSheet.NEW_CATEGORY },
            onManageMine = { viewModel.open(Screen.MyWords((scope as? WordsScope.Mine)?.listId)) },
        )
        // A new category opens at once, empty, with its button to add words.
        HomeSheet.NEW_CATEGORY -> ListEditorSheet(
            list = null,
            onSave = { name -> viewModel.addUserList(name)?.let { viewModel.selectMine(it.id) } },
            onDelete = null,
            onDismiss = { sheet = HomeSheet.NONE },
        )
        HomeSheet.WORD_PAIR -> WordPairSheet(
            source = source,
            target = viewModel.targetLanguage,
            onApply = viewModel::changeWordPair,
            onDismiss = { sheet = HomeSheet.NONE },
        )
    }

    val openUserWord = openWordId?.let(viewModel::userWord)
    val openWord = remember(openWordId, vocabulary) { openWordId?.takeIf { !isUserWordId(it) }?.let(vocabulary::find) }
    if (openUserWord != null) {
        WordDetailOverlay(
            detail = openUserWord.toDetail(viewModel.userList(openUserWord.listId)?.name),
            bookmarked = null,
            onToggleBookmark = {},
            onDismiss = { openWordId = null },
            onEdit = { editWordId = openUserWord.id },
        )
    } else if (openWord != null) {
        WordDetailOverlay(
            detail = openWord.toDetail(source, viewModel.targetLanguage),
            bookmarked = openWord.id in bookmarkedIds,
            onToggleBookmark = { viewModel.toggleBookmark(openWord) },
            onDismiss = { openWordId = null },
        )
    }
    editWordId?.let { id ->
        UserWordEditor(
            viewModel = viewModel,
            vocabulary = vocabulary,
            wordId = id,
            startListId = (scope as? WordsScope.Mine)?.listId,
            // A new word shows in its category, wherever it was added from.
            onSaved = { saved -> if (id == NEW_WORD) viewModel.selectMine(saved.listId) },
            onDismiss = { editWordId = null },
        )
    }
}

/** The chapter on screen, as the chapter picker names it. */
private fun WordsScope.asChoice(): LearnSource = when (this) {
    is WordsScope.Level -> LearnSource.Level(level)
    is WordsScope.Category -> LearnSource.Category(tag)
    is WordsScope.Group -> LearnSource.Group(group)
    is WordsScope.Mine -> LearnSource.Mine(listId)
}

/** Round button of the header, as big as the stats badge. */
@Composable
internal fun CircleButton(icon: DrawableResource, description: String, onClick: () -> Unit, enabled: Boolean = true) {
    Box(
        modifier = Modifier
            .size(44.dp)
            .alpha(if (enabled) 1f else 0.35f)
            .clip(CircleShape)
            .background(appColors.headerButton)
            .clickable(enabled = enabled, onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(painterResource(icon), contentDescription = description, modifier = Modifier.size(20.dp), tint = appColors.onHeaderButton)
    }
}

/** Circle with the viewed count over the total. */
@Composable
private fun StatsBadge(viewed: Int, total: Int, onClick: () -> Unit) {
    val small = MaterialTheme.typography.bodySmall
    val fill = appColors.headerButton
    Column(
        modifier = Modifier
            .sizeIn(minWidth = 44.dp, minHeight = 44.dp)
            .drawBehind { drawCircle(fill, radius = size.minDimension / 2) }
            .clickable(interactionSource = null, indication = null, onClick = onClick)
            .padding(8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text("$viewed", color = appColors.onHeaderButton, style = small.copy(fontWeight = FontWeight.Bold))
        Spacer(Modifier.height(2.dp))
        Text(
            text = "$total",
            color = appColors.onHeaderButton.copy(alpha = 0.8f),
            style = small.copy(fontWeight = FontWeight.SemiBold, fontSize = 11.sp, lineHeight = 14.67.sp),
        )
    }
}

/**
 * Pill naming the level, category or word group on screen; opens the chapter picker. The
 * down arrow shows that it is something to choose from.
 */
@Composable
internal fun ScopeButton(
    label: String,
    large: Boolean,
    labelDirection: LayoutDirection,
    maxWidth: Dp,
    onClick: () -> Unit,
) {
    val chooseLabel = stringResource(Strings.choose_chapter)
    // The arrow comes after the name in its reading direction: on the left in Farsi and Pashto.
    ProvideDirection(labelDirection) {
        Row(
            modifier = Modifier
                .widthIn(max = maxWidth)
                .heightIn(min = 44.dp)
                .clip(CircleShape)
                .background(appColors.headerButton)
                .clickable(onClickLabel = chooseLabel, onClick = onClick)
                .padding(start = if (large) 16.dp else 14.dp, end = 10.dp, top = 8.dp, bottom = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Takes what room is left, so a long name is cut before the arrow is.
            Box(Modifier.weight(1f, fill = false)) {
                HeaderLabel(label, if (large) 20.sp else 17.sp, labelDirection)
            }
            Spacer(Modifier.width(4.dp))
            Icon(painterResource(Res.drawable.ic_chevron_down), contentDescription = null, modifier = Modifier.size(20.dp), tint = appColors.onHeaderButton)
        }
    }
}

/**
 * Pill beside the button of a word group (Verbs, Small words) with the level its words
 * are filtered by; opens a menu of "All levels" and every level that has such words, each
 * with its number of words.
 */
@Composable
private fun GroupLevelButton(
    label: String,
    selected: String?,
    bands: List<String>,
    countOf: (String?) -> Int,
    labelDirection: LayoutDirection,
    onSelect: (String?) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    val allLevels = stringResource(Strings.verbs_all_levels)
    Box {
        ProvideDirection(labelDirection) {
            Row(
                modifier = Modifier
                    .heightIn(min = 44.dp)
                    .clip(CircleShape)
                    .background(appColors.headerButton)
                    .clickable(onClickLabel = stringResource(Strings.verbs_level)) { expanded = true }
                    .padding(start = 14.dp, end = 8.dp, top = 8.dp, bottom = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                HeaderLabel(label, 17.sp, labelDirection)
                Spacer(Modifier.width(6.dp))
                Icon(painterResource(Res.drawable.ic_chevron_down), null, Modifier.size(20.dp), tint = appColors.onHeaderButton)
            }
        }
        DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            // The header row is always left to right; the menu follows the interface language.
            ProvideDirection(labelDirection) {
                for (band in listOf(null) + bands) {
                    val isSelected = band == selected
                    DropdownMenuItem(
                        text = {
                            Text(
                                text = band ?: allLevels,
                                color = if (isSelected) MaterialTheme.colorScheme.primary else appColors.heading,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                            )
                        },
                        trailingIcon = {
                            Text("${countOf(band)}", color = appColors.textMuted, style = MaterialTheme.typography.labelMedium)
                        },
                        onClick = {
                            expanded = false
                            onSelect(band)
                        },
                    )
                }
            }
        }
    }
}

@Composable
private fun HeaderLabel(text: String, fontSize: TextUnit, direction: LayoutDirection) {
    Text(
        text = text,
        color = appColors.onHeaderButton,
        maxLines = 1,
        softWrap = false,
        overflow = TextOverflow.Ellipsis,
        style = MaterialTheme.typography.titleMedium.copy(
            fontWeight = FontWeight.ExtraBold,
            fontSize = fontSize,
            lineHeight = fontSize * 1.5f,
            textDirection = if (direction == LayoutDirection.Rtl) TextDirection.Rtl else TextDirection.Ltr,
        ),
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun WordWall(
    words: List<Word>,
    source: AppLanguage,
    viewedIds: Set<String>,
    bookmarkedIds: Set<String>,
    emptyText: String,
    onRefresh: () -> Unit,
    onOpen: (Word) -> Unit,
    onLongClick: (Word) -> Unit,
    modifier: Modifier = Modifier,
) {
    val coroutineScope = rememberCoroutineScope()
    var refreshing by remember { mutableStateOf(false) }
    PullToRefreshBox(
        isRefreshing = refreshing,
        onRefresh = {
            onRefresh()
            // The new order is instant; keep the indicator up just long enough to be seen.
            coroutineScope.launch {
                refreshing = true
                delay(350)
                refreshing = false
            }
        },
        modifier = modifier.fillMaxWidth(),
    ) {
        BoxWithConstraints(Modifier.fillMaxSize()) {
            val texts = remember(words, source) { words.map { it.displayText(source) } }
            val rows = rememberWordRows(texts, maxWidth - 32.dp)
            // A new word list starts at the top; the same list keeps its place across tab switches.
            val listState = rememberSaveable(words, saver = LazyListState.Saver) { LazyListState() }
            // Chips fill rows from the left in every language, so their order stays stable.
            ProvideDirection(LayoutDirection.Ltr) {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    state = listState,
                    contentPadding = PaddingValues(start = 16.dp, top = 16.dp, end = 16.dp, bottom = 120.dp),
                    verticalArrangement = Arrangement.spacedBy(3.dp),
                ) {
                    if (words.isEmpty()) {
                        item {
                            Text(
                                text = emptyText,
                                modifier = Modifier.fillMaxWidth().padding(top = 32.dp),
                                style = MaterialTheme.typography.bodyLarge,
                                textAlign = TextAlign.Center,
                            )
                        }
                    }
                    items(rows.size) { rowIndex ->
                        Row(horizontalArrangement = Arrangement.spacedBy(WordChipDefaults.Spacing)) {
                            for (index in rows[rowIndex]) {
                                val word = words[index]
                                WordChip(
                                    text = texts[index],
                                    bookmarked = word.id in bookmarkedIds,
                                    viewed = word.id in viewedIds,
                                    rightToLeft = source.isRtl,
                                    onClick = { onOpen(word) },
                                    onLongClick = { onLongClick(word) },
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
