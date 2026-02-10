import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;
  String? _currentEncodedUrl;

  Stream<bool> get playingStream => _player.playingStream;
  String? get currentUrl => _currentUrl;
  String? get currentEncodedUrl => _currentEncodedUrl;

  Future<void> playUrl(String url) async {
    if (url.trim().isEmpty) return;
    try {
      final trimmed = url.trim().replaceAll('\\', '/');
      _currentUrl = trimmed;
      await _player.stop();
      final parsed = Uri.tryParse(trimmed);
      final scheme = (parsed?.scheme ?? '').toLowerCase();

      if (scheme == 'http' || scheme == 'https') {
        final encodedUrl = Uri.encodeFull(trimmed);
        _currentEncodedUrl = encodedUrl;
        await _player.setUrl(encodedUrl);
      } else if (_looksLikeBundledAssetPath(trimmed)) {
        final chosenAsset = await _setFromAssetCandidates(trimmed);
        _currentEncodedUrl = chosenAsset;
      } else if (scheme == 'file' && parsed != null) {
        final filePath = parsed.toFilePath();
        _currentEncodedUrl = trimmed;
        await _player.setFilePath(filePath);
      } else {
        _currentEncodedUrl = trimmed;
        await _player.setFilePath(trimmed);
      }

      await _player.play();
    } catch (e) {
      debugPrint('AudioService: failed to play url: $e');
      rethrow;
    }
  }

  bool _looksLikeBundledAssetPath(String input) {
    if (input.startsWith('assets/')) return true;
    if (input.startsWith('/')) return false;
    if (RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(input)) return false;
    if (input.contains('://')) return false;
    return true;
  }

  Future<String> _setFromAssetCandidates(String input) async {
    final normalized = input.trim().replaceAll('\\', '/');
    final candidates = <String>{
      normalized,
      if (normalized.startsWith('assets/'))
        normalized.substring('assets/'.length),
      if (!normalized.startsWith('assets/')) 'assets/$normalized',
    }.where((e) => e.trim().isNotEmpty).toList();

    Object? firstError;
    for (final candidate in candidates) {
      try {
        await _player.setAsset(candidate);
        return candidate;
      } catch (e) {
        firstError ??= e;
      }
    }

    throw firstError ?? Exception('Unable to load asset audio: $input');
  }

  Future<void> stop() {
    _currentUrl = null;
    _currentEncodedUrl = null;
    return _player.stop();
  }
}
