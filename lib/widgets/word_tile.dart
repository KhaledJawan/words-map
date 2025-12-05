import 'package:flutter/material.dart';
import 'package:word_map_app/models/vocab_word.dart';

class WordTile extends StatefulWidget {
  final VocabWord word;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const WordTile({
    super.key,
    required this.word,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final word = widget.word;
    const Color bookmarkedBlue = Color(0xFF1E88E5);

    final bool bookmarked = word.isBookmarked;
    final bool visited = word.isViewed;

    final Color bg = bookmarked
        ? cs.surface
        : visited
            ? (isDark ? cs.surface : cs.background)
            : cs.surface;
    final Color? border = bookmarked
        ? null
        : visited
            ? null
            : cs.outline.withOpacity(0.6);
    final Color textColor =
        bookmarked ? bookmarkedBlue : cs.onSurface.withOpacity(0.9);
    final List<BoxShadow>? shadow = visited
        ? null
        : [
            BoxShadow(
              color: bookmarked
                  ? bookmarkedBlue.withOpacity(0.16)
                  : Colors.black.withOpacity(isDark ? 0.18 : 0.06),
              blurRadius: bookmarked ? 8 : 8,
              offset: const Offset(0, 4),
            ),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 68),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 36,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
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
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
