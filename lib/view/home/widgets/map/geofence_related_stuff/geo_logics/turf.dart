import 'dart:developer';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:turf/turf.dart' as turf;
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';

// Older version of the function
// bool isInsideTheAssignedSafeZone({
//   required mp.Position userPosition,
//   required List<MyGeofenceModel> activeGeofences,
// }) {
//   final userCoordinate = turf.Position.of([userPosition.lng, userPosition.lat]);
//
//   for (MyGeofenceModel geofence in activeGeofences) {
//     // in each MyGeofenceModel get the geofence coordinates
//     List<mp.Position> zoneCoordinates = geofence.geofenceCoordinates;
//     // just in case the coordinates provided is empty
//     if (zoneCoordinates.isEmpty) continue;
//
//     // convert the mapbox Position object to a turf Position object
//     List<turf.Position> outerRing = zoneCoordinates.map((mp.Position position) {
//       return turf.Position.of([position.lng, position.lat]);
//     }).toList();
//
//     // ensure the ring is closed (Turf requirement)
//     if (outerRing.first != outerRing.last) {
//       outerRing.add(outerRing.first);
//     }
//
//     // since we only need the outside (boundary) part of the polygon we only provided the outerRing or the first List of Position (List<Position>)
//     final polygon = turf.Polygon(coordinates: [outerRing]);
//
//     // lastly, check if the point is inside this specific geofence
//     if (turf.booleanPointInPolygon(userCoordinate, polygon)) {
//       return true; // If they are inside ANY of the active zones, they are safe
//     }
//   }
//
//   return false;
// }

class MyGeofenceLogic {
  static Future<bool> isPatientInsideTheAssignedSafeZone({
    required mp.Position userPosition,
    required List<MyGeofenceModel> activeGeofences,
    required String userID,
  }) async {
    try {
      final userCoordinate = turf.Position.of([
        userPosition.lng,
        userPosition.lat,
      ]);
      // to determine if patient is registered in at least one safezone or not
      bool isPatientRegisteredAtLeastOneSafeZone = false;

      for (MyGeofenceModel geofence in activeGeofences) {
        // checks if the patient is registered in this geofence
        if (geofence.registeredPatients.contains(userID)) {
          isPatientRegisteredAtLeastOneSafeZone = true;

          // in each MyGeofenceModel get the geofence coordinates
          List<mp.Position> zoneCoordinates = geofence.geofenceCoordinates;
          // just in case the coordinates provided is empty
          if (zoneCoordinates.isEmpty) continue;

          // convert the mapbox Position object to a turf Position object
          List<turf.Position> outerRing = zoneCoordinates.map((
            mp.Position position,
          ) {
            return turf.Position.of([position.lng, position.lat]);
          }).toList();

          // ensure the ring is closed (Turf requirement)
          if (outerRing.first != outerRing.last) {
            outerRing.add(outerRing.first);
          }

          // since we only need the outside (boundary) part of the polygon we only provided the outerRing or the first List of Position (List<Position>)
          final polygon = turf.Polygon(coordinates: [outerRing]);

          log(
            "Patient ID: $userID is currently insdie --> Safezone Name: ${geofence.geofenceName}",
          );

          // lastly, check if the point is inside this specific geofence
          if (turf.booleanPointInPolygon(userCoordinate, polygon)) {
            return true; // inside the safezone
          }
          //// this is for scenario that a patient must only be inside one safe zone
          // else {
          //   // for debuggin purposes only
          //   log(
          //     "🗺️🗺️ Patient: $userID is not in this Safezone (${geofence.geofenceName})",
          //   );
          //   return false; // not inside the safezone
          // }
        }

        // --- ONLY REACHED IF NOT INSIDE ANY GEOFENCE ---
        if (!isPatientRegisteredAtLeastOneSafeZone) {
          log("⚠️ No geofences were even registered for Patient: $userID");
        } else {
          // Use an await here instead of .then() to keep logs in order
          final personalInfo =
              await MyPersonalInfoRepository.getSpecificPersonalInfo(
                userID: userID,
              );
          log(
            "🚨 ALERT: Patient ${personalInfo.name} is OUTSIDE of all assigned safezones!",
          );
        }
      }
      return false;
    } catch (e, stackTrace) {
      log(
        "An error occurred in isInsideTheAssignedSafeZone: $e. AT $stackTrace",
      );
      rethrow;
    }
  }
}
