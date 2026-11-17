package dev.nefrin.wordsmap.ui.mywords

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.ReadOnlyComposable
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.UserWord
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.data.isUserWordId
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.WordDetail

/** What a word editor is open for: a new word ([wordId] empty) or one of the learner's words. */
internal const val NEW_WORD = ""

/**
 * The word editor wired to the app: [wordId] is the word to change, or [NEW_WORD] for a new
 * one that goes into [startListId]. [onSaved] gets the word as it was saved.
 */
@Composable
internal fun UserWordEditor(
    viewModel: AppViewModel,
    vocabulary: Vocabulary,
    wordId: String,
    startListId: String?,
    onDismiss: () -> Unit,
    onSaved: (UserWord) -> Unit = {},
) {
    val word = viewModel.userWord(wordId)
    // The word was deleted meanwhile.
    if (wordId != NEW_WORD && word == null) {
        LaunchedEffect(Unit) { onDismiss() }
        return
    }
    val source = viewModel.sourceLanguage
    WordEditorSheet(
        word = word,
        lists = viewModel.userLists,
        startListId = startListId,
        germanArticles = source == AppLanguage.DE,
        source = source,
        target = viewModel.targetLanguage,
        // Only the app's own words; the learner's own are found as duplicates.
        findKnown = { text -> vocabulary.find(text)?.takeIf { !isUserWordId(it.id) } },
        isDuplicate = { text -> viewModel.userWords.any { it.id != wordId && it.text.equals(text, ignoreCase = true) } },
        onCreateList = viewModel::addUserList,
        onSave = { saved ->
            viewModel.saveUserWord(saved)
            onSaved(saved)
        },
        onDelete = word?.let { { viewModel.deleteUserWord(it.id) } },
        onDismiss = onDismiss,
    )
}

/** The card texts of one of the learner's words: "My words • Work" above the word. */
@Composable
@ReadOnlyComposable
internal fun UserWord.toDetail(listName: String?): WordDetail = WordDetail(
    label = listOfNotNull(stringResource(Strings.my_words), listName).joinToString(" • "),
    word = text,
    translation = translation,
    article = article,
    plural = plural,
    example = example,
)
