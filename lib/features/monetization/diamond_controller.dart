import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_map_app/services/ads/rewarded_ad_service.dart';

enum DiamondWatchResult {
  activated,
  adLoading,
  notRewarded,
}

class DiamondController extends ChangeNotifier {
  DiamondController({
    required RewardedAdService rewardedAdService,
  }) : _rewardedAdService = rewardedAdService {
    unawaited(_loadFromPrefs());
    unawaited(_rewardedAdService.load());
  }

  static const int startCounter = 50;
  static const int _legacyStartCounter = 20;
  static const Duration diamondDuration = Duration(hours: 1);

  static const String _prefsCounterKey = 'diamond_word_counter';
  static const String _prefsExpireAtKey = 'diamond_expire_at_ms';

  final RewardedAdService _rewardedAdService;

  int _counter = startCounter;
  DateTime? _diamondExpireAt;
  bool _isLoaded = false;
  int _activationGeneration = 0;
  Timer? _ticker;

  bool get isLoaded => _isLoaded;
  int get counter => _counter;
  int get activationGeneration => _activationGeneration;

  DateTime? get diamondExpireAt => _diamondExpireAt;

  bool get isDiamondActive {
    final expiry = _diamondExpireAt;
    if (expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  Duration get remainingTime {
    if (!isDiamondActive) return Duration.zero;
    final expiry = _diamondExpireAt!;
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  String remainingText() {
    final d = remainingTime;
    final totalMinutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    final mm = totalMinutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCounter = prefs.getInt(_prefsCounterKey);
    _counter = storedCounter ?? startCounter;
    if (storedCounter == _legacyStartCounter && startCounter > _legacyStartCounter) {
      _counter = startCounter;
    }
    if (_counter > startCounter) {
      _counter = startCounter;
    }
    if (storedCounter == null || storedCounter != _counter) {
      await prefs.setInt(_prefsCounterKey, _counter);
    }
    final expireMs = prefs.getInt(_prefsExpireAtKey);
    _diamondExpireAt =
        expireMs != null && expireMs > 0 ? DateTime.fromMillisecondsSinceEpoch(expireMs) : null;
    _isLoaded = true;
    _syncTicker();
    notifyListeners();
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsCounterKey, _counter);
  }

  Future<void> _saveExpireAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = _diamondExpireAt?.millisecondsSinceEpoch ?? 0;
    await prefs.setInt(_prefsExpireAtKey, ms);
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (!isDiamondActive) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isDiamondActive) {
        _ticker?.cancel();
        _ticker = null;
        notifyListeners();
        return;
      }
      notifyListeners();
    });
  }

  Future<void> resetCounter() async {
    _counter = startCounter;
    notifyListeners();
    await _saveCounter();
  }

  Future<void> _activateDiamondFor(Duration duration) async {
    _diamondExpireAt = DateTime.now().add(duration);
    _activationGeneration += 1;
    _syncTicker();
    notifyListeners();
    await _saveExpireAt();
  }

  Future<DiamondWatchResult> watchAdForDiamond() async {
    if (!_rewardedAdService.isReady) {
      unawaited(_rewardedAdService.load());
      return DiamondWatchResult.adLoading;
    }

    final earnedReward = await _rewardedAdService.show();
    if (!earnedReward) {
      return DiamondWatchResult.notRewarded;
    }

    await _activateDiamondFor(diamondDuration);
    await resetCounter();
    return DiamondWatchResult.activated;
  }

  bool onWordSelected() {
    if (isDiamondActive) return true;
    if (_counter <= 0) return false;
    _counter -= 1;
    notifyListeners();
    unawaited(_saveCounter());
    return true;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
