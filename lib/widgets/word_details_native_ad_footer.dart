import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_map_app/config/ad_policy.dart';

class WordDetailsNativeAdFooter extends StatefulWidget {
  const WordDetailsNativeAdFooter({super.key, this.height = 128});

  final double height;

  static const String factoryId = 'wordDetailsFooter';

  @override
  State<WordDetailsNativeAdFooter> createState() =>
      _WordDetailsNativeAdFooterState();
}

class _WordDetailsNativeAdFooterState extends State<WordDetailsNativeAdFooter> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _failed = false;
  bool _loadRequested = false;

  @override
  void initState() {
    super.initState();
    if (!AdPolicy.enableNativeAds) {
      _failed = true;
      return;
    }
    _load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  String _nativeAdUnitId() {
    const production = 'ca-app-pub-5088702480788455/9294388664';
    const testAndroid = 'ca-app-pub-3940256099942544/2247696110';
    const testIos = 'ca-app-pub-3940256099942544/3986624511';

    if (kReleaseMode) return production;
    if (kIsWeb) return testAndroid;
    if (defaultTargetPlatform == TargetPlatform.iOS) return testIos;
    return testAndroid;
  }

  void _load() {
    if (_loadRequested || _failed) return;
    _loadRequested = true;

    final ad = NativeAd(
      adUnitId: _nativeAdUnitId(),
      factoryId: WordDetailsNativeAdFooter.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _failed = true;
            _nativeAd = null;
          });
        },
      ),
      nativeAdOptions: NativeAdOptions(),
    );

    _nativeAd = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || !AdPolicy.enableNativeAds) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    final borderColor = theme.dividerColor.withValues(alpha: 0.35);

    return SizedBox(
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AdLabel(),
              const SizedBox(height: 8),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _isLoaded && _nativeAd != null
                      ? AdWidget(ad: _nativeAd!)
                      : const Center(
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdLabel extends StatelessWidget {
  const _AdLabel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pillBg = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.06);
    final pillFg = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.black.withValues(alpha: 0.75);
    final labelFg = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.black.withValues(alpha: 0.55);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Ad',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: pillFg,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Anzeige',
          style: textTheme.labelSmall?.copyWith(
            color: labelFg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
