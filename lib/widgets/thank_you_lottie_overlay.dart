import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class ThankYouLottieOverlay {
  static const String primaryAsset = 'assets/animations/thank_you.json';
  static const String fallbackAsset = 'assets/lottie/hearts.json';

  static Future<void> show(BuildContext context, {Duration duration = const Duration(seconds: 2)}) async {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (context) => const _ThankYouOverlayBody(),
    );

    overlay.insert(entry);
    await Future<void>.delayed(duration);
    entry.remove();
  }
}

class _ThankYouOverlayBody extends StatefulWidget {
  const _ThankYouOverlayBody();

  @override
  State<_ThankYouOverlayBody> createState() => _ThankYouOverlayBodyState();
}

class _ThankYouOverlayBodyState extends State<_ThankYouOverlayBody> {
  late final Future<String?> _assetFuture;

  @override
  void initState() {
    super.initState();
    _assetFuture = _pickAsset();
  }

  Future<String?> _pickAsset() async {
    for (final candidate in const [
      ThankYouLottieOverlay.primaryAsset,
      ThankYouLottieOverlay.fallbackAsset,
      'assets/lottie/splash.json',
    ]) {
      try {
        await rootBundle.load(candidate);
        return candidate;
      } catch (_) {
        // try next
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.18)),
            ),
          ),
          Center(
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<String?>(
                    future: _assetFuture,
                    builder: (context, snapshot) {
                      final asset = snapshot.data;
                      if (asset == null) {
                        return const SizedBox(
                          height: 140,
                          child: Center(child: Icon(Icons.check_circle, size: 48)),
                        );
                      }
                      return Lottie.asset(
                        asset,
                        height: 140,
                        repeat: false,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thank you!',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
