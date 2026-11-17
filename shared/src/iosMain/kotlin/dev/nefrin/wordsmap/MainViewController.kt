package dev.nefrin.wordsmap

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.ComposeUIViewController
import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.data.UserDefaultsStore
import dev.nefrin.wordsmap.platform.StatusBar
import dev.nefrin.wordsmap.platform.StatusBarController
import dev.nefrin.wordsmap.reminder.IosReminderScheduler
import dev.nefrin.wordsmap.reminder.ReminderTaps
import dev.nefrin.wordsmap.reminder.notificationsAllowedForScreenshots
import dev.nefrin.wordsmap.resources.Res
import dev.nefrin.wordsmap.resources.splash_logo
import dev.nefrin.wordsmap.ui.WordsMapApp
import dev.nefrin.wordsmap.update.AppleAppStore
import org.jetbrains.compose.resources.painterResource
import platform.Foundation.NSProcessInfo
import platform.UIKit.UIViewController
import kotlin.experimental.ExperimentalNativeApi
import kotlin.native.Platform

/** The whole app as one view controller; the Xcode project shows it in its window. */
@Suppress("FunctionName", "unused") // Called from Swift.
fun MainViewController(): UIViewController {
    val viewModel = AppViewModel(AppPreferences(UserDefaultsStore()), IosReminderScheduler(), AppleAppStore())
    openRequestedScreen(viewModel)
    val compose = ComposeUIViewController {
        // The daily reminder was tapped: show the daily words.
        LaunchedEffect(ReminderTaps.pending) {
            if (ReminderTaps.pending) {
                viewModel.openLearn()
                ReminderTaps.pending = false
            }
        }
        WordsMapApp(viewModel, loading = { Splash() })
    }
    return StatusBarController(compose).also { StatusBar.controller = it }
}

// Continues the launch screen of the Xcode project (logo on the splash color) until the
// words are loaded, as the Android splash screen does. Both show the logo at 288 points.
@Composable
private fun Splash() {
    Box(Modifier.fillMaxSize().background(SplashColor), contentAlignment = Alignment.Center) {
        Image(painterResource(Res.drawable.splash_logo), contentDescription = null, modifier = Modifier.size(288.dp))
    }
}

private val SplashColor = Color(0xFF031918)

/**
 * For App Store screenshots: a debug build started with `WORDSMAP_SCREEN` opens that screen,
 * for example `SIMCTL_CHILD_WORDSMAP_SCREEN=learn xcrun simctl launch booted
 * dev.nefrin.wordsmap`. See [openForScreenshot] for the values. Notifications count as
 * allowed, so a reminder shows as set. Release builds ignore it.
 */
@OptIn(ExperimentalNativeApi::class)
private fun openRequestedScreen(viewModel: AppViewModel) {
    if (!Platform.isDebugBinary) return
    val request = NSProcessInfo.processInfo.environment["WORDSMAP_SCREEN"] as? String ?: return
    notificationsAllowedForScreenshots = true
    viewModel.openForScreenshot(request)
}
