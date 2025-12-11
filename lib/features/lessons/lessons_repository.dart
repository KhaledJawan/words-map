import 'package:shared_preferences/shared_preferences.dart';

class LessonSlide {
  final String id;
  final String text;
  final String? title;

  const LessonSlide({
    required this.id,
    required this.text,
    this.title,
  });
}

class LessonItem {
  final String id;
  final String title;
  final String categoryId;
  final String? description;
  final List<LessonSlide> slides;

  const LessonItem({
    required this.id,
    required this.title,
    required this.categoryId,
    this.description,
    required this.slides,
  });
}

class LessonCategory {
  final String id;
  final String title;
  final String? description;
  final List<LessonItem> lessons;

  const LessonCategory({
    required this.id,
    required this.title,
    this.description,
    this.lessons = const [],
  });
}

class LessonsRepository {
  static const _completionPrefix = 'lesson_completed_';

  static final List<LessonCategory> categories = [
    LessonCategory(
      id: 'beginner',
      title: 'Beginner Basics',
      description: 'Start here: alphabet, reading, and daily exchanges.',
      lessons: [
        LessonItem(
          id: 'alphabet',
          title: 'Alphabet',
          categoryId: 'beginner',
          description: 'Get comfortable with the letters.',
          slides: [
            const LessonSlide(
              id: 'alphabet-slide-1',
              title: 'Alphabet Overview',
              text: 'TODO: Add real content for Alphabet slide 1.',
            ),
            const LessonSlide(
              id: 'alphabet-slide-2',
              title: 'Pronunciation tips',
              text: 'TODO: Add real content for Alphabet slide 2.',
            ),
          ],
        ),
        LessonItem(
          id: 'reading_rules',
          title: 'Reading rules',
          categoryId: 'beginner',
          description: 'Learn how letters combine.',
          slides: [
            const LessonSlide(
              id: 'reading-slide-1',
              text: 'TODO: Add real content for Reading rules slide 1.',
            ),
            const LessonSlide(
              id: 'reading-slide-2',
              text: 'TODO: Add real content for Reading rules slide 2.',
            ),
          ],
        ),
        LessonItem(
          id: 'parts_of_speech',
          title: 'Parts of speech',
          categoryId: 'beginner',
          description: 'Simple mechanics of German grammar.',
          slides: [
            const LessonSlide(
              id: 'parts-slide-1',
              text: 'TODO: Add real content for Parts of speech slide 1.',
            ),
            const LessonSlide(
              id: 'parts-slide-2',
              text: 'TODO: Add real content for Parts of speech slide 2.',
            ),
          ],
        ),
        LessonItem(
          id: 'hallo',
          title: 'Hallo',
          categoryId: 'beginner',
          description: 'Greetings for everyday practice.',
          slides: [
            const LessonSlide(
              id: 'hallo-slide-1',
              text: 'TODO: Add real content for Hallo slide 1.',
            ),
            const LessonSlide(
              id: 'hallo-slide-2',
              text: 'TODO: Add real content for Hallo slide 2.',
            ),
          ],
        ),
        LessonItem(
          id: 'all_about_german',
          title: 'All about German',
          categoryId: 'beginner',
          description: 'Culture, words, and basics to keep learning.',
          slides: [
            const LessonSlide(
              id: 'german-slide-1',
              text: 'TODO: Add real content for All about German slide 1.',
            ),
            const LessonSlide(
              id: 'german-slide-2',
              text: 'TODO: Add real content for All about German slide 2.',
            ),
          ],
        ),
      ],
    ),
    const LessonCategory(
      id: 'grammar',
      title: 'Grammar',
      description: 'Structure and syntax (coming soon).',
    ),
    const LessonCategory(
      id: 'dialogues',
      title: 'Useful Dialogues',
      description: 'Short conversations you can say today.',
    ),
    const LessonCategory(
      id: 'reading_listening',
      title: 'Reading & Listening',
      description: 'Practice comprehension with short stories.',
    ),
    const LessonCategory(
      id: 'exam',
      title: 'Exam Practice',
      description: 'Targeted drills for exams (A1, A2).',
    ),
  ];

  static List<LessonItem> get _allLessons =>
      categories.expand((category) => category.lessons).toList();

  Future<Map<String, bool>> loadCompletionStates() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> states = {};
    for (final lesson in _allLessons) {
      states[lesson.id] = prefs.getBool(_completionKey(lesson.id)) ?? false;
    }
    return states;
  }

  Future<void> markCompleted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completionKey(lessonId), true);
  }

  static String _completionKey(String lessonId) =>
      '$_completionPrefix$lessonId';
}
