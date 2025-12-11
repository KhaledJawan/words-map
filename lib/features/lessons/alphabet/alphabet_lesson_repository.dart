import 'dart:convert';

import 'package:flutter/services.dart';

import 'alphabet_lesson_item.dart';

abstract class AlphabetLessonRepository {
  Future<List<AlphabetLessonItem>> loadAlphabetLesson();
}

class AssetAlphabetLessonRepository implements AlphabetLessonRepository {
  final String assetPath;

  const AssetAlphabetLessonRepository({
    this.assetPath = 'assets/lessons/beginner-basics/alphabet.json',
  });

  @override
  Future<List<AlphabetLessonItem>> loadAlphabetLesson() async {
    try {
      final asset = await rootBundle.loadString(assetPath);
      final dynamic decoded = jsonDecode(asset);
      if (decoded is List) {
        return decoded
            .cast<Map<String, dynamic>>()
            .map((item) => AlphabetLessonItem.fromJson(item))
            .toList();
      }
      return const [];
    } catch (error, stackTrace) {
      throw AlphabetLessonLoadException(
        'Failed to load alphabet lesson from $assetPath',
        error,
        stackTrace,
      );
    }
  }
}

class AlphabetLessonLoadException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  AlphabetLessonLoadException(this.message, [this.cause, this.stackTrace]);

  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (cause != null) {
      buffer.write(': $cause');
    }
    return buffer.toString();
  }
}
