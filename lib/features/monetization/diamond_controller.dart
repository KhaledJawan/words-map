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
  static const String _prefsCooldownUntilKey = 'diamond_cooldown_until_ms';

  final RewardedAdService _rewardedAdService;

  int _counter = startCounter;
  DateTime? _diamondExpireAt;
  DateTime? _cooldownUntil;
  bool _isLoaded = false;
  int _activationGeneration = 0;
  Timer? _ticker;

  bool get isLoaded => _isLoaded;
  int get counter => _counter;
  int get activationGeneration => _activationGeneration;

  DateTime? get diamondExpireAt => _diamondExpireAt;
  DateTime? get cooldownUntil => _cooldownUntil;

  bool get isDiamondActive {
    final expiry = _diamondExpireAt;
    if (expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  bool get isCooldownActive {
    final until = _cooldownUntil;
    if (until == null) return false;
    return until.isAfter(DateTime.now());
  }

  Duration get remainingTime {
    if (!isDiamondActive) return Duration.zero;
    final expiry = _diamondExpireAt!;
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  Duration get cooldownRemainingTime {
    if (!isCooldownActive) return Duration.zero;
    final until = _cooldownUntil!;
    final remaining = until.difference(DateTime.now());
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

  String cooldownText() {
    final d = cooldownRemainingTime;
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
    final cooldownMs = prefs.getInt(_prefsCooldownUntilKey);
    _cooldownUntil =
        cooldownMs != null && cooldownMs > 0 ? DateTime.fromMillisecondsSinceEpoch(cooldownMs) : null;

    _completeCooldownInMemoryIfExpired();
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

  Future<void> _saveCooldownUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = _cooldownUntil?.millisecondsSinceEpoch ?? 0;
    await prefs.setInt(_prefsCooldownUntilKey, ms);
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (!isDiamondActive && !isCooldownActive) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _completeCooldownInMemoryIfExpired();
      if (!isDiamondActive && !isCooldownActive) {
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

  Future<void> startCooldown() async {
    if (isDiamondActive) return;
    _counter = 0;
    _cooldownUntil = DateTime.now().add(diamondDuration);
    _syncTicker();
    notifyListeners();
    await _saveCounter();
    await _saveCooldownUntil();
  }

  Future<void> clearCooldown() async {
    if (_cooldownUntil == null) return;
    _cooldownUntil = null;
    _syncTicker();
    notifyListeners();
    await _saveCooldownUntil();
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

    await clearCooldown();
    await _activateDiamondFor(diamondDuration);
    await resetCounter();
    return DiamondWatchResult.activated;
  }

  bool onWordSelected() {
    if (isDiamondActive) return true;
    _completeCooldownInMemoryIfExpired();
    if (isCooldownActive) return false;
    if (_counter <= 0) return false;
    _counter -= 1;
    notifyListeners();
    unawaited(_saveCounter());
    return true;
  }

  void _completeCooldownInMemoryIfExpired({bool save = true}) {
    final until = _cooldownUntil;
    if (until == null) return;
    if (until.isAfter(DateTime.now())) return;

    _cooldownUntil = null;
    if (_counter <= 0) {
      _counter = startCounter;
    }
    if (save) {
      unawaited(_saveCooldownUntil());
      unawaited(_saveCounter());
    }
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
