import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/features/grammar/grammar_models.dart';
import 'package:word_map_app/features/grammar/grammar_localization.dart';
import 'package:word_map_app/features/lessons/lesson_completion_repository.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.topic.level.isNotEmpty)
                      Text(
                        'Level ${widget.topic.level}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
                                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: _primaryButtonStyle(theme, backgroundColor: Colors.green),
                    onPressed: _completeTopic,
                    child: Text(loc.lessonCompleted),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: _secondaryButtonStyle(theme),
                    onPressed: _repeatTopic,
                    child: Text(loc.lessonRepeatAgain),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  ButtonStyle _secondaryButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      side: BorderSide(color: theme.colorScheme.primary),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
