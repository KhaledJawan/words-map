package dev.nefrin.wordsmap.ui

import dev.nefrin.wordsmap.ui.update.UpdateLayer
import androidx.lifecycle.compose.LifecycleResumeEffect
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.ContentState
import dev.nefrin.wordsmap.LessonsState
import dev.nefrin.wordsmap.Screen
import dev.nefrin.wordsmap.data.Library
import dev.nefrin.wordsmap.data.LibraryItem
import dev.nefrin.wordsmap.data.ThemeMode
import dev.nefrin.wordsmap.platform.SystemBars
import dev.nefrin.wordsmap.platform.BackHandler
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_badge_abc
import dev.nefrin.wordsmap.resources.ic_badge_link
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.CenteredMessage
import dev.nefrin.wordsmap.ui.components.LocalBackdropBlur
import dev.nefrin.wordsmap.ui.grammar.GrammarLessonScreen
import dev.nefrin.wordsmap.ui.learn.LearnSessionScreen
import dev.nefrin.wordsmap.ui.lessons.AlphabetLessonScreen
import dev.nefrin.wordsmap.ui.lessons.CombinationsLessonScreen
import dev.nefrin.wordsmap.ui.library.LibraryChapterScreen
import dev.nefrin.wordsmap.ui.library.LibraryKind
import dev.nefrin.wordsmap.ui.library.LibraryScreen
import dev.nefrin.wordsmap.ui.library.LibraryShortcut
import dev.nefrin.wordsmap.ui.mywords.MyWordsScreen
import dev.nefrin.wordsmap.ui.texts.ReadingTextScreen
import dev.nefrin.wordsmap.ui.theme.WordsMapTheme

/**
 * The whole app. [loading] is shown until the words are read: nothing on Android, where the
 * system splash screen stays up meanwhile, and the splash on iOS.
 */
@Composable
fun WordsMapApp(viewModel: AppViewModel, loading: @Composable () -> Unit = {}) {
    val darkTheme = when (viewModel.themeMode) {
        ThemeMode.SYSTEM -> isSystemInDarkTheme()
        ThemeMode.LIGHT -> false
        ThemeMode.DARK -> true
    }
    WordsMapTheme(darkTheme = darkTheme, language = viewModel.appLanguage) {
        val content = viewModel.content
        // Lesson screens have a colored top bar; everything else sits on the page background.
        val onColoredBar = content is ContentState.Ready && !viewModel.backStack.last().onPageBackground
        val onSplash = content is ContentState.Loading
        SystemBars(darkTheme = darkTheme, lightStatusBarIcons = darkTheme || onColoredBar || onSplash)

        val blurRequests = remember { mutableIntStateOf(0) }
        val blurRadius by animateDpAsState(
            targetValue = if (blurRequests.intValue > 0) 16.dp else 0.dp,
            animationSpec = tween(220),
            label = "backdropBlur",
        )
        CompositionLocalProvider(LocalBackdropBlur provides blurRequests) {
            Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background).blur(blurRadius)) {
                when (content) {
                    ContentState.Loading -> Unit
                    is ContentState.Ready -> AppScreens(viewModel, content)
                    ContentState.Failed -> CenteredMessage(stringResource(Strings.load_words_failed))
                }
            }
        }
        if (content is ContentState.Ready) {
            val updates = viewModel.updates
            // On start and on every return to the app; the check itself decides whether it is due.
            LifecycleResumeEffect(updates) {
                updates.checkAutomatically()
                onPauseOrDispose {}
            }
            Box(Modifier.fillMaxSize()) { UpdateLayer(updates, language = viewModel.appLanguage.code) }
        }
        if (content is ContentState.Loading) loading()
    }
}

/** Shows the screen on top of the back stack. */
@Composable
private fun AppScreens(viewModel: AppViewModel, content: ContentState.Ready) {
    val screenStates = rememberSaveableStateHolder()
    val goBack = {
        // A screen that was left for good starts fresh when opened again.
        viewModel.back()?.let { screenStates.removeState(it.key) }
        Unit
    }
    BackHandler(enabled = viewModel.backStack.size > 1, onBack = goBack)

    val language = viewModel.targetLanguage
    AnimatedContent(
        targetState = viewModel.backStack.last(),
        transitionSpec = { (fadeIn(tween(220)) + scaleIn(tween(220), initialScale = 0.97f)) togetherWith fadeOut(tween(120)) },
        label = "screen",
    ) { screen ->
        screenStates.SaveableStateProvider(screen.key) {
            when (screen) {
                Screen.Main -> MainScreen(viewModel, content)
                Screen.LearnSession -> LearnSessionScreen(viewModel, content.vocabulary, onClose = goBack)
                is Screen.MyWords -> MyWordsScreen(viewModel, content.vocabulary, startListId = screen.listId, onBack = goBack)
                Screen.Alphabet, Screen.Combinations -> when (val lessons = viewModel.lessons) {
                    is LessonsState.Ready -> if (screen == Screen.Alphabet) {
                        AlphabetLessonScreen(lessons.lessons.alphabet, content.vocabulary, viewModel, goBack)
                    } else {
                        CombinationsLessonScreen(lessons.lessons.combinations, content.vocabulary, viewModel, goBack)
                    }
                    else -> CenteredMessage(stringResource(Strings.lesson_load_failed))
                }
                Screen.Grammar -> LibraryScreen(
                    kind = LibraryKind.GRAMMAR,
                    library = content.grammar,
                    language = language,
                    completed = viewModel.completedLessonIds,
                    onOpenChapter = { viewModel.open(Screen.GrammarChapter(it)) },
                    onOpenItem = { viewModel.open(Screen.GrammarLesson(it.id)) },
                    onBack = goBack,
                    shortcuts = grammarBasics(viewModel),
                )
                is Screen.GrammarChapter -> ChapterOrMissing(LibraryKind.GRAMMAR, content.grammar, screen.chapterId, viewModel, goBack) {
                    viewModel.open(Screen.GrammarLesson(it.id))
                }
                is Screen.GrammarLesson -> when (val lesson = content.grammar.item(screen.lessonId)) {
                    null -> CenteredMessage(stringResource(Strings.lesson_load_failed))
                    else -> {
                        val key = LibraryKind.GRAMMAR.completionKey(lesson)
                        GrammarLessonScreen(
                            lesson = lesson,
                            language = language,
                            learned = key in viewModel.completedLessonIds,
                            onLearned = { viewModel.completeLesson(key) },
                            onBack = goBack,
                        )
                    }
                }
                Screen.Texts -> LibraryScreen(
                    kind = LibraryKind.TEXTS,
                    library = content.texts,
                    language = language,
                    completed = viewModel.completedLessonIds,
                    onOpenChapter = { viewModel.open(Screen.TextsChapter(it)) },
                    onOpenItem = { viewModel.open(Screen.Text(it.id)) },
                    onBack = goBack,
                )
                is Screen.TextsChapter -> ChapterOrMissing(LibraryKind.TEXTS, content.texts, screen.chapterId, viewModel, goBack) {
                    viewModel.open(Screen.Text(it.id))
                }
                is Screen.Text -> when (val text = content.texts.item(screen.textId)) {
                    null -> CenteredMessage(stringResource(Strings.lesson_load_failed))
                    else -> {
                        val key = LibraryKind.TEXTS.completionKey(text)
                        ReadingTextScreen(
                            text = text,
                            language = language,
                            wordIndex = content.wordIndex,
                            bookmarkedIds = viewModel.bookmarkedIds,
                            onToggleBookmark = viewModel::toggleBookmark,
                            highlightWords = viewModel.highlightReadingWords,
                            onToggleHighlight = viewModel::toggleReadingHighlights,
                            learned = key in viewModel.completedLessonIds,
                            onLearned = { viewModel.completeLesson(key) },
                            onBack = goBack,
                        )
                    }
                }
            }
        }
    }
}

/** The alphabet and letter combinations lessons, at the top of the Grammar page. */
@Composable
private fun grammarBasics(viewModel: AppViewModel): List<LibraryShortcut> {
    val lessons = (viewModel.lessons as? LessonsState.Ready)?.lessons ?: return emptyList()
    val completed = viewModel.completedLessonIds
    return listOf(
        LibraryShortcut(
            key = "alphabet",
            icon = Res.drawable.ic_badge_abc,
            title = lessons.alphabet.title,
            countLabel = Strings.lesson_letters_count,
            count = lessons.alphabet.letters.size,
            color = MaterialTheme.colorScheme.primary,
            fadeTo = 0.78f,
            completed = lessons.alphabet.id in completed,
            onClick = { viewModel.open(Screen.Alphabet) },
        ),
        LibraryShortcut(
            key = "combinations",
            icon = Res.drawable.ic_badge_link,
            title = lessons.combinations.title,
            countLabel = Strings.lesson_rules_count,
            count = lessons.combinations.rules.size,
            color = MaterialTheme.colorScheme.secondary,
            fadeTo = 0.82f,
            completed = lessons.combinations.id in completed,
            onClick = { viewModel.open(Screen.Combinations) },
        ),
    )
}

@Composable
private fun ChapterOrMissing(
    kind: LibraryKind,
    library: Library<*>,
    chapterId: String,
    viewModel: AppViewModel,
    onBack: () -> Unit,
    onOpenItem: (LibraryItem) -> Unit,
) {
    when (val chapter = library.chapter(chapterId)) {
        null -> CenteredMessage(stringResource(Strings.lesson_load_failed))
        else -> LibraryChapterScreen(
            kind = kind,
            library = library,
            chapter = chapter,
            language = viewModel.targetLanguage,
            completed = viewModel.completedLessonIds,
            onOpenItem = onOpenItem,
            onBack = onBack,
        )
    }
}
