import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_map_app/models/word_progress.dart';

class ProgressRepository {
  static const String _progressKey = 'word_progress_map';
  static const String _lastLevelKey = 'last_level';
  static const String _lastWordsScopeKey = 'last_words_scope';
  static const String _lastCategoryTagKey = 'last_category_tag';

  Future<Map<String, WordProgress>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      return WordProgress.decodeMap(raw);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveProgress(Map<String, WordProgress> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, WordProgress.encodeMap(data));
  }

  Future<void> saveLastLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLevelKey, level);
  }

  Future<String?> loadLastLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLevelKey);
  }

  Future<void> saveLastWordsScope(String scope) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastWordsScopeKey, scope);
  }

  Future<String?> loadLastWordsScope() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastWordsScopeKey);
  }

  Future<void> saveLastCategoryTag(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCategoryTagKey, tag);
  }

  Future<String?> loadLastCategoryTag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCategoryTagKey);
  }
}
