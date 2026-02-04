import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyMapGeofence {
  // Sample geofence polygon points
  static final _customShapePoints = [
    [
      // Position(125.801, 7.441),
      // Position(125.805, 7.441),
      // Position(125.805, 7.438),
      // Position(125.803, 7.438),
      // Position(125.803, 7.440),
      // Position(125.801, 7.440),
      // Position(125.801, 7.441), // Closing the loop

      // testing purposes only
      Position(125.79811, 7.42784),
      Position(125.79937, 7.42688),
      Position(125.80123, 7.42712),
      Position(125.80336, 7.42956),
      Position(125.80139, 7.43204),
      Position(125.79735, 7.43112),
      Position(125.79811, 7.42784), // Closing the loop
    ],
  ];

  /// This is the actual visible geofence area
  static void drawPolygon({required MapboxMap mapboxMapController}) async {
    final PolygonAnnotationManager polygonManager = await mapboxMapController
        .annotations
        .createPolygonAnnotationManager();

    polygonManager.create(
      PolygonAnnotationOptions(
        geometry: Polygon(coordinates: _customShapePoints),
        fillColor: Colors.blue.toARGB32(),
        fillOpacity: 0.2,
        fillOutlineColor: Colors.black.toARGB32(),
        fillConstructBridgeGuardRail: true,
        fillZOffset: 10,
        // fil
      ),
    );
  }

  /// This is for marking the pressed position when the user is creating the polygon of the geofence
  static void markPressedPoints({
    required MapboxMap mapboxMapController,
  }) async {
    final PointAnnotationManager pointManager = await mapboxMapController
        .annotations
        .createPointAnnotationManager();

    pointManager.create(
      PointAnnotationOptions(
        // position to be change
        geometry: Point(coordinates: Position(125.79811, 7.42784)),
        iconImage: "",
      ),
    );
  }
}
