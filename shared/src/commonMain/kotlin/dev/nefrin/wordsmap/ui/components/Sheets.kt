package dev.nefrin.wordsmap.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.ui.theme.appColors
import kotlinx.coroutines.launch

/** Lets the content of an [AppBottomSheet] close it. */
fun interface SheetScope {
    /** Slides the sheet away, then runs [then]. */
    fun close(then: () -> Unit)
}

fun SheetScope.close() = close {}

/**
 * The app's modal bottom sheet: surface colored, flat, sized to its content.
 *
 * @param onDismiss called once the sheet is gone, however it was closed
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppBottomSheet(
    onDismiss: () -> Unit,
    showHandle: Boolean = true,
    topRadius: Dp = 28.dp,
    content: @Composable ColumnScope.(SheetScope) -> Unit,
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val coroutineScope = rememberCoroutineScope()
    val sheetScope = SheetScope { then ->
        coroutineScope.launch { sheetState.hide() }.invokeOnCompletion {
            if (!sheetState.isVisible) {
                onDismiss()
                then()
            }
        }
    }
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        shape = RoundedCornerShape(topStart = topRadius, topEnd = topRadius),
        containerColor = MaterialTheme.colorScheme.surface,
        contentColor = appColors.text,
        tonalElevation = 0.dp,
        scrimColor = Color.Black.copy(alpha = 0.54f),
        dragHandle = if (showHandle) {
            { SheetHandle() }
        } else {
            null
        },
    ) {
        content(sheetScope)
    }
}

@Composable
private fun SheetHandle() {
    Box(
        Modifier
            .padding(vertical = 22.dp)
            .size(width = 32.dp, height = 4.dp)
            .background(MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f), CircleShape),
    )
}
