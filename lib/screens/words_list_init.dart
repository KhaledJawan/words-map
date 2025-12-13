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
  final List<String> levels;
  final ProgressRepository repo;

  WordsInitBundle({
    required this.allWords,
    required this.progress,
    required this.lastLevel,
    required this.levels,
    required this.repo,
  });
}

Future<WordsInitBundle> loadWordsInit(
    AppState appState, BuildContext context) async {
  final repo = ProgressRepository();
  final levels = appState.levels;
  final progress = await repo.loadProgress();
  final lastLevel =
      await repo.loadLastLevel() ?? appState.currentLevel;

  final List<VocabWord> allWords = [];
  for (final level in levels) {
    final words = await loadWordsForLevel(level);
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
    levels: levels,
    repo: repo,
  );
}
