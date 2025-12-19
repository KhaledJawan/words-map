import 'package:word_map_app/models/app_language.dart';

class VocabWord {
  final String id;
  final String de; // Original German word
  final String translationEn;
  final String translationFa;
  final String translationPs;
  final String? example;
  final String audio;
  final String image;
  final List<String> category;
  final String? level;

  bool isVisited;
  bool isBookmarked;
  bool get isViewed => isVisited;
  set isViewed(bool value) => isVisited = value;

  VocabWord({
    required this.id,
    required this.de,
    required this.translationEn,
    required this.translationFa,
    this.translationPs = '',
    this.example,
    this.audio = '',
    required this.image,
    this.category = const [],
    this.level,
    this.isVisited = false,
    this.isBookmarked = false,
  });

  factory VocabWord.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final category = switch (rawCategory) {
      final List list => list.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList(),
      final String s when s.trim().isNotEmpty => [s.trim()],
      _ => <String>[],
    };
    return VocabWord(
      id: json['id']?.toString() ?? '',
      de: json['word'] ?? '',
      translationEn: json['translation_en'] ?? '',
      translationFa: json['translation_fa'] ?? '',
      translationPs: json['translation_ps']?.toString() ?? '',
      example: json['example'] as String?,
      audio: json['audio']?.toString() ?? '',
      image: json['image'] ?? '',
      category: category,
      level: json['level'] as String?,
    );
  }

  String? get categoryLabel {
    if (category.isEmpty) return null;
    const max = 2;
    return category.take(max).join(', ');
  }

  String translationFor(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return translationEn;
      case AppLanguage.fa:
        return translationFa;
      case AppLanguage.ps:
        return translationPs;
    }
  }

  // Legacy getters for older call sites
  // ignore: non_constant_identifier_names
  String get word => de;
  // ignore: non_constant_identifier_names
  String get translation_en => translationEn;
  // ignore: non_constant_identifier_names
  String get translation_fa => translationFa;
}
