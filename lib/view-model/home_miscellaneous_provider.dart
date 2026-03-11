import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/audios/audio_player.dart';

class MyHomeMiscellaneousProvider extends ChangeNotifier {
  bool _isIntroAnimationDone = false;
  final MyAudioPlayer _alarmAudio = MyAudioPlayer();

  bool get isIntroAnimationDone => _isIntroAnimationDone;

  void setIsIntroAnimationDone(bool isDone) {
    _isIntroAnimationDone = isDone;
    notifyListeners();

    if (isDone == true) log("Intro Animation successfully set to Done");
    if (isDone == false)
      log("Intro Animation successfully set to Not Yet Done");
  }

  // For alarm
  void playAlarmAudio() {
    _alarmAudio.playLocalAudio(
      "audios/warning_alarm.mp3",
      isOnRepeatMode: true,
    );
  }

  void stopAlarmAudio() {
    _alarmAudio.stopAudio();
  }

  void disposeAlarmAudio() {
    _alarmAudio.dispose();
  }
}
