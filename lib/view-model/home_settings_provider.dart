import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/settings_model.dart';

class MyHomeSettingsProvider extends ChangeNotifier {
  double? _zoomLevel;
  bool? _alwaysFollowYourAvatar;
  bool? _useDefaultAvatar;
  bool? _enableAvatarDistanceAccuracy;
  int? _mapView;
  bool? _enableBatteryPercentage;
  bool? _minimizeHomePageButtons;

  // bool? _useDefaultAvatar;
  // bool? _enableAvatarDistanceAccuracy;

  double get zoomLevel => _zoomLevel ?? 15.0;
  bool get alwaysFollowYourAvatar => _alwaysFollowYourAvatar ?? true;
  bool get useDefaultAvatar => _useDefaultAvatar ?? false;
  bool get enableAvatarDistanceAccuracy =>
      _enableAvatarDistanceAccuracy ?? true;
  int get mapView => _mapView ?? 0;
  bool get enableBatteryPercentage => _enableBatteryPercentage ?? false;
  bool get minimizeHomePageButtons => _minimizeHomePageButtons ?? false;

  /// Initializes all the user settings data
  Future<void> initUserSettings(MySettingsModel settings) async {
    setZoomLevel(settings.zoomLevel);
    setAlwaysFollowYourAvatar(settings.alwaysFollowYourAvatar);
    setToUseDefaultAvatar(settings.useDefaultAvatar);
    setEnableAvatarDistanceAccuracy(settings.enableAvatarDistanceAccuracy);
    setMapView(settings.mapView);
    setEnableBatteryPercentage(settings.enableBatteryPercentage);
    setMinimizeHomePageButtons(settings.minimizeHomePageButtons);
  }

  void resetUserSettings() {
    _zoomLevel = null;
    _alwaysFollowYourAvatar = null;
    _useDefaultAvatar = null;
    _enableAvatarDistanceAccuracy = null;
    _mapView = null;
    _enableBatteryPercentage = null;
    _minimizeHomePageButtons = null;
    notifyListeners();
  }

  MySettingsModel getUserSettings() {
    return MySettingsModel(
      userID: "",
      zoomLevel: zoomLevel,
      alwaysFollowYourAvatar: alwaysFollowYourAvatar,
      useDefaultAvatar: useDefaultAvatar,
      enableAvatarDistanceAccuracy: enableAvatarDistanceAccuracy,
      mapView: mapView,
      enableBatteryPercentage: enableBatteryPercentage,
      minimizeHomePageButtons: minimizeHomePageButtons,
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

  void setEnableBatteryPercentage(bool value) {
    _enableBatteryPercentage = value;
    notifyListeners();
  }

  void setMinimizeHomePageButtons(bool value) {
    _minimizeHomePageButtons = value;
    notifyListeners();
  }
}
