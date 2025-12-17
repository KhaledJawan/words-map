import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_map_app/ui/ios_card.dart';

class WordDetailSoftCard extends StatelessWidget {
  final String word;
  final String translationPrimary;
  final String? translationSecondary;
  final String? example;
  final String? extra;
  final bool isBookmarked;
  final bool showBookmark;
  final bool trailingBelowContent;
  final VoidCallback? onToggleBookmark;
  final Widget? trailingAction;

  const WordDetailSoftCard({
    super.key,
    required this.word,
    required this.translationPrimary,
    this.translationSecondary,
    this.example,
    this.extra,
    this.isBookmarked = false,
    this.showBookmark = true,
    this.trailingBelowContent = false,
    this.onToggleBookmark,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    bool isSingleToken(String value) => !RegExp(r'\s').hasMatch(value.trim());
    return IosCard(
      padding: const EdgeInsets.all(18),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: extra != null && extra!.trim().isNotEmpty
                      ? Text(
                          extra!,
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (trailingAction != null && !trailingBelowContent) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: trailingAction,
                  ),
                ],
                if (showBookmark)
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 22,
                      icon: Icon(
                        isBookmarked ? LucideIcons.bookmark : LucideIcons.bookmarkPlus,
                        color: isBookmarked
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[500],
                      ),
                      onPressed: onToggleBookmark,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final useStackedLayout = constraints.maxWidth < 420;
                final wordSingle = isSingleToken(word);
                final translationSingle = isSingleToken(translationPrimary);

                final wordText = Text(
                  word,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: wordSingle ? 1 : 2,
                  softWrap: !wordSingle,
                  overflow: TextOverflow.ellipsis,
                );

                final translationTextStyle =
                    textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ) ??
                        textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        );

                final translationBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      translationPrimary,
                      textAlign: TextAlign.end,
                      style: translationTextStyle,
                      maxLines: translationSingle ? 1 : 2,
                      softWrap: !translationSingle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (translationSecondary != null &&
                        translationSecondary!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        translationSecondary!,
                        textAlign: TextAlign.end,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.65),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                );

                if (useStackedLayout) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wordText,
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: translationBlock,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: wordText),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: translationBlock),
                  ],
                );
              },
            ),
            if (example != null && example!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                example!,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
            if (trailingBelowContent && trailingAction != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  trailingAction!,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
