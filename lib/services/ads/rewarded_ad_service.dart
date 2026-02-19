import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAdService({required bool enableRewardedAds})
    : _enableRewardedAds = enableRewardedAds;

  static const String rewardedAdUnitIdAndroid =
      'ca-app-pub-5088702480788455/6692824796';
  static const String rewardedAdUnitIdIos =
      'ca-app-pub-5088702480788455/6692824796';

  final bool _enableRewardedAds;
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  bool get isEnabled => _enableRewardedAds;
  bool get isReady => _rewardedAd != null;
  bool get isLoading => _isLoading;

  String get _adUnitId {
    if (kIsWeb) return rewardedAdUnitIdAndroid;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return rewardedAdUnitIdIos;
      case TargetPlatform.android:
        return rewardedAdUnitIdAndroid;
      default:
        return rewardedAdUnitIdAndroid;
    }
  }

  Future<void> load() async {
    if (!_enableRewardedAds) return;
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;
    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _rewardedAd = ad;
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              unawaited(load());
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              unawaited(load());
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _rewardedAd = null;
          if (kDebugMode) {
            debugPrint('RewardedAd failed to load: $error');
          }
        },
      ),
    );
  }

  Future<bool> show({VoidCallback? onRewardEarned}) async {
    if (!_enableRewardedAds) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      unawaited(load());
      return false;
    }

    _rewardedAd = null;
    final completer = Completer<bool>();
    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(load());
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(load());
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        if (rewarded) return;
        rewarded = true;
        onRewardEarned?.call();
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 90),
      onTimeout: () {
        unawaited(load());
        return rewarded;
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
