import 'package:flutter/material.dart';
import 'package:word_map_app/l10n/app_localizations.dart';

class WordLevelsScreen extends StatelessWidget {
  const WordLevelsScreen({
    super.key,
    required this.levels,
    required this.currentLevel,
  });

  final List<String> levels;
  final String currentLevel;

  Widget _buildLevelCard(
    BuildContext context, {
    required String level,
    required bool selected,
  }) {
    final Color textColor =
        selected ? const Color(0xFF1E90FF) : Colors.black87;
    final List<BoxShadow> shadows = selected
        ? [
            BoxShadow(
              color: const Color(0xFF1E90FF).withOpacity(0.2),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ];

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(level),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: shadows,
            border: Border.all(
              color: selected
                  ? const Color(0xFF1E90FF).withOpacity(0.6)
                  : Colors.transparent,
              width: selected ? 1.2 : 0,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.map, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                level,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
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
    final cs = Theme.of(context).colorScheme;
    final appLoc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(appLoc.wordLevelsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final lvl in levels)
              _buildLevelCard(
                context,
                level: lvl,
                selected: lvl == currentLevel,
              ),
          ],
        ),
      ),
      backgroundColor: cs.surface,
    );
  }
}
