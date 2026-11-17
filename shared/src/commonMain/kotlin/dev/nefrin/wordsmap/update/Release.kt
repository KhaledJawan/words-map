package dev.nefrin.wordsmap.update

import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.longOrNull

/** The platforms the WordsMap server publishes releases for, by their key in its answer. */
enum class UpdatePlatform(val key: String) { ANDROID("android"), IOS("ios") }

/**
 * The app on this phone: its version name ("2.2.0") and its build number, which is the
 * Android versionCode or the iOS CFBundleVersion. The build number decides; the name is shown.
 */
data class InstalledVersion(val name: String, val build: Long)

/** A release of one platform, as the WordsMap server publishes it. */
data class PublishedRelease(
    val latestVersion: String,
    val latestBuild: Long,
    /** Builds below this one have to update; 0 when none has to. */
    val minimumSupportedBuild: Long,
    /** The notes by language code: "en", "de", "fa", "ps". */
    val releaseNotes: Map<String, String>,
    /** The store page; always an address of the official store of the platform. */
    val storeUrl: String,
) {
    /** The notes in [language], else in English, else in any language there are notes in. */
    fun notesIn(language: String): String? =
        releaseNotes[language] ?: releaseNotes["en"] ?: releaseNotes.values.firstOrNull()
}

/** What a published release means for the installed app. */
enum class UpdateNeed { NONE, OPTIONAL, REQUIRED }

/**
 * Decides by build numbers, never by comparing version names as text. An update is required
 * only when there is a newer build to update to.
 */
fun updateNeed(installed: InstalledVersion, release: PublishedRelease): UpdateNeed = when {
    release.latestBuild <= installed.build -> UpdateNeed.NONE
    installed.build < release.minimumSupportedBuild -> UpdateNeed.REQUIRED
    else -> UpdateNeed.OPTIONAL
}

/**
 * Compares version names part by part as numbers, so "2.10.0" is newer than "2.9.1" and
 * "2.2" is the same as "2.2.0". Null when either is not a version name.
 */
fun compareVersions(a: String, b: String): Int? {
    val left = versionParts(a) ?: return null
    val right = versionParts(b) ?: return null
    for (index in 0 until maxOf(left.size, right.size)) {
        val difference = left.getOrElse(index) { 0L }.compareTo(right.getOrElse(index) { 0L })
        if (difference != 0) return difference
    }
    return 0
}

private val VersionPattern = Regex("""\d{1,9}(\.\d{1,9}){0,3}""")

/** "2.2.0" as [2, 2, 0]. A leading "v" and a suffix such as "-beta" or " (27)" are left out. */
internal fun versionParts(version: String): List<Long>? {
    val core = version.trim().removePrefix("v").takeWhile { it.isDigit() || it == '.' }
    if (!VersionPattern.matches(core)) return null
    return core.split('.').map { it.toLong() }
}

/** The official store pages of WordsMap, used when the server names no valid one. */
object StorePages {
    const val PLAY = "https://play.google.com/store/apps/details?id=com.merlinict.wordmap"
    const val APP_STORE = "https://apps.apple.com/app/id6823419767"

    fun of(platform: UpdatePlatform): String = when (platform) {
        UpdatePlatform.ANDROID -> PLAY
        UpdatePlatform.IOS -> APP_STORE
    }

    private val Address = Regex("""https://([a-z0-9.-]+)(/[^\s]*)?""")

    /** Whether [url] is an https address of the store of [platform]; no other address is ever opened. */
    fun isOfficial(url: String, platform: UpdatePlatform): Boolean {
        val host = Address.matchEntire(url.trim())?.groupValues?.get(1) ?: return false
        return when (platform) {
            UpdatePlatform.ANDROID -> host == "play.google.com"
            UpdatePlatform.IOS -> host == "apps.apple.com" || host == "itunes.apple.com"
        }
    }
}

/** The server's answer did not fit; nothing of it is used. */
class InvalidReleaseConfig(message: String) : Exception(message)

/**
 * Reads the answer of `GET /api/app-updates`. What does not fit is refused rather than
 * guessed, and nothing in it can lock users out: a minimum build above the newest build
 * counts as no minimum, and a store address that is not the official store is replaced by it.
 */
object ReleaseConfig {
    const val MAX_NOTE_LENGTH = 2_000
    private const val MAX_NOTES = 20
    private val LanguageCode = Regex("[a-z]{2,3}")

    fun parse(text: String, platform: UpdatePlatform): PublishedRelease {
        val root = try {
            Json.parseToJsonElement(text)
        } catch (error: SerializationException) {
            throw InvalidReleaseConfig("Not JSON: ${error.message}")
        } catch (error: IllegalArgumentException) {
            throw InvalidReleaseConfig("Not JSON: ${error.message}")
        } as? JsonObject ?: throw InvalidReleaseConfig("Not a JSON object")
        val entry = root[platform.key] as? JsonObject ?: throw InvalidReleaseConfig("No ${platform.key} release")

        val latestVersion = entry.string("latestVersion")?.trim()?.takeIf { versionParts(it) != null }
            ?: throw InvalidReleaseConfig("latestVersion is missing or not a version")
        val latestBuild = entry.whole("latestBuild")?.takeIf { it > 0 }
            ?: throw InvalidReleaseConfig("latestBuild is missing or not a positive whole number")
        val minimum = entry.whole("minimumSupportedBuild")?.takeIf { it >= 0 } ?: 0L
        val notes = (entry["releaseNotes"] as? JsonObject).orEmpty().entries
            .mapNotNull { (language, value) ->
                val note = (value as? JsonPrimitive)?.takeIf { it.isString }?.content?.trim()
                if (note.isNullOrEmpty() || !LanguageCode.matches(language)) null else language to note.take(MAX_NOTE_LENGTH)
            }
            .take(MAX_NOTES)
            .toMap()
        val storeUrl = entry.string("storeUrl")?.trim()?.takeIf { StorePages.isOfficial(it, platform) } ?: StorePages.of(platform)
        return PublishedRelease(
            latestVersion = latestVersion,
            latestBuild = latestBuild,
            minimumSupportedBuild = if (minimum > latestBuild) 0L else minimum,
            releaseNotes = notes,
            storeUrl = storeUrl,
        )
    }

    private fun JsonObject.string(key: String): String? = (this[key] as? JsonPrimitive)?.takeIf { it.isString }?.content

    /** A whole number written as a number; "27" in quotes or 27.5 do not count. */
    private fun JsonObject.whole(key: String): Long? =
        (this[key] as? JsonPrimitive)?.takeIf { !it.isString && '.' !in it.content && 'e' !in it.content.lowercase() }?.longOrNull
}
