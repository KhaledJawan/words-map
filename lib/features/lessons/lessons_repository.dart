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
              title: 'German Alphabet – Overview',
              text:
                  'The German alphabet has 26 basic letters like English (A–Z) plus 4 extra characters:\n\nÄ, Ö, Ü (called “Umlaut” vowels)\n\nß (called “Eszett” or “scharfes S”)\nExample:\n\nä like in “Mädchen”\n\nö like in “schön”\n\nü like in “Tschüss”\n\nß like in “Straße”',
            ),
            const LessonSlide(
              id: 'alphabet-slide-2',
              title: 'Vowels (A, E, I, O, U)',
              text:
                  'German vowels can be short or long.\n\nShort: “Mann”, “Sonne”, “Mitte”\n\nLong: “Name”, “Meer”, “Liebe”, “Boot”, “gut”\nOften, a doubled consonant after a vowel makes it short:\n\n“Mitte” (short i) vs “Miete” (long ie)',
            ),
            const LessonSlide(
              id: 'alphabet-slide-3',
              title: 'Umlaut vowels (Ä, Ö, Ü)',
              text:
                  'Umlaut vowels change the sound and sometimes the meaning.\n\na → ä : “Mann” vs “Männer”\n\no → ö : “schon” vs “schön”\n\nu → ü : “Mutter” vs “Mütter”\nIn typing, you can write them as:\n\nä → ae, ö → oe, ü → ue',
            ),
            const LessonSlide(
              id: 'alphabet-slide-4',
              title: 'ß – Eszett',
              text:
                  'ß is used only in German. It is pronounced like a sharp “s”.\n\nExample: “Straße”, “heißen”, “Fuß”\nIf you can’t type ß, you can use “ss”:\n\nStraße → Strasse, Fuß → Fuss',
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
              title: 'Basic reading rule – “ie” vs “ei”',
              text:
                  'German has two important letter pairs:\n\n“ie” → long “i” (like “machine”)\n\n“ei” → like English “eye”\nExamples:\n\n“vier”, “lieben”, “Spiel” (ie → long i)\n\n“eins”, “mein”, “klein” (ei → eye sound)',
            ),
            const LessonSlide(
              id: 'reading-slide-2',
              title: '“sch”, “ch” and “sp / st”',
              text:
                  '“sch” → like English “sh”: “Schule”, “Fisch”\n\n“ch” has two sounds:\n\nafter e, i, ä, ö, ü → soft “ch”: “ich”, “leicht”\n\nafter a, o, u → strong “ch”: “Bach”, “noch”, “Buch”\nAt the beginning of a word:\n\n“sp” → “shp”: “Sport”, “spät”\n\n“st” → “sht”: “Straße”, “Stadt”',
            ),
            const LessonSlide(
              id: 'reading-slide-3',
              title: 'Capital letters (Nouns)',
              text:
                  'In German, all nouns start with a capital letter.\nExamples:\n\n“der Hund”, “die Frau”, “das Auto”, “die Stadt”\nThis helps you recognize nouns quickly in a sentence.',
            ),
            const LessonSlide(
              id: 'reading-slide-4',
              title: 'Long vs short vowels',
              text:
                  'Typical patterns:\n\nLong vowel: vowel + h → “fahren”, “sehen”\n\nLong vowel: double vowel → “Meer”, “Boot”\n\nShort vowel: vowel + double consonant → “Mitte”, “Mutter”\nYou don’t need to memorize every rule now, just start to notice these patterns when reading.',
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
              title: 'Main parts of speech',
              text:
                  'The most important word types in German:\n\nNomen (nouns): Dinge, Personen, Orte – “Auto”, “Frau”, “Berlin”\n\nVerben (verbs): Aktionen – “gehen”, “lernen”, “schlafen”\n\nAdjektive (adjectives): Eigenschaften – “groß”, “klein”, “schnell”\n\nArtikel (articles): “der”, “die”, “das”, “ein”, “eine”',
            ),
            const LessonSlide(
              id: 'parts-slide-2',
              title: 'Nouns and gender',
              text:
                  'Every German noun has a gender:\n\nder (maskulin)\n\ndie (feminin)\n\ndas (neutrum)\nExamples:\n\nder Tisch, der Tag\n\ndie Lampe, die Stadt\n\ndas Buch, das Kind',
            ),
            const LessonSlide(
              id: 'parts-slide-3',
              title: 'Verbs in basic form (Infinitiv)',
              text:
                  'Most verbs end with “-en” or “-n”.\nExamples:\n\ngehen, kommen, lernen, machen, arbeiten\nWhen you conjugate them, the ending changes:\n\nich gehe, du gehst, er/sie geht',
            ),
            const LessonSlide(
              id: 'parts-slide-4',
              title: 'Adjectives – describing words',
              text:
                  'Adjectives describe nouns:\n\nein großer Hund\n\neine kleine Wohnung\n\nein neues Auto\nAt A1 level, it’s enough to recognize them and use them in simple phrases.',
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
              title: 'Basic greetings',
              text:
                  'Common ways to say hello:\n\nHallo!\n\nGuten Morgen! (morning)\n\nGuten Tag! (day / afternoon)\n\nGuten Abend! (evening)\n\nTschüss! / Auf Wiedersehen! (goodbye)',
            ),
            const LessonSlide(
              id: 'hallo-slide-2',
              title: 'Introducing yourself',
              text:
                  'Useful phrases:\n\nIch heiße …\n\nIch bin …\n\nIch komme aus …\n\nIch wohne in …\nExample:\n\n„Hallo, ich heiße Khaled. Ich komme aus … und wohne in Trier.“',
            ),
            const LessonSlide(
              id: 'hallo-slide-3',
              title: 'Asking “How are you?”',
              text:
                  'Wie geht es dir? (informal)\n\nWie geht es Ihnen? (formal)\nPossible answers:\n\nMir geht es gut.\n\nEs geht.\n\nNicht so gut.',
            ),
            const LessonSlide(
              id: 'hallo-slide-4',
              title: 'Polite words',
              text:
                  'Always useful:\n\nDanke! / Vielen Dank!\n\nBitte! (you’re welcome / please)\n\nEntschuldigung! (sorry / excuse me)\nThese small words make your German sound friendly.',
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
              title: 'Where is German spoken?',
              text:
                  'German is spoken in:\n\nGermany (Deutschland)\n\nAustria (Österreich)\n\nSwitzerland (Schweiz – part of the country)\nand in some other regions in Europe.\nThere are different accents and dialects, but the standard language is called “Hochdeutsch”.',
            ),
            const LessonSlide(
              id: 'german-slide-2',
              title: 'Formal vs informal “you”',
              text:
                  'German has two forms of “you”:\n\ndu (informal, for friends, family)\n\nSie (formal, polite, for strangers / official situations)\nExample:\n\nWie geht es dir? (du)\n\nWie geht es Ihnen? (Sie)',
            ),
            const LessonSlide(
              id: 'german-slide-3',
              title: 'Word order – basic idea',
              text:
                  'In a simple main clause, the verb is usually in position 2:\n\nIch lerne Deutsch.\n\nHeute lerne ich Deutsch.\n\nMorgen gehe ich nach Berlin.\nYou don’t need all grammar rules now, but remember: the verb wants to be in position 2.',
            ),
            const LessonSlide(
              id: 'german-slide-4',
              title: 'Don’t be afraid of long words',
              text:
                  'German loves long compound words:\n\ndie Straßenbahn (Straße + Bahn)\n\ndas Krankenhaus (krank + Haus)\n\ndie Haustür (Haus + Tür)\nTry to see them as small pieces glued together.\nThis makes them easier to understand and remember.',
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
