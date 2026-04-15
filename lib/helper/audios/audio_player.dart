import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';

class MyAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  /// Note: remove the "assets/" becuase by default this will generate and concatenate that "assets/" string
  void playLocalAudio(String path, {bool isOnRepeatMode = false}) async {
    try {
      // For files in your assets folder
      await _player.play(AssetSource(path));
      await _player.setReleaseMode(
        (isOnRepeatMode) ? ReleaseMode.loop : ReleaseMode.release,
      );
    } catch (e, stackTrace) {
      log("ERROR WHILE PLAYING LOCAL AUDIO: $e. AT $stackTrace");
    }
  }

  /// Not yet tested (as of March 11, 2026)
  void stopRepeatMode(bool stopRepeat) async {
    try {
      await _player.setReleaseMode(
        (stopRepeat) ? ReleaseMode.release : ReleaseMode.loop,
      );
    } catch (e, stackTrace) {
      log("ERROR WHILE PLAYING LOCAL AUDIO: $e. AT $stackTrace");
    }
  }

  // void playRemoteAudio(String link) async {
  //   // For streaming from a URL
  //   await _player.play(UrlSource(link));
  // }

  /// Not yet tested (as of March 11, 2026)
  void stopAudioButDontDispose() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  void stopAudio() {
    _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
