package dev.nefrin.wordsmap

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.res.Configuration
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.runtime.LaunchedEffect
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import dev.nefrin.wordsmap.data.AppLanguage
import dev.nefrin.wordsmap.data.AppPreferences
import dev.nefrin.wordsmap.data.SharedPreferencesStore
import dev.nefrin.wordsmap.reminder.AndroidReminderScheduler
import dev.nefrin.wordsmap.ui.WordsMapApp
import dev.nefrin.wordsmap.update.PlayStore
import java.util.Locale

class MainActivity : ComponentActivity() {
    // The interface language this activity was created with.
    private var appliedLanguage = AppLanguage.EN

    // The screens take their texts from the shared code in the chosen language. The activity
    // still runs in that locale too, so that what Android draws itself (such as the text
    // selection menu) speaks the same language.
    override fun attachBaseContext(newBase: Context) {
        appliedLanguage = AppPreferences(SharedPreferencesStore(newBase)).appLanguage
        val configuration = Configuration(newBase.resources.configuration).apply {
            setLocale(Locale.forLanguageTag(appliedLanguage.code))
        }
        super.attachBaseContext(newBase.createConfigurationContext(configuration))
    }

    private val viewModel: AppViewModel by viewModels {
        viewModelFactory {
            initializer {
                AppViewModel(
                    AppPreferences(SharedPreferencesStore(applicationContext)),
                    AndroidReminderScheduler(applicationContext),
                    PlayStore.get(applicationContext),
                )
            }
        }
    }

    // Shows Google Play's update screens; Play reports back how they ended.
    private val updateFlow = registerForActivityResult(ActivityResultContracts.StartIntentSenderForResult()) { result ->
        PlayStore.get(applicationContext).onFlowResult(result.resultCode)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // The app icon stays on screen until the words are loaded, so the first screen
        // appears complete.
        installSplashScreen().setKeepOnScreenCondition { viewModel.content is ContentState.Loading }
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        PlayStore.get(applicationContext).attach(updateFlow)
        if (savedInstanceState == null) {
            openRequested(intent)
            openScreenshotScreen(intent)
        }
        setContent {
            LaunchedEffect(viewModel.appLanguage) {
                if (viewModel.appLanguage != appliedLanguage) recreate()
            }
            WordsMapApp(viewModel)
        }
    }

    override fun onDestroy() {
        PlayStore.get(applicationContext).detach(updateFlow)
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        openRequested(intent)
    }

    // The daily reminder opens the app on the daily words.
    private fun openRequested(intent: Intent?) {
        if (intent?.getBooleanExtra(EXTRA_OPEN_LEARN, false) != true) return
        intent.removeExtra(EXTRA_OPEN_LEARN)
        viewModel.openLearn()
    }

    // For Play Store screenshots (tools/store_screenshots): a debug build started with
    // `--es wordsmap.screen learn` opens that screen; see openForScreenshot for the values.
    private fun openScreenshotScreen(intent: Intent?) {
        if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE == 0) return
        intent?.getStringExtra(EXTRA_SCREEN)?.let { viewModel.openForScreenshot(it) }
    }

    companion object {
        const val EXTRA_OPEN_LEARN = "dev.nefrin.wordsmap.extra.OPEN_LEARN"
        private const val EXTRA_SCREEN = "wordsmap.screen"
    }
}
