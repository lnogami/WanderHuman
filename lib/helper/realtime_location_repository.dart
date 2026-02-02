// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wanderhuman_app/model/realtime_location_model.dart';

// // not yet tested out as of Jan 26, 2026
// class MyRealtimeLocationReposity {
//   static final CollectionReference _realtimeLocationCollectionReference =
//       FirebaseFirestore.instance.collection("Realtime Location");

//   // FOR PATIENT SIMULATION
//   static Future<void> savePatientLocation(RealtimeLocationModel patient) async {
//     try {
//       _realtimeLocationCollectionReference.doc().set({
//         "deviceID": patient.deviceID,
//         "patientID": patient.patientID,
//         "isInSafeZone": patient.isInSafeZone,
//         "currentLocationLng": patient.currentLocationLng,
//         "currentLocationLat": patient.currentLocationLat,
//         "currentlyIn": patient.currentlyIn,
//         "timeStamp": patient.timeStamp,
//         "deviceBatteryPercentage": patient.deviceBatteryPercentage,
//         "bPM": patient.bPM,
//         "requestBPM": patient.requestBPM,
//       });
//     } on FirebaseException catch (e) {
//       // ignore: avoid_print
//       print("❌ Error on saving user location:${e.message}");
//       throw Exception();
//     }
//   }

//   /// Retrieves all the latest records of patients
//   static Future<List<RealtimeLocationModel>>
//   getAllPatientsCurrentLocation() async {
//     try {
//       // for caching until retrieval of certain needed records (documents)
//       List<RealtimeLocationModel> allPatientLatestHistory = [];

//       // for conditional purposes only
//       final lastTimeEncounter = DateTime.now();

//       // StreamSubscription
//       _realtimeLocationCollectionReference.snapshots().listen((snapshot) {
//         // for every document in snapshot of documents
//         for (var doc in snapshot.docs) {
//           // retrieves a single document as a Map<String, dynamic>
//           var timeStampData = doc.data() as Map<String, dynamic>;
//           // retieve the timeStamp in the map
//           DateTime timeStamp = DateTime.parse(timeStampData["timeStamp"]);
//           // only retrive the document I needed, in this case, the latest patient record (document) their is.
//           if (timeStamp.difference(lastTimeEncounter).inSeconds <= 30) {
//             // if it is latest, then add the PatientHisotry to the List of PatientHistory
//             allPatientLatestHistory.add(
//               RealtimeLocationModel(
//                 deviceID: doc["deviceID"],
//                 patientID: doc["patientID"],
//                 isInSafeZone: doc["isInSafeZone"],
//                 currentlyIn: doc["currentlyIn"],
//                 currentLocationLng: doc["currentLocationLng"],
//                 currentLocationLat: doc["currentLocationLat"],
//                 timeStamp: timeStamp.toString(),
//                 deviceBatteryPercentage: doc["deviceBatteryPercentage"],
//                 bPM: doc["bPM"],
//                 requestBPM: doc["requestBPM"],
//               ),
//             );
//           }
//         }
//       });
//       return allPatientLatestHistory;
//     } catch (e) {
//       print("❌ Something went wrong in getAllPatientHistory function: $e");
//       throw Exception();
//     }
//   }

//   /// To get a specific patient's location data by patientID
//   static Future<RealtimeLocationModel> getSpecificPatientHistory(
//     String patientID,
//   ) async {
//     // query the patient data based on patientID
//     QuerySnapshot querySnapshot = await _realtimeLocationCollectionReference
//         .where("patientID", isEqualTo: patientID)
//         .get();

//     // because QuerySnapshot returns a DocumentSnapshot, call .data() to get a generic Object and convert it to Map to use it accordingly
//     final data = querySnapshot.docs.first.data() as Map<String, dynamic>;

//     // finally, return the data as a RealtimeLocationModel object
//     return RealtimeLocationModel(
//       deviceID: data["deviceID"],
//       patientID: data["patientID"],
//       isInSafeZone: data["isInSafeZone"],
//       currentlyIn: data["currentlyIn"],
//       currentLocationLng: data["currentLocationLng"],
//       currentLocationLat: data["currentLocationLat"],
//       timeStamp: data["timeStamp"],
//       deviceBatteryPercentage: data["deviceBatteryPercentage"],
//       bPM: data["bPM"],
//       requestBPM: data["requestBPM"],
//     );
//     // }
//   }
// }

import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/model/realtime_location_model.dart';

class MyRealtimeLocationReposity {
  // this is the root reference, it is only called once
  static final DatabaseReference _rootRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    // nakatago ang link ani
    databaseURL: dotenv.env["MY_REALTIME_DATABASE_LINK"],
  ).ref();

  /// A getter that returns the realtime location reference
  static DatabaseReference get _realtimeLocationRef =>
      _rootRef.child("Realtime_Location");

  // // test (temporary only)
  // static Future<void> add(int price) async {
  //   try {
  //     final testRef = _rootRef.child("test");
  //     await testRef.set({"price": price});

  //     print("price was set to $price");
  //   } catch (e, st) {
  //     print("Error: $e. On ${st}");
  //   }
  // }

  // // test (temporary only)
  // static Future<int> getPrice() async {
  //   try {
  //     final testRef = _rootRef.child("test/price");
  //     final snapshot = await testRef.get();
  //     return snapshot.value as int;
  //   } catch (e, st) {
  //     print("Error: $e. On ${st}");
  //     rethrow;
  //   }
  // }

  // // test (temporary only)
  // static Stream<int> priceStream() {
  //   return _rootRef.child("test/price").onValue.map((event) {
  //     print("STREAM WORKS");
  //     if (event.snapshot.exists) {
  //       return event.snapshot.value as int;
  //     }
  //     return 0;
  //   });
  // }

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

        return MyRealtimeLocationModel(
          deviceID: deviceID,
          patientID: "NO DATA FOUND",
          isInSafeZone: false,
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
}
