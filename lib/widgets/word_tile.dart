import 'package:flutter/material.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/ui/ios_card.dart';

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

    Color bg = Colors.white;
    Color? border;
    Color textColor = cs.onSurface;
    List<BoxShadow>? shadow;

    if (bookmarked) {
      bg = Colors.white;
      textColor = bookmarkedBlue;
      shadow = [
        BoxShadow(
          color: bookmarkedBlue.withOpacity(0.12),
          blurRadius: 6,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: bookmarkedBlue.withOpacity(0.04),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ];
    } else if (isVisited) {
      bg = theme.scaffoldBackgroundColor;
      textColor = const Color(0xFFAAAAAA);
      shadow = null;
      border = null;
    } else {
      // Normal
      bg = Colors.white;
      textColor = const Color(0xFF111111);
      shadow = [
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
      ];
      border = const Color(0xFFE0E0E0);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: IntrinsicWidth(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: _horizontalPadding(word.de),
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              boxShadow: shadow,
            ),
            child: Text(
              word.de,
              textAlign: TextAlign.center,
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
