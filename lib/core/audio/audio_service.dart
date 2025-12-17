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
      final trimmed = url.trim();
      final encodedUrl = Uri.encodeFull(trimmed);
      _currentUrl = trimmed;
      _currentEncodedUrl = encodedUrl;
      await _player.stop();
      await _player.setUrl(encodedUrl);
      await _player.play();
    } catch (e) {
      debugPrint('AudioService: failed to play url: $e');
      rethrow;
    }
  }

  Future<void> stop() {
    _currentUrl = null;
    _currentEncodedUrl = null;
    return _player.stop();
  }
}
