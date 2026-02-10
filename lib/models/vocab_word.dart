import 'package:word_map_app/models/app_language.dart';

class VocabWord {
  final String id;
  final Map<String, String> words;
  final Map<String, String> examples;
  final Map<String, String> audios;
  final String image;
  final List<String> category;
  final String? level;

  bool isVisited;
  bool isBookmarked;
  bool get isViewed => isVisited;
  set isViewed(bool value) => isVisited = value;

  VocabWord({
    required this.id,
    required String de,
    required String translationEn,
    String translationFr = '',
    required String translationFa,
    String translationPs = '',
    String translationTr = '',
    Map<String, String>? words,
    String? example,
    String audio = '',
    Map<String, String>? examples,
    Map<String, String>? audios,
    required this.image,
    this.category = const [],
    this.level,
    this.isVisited = false,
    this.isBookmarked = false,
  }) : words = _normalizeWords({
         'de': de,
         'en': translationEn,
         'fr': translationFr,
         'fa': translationFa,
         'ps': translationPs,
         'tr': translationTr,
         ...?words,
       }),
       examples = _normalizeWords({'de': example ?? '', ...?examples}),
       audios = _normalizeWords({'de': audio, ...?audios});

  factory VocabWord.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final category = switch (rawCategory) {
      final List list =>
        list
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList(),
      final String s when s.trim().isNotEmpty => [s.trim()],
      _ => <String>[],
    };

    final wordsFromJson = <String, String>{};
    final rawWords = json['words'];
    if (rawWords is Map) {
      rawWords.forEach((key, value) {
        final langCode = key.toString().trim().toLowerCase();
        final text = value?.toString() ?? '';
        if (langCode.isNotEmpty && text.trim().isNotEmpty) {
          wordsFromJson[langCode] = text.trim();
        }
      });
    }

    void addIfPresent(String langCode, dynamic value) {
      if (wordsFromJson[langCode]?.trim().isNotEmpty == true) return;
      final text = value?.toString() ?? '';
      if (text.trim().isNotEmpty) {
        wordsFromJson[langCode] = text.trim();
      }
    }

    addIfPresent('de', json['word']);
    addIfPresent('en', json['translation_en']);
    addIfPresent('fr', json['translation_fr']);
    addIfPresent('fa', json['translation_fa']);
    addIfPresent('ps', json['translation_ps']);
    addIfPresent('tr', json['translation_tr']);
    addIfPresent('de', json['de']);
    addIfPresent('en', json['en']);
    addIfPresent('fr', json['fr']);
    addIfPresent('fa', json['fa']);
    addIfPresent('ps', json['ps']);
    addIfPresent('tr', json['tr']);

    final examplesFromJson = <String, String>{};
    final rawExamples = json['examples'];
    if (rawExamples is Map) {
      rawExamples.forEach((key, value) {
        final langCode = key.toString().trim().toLowerCase();
        final text = value?.toString() ?? '';
        if (langCode.isNotEmpty && text.trim().isNotEmpty) {
          examplesFromJson[langCode] = text.trim();
        }
      });
    }
    if ((json['example']?.toString().trim().isNotEmpty ?? false) &&
        (examplesFromJson['de']?.trim().isNotEmpty ?? false) == false) {
      examplesFromJson['de'] = json['example'].toString().trim();
    }

    final audiosFromJson = <String, String>{};
    final rawAudios = json['audios'];
    if (rawAudios is Map) {
      rawAudios.forEach((key, value) {
        final langCode = key.toString().trim().toLowerCase();
        final text = value?.toString() ?? '';
        if (langCode.isNotEmpty && text.trim().isNotEmpty) {
          audiosFromJson[langCode] = text.trim();
        }
      });
    }
    if ((json['audio']?.toString().trim().isNotEmpty ?? false) &&
        (audiosFromJson['de']?.trim().isNotEmpty ?? false) == false) {
      audiosFromJson['de'] = json['audio'].toString().trim();
    }

    return VocabWord(
      id: json['id']?.toString() ?? '',
      de: wordsFromJson['de'] ?? '',
      translationEn: wordsFromJson['en'] ?? '',
      translationFr: wordsFromJson['fr'] ?? '',
      translationFa: wordsFromJson['fa'] ?? '',
      translationPs: wordsFromJson['ps'] ?? '',
      translationTr: wordsFromJson['tr'] ?? '',
      words: wordsFromJson,
      examples: examplesFromJson,
      audios: audiosFromJson,
      example: examplesFromJson['de'],
      audio: audiosFromJson['de'] ?? '',
      image: json['image']?.toString() ?? '',
      category: category,
      level: json['level'] as String?,
    );
  }

  static Map<String, String> _normalizeWords(Map<String, String> input) {
    final out = <String, String>{};
    input.forEach((key, value) {
      final code = key.trim().toLowerCase();
      final text = value.trim();
      if (code.isEmpty || text.isEmpty) return;
      out[code] = text;
    });
    return out;
  }

  String textFor(AppLanguage language) => textForCode(language.languageCode);

  String textForCode(String languageCode) {
    return words[languageCode.trim().toLowerCase()] ?? '';
  }

  String exampleFor(AppLanguage language) =>
      examples[language.languageCode] ?? '';

  String exampleForCode(String languageCode) {
    return examples[languageCode.trim().toLowerCase()] ?? '';
  }

  String audioFor(AppLanguage language) => audios[language.languageCode] ?? '';

  String audioForCode(String languageCode) {
    return audios[languageCode.trim().toLowerCase()] ?? '';
  }

  String bestAudioFor(
    AppLanguage primary, {
    List<AppLanguage> fallbackOrder = const [
      AppLanguage.de,
      AppLanguage.en,
      AppLanguage.fr,
      AppLanguage.tr,
      AppLanguage.fa,
      AppLanguage.ps,
    ],
  }) {
    final direct = audioFor(primary).trim();
    if (direct.isNotEmpty) return direct;

    for (final language in fallbackOrder) {
      if (language == primary) continue;
      final candidate = audioFor(language).trim();
      if (candidate.isNotEmpty) return candidate;
    }

    for (final value in audios.values) {
      final candidate = value.trim();
      if (candidate.isNotEmpty) return candidate;
    }

    return '';
  }

  String firstAvailableText(List<AppLanguage> preferred) {
    for (final language in preferred) {
      final value = textFor(language).trim();
      if (value.isNotEmpty) return value;
    }
    for (final value in words.values) {
      final text = value.trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String? get categoryLabel {
    if (category.isEmpty) return null;
    const max = 2;
    return category.take(max).join(', ');
  }

  String translationFor(AppLanguage language) => textFor(language);

  // Legacy getters for older call sites
  // ignore: non_constant_identifier_names
  String get word => de;
  String get de => textFor(AppLanguage.de);
  String get translationEn => textFor(AppLanguage.en);
  String get translationFr => textFor(AppLanguage.fr);
  String get translationFa => textFor(AppLanguage.fa);
  String get translationPs => textFor(AppLanguage.ps);
  String get translationTr => textFor(AppLanguage.tr);
  String? get example {
    final value = exampleFor(AppLanguage.de).trim();
    return value.isEmpty ? null : value;
  }

  String get audio => audioFor(AppLanguage.de);
  // ignore: non_constant_identifier_names
  String get translation_en => translationEn;
  // ignore: non_constant_identifier_names
  String get translation_fr => translationFr;
  // ignore: non_constant_identifier_names
  String get translation_fa => translationFa;
  // ignore: non_constant_identifier_names
  String get translation_tr => translationTr;
}
