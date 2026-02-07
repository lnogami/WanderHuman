import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyHomeGeofenceConfigurationProvider extends ChangeNotifier {
  bool _isCreatingGeofence = false;
  bool _isViewingGeofences = false;
  // This two Managers are for temporary scenarios like when creating a safe zone (geofence)
  PolygonAnnotationManager? _markedPolygonAnnotationManager;
  PointAnnotationManager? _markedPointAnnotationManager;

  /// this will hold the list of marked positions that will be used as an argument for deleting specific point annotations in [_markedPointAnnotationManager]
  final List<PointAnnotation> _listOfMarkedPointAnnotations = [];
  // this will act as a temporary variable to hold the coordinates before passing them to listOfPositions
  final List<List<Position>> _listOfMarkedPositions = [
    [
      // Position(0, 0)
    ],
  ];

  bool get isCreatingGeofence => _isCreatingGeofence;
  bool get isViewingGeofences => _isViewingGeofences;
  List<List<Position>> get listOfMarkedPositions => _listOfMarkedPositions;
  PolygonAnnotationManager? get markedPolygonAnnotationManager =>
      _markedPolygonAnnotationManager;
  PointAnnotationManager? get markedPointAnnotationManager =>
      _markedPointAnnotationManager;
  List<PointAnnotation> get listOfMarkedPointAnnotations =>
      _listOfMarkedPointAnnotations;

  // For when creating a new geofence.
  void toggleGeofenceCreation(bool value) {
    _isCreatingGeofence = value;
    notifyListeners();

    log("Successfully toggled geofence creation to $value");
  }

  // For when viewing existing geofences.
  void toggleGeofenceViewing(bool value) {
    _isViewingGeofences = value;
    notifyListeners();

    log("Successfully toggled geofence viewing to $value");
  }

  // For adding a mark to a specific Position (coordinates in the map) that will be used for creating a geofence, this will be added to the listOfMarkedPositions which will then be used for drawing the geofence polygon.
  void addMarkedPosition(Position position) {
    _listOfMarkedPositions[0].add(position);
    notifyListeners();

    log(
      "Successfully marked a point in geofence creation to  lng: ${position.lng}, lat: ${position.lat}",
    );
  }

  // For clearing the list of marked positions, this will be used for when the user wants to clear all the marked positions and start over in creating a geofence.
  void clearMarkedPositions() {
    _listOfMarkedPositions[0].clear();
    notifyListeners();

    log("Successfully cleared marked positions");
  }

  // For setting up PolygonAnnotationManager and PointAnnotationManager, this will be used for when the user wants to start creating a geofence, we need to initialize these two managers to be able to draw the polygon and the points in the map.
  void initPolygonAndPointManagers({
    required PolygonAnnotationManager polygonManager,
    required PointAnnotationManager pointManager,
  }) {
    _markedPolygonAnnotationManager = polygonManager;
    _markedPointAnnotationManager = pointManager;
    notifyListeners();

    log(
      "Successfully initialized PolygonAnnotationManager and PointAnnotationManager for geofence creation",
    );
  }

  /// This will be used for storing a copy of the created PointAnnotation in the [_markedPolygonAnnotationManager]
  void addTempPointAnnotation(PointAnnotation annotation) {
    _listOfMarkedPointAnnotations.add(annotation);
    notifyListeners();

    log(
      "Successfully added a temporary point annotation for geofence creation",
    );
  }

  /// This will remove a marked position at the specified index
  void removeMarkedAnnotationPositionAt(int index) {
    if (_listOfMarkedPointAnnotations.isEmpty) {
      log("No marked point annotations to remove.");
      return;
    }

    final annotationToDelete = _listOfMarkedPointAnnotations[index];

    _markedPointAnnotationManager?.delete(annotationToDelete);
    _listOfMarkedPointAnnotations.removeAt(index);
    // _listOfMarkedPositions[0].removeAt(index);
    notifyListeners();

    log("Successfully removed marked position at index $index");
  }
}
