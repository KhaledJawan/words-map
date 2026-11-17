package dev.nefrin.wordsmap.ui.grammar

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import dev.nefrin.wordsmap.data.GrammarLesson
import dev.nefrin.wordsmap.platform.Log
import dev.nefrin.wordsmap.platform.decodeImage
import dev.nefrin.wordsmap.resources.AppAssets
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.ic_image
import dev.nefrin.wordsmap.ui.theme.Palette
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.withContext
import org.jetbrains.compose.resources.painterResource

/**
 * The cover photo of [lesson], cropped to fill. Lessons without a photo get a plain
 * indigo panel with an image icon, so a missing file never leaves a hole.
 */
@Composable
internal fun GrammarCover(lesson: GrammarLesson, modifier: Modifier = Modifier, iconSize: Dp = 40.dp) {
    val path = lesson.cover
    val image by produceState(initialValue = path?.let(CoverImages::cached), path) {
        if (path != null && value == null) value = CoverImages.load(path)
    }
    Box(
        modifier = modifier.background(
            Brush.linearGradient(listOf(Palette.GrammarIndigo, Palette.GrammarIndigo.copy(alpha = 0.7f))),
        ),
        contentAlignment = Alignment.Center,
    ) {
        val bitmap = image
        if (bitmap != null) {
            Image(bitmap, contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
        } else if (path == null) {
            Icon(
                painter = painterResource(Res.drawable.ic_image),
                contentDescription = null,
                modifier = Modifier.size(iconSize),
                tint = Color.White.copy(alpha = 0.7f),
            )
        }
    }
}

private object CoverImages {
    private const val TAG = "CoverImages"
    private const val MAX_SIDE = 1600

    // A decoded cover is about 4 MB.
    private const val MAX_CACHED = 8

    // Least recently used first. Only touched on the main thread.
    private val cache = LinkedHashMap<String, ImageBitmap>()

    fun cached(path: String): ImageBitmap? = cache.remove(path)?.also { cache[path] = it }

    /** Decodes the file at [path] off the main thread, scaled down so that a large photo cannot exhaust memory. */
    suspend fun load(path: String): ImageBitmap? {
        val image = try {
            withContext(Dispatchers.IO) { decodeImage(AppAssets.readBytes(path), MAX_SIDE) }
        } catch (error: CancellationException) {
            throw error
        } catch (error: Exception) {
            Log.w(TAG, "Could not read cover $path", error)
            null
        }
        if (image != null) {
            cache[path] = image
            while (cache.size > MAX_CACHED) cache.remove(cache.keys.first())
        }
        return image
    }
}
