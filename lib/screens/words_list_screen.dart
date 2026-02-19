import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/models/app_language.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/models/word_progress.dart';
import 'package:word_map_app/core/audio/audio_service.dart';
import 'package:word_map_app/features/categories/word_category_localization.dart';
import 'package:word_map_app/features/monetization/diamond_controller.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/screens/words_list_init.dart';
import 'package:word_map_app/services/home_support_banner_service.dart';
import 'package:word_map_app/services/progress_repository.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/widgets/home_support_banner.dart';
import 'package:word_map_app/widgets/thank_you_lottie_overlay.dart';
import 'package:word_map_app/widgets/word_detail_soft_card.dart';
import 'package:word_map_app/widgets/word_details_native_ad_footer.dart';
import 'package:word_map_app/widgets/word_tile.dart';

enum SortMode { defaultOrder, priorityGrouped }

enum WordsScope { level, category }

const List<AppLanguage> _wordTextFallbackOrder = [
  AppLanguage.de,
  AppLanguage.en,
  AppLanguage.fr,
  AppLanguage.tr,
  AppLanguage.fa,
  AppLanguage.ps,
];

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

String _resolveWordText(
  VocabWord word,
  AppLanguage primary, {
  List<AppLanguage> fallbackOrder = _wordTextFallbackOrder,
}) {
  final direct = word.textFor(primary).trim();
  if (direct.isNotEmpty) return direct;
  final remaining = fallbackOrder
      .where((lang) => lang != primary)
      .toList(growable: false);
  final fallback = word.firstAvailableText(remaining).trim();
  return fallback.isNotEmpty ? fallback : '—';
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
              child: Text(loc.loadWordsFailed, style: textTheme.titleMedium),
            ),
          );
        }
        final data = snapshot.data!;
        return Scaffold(
          body: WordsHomeTab(
            allWords: data.allWords,
            initialProgress: data.progress,
            initialLevel: data.lastLevel,
            initialScope: data.lastScope,
            initialCategoryTag: data.lastCategoryTag,
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
    required this.initialScope,
    required this.initialCategoryTag,
    required this.levels,
    required this.repo,
  });

  final List<VocabWord> allWords;
  final Map<String, WordProgress> initialProgress;
  final String initialLevel;
  final String? initialScope;
  final String? initialCategoryTag;
  final List<String> levels;
  final ProgressRepository repo;

  @override
  State<WordsHomeTab> createState() => _WordsHomeTabState();
}

class _WordsHomeTabState extends State<WordsHomeTab> {
  late Map<String, WordProgress> _progress;
  late Map<String, List<VocabWord>> _wordsByLevel;
  late Map<String, List<VocabWord>> _wordsByCategory;
  late String _currentLevel;
  WordsScope _scope = WordsScope.level;
  String? _currentCategoryTag;
  List<VocabWord> _visibleWords = [];
  final SortMode _sortMode = SortMode.defaultOrder;
  Timer? _saveDebounce;
  final HomeSupportBannerService _supportBannerService =
      HomeSupportBannerService();
  bool _showSupportBanner = false;
  String? _lastAudioAvailabilityKey;

  @override
  void initState() {
    super.initState();
    _progress = Map.of(widget.initialProgress);
    _wordsByLevel = _groupByLevel(widget.allWords);
    _wordsByCategory = _groupByCategory(widget.allWords);
    _currentLevel = widget.initialLevel.isNotEmpty
        ? widget.initialLevel
        : widget.levels.first;
    final requestedScope = (widget.initialScope ?? '').trim().toLowerCase();
    final requestedCategory = (widget.initialCategoryTag ?? '').trim();
    if (requestedScope == 'category' &&
        requestedCategory.isNotEmpty &&
        _wordsByCategory.containsKey(requestedCategory)) {
      _scope = WordsScope.category;
      _currentCategoryTag = requestedCategory;
      _setVisibleForCategory(requestedCategory, forceSort: true);
    } else {
      _scope = WordsScope.level;
      _setVisibleForLevel(_currentLevel, forceSort: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowSupportBanner();
    });
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

  Map<String, List<VocabWord>> _groupByCategory(List<VocabWord> words) {
    final Map<String, List<VocabWord>> grouped = {};
    for (final w in words) {
      for (final tag in w.category) {
        grouped.putIfAbsent(tag, () => []);
        grouped[tag]!.add(w);
      }
    }
    return grouped;
  }

  void _setVisibleForLevel(String level, {bool forceSort = false}) {
    final list = _wordsByLevel[level] ?? [];
    _visibleWords = List.of(list);
    _applySort(forcePriority: forceSort);
  }

  void _setVisibleForCategory(String tag, {bool forceSort = false}) {
    final list = _wordsByCategory[tag] ?? [];
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
      _scope = WordsScope.level;
      _currentLevel = level;
      _setVisibleForLevel(level, forceSort: true);
    });
    widget.repo.saveLastLevel(level);
    widget.repo.saveLastWordsScope('level');
  }

  void _changeCategory(String tag) {
    if (_scope == WordsScope.category && tag == _currentCategoryTag) return;
    setState(() {
      _scope = WordsScope.category;
      _currentCategoryTag = tag;
      _setVisibleForCategory(tag, forceSort: true);
    });
    widget.repo.saveLastWordsScope('category');
    widget.repo.saveLastCategoryTag(tag);
  }

  void _toggleBookmark(VocabWord word) {
    setState(() {
      word.isBookmarked = !word.isBookmarked;
      final existing = _progress[word.id];
      _progress[word.id] = (existing ?? WordProgress(wordId: word.id)).copyWith(
        bookmarked: word.isBookmarked,
      );
    });
    _debouncedSave();
  }

  void _markLearned(VocabWord word) {
    if (word.isViewed) return;
    setState(() {
      word.isViewed = true;
      final existing = _progress[word.id];
      _progress[word.id] = (existing ?? WordProgress(wordId: word.id)).copyWith(
        learned: true,
      );
    });
    _debouncedSave();
  }

  void _debouncedSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      widget.repo.saveProgress(_progress);
    });
  }

  bool _hasAudioForLanguageInWords(
    Iterable<VocabWord> words,
    AppLanguage language,
  ) {
    return words.any((word) => word.audioFor(language).trim().isNotEmpty);
  }

  String? _firstLevelWithAudio(AppLanguage language) {
    for (final level in widget.levels) {
      final words = _wordsByLevel[level] ?? const <VocabWord>[];
      if (_hasAudioForLanguageInWords(words, language)) {
        return level;
      }
    }
    return null;
  }

  void _ensureCurrentLevelHasAudioFor(
    AppLanguage language, {
    required String switchedMessage,
    required String unavailableMessage,
  }) {
    if (_scope != WordsScope.level) return;

    final currentWords = _wordsByLevel[_currentLevel] ?? const <VocabWord>[];
    if (_hasAudioForLanguageInWords(currentWords, language)) return;

    final replacementLevel = _firstLevelWithAudio(language);
    if (replacementLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(unavailableMessage),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (replacementLevel == _currentLevel) return;

    _changeLevel(replacementLevel);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(switchedMessage), duration: Duration(seconds: 3)),
    );
  }

  Future<void> _maybeShowSupportBanner() async {
    final diamond = context.read<DiamondController>();
    if (!diamond.isRewardedFlowEnabled) return;
    final shouldShow = await _supportBannerService.shouldShow();
    if (!shouldShow || !mounted) return;
    await _supportBannerService.markShown();
    if (!mounted) return;
    setState(() => _showSupportBanner = true);
  }

  Future<void> _handleSupportBannerSupport() async {
    final diamond = context.read<DiamondController>();
    if (!diamond.isRewardedFlowEnabled) return;
    final loc = AppLocalizations.of(context)!;
    final result = await diamond.watchAdForDiamond();
    if (!mounted) return;
    if (result == DiamondWatchResult.adLoading) {
      if (diamond.counter <= 0 &&
          !diamond.isDiamondActive &&
          !diamond.isCooldownActive) {
        unawaited(diamond.startCooldown());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.adLoading), duration: Duration(seconds: 2)),
      );
      return;
    }
    if (result == DiamondWatchResult.activated) {
      await ThankYouLottieOverlay.show(context);
    }
  }

  Future<void> _refreshAll() async {
    if (_scope == WordsScope.category && _currentCategoryTag != null) {
      _setVisibleForCategory(_currentCategoryTag!, forceSort: true);
      return;
    }
    _setVisibleForLevel(_currentLevel, forceSort: true);
  }

  Future<void> _showCountsSheet(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final scopeLabel = _scope == WordsScope.level
        ? _currentLevel
        : localizeWordCategoryTag(loc, _currentCategoryTag ?? 'uncategorized');
    final scopeWords = _visibleWords;
    final total = scopeWords.length;
    final viewed = scopeWords.where((w) => w.isViewed || w.isVisited).length;
    final bookmarked = scopeWords.where((w) => w.isBookmarked).length;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _scope == WordsScope.level
                      ? loc.chapterOverview(_currentLevel)
                      : loc.categoryOverview(scopeLabel),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.totalWordsLabel, style: textTheme.bodyMedium),
                    Text(
                      '$total',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.bookmarkedLabel, style: textTheme.bodyMedium),
                    Text(
                      '$bookmarked',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.viewedLabel, style: textTheme.bodyMedium),
                    Text(
                      '$viewed',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxHeight = constraints.maxHeight * 0.82;
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 560,
                              maxHeight: maxHeight,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const WordDetailsNativeAdFooter(),
                                const SizedBox(height: 12),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Builder(
                                      builder: (dialogContext) {
                                        final appState = dialogContext
                                            .read<AppState>();
                                        final sourceLang =
                                            appState.sourceWordLanguage;
                                        final targetLang =
                                            appState.targetWordLanguage;
                                        final source = _resolveWordText(
                                          word,
                                          sourceLang,
                                        );
                                        var target = _resolveWordText(
                                          word,
                                          targetLang,
                                        );
                                        if (target == source) {
                                          target = word
                                              .firstAvailableText(
                                                _wordTextFallbackOrder
                                                    .where(
                                                      (lang) =>
                                                          lang != sourceLang,
                                                    )
                                                    .toList(),
                                              )
                                              .trim();
                                          if (target.isEmpty) {
                                            target = '—';
                                          }
                                        }
                                        final audioUrl = word
                                            .audioFor(sourceLang)
                                            .trim();
                                        final exampleText = word
                                            .exampleFor(sourceLang)
                                            .trim();
                                        final hasAudio = audioUrl.isNotEmpty;
                                        final messenger = ScaffoldMessenger.of(
                                          dialogContext,
                                        );
                                        final loc = AppLocalizations.of(
                                          dialogContext,
                                        )!;
                                        Future<void> handlePlayAudio() async {
                                          if (!hasAudio) return;
                                          try {
                                            await AudioService.instance.playUrl(
                                              audioUrl,
                                            );
                                          } catch (e) {
                                            debugPrint(
                                              'Audio playback failed: $e',
                                            );
                                            if (!mounted) return;
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  loc.audioPlaybackFailed,
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        }

                                        final audioAction = SizedBox(
                                          height: 28,
                                          width: 28,
                                          child: StreamBuilder<bool>(
                                            stream: AudioService
                                                .instance
                                                .playingStream,
                                            builder: (streamContext, snapshot) {
                                              final isPlaying =
                                                  snapshot.data ?? false;
                                              final iconColor = hasAudio
                                                  ? Theme.of(
                                                      streamContext,
                                                    ).colorScheme.primary
                                                  : Colors.grey[400];
                                              final isPlayingThisWord =
                                                  isPlaying &&
                                                  AudioService
                                                          .instance
                                                          .currentUrl ==
                                                      audioUrl;
                                              return IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                iconSize: 20,
                                                onPressed: hasAudio
                                                    ? () async =>
                                                          await handlePlayAudio()
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
                                          word: source,
                                          translationPrimary: target,
                                          translationSecondary: null,
                                          example: exampleText.isNotEmpty
                                              ? exampleText
                                              : null,
                                          extra: [
                                            if (word.level != null) word.level,
                                            formatCategoryLabel(
                                              AppLocalizations.of(
                                                dialogContext,
                                              )!,
                                              word.category,
                                              max: 2,
                                            ),
                                          ].whereType<String>().join(' • '),
                                          isBookmarked: bookmarkedLocal,
                                          trailingAction: audioAction,
                                          onToggleBookmark: () {
                                            setSheetState(() {
                                              bookmarkedLocal =
                                                  !bookmarkedLocal;
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
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Future<void> _handleWordTap(VocabWord word) async {
    final diamond = context.read<DiamondController>();
    final loc = AppLocalizations.of(context)!;
    if (!diamond.isWordLimitEnabled) {
      await _onWordTapped(word);
      return;
    }
    if (diamond.isCooldownActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.cooldownActive(diamond.cooldownText())),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final allowed = diamond.onWordSelected();
    if (!allowed) {
      final shouldWatch = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(loc.noMoreWordsTitle),
            content: Text(loc.noMoreWordsBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(loc.noMoreWordsWaitOneHour),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(loc.noMoreWordsWatchAd),
              ),
            ],
          );
        },
      );
      if (!mounted) return;
      if (shouldWatch == true) {
        final result = await diamond.watchAdForDiamond();
        if (!mounted) return;
        if (result == DiamondWatchResult.adLoading) {
          unawaited(diamond.startCooldown());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.adLoading),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        if (result == DiamondWatchResult.activated) {
          await ThankYouLottieOverlay.show(context);
          if (!mounted) return;
          await _onWordTapped(word);
        }
      } else {
        unawaited(diamond.startCooldown());
      }
      return;
    }

    await _onWordTapped(word);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final appState = context.watch<AppState>();
    final diamond = context.watch<DiamondController>();
    final sourceLanguage = appState.sourceWordLanguage;
    final audioAvailabilityKey =
        '${sourceLanguage.languageCode}|${_scope.name}|$_currentLevel';
    if (_lastAudioAvailabilityKey != audioAvailabilityKey) {
      _lastAudioAvailabilityKey = audioAvailabilityKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ensureCurrentLevelHasAudioFor(
          sourceLanguage,
          switchedMessage:
              'No ${sourceLanguage.nativeName} audio in this level yet. Switched to the next level with audio.',
          unavailableMessage:
              'No ${sourceLanguage.nativeName} audio is available yet for the current vocabulary set.',
        );
      });
    }
    final viewedCount = _visibleWords
        .where((w) => w.isViewed || w.isVisited)
        .length;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 390;
                    final maxButtonWidth = constraints.maxWidth * 0.52;
                    final maxDiamondWidth = constraints.maxWidth * 0.38;
                    final showMonetization = diamond.isWordLimitEnabled;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textDirection: TextDirection.ltr,
                      children: [
                        _buildStatsBadge(textTheme, viewedCount),
                        if (showMonetization) const SizedBox(width: 10),
                        if (showMonetization)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxDiamondWidth,
                            ),
                            child: _buildDiamondBadge(
                              textTheme,
                              diamond,
                              compact: isNarrow,
                            ),
                          ),
                        if (showMonetization) const SizedBox(width: 10),
                        const Spacer(),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxButtonWidth),
                          child: _buildLevelButton(
                            textTheme,
                            appState,
                            maxButtonWidth: maxButtonWidth,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildWordsTab(textTheme)),
            ],
          ),
          if (_showSupportBanner && diamond.isRewardedFlowEnabled)
            Positioned(
              left: 16,
              right: 80,
              bottom: 16,
              child: HomeSupportBanner(
                onSupport: _handleSupportBannerSupport,
                onDismissed: () {
                  if (!mounted) return;
                  setState(() => _showSupportBanner = false);
                },
              ),
            ),
          if (diamond.isRewardedFlowEnabled)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await diamond.watchAdForDiamond();
                  if (!context.mounted) return;
                  final loc = AppLocalizations.of(context)!;
                  if (result == DiamondWatchResult.adLoading) {
                    if (diamond.counter <= 0 &&
                        !diamond.isDiamondActive &&
                        !diamond.isCooldownActive) {
                      unawaited(diamond.startCooldown());
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.adLoading),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  if (result == DiamondWatchResult.activated) {
                    await ThankYouLottieOverlay.show(context);
                  }
                },
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                child: const Icon(LucideIcons.gem),
              ),
            ),
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
        decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
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

  Widget _buildLevelButton(
    TextTheme textTheme,
    AppState appState, {
    required double maxButtonWidth,
  }) {
    final loc = AppLocalizations.of(context)!;
    final uiTextDirection = Directionality.of(context);
    final label = _scope == WordsScope.level
        ? _currentLevel
        : localizeWordCategoryTag(loc, _currentCategoryTag ?? 'uncategorized');
    final baseFontSize = textTheme.titleMedium?.fontSize ?? 16;
    final fontSize = _scope == WordsScope.level
        ? baseFontSize + 4
        : baseFontSize + 1;
    final maxTextWidth = (maxButtonWidth - 48)
        .clamp(80.0, maxButtonWidth)
        .toDouble();
    return TextButton(
      onPressed: () => _showLevelPicker(context, appState),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: _scope == WordsScope.level ? 12 : 10,
          vertical: 8,
        ),
        shape: const StadiumBorder(),
        backgroundColor: Colors.black,
        minimumSize: const Size(0, 44),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxButtonWidth),
        child: Row(
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _scope == WordsScope.level ? LucideIcons.layers : LucideIcons.tag,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textDirection: uiTextDirection,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiamondBadge(
    TextTheme textTheme,
    DiamondController diamond, {
    bool compact = false,
  }) {
    final loc = AppLocalizations.of(context)!;
    final isActive = diamond.isDiamondActive;
    final isCooldown = diamond.isCooldownActive;
    final label = isActive
        ? diamond.remainingText()
        : (isCooldown ? diamond.cooldownText() : '${diamond.counter}');
    final subtitle = isActive
        ? loc.diamondBadgeSubtitleActive
        : (isCooldown
              ? loc.diamondBadgeSubtitleCooldown
              : loc.diamondBadgeSubtitleInactive);
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.gem,
            size: 18,
            color: isActive
                ? const Color(0xFF4BA8FF)
                : (isCooldown
                      ? Colors.white.withValues(alpha: 0.45)
                      : Colors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: (textTheme.bodySmall?.fontSize ?? 12) - 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWordPairPicker(BuildContext context) async {
    final appState = context.read<AppState>();
    final uiLanguage = appState.appLanguage;
    final allOptions = const <AppLanguage>[
      AppLanguage.de,
      AppLanguage.en,
      AppLanguage.fr,
      AppLanguage.tr,
      AppLanguage.fa,
      AppLanguage.ps,
    ];
    AppLanguage source = appState.sourceWordLanguage;
    AppLanguage target = appState.targetWordLanguage;
    if (target == source) {
      target = allOptions.firstWhere((lang) => lang != source);
    }

    String copy({required String en, required String fa, required String ps}) {
      switch (uiLanguage) {
        case AppLanguage.fa:
          return fa;
        case AppLanguage.ps:
          return ps;
        case AppLanguage.en:
        case AppLanguage.fr:
        case AppLanguage.de:
        case AppLanguage.tr:
          return en;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            List<AppLanguage> targetOptions() =>
                allOptions.where((lang) => lang != source).toList();

            Widget languageDropdown({
              required String label,
              required String hint,
              required AppLanguage value,
              required List<AppLanguage> options,
              required ValueChanged<AppLanguage?> onChanged,
              required IconData icon,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AppLanguage>(
                    key: ValueKey<String>('${label}_${value.languageCode}'),
                    initialValue: value,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronsUpDown),
                    decoration: InputDecoration(
                      hintText: hint,
                      prefixIcon: Icon(icon),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: options
                        .map(
                          (lang) => DropdownMenuItem<AppLanguage>(
                            value: lang,
                            child: Text(lang.nativeName),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: onChanged,
                  ),
                ],
              );
            }

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16,
                      0,
                      16,
                      16 + MediaQuery.of(sheetContext).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.languages,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              copy(
                                en: 'Word Pair',
                                fa: 'جفت واژه',
                                ps: 'د لغت جوړه',
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          copy(
                            en: 'Set your learning and translation languages.',
                            fa: 'زبان یادگیری و زبان ترجمه را انتخاب کنید.',
                            ps: 'د زده کړې ژبه او د ژباړې ژبه وټاکئ.',
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        languageDropdown(
                          label: copy(
                            en: 'Learn In',
                            fa: 'زبان یادگیری',
                            ps: 'د زده کړې ژبه',
                          ),
                          hint: copy(
                            en: 'Language shown on word cards',
                            fa: 'زبان خود واژه‌ها',
                            ps: 'د لغتونو ژبه',
                          ),
                          value: source,
                          options: allOptions,
                          icon: LucideIcons.bookOpen,
                          onChanged: (next) {
                            if (next == null) return;
                            setSheetState(() {
                              source = next;
                              if (target == source) {
                                target = targetOptions().first;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        languageDropdown(
                          label: copy(
                            en: 'Translate To',
                            fa: 'زبان معنی',
                            ps: 'د مانا ژبه',
                          ),
                          hint: copy(
                            en: 'Language used for meanings',
                            fa: 'زبان ترجمه‌ها',
                            ps: 'د ژباړې ژبه',
                          ),
                          value: target,
                          options: targetOptions(),
                          icon: LucideIcons.languages,
                          onChanged: (next) {
                            if (next == null) return;
                            setSheetState(() => target = next);
                          },
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.55),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${source.nativeName}  ->  ${target.nativeName}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                  backgroundColor: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.55),
                                  foregroundColor: theme.colorScheme.onSurface,
                                  shape: const StadiumBorder(),
                                ),
                                child: Text(
                                  copy(en: 'Cancel', fa: 'لغو', ps: 'لغوه'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  await appState.setWordLanguages([
                                    source,
                                    target,
                                  ]);
                                  if (!mounted) return;
                                  _ensureCurrentLevelHasAudioFor(
                                    source,
                                    switchedMessage: copy(
                                      en: 'No ${source.nativeName} audio in this level yet. Switched to the next level with audio.',
                                      fa: 'برای این سطح، صدای ${source.nativeName} وجود ندارد. به نزدیک‌ترین سطح دارای صدا منتقل شد.',
                                      ps: 'په دې کچه کې د ${source.nativeName} غږ نشته. هغه بلې کچې ته ولاړ شو چې غږ لري.',
                                    ),
                                    unavailableMessage: copy(
                                      en: 'No ${source.nativeName} audio is available yet for the current vocabulary set.',
                                      fa: 'هنوز برای واژگان فعلی صدای ${source.nativeName} موجود نیست.',
                                      ps: 'د اوسني لغتونو لپاره لا د ${source.nativeName} غږ نشته.',
                                    ),
                                  );
                                  if (!sheetContext.mounted) return;
                                  Navigator.of(sheetContext).pop();
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                ),
                                icon: const Icon(LucideIcons.check, size: 16),
                                label: Text(
                                  copy(en: 'Apply', fa: 'اعمال', ps: 'پلي کول'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLevelPicker(BuildContext context, AppState appState) async {
    final wordPairTitle = switch (appState.appLanguage) {
      AppLanguage.fa => 'جفت واژه',
      AppLanguage.ps => 'د لغت جوړه',
      AppLanguage.en ||
      AppLanguage.de ||
      AppLanguage.tr ||
      AppLanguage.fr => 'Word Pair',
    };
    final wordPairSubtitle =
        '${appState.sourceWordLanguage.nativeName} -> ${appState.targetWordLanguage.nativeName}';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final loc = AppLocalizations.of(context)!;
        final counts = <String, int>{};
        _wordsByCategory.forEach((tag, words) {
          counts[tag] = words.length;
        });

        final tags = counts.keys.toList()
          ..sort(
            (a, b) => localizeWordCategoryTag(
              loc,
              a,
            ).compareTo(localizeWordCategoryTag(loc, b)),
          );

        return _ChapterPickerSheet(
          levels: widget.levels,
          selectedLevel: _currentLevel,
          selectedScope: _scope,
          selectedCategoryTag: _currentCategoryTag,
          categoryTags: tags,
          categoryCounts: counts,
          wordPairTitle: wordPairTitle,
          wordPairSubtitle: wordPairSubtitle,
          onSelectLevel: (level) {
            Navigator.of(context).pop();
            _changeLevel(level);
          },
          onSelectCategory: (tag) {
            Navigator.of(context).pop();
            _changeCategory(tag);
          },
          onOpenWordPair: () {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              unawaited(_showWordPairPicker(this.context));
            });
          },
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
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 32),
              child: Text(
                _scope == WordsScope.level
                    ? loc.chapterEmptyState
                    : loc.categoryEmptyState,
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
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
            sliver: SliverToBoxAdapter(
              child: _WordList(
                words: _visibleWords,
                onTap: _handleWordTap,
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
    final appState = context.watch<AppState>();
    final sourceLang = appState.sourceWordLanguage;
    final sourceTextDirection = sourceLang.isRtlScript
        ? TextDirection.rtl
        : TextDirection.ltr;
    return Wrap(
      spacing: 8,
      runSpacing: 3,
      textDirection: TextDirection.ltr, // keep tile order stable across locales
      children: List.generate(words.length, (index) {
        final word = words[index];
        final displayText = _resolveWordText(word, sourceLang);
        return WordTile(
          word: word,
          index: index,
          displayText: displayText,
          textDirection: sourceTextDirection,
          onTap: () => onTap(word),
          onLongPress: () => onBookmarkToggle(word),
        );
      }),
    );
  }
}

class _ChapterPickerSheet extends StatefulWidget {
  const _ChapterPickerSheet({
    required this.levels,
    required this.selectedLevel,
    required this.selectedScope,
    required this.selectedCategoryTag,
    required this.categoryTags,
    required this.categoryCounts,
    required this.wordPairTitle,
    required this.wordPairSubtitle,
    required this.onSelectLevel,
    required this.onSelectCategory,
    required this.onOpenWordPair,
  });

  final List<String> levels;
  final String selectedLevel;
  final WordsScope selectedScope;
  final String? selectedCategoryTag;
  final List<String> categoryTags;
  final Map<String, int> categoryCounts;
  final String wordPairTitle;
  final String wordPairSubtitle;
  final ValueChanged<String> onSelectLevel;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onOpenWordPair;

  @override
  State<_ChapterPickerSheet> createState() => _ChapterPickerSheetState();
}

class _ChapterPickerSheetState extends State<_ChapterPickerSheet> {
  bool _showCategories = false;

  @override
  void initState() {
    super.initState();
    _showCategories = widget.selectedScope == WordsScope.category;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final maxHeightFactor = _showCategories ? 0.86 : 0.56;
    final height = MediaQuery.of(context).size.height * maxHeightFactor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: height,
      padding: EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _showCategories
          ? Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _showCategories = false),
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? LucideIcons.chevronRight
                            : LucideIcons.chevronLeft,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        loc.chooseCategory,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: widget.categoryTags.isEmpty
                      ? Center(child: Text(loc.tagUncategorized))
                      : ListView.separated(
                          itemCount: widget.categoryTags.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final tag = widget.categoryTags[index];
                            final selected =
                                widget.selectedScope == WordsScope.category &&
                                widget.selectedCategoryTag == tag;
                            final label = localizeWordCategoryTag(loc, tag);
                            final count = widget.categoryCounts[tag] ?? 0;
                            return Material(
                              color: selected
                                  ? cs.primary.withValues(alpha: 0.10)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: ListTile(
                                onTap: () => widget.onSelectCategory(tag),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                leading: Icon(
                                  selected
                                      ? LucideIcons.checkCircle2
                                      : LucideIcons.tag,
                                  color: selected
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                ),
                                title: Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.chooseChapter,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.levels.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemBuilder: (context, index) {
                    final isCategoriesTile = index == widget.levels.length;
                    final isSelected = isCategoriesTile
                        ? widget.selectedScope == WordsScope.category
                        : widget.selectedScope == WordsScope.level &&
                              widget.levels[index] == widget.selectedLevel;

                    final bg = isSelected ? cs.primary : Colors.grey.shade100;
                    final border = isSelected
                        ? cs.primary
                        : Colors.grey.shade300;
                    final textColor = isSelected
                        ? Colors.white
                        : Colors.black87;

                    if (isCategoriesTile) {
                      return GestureDetector(
                        onTap: () => setState(() => _showCategories = true),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.tag, size: 16, color: textColor),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  loc.chapterCategories,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final level = widget.levels[index];
                    return GestureDetector(
                      onTap: () => widget.onSelectLevel(level),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 230),
                    child: TextButton.icon(
                      onPressed: widget.onOpenWordPair,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(LucideIcons.languages, size: 16),
                      label: Text(
                        '${widget.wordPairTitle}: ${widget.wordPairSubtitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
