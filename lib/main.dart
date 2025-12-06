import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'utils/app_theme.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      scrollBehavior: IOSScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4BA8FF),
          primary: const Color(0xFF4BA8FF),
          secondary: const Color(0xFF5856D6),
          background: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black.withOpacity(0.05),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF4BA8FF),
          textColor: Colors.black,
          subtitleTextStyle: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4BA8FF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedItemColor: Color(0xFF4BA8FF),
          unselectedItemColor: Colors.grey,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      locale: appState.appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _AuthGate(appState: appState),
      routes: {
        '/sign-in': (_) => const SignInScreen(),
        '/levels': (_) => const LevelSelectScreen(),
        '/words': (_) => WordsListScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

class IOSScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class _AuthGate extends StatelessWidget {
  final AppState appState;
  const _AuthGate({required this.appState});

  @override
  Widget build(BuildContext context) {
    // Always enter the app directly; listen to auth changes only to keep user info fresh.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Regardless of auth state, go to the main experience.
        return WordsListScreen(level: appState.currentLevel);
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
