import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/screens/alphabet_lesson_page.dart';
import 'package:word_map_app/features/lessons/alphabet/alphabet_lesson_item.dart';
import 'package:word_map_app/features/lessons/alphabet/alphabet_lesson_repository.dart';
import 'package:word_map_app/features/lessons/lesson_localization.dart';
import 'package:word_map_app/features/lessons/lessons_repository.dart';
import 'package:word_map_app/features/grammar/grammar_models.dart';
import 'package:word_map_app/features/grammar/grammar_repository.dart';
import 'package:word_map_app/screens/grammar_category_page.dart';
import 'package:word_map_app/screens/lesson_detail_page.dart';
import 'package:word_map_app/widgets/lesson_row.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.completedLessonIds,
    this.onLessonCompleted,
  });

  final LessonCategory category;
  final Set<String> completedLessonIds;
  final ValueChanged<String>? onLessonCompleted;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late final Set<String> _completedLessonIds;
  final GrammarRepository _grammarRepository = AssetGrammarRepository();
  late final Future<List<GrammarCategory>> _grammarCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _completedLessonIds = Set.of(widget.completedLessonIds);
    _grammarCategoriesFuture = _grammarRepository.loadCategories();
  }

  Future<void> _openLesson(LessonItem lesson) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LessonDetailPage(lesson: lesson),
      ),
    );
    if (result == true) {
      _handleLessonCompleted(lesson.id);
    }
  }

  Future<void> _openAlphabetLesson(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AlphabetLessonPage(
          repository: AssetAlphabetLessonRepository(),
          lessonId: _alphabetLessonId,
        ),
      ),
    );
    if (result == true) {
      _handleLessonCompleted(_alphabetLessonId);
    }
  }

  Future<void> _openGrammarCategory(GrammarCategory category) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => GrammarCategoryPage(
          category: category,
          completedLessonIds: _completedLessonIds,
          onTopicCompleted: _handleLessonCompleted,
        ),
      ),
    );
  }

  bool _isCompleted(LessonItem lesson) => _completedLessonIds.contains(lesson.id);
  bool _isTopicCompleted(GrammarTopic topic) => _completedLessonIds.contains(topic.id);

  void _handleLessonCompleted(String lessonId) {
    if (_completedLessonIds.add(lessonId)) {
      setState(() {});
    }
    widget.onLessonCompleted?.call(lessonId);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isGrammar = widget.category.id == 'grammar';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizedCategoryTitle(widget.category.id, loc),
        ),
      ),
      body: isGrammar ? _buildGrammarCategoryList(loc) : _buildLessonList(loc),
    );
  }

  static const String _alphabetLessonId = 'alphabet_json';

  Widget _buildGrammarCategoryList(AppLocalizations loc) {
    return FutureBuilder<List<GrammarCategory>>(
      future: _grammarCategoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(loc.grammarContentLoadError));
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return Center(child: Text(loc.lessonsStatusComingSoon));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: categories
              .map((category) => _buildGrammarCategoryCard(category, loc))
              .toList(),
        );
      },
    );
  }

  Widget _buildLessonList(AppLocalizations loc) {
    if (widget.category.id == 'beginner') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: _buildAlphabetCard(loc),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: widget.category.lessons
          .map(
            (lesson) => LessonCard(
              lesson: lesson,
              isCompleted: _isCompleted(lesson),
              onTap: () => _openLesson(lesson),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGrammarCategoryCard(GrammarCategory category, AppLocalizations loc) {
    final theme = Theme.of(context);
    final total = category.topics.length;
    final hasTopics = total > 0;
    final completed = category.topics.where(_isTopicCompleted).length;
    final iconColor = hasTopics && completed == total ? Colors.green : Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: hasTopics ? () => _openGrammarCategory(category) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasTopics
                          ? loc.grammarLevelLessonsCount(total)
                          : localizedLessonsStatusComingSoon(loc),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                hasTopics && completed == total ? LucideIcons.checkCircle2 : LucideIcons.circle,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlphabetCard(AppLocalizations loc) {
    final isCompleted = _completedLessonIds.contains(_alphabetLessonId);
    return FutureBuilder<List<AlphabetLessonItem>>(
      future: const AssetAlphabetLessonRepository().loadAlphabetLesson(),
      builder: (context, snapshot) {
        final slides = snapshot.data?.length ?? 0;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          child: ListTile(
            onTap: () => _openAlphabetLesson(context),
            leading: Icon(
              isCompleted ? LucideIcons.checkCircle2 : LucideIcons.bookOpenCheck,
              color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              loc.lessonBeginnerAlphabetTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              snapshot.connectionState == ConnectionState.done
                  ? '$slides ${slides == 1 ? 'slide' : 'slides'}'
                  : 'Loading…',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

}
