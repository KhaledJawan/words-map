import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/core/audio/audio_service.dart';
import 'package:word_map_app/features/lessons/combinations_json/combinations_json_lesson_models.dart';
import 'package:word_map_app/features/lessons/combinations_json/combinations_json_lesson_repository.dart';
import 'package:word_map_app/features/lessons/lesson_completion_repository.dart';
import 'package:word_map_app/models/app_language.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/widgets/word_detail_soft_card.dart';
import 'package:word_map_app/widgets/word_tile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CombinationsJsonLessonPage extends StatefulWidget {
  const CombinationsJsonLessonPage({
    super.key,
    required this.assetPath,
    required this.allWords,
    this.initialLesson,
  });

  final String assetPath;
  final List<VocabWord> allWords;
  final CombinationsJsonLesson? initialLesson;

  @override
  State<CombinationsJsonLessonPage> createState() =>
      _CombinationsJsonLessonPageState();
}

class _CombinationsJsonLessonPageState extends State<CombinationsJsonLessonPage> {
  final LessonCompletionRepository _completionRepo = LessonCompletionRepository();
  late final Future<CombinationsJsonLesson> _lessonFuture;

  @override
  void initState() {
    super.initState();
    _lessonFuture = widget.initialLesson != null
        ? Future.value(widget.initialLesson!)
        : AssetCombinationsJsonLessonRepository(assetPath: widget.assetPath)
            .loadLesson();
  }

  String _localized(
    AppLanguage lang, {
    required String en,
    required String fa,
    required String de,
  }) {
    switch (lang) {
      case AppLanguage.fa:
        return fa.isNotEmpty ? fa : (en.isNotEmpty ? en : de);
      case AppLanguage.en:
        return en.isNotEmpty ? en : (de.isNotEmpty ? de : fa);
      case AppLanguage.de:
        return de.isNotEmpty ? de : (en.isNotEmpty ? en : fa);
    }
  }

  Future<void> _markCompleted(String lessonId) async {
    await _completionRepo.setLessonCompleted(lessonId, true);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String _ruleBadgeText(LetterCombinationRule rule) {
    final title = rule.titleDe.trim();
    if (title.isNotEmpty) {
      final tokens = title.split(RegExp(r'\\s+')).where((t) => t.isNotEmpty).toList();
      if (tokens.length >= 3 && tokens[1] == '/') {
        return '${tokens[0]}/${tokens[2]}';
      }
      final first = tokens.isNotEmpty ? tokens.first : '';
      if (first.isNotEmpty && first.length <= 10) {
        return first;
      }
    }

    final id = rule.id.trim();
    if (id.isEmpty) return '';
    final parts = id.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0]}/${parts[1]}';
    return id;
  }

  VocabWord? _findWordByKey(String key) {
    final normalized = key.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final w in widget.allWords) {
      if (w.id.trim().toLowerCase() == normalized) return w;
      if (w.de.trim().toLowerCase() == normalized) return w;
    }
    return null;
  }

  Future<void> _openWordOverlay(VocabWord word) async {
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
                      child: Builder(
                        builder: (dialogContext) {
                          final localeCode = Localizations.localeOf(dialogContext)
                              .languageCode;
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
                                  onPressed:
                                      hasAudio ? () async => await handlePlayAudio() : null,
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
                            showBookmark: false,
                            isBookmarked: bookmarkedLocal,
                            trailingAction: audioAction,
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

  Future<void> _openMissingWordOverlay(AppLanguage lang, String key) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'word-detail',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
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
                  child: WordDetailSoftCard(
                    word: key,
                    translationPrimary: _localized(
                      lang,
                      en: 'Not found',
                      fa: 'پیدا نشد',
                      de: 'Nicht gefunden',
                    ),
                    translationSecondary: _localized(
                      lang,
                      en: 'This word is not in your vocabulary yet.',
                      fa: 'این کلمه هنوز در واژگان شما نیست.',
                      de: 'Dieses Wort ist noch nicht in deinem Wortschatz.',
                    ),
                    extra: _localized(
                      lang,
                      en: 'Vocabulary',
                      fa: 'واژگان',
                      de: 'Wortschatz',
                    ),
                    showBookmark: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<AppState>().appLanguage;
    return FutureBuilder<CombinationsJsonLesson>(
      future: _lessonFuture,
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lesson')),
            body: Center(
              child: Text(
                _localized(
                  appLanguage,
                  en: 'Failed to load lesson.',
                  fa: 'بارگذاری درس ناموفق بود.',
                  de: 'Lektion konnte nicht geladen werden.',
                ),
              ),
            ),
          );
        }

        final lesson = snapshot.data!;
        final title = _localized(appLanguage, en: lesson.titleEn, fa: lesson.titleFa, de: lesson.titleDe);
        final level = _localized(appLanguage, en: lesson.levelEn, fa: lesson.levelFa, de: lesson.levelDe);

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.secondary.withValues(alpha: 0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSecondary),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              title.isNotEmpty
                                  ? title
                                  : _localized(appLanguage, en: 'Combinations', fa: 'ترکیب‌ها', de: 'Kombinationen'),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSecondary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (level.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSecondary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            level,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lesson.explanations.isNotEmpty) ...[
                        Text(
                          _localized(appLanguage, en: 'Overview', fa: 'معرفی', de: 'Überblick'),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        ...lesson.explanations.map((block) {
                          final blockTitle = _localized(
                            appLanguage,
                            en: block.titleEn,
                            fa: block.titleFa,
                            de: block.titleDe,
                          );
                          final blockText = _localized(
                            appLanguage,
                            en: block.explanationEn,
                            fa: block.explanationFa,
                            de: block.explanationDe,
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (blockTitle.isNotEmpty)
                                  Text(
                                    blockTitle,
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                if (blockText.isNotEmpty) ...[
                                  if (blockTitle.isNotEmpty) const SizedBox(height: 8),
                                  Text(blockText, style: theme.textTheme.bodyMedium),
                                ],
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 6),
                      ],
                      if (lesson.combinations.isNotEmpty) ...[
                        Text(
                          _localized(appLanguage, en: 'Combinations', fa: 'ترکیب‌ها', de: 'Kombinationen'),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        ...lesson.combinations.map((rule) {
                          final ruleTitle = _localized(
                            appLanguage,
                            en: rule.titleEn,
                            fa: rule.titleFa,
                            de: rule.titleDe,
                          );
                          final ruleDesc = _localized(
                            appLanguage,
                            en: rule.descriptionEn,
                            fa: rule.descriptionFa,
                            de: rule.descriptionDe,
                          );
                          final exampleKeys = rule.examples
                              .map((e) => e.wordRef?.key ?? '')
                              .map((v) => v.trim())
                              .where((v) => v.isNotEmpty)
                              .toList();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _ruleBadgeText(rule),
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        ruleTitle.isNotEmpty ? ruleTitle : rule.id,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (ruleDesc.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(ruleDesc, style: theme.textTheme.bodyMedium),
                                ],
                                if (exampleKeys.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 3,
                                    textDirection: TextDirection.ltr,
                                    children: List.generate(exampleKeys.length, (index) {
                                      final key = exampleKeys[index];
                                      final found = _findWordByKey(key);
                                      final word = found ??
                                          VocabWord(
                                            id: key,
                                            de: key,
                                            translationEn: '',
                                            translationFa: '',
                                            image: '',
                                          );
                                      Future<void> handleTap() async {
                                        if (found == null) {
                                          await _openMissingWordOverlay(appLanguage, key);
                                          return;
                                        }
                                        await _openWordOverlay(found);
                                      }

                                      return WordTile(
                                        word: word,
                                        index: index,
                                        onTap: () async => await handleTap(),
                                        onLongPress: () async => await handleTap(),
                                      );
                                    }),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: lesson.id.isNotEmpty ? () => _markCompleted(lesson.id) : null,
                          child: Text(
                            _localized(appLanguage, en: 'Mark as completed', fa: 'تمام شد', de: 'Als erledigt markieren'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
