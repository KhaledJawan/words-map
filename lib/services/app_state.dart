import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_language.dart';
import '../theme_controller.dart';

class AppState with ChangeNotifier {
  Locale? _appLocale;
  AppLanguage _appLanguage = AppLanguage.en;
  List<AppLanguage> _wordLanguages = const [AppLanguage.en];
  bool _wordLanguagesCustomized = false;
  bool _onboardingCompleted = false;
  bool _isDataLoaded = false;
  String _currentLevel = 'A1.1';
  ThemeMode _themeMode = ThemeMode.system;
  Set<String> _bookmarkedIds = {};
  Set<String> _viewedIds = {};

  static const String _prefsWordLanguagesKey = 'word_languages';

  Locale? get appLocale => _appLocale;
  AppLanguage get appLanguage => _appLanguage;
  List<AppLanguage> get wordLanguages => List.unmodifiable(_wordLanguages);
  AppLanguage get sourceWordLanguage =>
      _wordLanguages.length > 1 ? _wordLanguages.first : AppLanguage.de;
  AppLanguage get targetWordLanguage {
    if (_wordLanguages.length > 1) return _wordLanguages[1];
    if (_wordLanguages.isEmpty) return _appLanguage;
    final only = _wordLanguages.first;
    if (only == AppLanguage.de) return AppLanguage.en;
    return only;
  }

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
    final storedLanguageCode = prefs.getString('languageCode');
    _appLanguage = appLanguageFromLocale(storedLanguageCode);
    _appLocale = _appLanguage.locale;
    if (storedLanguageCode == null ||
        storedLanguageCode != _appLanguage.languageCode) {
      await prefs.setString('languageCode', _appLanguage.languageCode);
    }

    final storedWordLanguages = prefs.getStringList(_prefsWordLanguagesKey);
    if (storedWordLanguages == null) {
      _wordLanguagesCustomized = false;
      _wordLanguages = [_appLanguage];
    } else {
      _wordLanguagesCustomized = true;
      _wordLanguages = _normalizeWordLanguages(
        storedWordLanguages.map(wordLanguageFromCode).toList(),
        fallback: _appLanguage,
      );
      final normalizedCodes = _wordLanguages
          .map((l) => l.languageCode)
          .toList();
      if (normalizedCodes.length != storedWordLanguages.length ||
          !_listEquals(normalizedCodes, storedWordLanguages)) {
        await prefs.setStringList(_prefsWordLanguagesKey, normalizedCodes);
      }
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

  List<AppLanguage> _normalizeWordLanguages(
    List<AppLanguage> languages, {
    required AppLanguage fallback,
  }) {
    final out = <AppLanguage>[];
    for (final lang in languages) {
      if (out.contains(lang)) continue;
      out.add(lang);
      if (out.length == 2) break;
    }
    if (out.isEmpty) return [fallback];
    return out;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> changeLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    if (_appLocale == newLocale) {
      return;
    }
    _appLocale = newLocale;
    _appLanguage = appLanguageFromLocale(newLocale.languageCode);
    await prefs.setString('languageCode', newLocale.languageCode);
    if (!_wordLanguagesCustomized) {
      _wordLanguages = [_appLanguage];
    }
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    final prefs = await SharedPreferences.getInstance();
    if (_appLanguage == lang) return;
    _appLanguage = lang;
    _appLocale = lang.locale;
    await prefs.setString('languageCode', lang.languageCode);
    if (!_wordLanguagesCustomized) {
      _wordLanguages = [_appLanguage];
    }
    notifyListeners();
  }

  Future<void> setWordLanguages(List<AppLanguage> languages) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeWordLanguages(
      languages,
      fallback: _appLanguage,
    );
    _wordLanguagesCustomized = true;
    _wordLanguages = normalized;
    await prefs.setStringList(
      _prefsWordLanguagesKey,
      normalized.map((l) => l.languageCode).toList(),
    );
    notifyListeners();
  }

  Future<void> resetWordLanguagesToAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _wordLanguagesCustomized = false;
    _wordLanguages = [_appLanguage];
    await prefs.remove(_prefsWordLanguagesKey);
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
