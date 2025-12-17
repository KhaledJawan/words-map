class CombinationWordRef {
  const CombinationWordRef({
    required this.source,
    required this.key,
  });

  final String source;
  final String key;

  factory CombinationWordRef.fromJson(Map<String, dynamic> json) {
    return CombinationWordRef(
      source: json['source']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
    );
  }
}

class CombinationExample {
  const CombinationExample({required this.wordRef});

  final CombinationWordRef? wordRef;

  factory CombinationExample.fromJson(Map<String, dynamic> json) {
    final raw = json['word_ref'];
    return CombinationExample(
      wordRef:
          raw is Map<String, dynamic> ? CombinationWordRef.fromJson(raw) : null,
    );
  }
}

class LetterCombinationRule {
  const LetterCombinationRule({
    required this.id,
    required this.titleDe,
    required this.titleFa,
    required this.titleEn,
    required this.descriptionFa,
    required this.descriptionEn,
    required this.descriptionDe,
    required this.examples,
  });

  final String id;
  final String titleDe;
  final String titleFa;
  final String titleEn;
  final String descriptionFa;
  final String descriptionEn;
  final String descriptionDe;
  final List<CombinationExample> examples;

  factory LetterCombinationRule.fromJson(Map<String, dynamic> json) {
    final examplesRaw = json['examples'];
    return LetterCombinationRule(
      id: json['id']?.toString() ?? '',
      titleDe: json['title_de']?.toString() ?? '',
      titleFa: json['title_fa']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      descriptionFa: json['description_fa']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionDe: json['description_de']?.toString() ?? '',
      examples: examplesRaw is List
          ? examplesRaw
              .whereType<Map<String, dynamic>>()
              .map(CombinationExample.fromJson)
              .toList()
          : const [],
    );
  }
}

class CombinationsLessonExplanation {
  const CombinationsLessonExplanation({
    required this.titleEn,
    required this.titleFa,
    required this.titleDe,
    required this.explanationEn,
    required this.explanationFa,
    required this.explanationDe,
  });

  final String titleEn;
  final String titleFa;
  final String titleDe;
  final String explanationEn;
  final String explanationFa;
  final String explanationDe;

  factory CombinationsLessonExplanation.fromJson(Map<String, dynamic> json) {
    return CombinationsLessonExplanation(
      titleEn: json['title_en']?.toString() ?? '',
      titleFa: json['title_fa']?.toString() ?? '',
      titleDe: json['title_de']?.toString() ?? '',
      explanationEn: json['explanation_en']?.toString() ?? '',
      explanationFa: json['explanation_fa']?.toString() ?? '',
      explanationDe: json['explanation_de']?.toString() ?? '',
    );
  }
}

class CombinationsJsonLesson {
  const CombinationsJsonLesson({
    required this.id,
    required this.levelEn,
    required this.levelFa,
    required this.levelDe,
    required this.titleDe,
    required this.titleFa,
    required this.titleEn,
    required this.explanations,
    required this.combinations,
    required this.assetPath,
  });

  final String id;
  final String levelEn;
  final String levelFa;
  final String levelDe;
  final String titleDe;
  final String titleFa;
  final String titleEn;
  final List<CombinationsLessonExplanation> explanations;
  final List<LetterCombinationRule> combinations;
  final String assetPath;

  factory CombinationsJsonLesson.fromJson(
    Map<String, dynamic> json, {
    required String assetPath,
  }) {
    final explanationsRaw = (json['explanition'] ?? json['explanation']);
    final combinationsRaw = json['combinations'];
    final legacyLevel = json['level']?.toString() ?? '';
    return CombinationsJsonLesson(
      id: json['id']?.toString() ?? '',
      levelEn: json['level_en']?.toString() ?? legacyLevel,
      levelFa: json['level_fa']?.toString() ?? legacyLevel,
      levelDe: json['level_de']?.toString() ?? legacyLevel,
      titleDe: json['title_de']?.toString() ?? '',
      titleFa: json['title_fa']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      explanations: explanationsRaw is List
          ? explanationsRaw
              .whereType<Map<String, dynamic>>()
              .map(CombinationsLessonExplanation.fromJson)
              .toList()
          : const [],
      combinations: combinationsRaw is List
          ? combinationsRaw
              .whereType<Map<String, dynamic>>()
              .map(LetterCombinationRule.fromJson)
              .toList()
          : const [],
      assetPath: assetPath,
    );
  }
}

