import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:word_map_app/features/grammar/grammar_models.dart';

abstract class GrammarRepository {
  Future<List<GrammarCategory>> loadCategories();
}

class AssetGrammarRepository implements GrammarRepository {
  AssetGrammarRepository([AssetBundle? bundle]) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  @override
  Future<List<GrammarCategory>> loadCategories() async {
    final catalogContent = await _bundle.loadString('assets/lessons/grammar/catalog.json');
    final catalogData = jsonDecode(catalogContent) as List<dynamic>;
    final categories = <GrammarCategory>[];
    for (final rawCategory in catalogData) {
      if (rawCategory is! Map<String, dynamic>) continue;
      final folderValue = rawCategory['id'];
      if (folderValue is! String) continue;
      final folder = folderValue;
      final title = rawCategory['title']?.toString() ?? '';
      final topics = <GrammarTopic>[];
      final topicFiles = (rawCategory['topics'] as List<dynamic>?) ?? [];
      for (final fileEntry in topicFiles) {
        final fileName = fileEntry?.toString();
        if (fileName == null) continue;
        final assetPath = 'assets/lessons/grammar/$folder/$fileName';
        final topic = await _loadTopic(assetPath);
        if (topic != null) {
          topics.add(topic);
        }
      }
      categories.add(GrammarCategory(id: folder, title: title, folder: folder, topics: topics));
    }
    return categories;
  }

  Future<GrammarTopic> _loadTopic(String assetPath) async {
    try {
      final content = await _bundle.loadString(assetPath);
      final data = content.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(content) as Map<String, dynamic>;
      final fileName = assetPath.split('/').last;
      final slug = _stripPrefix(fileName.replaceAll('.json', ''));
      final fallbackTitle = _humanizeName(slug);
      final examples = _parseExamples(data['examples']);
      return GrammarTopic(
        id: data['id']?.toString() ?? slug,
        titleEn: data['title_en']?.toString() ?? fallbackTitle,
        titleFa: data['title_fa']?.toString() ?? '',
        titleDe: data['title_de']?.toString() ?? fallbackTitle,
        level: data['level']?.toString() ?? '',
        descriptionEn: data['description_en']?.toString() ?? '',
        descriptionFa: data['description_fa']?.toString() ?? '',
        descriptionDe: data['description_de']?.toString() ?? '',
        examples: examples,
        assetPath: assetPath,
      );
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('Failed to parse grammar topic $assetPath: $error');
        debugPrint('$stack');
      }
      final fileName = assetPath.split('/').last;
      final slug = _stripPrefix(fileName.replaceAll('.json', ''));
      final fallbackTitle = _humanizeName(slug);
      return GrammarTopic(
        id: slug,
        titleEn: fallbackTitle,
        titleFa: '',
        titleDe: fallbackTitle,
        level: '',
        descriptionEn: '',
        descriptionFa: '',
        descriptionDe: '',
        examples: const [],
        assetPath: assetPath,
      );
    }
  }

  static List<GrammarExample> _parseExamples(dynamic raw) {
    if (raw is Iterable) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((row) => GrammarExample(
                de: row['de']?.toString() ?? '',
                fa: row['fa']?.toString() ?? '',
              ))
          .toList();
    }
    return const [];
  }
}

String _stripPrefix(String value) {
  return value.replaceFirst(RegExp(r'^\d+-'), '');
}

String _humanizeName(String value) {
  final parts = value.replaceAll('_', '-').split('-');
  final words = parts
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .toList();
  return words.join(' ').trim();
}
