import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;

  Stream<bool> get playingStream => _player.playingStream;
  String? get currentUrl => _currentUrl;

  Future<void> playUrl(String url) async {
    if (url.trim().isEmpty) return;
    try {
      _currentUrl = url;
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('AudioService: failed to play url: $e');
      rethrow;
    }
  }

  Future<void> stop() {
    _currentUrl = null;
    return _player.stop();
  }
}
