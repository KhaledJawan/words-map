class VocabWord {
  final String id;
  final String de; // Original German word
  final String translationEn;
  final String translationFa;
  final String? example;
  final String audio;
  final String image;
  final String? category;
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
    this.example,
    this.audio = '',
    required this.image,
    this.category,
    this.level,
    this.isVisited = false,
    this.isBookmarked = false,
  });

  factory VocabWord.fromJson(Map<String, dynamic> json) {
    return VocabWord(
      id: json['id']?.toString() ?? '',
      de: json['word'] ?? '',
      translationEn: json['translation_en'] ?? '',
      translationFa: json['translation_fa'] ?? '',
      example: json['example'] as String?,
      audio: json['audio']?.toString() ?? '',
      image: json['image'] ?? '',
      category: json['category'] as String?,
      level: json['level'] as String?,
    );
  }

  // Legacy getters for older call sites
  String get word => de;
  String get translation_en => translationEn;
  String get translation_fa => translationFa;
}
