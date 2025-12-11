import 'package:flutter/material.dart';
import 'package:word_map_app/features/lessons/lessons_repository.dart';
import 'package:word_map_app/screens/lesson_detail_page.dart';
import 'package:word_map_app/widgets/lesson_row.dart';

class GrammarLevelPage extends StatefulWidget {
  const GrammarLevelPage({
    super.key,
    required this.level,
    required this.lessons,
    required this.completedLessonIds,
    this.onLessonCompleted,
  });

  final String level;
  final List<LessonItem> lessons;
  final Set<String> completedLessonIds;
  final ValueChanged<String>? onLessonCompleted;

  @override
  State<GrammarLevelPage> createState() => _GrammarLevelPageState();
}

class _GrammarLevelPageState extends State<GrammarLevelPage> {
  late final Set<String> _completedLessonIds;

  @override
  void initState() {
    super.initState();
    _completedLessonIds = widget.completedLessonIds;
  }

  Future<void> _openLesson(LessonItem lesson) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LessonDetailPage(lesson: lesson),
      ),
    );
    if (result == true) {
      _completedLessonIds.add(lesson.id);
      widget.onLessonCompleted?.call(lesson.id);
      setState(() {});
    }
  }

  bool _isCompleted(LessonItem lesson) => _completedLessonIds.contains(lesson.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.level} Grammar'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.lessons.length,
        itemBuilder: (context, index) {
          final lesson = widget.lessons[index];
          return LessonCard(
            lesson: lesson,
            isCompleted: _isCompleted(lesson),
            onTap: () => _openLesson(lesson),
          );
        },
      ),
    );
  }
}
