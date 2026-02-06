import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';

class MyMapGeofenceDrawer {
  // Sample geofence polygon points
  static final customShapePoints = [
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
  static void drawPolygon({
    required PolygonAnnotationManager polygonManager,
    required List<List<Position>> positions,
  }) async {
    await polygonManager.deleteAll();

    // A polygon needs at least 3 points to be visible (4 if you count closing the loop)
    if (positions[0].isEmpty || positions[0].length < 3) {
      return;
    }

    final List<List<Position>> drawablePositions = [List.from(positions[0])];

    // This is for adding a closing point to a polygon, think of it as drawing a triangle,
    // you start the stroke with a point to the second point, then to the third, then the last stroke goes back to where you started.
    // drawablePositions[0].add(drawablePositions[0][0]);

    for (var drawablePosition in drawablePositions[0]) {
      log(
        "drawablePosition in drawablePositions collection: lng: ${drawablePosition.lng}, lat: ${drawablePosition.lat}",
      );
    }

    polygonManager.create(
      PolygonAnnotationOptions(
        // geometry: Polygon(coordinates: customShapePoints),
        geometry: Polygon(coordinates: drawablePositions),
        fillColor: Colors.blue.toARGB32(),
        fillOpacity: 0.2,
        fillOutlineColor: Colors.black.toARGB32(),
        fillConstructBridgeGuardRail: true,
        fillZOffset: 10,
        // fil
      ),
    );

    // final PolygonAnnotationManager polygonManager = await mapboxMapController
    //     .annotations
    //     .createPolygonAnnotationManager();

    // await polygonManager.deleteAll();

    // // Check the inner list (the first ring of the polygon)
    // if (positions.isEmpty || positions[0].length < 3) {
    //   return;
    // }

    // // DEEP COPY the positions to avoid corrupting the Provider data
    // // This creates a new list so we don't keep adding 'closing points' to the original
    // List<List<Position>> drawablePositions = [List.from(positions[0])];

    // // Mapbox requires the last point to be identical to the first to close the loop
    // drawablePositions[0].add(drawablePositions[0][0]);

    // for (var position in drawablePositions[0]) {
    //   log("Drawing point: lng: ${position.lng}, lat: ${position.lat}");
    // }

    // polygonManager.create(
    //   PolygonAnnotationOptions(
    //     geometry: Polygon(coordinates: drawablePositions),
    //     fillColor: Colors.blue.withOpacity(0.3).toARGB32(),
    //     fillOutlineColor: Colors.black.toARGB32(),
    //     fillZOffset: 10,
    //   ),
    // );

    // final polygonManager = await mapboxMapController.annotations
    //     .createPolygonAnnotationManager();
    // // Clear existing polygons before drawing the updated one
    // await polygonManager.deleteAll();
    // // A polygon needs at least 3 points to be visible (4 if you count closing the loop)
    // if (positions[0].length < 3) return;
    // polygonManager.create(
    //   PolygonAnnotationOptions(
    //     geometry: Polygon(coordinates: positions),
    //     fillColor: Colors.blue.withOpacity(0.2).toARGB32(),
    //     fillOutlineColor: Colors.black.toARGB32(),
    //   ),
    // );
  }

  /// This is for marking the pressed position when the user is creating the polygon of the geofence
  static void markPressedPoints({
    required PointAnnotationManager pointManager,
    required Point tappedPoint,
    required BuildContext context,
  }) async {
    pointManager.create(
      PointAnnotationOptions(
        geometry: tappedPoint,
        image: await imageToIconLoader("assets/icons/location_marker.png"),
        iconSize: 0.035,
      ),
    );

    // listOfMarkedPositions[0].add(
    //   Position(tappedPoint.coordinates.lng, tappedPoint.coordinates.lat),
    // );
    if (context.mounted) {
      context.read<MyHomeGeofenceConfigurationProvider>().addMarkedPosition(
        Position(tappedPoint.coordinates.lng, tappedPoint.coordinates.lat),
      );
    }
  }

  // for loading an image asset an converting it into a Uint8List
  static Future<Uint8List> imageToIconLoader(String imagePath) async {
    var byteData = await rootBundle.load(imagePath);
    return byteData.buffer.asUint8List();
  }

  // // This will return a Point object where the tapped point is in the map
  // Future<Point> clickedPoint(
  //   MapboxMap mapboxMapController,
  //   Point tappedPoint,
  // ) async {
  //   PointAnnotationManager pointAnnotationManager = await mapboxMapController
  //       .annotations
  //       .createPointAnnotationManager();
  //   pointAnnotationManager.create(
  //     PointAnnotationOptions(
  //       geometry: tappedPoint,
  //       image: await imageToIconLoader("assets/icons/location_marker.png"),
  //     ),
  //   );
  //   return Point(
  //     coordinates: Position(
  //       tappedPoint.coordinates.lng,
  //       tappedPoint.coordinates.lat,
  //     ),
  //   );
  // }
}
