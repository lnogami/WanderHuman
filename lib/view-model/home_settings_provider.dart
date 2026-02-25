import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/settings_model.dart';

class MyHomeSettingsProvider extends ChangeNotifier {
  double? _zoomLevel;
  bool? _alwaysFollowYourAvatar;

  double get zoomLevel => _zoomLevel ?? 15.0;
  bool get alwaysFollowYourAvatar => _alwaysFollowYourAvatar ?? true;

  /// Initializes all the user settings data
  Future<void> initUserSettings(MySettingsModel settings) async {
    setZoomLevel(settings.zoomLevel);
    setAlwaysFollowYourAvatar(settings.alwaysFollowYourAvatar);
  }

  MySettingsModel getUserSettings() {
    return MySettingsModel(
      userID: "",
      zoomLevel: zoomLevel,
      alwaysFollowYourAvatar: alwaysFollowYourAvatar,
    );
  }

  void setZoomLevel(double value) {
    _zoomLevel = value;
    notifyListeners();
  }

  void setAlwaysFollowYourAvatar(bool value) {
    _alwaysFollowYourAvatar = value;
    notifyListeners();
  }
}
