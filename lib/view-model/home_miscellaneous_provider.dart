import 'dart:developer';

import 'package:flutter/material.dart';

class MyHomeMiscellaneousProvider extends ChangeNotifier {
  bool _isIntroAnimationDone = false;

  bool get isIntroAnimationDone => _isIntroAnimationDone;

  void setIsIntroAnimationDone(bool isDone) {
    _isIntroAnimationDone = isDone;
    notifyListeners();

    if (isDone == true) log("Intro Animation successfully set to Done");
    if (isDone == false)
      log("Intro Animation successfully set to Not Yet Done");
  }
}
