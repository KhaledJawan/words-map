import 'package:flutter/material.dart';

class WordDetailGlassCard extends StatelessWidget {
  final String word;
  final String translation;
  final String? example;
  final String? extra;

  const WordDetailGlassCard({
    super.key,
    required this.word,
    required this.translation,
    this.example,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (extra != null && extra!.isNotEmpty) ...[
            Text(
              extra!,
              style: textTheme.labelMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            word,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translation,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (example != null && example!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              example!,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
