import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/models/word_progress.dart';
import 'package:word_map_app/core/audio/audio_service.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/screens/words_list_init.dart';
import 'package:word_map_app/services/progress_repository.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/widgets/word_detail_soft_card.dart';
import 'package:word_map_app/widgets/word_tile.dart';

enum SortMode { defaultOrder, priorityGrouped }

List<VocabWord> sortWordsForDisplay(List<VocabWord> words) {
  final bookmarked = <VocabWord>[];
  final normal = <VocabWord>[];
  final viewed = <VocabWord>[];

  for (final w in words) {
    if (w.isBookmarked) {
      bookmarked.add(w);
    } else if (w.isViewed || w.isVisited) {
      viewed.add(w);
    } else {
      normal.add(w);
    }
  }

  return [...bookmarked, ...normal, ...viewed];
}

class WordsListScreen extends StatefulWidget {
  const WordsListScreen({super.key, this.level, this.initialBundle});

  final String? level;
  final WordsInitBundle? initialBundle;

  @override
  State<WordsListScreen> createState() => _WordsListScreenState();
}

class _WordsListScreenState extends State<WordsListScreen> {
  late Future<WordsInitBundle> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.initialBundle != null
        ? Future.value(widget.initialBundle)
        : loadWordsInit(Provider.of<AppState>(context, listen: false), context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    return FutureBuilder<WordsInitBundle>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                loc.loadWordsFailed,
                style: textTheme.titleMedium,
              ),
            ),
          );
        }
        final data = snapshot.data!;
        return Scaffold(
          body: WordsHomeTab(
            allWords: data.allWords,
            initialProgress: data.progress,
            initialLevel: data.lastLevel,
            levels: data.levels,
            repo: data.repo,
          ),
        );
      },
    );
  }
}

class WordsHomeTab extends StatefulWidget {
  const WordsHomeTab({
    super.key,
    required this.allWords,
    required this.initialProgress,
    required this.initialLevel,
    required this.levels,
    required this.repo,
  });

  final List<VocabWord> allWords;
  final Map<String, WordProgress> initialProgress;
  final String initialLevel;
  final List<String> levels;
  final ProgressRepository repo;

  @override
  State<WordsHomeTab> createState() => _WordsHomeTabState();
}

class _WordsHomeTabState extends State<WordsHomeTab> {
  late Map<String, WordProgress> _progress;
  late Map<String, List<VocabWord>> _wordsByLevel;
  late String _currentLevel;
  List<VocabWord> _visibleWords = [];
  final SortMode _sortMode = SortMode.defaultOrder;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _progress = Map.of(widget.initialProgress);
    _wordsByLevel = _groupByLevel(widget.allWords);
    _currentLevel =
        widget.initialLevel.isNotEmpty ? widget.initialLevel : widget.levels.first;
    _setVisibleForLevel(_currentLevel, forceSort: true);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Map<String, List<VocabWord>> _groupByLevel(List<VocabWord> words) {
    final Map<String, List<VocabWord>> grouped = {};
    for (final w in words) {
      final level = w.level ?? 'unknown';
      grouped.putIfAbsent(level, () => []);
      grouped[level]!.add(w);
    }
    return grouped;
  }

  void _setVisibleForLevel(String level, {bool forceSort = false}) {
    final list = _wordsByLevel[level] ?? [];
    _visibleWords = List.of(list);
    _applySort(forcePriority: forceSort);
  }

  void _applySort({bool forcePriority = false}) {
    if (forcePriority || _sortMode == SortMode.priorityGrouped) {
      _visibleWords = sortWordsForDisplay(_visibleWords);
    }
    setState(() {});
  }

  void _changeLevel(String level) {
    if (level == _currentLevel) return;
    setState(() {
      _currentLevel = level;
      _setVisibleForLevel(level, forceSort: true);
    });
    widget.repo.saveLastLevel(level);
  }

  void _toggleBookmark(VocabWord word) {
    setState(() {
      word.isBookmarked = !word.isBookmarked;
      final existing = _progress[word.id];
      _progress[word.id] = (existing ?? WordProgress(wordId: word.id))
          .copyWith(bookmarked: word.isBookmarked);
    });
    _debouncedSave();
  }

  void _markLearned(VocabWord word) {
    if (word.isViewed) return;
    setState(() {
      word.isViewed = true;
      final existing = _progress[word.id];
      _progress[word.id] = (existing ?? WordProgress(wordId: word.id))
          .copyWith(learned: true);
    });
    _debouncedSave();
  }

  void _debouncedSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      widget.repo.saveProgress(_progress);
    });
  }

  Future<void> _refreshAll() async {
    _setVisibleForLevel(_currentLevel, forceSort: true);
  }

  Future<void> _showCountsSheet(BuildContext context) async {
    final levelWords = _wordsByLevel[_currentLevel] ?? [];
    final total = levelWords.length;
    final viewed = levelWords.where((w) => w.isViewed || w.isVisited).length;
    final bookmarked = levelWords.where((w) => w.isBookmarked).length;

    final loc = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.chapterOverview(_currentLevel),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.totalWordsLabel, style: textTheme.bodyMedium),
                    Text('$total', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.bookmarkedLabel, style: textTheme.bodyMedium),
                    Text('$bookmarked', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.viewedLabel, style: textTheme.bodyMedium),
                    Text('$viewed', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onWordTapped(VocabWord word) async {
    _markLearned(word);
    if (!mounted) return;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'word-detail',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        bool bookmarkedLocal = word.isBookmarked;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Builder(
                        builder: (dialogContext) {
                          final localeCode =
                              Localizations.localeOf(dialogContext).languageCode;
                          final fa = word.translationFa;
                          final en = word.translationEn;
                          final primary = localeCode == 'fa'
                              ? (fa.isNotEmpty ? fa : en)
                              : (en.isNotEmpty ? en : fa);
                          final secondary = localeCode == 'fa'
                              ? (en.isNotEmpty ? en : '')
                              : (fa.isNotEmpty ? fa : '');
                          final audioUrl = word.audio.trim();
                          final hasAudio = audioUrl.isNotEmpty;
                          final messenger = ScaffoldMessenger.of(dialogContext);
                          Future<void> handlePlayAudio() async {
                            if (!hasAudio) return;
                            try {
                              await AudioService.instance.playUrl(audioUrl);
                            } catch (e) {
                              debugPrint('Audio playback failed: $e');
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Audio konnte nicht abgespielt werden.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                          final audioAction = SizedBox(
                            height: 28,
                            width: 28,
                            child: StreamBuilder<bool>(
                              stream: AudioService.instance.playingStream,
                              builder: (streamContext, snapshot) {
                                final isPlaying = snapshot.data ?? false;
                                final iconColor = hasAudio
                                    ? Theme.of(streamContext).colorScheme.primary
                                    : Colors.grey[400];
                                final isPlayingThisWord = isPlaying &&
                                    AudioService.instance.currentUrl == audioUrl;
                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 20,
                                  onPressed: hasAudio
                                      ? () async => await handlePlayAudio()
                                      : null,
                                  icon: Icon(
                                    isPlayingThisWord
                                        ? LucideIcons.signalHigh
                                        : LucideIcons.playCircle,
                                    color: iconColor,
                                  ),
                                );
                              },
                            ),
                          );
                          return WordDetailSoftCard(
                            word: word.de,
                            translationPrimary: primary,
                            translationSecondary:
                                secondary.isNotEmpty ? secondary : null,
                            example: word.example,
                            extra: [
                              if (word.level != null) word.level,
                              if (word.category != null) word.category,
                            ].whereType<String>().join(' • '),
                            isBookmarked: bookmarkedLocal,
                            trailingAction: audioAction,
                            onToggleBookmark: () {
                              setSheetState(() {
                                bookmarkedLocal = !bookmarkedLocal;
                              });
                              _toggleBookmark(word);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final appState = context.watch<AppState>();
    final viewedCount =
        _visibleWords.where((w) => w.isViewed || w.isVisited).length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatsBadge(textTheme, viewedCount),
                const Spacer(),
                _buildLevelButton(textTheme, appState),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildWordsTab(textTheme)),
        ],
      ),
    );
  }

  Widget _buildStatsBadge(TextTheme textTheme, int viewedCount) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showCountsSheet(context),
      child: Container(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$viewedCount',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_visibleWords.length}',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: textTheme.bodySmall?.fontSize != null
                    ? textTheme.bodySmall!.fontSize! - 1
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(TextTheme textTheme, AppState appState) {
    return TextButton.icon(
      onPressed: () => _showLevelPicker(context, appState),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(),
        backgroundColor: Colors.black,
        minimumSize: const Size(0, 44),
      ),
      icon: const Icon(LucideIcons.layers, color: Colors.white),
      label: Text(
        _currentLevel,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: (textTheme.titleMedium?.fontSize ?? 16) + 4,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _showLevelPicker(BuildContext context, AppState appState) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
          ),
          child: _LevelGrid(
            levels: widget.levels,
            selectedLevel: _currentLevel,
            onSelect: (level) async {
              Navigator.of(context).pop();
              _changeLevel(level);
            },
          ),
        );
      },
    );
  }

  Widget _buildWordsTab(TextTheme textTheme) {
    final loc = AppLocalizations.of(context)!;
    if (_visibleWords.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 32),
              child: Text(
                loc.chapterEmptyState,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
            sliver: SliverToBoxAdapter(
              child: _WordList(
                words: _visibleWords,
                onTap: _onWordTapped,
                onBookmarkToggle: _toggleBookmark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  const _WordList({
    required this.words,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  final List<VocabWord> words;
  final ValueChanged<VocabWord> onTap;
  final ValueChanged<VocabWord> onBookmarkToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 3,
      textDirection: TextDirection.ltr, // keep tile order stable across locales
      children: List.generate(words.length, (index) {
        final word = words[index];
        return WordTile(
          word: word,
          index: index,
          onTap: () => onTap(word),
          onLongPress: () => onBookmarkToggle(word),
        );
      }),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final List<String> levels;
  final String selectedLevel;
  final ValueChanged<String> onSelect;

  const _LevelGrid({
    required this.levels,
    required this.selectedLevel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.chooseChapter,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: levels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
          ),
          itemBuilder: (context, index) {
            final level = levels[index];
            final isSelected = level == selectedLevel;

            return GestureDetector(
              onTap: () => onSelect(level),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? cs.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ).copyWith(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
