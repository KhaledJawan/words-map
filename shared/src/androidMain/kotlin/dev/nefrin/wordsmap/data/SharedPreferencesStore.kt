package dev.nefrin.wordsmap.data

import android.content.Context
import androidx.core.content.edit

/** The Android [KeyValueStore]: the same SharedPreferences file the app has always used. */
class SharedPreferencesStore(context: Context) : KeyValueStore {
    private val prefs = context.getSharedPreferences(AppPreferences.FILE, Context.MODE_PRIVATE)

    override fun getString(key: String): String? = prefs.getString(key, null)

    override fun putString(key: String, value: String?) = prefs.edit { putString(key, value) }

    override fun getBoolean(key: String, default: Boolean): Boolean = prefs.getBoolean(key, default)

    override fun putBoolean(key: String, value: Boolean) = prefs.edit { putBoolean(key, value) }

    override fun getStringSet(key: String): Set<String>? = prefs.getStringSet(key, null)

    override fun putStringSet(key: String, value: Set<String>) = prefs.edit { putStringSet(key, value) }
}
