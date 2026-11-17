package dev.nefrin.wordsmap.ui.bookmarks

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
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
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.data.Word
import dev.nefrin.wordsmap.data.WordSearch
import dev.nefrin.wordsmap.platform.BackHandler
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.StringRes
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_arrow_back
import dev.nefrin.wordsmap.resources.ic_bookmark
import dev.nefrin.wordsmap.resources.ic_bookmark_filled
import dev.nefrin.wordsmap.resources.ic_search
import dev.nefrin.wordsmap.resources.ic_x
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.AppBottomSheet
import dev.nefrin.wordsmap.ui.components.PillButton
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.SearchField
import dev.nefrin.wordsmap.ui.components.SoftShadows
import dev.nefrin.wordsmap.ui.components.WordDetailOverlay
import dev.nefrin.wordsmap.ui.components.close
import dev.nefrin.wordsmap.ui.components.softShadow
import dev.nefrin.wordsmap.ui.components.toDetail
import dev.nefrin.wordsmap.ui.home.CircleButton
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.painterResource

/**
 * The Bookmarks tab: the saved words as a list of words and meanings. A word that is
 * unbookmarked anywhere moves to "Earlier bookmarks", dimmed, until it is long-pressed here
 * and removed. The search looks through all words, with the same rows to bookmark from.
 */
@Composable
fun BookmarksScreen(viewModel: AppViewModel, vocabulary: Vocabulary, wordSearch: WordSearch) {
    var searching by rememberSaveable { mutableStateOf(false) }
    var query by rememberSaveable { mutableStateOf("") }
    var openWordId by rememberSaveable { mutableStateOf<String?>(null) }
    var removeWordId by rememberSaveable { mutableStateOf<String?>(null) }
    val results = remember(wordSearch, query) { wordSearch.find(query) }
    val keyboard = LocalSoftwareKeyboardController.current
    val closeSearch = {
        searching = false
        query = ""
    }
    BackHandler(enabled = searching, onBack = closeSearch)

    val bookmarkedIds = viewModel.bookmarkedIds
    val listed = remember(vocabulary, viewModel.bookmarkHistory) { viewModel.bookmarkHistory.mapNotNull(vocabulary::find) }
    val saved = listed.filter { it.id in bookmarkedIds }
    val earlier = listed.filter { it.id !in bookmarkedIds }
    val source = viewModel.sourceLanguage
    val target = viewModel.targetLanguage
    val open = { word: Word ->
        keyboard?.hide()
        viewModel.markViewed(word)
        openWordId = word.id
    }
    val row: @Composable (Word, Boolean, (() -> Unit)?, Modifier) -> Unit = { word, faded, onLongClick, modifier ->
        BookmarkRow(
            word = word,
            source = source,
            target = target,
            bookmarked = word.id in bookmarkedIds,
            faded = faded,
            onClick = { open(word) },
            onLongClick = onLongClick,
            onToggleBookmark = { viewModel.toggleBookmark(word) },
            modifier = modifier,
        )
    }

    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        Header(
            searching = searching,
            query = query,
            onQueryChange = { query = it },
            onOpenSearch = { searching = true },
            onCloseSearch = closeSearch,
        )
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(start = 16.dp, top = 8.dp, end = 16.dp, bottom = 120.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            when {
                searching -> {
                    if (results.isEmpty()) {
                        emptyMessage(if (query.isBlank()) Strings.word_search_start else Strings.word_search_none)
                    }
                    items(results, key = { "search:${it.id}" }) { word -> row(word, false, null, Modifier) }
                }
                listed.isEmpty() -> emptyMessage(Strings.bookmarks_empty)
                else -> {
                    if (saved.isNotEmpty()) {
                        item(key = "saved") { SectionHeader(stringResource(Strings.bookmarks_saved), saved.size, Modifier.animateItem()) }
                        // The same keys in both sections let a word slide over when its bookmark changes.
                        items(saved, key = { it.id }) { word ->
                            row(word, false, { removeWordId = word.id }, Modifier.animateItem())
                        }
                    }
                    if (earlier.isNotEmpty()) {
                        item(key = "earlier") {
                            SectionHeader(
                                title = stringResource(Strings.bookmarks_earlier),
                                count = earlier.size,
                                modifier = Modifier.animateItem(),
                                hint = stringResource(Strings.bookmarks_earlier_hint),
                            )
                        }
                        items(earlier, key = { it.id }) { word ->
                            row(word, true, { removeWordId = word.id }, Modifier.animateItem())
                        }
                    }
                }
            }
        }
    }

    val removeWord = remember(removeWordId, vocabulary) { removeWordId?.let(vocabulary::find) }
    if (removeWord != null) {
        RemoveBookmarkSheet(
            word = removeWord,
            source = source,
            target = target,
            onRemove = { viewModel.removeFromBookmarks(removeWord) },
            onDismiss = { removeWordId = null },
        )
    }

    val openWord = remember(openWordId, vocabulary) { openWordId?.let(vocabulary::find) }
    if (openWord != null) {
        WordDetailOverlay(
            detail = openWord.toDetail(source, target),
            bookmarked = openWord.id in bookmarkedIds,
            onToggleBookmark = { viewModel.toggleBookmark(openWord) },
            onDismiss = { openWordId = null },
        )
    }
}

/** The page title with the search button, or the search field while searching. */
@Composable
private fun Header(
    searching: Boolean,
    query: String,
    onQueryChange: (String) -> Unit,
    onOpenSearch: () -> Unit,
    onCloseSearch: () -> Unit,
) {
    Box(Modifier.fillMaxWidth().heightIn(min = 76.dp).padding(start = 16.dp, top = 16.dp, end = 16.dp, bottom = 8.dp)) {
        if (searching) {
            val focus = remember { FocusRequester() }
            LaunchedEffect(Unit) { focus.requestFocus() }
            val interfaceDirection = LocalLayoutDirection.current
            // The back button keeps its side, like on Home; the text follows the interface language.
            ProvideDirection(LayoutDirection.Ltr) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    CircleButton(Res.drawable.ic_arrow_back, stringResource(Strings.word_search_close), onClick = onCloseSearch)
                    Spacer(Modifier.width(10.dp))
                    val fieldModifier = Modifier.weight(1f).focusRequester(focus)
                    ProvideDirection(interfaceDirection) {
                        SearchField(
                            query = query,
                            hint = stringResource(Strings.word_search_hint),
                            cursor = MaterialTheme.colorScheme.primary,
                            onQueryChange = onQueryChange,
                            modifier = fieldModifier,
                        )
                    }
                }
            }
        } else {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = stringResource(Strings.tab_bookmarks),
                    modifier = Modifier.weight(1f),
                    color = appColors.heading,
                    style = MaterialTheme.typography.titleLarge,
                )
                CircleButton(Res.drawable.ic_search, stringResource(Strings.word_search), onClick = onOpenSearch)
            }
        }
    }
}

@Composable
private fun SectionHeader(title: String, count: Int, modifier: Modifier = Modifier, hint: String? = null) {
    Column(modifier.fillMaxWidth().padding(start = 4.dp, top = 10.dp, bottom = 2.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = title,
                color = appColors.heading.copy(alpha = appColors.heading.alpha * 0.75f),
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
            )
            Spacer(Modifier.width(8.dp))
            Text(
                text = "$count",
                modifier = Modifier
                    .background(appColors.heading.copy(alpha = 0.07f), CircleShape)
                    .padding(horizontal = 8.dp, vertical = 2.dp),
                color = appColors.textMuted,
                style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold),
            )
        }
        if (hint != null) {
            Spacer(Modifier.height(2.dp))
            Text(hint, color = appColors.textMuted, style = MaterialTheme.typography.bodySmall)
        }
    }
}

private fun LazyListScope.emptyMessage(text: StringRes) {
    item(key = "empty") {
        Text(
            text = stringResource(text),
            modifier = Modifier.fillMaxWidth().padding(start = 16.dp, top = 40.dp, end = 16.dp),
            color = appColors.textMuted,
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center,
        )
    }
}

/**
 * One word as a list row: the word (with its article), the meaning below, the level, and a
 * bookmark button. [faded] dims an earlier bookmark; [onLongClick] is only set where removing
 * is possible.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun BookmarkRow(
    word: Word,
    source: AppLanguage,
    target: AppLanguage,
    bookmarked: Boolean,
    faded: Boolean,
    onClick: () -> Unit,
    onLongClick: (() -> Unit)?,
    onToggleBookmark: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val colors = appColors
    val shape = RoundedCornerShape(16.dp)
    val article = word.article.takeIf { source == AppLanguage.DE }
    val meaning = word.translation(source, target)
    // Rows read in the direction of the learned language, like the word chips on Home.
    ProvideDirection(if (source.isRtl) LayoutDirection.Rtl else LayoutDirection.Ltr) {
        Row(
            modifier = modifier
                .fillMaxWidth()
                .softShadow(if (colors.isDark || faded) emptyList() else SoftShadows.listCard, cornerRadius = 16.dp)
                .clip(shape)
                .background(if (faded) MaterialTheme.colorScheme.surface.copy(alpha = 0.55f) else MaterialTheme.colorScheme.surface)
                .combinedClickable(onClick = onClick, onLongClick = onLongClick)
                .padding(start = 16.dp, top = 10.dp, bottom = 10.dp, end = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(Modifier.weight(1f).alpha(if (faded) 0.55f else 1f)) {
                Text(
                    text = buildAnnotatedString {
                        if (article != null) withStyle(SpanStyle(color = colors.textMuted, fontWeight = FontWeight.Medium)) { append("$article ") }
                        append(word.displayText(source))
                    },
                    color = colors.heading,
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.SemiBold,
                        textDirection = if (source.isRtl) TextDirection.Rtl else TextDirection.Ltr,
                    ),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                if (meaning.isNotEmpty()) {
                    Spacer(Modifier.height(2.dp))
                    Text(
                        text = meaning,
                        color = colors.textMuted,
                        style = MaterialTheme.typography.bodyMedium.copy(
                            textDirection = if (target.isRtl) TextDirection.Rtl else TextDirection.Ltr,
                        ),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
            Spacer(Modifier.width(8.dp))
            Text(
                text = word.level,
                modifier = Modifier
                    .alpha(if (faded) 0.55f else 1f)
                    .background(colors.tile, CircleShape)
                    .padding(horizontal = 8.dp, vertical = 3.dp),
                color = colors.textMuted,
                style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, textDirection = TextDirection.Ltr),
            )
            IconButton(onClick = onToggleBookmark) {
                Icon(
                    painter = painterResource(if (bookmarked) Res.drawable.ic_bookmark_filled else Res.drawable.ic_bookmark),
                    contentDescription = stringResource(if (bookmarked) Strings.bookmark_remove else Strings.bookmark_add),
                    modifier = Modifier.size(22.dp),
                    tint = if (bookmarked) MaterialTheme.colorScheme.primary else colors.textMuted,
                )
            }
        }
    }
}

/** Asks before a word leaves the Bookmarks page for good. */
@Composable
private fun RemoveBookmarkSheet(
    word: Word,
    source: AppLanguage,
    target: AppLanguage,
    onRemove: () -> Unit,
    onDismiss: () -> Unit,
) {
    val colors = appColors
    AppBottomSheet(onDismiss = onDismiss) { sheet ->
        Column(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 16.dp)) {
            Text(
                text = word.displayText(source),
                color = colors.heading,
                style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold),
            )
            val meaning = word.translation(source, target)
            if (meaning.isNotEmpty()) {
                Spacer(Modifier.height(2.dp))
                Text(meaning, color = colors.textMuted, style = MaterialTheme.typography.bodyLarge)
            }
            Spacer(Modifier.height(12.dp))
            Text(
                text = stringResource(Strings.bookmarks_remove_text),
                color = colors.textMuted,
                style = MaterialTheme.typography.bodyMedium,
            )
            Spacer(Modifier.height(18.dp))
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
                    text = stringResource(Strings.bookmarks_remove),
                    icon = Res.drawable.ic_x,
                    background = Palette.Failure,
                    contentColor = Color.White,
                    onClick = { sheet.close(then = onRemove) },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}
