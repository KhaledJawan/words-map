import 'package:flutter/material.dart';
import 'package:word_map_app/features/lessons/lessons_repository.dart';
import 'package:word_map_app/screens/grammar_level_page.dart';
import 'package:word_map_app/screens/lesson_detail_page.dart';
import 'package:word_map_app/widgets/lesson_row.dart';

const _grammarLevelsOrder = ['A1', 'A2', 'B1', 'B2', 'C1'];

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
  late final Map<String, List<LessonItem>> _grammarByLevel;

  @override
  void initState() {
    super.initState();
    _completedLessonIds = Set.of(widget.completedLessonIds);
    _grammarByLevel = _buildGrammarLevels();
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

  bool _isCompleted(LessonItem lesson) => _completedLessonIds.contains(lesson.id);

  void _handleLessonCompleted(String lessonId) {
    if (_completedLessonIds.add(lessonId)) {
      setState(() {});
    }
    widget.onLessonCompleted?.call(lessonId);
  }

  Map<String, List<LessonItem>> _buildGrammarLevels() {
    final Map<String, List<LessonItem>> grouped = {};
    for (final lesson in widget.category.lessons) {
      final level = _extractLevelPrefix(lesson.title);
      if (level == null) continue;
      grouped.putIfAbsent(level, () => []);
      grouped[level]!.add(lesson);
    }
    return grouped;
  }

  String? _extractLevelPrefix(String title) {
    final match = RegExp(r'^(A1|A2|B1|B2|C1)\b').firstMatch(title);
    return match?.group(1);
  }

  Future<void> _openGrammarLevel(String level, List<LessonItem> lessons) async {
    if (lessons.isEmpty) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => GrammarLevelPage(
          level: level,
          lessons: lessons,
          completedLessonIds: _completedLessonIds,
          onLessonCompleted: _handleLessonCompleted,
        ),
      ),
    );
  }

  Widget _buildLevelCard(String level, List<LessonItem> lessons) {
    final theme = Theme.of(context);
    final hasLessons = lessons.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: hasLessons ? () => _openGrammarLevel(level, lessons) : null,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$level Grammar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasLessons ? '${lessons.length} lessons' : 'Coming soon',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGrammar = widget.category.id == 'grammar';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: isGrammar ? _buildGrammarLevelList() : _buildLessonList(),
    );
  }

  Widget _buildLessonList() {
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

  Widget _buildGrammarLevelList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _grammarLevelsOrder
          .map(
            (level) => _buildLevelCard(
              level,
              _grammarByLevel[level] ?? const [],
            ),
          )
          .toList(),
    );
  }
}
