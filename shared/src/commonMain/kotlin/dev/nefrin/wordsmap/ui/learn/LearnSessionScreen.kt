package dev.nefrin.wordsmap.ui.learn

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutLinearInEasing
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.util.VelocityTracker
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.nefrin.wordsmap.AppViewModel
import dev.nefrin.wordsmap.data.Vocabulary
import dev.nefrin.wordsmap.data.isUserWordId
import dev.nefrin.wordsmap.learn.CardSession
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.ic_check
import dev.nefrin.wordsmap.resources.ic_flame
import dev.nefrin.wordsmap.resources.ic_plus
import dev.nefrin.wordsmap.resources.ic_repeat
import dev.nefrin.wordsmap.resources.ic_bookmark
import dev.nefrin.wordsmap.resources.ic_bookmark_plus
import dev.nefrin.wordsmap.resources.ic_rotate
import dev.nefrin.wordsmap.resources.ic_undo
import dev.nefrin.wordsmap.resources.ic_x
import dev.nefrin.wordsmap.resources.stringResource
import dev.nefrin.wordsmap.ui.components.PillButton
import dev.nefrin.wordsmap.ui.components.ProvideDirection
import dev.nefrin.wordsmap.ui.components.SoftShadows
import dev.nefrin.wordsmap.ui.components.WordDetail
import dev.nefrin.wordsmap.ui.components.softShadow
import dev.nefrin.wordsmap.ui.components.toDetail
import dev.nefrin.wordsmap.ui.home.CircleButton
import dev.nefrin.wordsmap.ui.mywords.toDetail
import dev.nefrin.wordsmap.ui.theme.Palette
import dev.nefrin.wordsmap.ui.theme.appColors
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.launch
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource
import kotlin.math.abs

// "Not yet" is orange rather than red: a word not known yet is no mistake.
private val KnowColor = Palette.Success
private val AgainColor = Palette.AccentOrange
private val CardRadius = 28.dp

/** How far a card is dragged, as a share of the width, before letting go answers it. */
private const val ANSWER_SHARE = 0.28f

/**
 * The cards of the day, one at a time. A tap turns a card over to its meaning; swiping it
 * right (or the check button) means "I know it", swiping it left "Not yet". The cards not
 * known come again, round after round, until every card has gone right.
 */
@Composable
fun LearnSessionScreen(viewModel: AppViewModel, vocabulary: Vocabulary, onClose: () -> Unit) {
    val learning = viewModel.learning
    // Opened without a sitting, as the screenshot hook does: start one.
    LaunchedEffect(Unit) { if (learning.session == null) learning.start() }
    // While the screen fades out after closing, it keeps showing the sitting it had.
    val last = remember { arrayOfNulls<CardSession>(1) }
    val session = (learning.session ?: last[0]) ?: return
    last[0] = session

    val source = viewModel.sourceLanguage
    val target = viewModel.targetLanguage
    val listNames = viewModel.userLists.associate { it.id to it.name }
    val details = buildMap {
        for (id in learning.todayIds) {
            val detail = if (isUserWordId(id)) {
                viewModel.userWord(id)?.let { it.toDetail(it.listId?.let(listNames::get)) }
            } else {
                vocabulary.find(id)?.toDetail(source, target)
            }
            if (detail != null) put(id, detail)
        }
    }

    val scope = rememberCoroutineScope()
    val haptics = LocalHapticFeedback.current
    // The card taken back by "Undo" flies in from the side it left to: 1 right, -1 left.
    var enterFrom by remember { mutableIntStateOf(0) }
    val stackWidth = remember { floatArrayOf(1f) }
    val top = session.current
    val swipe = remember(top, session.round) { CardSwipe(scope, haptics, stackWidth[0], enterFrom) }
    LaunchedEffect(swipe) {
        enterFrom = 0
        swipe.enter()
    }
    // Answered cards fly off above the stack while the next card can already be swiped.
    val leaving = remember { mutableStateListOf<LeavingCard>() }
    var leavingCount by remember { mutableIntStateOf(0) }
    val answer = { knew: Boolean ->
        val card = session.current
        if (card != null) {
            leaving += LeavingCard(leavingCount++, card, swipe.x.value, swipe.y.value, swipe.flipped, knew)
            haptics.performHapticFeedback(if (knew) HapticFeedbackType.Confirm else HapticFeedbackType.Reject)
            learning.answer(knew)
        }
    }
    val undo = {
        if (session.canUndo) {
            // The last answer of the round is the one taken back.
            enterFrom = if (session.lastAnswerKnew() == true) 1 else -1
            learning.undo()
        }
    }

    val state = when {
        session.finished -> SessionState.FINISHED
        session.roundDone -> SessionState.ROUND_DONE
        else -> SessionState.CARDS
    }
    Column(Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding()) {
        TopBar(
            session = session,
            canUndo = state == SessionState.CARDS && session.canUndo,
            onClose = onClose,
            onUndo = undo,
        )
        AnimatedContent(
            targetState = state,
            modifier = Modifier.weight(1f).fillMaxWidth(),
            transitionSpec = { (fadeIn(tween(260)) + scaleIn(tween(260), initialScale = 0.92f)) togetherWith fadeOut(tween(140)) },
            label = "sessionState",
        ) { shown ->
            when (shown) {
                SessionState.CARDS -> Column(Modifier.fillMaxSize()) {
                    CardStack(
                        queue = session.queue,
                        details = details,
                        // The app's words can be bookmarked from their card; the learner's own are kept in My words.
                        bookmarkedOf = { id -> if (isUserWordId(id)) null else id in viewModel.bookmarkedIds },
                        onToggleBookmark = { id -> vocabulary.find(id)?.let(viewModel::toggleBookmark) },
                        swipe = swipe,
                        leaving = leaving,
                        onWidth = { stackWidth[0] = it },
                        onLeft = { leaving.remove(it) },
                        onAnswer = answer,
                        modifier = Modifier.weight(1f).fillMaxWidth().padding(start = 20.dp, end = 20.dp, top = 8.dp),
                    )
                    Text(
                        text = stringResource(Strings.learn_swipe_hint),
                        modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 12.dp),
                        color = appColors.textMuted,
                        style = MaterialTheme.typography.bodySmall,
                        textAlign = TextAlign.Center,
                    )
                    AnswerButtons(
                        onNotYet = { answer(false) },
                        onFlip = { swipe.flipped = !swipe.flipped },
                        onKnow = { answer(true) },
                    )
                }
                SessionState.ROUND_DONE -> RoundDonePanel(session, onNext = learning::nextRound)
                SessionState.FINISHED -> FinishedPanel(
                    session = session,
                    streak = learning.streak,
                    wordsPerDay = learning.wordsPerDay,
                    onDone = onClose,
                    onMore = learning::learnMore,
                )
            }
        }
    }
}

private enum class SessionState { CARDS, ROUND_DONE, FINISHED }

/** Close, the round and the count of known cards, undo; a bar of the known share below. */
@Composable
private fun TopBar(session: CardSession, canUndo: Boolean, onClose: () -> Unit, onUndo: () -> Unit) {
    val progress by animateFloatAsState(
        targetValue = if (session.total == 0) 0f else session.known.toFloat() / session.total,
        animationSpec = tween(350),
        label = "sessionProgress",
    )
    Column(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, top = 12.dp, bottom = 4.dp)) {
        // The buttons keep their sides in every language, like the header of Home.
        ProvideDirection(LayoutDirection.Ltr) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                CircleButton(Res.drawable.ic_x, stringResource(Strings.common_close), onClick = onClose)
                Column(Modifier.weight(1f), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = if (session.review) stringResource(Strings.learn_reviewing) else stringResource(Strings.learn_round, session.round.toString()),
                        color = appColors.textMuted,
                        style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.SemiBold),
                    )
                    Text(
                        text = "${session.known} / ${session.total}",
                        color = appColors.heading,
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.ExtraBold),
                    )
                }
                CircleButton(Res.drawable.ic_undo, stringResource(Strings.learn_undo), onClick = onUndo, enabled = canUndo)
            }
        }
        Spacer(Modifier.height(12.dp))
        Box(
            Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(CircleShape)
                .background(appColors.heading.copy(alpha = 0.08f)),
        ) {
            Box(Modifier.fillMaxWidth(progress).fillMaxHeight().clip(CircleShape).background(KnowColor))
        }
    }
}

/** The card on top with up to two more peeking out below it, and the answered cards flying off. */
@Composable
private fun CardStack(
    queue: List<String>,
    details: Map<String, WordDetail>,
    bookmarkedOf: (String) -> Boolean?,
    onToggleBookmark: (String) -> Unit,
    swipe: CardSwipe,
    leaving: List<LeavingCard>,
    onWidth: (Float) -> Unit,
    onLeft: (LeavingCard) -> Unit,
    onAnswer: (Boolean) -> Unit,
    modifier: Modifier = Modifier,
) {
    val visible = queue.take(3)
    BoxWithConstraints(modifier, contentAlignment = Alignment.Center) {
        val peek = 12.dp
        val width = constraints.maxWidth.toFloat()
        swipe.width = width
        onWidth(width)
        // Up by the strips peeking out below, so that the whole stack is centred.
        val cardModifier = Modifier
            .offset(y = -peek * (visible.size - 1) / 2)
            .width(minOf(maxWidth, 520.dp))
            .height(minOf(maxHeight - peek * 4, minOf(maxWidth, 520.dp) * 1.5f))
        for (index in visible.indices.reversed()) {
            val id = visible[index]
            key(id) {
                val isTop = index == 0
                // A card moving up the stack grows into place.
                val depth by animateFloatAsState(index.toFloat(), spring(stiffness = Spring.StiffnessMediumLow), label = "cardDepth")
                val placed = cardModifier.graphicsLayer {
                    val scale = 1f - 0.05f * depth
                    scaleX = scale
                    scaleY = scale
                    // Shrinking lifts the bottom edge by a share of the height; each card
                    // below moves down by that and by [peek], to show a strip of that height.
                    translationY = depth * (size.height * 0.025f + peek.toPx())
                    if (isTop) {
                        translationX = swipe.x.value
                        translationY += swipe.y.value * 0.3f
                        rotationZ = swipe.x.value / width * 12f
                    }
                }
                FlashCard(
                    detail = details[id],
                    flipped = isTop && swipe.flipped,
                    lean = if (isTop) swipe::lean else ({ 0f }),
                    onFlip = if (isTop) ({ swipe.flipped = !swipe.flipped }) else null,
                    bookmarked = if (isTop) bookmarkedOf(id) else null,
                    onToggleBookmark = { onToggleBookmark(id) },
                    modifier = if (isTop) placed.swipeToAnswer(swipe, onAnswer) else placed,
                )
            }
        }
        for (card in leaving) {
            key("leaving-${card.key}") {
                LeavingCardView(card, details[card.id], width, cardModifier, onGone = { onLeft(card) })
            }
        }
    }
}

/** A card just answered, on its way off the screen to the side of its answer. */
private class LeavingCard(
    val key: Int,
    val id: String,
    val fromX: Float,
    val fromY: Float,
    val flipped: Boolean,
    val knew: Boolean,
)

@Composable
private fun LeavingCardView(card: LeavingCard, detail: WordDetail?, width: Float, modifier: Modifier, onGone: () -> Unit) {
    val x = remember { Animatable(card.fromX) }
    val y = remember { Animatable(card.fromY) }
    LaunchedEffect(Unit) {
        launch { y.animateTo(card.fromY + width * 0.08f, tween(240)) }
        x.animateTo((if (card.knew) 1 else -1) * width * 1.5f, tween(240, easing = FastOutLinearInEasing))
        onGone()
    }
    val threshold = width * ANSWER_SHARE
    FlashCard(
        detail = detail,
        flipped = card.flipped,
        lean = { (x.value / threshold).coerceIn(-1f, 1f) },
        onFlip = null,
        modifier = modifier.graphicsLayer {
            translationX = x.value
            translationY = y.value * 0.3f
            rotationZ = x.value / width * 12f
        },
    )
}

private fun Modifier.swipeToAnswer(swipe: CardSwipe, onAnswer: (Boolean) -> Unit): Modifier = pointerInput(swipe) {
    detectDragGestures(
        onDragStart = { swipe.startDrag() },
        onDragEnd = { swipe.release(onAnswer) },
        onDragCancel = { swipe.settle() },
        onDrag = { change, amount ->
            change.consume()
            swipe.dragBy(amount, change.uptimeMillis)
        },
    )
}

/**
 * The drag and the flip of the card on top. A new one comes for every card, so a new card
 * always starts unturned in the middle, or off the screen on [enterSide] (1 right, -1 left)
 * when it is a card taken back.
 */
@Stable
private class CardSwipe(
    private val scope: CoroutineScope,
    private val haptics: HapticFeedback,
    var width: Float,
    enterSide: Int,
) {
    val x = Animatable(enterSide * width * 1.5f)
    val y = Animatable(0f)
    var flipped by mutableStateOf(false)

    private val tracker = VelocityTracker()
    private var dragX = 0f
    private var dragY = 0f
    private var pastThreshold = false

    private val threshold get() = width * ANSWER_SHARE

    /** How far the card leans to an answer: 1 at the point where letting go says "I know it", -1 for "Not yet". */
    fun lean(): Float = (x.value / threshold).coerceIn(-1f, 1f)

    fun startDrag() {
        tracker.resetTracking()
        dragX = x.value
        dragY = y.value
    }

    fun dragBy(amount: Offset, time: Long) {
        dragX += amount.x
        dragY += amount.y
        // The card moves with the finger, so the finger's own position on it barely changes; track the card.
        tracker.addPosition(time, Offset(dragX, dragY))
        // At once, not queued, so the card is exactly where the finger left it when the answer is read.
        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            x.snapTo(dragX)
            y.snapTo(dragY)
        }
        val past = abs(dragX) > threshold
        if (past != pastThreshold) {
            pastThreshold = past
            if (past) haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
        }
    }

    /** Answers the card when it was dragged far enough, or thrown; otherwise it springs back. */
    fun release(onAnswer: (Boolean) -> Unit) {
        val velocity = tracker.calculateVelocity().x
        val flung = abs(velocity) > 1800f && abs(dragX) > 24f && (velocity > 0) == (dragX > 0)
        if (abs(dragX) > threshold || flung) onAnswer(dragX > 0) else settle()
    }

    fun settle() {
        pastThreshold = false
        scope.launch {
            launch { y.animateTo(0f, spring(dampingRatio = 0.7f, stiffness = Spring.StiffnessMediumLow)) }
            x.animateTo(0f, spring(dampingRatio = 0.7f, stiffness = Spring.StiffnessMediumLow))
        }
    }

    /** Brings a card taken back in from off the screen. */
    suspend fun enter() {
        if (x.value != 0f) x.animateTo(0f, spring(dampingRatio = 0.75f, stiffness = Spring.StiffnessMediumLow))
    }
}

/**
 * One card: the word on the front, the meaning on the back. [lean] tints it and shows a
 * stamp while it is dragged toward an answer.
 */
@Composable
private fun FlashCard(
    detail: WordDetail?,
    flipped: Boolean,
    lean: () -> Float,
    onFlip: (() -> Unit)?,
    modifier: Modifier = Modifier,
    bookmarked: Boolean? = null,
    onToggleBookmark: () -> Unit = {},
) {
    val colors = appColors
    val rotation by animateFloatAsState(
        targetValue = if (flipped) 180f else 0f,
        animationSpec = tween(420, easing = FastOutSlowInEasing),
        label = "cardFlip",
    )
    val shape = RoundedCornerShape(CardRadius)
    val cardColor = if (colors.isDark) Color(0xFF26262C) else Color.White
    val flipLabel = stringResource(if (flipped) Strings.learn_tap_to_flip_back else Strings.learn_tap_to_flip)
    Box(modifier) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .graphicsLayer {
                    rotationY = rotation
                    cameraDistance = 14f * density
                }
                .softShadow(if (colors.isDark) emptyList() else SoftShadows.lessonCard, cornerRadius = CardRadius)
                .clip(shape)
                .background(cardColor)
                .then(if (colors.isDark) Modifier.border(1.dp, colors.tileBorder, shape) else Modifier)
                .drawWithContent {
                    drawContent()
                    val amount = lean()
                    if (amount != 0f) {
                        drawRoundRect(
                            color = if (amount > 0) KnowColor else AgainColor,
                            alpha = abs(amount) * 0.14f,
                            cornerRadius = CornerRadius(CardRadius.toPx()),
                        )
                    }
                }
                .then(
                    if (onFlip != null) {
                        Modifier.clickable(interactionSource = null, indication = null, role = Role.Button, onClickLabel = flipLabel, onClick = onFlip)
                    } else {
                        Modifier
                    },
                ),
        ) {
            if (detail != null) {
                if (rotation <= 90f) {
                    CardFace(detail, back = false)
                } else {
                    // The back is drawn turned, so that it reads the right way round once the card has turned.
                    Box(Modifier.fillMaxSize().graphicsLayer { rotationY = 180f }) { CardFace(detail, back = true) }
                }
            }
        }
        Stamp(
            text = stringResource(Strings.learn_stamp_know),
            color = KnowColor,
            tilt = -12f,
            visibility = { lean().coerceAtLeast(0f) },
            modifier = Modifier.align(Alignment.TopStart).padding(start = 22.dp, top = 52.dp),
        )
        Stamp(
            text = stringResource(Strings.learn_stamp_again),
            color = AgainColor,
            tilt = 12f,
            visibility = { (-lean()).coerceAtLeast(0f) },
            modifier = Modifier.align(Alignment.TopEnd).padding(end = 22.dp, top = 52.dp),
        )
        // Like the bookmark of the word card; it stays in its corner while the card turns.
        if (bookmarked != null) {
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = 8.dp, end = 8.dp)
                    .size(40.dp)
                    .clip(CircleShape)
                    .clickable(onClick = onToggleBookmark),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    painter = painterResource(if (bookmarked) Res.drawable.ic_bookmark else Res.drawable.ic_bookmark_plus),
                    contentDescription = stringResource(if (bookmarked) Strings.bookmark_remove else Strings.bookmark_add),
                    modifier = Modifier.size(22.dp),
                    tint = if (bookmarked) MaterialTheme.colorScheme.primary else Palette.Grey500,
                )
            }
        }
    }
}

@Composable
private fun CardFace(detail: WordDetail, back: Boolean) {
    val colors = appColors
    Column(Modifier.fillMaxSize().padding(horizontal = 24.dp, vertical = 22.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = detail.label,
            // Clear of the bookmark button in the corner.
            modifier = Modifier.fillMaxWidth().padding(horizontal = 28.dp),
            color = colors.textMuted,
            style = MaterialTheme.typography.labelMedium,
            textAlign = TextAlign.Center,
            maxLines = 1,
        )
        Column(
            Modifier.weight(1f).fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            val word = buildAnnotatedString {
                if (!detail.article.isNullOrBlank()) {
                    withStyle(SpanStyle(color = colors.textMuted, fontWeight = FontWeight.Medium)) { append("${detail.article} ") }
                }
                append(detail.word)
            }
            if (!back) {
                Text(
                    text = word,
                    modifier = Modifier.fillMaxWidth(),
                    color = colors.heading,
                    style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.ExtraBold, textDirection = TextDirection.Content),
                    textAlign = TextAlign.Center,
                    maxLines = lineLimit(word.text),
                    autoSize = TextAutoSize.StepBased(minFontSize = 16.sp, maxFontSize = 38.sp, stepSize = 1.sp),
                )
            } else {
                Text(
                    text = word,
                    modifier = Modifier.fillMaxWidth(),
                    color = colors.textMuted,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold, textDirection = TextDirection.Content),
                    textAlign = TextAlign.Center,
                    maxLines = 2,
                )
                Spacer(Modifier.height(10.dp))
                Box(Modifier.width(40.dp).height(3.dp).background(MaterialTheme.colorScheme.primary.copy(alpha = 0.35f), CircleShape))
                Spacer(Modifier.height(14.dp))
                Text(
                    text = detail.translation,
                    modifier = Modifier.fillMaxWidth(),
                    color = MaterialTheme.colorScheme.primary,
                    style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.ExtraBold, textDirection = TextDirection.Content),
                    textAlign = TextAlign.Center,
                    maxLines = lineLimit(detail.translation),
                    autoSize = TextAutoSize.StepBased(minFontSize = 16.sp, maxFontSize = 34.sp, stepSize = 1.sp),
                )
                if (!detail.plural.isNullOrBlank()) {
                    Spacer(Modifier.height(10.dp))
                    Text(
                        text = "Pl. ${detail.plural}",
                        color = colors.textMuted,
                        style = MaterialTheme.typography.bodyMedium.copy(textDirection = TextDirection.Content),
                        textAlign = TextAlign.Center,
                    )
                }
                if (!detail.example.isNullOrBlank()) {
                    Spacer(Modifier.height(16.dp))
                    Text(
                        text = detail.example,
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(colors.heading.copy(alpha = 0.05f), RoundedCornerShape(14.dp))
                            .padding(horizontal = 14.dp, vertical = 10.dp),
                        color = colors.text,
                        style = MaterialTheme.typography.bodyMedium.copy(textDirection = TextDirection.Content),
                        textAlign = TextAlign.Center,
                        maxLines = 4,
                    )
                }
            }
        }
        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.clearAndSetSemantics {}) {
            Icon(painterResource(Res.drawable.ic_rotate), contentDescription = null, modifier = Modifier.size(14.dp), tint = colors.textMuted)
            Spacer(Modifier.width(6.dp))
            Text(
                text = stringResource(if (back) Strings.learn_tap_to_flip_back else Strings.learn_tap_to_flip),
                color = colors.textMuted,
                style = MaterialTheme.typography.bodySmall,
            )
        }
    }
}

/**
 * At most one line per word, and four in all. A long word such as "Haushaltskonsolidierung"
 * then has to fit on its line, so the text gets smaller instead of breaking inside the word.
 */
private fun lineLimit(text: String): Int = text.trim().split(Regex("\\s+")).size.coerceIn(1, 4)

/** "KNOW IT" or "AGAIN", stamped on the card as it is dragged that way. */
@Composable
private fun Stamp(text: String, color: Color, tilt: Float, visibility: () -> Float, modifier: Modifier = Modifier) {
    Text(
        text = text,
        modifier = modifier
            .graphicsLayer {
                alpha = visibility()
                rotationZ = tilt
            }
            .border(3.dp, color, RoundedCornerShape(10.dp))
            .padding(horizontal = 12.dp, vertical = 4.dp),
        color = color,
        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Black, letterSpacing = 1.5.sp),
    )
}

@Composable
private fun AnswerButtons(onNotYet: () -> Unit, onFlip: () -> Unit, onKnow: () -> Unit) {
    // "Not yet" stays on the left and "I know it" on the right, as the swipes go.
    ProvideDirection(LayoutDirection.Ltr) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(start = 24.dp, end = 24.dp, bottom = 20.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.Top,
        ) {
            AnswerButton(Res.drawable.ic_x, stringResource(Strings.learn_not_yet), AgainColor, 64.dp, onNotYet)
            AnswerButton(Res.drawable.ic_rotate, stringResource(Strings.learn_flip), MaterialTheme.colorScheme.primary, 52.dp, onFlip)
            AnswerButton(Res.drawable.ic_check, stringResource(Strings.learn_know), KnowColor, 64.dp, onKnow)
        }
    }
}

@Composable
private fun AnswerButton(icon: DrawableResource, label: String, color: Color, size: Dp, onClick: () -> Unit) {
    val colors = appColors
    Column(Modifier.width(92.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .padding(top = (64.dp - size) / 2)
                .size(size)
                .softShadow(if (colors.isDark) emptyList() else SoftShadows.listCard)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.surface)
                .border(2.dp, color.copy(alpha = 0.4f), CircleShape)
                .clickable(role = Role.Button, onClick = onClick)
                .semantics { contentDescription = label },
            contentAlignment = Alignment.Center,
        ) {
            Icon(painterResource(icon), contentDescription = null, modifier = Modifier.size(size * 0.42f), tint = color)
        }
        Spacer(Modifier.height(6.dp + (64.dp - size) / 2))
        Text(
            text = label,
            modifier = Modifier.clearAndSetSemantics {},
            color = colors.textMuted,
            style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.SemiBold),
            textAlign = TextAlign.Center,
            maxLines = 1,
        )
    }
}

/** Between rounds: how the round went, and the button that brings the others back. */
@Composable
private fun RoundDonePanel(session: CardSession, onNext: () -> Unit) {
    val again = session.again.size
    PanelColumn {
        Box(
            Modifier.size(96.dp).background(AgainColor.copy(alpha = if (appColors.isDark) 0.22f else 0.14f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(painterResource(Res.drawable.ic_repeat), contentDescription = null, modifier = Modifier.size(42.dp), tint = AgainColor)
        }
        Spacer(Modifier.height(22.dp))
        Text(
            text = stringResource(Strings.learn_round_done, session.round.toString()),
            color = appColors.heading,
            style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.ExtraBold),
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(10.dp))
        Text(
            text = stringResource(Strings.learn_round_done_text, (session.roundSize - again).toString(), session.roundSize.toString()),
            color = appColors.textMuted,
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(28.dp))
        PillButton(
            text = if (again == 1) stringResource(Strings.learn_repeat_one) else stringResource(Strings.learn_repeat_many, again.toString()),
            icon = Res.drawable.ic_repeat,
            background = appColors.headerButton,
            contentColor = appColors.onHeaderButton,
            onClick = onNext,
            modifier = Modifier.fillMaxWidth().height(52.dp),
        )
    }
}

/** Every card known: the check, the streak, and the ways on. */
@Composable
private fun FinishedPanel(session: CardSession, streak: Int, wordsPerDay: Int, onDone: () -> Unit, onMore: () -> Unit) {
    var shown by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { shown = true }
    val pop by animateFloatAsState(
        targetValue = if (shown) 1f else 0.4f,
        animationSpec = spring(dampingRatio = 0.45f, stiffness = Spring.StiffnessLow),
        label = "finishedPop",
    )
    PanelColumn {
        Box(
            Modifier
                .size(112.dp)
                .graphicsLayer {
                    scaleX = pop
                    scaleY = pop
                }
                .background(KnowColor.copy(alpha = if (appColors.isDark) 0.22f else 0.14f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Box(Modifier.size(76.dp).background(KnowColor, CircleShape), contentAlignment = Alignment.Center) {
                Icon(painterResource(Res.drawable.ic_check), contentDescription = null, modifier = Modifier.size(40.dp), tint = Color.White)
            }
        }
        Spacer(Modifier.height(24.dp))
        Text(
            text = stringResource(if (session.review) Strings.learn_review_finished else Strings.learn_finished),
            color = appColors.heading,
            style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.ExtraBold),
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(10.dp))
        Text(
            text = stringResource(
                if (session.review) Strings.learn_review_finished_text else Strings.learn_finished_text,
                session.total.toString(),
            ),
            color = appColors.textMuted,
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center,
        )
        if (streak > 0 && !session.review) {
            Spacer(Modifier.height(16.dp))
            Row(
                modifier = Modifier
                    .clip(CircleShape)
                    .background(AgainColor.copy(alpha = if (appColors.isDark) 0.22f else 0.13f))
                    .padding(horizontal = 14.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(painterResource(Res.drawable.ic_flame), contentDescription = null, modifier = Modifier.size(18.dp), tint = AgainColor)
                Spacer(Modifier.width(6.dp))
                Text(
                    text = if (streak == 1) stringResource(Strings.learn_streak_day) else stringResource(Strings.learn_streak_days, streak.toString()),
                    color = AgainColor,
                    style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.ExtraBold),
                )
            }
        }
        Spacer(Modifier.height(30.dp))
        PillButton(
            text = stringResource(Strings.learn_done),
            icon = Res.drawable.ic_check,
            background = appColors.headerButton,
            contentColor = appColors.onHeaderButton,
            onClick = onDone,
            modifier = Modifier.fillMaxWidth().height(52.dp),
        )
        if (!session.review) {
            Spacer(Modifier.height(10.dp))
            PillButton(
                text = stringResource(Strings.learn_more, wordsPerDay.toString()),
                icon = Res.drawable.ic_plus,
                background = appColors.tile,
                contentColor = appColors.heading,
                onClick = onMore,
                modifier = Modifier.fillMaxWidth().height(52.dp).border(1.dp, appColors.tileBorder, CircleShape),
            )
        }
    }
}

@Composable
private fun PanelColumn(content: @Composable () -> Unit) {
    Box(Modifier.fillMaxSize().padding(horizontal = 32.dp), contentAlignment = Alignment.Center) {
        Column(Modifier.widthIn(max = 420.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            content()
        }
    }
}
