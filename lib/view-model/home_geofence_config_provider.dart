import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyHomeGeofenceConfigurationProvider extends ChangeNotifier {
  bool _isCreatingGeofence = false;
  bool _isViewingGeofences = false;

  // this will act as a temporary variable to hold the coordinates before passing them to listOfPositions
  List<List<Position>> _listOfMarkedPositions = [
    [
      // Position(0, 0)
    ],
  ];

  bool get isCreatingGeofence => _isCreatingGeofence;
  bool get isViewingGeofences => _isViewingGeofences;
  List<List<Position>> get listOfMarkedPositions => _listOfMarkedPositions;

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

  void addMarkedPosition(Position position) {
    _listOfMarkedPositions[0].add(position);
    notifyListeners();

    log(
      "Successfully marked a point in geofence creation to  lng: ${position.lng}, lat: ${position.lat}",
    );
  }

  void clearMarkedPositions() {
    _listOfMarkedPositions[0].clear();
    notifyListeners();

    log("Successfully cleared marked positions");
  }
}
