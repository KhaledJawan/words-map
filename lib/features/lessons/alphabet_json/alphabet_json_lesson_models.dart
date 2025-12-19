class AlphabetLessonExplanation {
  const AlphabetLessonExplanation({
    required this.titleEn,
    required this.titleFa,
    required this.titlePs,
    required this.titleDe,
    required this.explanationEn,
    required this.explanationFa,
    required this.explanationPs,
    required this.explanationDe,
  });

  final String titleEn;
  final String titleFa;
  final String titlePs;
  final String titleDe;
  final String explanationEn;
  final String explanationFa;
  final String explanationPs;
  final String explanationDe;

  factory AlphabetLessonExplanation.fromJson(Map<String, dynamic> json) {
    return AlphabetLessonExplanation(
      titleEn: json['title_en']?.toString() ?? '',
      titleFa: json['title_fa']?.toString() ?? '',
      titlePs: json['title_ps']?.toString() ?? '',
      titleDe: json['title_de']?.toString() ?? '',
      explanationEn: json['explanation_en']?.toString() ?? '',
      explanationFa: json['explanation_fa']?.toString() ?? '',
      explanationPs: json['explanation_ps']?.toString() ?? '',
      explanationDe: json['explanation_de']?.toString() ?? '',
    );
  }
}

class AlphabetLessonLetter {
  const AlphabetLessonLetter({
    required this.upper,
    required this.lower,
    required this.nameDe,
    required this.faHint,
    required this.psHint,
    required this.examples,
  });

  final String upper;
  final String lower;
  final String nameDe;
  final String faHint;
  final String psHint;
  final List<String> examples;

  factory AlphabetLessonLetter.fromJson(Map<String, dynamic> json) {
    final examplesRaw = json['examples'];
    final exampleKeys = <String>[];
    if (examplesRaw is List) {
      for (final entry in examplesRaw) {
        if (entry is! Map<String, dynamic>) continue;
        final wordRef = entry['word_ref'];
        if (wordRef is! Map<String, dynamic>) continue;
        final key = wordRef['key']?.toString() ?? '';
        if (key.trim().isEmpty) continue;
        exampleKeys.add(key.trim());
      }
    }
    return AlphabetLessonLetter(
      upper: json['upper']?.toString() ?? '',
      lower: json['lower']?.toString() ?? '',
      nameDe: json['name_de']?.toString() ?? '',
      faHint: json['fa_hint']?.toString() ?? '',
      psHint: json['ps_hint']?.toString() ?? '',
      examples: exampleKeys,
    );
  }
}

class AlphabetLessonSpecialLetter {
  const AlphabetLessonSpecialLetter({
    required this.symbol,
    required this.nameDe,
    required this.faHint,
    required this.psHint,
    required this.descriptionFa,
    required this.descriptionEn,
    required this.descriptionPs,
    required this.descriptionDe,
  });

  final String symbol;
  final String nameDe;
  final String faHint;
  final String psHint;
  final String descriptionFa;
  final String descriptionEn;
  final String descriptionPs;
  final String descriptionDe;

  factory AlphabetLessonSpecialLetter.fromJson(Map<String, dynamic> json) {
    return AlphabetLessonSpecialLetter(
      symbol: json['symbol']?.toString() ?? '',
      nameDe: json['name_de']?.toString() ?? '',
      faHint: json['fa_hint']?.toString() ?? '',
      psHint: json['ps_hint']?.toString() ?? '',
      descriptionFa: json['description_fa']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionPs: json['description_ps']?.toString() ?? '',
      descriptionDe: json['description_de']?.toString() ?? '',
    );
  }
}

class AlphabetLessonAlphabetBlock {
  const AlphabetLessonAlphabetBlock({
    required this.noteFa,
    required this.noteEn,
    required this.notePs,
    required this.noteDe,
    required this.letters,
    required this.specialLetters,
  });

  final String noteFa;
  final String noteEn;
  final String notePs;
  final String noteDe;
  final List<AlphabetLessonLetter> letters;
  final List<AlphabetLessonSpecialLetter> specialLetters;

  factory AlphabetLessonAlphabetBlock.fromJson(Map<String, dynamic> json) {
    final lettersRaw = json['letters'];
    final specialRaw = json['special_letters'];
    return AlphabetLessonAlphabetBlock(
      noteFa: json['note_fa']?.toString() ?? '',
      noteEn: json['note_en']?.toString() ?? '',
      notePs: json['note_ps']?.toString() ?? '',
      noteDe: json['note_de']?.toString() ?? '',
      letters: lettersRaw is List
          ? lettersRaw
              .whereType<Map<String, dynamic>>()
              .map(AlphabetLessonLetter.fromJson)
              .toList()
          : const [],
      specialLetters: specialRaw is List
          ? specialRaw
              .whereType<Map<String, dynamic>>()
              .map(AlphabetLessonSpecialLetter.fromJson)
              .toList()
          : const [],
    );
  }
}

class AlphabetJsonLesson {
  const AlphabetJsonLesson({
    required this.id,
    required this.levelEn,
    required this.levelFa,
    required this.levelPs,
    required this.levelDe,
    required this.titleDe,
    required this.titleFa,
    required this.titleEn,
    required this.titlePs,
    required this.explanations,
    required this.alphabet,
    required this.uiNotesFa,
    required this.uiNotesEn,
    required this.uiNotesPs,
    required this.uiNotesDe,
    required this.assetPath,
  });

  final String id;
  final String levelEn;
  final String levelFa;
  final String levelPs;
  final String levelDe;
  final String titleDe;
  final String titleFa;
  final String titleEn;
  final String titlePs;
  final List<AlphabetLessonExplanation> explanations;
  final AlphabetLessonAlphabetBlock? alphabet;
  final String uiNotesFa;
  final String uiNotesEn;
  final String uiNotesPs;
  final String uiNotesDe;
  final String assetPath;

  factory AlphabetJsonLesson.fromJson(
    Map<String, dynamic> json, {
    required String assetPath,
  }) {
    final explanationsRaw = (json['explanition'] ?? json['explanation']);
    final uiNotes = json['ui_notes'];
    final legacyLevel = json['level']?.toString() ?? '';
    return AlphabetJsonLesson(
      id: json['id']?.toString() ?? '',
      levelEn: json['level_en']?.toString() ?? legacyLevel,
      levelFa: json['level_fa']?.toString() ?? legacyLevel,
      levelPs: json['level_ps']?.toString() ?? legacyLevel,
      levelDe: json['level_de']?.toString() ?? legacyLevel,
      titleDe: json['title_de']?.toString() ?? '',
      titleFa: json['title_fa']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      titlePs: json['title_ps']?.toString() ?? '',
      explanations: explanationsRaw is List
          ? explanationsRaw
              .whereType<Map<String, dynamic>>()
              .map(AlphabetLessonExplanation.fromJson)
              .toList()
          : const [],
      alphabet: json['alphabet'] is Map<String, dynamic>
          ? AlphabetLessonAlphabetBlock.fromJson(
              json['alphabet'] as Map<String, dynamic>,
            )
          : null,
      uiNotesFa: uiNotes is Map ? uiNotes['fa']?.toString() ?? '' : '',
      uiNotesEn: uiNotes is Map ? uiNotes['en']?.toString() ?? '' : '',
      uiNotesPs: uiNotes is Map ? uiNotes['ps']?.toString() ?? '' : '',
      uiNotesDe: uiNotes is Map ? uiNotes['de']?.toString() ?? '' : '',
      assetPath: assetPath,
    );
  }
}
