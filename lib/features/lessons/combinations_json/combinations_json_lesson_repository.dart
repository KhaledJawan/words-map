import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:word_map_app/features/lessons/combinations_json/combinations_json_lesson_models.dart';

abstract class CombinationsJsonLessonRepository {
  Future<CombinationsJsonLesson> loadLesson();
}

class AssetCombinationsJsonLessonRepository
    implements CombinationsJsonLessonRepository {
  AssetCombinationsJsonLessonRepository({
    required this.assetPath,
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  final String assetPath;
  final AssetBundle _bundle;

  @override
  Future<CombinationsJsonLesson> loadLesson() async {
    try {
      final content = await _bundle.loadString(assetPath);
      final decoded = jsonDecode(content);
      final data = _extractJsonObject(decoded);
      if (data == null) {
        throw const FormatException('Combinations lesson JSON must be an object');
      }
      return CombinationsJsonLesson.fromJson(data, assetPath: assetPath);
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('Failed to load combinations lesson $assetPath: $error');
        debugPrint('$stack');
      }
      rethrow;
    }
  }

  Map<String, dynamic>? _extractJsonObject(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final nestedCombinations = decoded['combinations'];
      if (nestedCombinations is Map<String, dynamic>) {
        return nestedCombinations;
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
