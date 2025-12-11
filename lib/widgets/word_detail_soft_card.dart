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
    this.onToggleBookmark,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                if (trailingAction != null) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: trailingAction,
                  ),
                ],
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    word,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        translationPrimary,
                        textAlign: TextAlign.end,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.black.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (translationSecondary != null &&
                          translationSecondary!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          translationSecondary!,
                          textAlign: TextAlign.end,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black.withOpacity(0.65),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
          ],
        ),
      ),
    );
  }
}
