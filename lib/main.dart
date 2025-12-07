import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'utils/app_theme.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:lottie/lottie.dart';
import 'package:word_map_app/screens/words_list_init.dart';
import 'screens/words_list_screen.dart';
import 'screens/settings_screen.dart';
import 'theme_controller.dart';

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

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Word Map',
          debugShowCheckedModeBanner: false,
          scrollBehavior: IOSScrollBehavior(),
          themeMode: mode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          locale: appState.appLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _AuthGate(appState: appState),
          routes: {
            '/words': (_) => WordsListScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: WordMapColors.lightBackground,
    canvasColor: WordMapColors.lightSurface,
    cardColor: WordMapColors.lightCard,
    colorScheme: const ColorScheme.light(
      primary: WordMapColors.primaryBlue,
      secondary: WordMapColors.accentOrange,
      surface: WordMapColors.lightSurface,
      background: WordMapColors.lightBackground,
    ),
    dividerColor: Colors.grey.shade300,
    appBarTheme: const AppBarTheme(
      backgroundColor: WordMapColors.lightSurface,
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
      color: WordMapColors.lightCard,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(0.05),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: WordMapColors.primaryBlue,
      textColor: Colors.black,
      subtitleTextStyle: TextStyle(
        color: Colors.black54,
        fontSize: 13,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WordMapColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Colors.black87),
      labelLarge: TextStyle(color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: WordMapColors.lightSurface,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedItemColor: WordMapColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

ThemeData _buildDarkTheme() {
  final base = _buildLightTheme();
  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: WordMapColors.darkBackground,
    canvasColor: WordMapColors.darkSurface,
    cardColor: WordMapColors.darkCard,
    colorScheme: const ColorScheme.dark(
      primary: WordMapColors.primaryBlue,
      secondary: WordMapColors.accentOrange,
      surface: WordMapColors.darkSurface,
      background: WordMapColors.darkBackground,
    ),
    dividerColor: WordMapColors.dividerDark,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: WordMapColors.darkSurface,
      foregroundColor: Colors.white,
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(color: Colors.white),
    ),
    cardTheme: base.cardTheme.copyWith(color: WordMapColors.darkCard),
    listTileTheme: base.listTileTheme.copyWith(
      iconColor: WordMapColors.primaryBlue,
      textColor: Colors.white,
      subtitleTextStyle: const TextStyle(color: Colors.white70, fontSize: 13),
    ),
    textTheme: base.textTheme.apply(bodyColor: Colors.white70, displayColor: Colors.white70).copyWith(
          titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          titleMedium: const TextStyle(color: Colors.white70),
          labelLarge: const TextStyle(color: Colors.white),
        ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      fillColor: Colors.grey.shade900,
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: WordMapColors.darkSurface,
      selectedItemColor: WordMapColors.primaryBlue,
      unselectedItemColor: Colors.grey,
    ),
  );
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

class _AuthGate extends StatefulWidget {
  final AppState appState;
  const _AuthGate({required this.appState});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final Future<List<dynamic>> _splashFuture;

  @override
  void initState() {
    super.initState();
    final prefetchBundle = loadWordsInit(widget.appState, context);
    _splashFuture = Future.wait<dynamic>([
      Future.delayed(const Duration(seconds: 3)),
      prefetchBundle,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _splashFuture,
      builder: (context, splashSnap) {
        if (splashSnap.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        final results = splashSnap.data!;
        final bundle = results[1] as WordsInitBundle;
        // After splash + prefetch, go to main experience with prefetched data.
        return WordsListScreen(
          level: widget.appState.currentLevel,
          initialBundle: bundle,
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/lottie/splash.json',
          width: 160,
          height: 160,
          repeat: false,
        ),
      ),
    );
  }
}
