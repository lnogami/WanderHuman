// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wanderhuman_app/model/history_model.dart';
// import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
// // not yet tested out as of Jan 26, 2026
// class MyHistoryReposity {
//   static final CollectionReference _historyCollectionReference =
//       FirebaseFirestore.instance.collection("History");
//   // FOR PATIENT SIMULATION
//   static Future<void> savePatientLocation(HistoryModel patient) async {
//     try {
//       print("savePatientLocation TRY WAS RUNNNNNNNNNNNNNNNNNNNNNNN");
//       _historyCollectionReference.doc().set({
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
//   static Future<List<HistoryModel>> getAllPatientsLatestHistory() async {
//     try {
//       print(
//         "getAllPatientsLatestHistory was run TRY WAS RUNNNNNNNNNNNNNNNNNNNNNNN",
//       );
//       // for caching until retrieval of certain needed records (documents)
//       List<HistoryModel> allPatientLatestHistory = [];
//       // for conditional purposes only
//       final lastTimeEncounter = DateTime.now();
//       // StreamSubscription
//       _historyCollectionReference.snapshots().listen((snapshot) {
//         // for every document in snapshot of documents
//         for (var doc in snapshot.docs) {
//           // retrieves a single document as a Map<String, dynamic>
//           var timeStampData = doc.data() as Map<String, dynamic>;
//           // retieve the timeStamp in the map
//           // DateTime timeStamp = DateTime.parse(
//           //   timeStampData["timeStamp"].toString(),
//           // );
//           print("BEFORE TIMESTAMPPPPPPPPPPPP: $timeStampData");
//           DateTime timeStamp = DateTime.parse(
//             MyDateFormatter.formatDate(
//               dateTimeInString: timeStampData["timeStamp"],
//               formatOptions: 8,
//             ),
//           );
//           print("TIMESTAMPPPPPPPPPPPPPPPPPPPPPP IS: $timeStamp");
//           // only retrive the document I needed, in this case, the latest patient record (document) their is.
//           if (timeStamp.difference(lastTimeEncounter).inSeconds <= 30) {
//             // if it is latest, then add the PatientHisotry to the List of PatientHistory
//             allPatientLatestHistory.add(
//               HistoryModel(
//                 deviceID: doc["deviceID"] ?? "No Data Retrieved",
//                 patientID: doc["patientID"] ?? "No Data Retrieved",
//                 isInSafeZone: doc["isInSafeZone"] ?? false,
//                 isCurrentlySafe: doc["isCurrentlySafe"] ?? true,
//                 currentlyIn: doc["currentlyIn"] ?? "No Data Retrieved",
//                 currentLocationLng:
//                     doc["currentLocationLng"] ?? "No Data Retrieved",
//                 currentLocationLat:
//                     doc["currentLocationLat"] ?? "No Data Retrieved",
//                 timeStamp: timeStamp.toString(),
//                 deviceBatteryPercentage:
//                     doc["deviceBatteryPercentage"] ?? "No Data Retrieved",
//                 bPM: doc["bPM"] ?? "No Data Retrieved",
//                 requestBPM: doc["requestBPM"] ?? "No Data Retrieved",
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
//   static Future<HistoryModel> getSpecificPatientHistory(
//     String patientID,
//   ) async {
//     // query the patient data based on patientID
//     QuerySnapshot querySnapshot = await _historyCollectionReference
//         .where("patientID", isEqualTo: patientID)
//         .get();
//     // because QuerySnapshot returns a DocumentSnapshot, call .data() to get a generic Object and convert it to Map to use it accordingly
//     final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
//     // finally, return the data as a HistoryModel object
//     return HistoryModel(
//       deviceID: data["deviceID"] ?? "",
//       patientID: data["patientID"] ?? "",
//       isInSafeZone: data["isInSafeZone"] ?? "",
//       isCurrentlySafe: data["isCurrentlySafe"] ?? "",
//       currentlyIn: data["currentlyIn"] ?? "",
//       currentLocationLng: data["currentLocationLng"] ?? "",
//       currentLocationLat: data["currentLocationLat"] ?? "",
//       timeStamp: data["timeStamp"] ?? "",
//       deviceBatteryPercentage: data["deviceBatteryPercentage"] ?? "",
//       bPM: data["bPM"] ?? "",
//       requestBPM: data["requestBPM"] ?? "",
//     );
//   }
// }

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/model/realtime_location_model.dart';

class MyHistoryReposity {
  /// This will contain all the last saved times for each patient
  static final Map<String, DateTime> _lastSavedTimes = {};

  /// This _timeGapInSeconds means the duration between each log to save to the database
  static final int _timeGapInSeconds = 30;

  /// Root collection for History
  static final CollectionReference _rootCollection = FirebaseFirestore.instance
      .collection("History");

  /// Sub-collection for PatientLogs
  static final String _subCollection = "PatientLogs";

  /// This checks RAM instead of the Database (Instant & Free)
  static bool _shouldSaveNow(String patientID) {
    // If we have never saved for this patient in this session, save now.
    if (!_lastSavedTimes.containsKey(patientID)) {
      return true;
    }

    DateTime lastSave = _lastSavedTimes[patientID]!;
    DateTime now = DateTime.now();

    // Check if 30 seconds have passed
    if (now.difference(lastSave).inSeconds >= _timeGapInSeconds) {
      return true;
    }

    return false;
  }

  static Future<void> savePatientLocation({
    required MyRealtimeLocationModel locationData,
  }) async {
    try {
      // 3. Check memory first!
      // This stops the code from doing ANY database work if it's too soon.
      if (!_shouldSaveNow(locationData.patientID)) {
        // Uncomment this if you want to see how many saves are being skipped
        log(
          "NOTICEEEEE: Skipping history save for ${locationData.patientID} (Too soon)",
        );
        return;
      }

      // 4. Update the "Last Saved" time immediately so we don't save again too soon
      _lastSavedTimes[locationData.patientID] = DateTime.now();

      // 5. Proceed with saving to Firestore
      // (You don't need _isPatientLogsEmpty checks anymore if you trust the timestamps)

      await _rootCollection
          .doc(locationData.patientID)
          .collection(_subCollection)
          .doc(DateTime.now().toString())
          .set(MyHistoryModel.toMap(locationData));

      log("✅ SUCCESSFULLY SAVED HISTORY for ${locationData.patientID}");
    } catch (e, stackTrace) {
      log("ERROR SAVING HISTORY: $e \nAT: $stackTrace");
    }
  }

  /// Retrieve all history logs for a specific patient
  static Future<List<MyHistoryModel>> getPatientHistory(
    String patientID,
  ) async {
    try {
      QuerySnapshot snapshot = await _rootCollection
          .doc(patientID)
          .collection(_subCollection)
          .orderBy('timeStamp', descending: true) // Get newest first
          .get();

      return snapshot.docs.map((doc) {
        return MyHistoryModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      log("ERROR FETCHING HISTORY: $e");
      return [];
    }
  }
}
