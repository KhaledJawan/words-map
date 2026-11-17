package dev.nefrin.wordsmap.data

import platform.Foundation.NSUserDefaults

/** The iOS [KeyValueStore]. A string set is kept as an array of strings. */
class UserDefaultsStore(private val defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults) : KeyValueStore {

    override fun getString(key: String): String? = defaults.stringForKey(key)

    override fun putString(key: String, value: String?) {
        if (value == null) defaults.removeObjectForKey(key) else defaults.setObject(value, key)
    }

    override fun getBoolean(key: String, default: Boolean): Boolean =
        if (defaults.objectForKey(key) == null) default else defaults.boolForKey(key)

    override fun putBoolean(key: String, value: Boolean) = defaults.setBool(value, key)

    override fun getStringSet(key: String): Set<String>? =
        defaults.arrayForKey(key)?.filterIsInstance<String>()?.toSet()

    override fun putStringSet(key: String, value: Set<String>) = defaults.setObject(value.toList(), key)
}
