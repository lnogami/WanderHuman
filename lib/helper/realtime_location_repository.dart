import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:wanderhuman_app/model/realtime_location_model.dart';

class MyRealtimeLocationReposity {
  // Getters
  /// `rootRef` refers to the root node of the realtime database
  static get rootRef => _rootRef;

  // this is the root reference, it is only called once
  static final DatabaseReference _rootRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    // nakatago ang link ani
    databaseURL: dotenv.env["MY_REALTIME_DATABASE_LINK"],
  ).ref();

  /// A getter that returns the realtime location reference
  static DatabaseReference get _realtimeLocationRef =>
      _rootRef.child("Realtime_Location");

  // Setters
  /// This will assign the device (deviceID) to a specific patient (patientID)
  static Future<void> setPatientDevice({
    required String deviceID,
    required String patientID,
  }) async {
    try {
      await _realtimeLocationRef.child(deviceID).update({
        "patientID": patientID,
      });

      log("SUCCESSFULLY UPDATED PATIENT DEVICE");
    } catch (e, stackTrace) {
      log("ERROR WHILE SETTING PATIENT DEVICE: $e. AT $stackTrace");
      rethrow;
    }
  }

  // // Getters
  // /// Will listen to the realtime location of the patient based on its device (deviceID)
  // static Stream<MyRealtimeLocationModel> getRealtimePatientLocationStream({
  //   required String deviceID,
  // }) {
  //   try {
  //     // the .child is like a doc, while .onValue is like .data in firestore
  //     return _realtimeLocationRef.child(deviceID).onValue.map((event) {
  //       if (event.snapshot.exists) {
  //         Map<String, dynamic> data = Map<String, dynamic>.from(
  //           event.snapshot.value as Map,
  //         );
  //         String patientID = data["patientID"];
  //         log("PATIENT IDDDDDDDDDDDDDDDDDDDDDDDDD: $patientID");
  //         return MyRealtimeLocationModel.fromMap(
  //           deviceID: deviceID,
  //           data: data,
  //         );
  //       }
  //       return MyRealtimeLocationModel(
  //         deviceID: deviceID,
  //         patientID: "NO DATA FOUND",
  //         isInSafeZone: false,
  //         currentlyIn: "NO DATA FOUND",
  //         currentLocationLng: "NO DATA FOUND",
  //         currentLocationLat: "NO DATA FOUND",
  //         timeStamp: "NO DATA FOUND",
  //         deviceBatteryPercentage: 0,
  //         bPM: "NO DATA FOUND",
  //         requestBPM: false,
  //       );
  //     });
  //   } catch (e, stackTrace) {
  //     log(
  //       "ERROR WHILE RETRIEVING REALTIME LOCATION OF PATIENT: $e. AT $stackTrace",
  //     );
  //     rethrow;
  //   }
  // }

  // Getters
  /// Will listen to the realtime location of the patient based on its device (deviceID)
  static Stream<MyRealtimeLocationModel> getRealtimePatientLocationStream({
    required String deviceID,
  }) {
    try {
      // the .child is like a doc, while .onValue is like .data in firestore
      return _realtimeLocationRef.child(deviceID).onValue.map((event) {
        if (event.snapshot.exists) {
          Map<String, dynamic> data = Map<String, dynamic>.from(
            event.snapshot.value as Map,
          );
          String patientID = data["patientID"];
          log("PATIENT IDDDDDDDDDDDDDDDDDDDDDDDDD: $patientID");

          print("LONG: ${data["currentLocationLng"]}");
          print("LAT: ${data["currentLocationLat"]}");

          return MyRealtimeLocationModel.fromMap(
            deviceID: deviceID,
            data: data,
          );
        }

        // default (no value found)
        return MyRealtimeLocationModel(
          deviceID: deviceID,
          patientID: "NO DATA FOUND",
          isInSafeZone: true,
          isCurrentlySafe: true,
          currentlyIn: "NO DATA FOUND",
          currentLocationLng: "NO DATA FOUND",
          currentLocationLat: "NO DATA FOUND",
          timeStamp: "NO DATA FOUND",
          deviceBatteryPercentage: 0,
          bPM: "NO DATA FOUND",
          requestBPM: false,
        );
      });
    } catch (e, stackTrace) {
      log(
        "ERROR WHILE RETRIEVING REALTIME LOCATION OF PATIENT: $e. AT $stackTrace",
      );
      rethrow;
    }
  }

  /// This will return a Position object. To access lng or lat, just call Postion.lng or Position.lat
  static Future<mp.Position> getLocation({required String deviceID}) async {
    try {
      final snapshot = await _realtimeLocationRef.child(deviceID).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map,
        );

        return mp.Position(
          double.tryParse(data["currentLocationLng"]) ?? 0.0,
          double.tryParse(data["currentLocationLat"]) ?? 0.0,
        );
      }

      return mp.Position(0, 0);
    } catch (e, stackTrace) {
      log(
        "ERROR WHILE RETRIEVING REALTIME LOCATION OF PATIENT: $e. AT $stackTrace",
      );
      rethrow;
    }
  }

  // Update
  /// [userID] is either a staff's ID or a patient's ID
  /// for staff, the deviceID is their userID
  static Future<void> updateLocation({
    required String deviceID,
    required MyRealtimeLocationModel realtimeData,
  }) async {
    try {
      _realtimeLocationRef
          .child(deviceID)
          .update(
            Map<String, dynamic>.from(
              MyRealtimeLocationModel.toMap(
                    MyRealtimeLocationModel(
                      deviceID: deviceID,
                      patientID: realtimeData.patientID,
                      isInSafeZone: realtimeData.isInSafeZone,
                      isCurrentlySafe: realtimeData.isCurrentlySafe,
                      currentlyIn: realtimeData.currentlyIn,
                      currentLocationLng: realtimeData.currentLocationLng,
                      currentLocationLat: realtimeData.currentLocationLat,
                      timeStamp: realtimeData.timeStamp,
                      deviceBatteryPercentage:
                          realtimeData.deviceBatteryPercentage,
                      bPM: realtimeData.bPM,
                      requestBPM: realtimeData.requestBPM,
                    ),
                  )
                  as Map,
            ),
          );
    } catch (e, stackTrace) {
      log(
        "ERROR WHILE UPDATING REALTIME LOCATION OF PATIENT: $e. AT $stackTrace",
      );
      rethrow;
    }
  }

  static Future<void> updateASingleField({
    required String deviceID,
    required String fieldToUpdate,
    required String value,
    bool isABooleanValue = false,
  }) async {
    try {
      if (isABooleanValue) {
        bool valueToBoolConvertedValue = bool.parse(value);
        _realtimeLocationRef.child(deviceID).update({
          fieldToUpdate: valueToBoolConvertedValue,
        });
      } else {
        _realtimeLocationRef.child(deviceID).update({fieldToUpdate: value});
      }
      log("SUCCESSFULLY UPDATED A SINGLE FIELD (of Patient: $deviceID)");
    } catch (e, stackTrace) {
      log(
        "ERROR WHILE UPDATING A SINGLE VALUE (of Patient: $deviceID): $e. AT $stackTrace",
      );
      rethrow;
    }
  }

  //----- User Device Status ---------------------------------------------------

  // /// Get user/device status in realtime stream
  // Stream<ActiveStatusModel> getActiveStatusStream({required String deviceID}) {
  //   try {
  //     return _realtimeLocationRef.child("ActiveStatus").onValue.map((event) {
  //       if (event.snapshot.exists) {
  //         return ActiveStatusModel.fromMap(
  //           Map<String, dynamic>.from(event.snapshot.value as Map),
  //         );
  //       }

  //       return ActiveStatusModel(deviceID: deviceID, isActive: false);
  //     });
  //   } catch (e, stackTrace) {
  //     log("ERROR WHILE RETRIEVING ACTIVE STATUS: $e. AT $stackTrace");
  //     rethrow;
  //   }
  // }
}
