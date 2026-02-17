// import 'dart:developer';
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:wanderhuman_app/helper/geofence_repository.dart';
import 'package:wanderhuman_app/helper/history_reposity.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/model/realtime_location_model.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/bottom_modal_sheet_for_patient.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/geo_logics/notifcation_alerts.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/geo_logics/turf.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/point_annotation_options.dart';

class ListenToPatients {
  static List<PersonalInfo> _patientsList = [];
  // Keep track of subscriptions so we can cancel them later to save bandwidth
  static final Map<String, StreamSubscription> _locationSubscriptions = {};

  // // Geofence logic object
  // MyGeofenceLogic geofenceLogic = MyGeofenceLogic();

  static Future<void> _getAllPatients() async {
    _patientsList = await MyPersonalInfoRepository.getAllPersonalInfoRecords(
      fieldName: "userType",
      valueToLookFor: "Patient",
    );
  }

  /// Call this method to cancel all the subcriptions at once
  static void stopListening() {
    try {
      for (var patient in _patientsList) {
        _locationSubscriptions[patient.deviceID]?.cancel();
      }
      // Clear the map so we know they are gone
      _locationSubscriptions.clear();
      log(
        "Notice: 🛑 All patient location listeners were successfully stopped.",
      );
    } catch (e, stackTrace) {
      log(
        "ERROR ON STOPLISTENING METHOD in ListenToPatients class: $e. AT $stackTrace",
      );
    }
  }

  /// To listen to patients realtime location data
  static void listenToPatients({
    required Map<String, Map<String, dynamic>> annotationData,
    required Map<String, mp.PointAnnotation> userAnnotations,
    mp.PointAnnotationManager? pointAnnotationManager,
    required BuildContext context,
    List<MyGeofenceModel>? activeGeofences,
  }) async {
    try {
      // 1. Fetch all patients from Firestore (Personal Info)
      await _getAllPatients();

      List<MyGeofenceModel> activeGeofences =
          await MyGeofenceRepository.getActiveGeofences();

      // for debugging purposes only
      for (var p in _patientsList) {
        log("PATIENTSSSSSSSSSSSSSSSSSSSSSSSSS: ${p.name}");
        log("PATIENT IDDDDDDDDDDDDDDDDDDDDDDD: ${p.userID}");
        log("DEVICE IDDDDDDDDDDDDDDDDDDDDDDDD: ${p.deviceID}");
      }

      // Create a random number generator for ID generation for each patient so that each of them have different notifications.
      math.Random randomNumberGenerator = math.Random();
      // 2. Loop through patients and attach a REALTIME listener to each
      for (var patient in _patientsList) {
        String deviceID = patient.deviceID;
        int randomGeneratedID = randomNumberGenerator.nextInt(100);

        // Cancel existing subscription if it exists to avoid memory leaks
        await _locationSubscriptions[deviceID]?.cancel();

        _locationSubscriptions[deviceID] =
            MyRealtimeLocationReposity.getRealtimePatientLocationStream(
              deviceID: deviceID,
            ).listen((MyRealtimeLocationModel realtimeLocModel) async {
              try {
                // Parse coordinates safely
                double lng =
                    double.tryParse(realtimeLocModel.currentLocationLng) ?? 0.0;
                double lat =
                    double.tryParse(realtimeLocModel.currentLocationLat) ?? 0.0;

                // Prepare metadata for the Bottom Sheet
                annotationData[deviceID] = {
                  'name': patient.name,
                  'patientID': realtimeLocModel.patientID,
                  'lng': lng,
                  'lat': lat,
                  'currentlyIn': realtimeLocModel.currentlyIn,
                  'isInSafeZone': realtimeLocModel.isInSafeZone,
                  'timeStamp': realtimeLocModel.timeStamp,
                  'deviceBatteryPercentage': realtimeLocModel
                      .deviceBatteryPercentage
                      .toString(),
                  'age': patient.age,
                  'sex': patient.sex,
                  'contactInfo': patient.contactNumber,
                  'address': patient.address,
                  'notableBehavior': patient.notableBehavior,
                };

                // Decode the patient icon
                final Uint8List patientIcon =
                    MyImageProcessor.decodeStringToUint8List(patient.picture);

                // 3. MAPBOX UPDATE LOGIC
                // Remove old annotation if it exists
                if (userAnnotations.containsKey(deviceID)) {
                  await pointAnnotationManager?.delete(
                    userAnnotations[deviceID]!,
                  );
                }

                // Create new annotation at updated location
                var newAnnotation = await pointAnnotationManager?.create(
                  await myPointAnnotationOptions(
                    name: patient.name,
                    myPosition: mp.Position(lng, lat),
                    imageData: patientIcon,
                  ),
                );

                // if the newAnnotation is not null, add it to a specific userAnnoation
                if (newAnnotation != null) {
                  userAnnotations[deviceID] = newAnnotation;
                }

                // 4. Setup Tap Events (Do this once or update properly)
                _setupMapTapEvents(
                  pointAnnotationManager: pointAnnotationManager!,
                  userAnnotations: userAnnotations,
                  annotationData: annotationData,
                  // ignore: use_build_context_synchronously
                  context: context,
                );

                // This will determine if a patient is inside a safe zone or not
                var isInsideSafeZone =
                    await MyGeofenceLogic.isPatientInsideTheAssignedSafeZone(
                      userPosition: mp.Position(lng, lat),
                      activeGeofences: activeGeofences,
                      userID: patient.userID,
                    );

                // Notifies if the patient is not inside the safe zone
                if (!isInsideSafeZone) {
                  MyAlertNotification.triggerSafeZoneAlert(
                    patientName: patient.name,
                    randomGeneratedIDForAlert: randomGeneratedID,
                  );
                }

                // Saves the lcation data of the patient to the database
                await MyHistoryReposity.savePatientLocation(
                  locationData: realtimeLocModel,
                );

                // for debugging purposes only
                log(
                  "🗺️ Patient ${patient.name} is inside the Safe Zone: --> $isInsideSafeZone",
                );
                log(
                  "POSITION of patient with ID ${patient.userID} is lng:$lng, lat:$lat",
                );
              } catch (e, stackTrace) {
                log("ERROR UPDATING MARKER FOR $deviceID: $e. AT $stackTrace");
              }
            });
      }

      log(
        "Notice:✅ Successfully listening to ${_patientsList.length} patients realtime locations.",
      );
    } catch (e, stackTrace) {
      log("ERROR ON LISTENTOPATIENTS METHOD: $e. AT $stackTrace");
    }
  }

  static void _setupMapTapEvents({
    required Map<String, Map<String, dynamic>> annotationData,
    required Map<String, mp.PointAnnotation> userAnnotations,
    mp.PointAnnotationManager? pointAnnotationManager,
    required BuildContext context,
  }) {
    // set up tap events ONCE, outside the loop
    pointAnnotationManager?.tapEvents(
      onTap: (mp.PointAnnotation tappedAnnotation) {
        // find which document this annotation belongs to
        String? docId = userAnnotations.entries
            .firstWhere(
              (entry) => entry.value == tappedAnnotation,
              orElse: () => MapEntry('', tappedAnnotation),
            )
            .key;

        if (docId.isNotEmpty && annotationData.containsKey(docId)) {
          var data = annotationData[docId]!;
          showMyBottomNavigationSheet(
            context: context,
            name: "${data['name']} : ${data['number']}",
            sex: data['sex'] ?? "NO DATA ACQUIRED",
            age: data['age'] ?? "NO DATA ACQUIRED",
            contactInfo: data['contactInfo'] ?? "NO DATA ACQUIRED",
            address: data['address'] ?? "NO DATA ACQUIRED",
            notableBehavior: data['notableBehavior'] ?? "NO DATA ACQUIRED",
          );
        }
      },
    );
  }
}
