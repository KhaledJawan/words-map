package dev.nefrin.wordsmap.ui.lessons

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.Screen
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.Grammar
import dev.nefrin.wordsmap.data.Library
import dev.nefrin.wordsmap.data.Texts
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_languages
import dev.nefrin.wordsmap.resources.ic_sparkles
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.LessonCard
import dev.nefrin.wordsmap.ui.components.PillButton
import dev.nefrin.wordsmap.ui.library.LibraryKind
import dev.nefrin.wordsmap.ui.library.countLabel
import dev.nefrin.wordsmap.ui.library.title
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.painterResource

/**
 * The Lessons tab: Grammar (which starts with the alphabet and letter combinations) and
 * Reading. Like the whole interface it is in the app language; only the lessons themselves
 * are written in the "Translate To" language.
 */
@Composable
fun LessonsScreen(viewModel: AppViewModel, grammar: Grammar, texts: Texts) {
    LazyColumn(
        modifier = Modifier.fillMaxSize().statusBarsPadding(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        item {
            Text(
                text = stringResource(Strings.lessons_title),
                modifier = Modifier.padding(bottom = 2.dp),
                color = appColors.heading,
                style = MaterialTheme.typography.titleLarge,
            )
        }
        // The lessons teach German; for any other learned language they are still a beta.
        if (viewModel.sourceLanguage != AppLanguage.DE) {
            item { BetaNotice(onLearnGerman = viewModel::learnGerman) }
        }
        item { LibraryCard(LibraryKind.GRAMMAR, grammar, onClick = { viewModel.open(Screen.Grammar) }) }
        item { LibraryCard(LibraryKind.TEXTS, texts, onClick = { viewModel.open(Screen.Texts) }) }
    }
}

/** Says that only German lessons exist so far, with a way to switch to learning German. */
@Composable
private fun BetaNotice(onLearnGerman: () -> Unit) {
    val accent = MaterialTheme.colorScheme.secondary
    val shape = RoundedCornerShape(20.dp)
    Column(
        Modifier
            .fillMaxWidth()
            .clip(shape)
            .background(MaterialTheme.colorScheme.surface)
            .border(1.dp, accent.copy(alpha = 0.45f), shape)
            .padding(16.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(36.dp).background(accent.copy(alpha = 0.16f), CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Icon(painterResource(Res.drawable.ic_sparkles), contentDescription = null, modifier = Modifier.size(18.dp), tint = accent)
            }
            Spacer(Modifier.width(12.dp))
            Text(
                text = stringResource(Strings.lessons_beta_title),
                color = appColors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
            )
        }
        Spacer(Modifier.height(8.dp))
        Text(
            text = stringResource(Strings.lessons_beta_text),
            color = appColors.textMuted,
            style = MaterialTheme.typography.bodyMedium,
        )
        Spacer(Modifier.height(14.dp))
        PillButton(
            text = stringResource(Strings.lessons_beta_switch),
            icon = Res.drawable.ic_languages,
            background = appColors.headerButton,
            contentColor = appColors.onHeaderButton,
            onClick = onLearnGerman,
        )
    }
}

@Composable
private fun LibraryCard(kind: LibraryKind, library: Library<*>, onClick: () -> Unit) {
    val levels = library.chapters
    // The isolate marks keep "A1 – C1" in one piece inside right-to-left text.
    val range = "\u2066${levels.first().label} – ${levels.last().label}\u2069"
    LessonCard(
        icon = kind.icon,
        title = kind.title(),
        // Grammar is never empty: the alphabet and letter combinations come before the levels.
        subtitle = if (library.itemCount == 0) range else "$range • " + kind.countLabel(library.itemCount),
        color = kind.color,
        completed = false,
        onClick = onClick,
    )
}
