package dev.nefrin.wordsmap.platform

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.window.DialogProperties

// The few things Android and iOS do differently. Everything else is shared code.

/** Writes to the platform log: Logcat on Android, the Xcode console on iOS. */
object Log {
    fun e(tag: String, message: String, error: Throwable? = null) = writeLog(isError = true, tag, message, error)

    fun w(tag: String, message: String, error: Throwable? = null) = writeLog(isError = false, tag, message, error)
}

internal expect fun writeLog(isError: Boolean, tag: String, message: String, error: Throwable?)

/** Milliseconds since 1 January 1970, UTC. */
expect fun currentTimeMillis(): Long

/**
 * Today as the number of days since 1 January 1970 in the phone's time zone, so it changes
 * at local midnight. The daily words and their streak count in these days.
 */
expect fun localEpochDay(): Long

/** [text] in Unicode normal form D: an accented letter becomes the plain letter followed by its marks. */
expect fun decomposeAccents(text: String): String

/** Decodes a photo, scaled down so that a large one cannot exhaust memory; null when it cannot be read. */
expect fun decodeImage(bytes: ByteArray, maxSide: Int): ImageBitmap?

/** A paint that draws [color] blurred by [radius] pixels, for soft shadows. */
expect fun blurredPaint(color: Color, radius: Float): Paint

/** Keeps the system bars transparent, with icons that stay readable on what is behind them. */
@Composable
expect fun SystemBars(darkTheme: Boolean, lightStatusBarIcons: Boolean)

/** Runs [onBack] on the system back action: the back button or gesture on Android, the edge swipe on iOS. */
@Composable
expect fun BackHandler(enabled: Boolean = true, onBack: () -> Unit)

/** A dialog that covers the whole screen and draws its own dimming. */
expect fun fullScreenDialogProperties(): DialogProperties

/** Called inside such a dialog: takes away what the platform adds around it, such as Android's window dim. */
@Composable
expect fun PlainDialogWindow()

/**
 * Reads [url] with a GET request: https only, at most [timeoutMillis] to connect and as long
 * again to read, and an answer of at most [maxBytes]. Throws [HttpException] when the answer
 * is not 200 OK, and an I/O error when the server cannot be reached.
 */
expect suspend fun httpGet(url: String, timeoutMillis: Long, maxBytes: Int): String

class HttpException(message: String) : Exception(message)

/** A date with its time, in the way of [languageCode]: "16 Nov 2026, 07:10". */
expect fun formatDateTime(epochMillis: Long, languageCode: String): String
