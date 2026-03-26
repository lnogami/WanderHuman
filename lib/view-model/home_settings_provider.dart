import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/settings_model.dart';

class MyHomeSettingsProvider extends ChangeNotifier {
  double? _zoomLevel;
  bool? _alwaysFollowYourAvatar;
  bool? _useDefaultAvatar;
  bool? _enableAvatarDistanceAccuracy;
  int? _mapView;

  // bool? _useDefaultAvatar;
  // bool? _enableAvatarDistanceAccuracy;

  double get zoomLevel => _zoomLevel ?? 15.0;
  bool get alwaysFollowYourAvatar => _alwaysFollowYourAvatar ?? true;
  bool get useDefaultAvatar => _useDefaultAvatar ?? true;
  bool get enableAvatarDistanceAccuracy =>
      _enableAvatarDistanceAccuracy ?? true;
  int get mapView => _mapView ?? 0;

  /// Initializes all the user settings data
  Future<void> initUserSettings(MySettingsModel settings) async {
    setZoomLevel(settings.zoomLevel);
    setAlwaysFollowYourAvatar(settings.alwaysFollowYourAvatar);
    setToUseDefaultAvatar(settings.useDefaultAvatar);
    setEnableAvatarDistanceAccuracy(settings.enableAvatarDistanceAccuracy);
    setMapView(settings.mapView);
  }

  MySettingsModel getUserSettings() {
    return MySettingsModel(
      userID: "",
      zoomLevel: zoomLevel,
      alwaysFollowYourAvatar: alwaysFollowYourAvatar,
      useDefaultAvatar: useDefaultAvatar,
      enableAvatarDistanceAccuracy: enableAvatarDistanceAccuracy,
      mapView: mapView,
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

  void setToUseDefaultAvatar(bool value) {
    _useDefaultAvatar = value;
    notifyListeners();
  }

  void setEnableAvatarDistanceAccuracy(bool value) {
    _enableAvatarDistanceAccuracy = value;
    notifyListeners();
  }

  void setMapView(int value) {
    _mapView = value;
    notifyListeners();
    log("MMMMMMMMMapView was successfully set to $value");
  }
}
