import 'dart:developer';

import 'package:flutter/material.dart';

class MyHomeGeofenceConfigurationProvider extends ChangeNotifier {
  bool _isCreatingGeofence = false;
  bool _isViewingGeofences = false;

  bool get isCreatingGeofence => _isCreatingGeofence;
  bool get isViewingGeofences => _isViewingGeofences;

  void toggleGeofenceCreation(bool value) {
    _isCreatingGeofence = value;
    notifyListeners();

    log("Successfully toggled geofence creation to $value");
  }

  void toggleGeofenceViewing(bool value) {
    _isViewingGeofences = value;
    notifyListeners();

    log("Successfully toggled geofence creation to $value");
  }
}
