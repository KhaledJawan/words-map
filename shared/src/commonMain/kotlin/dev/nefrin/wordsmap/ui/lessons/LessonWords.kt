package dev.nefrin.wordsmap.ui.lessons

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.LayoutDirection
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.WordChip
import dev.nefrin.wordsmap.ui.components.WordChipDefaults
import dev.nefrin.wordsmap.ui.components.WordDetail
import dev.nefrin.wordsmap.ui.components.WordDetailOverlay
import dev.nefrin.wordsmap.ui.components.toDetail

/**
 * The example words of a lesson as chips. A chip opens the word card without a bookmark
 * button; a key that matches no word of the vocabulary opens a "not found" card.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
internal fun LessonWordChips(
    keys: List<String>,
    vocabulary: Vocabulary,
    viewModel: AppViewModel,
    modifier: Modifier = Modifier,
) {
    val source = viewModel.sourceLanguage
    var openDetail by remember { mutableStateOf<WordDetail?>(null) }
    val missing = WordDetail(
        label = stringResource(Strings.word_not_found_label),
        word = "",
        translation = stringResource(Strings.word_not_found),
        note = stringResource(Strings.word_not_found_body),
    )
    val details = keys.map { key ->
        val word = vocabulary.find(key)
        word to (word?.toDetail(source, viewModel.targetLanguage) ?: missing.withWord(key))
    }
    ProvideDirection(LayoutDirection.Ltr) {
        FlowRow(
            modifier = modifier,
            horizontalArrangement = Arrangement.spacedBy(WordChipDefaults.Spacing),
            verticalArrangement = Arrangement.spacedBy(WordChipDefaults.VerticalMargin),
        ) {
            for ((word, detail) in details) {
                WordChip(
                    text = detail.word,
                    bookmarked = word != null && word.id in viewModel.bookmarkedIds,
                    viewed = word != null && word.id in viewModel.viewedIds,
                    rightToLeft = source.isRtl,
                    onClick = { openDetail = detail },
                    onLongClick = { openDetail = detail },
                )
            }
        }
    }
    openDetail?.let { detail ->
        WordDetailOverlay(detail, bookmarked = null, onToggleBookmark = {}, onDismiss = { openDetail = null })
    }
}

private fun WordDetail.withWord(word: String) =
    WordDetail(label = label, word = word, translation = translation, note = note)
