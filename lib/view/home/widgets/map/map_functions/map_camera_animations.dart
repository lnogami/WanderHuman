import 'dart:developer';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyMapCameraAnimations {
  /// This function will move the camera to a specific location on the map (based on patient's location)
  /// patientID must be provided to enable flyTo
  static Future<void> myMapFlyTo({
    required MapboxMap mapboxController,
    required Position position,
    // required String patientID,
    double zoomLevel = 15.0,
    int animationDurationInMilliseconds = 700,
  }) async {
    try {
      double lng = position.lng.toDouble();
      double lat = position.lat.toDouble();

      mapboxController.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(lng, lat)),
          zoom: zoomLevel,
        ),
        MapAnimationOptions(duration: animationDurationInMilliseconds),
      );
    } catch (e, stackTrace) {
      log("AN ERROR OCCURED IN myMapFlyTo method: $e. AT $stackTrace");
    }

    // var interaction = TapInteraction(, );
    // mapboxController.addInteraction(interaction);
  }

  /// This will do a zoom animation on the map
  static Future<void> myMapZoom({
    required MapboxMap mapboxController,
    required double zoomLevel,
    Position? position,
    int animationDurationInMilliseconds = 700,
  }) async {
    try {
      mapboxController.easeTo(
        CameraOptions(
          center: (position != null) ? Point(coordinates: position) : null,
          zoom: zoomLevel,
        ),
        MapAnimationOptions(duration: animationDurationInMilliseconds),
      );
    } catch (e, stackTrace) {
      log("AN ERROR OCCURED IN myMapZoom method: $e. AT $stackTrace");
    }
  }
}
