package dev.nefrin.wordsmap.data

enum class AppLanguage(val code: String, val nativeName: String, val isRtl: Boolean) {
    DE("de", "Deutsch", false),
    EN("en", "English", false),
    FA("fa", "فارسی", true),
    PS("ps", "پښتو", true),
    TR("tr", "Türkçe", false),
    FR("fr", "Français", false);

    companion object {
        /** Languages the interface is translated into. */
        val interfaceLanguages = listOf(EN, FA, PS)

        /** Order of the word-pair pickers, and the order word texts fall back in. */
        val wordLanguages = listOf(DE, EN, FR, TR, FA, PS)

        fun fromCode(code: String?): AppLanguage? = entries.firstOrNull { it.code == code }
    }
}

/** The language shown on word chips and the language their meaning is given in. */
data class WordPair(val source: AppLanguage, val target: AppLanguage)
