package dev.nefrin.wordsmap.resources

import org.jetbrains.compose.resources.ExperimentalResourceApi

/**
 * The content files under `composeResources/files`: words, lessons and reading texts.
 * Paths are relative to that folder, such as `words/a1_1.json`.
 */
object AppAssets {

    /** Names of the files and folders directly inside [folder]. */
    fun list(folder: String): List<String> {
        val prefix = "${folder.trimEnd('/')}/"
        return assetPaths.asSequence()
            .filter { it.startsWith(prefix) }
            .map { it.removePrefix(prefix).substringBefore('/') }
            .distinct()
            .toList()
    }

    @OptIn(ExperimentalResourceApi::class)
    suspend fun readBytes(path: String): ByteArray = Res.readBytes("files/$path")

    suspend fun readText(path: String): String = readBytes(path).decodeToString()
}
