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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
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
              color: Colors.white.withOpacity(0.9),
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
