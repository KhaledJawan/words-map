import 'package:flutter/material.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/models/word_progress.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/services/progress_repository.dart';
import 'package:word_map_app/services/vocab_loader.dart';
import 'package:word_map_app/version_checker.dart';

class WordsInitBundle {
  final List<VocabWord> allWords;
  final Map<String, WordProgress> progress;
  final String lastLevel;
  final String? lastScope;
  final String? lastCategoryTag;
  final List<String> levels;
  final ProgressRepository repo;

  WordsInitBundle({
    required this.allWords,
    required this.progress,
    required this.lastLevel,
    required this.lastScope,
    required this.lastCategoryTag,
    required this.levels,
    required this.repo,
  });
}

Future<WordsInitBundle> loadWordsInit(
  AppState appState,
  BuildContext context,
) async {
  final repo = ProgressRepository();
  final levelToAssetPath = await loadWordLevelAssetPaths(
    preferredOrder: appState.levels,
  );
  final levels = levelToAssetPath.keys.toList(growable: false);
  final progress = await repo.loadProgress();
  final preferredLastLevel =
      await repo.loadLastLevel() ?? appState.currentLevel;
  final lastLevel = levels.contains(preferredLastLevel)
      ? preferredLastLevel
      : levels.first;
  final lastScope = await repo.loadLastWordsScope();
  final lastCategoryTag = await repo.loadLastCategoryTag();

  final List<VocabWord> allWords = [];
  for (final level in levels) {
    final words = await loadWordsForLevel(
      level,
      levelToAssetPath: levelToAssetPath,
    );
    for (final w in words) {
      final p = progress[w.id];
      if (p != null) {
        w.isBookmarked = p.bookmarked;
        w.isViewed = p.learned;
      } else {
        w.isBookmarked = appState.isBookmarked(w);
        w.isViewed = appState.isViewed(w);
      }
    }
    allWords.addAll(words);
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    VersionChecker.checkForUpdate(context);
  });

  return WordsInitBundle(
    allWords: allWords,
    progress: progress,
    lastLevel: lastLevel,
    lastScope: lastScope,
    lastCategoryTag: lastCategoryTag,
    levels: levels,
    repo: repo,
  );
}
