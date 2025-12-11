import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_map_app/features/lessons/lesson_completion_repository.dart';
import 'package:word_map_app/features/lessons/lesson_localization.dart';
import 'package:word_map_app/features/lessons/lessons_repository.dart';
import 'package:word_map_app/l10n/app_localizations.dart';

class LessonDetailPage extends StatefulWidget {
  const LessonDetailPage({
    super.key,
    required this.lesson,
  });

  final LessonItem lesson;

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  int _currentSlideIndex = 0;
  final LessonCompletionRepository _completionRepo = LessonCompletionRepository();

  void _nextSlide() {
    if (_currentSlideIndex < widget.lesson.slides.length - 1) {
      setState(() {
        _currentSlideIndex += 1;
      });
    }
  }

  void _repeatLesson() {
    setState(() {
      _currentSlideIndex = 0;
    });
  }

  Future<void> _completeLesson() async {
    await _completionRepo.setLessonCompleted(widget.lesson.id, true);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.lesson.slides[_currentSlideIndex];
    final isLast = _currentSlideIndex == widget.lesson.slides.length - 1;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final lessonTitle = localizedLessonTitle(widget.lesson, loc);
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
                      lessonTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildSlideText(theme, slide, loc),
            ),
          ),
        ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (!isLast)
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: _primaryButtonStyle(theme),
                        onPressed: _nextSlide,
                        child: Text(loc.lessonButtonNext),
                      ),
                    ),
                  if (isLast) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: _primaryButtonStyle(theme, backgroundColor: Colors.green),
                            onPressed: _completeLesson,
                            child: Text(loc.lessonCompleted),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: _secondaryButtonStyle(theme),
                            onPressed: _repeatLesson,
                            child: Text(loc.lessonRepeatAgain),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideText(ThemeData theme, LessonSlide slide, AppLocalizations loc) {
    final parts = _splitSlideText(slide.text);
    final exampleText = parts.example?.trim();
    final hasExample = exampleText != null && exampleText.isNotEmpty;
    final bodyText =
        hasExample ? parts.body.trim() : slide.text.trim();
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
          height: 1.45,
        ) ??
        theme.textTheme.bodyMedium?.copyWith(height: 1.45);
    final exampleStyle = theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
        );

    final slideTitle = localizedLessonSlideTitle(slide, loc);
    final showTitle = slideTitle.isNotEmpty ? slideTitle : (slide.title ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        if (showTitle.isNotEmpty) ...[
          Center(
            child: Text(
              showTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (bodyText.isNotEmpty)
          Text(
            bodyText,
            textAlign: TextAlign.left,
            style: bodyStyle,
          ),
        if (hasExample) const SizedBox(height: 18),
        if (hasExample)
          Center(
            child: Text(
              exampleText!,
              textAlign: TextAlign.center,
              style: exampleStyle,
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  _SlideTextParts _splitSlideText(String text) {
    const markers = ['Examples:', 'Example:'];
    final trimmed = text.trim();
    for (final marker in markers) {
      final index = trimmed.indexOf(marker);
      if (index != -1) {
        final before = trimmed.substring(0, index).trim();
        final after = trimmed.substring(index).trim();
        return _SlideTextParts(body: before, example: after);
      }
    }
    return _SlideTextParts(body: trimmed, example: null);
  }

  ButtonStyle _primaryButtonStyle(ThemeData theme, {Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  ButtonStyle _secondaryButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      side: BorderSide(color: theme.colorScheme.primary),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _SlideTextParts {
  const _SlideTextParts({
    required this.body,
    this.example,
  });

  final String body;
  final String? example;
}
