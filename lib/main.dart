import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'screens/language_onboarding_screen.dart';
import 'services/app_state.dart';
import 'utils/app_theme.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/sign_in_or_skip_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/words_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully', name: 'main');
  } catch (e) {
    developer.log('Firebase initialization error: $e', name: 'main', error: e);
    rethrow;
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const WordMapApp(),
    ),
  );
}

class WordMapApp extends StatelessWidget {
  const WordMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.appLocale == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return MaterialApp(
      title: 'Word Map',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      locale: appState.appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: appState.onboardingCompleted ? '/sign-in-or-skip' : '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (_) => LanguageOnboardingScreen(
                      currentLocale: appState.appLocale ?? const Locale('en'),
                      onLocaleChanged: (locale) =>
                          appState.changeLocale(locale),
                      onFinished: () => appState.completeOnboarding(),
                    ));
          case '/sign-in-or-skip':
            return MaterialPageRoute(builder: (_) => const SignInOrSkipScreen());
          case '/sign-in':
            return MaterialPageRoute(builder: (_) => const SignInScreen());
          case '/levels':
            return MaterialPageRoute(builder: (_) => const LevelSelectScreen());
          case '/words':
            return MaterialPageRoute(
              builder: (_) => WordsListScreen(
                level: settings.arguments as String?,
              ),
            );
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          default:
            // It's good practice to handle unknown routes.
            // For now, we'll just navigate to the home screen.
            return MaterialPageRoute(
                builder: (_) => LanguageOnboardingScreen(
                  currentLocale: appState.appLocale ?? const Locale('en'),
                  onLocaleChanged: (locale) =>
                      appState.changeLocale(locale),
                  onFinished: () => appState.completeOnboarding(),
                ));
        }
      },
    );
  }
}
