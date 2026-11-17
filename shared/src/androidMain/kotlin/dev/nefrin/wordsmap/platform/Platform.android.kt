package dev.nefrin.wordsmap.platform

import android.graphics.BitmapFactory
import android.graphics.BlurMaskFilter
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.LocalActivity
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.nativePaint
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.window.DialogProperties
import androidx.compose.ui.window.DialogWindowProvider
import androidx.core.view.WindowCompat
import java.text.Normalizer

internal actual fun writeLog(isError: Boolean, tag: String, message: String, error: Throwable?) {
    if (isError) android.util.Log.e(tag, message, error) else android.util.Log.w(tag, message, error)
}

actual fun currentTimeMillis(): Long = System.currentTimeMillis()

actual fun localEpochDay(): Long {
    val now = System.currentTimeMillis()
    return (now + java.util.TimeZone.getDefault().getOffset(now)).floorDiv(86_400_000L)
}

actual fun decomposeAccents(text: String): String = Normalizer.normalize(text, Normalizer.Form.NFD)

actual fun decodeImage(bytes: ByteArray, maxSide: Int): ImageBitmap? {
    val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
    BitmapFactory.decodeByteArray(bytes, 0, bytes.size, bounds)
    var sampleSize = 1
    while (maxOf(bounds.outWidth, bounds.outHeight) / sampleSize > maxSide) sampleSize *= 2
    val options = BitmapFactory.Options().apply { inSampleSize = sampleSize }
    return BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options)?.asImageBitmap()
}

actual fun blurredPaint(color: Color, radius: Float): Paint = Paint().apply {
    this.color = color
    nativePaint.maskFilter = BlurMaskFilter(radius, BlurMaskFilter.Blur.NORMAL)
}

@Composable
actual fun SystemBars(darkTheme: Boolean, lightStatusBarIcons: Boolean) {
    val activity = LocalActivity.current as? ComponentActivity ?: return
    val view = LocalView.current
    DisposableEffect(activity, darkTheme) {
        val transparent = Color.Transparent.toArgb()
        activity.enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.auto(transparent, transparent) { darkTheme },
            navigationBarStyle = SystemBarStyle.auto(transparent, transparent) { darkTheme },
        )
        onDispose {}
    }
    SideEffect {
        WindowCompat.getInsetsController(activity.window, view).isAppearanceLightStatusBars = !lightStatusBarIcons
    }
}

@Composable
actual fun BackHandler(enabled: Boolean, onBack: () -> Unit) {
    androidx.activity.compose.BackHandler(enabled, onBack)
}

actual fun fullScreenDialogProperties(): DialogProperties =
    DialogProperties(usePlatformDefaultWidth = false, decorFitsSystemWindows = false)

@Composable
actual fun PlainDialogWindow() {
    // The dialog only carries the card above bottom sheets; the dimming is drawn by the card.
    val window = (LocalView.current.parent as? DialogWindowProvider)?.window
    SideEffect {
        window?.setDimAmount(0f)
        window?.setWindowAnimations(0)
    }
}
