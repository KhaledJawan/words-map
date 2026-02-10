import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vocab_word.dart';

const String _wordsAssetPrefix = 'assets/words/';
const Map<String, String> _fallbackFileMap = {
  'A1.1': 'assets/words/a1_1.json',
  'A1.2': 'assets/words/a1_2.json',
  'A2.1': 'assets/words/a2_1.json',
  'A2.2': 'assets/words/a2_2.json',
  'B1.1': 'assets/words/b1_1.json',
  'B1.2': 'assets/words/b1_2.json',
  'B2.1': 'assets/words/b2_1.json',
  'B2.2': 'assets/words/b2_2.json',
};

String? _levelFromWordFileName(String fileName) {
  final match = RegExp(
    r'^([a-z])(\d)_([0-9]+)\.json$',
    caseSensitive: false,
  ).firstMatch(fileName);
  if (match == null) return null;
  final band = match.group(1)!.toUpperCase();
  final major = match.group(2)!;
  final minor = match.group(3)!;
  return '$band$major.$minor';
}

Map<String, String> _sortLevelMap(
  Map<String, String> discovered,
  List<String> preferredOrder,
) {
  final sorted = <String, String>{};
  for (final level in preferredOrder) {
    final path = discovered[level];
    if (path != null) {
      sorted[level] = path;
    }
  }

  final remaining =
      discovered.keys.where((level) => !sorted.containsKey(level)).toList()
        ..sort();
  for (final level in remaining) {
    sorted[level] = discovered[level]!;
  }
  return sorted;
}

Future<Map<String, String>> loadWordLevelAssetPaths({
  List<String> preferredOrder = const [
    'A1.1',
    'A1.2',
    'A2.1',
    'A2.2',
    'B1.1',
    'B1.2',
    'B2.1',
    'B2.2',
  ],
}) async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final discovered = <String, String>{};
    for (final path in manifest.listAssets()) {
      if (!path.startsWith(_wordsAssetPrefix) || !path.endsWith('.json')) {
        continue;
      }

      final fileName = path.substring(_wordsAssetPrefix.length);
      if (fileName.contains('/')) continue;
      final level = _levelFromWordFileName(fileName);
      if (level == null) continue;
      discovered[level] = path;
    }

    if (discovered.isEmpty) return _fallbackFileMap;
    return _sortLevelMap(discovered, preferredOrder);
  } catch (_) {
    return _fallbackFileMap;
  }
}

Future<List<VocabWord>> loadWordsForLevel(
  String level, {
  Map<String, String>? levelToAssetPath,
}) async {
  final fileMap = levelToAssetPath ?? await loadWordLevelAssetPaths();
  final fallbackPath = fileMap.isNotEmpty
      ? fileMap.values.first
      : _fallbackFileMap['A1.1']!;
  final path = fileMap[level] ?? fallbackPath;
  final jsonStr = await rootBundle.loadString(path);
  final List<dynamic> decoded = json.decode(jsonStr) as List<dynamic>;

  return decoded
      .map((item) => VocabWord.fromJson(item as Map<String, dynamic>))
      .toList();
}
