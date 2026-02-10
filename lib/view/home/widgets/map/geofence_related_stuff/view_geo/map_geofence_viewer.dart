import 'dart:developer';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/helper/geofence_repository.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/map_geofence_drawer.dart';

class MyMapGeofenceViewer {
  static Future<void> viewAllGeofences(
    PolygonAnnotationManager polygonManager,
  ) async {
    try {
      List<MyGeofenceModel> allGeofences =
          await MyGeofenceRepository.getAllGeofences();

      for (final geofence in allGeofences) {
        // This will draw the geofence polygon in the map using the coordinates stored in the geofence model, and the polygon will be added to the PolygonAnnotationManager which will then be displayed in the map.
        MyMapGeofenceDrawer.drawPolygon(
          polygonManager: polygonManager,
          positions: [geofence.geofenceCoordinates],
        );
      }
    } catch (e, stackTrace) {
      log("ERROR WHILE VIEWING GEOFENCES: $e. AT $stackTrace");
    }
  }
}
