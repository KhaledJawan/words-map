import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_map_app/models/vocab_word.dart';

class AppState with ChangeNotifier {
  Locale? _appLocale;
  bool _onboardingCompleted = false;
  String _currentLevel = 'A1.1';
  ThemeMode _themeMode = ThemeMode.system;
  Set<String> _bookmarkedIds = {};
  Set<String> _viewedIds = {};

  Locale? get appLocale => _appLocale;
  bool get onboardingCompleted => _onboardingCompleted;
  String get currentLevel => _currentLevel;
  ThemeMode get themeMode => _themeMode;
  Set<String> get viewedIds => _viewedIds;

  final List<String> levels = const [
    'A1.1',
    'A1.2',
    'A2.1',
    'A2.2',
    'B1.1',
    'B1.2',
    'B2.1',
    'B2.2',
  ];

  AppState() {
    _loadAppState();
  }

  Future<void> _loadAppState() async {
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

    await _loadBookmarks();

    notifyListeners();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('bookmarkedWordIds') ?? <String>[];
    _bookmarkedIds = ids.toSet();
    final viewed = prefs.getStringList('viewedWordIds') ?? <String>[];
    _viewedIds = viewed.toSet();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _bookmarkedIds.toList();
    await prefs.setStringList('bookmarkedWordIds', ids);
    await prefs.setStringList('viewedWordIds', _viewedIds.toList());
  }

  bool isBookmarked(VocabWord word) {
    return _bookmarkedIds.contains(word.id);
  }

  Future<void> toggleBookmark(VocabWord word) async {
    if (isBookmarked(word)) {
      _bookmarkedIds.remove(word.id);
      word.isBookmarked = false;
    } else {
      _bookmarkedIds.add(word.id);
      word.isBookmarked = true;
    }
    await _saveBookmarks();
    notifyListeners();
  }

  bool isViewed(VocabWord word) => _viewedIds.contains(word.id);

  Future<void> markViewed(VocabWord word) async {
    if (_viewedIds.contains(word.id)) return;
    _viewedIds.add(word.id);
    await _saveBookmarks();
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
    notifyListeners();
  }
}
