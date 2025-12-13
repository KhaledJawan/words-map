import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/features/grammar/grammar_models.dart';
import 'package:word_map_app/features/grammar/grammar_localization.dart';
import 'package:word_map_app/features/lessons/lesson_completion_repository.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/models/app_language.dart';
import 'package:word_map_app/services/app_state.dart';

class GrammarTopicPage extends StatefulWidget {
  const GrammarTopicPage({super.key, required this.topic});

  final GrammarTopic topic;

  @override
  State<GrammarTopicPage> createState() => _GrammarTopicPageState();
}

class _GrammarTopicPageState extends State<GrammarTopicPage> {
  final ScrollController _scrollController = ScrollController();
  final LessonCompletionRepository _completionRepo = LessonCompletionRepository();
  late Future<_LessonLoadResult> _contentFuture;
  bool _initializedContent = false;
  bool _showVocabulary = false;

  Future<void> _completeTopic() async {
    await _completionRepo.setLessonCompleted(widget.topic.id, true);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _repeatTopic() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedContent) return;
    _contentFuture = _loadLessonContent(DefaultAssetBundle.of(context));
    _initializedContent = true;
  }

  Future<_LessonLoadResult> _loadLessonContent(AssetBundle bundle) async {
    if (widget.topic.assetPath.isEmpty) {
      return _LessonLoadResult(null, 'Missing asset path');
    }

    final bundles = <AssetBundle>{
      bundle,
      if (!identical(bundle, rootBundle)) rootBundle,
    };

    Object? lastError;
    for (final candidate in bundles) {
      try {
        final raw = await candidate.loadString(widget.topic.assetPath);
        final data = jsonDecode(raw);
        if (data is! Map<String, dynamic>) {
          lastError = 'Asset did not contain a JSON object';
          continue;
        }
        return _LessonLoadResult(_GrammarLessonContent.fromJson(data), null);
      } catch (error, stack) {
        lastError = error;
        debugPrint('Failed to load grammar lesson content from ${widget.topic.assetPath} with bundle $candidate: $error');
        debugPrint('$stack');
      }
    }

    return _LessonLoadResult(null, lastError ?? 'Unknown asset load error');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final appLanguage = context.watch<AppState>().appLanguage;
    final title = localizedGrammarTopicTitle(widget.topic, appLanguage);
    final description = localizedGrammarTopicDescription(widget.topic, appLanguage);
    final hasDescription = description.isNotEmpty;
    final hasExamples = widget.topic.examples.isNotEmpty;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.x),
                        color: theme.colorScheme.onPrimary,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget.topic.level.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Level ${widget.topic.level}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: FutureBuilder<_LessonLoadResult>(
                  future: _contentFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final result = snapshot.data;
                    final content = result?.content;
                    if (content != null) {
                      return _buildLessonContent(
                        context: context,
                        theme: theme,
                        content: content,
                        loc: loc,
                        showVocabulary: _showVocabulary,
                        onToggleVocabulary: _toggleVocabulary,
                        onComplete: _completeTopic,
                      );
                    }
                    if (result?.error != null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Content failed to load',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Asset: ${widget.topic.assetPath}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                            if (result?.error != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Error: ${result!.error}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    return _buildFallbackContent(
                      theme: theme,
                      loc: loc,
                      description: description,
                      hasDescription: hasDescription,
                      hasExamples: hasExamples,
                      onComplete: _completeTopic,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonContent({
    required BuildContext context,
    required ThemeData theme,
    required _GrammarLessonContent content,
    required AppLocalizations loc,
    required bool showVocabulary,
    required VoidCallback onToggleVocabulary,
    required VoidCallback onComplete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
            if (content.vocabulary.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('نمایش لغات جدید'),
                  onPressed: onToggleVocabulary,
                ),
            ),
            if (showVocabulary) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: content.vocabulary
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.de,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (item.fa.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  item.fa,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
          const SizedBox(height: 20),
          ...content.pages.map(
            (page) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _GrammarLessonPageCard(
                page: page,
                theme: theme,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: _primaryButtonStyle(theme, backgroundColor: Colors.green),
            onPressed: onComplete,
            child: Text(loc.lessonCompleted),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFallbackContent({
    required ThemeData theme,
    required AppLocalizations loc,
    required String description,
    required bool hasDescription,
    required bool hasExamples,
    required VoidCallback onComplete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.topic.level.isNotEmpty)
            Text(
              'Level ${widget.topic.level}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          if (widget.topic.level.isNotEmpty) const SizedBox(height: 12),
          if (hasDescription)
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5) ??
                  theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            )
          else
            Text(
              loc.grammarTopicComingSoon,
              style: theme.textTheme.bodyLarge,
            ),
          if (hasExamples) ...[
            const SizedBox(height: 24),
            Text(
              loc.lessonExamplesTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.topic.examples
                  .map(
                    (example) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (example.de.isNotEmpty)
                            Text(
                              example.de,
                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          if (example.fa.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                example.fa,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            style: _primaryButtonStyle(theme, backgroundColor: Colors.green),
            onPressed: onComplete,
            child: Text(loc.lessonCompleted),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  ButtonStyle _primaryButtonStyle(ThemeData theme, {Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  void _toggleVocabulary() {
    setState(() {
      _showVocabulary = !_showVocabulary;
    });
  }
}

class _GrammarLessonPageCard extends StatelessWidget {
  const _GrammarLessonPageCard({
    required this.page,
    required this.theme,
  });

  final _GrammarLessonPage page;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (page.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                page.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          if (page.explanation.isNotEmpty)
            Text(
              page.explanation,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5) ??
                  theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          if (page.examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: page.examples
                  .map(
                    (example) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (example.de.isNotEmpty)
                            Text(
                              example.de,
                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          if (example.fa.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                example.fa,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrammarLessonContent {
  _GrammarLessonContent({
    required this.id,
    required this.titleDe,
    required this.titleFa,
    required this.vocabulary,
    required this.pages,
  });

  final String id;
  final String titleDe;
  final String titleFa;
  final List<_VocabularyItem> vocabulary;
  final List<_GrammarLessonPage> pages;

  factory _GrammarLessonContent.fromJson(Map<String, dynamic> json) {
    return _GrammarLessonContent(
      id: json['id']?.toString() ?? '',
      titleDe: json['title_de']?.toString() ?? '',
      titleFa: json['title_fa']?.toString() ?? '',
      vocabulary: _parseVocabulary(json['vocabulary_before_lesson']),
      pages: _parsePages(json['pages']),
    );
  }

  static List<_VocabularyItem> _parseVocabulary(dynamic raw) {
    if (raw is Iterable) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => _VocabularyItem(
              de: row['de']?.toString() ?? '',
              fa: row['fa']?.toString() ?? '',
            ),
          )
          .toList();
    }
    return const [];
  }

  static List<_GrammarLessonPage> _parsePages(dynamic raw) {
    if (raw is Iterable) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(_GrammarLessonPage.fromJson)
          .toList();
    }
    return const [];
  }
}

class _LessonLoadResult {
  _LessonLoadResult(this.content, this.error);

  final _GrammarLessonContent? content;
  final Object? error;
}

class _VocabularyItem {
  const _VocabularyItem({required this.de, required this.fa});
  final String de;
  final String fa;
}

class _GrammarLessonPage {
  _GrammarLessonPage({
    required this.title,
    required this.explanation,
    required this.examples,
  });

  final String title;
  final String explanation;
  final List<_GrammarLessonExample> examples;

  factory _GrammarLessonPage.fromJson(Map<String, dynamic> json) {
    final examples = <_GrammarLessonExample>[];
    if (json['example'] is Map<String, dynamic>) {
      examples.add(_GrammarLessonExample.fromJson(json['example'] as Map<String, dynamic>));
    }
    if (json['examples'] is Iterable) {
      examples.addAll(
        (json['examples'] as Iterable)
            .whereType<Map<String, dynamic>>()
            .map(_GrammarLessonExample.fromJson),
      );
    }
    return _GrammarLessonPage(
      title: json['title_fa']?.toString() ?? '',
      explanation: json['explanation_fa']?.toString() ?? '',
      examples: examples,
    );
  }
}

class _GrammarLessonExample {
  _GrammarLessonExample({
    required this.de,
    required this.fa,
  });

  final String de;
  final String fa;

  factory _GrammarLessonExample.fromJson(Map<String, dynamic> json) {
    return _GrammarLessonExample(
      de: json['de']?.toString() ?? '',
      fa: json['fa']?.toString() ?? '',
    );
  }
}
