import 'package:flutter/material.dart';
import 'package:word_map_app/features/lessons/lessons_repository.dart';
import 'package:word_map_app/widgets/lesson_row.dart';

class CategoryDetailPage extends StatelessWidget {
  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.isCompleted,
    required this.onLessonTap,
  });

  final LessonCategory category;
  final bool Function(String lessonId) isCompleted;
  final ValueChanged<LessonItem> onLessonTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: category.lessons
            .map(
              (lesson) => LessonRow(
                lesson: lesson,
                completed: isCompleted(lesson.id),
                onTap: () => onLessonTap(lesson),
              ),
            )
            .toList(),
      ),
    );
  }
}
