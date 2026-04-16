// // import 'dart:developer';
// import 'dart:async';
// import 'dart:developer';
// import 'dart:math' as math;
// import 'dart:typed_data';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
// import 'package:wanderhuman_app/helper/geofence_repository.dart';
// import 'package:wanderhuman_app/helper/history_reposity.dart';
// import 'package:wanderhuman_app/helper/personal_info_repository.dart';
// import 'package:wanderhuman_app/helper/realtime_active_status_repository.dart';
// import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
// import 'package:wanderhuman_app/model/geofence_model.dart';
// import 'package:wanderhuman_app/model/personal_info.dart';
// import 'package:wanderhuman_app/model/realtime_active_status_model.dart';
// import 'package:wanderhuman_app/model/realtime_location_model.dart';
// import 'package:wanderhuman_app/view/components/image_picker.dart';
// import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
// import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/bottom_modal_sheet_for_patient.dart';
// import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/geo_logics/notifcation_alerts.dart';
// import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/geo_logics/turf.dart';
// import 'package:wanderhuman_app/view/home/widgets/map/map_functions/point_annotation_options.dart';

// class ListenToPatients {
//   static final List<PersonalInfo> _patientsList = [];
//   // Keep track of subscriptions so we can cancel them later to save bandwidth
//   static final Map<String, StreamSubscription> _locationSubscriptions = {};

//   // // Geofence logic object
//   // MyGeofenceLogic geofenceLogic = MyGeofenceLogic();

//   static Future<void> _getAllPatients() async {
//     if (_patientsList.isNotEmpty) _patientsList.clear();

//     List<MyRealtimeActiveStatusModel> allActivePersons =
//         await MyRealtimeActiveStatusRepository.getAllDeviceIDWithActiveStatus();

//     for (var person in allActivePersons) {
//       // skip if it is the currently logged in user
//       if (person.userID == FirebaseAuth.instance.currentUser!.uid) continue;

//       _patientsList.add(
//         await MyPersonalInfoRepository.getSpecificPersonalInfo(
//           userID: person.userID,
//         ),
//       );
//     }
//     // _patientsList = await MyPersonalInfoRepository.getAllPersonalInfoRecords(
//     //   fieldName: "userType",
//     //   valueToLookFor: "Patient",
//     // );
//   }

//   /// Call this method to cancel all the subcriptions at once
//   static void stopListening() {
//     try {
//       for (var patient in _patientsList) {
//         _locationSubscriptions[patient.deviceID]?.cancel();
//       }
//       // Clear the map so we know they are gone
//       _locationSubscriptions.clear();
//       log(
//         "Notice: 🛑 All patient location listeners were successfully stopped.",
//       );
//     } catch (e, stackTrace) {
//       log(
//         "ERROR ON STOPLISTENING METHOD in ListenToPatients class: $e. AT $stackTrace",
//       );
//     }
//   }

//   /// To listen to patients realtime location data
//   static void listenToPatients({
//     required Map<String, Map<String, dynamic>> annotationData,
//     required Map<String, mp.PointAnnotation> userAnnotations,
//     mp.PointAnnotationManager? pointAnnotationManager,
//     required BuildContext context,
//     List<MyGeofenceModel>? activeGeofences,
//   }) async {
//     try {
//       // 1. Fetch all patients from Firestore (Personal Info)
//       await _getAllPatients();

//       List<MyGeofenceModel> activeGeofences =
//           await MyGeofenceRepository.getActiveGeofences();

//       // for debugging purposes only
//       for (var p in _patientsList) {
//         log("PATIENTSSSSSSSSSSSSSSSSSSSSSSSSS: ${p.name}");
//         log("PATIENT IDDDDDDDDDDDDDDDDDDDDDDD: ${p.userID}");
//         log("DEVICE IDDDDDDDDDDDDDDDDDDDDDDDD: ${p.deviceID}");
//       }

//       // Create a random number generator for ID generation for each patient so that each of them have different notifications.
//       math.Random randomNumberGenerator = math.Random();
//       // 2. Loop through patients and attach a REALTIME listener to each
//       for (var patient in _patientsList) {
//         String deviceID = patient.deviceID;
//         int randomGeneratedID = randomNumberGenerator.nextInt(100);
//         bool isAPatient =
//             (patient.userType ==
//             "Patient"); // this function is originally only for patients, but I have decided to adapt staffs too

//         // Cancel existing subscription if it exists to avoid memory leaks
//         await _locationSubscriptions[deviceID]?.cancel();

//         _locationSubscriptions[deviceID] =
//             MyRealtimeLocationReposity.getRealtimePatientLocationStream(
//               deviceID: deviceID,
//             ).listen((MyRealtimeLocationModel realtimeLocModel) async {
//               try {
//                 // Parse coordinates safely
//                 double lng =
//                     double.tryParse(realtimeLocModel.currentLocationLng) ?? 0.0;
//                 double lat =
//                     double.tryParse(realtimeLocModel.currentLocationLat) ?? 0.0;

//                 // Prepare metadata for the Bottom Sheet
//                 annotationData[deviceID] = {
//                   'name': patient.name,
//                   'patientID': realtimeLocModel.patientID,
//                   'lng': lng,
//                   'lat': lat,
//                   'currentlyIn': realtimeLocModel.currentlyIn,
//                   'isInSafeZone': realtimeLocModel.isInSafeZone,
//                   'timeStamp': realtimeLocModel.timeStamp,
//                   'deviceBatteryPercentage': realtimeLocModel
//                       .deviceBatteryPercentage
//                       .toString(),
//                   'userID': patient.userID,
//                   'profilePicture': patient.picture,
//                   'age': patient.age,
//                   'sex': patient.sex,
//                   'contactInfo': patient.contactNumber,
//                   'address': patient.address,
//                   'notableBehavior': patient.notableBehavior,
//                   'deviceID': patient.deviceID,
//                   'email': patient.email,
//                   'birthDate': patient.birthdate,
//                   'userType': patient.userType, // newly added, not yet tested
//                 };

//                 // Decode the patient icon
//                 final Uint8List patientIcon =
//                     MyImageProcessor.decodeStringToUint8List(patient.picture);

//                 // 3. MAPBOX UPDATE LOGIC
//                 // Remove old annotation if it exists
//                 if (userAnnotations.containsKey(deviceID)) {
//                   await pointAnnotationManager?.delete(
//                     userAnnotations[deviceID]!,
//                   );
//                 }

//                 // Create new annotation at updated location
//                 var newAnnotation = await pointAnnotationManager?.create(
//                   await myPointAnnotationOptions(
//                     name: patient.name,
//                     myPosition: mp.Position(lng, lat),
//                     imageData: patientIcon,
//                     isAPatient: (patient.userType == "Patient"),
//                   ),
//                 );

//                 // if the newAnnotation is not null, add it to a specific userAnnoation
//                 if (newAnnotation != null) {
//                   userAnnotations[deviceID] = newAnnotation;
//                 }

//                 // Patient exclusive function call, staffs not included
//                 if (isAPatient) {
//                   log("${patient.name} is a Patient");
//                   // 4. Setup Tap Events (Do this once or update properly)
//                   _setupMapTapEvents(
//                     pointAnnotationManager: pointAnnotationManager!,
//                     userAnnotations: userAnnotations,
//                     annotationData: annotationData,
//                     // ignore: use_build_context_synchronously
//                     context: context,
//                   );

//                   // This will determine if a patient is inside a safe zone or not
//                   var isInsideSafeZone =
//                       await MyGeofenceLogic.isPatientInsideTheAssignedSafeZone(
//                         userPosition: mp.Position(lng, lat),
//                         activeGeofences: activeGeofences,
//                         userID: patient.userID,
//                       );

//                   // // Notifies if the patient is not inside the safe zone
//                   // if (!isInsideSafeZone) {
//                   //   MyAlertNotification.triggerSafeZoneAlert(
//                   //     patientName: patient.name,
//                   //     randomGeneratedIDForAlert: randomGeneratedID,
//                   //   );
//                   // }

//                   // Saves the lcation data of the patient to the database
//                   await MyHistoryReposity.savePatientLocation(
//                     locationData: realtimeLocModel,
//                   );

//                   // for debugging purposes only
//                   log(
//                     "🗺️ Patient ${patient.name} is inside the Safe Zone: --> $isInsideSafeZone",
//                   );
//                   log(
//                     "POSITION of patient with ID ${patient.userID} is lng:$lng, lat:$lat",
//                   );
//                 }
//                 // (deletable) fro debugging purposes only
//                 else {
//                   log("${patient.name} is NOTTT a Patient");
//                 }
//               } catch (e, stackTrace) {
//                 log("ERROR UPDATING MARKER FOR $deviceID: $e. AT $stackTrace");
//               }
//             });
//       }

//       log(
//         "Notice:✅ Successfully listening to ${_patientsList.length} patients realtime locations.",
//       );
//     } catch (e, stackTrace) {
//       log("ERROR ON LISTENTOPATIENTS METHOD: $e. AT $stackTrace");
//     }
//   }

//   static void _setupMapTapEvents({
//     required Map<String, Map<String, dynamic>> annotationData,
//     required Map<String, mp.PointAnnotation> userAnnotations,
//     mp.PointAnnotationManager? pointAnnotationManager,
//     required BuildContext context,
//   }) {
//     // set up tap events ONCE, outside the loop
//     pointAnnotationManager?.tapEvents(
//       onTap: (mp.PointAnnotation tappedAnnotation) {
//         // find which document this annotation belongs to
//         String? docId = userAnnotations.entries
//             .firstWhere(
//               (entry) => entry.value == tappedAnnotation,
//               orElse: () => MapEntry('', tappedAnnotation),
//             )
//             .key;

//         if (docId.isNotEmpty && annotationData.containsKey(docId)) {
//           var data = annotationData[docId]!;
//           // Only show the bottom nav sheet if it is a patient
//           if (data["userType"] == "Patient") {
//             showMyBottomNavigationSheet(
//               context: context,
//               patientID: data['patientID'] ?? "NO DATA ACQUIRED",
//               name: data['name'] ?? "NO DATA ACQUIRED",
//               sex: data['sex'] ?? "NO DATA ACQUIRED",
//               age: data['age'] ?? "NO DATA ACQUIRED",
//               contactInfo: data['contactInfo'] ?? "NO DATA ACQUIRED",
//               address: data['address'] ?? "NO DATA ACQUIRED",
//               notableBehavior: data['notableBehavior'] ?? "NO DATA ACQUIRED",
//               profilePicture: data['profilePicture'] ?? "NO DATA ACQUIRED",
//               currentlyIn: data['currentlyIn'] ?? "NO DATA ACQUIRED",
//               batteryPercentage:
//                   int.tryParse(data['deviceBatteryPercentage']) ?? 0,
//               isCurrentlySafe: data['isInSafeZone'] ?? false,
//               deviceID: data['deviceID'] ?? "NO DATA ACQUIRED",
//               email: data['email'] ?? "NO DATA ACQUIRED",
//               birthDate: data['birthDate'] ?? "NO DATA ACQUIRED",
//             );
//           } else {
//             showMyAnimatedSnackBar(
//               context: context,
//               dataToDisplay:
//                   "${data["name"]} is a ${data["userType"].toString().toUpperCase()}",
//             );
//           }
//         }
//       },
//     );
//   }
// }

// import 'dart:developer';
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/geofence_repository.dart';
import 'package:wanderhuman_app/helper/history_reposity.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/helper/realtime_active_status_repository.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/model/realtime_active_status_model.dart';
import 'package:wanderhuman_app/model/realtime_location_model.dart';
import 'package:wanderhuman_app/view-model/home_active_persons_provider.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view-model/home_miscellaneous_provider.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/userRolesUI/patient/bottom_modal_sheet_for_patient.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/geo_logics/notifcation_alerts.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/geo_logics/turf.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/map_camera_animations.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/point_annotation_options.dart';

class ListenToPatients {
  // static final List<PersonalInfo> _patientsList = [];

  // Keep track of location subscriptions so we can cancel them individually
  static final Map<String, StreamSubscription> _locationSubscriptions = {};

  // Keep track of the MASTER active status subscription
  static StreamSubscription? _activeStatusSubscription;

  // Provider
  static late MyHomeActivePersonsProvider _activePersonsProvider;

  /// Call this method to cancel all the subscriptions at once when leaving the map
  static void stopListening() {
    try {
      // 1. Stop listening for new logins/logouts
      _activeStatusSubscription?.cancel();

      // 2. Stop listening to individual locations
      for (var patient in _activePersonsProvider.activePersons) {
        _locationSubscriptions[patient.deviceID]?.cancel();
      }

      // 3. Clear memory
      _locationSubscriptions.clear();
      // _patientsList.clear();
      _activePersonsProvider.activePersons.clear();
      _activePersonsProvider.personCurrentPosition.clear();
      _activePersonsProvider.decodedImagesBuffer.clear();
      // _activePersonsProvider.devicesBattery.clear();

      log("Notice: 🛑 All map listeners were successfully stopped.");
    } catch (e, stackTrace) {
      log(
        "ERROR ON STOPLISTENING METHOD in ListenToPatients class: $e. AT $stackTrace",
      );
    }
  }

  /// Master function to initialize the map listeners
  static void listenToPatients({
    required Map<String, Map<String, dynamic>> annotationData,
    required Map<String, mp.PointAnnotation> userAnnotations,
    mp.PointAnnotationManager? pointAnnotationManager,
    required BuildContext context,
  }) async {
    try {
      // Provider
      _activePersonsProvider = context.read<MyHomeActivePersonsProvider>();

      List<MyGeofenceModel> activeGeofences =
          await MyGeofenceRepository.getActiveGeofences();

      // Set up Tap Events ONCE globally
      if (pointAnnotationManager != null) {
        _setupMapTapEvents(
          pointAnnotationManager: pointAnnotationManager,
          userAnnotations: userAnnotations,
          annotationData: annotationData,
          context: context,
        );
      }

      // This will jut generte a random number to act as an ID for each patient's notification
      math.Random randomNumberGenerator = math.Random();

      // Listen to the Active Status database CONTINUOUSLY
      _activeStatusSubscription = MyRealtimeActiveStatusRepository.streamAllActivePersons().listen((
        List<MyRealtimeActiveStatusModel> currentlyActivePersons,
      ) async {
        String currentUserUID = FirebaseAuth.instance.currentUser!.uid;
        // 1. Check for NEW people who just came online
        for (var person in currentlyActivePersons) {
          // String? personalID;
          // // to handle transition with the custom tracking device
          // if (person.userID == "") {
          //   PersonalInfo personalInfo =
          //       await MyPersonalInfoRepository.getAllPersonalInfoRecords(
          //         fieldName: "deviceID",
          //         valueToLookFor: person.userID,
          //       ).then((value) => value.first);
          //   personalID = personalInfo.userID;
          // }

          // A special logic for the logged in user
          if (person.userID == currentUserUID) {
            // // Skip the entire specifal logic if the logged in user is already in the list
            // if (_activePersonsProvider.activePersons.any((p) {
            //   return p.userID == currentUserUID;
            // })) {
            //   continue;
            // }

            var tempMyDetails =
                await MyPersonalInfoRepository.getSpecificPersonalInfo(
                  userID: currentUserUID,
                );
            // State management purposes
            _activePersonsProvider.addActivePerson(tempMyDetails);
            _activePersonsProvider.decodeAndAddImageInBuffer(
              tempMyDetails.userID,
              tempMyDetails.picture,
            );
            // (deletable)
            // _activePersonsProvider.addDeviceBattery(
            //   tempMyDetails.userID, batteryPercentage)

            continue; // Skip ourselves from being included in the map interface
          }

          // This will jut generte a random number to act as an ID for each patient's notification
          int randomGeneratedID = randomNumberGenerator.nextInt(100);

          // If they are NOT in our list yet, they just logged in!
          bool isAlreadyTracked = _activePersonsProvider.activePersons.any(
            (p) => p.userID == person.userID || p.deviceID == person.userID,
          );

          if (!isAlreadyTracked) {
            log(
              "🟢 New user online! Adding (Device ID: ${person.userID}) to map...",
            );
            await _addPersonToMap(
              // userID: personalID ?? person.userID,
              userID: person.userID,
              annotationData: annotationData,
              userAnnotations: userAnnotations,
              pointAnnotationManager: pointAnnotationManager,
              context: context,
              activeGeofences: activeGeofences,
              randomGeneratedID: randomGeneratedID,
            );
          }
        }

        // 2. Check for OLD people who just went offline
        List<String> offlineDeviceIDs = [];

        for (var trackedPerson in _activePersonsProvider.activePersons) {
          // If a person in our list is NO LONGER in the database stream, they logged out
          bool isStillOnline = currentlyActivePersons.any(
            (active) =>
                active.userID == trackedPerson.deviceID ||
                active.userID == trackedPerson.userID,
          );

          if (!isStillOnline) {
            offlineDeviceIDs.add(trackedPerson.deviceID);
          }
        }

        // Remove the offline people from the map
        for (var offlineDeviceID in offlineDeviceIDs) {
          await _removePersonFromMap(
            deviceID: offlineDeviceID,
            annotationData: annotationData,
            userAnnotations: userAnnotations,
            pointAnnotationManager: pointAnnotationManager,
            // For state management purposes
            userID: _activePersonsProvider.activePersons
                .firstWhere((p) => p.deviceID == offlineDeviceID)
                .userID,
            context: context,
          );
        }
      });

      log("Notice: ✅ Successfully initialized the Realtime Map Traffic Cop.");
    } catch (e, stackTrace) {
      log("ERROR ON LISTENTOPATIENTS METHOD: $e. AT $stackTrace");
    }
  }

  /// HELPER 1: Starts tracking a NEW person and adds their icon
  static Future<void> _addPersonToMap({
    required String userID,
    required Map<String, Map<String, dynamic>> annotationData,
    required Map<String, mp.PointAnnotation> userAnnotations,
    mp.PointAnnotationManager? pointAnnotationManager,
    required BuildContext context,
    required List<MyGeofenceModel> activeGeofences,
    required int randomGeneratedID,
  }) async {
    try {
      // Providers
      var settingsProvider = context.read<MyHomeSettingsProvider>();
      var geofenceProvider = context
          .read<MyHomeGeofenceConfigurationProvider>();
      var miscellaneousProvider = context.read<MyHomeMiscellaneousProvider>();
      var mapboxRefProvider = context.read<MyMapboxRefProvider>();
      // var activePersonsProvider = context.read<MyHomeActivePersonsProvider>();

      // 1. Fetch their info from database
      late PersonalInfo personInfo;
      personInfo = await getPersonalInfo(userID);

      // _patientsList.add(personInfo);
      _activePersonsProvider.addActivePerson(personInfo);

      // State management purposes
      _activePersonsProvider.addActivePerson(personInfo);
      _activePersonsProvider.decodeAndAddImageInBuffer(
        personInfo.userID,
        personInfo.picture,
      );

      // for debugging purposes only
      log("___________THESE ARE THE ACTIVE PERSONS IN THE LIST:");
      for (var person in _activePersonsProvider.activePersons) {
        log(
          "Name: ${person.name}, userID: ${person.userID}, deviceID: ${person.deviceID}",
        );
      }

      String deviceID = personInfo.deviceID;
      bool isAPatient = (personInfo.userType == "Patient");

      // // Decode their profile picture once
      // final Uint8List personIcon = MyImageProcessor.decodeStringToUint8List(
      //   personInfo.picture,
      // );

      // Cancel existing subscription if it somehow exists to avoid memory leaks
      await _locationSubscriptions[deviceID]?.cancel();

      // 2. Start their location stream
      _locationSubscriptions[deviceID] = MyRealtimeLocationReposity.getRealtimePatientLocationStream(deviceID: deviceID).listen((
        MyRealtimeLocationModel realtimeLocModel,
      ) async {
        try {
          // Parse coordinates safely
          double lng =
              double.tryParse(realtimeLocModel.currentLocationLng) ?? 0.0;
          double lat =
              double.tryParse(realtimeLocModel.currentLocationLat) ?? 0.0;

          // State management purposes
          _activePersonsProvider.updatePersonCurrentPosition(
            personInfo.userID,
            mp.Position(lng, lat),
          );
          _activePersonsProvider.addDeviceBattery(
            personInfo.userID,
            realtimeLocModel.deviceBatteryPercentage,
          );

          log(
            "55555555555555555555 Patient ${personInfo.name} location updated: lng:$lng, lat:$lat. Battery: ${realtimeLocModel.deviceBatteryPercentage}%",
          );

          // if (!(activePersonsProvider.decodedImagesBuffer.containsKey(
          //   personInfo.userID,
          // ))) {
          //   activePersonsProvider.decodeAndAddImageInBuffer(
          //     personInfo.userID,
          //     personInfo.picture,
          //   );
          // }

          // Prepare metadata for the Bottom Sheet/Snackbars
          annotationData[deviceID] = {
            'name': personInfo.name,
            'patientID': realtimeLocModel.patientID,
            'lng': lng,
            'lat': lat,
            'currentlyIn': realtimeLocModel.currentlyIn,
            'isInSafeZone': realtimeLocModel.isInSafeZone,
            'isCurrentlySafe': realtimeLocModel.isCurrentlySafe,
            'timeStamp': realtimeLocModel.timeStamp,
            'deviceBatteryPercentage': realtimeLocModel.deviceBatteryPercentage
                .toString(),
            'userID': personInfo.userID,
            'profilePicture': personInfo.picture,
            'age': personInfo.age,
            'sex': personInfo.sex,
            'contactInfo': personInfo.contactNumber,
            'address': personInfo.address,
            'notableBehavior': personInfo.notableBehavior,
            'deviceID': personInfo.deviceID,
            'email': personInfo.email,
            'birthDate': personInfo.birthdate,
            'userType': personInfo.userType,
          };

          // 3. MAPBOX UPDATE LOGIC
          // Remove old annotation if it exists
          if (userAnnotations.containsKey(deviceID)) {
            await pointAnnotationManager?.delete(userAnnotations[deviceID]!);
          }

          // Create new annotation at updated location
          var newAnnotation = await pointAnnotationManager?.create(
            await myPointAnnotationOptions(
              name: personInfo.name,
              myPosition: mp.Position(lng, lat),
              batteryPercentage: realtimeLocModel.deviceBatteryPercentage,
              imageData:
                  _activePersonsProvider.decodedImagesBuffer[personInfo.userID],
              isAPatient: isAPatient,
              isCurrentlySafe: realtimeLocModel.isCurrentlySafe,
              enableBatteryPecentage: settingsProvider.enableBatteryPercentage,
            ),
          );

          if (newAnnotation != null) {
            userAnnotations[deviceID] = newAnnotation;
          }

          //// (deletable) just in case the new code implementation below does not work properly
          // // 4. Patient Exclusive Logic (Safe Zones & History)
          // if (isAPatient) {
          //   var isInsideSafeZone =
          //       await MyGeofenceLogic.isPatientInsideTheAssignedSafeZone(
          //         userPosition: mp.Position(lng, lat),
          //         activeGeofences: activeGeofences,
          //         userID: personInfo.userID,
          //       );
          //
          //   // TODO: uncomment this to save realtime location data to history
          //   // // Saves patient realtime location into the history
          //   // await MyHistoryReposity.savePatientLocation(
          //   //   locationData: realtimeLocModel,
          //   // );
          //
          //   mp.MapboxMap? mapboxRef = context
          //       .read<MyMapboxRefProvider>()
          //       .getMapboxMapController;
          //   bool isIntroAnimationDone = context
          //       .read<MyHomeMiscellaneousProvider>()
          //       .isIntroAnimationDone;
          //   // Notifies if the patient is not inside the safe zone
          //   if (!isInsideSafeZone) {
          //
          //   // TODO: uncomment this to to enable the phone vibration
          //     // // Vibration
          //     // MyAlertNotification.triggerSafeZoneAlert(
          //     //   patientName: personInfo.name,
          //     //   randomGeneratedIDForAlert: randomGeneratedID,
          //     // );
          //
          //     // Alarm Audio
          //     context.read<MyHomeMiscellaneousProvider>().playAlarmAudio();
          //
          //     // Will help to indicate a pulsing red warning animation
          //     context
          //         .read<MyHomeGeofenceConfigurationProvider>()
          //         .addPatientToInDangerList(personInfo.userID);
          //
          //     // Will move the camera to the patient who is in danger (outside safe zone)
          //     Future.delayed(
          //       Duration(milliseconds: (isIntroAnimationDone) ? 0 : 5500),
          //       () {
          //         // only move the camera if this setting is enabled
          //         if (!(context
          //             .read<MyHomeSettingsProvider>()
          //             .alwaysFollowYourAvatar)) {
          //           MyMapCameraAnimations.myMapFlyTo(
          //             mapboxController: mapboxRef!,
          //             position: mp.Position(lng, lat),
          //             animationDurationInMilliseconds: 1200,
          //             zoomLevel: context
          //                 .read<MyHomeSettingsProvider>()
          //                 .zoomLevel,
          //           );
          //         }
          //       },
          //     );
          //   } else {
          //     if (context
          //         .read<MyHomeGeofenceConfigurationProvider>()
          //         .patientsInDanger
          //         .contains(personInfo.userID)) {
          //       // this will help make the danger animation stop
          //       context
          //           .read<MyHomeGeofenceConfigurationProvider>()
          //           .removePatientFromDangerList(personInfo.userID);
          //
          //       context
          //           .read<MyHomeMiscellaneousProvider>()
          //           .stopAlarmAudio();
          //
          //       log(
          //         "-----Number of Patients who are in Danger: ${context.read<MyHomeGeofenceConfigurationProvider>().patientsInDanger.length}",
          //       );
          //
          //       if (context.mounted) {
          //         MyMapCameraAnimations.myMapFlyTo(
          //           mapboxController: mapboxRef!,
          //           position: mp.Position(lng, lat),
          //           animationDurationInMilliseconds: 1200,
          //           zoomLevel: context
          //               .read<MyHomeSettingsProvider>()
          //               .zoomLevel,
          //         );
          //       }
          //     }
          //   }
          //   log(
          //     "WARNINGGGGG!!! Patient ${personInfo.name}, patientID: ${personInfo.userID} is IN DANGER!",
          //   );
          // }

          // TODO: uncommnet this when it is time to save data to database
          // // 4. Patient Exclusive Logic (Safe Zones & History)
          // if (isAPatient) {
          //   var isInsideSafeZone =
          //       await MyGeofenceLogic.isPatientInsideTheAssignedSafeZone(
          //         userPosition: mp.Position(lng, lat),
          //         activeGeofences: activeGeofences,
          //         userID: personInfo.userID,
          //       );

          //   mp.MapboxMap? mapboxRef = mapboxRefProvider.getMapboxMapController;
          //   bool isIntroAnimationDone =
          //       miscellaneousProvider.isIntroAnimationDone;

          //   // Notifies if the patient is not inside the safe zone or is the patient safe
          //   if (!realtimeLocModel.isCurrentlySafe ||
          //       (!isInsideSafeZone &&
          //           realtimeLocModel.currentlyIn == "Unknown")) {
          //     // and extra condition to prevent false alarms (not yet tested as of March 21, 2026)
          //     // Update isInSafeZone field in the database, if the patient is still in the data indicates that the patient is still in the safe zone but in reality not.

          //     // ONLY update the database if it mistakenly thinks the patient is safe.
          //     // We know they are in danger here. If the DB says 'true', flip it to 'false'!
          //     if (realtimeLocModel.isInSafeZone == true) {
          //       MyRealtimeLocationReposity.updateASingleField(
          //         deviceID: deviceID,
          //         fieldToUpdate: "isInSafeZone",
          //         value: "false", // They are outside the safe zone
          //         isABooleanValue: true,
          //       );
          //     }

          //     // Vibration
          //     MyAlertNotification.triggerSafeZoneAlert(
          //       patientName: personInfo.name,
          //       randomGeneratedIDForAlert: randomGeneratedID,
          //       isForBreachingSafeZoneAlert: (!isInsideSafeZone) ? true : false,
          //     );

          //     // Alarm Audio
          //     miscellaneousProvider.playAlarmAudio();

          //     // Will help to indicate a pulsing red warning animation
          //     geofenceProvider.addPatientToInDangerList(personInfo.userID);

          //     // Will move the camera to the patient who is in danger (outside safe zone)
          //     Future.delayed(
          //       Duration(milliseconds: (isIntroAnimationDone) ? 0 : 5500),
          //       () {
          //         // only move the camera if this setting is enabled
          //         if (!(settingsProvider.alwaysFollowYourAvatar)) {
          //           MyMapCameraAnimations.myMapFlyTo(
          //             mapboxController: mapboxRef!,
          //             position: mp.Position(lng, lat),
          //             animationDurationInMilliseconds: 1200,
          //             zoomLevel: settingsProvider.zoomLevel,
          //           );
          //         }
          //       },
          //     );
          //   } else {
          //     // We know they are safe here.
          //     // ONLY update the database if it mistakenly thinks they are in danger!
          //     if (realtimeLocModel.isInSafeZone == false) {
          //       MyRealtimeLocationReposity.updateASingleField(
          //         deviceID: deviceID,
          //         fieldToUpdate: "isInSafeZone",
          //         value: "true", // They are safely inside
          //         isABooleanValue: true,
          //       );
          //     }

          //     if (geofenceProvider.patientsInDanger.contains(
          //       personInfo.userID,
          //     )) {
          //       // this will help make the danger animation stop
          //       geofenceProvider.removePatientFromDangerList(personInfo.userID);

          //       miscellaneousProvider.stopAlarmAudio();

          //       log(
          //         "-----Number of Patients who are in Danger: ${geofenceProvider.patientsInDanger.length}",
          //       );

          //       if (context.mounted) {
          //         MyMapCameraAnimations.myMapFlyTo(
          //           mapboxController: mapboxRef!,
          //           position: mp.Position(lng, lat),
          //           animationDurationInMilliseconds: 1200,
          //           zoomLevel: context.read<MyHomeSettingsProvider>().zoomLevel,
          //         );
          //       }
          //     }
          //   }
          //   log(
          //     "WARNINGGGGG!!! Patient ${personInfo.name}, patientID: ${personInfo.userID} is IN DANGER!",
          //   );

          //   // Saves patient Realtime Location into the History
          //   await MyHistoryReposity.savePatientLocation(
          //     locationData: realtimeLocModel,
          //   );
          // }
        } catch (e, stackTrace) {
          log("ERROR UPDATING MARKER FOR $deviceID: $e. AT $stackTrace");
        }
      });
    } catch (e) {
      log("ERROR ADDING PERSON TO MAP: $e");
    }
  }

  static Future<PersonalInfo> getPersonalInfo(String userID) async {
    try {
      log("(NORMAL) TRY WAS EXECUTEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
      PersonalInfo personalInfo =
          await MyPersonalInfoRepository.getSpecificPersonalInfo(
            userID: userID,
          );
      log(
        "${personalInfo.name}'s user ID: ${personalInfo.userID}, device ID: ${personalInfo.deviceID}",
      );
      return personalInfo;
    } catch (e) {
      // to handle transition with the custom tracking device
      var personalInfo =
          await MyPersonalInfoRepository.getAllPersonalInfoRecords(
            fieldName: "deviceID",
            valueToLookFor: userID,
          ).then((value) => value.first);
      log(
        "------CATCH WAS EXECUTEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD___ deviceID: $userID, patientID: ${personalInfo.userID}",
      );

      await MyRealtimeLocationReposity.updateASingleField(
        deviceID: userID,
        fieldToUpdate: "patientID",
        value: personalInfo.userID,
      );

      return personalInfo;
    }
  }

  /// HELPER 2: Stops tracking a person and removes their icon
  static Future<void> _removePersonFromMap({
    required String deviceID,
    required Map<String, Map<String, dynamic>> annotationData,
    required Map<String, mp.PointAnnotation> userAnnotations,
    mp.PointAnnotationManager? pointAnnotationManager,
    // State management purposes
    String? userID,
    BuildContext? context,
  }) async {
    try {
      log("🔴 Removing offline user (Device ID: $deviceID) from the map.");

      // // Experimental implementation (deletable)
      // // Restart the app if the logged in user sudden goes offline
      // if(context != null){
      //   if (deviceID ==
      //     context.read<HomeAppBarProvider>().loggedInUserData.userID) {
      //     Phoenix.rebirth(context);
      //   }
      // }

      // 1. Kill their location stream
      await _locationSubscriptions[deviceID]?.cancel();
      _locationSubscriptions.remove(deviceID);

      // State management purposes
      var activePersonsProvider = context?.read<MyHomeActivePersonsProvider>();
      activePersonsProvider?.removeActivePerson(userID!);
      if (!(activePersonsProvider!.decodedImagesBuffer.containsKey(userID))) {
        activePersonsProvider.removeDecodedImageInBuffer(userID!);
      }
      activePersonsProvider.removeDeviceBattery(userID!);

      // 2. Remove them from our local list
      _activePersonsProvider.activePersons.removeWhere(
        (p) => p.deviceID == deviceID,
      );

      // 3. Delete their Mapbox Icon!
      if (userAnnotations.containsKey(deviceID)) {
        await pointAnnotationManager?.delete(userAnnotations[deviceID]!);
        userAnnotations.remove(deviceID);
      }

      // 4. Clear their metadata
      annotationData.remove(deviceID);
    } catch (e) {
      log("ERROR REMOVING PERSON FROM MAP: $e");
    }
  }

  /// Sets up map tap events globally
  static void _setupMapTapEvents({
    required Map<String, Map<String, dynamic>> annotationData,
    required Map<String, mp.PointAnnotation> userAnnotations,
    mp.PointAnnotationManager? pointAnnotationManager,
    required BuildContext context,
  }) {
    pointAnnotationManager?.tapEvents(
      onTap: (mp.PointAnnotation tappedAnnotation) {
        String? docId = userAnnotations.entries
            .firstWhere(
              (entry) => entry.value == tappedAnnotation,
              orElse: () => MapEntry('', tappedAnnotation),
            )
            .key;

        if (docId.isNotEmpty && annotationData.containsKey(docId)) {
          var data = annotationData[docId]!;

          bool isTappedPersonAPatient = (data['userType'] == "Patient");

          if (isTappedPersonAPatient) {
            showMyBottomNavigationSheet(
              context: context,
              patientID: data['patientID'] ?? "NO DATA ACQUIRED",
              name: data['name'] ?? "NO DATA ACQUIRED",
              sex: data['sex'] ?? "NO DATA ACQUIRED",
              age: data['age'] ?? "NO DATA ACQUIRED",
              contactInfo: data['contactInfo'] ?? "NO DATA ACQUIRED",
              address: data['address'] ?? "NO DATA ACQUIRED",
              notableBehavior: data['notableBehavior'] ?? "NO DATA ACQUIRED",
              profilePicture: data['profilePicture'] ?? "NO DATA ACQUIRED",
              currentlyIn: data['currentlyIn'] ?? "NO DATA ACQUIRED",
              batteryPercentage:
                  int.tryParse(data['deviceBatteryPercentage']) ?? 0,
              isCurrentlySafe: data['isCurrentlySafe'] ?? false,
              deviceID: data['deviceID'] ?? "NO DATA ACQUIRED",
              email: data['email'] ?? "NO DATA ACQUIRED",
              birthDate: data['birthDate'] ?? "NO DATA ACQUIRED",
            );
          } else {
            String userType = data["userType"].toString().toUpperCase();
            String indefiniteArticle = (userType == "ADMIN") ? "an" : "a";
            int? batteryPercentage = int.tryParse(
              data["deviceBatteryPercentage"],
            );
            showMyAnimatedSnackBar(
              context: context,
              dataToDisplay:
                  "${data["name"]} is $indefiniteArticle $userType, has $batteryPercentage% battery left",
            );
          }
        }
      },
    );
  }
}
