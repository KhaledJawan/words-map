package dev.nefrin.wordsmap.data

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject

// Forgiving readers for the content files: a missing or mistyped value gives an empty
// default instead of an error, so one odd field never hides a whole lesson.

internal fun parseJsonObject(text: String): JsonObject = Json.parseToJsonElement(text).jsonObject

internal fun parseJsonArray(text: String): JsonArray = Json.parseToJsonElement(text).jsonArray

/** Text of a string, number or boolean; null for anything else. */
internal val JsonElement?.text: String?
    get() = (this as? JsonPrimitive)?.takeUnless { it is JsonNull }?.content

/** The value at [key] as text, or "" when there is none. */
internal fun JsonObject.string(key: String): String = this[key].text.orEmpty()

/** The number at [key], or [default] when there is none. */
internal fun JsonObject.int(key: String, default: Int = 0): Int =
    (this[key] as? JsonPrimitive)?.takeUnless { it is JsonNull }?.let { it.intOrNull ?: it.doubleOrNull?.toInt() } ?: default

internal fun JsonObject.array(key: String): JsonArray? = this[key] as? JsonArray

internal fun JsonObject.obj(key: String): JsonObject? = this[key] as? JsonObject

/** The objects of the array; anything else in it is skipped. */
internal fun JsonArray?.objects(): List<JsonObject> = this?.filterIsInstance<JsonObject>().orEmpty()

/** The non-blank strings of the array. */
internal fun JsonArray?.strings(): List<String> = this?.mapNotNull { it.text }?.filter { it.isNotBlank() }.orEmpty()
