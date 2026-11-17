package dev.nefrin.wordsmap.ui.library

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.Library
import dev.nefrin.wordsmap.data.LibraryChapter
import dev.nefrin.wordsmap.data.LibraryItem
import dev.nefrin.wordsmap.data.LocalizedText
import dev.nefrin.wordsmap.data.normalizeForSearch
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.StringRes
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_check_circle_2
import dev.nefrin.wordsmap.resources.ic_chevron_right
import dev.nefrin.wordsmap.resources.ic_circle
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ColorTopBar
import dev.nefrin.wordsmap.ui.components.LessonCard
import dev.nefrin.wordsmap.ui.components.SearchField
import dev.nefrin.wordsmap.ui.components.SoftShadows
import dev.nefrin.wordsmap.ui.components.directionFor
import dev.nefrin.wordsmap.ui.components.softShadow
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

/**
 * A lesson that is not in a level folder, such as the alphabet, shown as a big card above
 * the levels. [countLabel] is a string resource with one placeholder for [count].
 */
class LibraryShortcut(
    val key: String,
    val icon: DrawableResource,
    val title: LocalizedText,
    val countLabel: StringRes,
    val count: Int,
    val color: Color,
    val fadeTo: Float,
    val completed: Boolean,
    val onClick: () -> Unit,
) {
    /** Found by its title in any language. */
    fun matches(normalizedQuery: String): Boolean = title.all.any { normalizedQuery in normalizeForSearch(it) }
}

/** Home of a library: a search over all levels on top, then the [shortcuts] and one card per level. */
@Composable
fun LibraryScreen(
    kind: LibraryKind,
    library: Library<*>,
    language: AppLanguage,
    completed: Set<String>,
    onOpenChapter: (String) -> Unit,
    onOpenItem: (LibraryItem) -> Unit,
    onBack: () -> Unit,
    shortcuts: List<LibraryShortcut> = emptyList(),
) {
    var query by rememberSaveable { mutableStateOf("") }
    val results = remember(library, query, language) { library.search(query, language) }
    val shownShortcuts = if (query.isBlank()) shortcuts else shortcuts.filter { it.matches(normalizeForSearch(query)) }
    LibraryPage(kind, kind.title(), query, { query = it }, onBack) {
        items(shownShortcuts, key = { "shortcut:${it.key}" }) { shortcut ->
            LessonCard(
                icon = shortcut.icon,
                title = shortcut.title.resolve(language),
                subtitle = if (shortcut.count == 0) "" else stringResource(shortcut.countLabel, shortcut.count.toString()),
                color = shortcut.color,
                fadeTo = shortcut.fadeTo,
                completed = shortcut.completed,
                onClick = shortcut.onClick,
            )
        }
        when {
            query.isBlank() -> items(library.chapters, key = { it.id }) { chapter ->
                ChapterCard(
                    kind = kind,
                    chapter = chapter,
                    learned = chapter.items.count { kind.completionKey(it) in completed },
                    onClick = { onOpenChapter(chapter.id) },
                )
            }
            results.isEmpty() -> if (shownShortcuts.isEmpty()) item { NoResults(kind.noResults()) }
            else -> items(results, key = { it.id }) { item ->
                LibraryItemCard(kind, item, language, kind.completionKey(item) in completed, showLevel = true) {
                    onOpenItem(item)
                }
            }
        }
    }
}

/** The items of one level as small cards, with a search inside the level on top. */
@Composable
fun LibraryChapterScreen(
    kind: LibraryKind,
    library: Library<*>,
    chapter: LibraryChapter<*>,
    language: AppLanguage,
    completed: Set<String>,
    onOpenItem: (LibraryItem) -> Unit,
    onBack: () -> Unit,
) {
    var query by rememberSaveable { mutableStateOf("") }
    val items = remember(library, chapter, query, language) {
        if (query.isBlank()) chapter.items else library.search(query, language, chapter.id)
    }
    LibraryPage(kind, kind.chapterTitle(chapter.label), query, { query = it }, onBack) {
        when {
            chapter.items.isEmpty() -> item { NoResults(kind.countLabel(0)) }
            items.isEmpty() -> item { NoResults(kind.noResults()) }
            else -> items(items, key = { it.id }) { item ->
                LibraryItemCard(kind, item, language, kind.completionKey(item) in completed, showLevel = false) {
                    onOpenItem(item)
                }
            }
        }
    }
}

@Composable
private fun LibraryPage(
    kind: LibraryKind,
    title: String,
    query: String,
    onQueryChange: (String) -> Unit,
    onBack: () -> Unit,
    content: LazyListScope.() -> Unit,
) {
    Column(Modifier.fillMaxSize()) {
        ColorTopBar(title, kind.color, onBack)
        SearchField(
            query = query,
            hint = kind.searchHint(),
            cursor = kind.color,
            onQueryChange = onQueryChange,
            modifier = Modifier.padding(start = 16.dp, top = 16.dp, end = 16.dp),
        )
        LazyColumn(
            modifier = Modifier.fillMaxSize().windowInsetsPadding(WindowInsets.navigationBars).imePadding(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            content = content,
        )
    }
}

@Composable
private fun NoResults(text: String) {
    Text(
        text = text,
        modifier = Modifier.fillMaxWidth().padding(top = 32.dp),
        color = appColors.textMuted,
        style = MaterialTheme.typography.bodyLarge,
        textAlign = TextAlign.Center,
    )
}

@Composable
private fun ChapterCard(kind: LibraryKind, chapter: LibraryChapter<*>, learned: Int, onClick: () -> Unit) {
    val total = chapter.items.size
    val allLearned = total > 0 && learned == total
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .softShadow(SoftShadows.listCard, cornerRadius = 20.dp)
            .clip(RoundedCornerShape(20.dp))
            .background(MaterialTheme.colorScheme.surface)
            .clickable(enabled = total > 0, onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(46.dp)
                .background(kind.color.copy(alpha = 0.12f), RoundedCornerShape(14.dp)),
            contentAlignment = Alignment.Center,
        ) {
            Text(chapter.label, color = kind.accent, style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Black))
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(
                text = kind.chapterTitle(chapter.label),
                color = appColors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
            )
            Spacer(Modifier.height(6.dp))
            Text(
                text = if (learned > 0) {
                    kind.countLabel(total) + " • " + stringResource(Strings.library_learned_count, learned.toString())
                } else {
                    kind.countLabel(total)
                },
                color = appColors.textMuted,
                style = MaterialTheme.typography.bodyMedium,
            )
        }
        when {
            allLearned -> Icon(painterResource(Res.drawable.ic_check_circle_2), stringResource(Strings.lesson_learned), tint = Palette.Success)
            total > 0 -> Icon(painterResource(Res.drawable.ic_chevron_right), null, tint = appColors.textMuted)
        }
    }
}

/**
 * A lesson or text as a small card, with whether it is learned. A lesson with a topic shows
 * its number, the topic ("Personalpronomen") and below it the title from the book; anything
 * else shows its title and short description.
 */
@Composable
private fun LibraryItemCard(
    kind: LibraryKind,
    item: LibraryItem,
    language: AppLanguage,
    learned: Boolean,
    showLevel: Boolean,
    onClick: () -> Unit,
) {
    val hasTopic = !item.topic.resolveOrAny(language).isEmpty()
    val heading = if (hasTopic) item.topic else item.title
    val subline = if (hasTopic) item.title else item.description
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surface)
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        item.number?.let { number ->
            Box(
                modifier = Modifier.size(36.dp).background(kind.color.copy(alpha = 0.12f), CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Text("$number", color = kind.accent, style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Black))
            }
            Spacer(Modifier.width(12.dp))
        }
        Column(Modifier.weight(1f)) {
            if (showLevel) {
                Text(
                    text = item.chapterId.uppercase(),
                    color = kind.accent,
                    style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold),
                )
            }
            Text(
                text = heading.resolveOrAny(language),
                modifier = Modifier.fillMaxWidth(),
                color = appColors.heading,
                style = MaterialTheme.typography.bodyLarge.copy(
                    fontWeight = FontWeight.SemiBold,
                    textDirection = heading.directionFor(language),
                ),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
            val secondLine = subline.resolveOrAny(language)
            if (secondLine.isNotEmpty()) {
                Spacer(Modifier.height(2.dp))
                Text(
                    text = secondLine,
                    modifier = Modifier.fillMaxWidth(),
                    color = appColors.textMuted,
                    style = MaterialTheme.typography.bodySmall.copy(textDirection = subline.directionFor(language)),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
        Spacer(Modifier.width(12.dp))
        Icon(
            painter = painterResource(if (learned) Res.drawable.ic_check_circle_2 else Res.drawable.ic_circle),
            contentDescription = stringResource(if (learned) Strings.lesson_learned else Strings.lesson_not_learned),
            tint = if (learned) Palette.Success else Palette.Grey400,
        )
    }
}
