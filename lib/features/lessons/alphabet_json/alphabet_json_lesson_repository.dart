import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:word_map_app/features/lessons/alphabet_json/alphabet_json_lesson_models.dart';

abstract class AlphabetJsonLessonRepository {
  Future<AlphabetJsonLesson> loadLesson();
}

class AssetAlphabetJsonLessonRepository implements AlphabetJsonLessonRepository {
  AssetAlphabetJsonLessonRepository({
    required this.assetPath,
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  final String assetPath;
  final AssetBundle _bundle;

  @override
  Future<AlphabetJsonLesson> loadLesson() async {
    try {
      final content = await _bundle.loadString(assetPath);
      final decoded = jsonDecode(content);
      final data = _extractJsonObject(decoded);
      if (data == null) {
        throw const FormatException('Alphabet lesson JSON must be an object');
      }
      return AlphabetJsonLesson.fromJson(data, assetPath: assetPath);
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('Failed to load alphabet lesson $assetPath: $error');
        debugPrint('$stack');
      }
      rethrow;
    }
  }

  Map<String, dynamic>? _extractJsonObject(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final nestedAlphabet = decoded['alphabet'];
      if (nestedAlphabet is Map<String, dynamic>) {
        return nestedAlphabet;
      }
      return decoded;
    }
    if (decoded is List) {
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) return entry;
      }
    }
    return null;
  }
}
