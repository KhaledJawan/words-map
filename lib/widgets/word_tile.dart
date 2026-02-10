import 'package:flutter/material.dart';
import 'package:word_map_app/models/vocab_word.dart';

class WordTile extends StatelessWidget {
  final VocabWord word;
  final int index;
  final String displayText;
  final TextDirection textDirection;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const WordTile({
    super.key,
    required this.word,
    required this.index,
    required this.displayText,
    required this.textDirection,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    const Color bookmarkedBlue = Color(0xFF4BA8FF);

    final bool bookmarked = word.isBookmarked;
    final bool visited = word.isViewed;

    final bool isVisited = visited && !bookmarked;

    Color bg = isDark ? Colors.black : Colors.white;
    Color textColor = isDark ? Colors.white : cs.onSurface;
    List<BoxShadow>? shadow;

    if (bookmarked) {
      bg = isDark ? Colors.black : Colors.white;
      textColor = bookmarkedBlue;
      shadow = isDark
          ? null
          : [
              BoxShadow(
                color: bookmarkedBlue.withValues(alpha: 0.10),
                blurRadius: 11,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: bookmarkedBlue.withValues(alpha: 0.04),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 7),
              ),
            ];
    } else if (isVisited) {
      // Viewed state
      bg = isDark ? Colors.transparent : const Color(0xFFF2F2F7);
      textColor = isDark
          ? Colors.white.withValues(alpha: 0.6)
          : const Color(0xFFAAAAAA);
      shadow = isDark ? null : null;
    } else {
      // Normal
      bg = isDark ? Colors.black : Colors.white;
      textColor = isDark ? Colors.white : const Color(0xFF111111);
      shadow = isDark
          ? null
          : [
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
            ];
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: IntrinsicWidth(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: _horizontalPadding(displayText),
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              boxShadow: shadow,
            ),
            child: Text(
              displayText,
              textAlign: TextAlign.center,
              textDirection: textDirection,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  double _horizontalPadding(String w) {
    if (w.length <= 4) return 20;
    if (w.length <= 7) return 16;
    if (w.length <= 12) return 12;
    return 10;
  }
}
