import 'package:flutter/material.dart';
import 'package:word_map_app/models/vocab_word.dart';

class WordTile extends StatelessWidget {
  final VocabWord word;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  static const EdgeInsetsDirectional _defaultPadding =
      EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 8);
  const WordTile({
    super.key,
    required this.word,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    const Color bookmarkedBlue = Color(0xFF1E88E5);

    final bool bookmarked = word.isBookmarked;
    final bool visited = word.isViewed;

    final bool isVisited = visited && !bookmarked;
    final Color bg = bookmarked
        ? cs.surface
        : isVisited
            ? (isDark ? const Color(0xFF303030) : const Color(0xFFF6F6F6))
            : cs.surface;
    final Color? border = bookmarked
        ? null
        : isVisited
            ? null
            : cs.outline.withOpacity(0.2);
    final Color textColor = bookmarked
        ? bookmarkedBlue
        : isVisited
            ? (isDark ? cs.onSurface.withOpacity(0.55) : const Color(0xFF8A8A8A))
            : cs.onSurface.withOpacity(0.9);
    final List<BoxShadow>? shadow = isVisited
        ? null
        : [
            BoxShadow(
              color: bookmarked
                  ? bookmarkedBlue.withOpacity(0.16)
                  : Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: bookmarked ? 10 : 8,
              offset: const Offset(0, 4),
            ),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: _calcWidth(word.de),
          height: 48,
          padding: _defaultPadding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: border != null
                ? Border.all(color: border, width: 1.1)
                : null,
            boxShadow: shadow,
          ),
          child: Center(
            child: Text(
              word.de,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  double _calcWidth(String text) {
    const min = 72.0;
    const max = 180.0;
    final estimated = text.length * 9.0 + 24.0;
    if (estimated < min) return min;
    if (estimated > max) return max;
    return estimated;
  }
}
