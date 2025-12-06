import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'utils/app_theme.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/level_select_screen.dart';
import 'screens/words_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.loadInitialData();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      developer.log('Firebase initialized successfully', name: 'main');
    } else {
      Firebase.app();
    }
  } catch (e) {
    // Ignore duplicate-app errors; rethrow others.
    final msg = e.toString();
    if (!msg.contains('duplicate-app')) {
      developer.log('Firebase initialization error: $e',
          name: 'main', error: e);
      rethrow;
    }
  }
  runApp(
    ChangeNotifierProvider.value(
      value: appState, // Provide the initialized AppState instance
      child: const WordMapApp(),
    ),
  );
}

class WordMapApp extends StatelessWidget {
  const WordMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // This check is a safeguard for hot reloads, but data is loaded before runApp.
    if (!appState.isDataLoaded) {
      return const Center(child: CircularProgressIndicator());
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
      initialRoute: '/sign-in',
      onGenerateRoute: (settings) {
        switch (settings.name) {
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
            return MaterialPageRoute(builder: (_) => const SignInScreen());
        }
      },
    );
  }
}
