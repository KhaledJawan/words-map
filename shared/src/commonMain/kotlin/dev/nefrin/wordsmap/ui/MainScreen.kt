package dev.nefrin.wordsmap.ui

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.ContentState
import dev.nefrin.wordsmap.MainTab
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_bookmark
import dev.nefrin.wordsmap.resources.ic_nav_home
import dev.nefrin.wordsmap.resources.ic_nav_learn
import dev.nefrin.wordsmap.resources.ic_nav_lessons
import dev.nefrin.wordsmap.resources.ic_nav_settings
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.bookmarks.BookmarksScreen
import dev.nefrin.wordsmap.ui.home.HomeScreen
import dev.nefrin.wordsmap.ui.learn.LearnScreen
import dev.nefrin.wordsmap.ui.lessons.LessonsScreen
import dev.nefrin.wordsmap.ui.profile.ProfileScreen
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

/** The root page: Home, Learn, Bookmarks, Lessons and Profile behind a bottom bar. */
@Composable
fun MainScreen(viewModel: AppViewModel, content: ContentState.Ready) {
    val tabStates = rememberSaveableStateHolder()
    Column(Modifier.fillMaxSize()) {
        Box(Modifier.weight(1f)) {
            // Each tab keeps its scroll position while another one is showing.
            tabStates.SaveableStateProvider(viewModel.selectedTab.name) {
                when (viewModel.selectedTab) {
                    MainTab.HOME -> HomeScreen(viewModel, content.vocabulary, content.wordSearch)
                    MainTab.LEARN -> LearnScreen(viewModel, content.vocabulary)
                    MainTab.BOOKMARKS -> BookmarksScreen(viewModel, content.vocabulary, content.wordSearch)
                    MainTab.LESSONS -> LessonsScreen(viewModel, content.grammar, content.texts)
                    MainTab.PROFILE -> ProfileScreen(viewModel)
                }
            }
        }
        BottomBar(selected = viewModel.selectedTab, onSelect = { viewModel.selectedTab = it })
    }
}

@Composable
private fun BottomBar(selected: MainTab, onSelect: (MainTab) -> Unit) {
    Surface(color = MaterialTheme.colorScheme.surface, shadowElevation = 10.dp) {
        // Tabs keep their order in right-to-left languages, like the original.
        ProvideDirection(LayoutDirection.Ltr) {
            Row(
                Modifier.fillMaxWidth().navigationBarsPadding().height(64.dp).padding(horizontal = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                BottomBarItem(Res.drawable.ic_nav_home, stringResource(Strings.tab_home), selected == MainTab.HOME) {
                    onSelect(MainTab.HOME)
                }
                BottomBarItem(Res.drawable.ic_nav_learn, stringResource(Strings.tab_learn), selected == MainTab.LEARN) {
                    onSelect(MainTab.LEARN)
                }
                BottomBarItem(Res.drawable.ic_bookmark, stringResource(Strings.tab_bookmarks), selected == MainTab.BOOKMARKS) {
                    onSelect(MainTab.BOOKMARKS)
                }
                BottomBarItem(Res.drawable.ic_nav_lessons, stringResource(Strings.tab_lessons), selected == MainTab.LESSONS) {
                    onSelect(MainTab.LESSONS)
                }
                BottomBarItem(Res.drawable.ic_nav_settings, stringResource(Strings.settings_title), selected == MainTab.PROFILE) {
                    onSelect(MainTab.PROFILE)
                }
            }
        }
    }
}

/** A tab shown by its icon alone; the selected one sits on a soft pill of the accent color. */
@Composable
private fun RowScope.BottomBarItem(
    icon: DrawableResource,
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
) {
    val primary = MaterialTheme.colorScheme.primary
    val pill by animateColorAsState(
        targetValue = if (selected) primary.copy(alpha = if (appColors.isDark) 0.24f else 0.14f) else Color.Transparent,
        animationSpec = tween(200),
        label = "tabPill",
    )
    val tint by animateColorAsState(
        targetValue = if (selected) primary else Palette.Grey500,
        animationSpec = tween(200),
        label = "tabIcon",
    )
    Box(
        modifier = Modifier
            .weight(1f)
            .fillMaxHeight()
            .selectable(
                selected = selected,
                interactionSource = null,
                indication = ripple(bounded = false, radius = 36.dp),
                role = Role.Tab,
                onClick = onClick,
            ),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier = Modifier.size(width = 60.dp, height = 36.dp).clip(CircleShape).background(pill),
            contentAlignment = Alignment.Center,
        ) {
            Icon(painterResource(icon), contentDescription = label, modifier = Modifier.size(24.dp), tint = tint)
        }
    }
}
