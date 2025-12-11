import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme_controller.dart';

class AppState with ChangeNotifier {
  Locale? _appLocale;
  bool _onboardingCompleted = false;
  bool _isDataLoaded = false;
  String _currentLevel = 'A1.1';
  ThemeMode _themeMode = ThemeMode.system;
  Set<String> _bookmarkedIds = {};
  Set<String> _viewedIds = {};

  Locale? get appLocale => _appLocale;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isDataLoaded => _isDataLoaded;
  String get currentLevel => _currentLevel;
  ThemeMode get themeMode => _themeMode;
  List<String> get levels => const [
        'A1.1',
        'A1.2',
        'A2.1',
        'A2.2',
        'B1.1',
        'B1.2',
        'B2.1',
        'B2.2',
      ];

  // The constructor is now empty. Initialization is handled by `loadInitialData`.
  AppState();

  /// Loads the initial state from SharedPreferences.
  /// This should be called before the app is run.
  Future<void> loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _appLocale = Locale(languageCode);
    } else {
      _appLocale = const Locale('en');
    }

    _onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
    _currentLevel = prefs.getString('currentLevel') ?? 'A1.1';

    final theme = prefs.getString('themeMode');
    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    final bookmarked = prefs.getStringList('bookmarkedWordIds') ?? <String>[];
    final viewed = prefs.getStringList('viewedWordIds') ?? <String>[];
    _bookmarkedIds = bookmarked.toSet();
    _viewedIds = viewed.toSet();

    _isDataLoaded = true;
    notifyListeners();
  }

  Future<void> changeLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    if (_appLocale == newLocale) {
      return;
    }
    _appLocale = newLocale;
    await prefs.setString('languageCode', newLocale.languageCode);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = true;
    await prefs.setBool('onboardingCompleted', true);
    notifyListeners();
  }

  Future<void> setCurrentLevel(String newLevel) async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentLevel == newLevel) {
      return;
    }
    _currentLevel = newLevel;
    await prefs.setString('currentLevel', newLevel);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = mode;
    await prefs.setString('themeMode', mode.name);
    appThemeMode.value = mode;
    notifyListeners();
  }

  bool isBookmarked(dynamic word) => _bookmarkedIds.contains(word.id);

  Future<void> toggleBookmark(dynamic word) async {
    final prefs = await SharedPreferences.getInstance();
    if (_bookmarkedIds.contains(word.id)) {
      _bookmarkedIds.remove(word.id);
      word.isBookmarked = false;
    } else {
      _bookmarkedIds.add(word.id);
      word.isBookmarked = true;
    }
    await prefs.setStringList('bookmarkedWordIds', _bookmarkedIds.toList());
    notifyListeners();
  }

  bool isViewed(dynamic word) => _viewedIds.contains(word.id);

  Future<void> markViewed(dynamic word) async {
    if (_viewedIds.contains(word.id)) return;
    final prefs = await SharedPreferences.getInstance();
    _viewedIds.add(word.id);
    word.isViewed = true;
    await prefs.setStringList('viewedWordIds', _viewedIds.toList());
    notifyListeners();
  }

  /// Debug helper to check Firebase connectivity and print the current user.
  Future<void> logFirebaseStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('FirebaseAuth currentUser: ${user?.uid ?? 'none'}');
    } catch (e) {
      debugPrint('Firebase connectivity check failed: $e');
    }
  }

  /// Clears viewed and bookmarked word state locally and in preferences.
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarkedIds.clear();
    _viewedIds.clear();
    await prefs.setStringList('bookmarkedWordIds', _bookmarkedIds.toList());
    await prefs.setStringList('viewedWordIds', _viewedIds.toList());
    notifyListeners();
  }
}
