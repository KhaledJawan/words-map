import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../features/lessons/alphabet/alphabet_lesson_item.dart';
import '../features/lessons/alphabet/alphabet_lesson_localization.dart';
import '../features/lessons/alphabet/alphabet_lesson_repository.dart';
import '../features/lessons/lesson_completion_repository.dart';
import '../services/app_state.dart';

class AlphabetLessonPage extends StatefulWidget {
  final AlphabetLessonRepository repository;
  final String lessonId;

  const AlphabetLessonPage({
    super.key,
    required this.repository,
    required this.lessonId,
  });

  @override
  State<AlphabetLessonPage> createState() => _AlphabetLessonPageState();
}

class _AlphabetLessonPageState extends State<AlphabetLessonPage> {
  late final Future<List<AlphabetLessonItem>> _lessonsFuture;
  final LessonCompletionRepository _completionRepo = LessonCompletionRepository();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = widget.repository.loadAlphabetLesson();
  }

  void _repeatLesson() {
    setState(() {
      _currentIndex = 0;
    });
  }

  Future<void> _completeLesson() async {
    await _completionRepo.setLessonCompleted(widget.lessonId, true);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _nextSlide(int lastIndex) {
    if (_currentIndex >= lastIndex) {
      _completeLesson();
      return;
    }
    setState(() {
      _currentIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<AppState>().appLanguage;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(loc.lessonBeginnerAlphabetTitle),
      ),
      body: FutureBuilder<List<AlphabetLessonItem>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(loc.chapterEmptyState),
            );
          }
          final lessons = snapshot.data ?? [];
          if (lessons.isEmpty) {
            return Center(
              child: Text(loc.chapterEmptyState),
            );
          }
          final currentLesson = lessons[_currentIndex.clamp(0, lessons.length - 1)];
          final subject = getLocalizedSubject(currentLesson, appLanguage);
          final description = getLocalizedDescription(currentLesson, appLanguage);
          final examples = getLocalizedExamples(currentLesson, appLanguage);
          final bool isLast = _currentIndex >= lessons.length - 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        if (examples.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: examples
                                .map(
                                  (example) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '• $example',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        if (currentLesson.images.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: currentLesson.images
                                .map(
                                  (image) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      image,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        if (currentLesson.audioDe.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Play audio',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!isLast)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _nextSlide(lessons.length - 1),
                      child: Text(loc.lessonButtonNext),
                    ),
                  ),
                if (isLast)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _completeLesson,
                          child: Text(loc.lessonCompleted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _repeatLesson,
                          child: Text(loc.lessonRepeatAgain),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
