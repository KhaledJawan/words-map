package dev.nefrin.wordsmap.platform

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.net.URL
import java.text.DateFormat
import java.util.Date
import java.util.Locale
import javax.net.ssl.HttpsURLConnection

actual suspend fun httpGet(url: String, timeoutMillis: Long, maxBytes: Int): String = withContext(Dispatchers.IO) {
    val connection = URL(url).openConnection() as? HttpsURLConnection ?: throw HttpException("Not an https address: $url")
    try {
        connection.connectTimeout = timeoutMillis.toInt()
        connection.readTimeout = timeoutMillis.toInt()
        connection.useCaches = false
        connection.setRequestProperty("Accept", "application/json")
        val code = connection.responseCode
        if (code != HttpsURLConnection.HTTP_OK) throw HttpException("HTTP $code from $url")
        connection.inputStream.use { input ->
            val body = ByteArrayOutputStream()
            val buffer = ByteArray(8 * 1024)
            while (true) {
                val read = input.read(buffer)
                if (read < 0) break
                body.write(buffer, 0, read)
                if (body.size() > maxBytes) throw HttpException("The answer of $url is too large")
            }
            body.toByteArray().decodeToString()
        }
    } finally {
        connection.disconnect()
    }
}

actual fun formatDateTime(epochMillis: Long, languageCode: String): String =
    DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT, Locale.forLanguageTag(languageCode)).format(Date(epochMillis))
