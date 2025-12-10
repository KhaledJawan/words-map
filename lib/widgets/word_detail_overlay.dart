import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:word_map_app/widgets/word_detail_soft_card.dart';

void showWordDetailOverlay(
  BuildContext context, {
  required String word,
  required String translationPrimary,
  String? translationSecondary,
  String? example,
  String? extra,
  bool isBookmarked = false,
  VoidCallback? onToggleBookmark,
}) {
  bool currentBookmarked = isBookmarked;
  showGeneralDialog(
    context: context,
    barrierLabel: 'word-detail',
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.25),
    pageBuilder: (_, __, ___) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: Colors.black.withOpacity(0.1)),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WordDetailSoftCard(
                      word: word,
                      translationPrimary: translationPrimary,
                      translationSecondary: translationSecondary,
                      example: example,
                      extra: extra,
                      isBookmarked: currentBookmarked,
                      onToggleBookmark: () async {
                        await Future.sync(() => onToggleBookmark?.call());
                        setState(() {
                          currentBookmarked = !currentBookmarked;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return Transform.scale(
        scale: 0.95 + (0.05 * anim.value),
        child: Opacity(
          opacity: anim.value,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 180),
  );
}
