import 'package:shared_preferences/shared_preferences.dart';

class LessonCompletionRepository {
  static const _completionPrefix = 'lesson_completed_';

  Future<Set<String>> loadCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = <String>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_completionPrefix)) continue;
      final lessonId = key.substring(_completionPrefix.length);
      if (prefs.getBool(key) == true) {
        completed.add(lessonId);
      }
    }
    return completed;
  }

  Future<void> setLessonCompleted(String lessonId, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_completionPrefix$lessonId';
    await prefs.setBool(key, isCompleted);
  }
}
