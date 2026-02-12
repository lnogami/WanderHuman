// import 'dart:developer';

// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
// import 'package:wanderhuman_app/helper/geofence_repository.dart';
// import 'package:wanderhuman_app/model/geofence_model.dart';
// import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/map_geofence_drawer.dart';

// /// Just only for setting-up once the geofences
// Future<void> setupGeofences({
//   required mp.MapboxMap mapboxMapController,
//   required mp.PolygonAnnotationManager polygonAnnotationManager,
//   required mp.PointAnnotationManager pointAnnotationManager,
//   required int numberOfActiveGeofences,
// }) async {
//   try {
//     List<MyGeofenceModel> activeGeofences =
//         await MyGeofenceRepository.getActiveGeofences();

//     // return if there are no active geofences
//     if (activeGeofences.isEmpty) return;

//     polygonAnnotationManager = await mapboxMapController.annotations
//         .createPolygonAnnotationManager();

//     numberOfActiveGeofences = activeGeofences.length;

//     for (final geofence in activeGeofences) {
//       MyMapGeofenceDrawer.drawPolygon(
//         polygonManager: polygonAnnotationManager,
//         positions: [
//           geofence.geofenceCoordinates
//               .map((pos) => mp.Position(pos.lng, pos.lat))
//               .toList(),
//         ],
//       );
//     }

//     log("The number of active geofences is: $numberOfActiveGeofences");
//   } catch (e, stackTrace) {
//     log("ERROR WHILE SETTING UP GEOFENCES: $e. AT $stackTrace");
//   }
// }
