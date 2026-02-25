import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';

class MyAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  /// Note: remove the "assets/" becuase by default this will generate and concatenate that "assets/" string
  void playLocalAudio(String path) async {
    try {
      // For files in your assets folder
      await _player.play(AssetSource(path));
    } catch (e, stackTrace) {
      log("ERROR WHILE PLAYING LOCAL AUDIO: $e. AT $stackTrace");
    }
  }

  // void playRemoteAudio(String link) async {
  //   // For streaming from a URL
  //   await _player.play(UrlSource(link));
  // }

  void stopAudio() {
    _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
