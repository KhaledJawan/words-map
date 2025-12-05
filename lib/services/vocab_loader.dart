import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vocab_word.dart';

Future<List<VocabWord>> loadWordsForLevel(String level) async {
  const fileMap = {
    'A1.1': 'assets/words/a1_1.json',
    'A1.2': 'assets/words/a1_2.json',
    'A2.1': 'assets/words/a2_1.json',
    'A2.2': 'assets/words/a2_2.json',
    'B1.1': 'assets/words/b1_1.json',
    'B1.2': 'assets/words/b1_2.json',
    'B2.1': 'assets/words/b2_1.json',
    'B2.2': 'assets/words/b2_2.json',
  };

  final path = fileMap[level] ?? fileMap['A1.1']!;
  final jsonStr = await rootBundle.loadString(path);
  final List<dynamic> decoded = json.decode(jsonStr) as List<dynamic>;

  return decoded
      .map((item) => VocabWord.fromJson(item as Map<String, dynamic>))
      .toList();
}
