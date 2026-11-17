package dev.nefrin.wordsmap.ui.mywords

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
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
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.focus.FocusDirection
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.UserList
import dev.nefrin.wordsmap.data.UserWord
import dev.nefrin.wordsmap.data.Word
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_check
import dev.nefrin.wordsmap.resources.ic_chevron_down
import dev.nefrin.wordsmap.resources.ic_plus
import dev.nefrin.wordsmap.resources.ic_sparkles
import dev.nefrin.wordsmap.resources.ic_tag
import dev.nefrin.wordsmap.resources.ic_trash
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.AppBottomSheet
import dev.nefrin.wordsmap.ui.components.PillButton
import dev.nefrin.wordsmap.ui.components.close
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource

private val articleChoices = listOf("der", "die", "das")

/**
 * Adds a word of the learner's own, or changes one ([word] is then that word).
 *
 * @param startListId the category a new word goes into
 * @param germanArticles whether to offer der, die and das: only while learning German
 * @param findKnown the app's own word with that text, if there is one, to take its meaning from
 * @param isDuplicate whether another of the learner's words has that text already
 * @param onCreateList makes a category and returns it, or null for an empty name
 * @param onDelete deletes the word; null for a new one
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
internal fun WordEditorSheet(
    word: UserWord?,
    lists: List<UserList>,
    startListId: String?,
    germanArticles: Boolean,
    source: AppLanguage,
    target: AppLanguage,
    findKnown: (String) -> Word?,
    isDuplicate: (String) -> Boolean,
    onCreateList: (String) -> UserList?,
    onSave: (UserWord) -> Unit,
    onDelete: (() -> Unit)?,
    onDismiss: () -> Unit,
) {
    var text by rememberSaveable { mutableStateOf(word?.text.orEmpty()) }
    var translation by rememberSaveable { mutableStateOf(word?.translation.orEmpty()) }
    var article by rememberSaveable { mutableStateOf(word?.article) }
    var plural by rememberSaveable { mutableStateOf(word?.plural.orEmpty()) }
    var example by rememberSaveable { mutableStateOf(word?.example.orEmpty()) }
    var listId by rememberSaveable { mutableStateOf(word?.listId ?: startListId) }
    var showMore by rememberSaveable { mutableStateOf(!word?.plural.isNullOrEmpty() || !word?.example.isNullOrEmpty()) }
    var newList by rememberSaveable { mutableStateOf<String?>(null) }
    var confirmDelete by rememberSaveable { mutableStateOf(false) }
    val colors = appColors
    val focus = LocalFocusManager.current
    val wordFocus = remember { FocusRequester() }
    if (word == null) LaunchedEffect(Unit) { wordFocus.requestFocus() }

    val typed = text.trim()
    val known = remember(typed) { typed.takeIf { it.length > 1 }?.let(findKnown) }
    val duplicate = remember(typed) { typed.isNotEmpty() && isDuplicate(typed) }
    val canSave = typed.isNotEmpty() && translation.isNotBlank()

    AppBottomSheet(onDismiss = onDismiss) { sheet ->
        val save = {
            if (canSave) {
                onSave(
                    UserWord(
                        id = word?.id.orEmpty(),
                        text = typed,
                        translation = translation,
                        // The article stays as it was while another language is learned.
                        article = if (germanArticles) article else word?.article,
                        plural = plural,
                        example = example,
                        listId = listId,
                    ),
                )
                sheet.close()
            }
        }
        Column(
            Modifier
                .fillMaxWidth()
                .imePadding()
                .verticalScroll(rememberScrollState())
                .padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
        ) {
            Text(
                text = stringResource(if (word == null) Strings.editor_new_title else Strings.editor_edit_title),
                color = colors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
            )
            Spacer(Modifier.height(16.dp))
            FormField(
                value = text,
                onValueChange = { text = it },
                label = stringResource(Strings.editor_word),
                hint = stringResource(Strings.editor_word_hint),
                modifier = Modifier.focusRequester(wordFocus),
                onNext = { focus.moveFocus(FocusDirection.Down) },
            )
            if (known != null) {
                val knownWord = known.displayText(source)
                val knownMeaning = known.translation(source, target)
                if (!knownMeaning.equals(translation.trim(), ignoreCase = true)) {
                    Spacer(Modifier.height(8.dp))
                    KnownWordHint(
                        text = stringResource(
                            Strings.editor_known,
                            listOfNotNull(known.article.takeIf { germanArticles }, knownWord).joinToString(" ") + " – " + knownMeaning,
                        ),
                        onUse = {
                            text = knownWord
                            translation = knownMeaning
                            if (germanArticles && known.article != null) article = known.article
                            if (plural.isEmpty() && known.plural != null) plural = known.plural
                        },
                    )
                }
            } else if (duplicate) {
                Spacer(Modifier.height(6.dp))
                Text(
                    text = stringResource(Strings.editor_duplicate),
                    modifier = Modifier.padding(start = 4.dp),
                    color = Palette.AccentOrange,
                    style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.SemiBold),
                )
            }
            Spacer(Modifier.height(14.dp))
            FormField(
                value = translation,
                onValueChange = { translation = it },
                label = stringResource(Strings.editor_meaning),
                hint = stringResource(Strings.editor_meaning_hint),
                imeAction = ImeAction.Done,
                onDone = save,
            )
            if (germanArticles) {
                Spacer(Modifier.height(16.dp))
                FieldLabel(stringResource(Strings.editor_article))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    ChoiceChip("–", selected = article == null, onClick = { article = null })
                    for (option in articleChoices) {
                        ChoiceChip(option, selected = article == option, onClick = { article = option })
                    }
                }
            }
            Spacer(Modifier.height(16.dp))
            FieldLabel(stringResource(Strings.editor_category))
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                ChoiceChip(stringResource(Strings.my_words_no_list), selected = listId == null, onClick = { listId = null })
                for (list in lists) {
                    ChoiceChip(list.name, selected = listId == list.id, icon = Res.drawable.ic_tag, onClick = { listId = list.id })
                }
                if (newList == null) {
                    ChoiceChip(stringResource(Strings.my_words_new_list), selected = false, icon = Res.drawable.ic_plus, onClick = { newList = "" })
                }
            }
            AnimatedVisibility(visible = newList != null) {
                val listFocus = remember { FocusRequester() }
                LaunchedEffect(Unit) { listFocus.requestFocus() }
                val addList = {
                    onCreateList(newList.orEmpty())?.let { listId = it.id }
                    newList = null
                }
                Row(Modifier.padding(top = 10.dp), verticalAlignment = Alignment.Bottom) {
                    FormField(
                        value = newList.orEmpty(),
                        onValueChange = { newList = it },
                        label = stringResource(Strings.my_words_list_name),
                        hint = stringResource(Strings.my_words_list_hint),
                        modifier = Modifier.weight(1f).focusRequester(listFocus),
                        imeAction = ImeAction.Done,
                        onDone = addList,
                    )
                    Spacer(Modifier.width(8.dp))
                    PillButton(
                        text = stringResource(Strings.common_add),
                        background = colors.headerButton,
                        contentColor = colors.onHeaderButton,
                        onClick = addList,
                        modifier = Modifier.heightIn(min = 52.dp),
                    )
                }
            }
            Spacer(Modifier.height(12.dp))
            MoreToggle(open = showMore, onClick = { showMore = !showMore })
            AnimatedVisibility(visible = showMore) {
                Column {
                    Spacer(Modifier.height(8.dp))
                    FormField(
                        value = plural,
                        onValueChange = { plural = it },
                        label = stringResource(Strings.editor_plural),
                        onNext = { focus.moveFocus(FocusDirection.Down) },
                    )
                    Spacer(Modifier.height(14.dp))
                    FormField(
                        value = example,
                        onValueChange = { example = it },
                        label = stringResource(Strings.editor_example),
                        singleLine = false,
                        imeAction = ImeAction.Default,
                    )
                }
            }
            Spacer(Modifier.height(20.dp))
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
                    text = stringResource(Strings.editor_save),
                    icon = Res.drawable.ic_check,
                    background = if (canSave) colors.headerButton else colors.headerButton.copy(alpha = 0.35f),
                    contentColor = colors.onHeaderButton,
                    onClick = save,
                    modifier = Modifier.weight(1f),
                )
            }
            if (onDelete != null) {
                Spacer(Modifier.height(10.dp))
                if (confirmDelete) {
                    DeleteConfirm(
                        question = stringResource(Strings.editor_delete_confirm),
                        onKeep = { confirmDelete = false },
                        onDelete = { sheet.close(then = onDelete) },
                    )
                } else {
                    DeleteLink(stringResource(Strings.editor_delete), onClick = { confirmDelete = true })
                }
            }
        }
    }
}

/** Creates a category, or renames one ([list] is then that one) and offers to delete it. */
@Composable
internal fun ListEditorSheet(
    list: UserList?,
    onSave: (String) -> Unit,
    onDelete: (() -> Unit)?,
    onDismiss: () -> Unit,
) {
    var name by rememberSaveable { mutableStateOf(list?.name.orEmpty()) }
    var confirmDelete by rememberSaveable { mutableStateOf(false) }
    val colors = appColors
    val nameFocus = remember { FocusRequester() }
    LaunchedEffect(Unit) { nameFocus.requestFocus() }
    AppBottomSheet(onDismiss = onDismiss) { sheet ->
        val save = {
            if (name.isNotBlank()) {
                onSave(name)
                sheet.close()
            }
        }
        Column(Modifier.fillMaxWidth().imePadding().padding(start = 16.dp, end = 16.dp, bottom = 16.dp)) {
            Text(
                text = stringResource(if (list == null) Strings.my_words_new_list else Strings.my_words_edit_list),
                color = colors.heading,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
            )
            Spacer(Modifier.height(16.dp))
            FormField(
                value = name,
                onValueChange = { name = it },
                label = stringResource(Strings.my_words_list_name),
                hint = stringResource(Strings.my_words_list_hint),
                modifier = Modifier.focusRequester(nameFocus),
                imeAction = ImeAction.Done,
                onDone = save,
            )
            Spacer(Modifier.height(20.dp))
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
                    text = stringResource(Strings.editor_save),
                    icon = Res.drawable.ic_check,
                    background = if (name.isNotBlank()) colors.headerButton else colors.headerButton.copy(alpha = 0.35f),
                    contentColor = colors.onHeaderButton,
                    onClick = save,
                    modifier = Modifier.weight(1f),
                )
            }
            if (onDelete != null) {
                Spacer(Modifier.height(10.dp))
                if (confirmDelete) {
                    DeleteConfirm(
                        question = stringResource(Strings.my_words_delete_list_text),
                        onKeep = { confirmDelete = false },
                        onDelete = { sheet.close(then = onDelete) },
                    )
                } else {
                    DeleteLink(stringResource(Strings.my_words_delete_list), onClick = { confirmDelete = true })
                }
            }
        }
    }
}

/** A labelled text box in the style of the search field, on the tile color of the sheets. */
@Composable
internal fun FormField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    hint: String = "",
    singleLine: Boolean = true,
    imeAction: ImeAction = ImeAction.Next,
    onNext: () -> Unit = {},
    onDone: () -> Unit = {},
) {
    val colors = appColors
    val primary = MaterialTheme.colorScheme.primary
    val interaction = remember { MutableInteractionSource() }
    val focused by interaction.collectIsFocusedAsState()
    // Typed text reads in its own direction: a Farsi meaning inside an English interface too.
    val style = MaterialTheme.typography.bodyLarge.copy(color = colors.heading, textDirection = TextDirection.Content)
    val shape = RoundedCornerShape(14.dp)
    Column(modifier) {
        FieldLabel(label)
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier.fillMaxWidth(),
            textStyle = style,
            singleLine = singleLine,
            minLines = if (singleLine) 1 else 2,
            interactionSource = interaction,
            keyboardOptions = KeyboardOptions(imeAction = imeAction),
            keyboardActions = KeyboardActions(onNext = { onNext() }, onDone = { onDone() }),
            cursorBrush = SolidColor(primary),
            decorationBox = { inner ->
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(min = 52.dp)
                        .background(colors.tile, shape)
                        .border(if (focused) 1.5.dp else 1.dp, if (focused) primary else colors.tileBorder, shape)
                        .padding(horizontal = 14.dp, vertical = 14.dp),
                    contentAlignment = Alignment.CenterStart,
                ) {
                    if (value.isEmpty() && hint.isNotEmpty()) {
                        Text(hint, color = colors.textMuted.copy(alpha = colors.textMuted.alpha * 0.8f), style = style, maxLines = 1)
                    }
                    inner()
                }
            },
        )
    }
}

@Composable
private fun FieldLabel(text: String) {
    Text(
        text = text,
        modifier = Modifier.padding(start = 4.dp, bottom = 6.dp),
        color = appColors.heading.copy(alpha = appColors.heading.alpha * 0.75f),
        style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
    )
}

/** A pill to pick one of a few options; the picked one is filled with the accent color. */
@Composable
internal fun ChoiceChip(
    text: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: DrawableResource? = null,
) {
    val colors = appColors
    val primary = MaterialTheme.colorScheme.primary
    val content = if (selected) Color.White else colors.tileText
    Row(
        modifier = modifier
            .heightIn(min = 38.dp)
            .clip(CircleShape)
            .background(if (selected) primary else colors.tile)
            .border(1.dp, if (selected) primary else colors.tileBorder, CircleShape)
            .clickable(role = Role.RadioButton, onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Icon(painterResource(icon), contentDescription = null, modifier = Modifier.size(15.dp), tint = content)
            Spacer(Modifier.width(6.dp))
        }
        Text(
            text = text,
            color = content,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

/** "In WordsMap: der Apfel – apple", with a button that fills the form with it. */
@Composable
private fun KnownWordHint(text: String, onUse: () -> Unit) {
    val primary = MaterialTheme.colorScheme.primary
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(primary.copy(alpha = if (appColors.isDark) 0.18f else 0.08f))
            .padding(start = 12.dp, top = 6.dp, bottom = 6.dp, end = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(painterResource(Res.drawable.ic_sparkles), contentDescription = null, modifier = Modifier.size(16.dp), tint = primary)
        Spacer(Modifier.width(8.dp))
        Text(
            text = text,
            modifier = Modifier.weight(1f),
            color = appColors.heading,
            style = MaterialTheme.typography.bodySmall.copy(textDirection = TextDirection.Content),
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
        Text(
            text = stringResource(Strings.editor_use),
            modifier = Modifier
                .clip(CircleShape)
                .clickable(role = Role.Button, onClick = onUse)
                .padding(horizontal = 12.dp, vertical = 8.dp),
            color = primary,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
        )
    }
}

@Composable
private fun MoreToggle(open: Boolean, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .clip(CircleShape)
            .clickable(onClick = onClick)
            .padding(start = 4.dp, end = 10.dp, top = 8.dp, bottom = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = stringResource(Strings.editor_more),
            color = MaterialTheme.colorScheme.primary,
            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
        )
        Spacer(Modifier.width(4.dp))
        Icon(
            painter = painterResource(Res.drawable.ic_chevron_down),
            contentDescription = null,
            modifier = Modifier.size(18.dp).rotate(if (open) 180f else 0f),
            tint = MaterialTheme.colorScheme.primary,
        )
    }
}

@Composable
private fun DeleteLink(text: String, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(CircleShape)
            .clickable(role = Role.Button, onClick = onClick)
            .padding(vertical = 12.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(painterResource(Res.drawable.ic_trash), contentDescription = null, modifier = Modifier.size(18.dp), tint = Palette.Failure)
        Spacer(Modifier.width(8.dp))
        Text(text, color = Palette.Failure, style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold))
    }
}

/** Asks once more before something is deleted for good. */
@Composable
private fun DeleteConfirm(question: String, onKeep: () -> Unit, onDelete: () -> Unit) {
    Column(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(Palette.Failure.copy(alpha = if (appColors.isDark) 0.16f else 0.07f))
            .padding(12.dp),
    ) {
        Text(
            text = question,
            modifier = Modifier.fillMaxWidth(),
            color = appColors.heading,
            style = MaterialTheme.typography.bodyMedium,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(10.dp))
        Row {
            PillButton(
                text = stringResource(Strings.editor_keep),
                background = appColors.tile,
                contentColor = appColors.heading,
                onClick = onKeep,
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(10.dp))
            PillButton(
                text = stringResource(Strings.common_delete),
                icon = Res.drawable.ic_trash,
                background = Palette.Failure,
                contentColor = Color.White,
                onClick = onDelete,
                modifier = Modifier.weight(1f),
            )
        }
    }
}
