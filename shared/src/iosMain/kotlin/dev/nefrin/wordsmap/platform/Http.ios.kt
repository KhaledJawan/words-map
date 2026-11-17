package dev.nefrin.wordsmap.platform

import kotlinx.cinterop.BetaInteropApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.Foundation.NSDate
import platform.Foundation.NSDateFormatter
import platform.Foundation.NSDateFormatterMediumStyle
import platform.Foundation.NSDateFormatterShortStyle
import platform.Foundation.NSHTTPURLResponse
import platform.Foundation.NSLocale
import platform.Foundation.NSMutableURLRequest
import platform.Foundation.NSString
import platform.Foundation.NSURL
import platform.Foundation.NSURLRequestReloadIgnoringLocalCacheData
import platform.Foundation.NSURLSession
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.create
import platform.Foundation.dataTaskWithRequest
import platform.Foundation.dateWithTimeIntervalSince1970
import platform.Foundation.setHTTPMethod
import platform.Foundation.setValue
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

@OptIn(BetaInteropApi::class)
actual suspend fun httpGet(url: String, timeoutMillis: Long, maxBytes: Int): String {
    val address = NSURL.URLWithString(url)?.takeIf { it.scheme == "https" } ?: throw HttpException("Not an https address: $url")
    val request = NSMutableURLRequest.requestWithURL(address).apply {
        setHTTPMethod("GET")
        setTimeoutInterval(timeoutMillis / 1000.0)
        setCachePolicy(NSURLRequestReloadIgnoringLocalCacheData)
        setValue("application/json", forHTTPHeaderField = "Accept")
    }
    return suspendCancellableCoroutine { continuation ->
        val task = NSURLSession.sharedSession.dataTaskWithRequest(request) { data, response, error ->
            val code = (response as? NSHTTPURLResponse)?.statusCode?.toInt()
            when {
                error != null -> continuation.resumeWithException(HttpException(error.localizedDescription))
                code != 200 -> continuation.resumeWithException(HttpException("HTTP $code from $url"))
                data == null -> continuation.resumeWithException(HttpException("No answer from $url"))
                data.length.toLong() > maxBytes -> continuation.resumeWithException(HttpException("The answer of $url is too large"))
                else -> continuation.resume(NSString.create(data = data, encoding = NSUTF8StringEncoding)?.toString().orEmpty())
            }
        }
        continuation.invokeOnCancellation { task.cancel() }
        task.resume()
    }
}

actual fun formatDateTime(epochMillis: Long, languageCode: String): String = NSDateFormatter().apply {
    dateStyle = NSDateFormatterMediumStyle
    timeStyle = NSDateFormatterShortStyle
    locale = NSLocale(localeIdentifier = languageCode)
}.stringFromDate(NSDate.dateWithTimeIntervalSince1970(epochMillis / 1000.0))
