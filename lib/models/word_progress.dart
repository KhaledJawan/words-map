import 'dart:convert';

class WordProgress {
  final String wordId;
  bool learned;
  bool bookmarked;
  int updatedAt;

  WordProgress({
    required this.wordId,
    this.learned = false,
    this.bookmarked = false,
    int? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    return WordProgress(
      wordId: json['wordId'] as String,
      learned: json['learned'] as bool? ?? false,
      bookmarked: json['bookmarked'] as bool? ?? false,
      updatedAt: json['updatedAt'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'learned': learned,
      'bookmarked': bookmarked,
      'updatedAt': updatedAt,
    };
  }

  WordProgress copyWith({
    bool? learned,
    bool? bookmarked,
    int? updatedAt,
  }) {
    return WordProgress(
      wordId: wordId,
      learned: learned ?? this.learned,
      bookmarked: bookmarked ?? this.bookmarked,
      updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  static String encodeMap(Map<String, WordProgress> map) {
    final data = map.map((key, value) => MapEntry(key, value.toJson()));
    return jsonEncode(data);
  }

  static Map<String, WordProgress> decodeMap(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) =>
        MapEntry(key, WordProgress.fromJson(value as Map<String, dynamic>)));
  }
}
