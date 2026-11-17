package dev.nefrin.wordsmap.ui.mywords

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.data.UserList
import dev.nefrin.wordsmap.data.UserWord
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.data.matches
import dev.nefrin.wordsmap.data.normalizeForSearch
import dev.nefrin.wordsmap.platform.BackHandler
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_arrow_back
import dev.nefrin.wordsmap.resources.ic_pencil
import dev.nefrin.wordsmap.resources.ic_plus
import dev.nefrin.wordsmap.resources.ic_search
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.SearchField
import dev.nefrin.wordsmap.ui.components.SoftShadows
import dev.nefrin.wordsmap.ui.components.WordDetailOverlay
import dev.nefrin.wordsmap.ui.components.softShadow
import dev.nefrin.wordsmap.ui.components.textDirectionOf
import dev.nefrin.wordsmap.ui.home.CircleButton
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.painterResource

/** Which category sheet is open: none, a new category, or the one on screen. */
private enum class ListSheet { NONE, NEW, CURRENT }

/**
 * The learner's own words, as a list of words and meanings to look through and change. The
 * pills under the title pick a category; a new word goes into the one picked.
 */
@Composable
fun MyWordsScreen(viewModel: AppViewModel, vocabulary: Vocabulary, startListId: String?, onBack: () -> Unit) {
    var pickedListId by rememberSaveable { mutableStateOf(startListId) }
    // A category deleted on this screen (or elsewhere) falls back to all words.
    val list = viewModel.userList(pickedListId)
    val listId = list?.id
    var searching by rememberSaveable { mutableStateOf(false) }
    var query by rememberSaveable { mutableStateOf("") }
    var editWordId by rememberSaveable { mutableStateOf<String?>(null) }
    var openWordId by rememberSaveable { mutableStateOf<String?>(null) }
    var listSheet by rememberSaveable { mutableStateOf(ListSheet.NONE) }
    val keyboard = LocalSoftwareKeyboardController.current
    val closeSearch = {
        searching = false
        query = ""
    }
    BackHandler(enabled = searching, onBack = closeSearch)

    val allWords = viewModel.userWords
    val key = normalizeForSearch(query)
    val words = viewModel.userWordsIn(listId).filter { it.matches(key) }
    val listNames = viewModel.userLists.associate { it.id to it.name }

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize().statusBarsPadding()) {
            Header(
                title = list?.name ?: stringResource(Strings.my_words),
                searching = searching,
                query = query,
                canEditList = list != null,
                onBack = onBack,
                onQueryChange = { query = it },
                onOpenSearch = { searching = true },
                onCloseSearch = closeSearch,
                onEditList = { listSheet = ListSheet.CURRENT },
            )
            ListPills(
                selected = listId,
                allCount = allWords.size,
                lists = viewModel.userLists.map { it to allWords.count { word -> word.listId == it.id } },
                onSelect = { pickedListId = it },
                onNewList = { listSheet = ListSheet.NEW },
            )
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(start = 16.dp, top = 8.dp, end = 16.dp, bottom = 120.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                when {
                    allWords.isEmpty() -> item(key = "empty") { EmptyState(onAdd = { editWordId = NEW_WORD }) }
                    words.isEmpty() -> item(key = "none") {
                        Text(
                            text = stringResource(if (query.isNotBlank()) Strings.word_search_none else Strings.my_words_empty_list),
                            modifier = Modifier.fillMaxWidth().padding(start = 16.dp, top = 40.dp, end = 16.dp),
                            color = appColors.textMuted,
                            style = MaterialTheme.typography.bodyLarge,
                            textAlign = TextAlign.Center,
                        )
                    }
                    else -> items(words, key = { it.id }) { word ->
                        UserWordRow(
                            word = word,
                            listName = if (listId == null) word.listId?.let(listNames::get) else null,
                            onClick = {
                                keyboard?.hide()
                                viewModel.markViewed(word.id)
                                openWordId = word.id
                            },
                            onEdit = { editWordId = word.id },
                            modifier = Modifier.animateItem(),
                        )
                    }
                }
            }
        }
        if (allWords.isNotEmpty()) {
            AddWordButton(
                onClick = { editWordId = NEW_WORD },
                modifier = Modifier.align(Alignment.BottomEnd).navigationBarsPadding().padding(20.dp),
            )
        }
    }

    editWordId?.let { id ->
        UserWordEditor(viewModel, vocabulary, wordId = id, startListId = listId, onDismiss = { editWordId = null })
    }
    when (listSheet) {
        ListSheet.NONE -> Unit
        ListSheet.NEW -> ListEditorSheet(
            list = null,
            onSave = { name -> viewModel.addUserList(name)?.let { pickedListId = it.id } },
            onDelete = null,
            onDismiss = { listSheet = ListSheet.NONE },
        )
        ListSheet.CURRENT -> if (list != null) {
            ListEditorSheet(
                list = list,
                onSave = { viewModel.renameUserList(list.id, it) },
                onDelete = {
                    pickedListId = null
                    viewModel.deleteUserList(list.id)
                },
                onDismiss = { listSheet = ListSheet.NONE },
            )
        }
    }
    val openWord = openWordId?.let(viewModel::userWord)
    if (openWord != null) {
        WordDetailOverlay(
            detail = openWord.toDetail(openWord.listId?.let(listNames::get)),
            bookmarked = null,
            onToggleBookmark = {},
            onDismiss = { openWordId = null },
            onEdit = { editWordId = openWord.id },
        )
    }
}

@Composable
private fun Header(
    title: String,
    searching: Boolean,
    query: String,
    canEditList: Boolean,
    onBack: () -> Unit,
    onQueryChange: (String) -> Unit,
    onOpenSearch: () -> Unit,
    onCloseSearch: () -> Unit,
    onEditList: () -> Unit,
) {
    val interfaceDirection = LocalLayoutDirection.current
    Box(Modifier.fillMaxWidth().heightIn(min = 76.dp).padding(start = 16.dp, top = 16.dp, end = 16.dp, bottom = 8.dp)) {
        // The round buttons keep their sides, as on Home; the texts follow the interface language.
        ProvideDirection(LayoutDirection.Ltr) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (searching) {
                    val focus = remember { FocusRequester() }
                    LaunchedEffect(Unit) { focus.requestFocus() }
                    CircleButton(Res.drawable.ic_arrow_back, stringResource(Strings.word_search_close), onClick = onCloseSearch)
                    Spacer(Modifier.width(10.dp))
                    val fieldModifier = Modifier.weight(1f).focusRequester(focus)
                    ProvideDirection(interfaceDirection) {
                        SearchField(
                            query = query,
                            hint = stringResource(Strings.my_words_search_hint),
                            cursor = MaterialTheme.colorScheme.primary,
                            onQueryChange = onQueryChange,
                            modifier = fieldModifier,
                        )
                    }
                } else {
                    CircleButton(Res.drawable.ic_arrow_back, stringResource(Strings.common_back), onClick = onBack)
                    Spacer(Modifier.width(12.dp))
                    Box(Modifier.weight(1f)) {
                        ProvideDirection(interfaceDirection) {
                            Text(
                                text = title,
                                modifier = Modifier.fillMaxWidth(),
                                color = appColors.heading,
                                style = MaterialTheme.typography.titleLarge,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                    }
                    if (canEditList) {
                        Spacer(Modifier.width(8.dp))
                        CircleButton(Res.drawable.ic_pencil, stringResource(Strings.my_words_edit_list), onClick = onEditList)
                    }
                    Spacer(Modifier.width(8.dp))
                    CircleButton(Res.drawable.ic_search, stringResource(Strings.my_words_search_hint), onClick = onOpenSearch)
                }
            }
        }
    }
}

/** "All 14", one pill per category with its count, and "New category". */
@Composable
private fun ListPills(
    selected: String?,
    allCount: Int,
    lists: List<Pair<UserList, Int>>,
    onSelect: (String?) -> Unit,
    onNewList: () -> Unit,
) {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        item(key = "all") {
            ChoiceChip("${stringResource(Strings.common_all)} · $allCount", selected = selected == null, onClick = { onSelect(null) })
        }
        items(lists, key = { it.first.id }) { (list, count) ->
            ChoiceChip("${list.name} · $count", selected = selected == list.id, onClick = { onSelect(list.id) })
        }
        item(key = "new") {
            ChoiceChip(stringResource(Strings.my_words_new_list), selected = false, icon = Res.drawable.ic_plus, onClick = onNewList)
        }
    }
}

/** One of the learner's words: the word with its article, the meaning, its category and a pencil to change it. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
internal fun UserWordRow(
    word: UserWord,
    listName: String?,
    onClick: () -> Unit,
    onEdit: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val colors = appColors
    val shape = RoundedCornerShape(16.dp)
    Row(
        modifier = modifier
            .fillMaxWidth()
            .softShadow(if (colors.isDark) emptyList() else SoftShadows.listCard, cornerRadius = 16.dp)
            .clip(shape)
            .background(MaterialTheme.colorScheme.surface)
            .combinedClickable(onClick = onClick, onLongClick = onEdit)
            .padding(start = 16.dp, top = 10.dp, bottom = 10.dp, end = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(Modifier.weight(1f)) {
            Text(
                text = buildAnnotatedString {
                    if (word.article != null) withStyle(SpanStyle(color = colors.textMuted, fontWeight = FontWeight.Medium)) { append("${word.article} ") }
                    append(word.text)
                },
                modifier = Modifier.fillMaxWidth(),
                color = colors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold, textDirection = textDirectionOf(word.text)),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.height(2.dp))
            Text(
                text = word.translation,
                modifier = Modifier.fillMaxWidth(),
                color = colors.textMuted,
                style = MaterialTheme.typography.bodyMedium.copy(textDirection = textDirectionOf(word.translation)),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
        }
        if (listName != null) {
            Spacer(Modifier.width(8.dp))
            Text(
                text = listName,
                modifier = Modifier
                    .background(colors.tile, CircleShape)
                    .padding(horizontal = 8.dp, vertical = 3.dp),
                color = colors.textMuted,
                style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
        IconButton(onClick = onEdit) {
            Icon(
                painter = painterResource(Res.drawable.ic_pencil),
                contentDescription = stringResource(Strings.editor_edit_title),
                modifier = Modifier.size(20.dp),
                tint = colors.textMuted,
            )
        }
    }
}

/** The black pill at the bottom corner that adds a word. */
@Composable
internal fun AddWordButton(onClick: () -> Unit, modifier: Modifier = Modifier) {
    val colors = appColors
    Row(
        modifier = modifier
            .softShadow(SoftShadows.lessonCard)
            .clip(CircleShape)
            .background(colors.headerButton)
            .clickable(onClick = onClick)
            .heightIn(min = 52.dp)
            .padding(start = 18.dp, end = 22.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(painterResource(Res.drawable.ic_plus), contentDescription = null, modifier = Modifier.size(20.dp), tint = colors.onHeaderButton)
        Spacer(Modifier.width(8.dp))
        Text(
            text = stringResource(Strings.my_words_add),
            color = colors.onHeaderButton,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
        )
    }
}

/** Before the first word: what the page is for, and the way to add one. */
@Composable
private fun EmptyState(onAdd: () -> Unit) {
    val primary = MaterialTheme.colorScheme.primary
    Column(
        Modifier.fillMaxWidth().padding(start = 24.dp, top = 48.dp, end = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            Modifier.size(72.dp).background(primary.copy(alpha = if (appColors.isDark) 0.24f else 0.12f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(painterResource(Res.drawable.ic_pencil), contentDescription = null, modifier = Modifier.size(30.dp), tint = primary)
        }
        Spacer(Modifier.height(18.dp))
        Text(
            text = stringResource(Strings.my_words_empty_title),
            color = appColors.heading,
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
        )
        Spacer(Modifier.height(8.dp))
        Text(
            text = stringResource(Strings.my_words_empty_text),
            color = appColors.textMuted,
            style = MaterialTheme.typography.bodyMedium,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(22.dp))
        AddWordButton(onClick = onAdd)
    }
}
