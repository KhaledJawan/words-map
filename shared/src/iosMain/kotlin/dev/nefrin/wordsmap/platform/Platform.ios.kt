package dev.nefrin.wordsmap.platform

import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.skiaPaint
import androidx.compose.ui.graphics.toComposeImageBitmap
import androidx.compose.ui.window.DialogProperties
import androidx.navigationevent.NavigationEventInfo
import androidx.navigationevent.compose.NavigationBackHandler
import androidx.navigationevent.compose.rememberNavigationEventState
import kotlinx.cinterop.BetaInteropApi
import org.jetbrains.skia.FilterBlurMode
import org.jetbrains.skia.Image
import org.jetbrains.skia.MaskFilter
import org.jetbrains.skia.Rect
import org.jetbrains.skia.Surface
import platform.Foundation.NSDate
import platform.Foundation.NSString
import platform.Foundation.NSTimeZone
import platform.Foundation.localTimeZone
import platform.Foundation.timeIntervalSince1970
import platform.Foundation.create
import platform.Foundation.decomposedStringWithCanonicalMapping
import kotlin.math.roundToInt

internal actual fun writeLog(isError: Boolean, tag: String, message: String, error: Throwable?) {
    println("${if (isError) "E" else "W"}/$tag: $message")
    error?.let { println(it.stackTraceToString()) }
}

actual fun currentTimeMillis(): Long = (NSDate().timeIntervalSince1970 * 1000).toLong()

actual fun localEpochDay(): Long {
    val now = NSDate()
    val localSeconds = now.timeIntervalSince1970.toLong() + NSTimeZone.localTimeZone.secondsFromGMTForDate(now)
    return localSeconds.floorDiv(86_400L)
}

@OptIn(BetaInteropApi::class)
actual fun decomposeAccents(text: String): String = NSString.create(string = text).decomposedStringWithCanonicalMapping

actual fun decodeImage(bytes: ByteArray, maxSide: Int): ImageBitmap? = try {
    val image = Image.makeFromEncoded(bytes)
    val scale = maxSide.toFloat() / maxOf(image.width, image.height)
    if (scale >= 1f) {
        image.toComposeImageBitmap()
    } else {
        val width = (image.width * scale).roundToInt().coerceAtLeast(1)
        val height = (image.height * scale).roundToInt().coerceAtLeast(1)
        val surface = Surface.makeRasterN32Premul(width, height)
        surface.canvas.drawImageRect(image, Rect.makeWH(width.toFloat(), height.toFloat()))
        surface.makeImageSnapshot().toComposeImageBitmap()
    }
} catch (error: Exception) {
    Log.w("decodeImage", "Could not decode an image", error)
    null
}

actual fun blurredPaint(color: Color, radius: Float): Paint = Paint().apply {
    this.color = color
    // Android's BlurMaskFilter takes a radius and Skia a sigma; this is Android's conversion,
    // so the shadows look the same on both.
    skiaPaint.maskFilter = MaskFilter.makeBlur(FilterBlurMode.NORMAL, radius * 0.57735f + 0.5f)
}

@Composable
actual fun SystemBars(darkTheme: Boolean, lightStatusBarIcons: Boolean) {
    SideEffect { StatusBar.lightIcons = lightStatusBarIcons }
}

@Composable
actual fun BackHandler(enabled: Boolean, onBack: () -> Unit) {
    NavigationBackHandler(
        state = rememberNavigationEventState(NavigationEventInfo.None),
        isBackEnabled = enabled,
        onBackCompleted = onBack,
    )
}

actual fun fullScreenDialogProperties(): DialogProperties =
    DialogProperties(usePlatformDefaultWidth = false, usePlatformInsets = false, scrimColor = Color.Transparent)

@Composable
actual fun PlainDialogWindow() = Unit
