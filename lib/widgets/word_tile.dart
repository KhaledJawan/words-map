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
      shadow = const [
        BoxShadow(
          color: Color.fromRGBO(30, 136, 229, 0.2),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color.fromRGBO(30, 136, 229, 0.08),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ];
    } else if (isVisited) {
      bg = const Color(0xFFF2F2F2);
      textColor = const Color(0xFFAAAAAA);
      shadow = null;
      border = null;
    } else {
      // Normal
      bg = Colors.white;
      textColor = const Color(0xFF111111);
      shadow = const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.05),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.02),
          blurRadius: 4,
          offset: Offset(0, 1),
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
        child: SizedBox(
          width: _calcWidth(word.de),
          height: 48,
          child: IosCard(
            padding: _defaultPadding,
            color: bg,
            enableShadow: shadow != null,
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
