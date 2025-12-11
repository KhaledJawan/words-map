import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/features/grammar/grammar_models.dart';
import 'package:word_map_app/features/grammar/grammar_localization.dart';
import 'package:word_map_app/screens/grammar_topic_page.dart';
import 'package:word_map_app/services/app_state.dart';

class GrammarCategoryPage extends StatefulWidget {
  const GrammarCategoryPage({
    super.key,
    required this.category,
    required this.completedLessonIds,
    this.onTopicCompleted,
  });

  final GrammarCategory category;
  final Set<String> completedLessonIds;
  final ValueChanged<String>? onTopicCompleted;

  @override
  State<GrammarCategoryPage> createState() => _GrammarCategoryPageState();
}

class _GrammarCategoryPageState extends State<GrammarCategoryPage> {
  Future<void> _openTopic(GrammarTopic topic) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => GrammarTopicPage(topic: topic),
      ),
    );
    if (result == true) {
      widget.onTopicCompleted?.call(topic.id);
      setState(() {});
    }
  }

  bool _isCompleted(GrammarTopic topic) => widget.completedLessonIds.contains(topic.id);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appLanguage = context.watch<AppState>().appLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: widget.category.topics.isEmpty
          ? Center(child: Text(loc.lessonsStatusComingSoon))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.category.topics.length,
              itemBuilder: (context, index) {
                final topic = widget.category.topics[index];
                final title = localizedGrammarTopicTitle(topic, appLanguage);
                final description = localizedGrammarTopicDescription(topic, appLanguage);
                return GrammarTopicCard(
                  title: title,
                  subtitle: topic.level.isNotEmpty ? topic.level : null,
                  description: description,
                  isCompleted: _isCompleted(topic),
                  onTap: () => _openTopic(topic),
                );
              },
            ),
    );
  }
}

class GrammarTopicCard extends StatelessWidget {
  const GrammarTopicCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    required this.isCompleted,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? description;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isCompleted ? Colors.green : Colors.grey;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ),
                    if (description != null && description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          description!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
