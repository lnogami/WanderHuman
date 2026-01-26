// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wanderhuman_app/model/history.dart';

// class MyHistoryReposity {
//   static final CollectionReference _historyCollectionReference =
//       FirebaseFirestore.instance.collection("History");

//   // FOR PATIENT SIMULATION
//   static Future<void> savePatientLocation(PatientHistory patient) async {
//     try {
//       _historyCollectionReference.doc().set({
//         "patientID": patient.patientID,
//         "isInSafeZone": patient.isInSafeZone,
//         "currentLocation": patient.currentLocation,
//         "currentlyIn": patient.currentlyIn,
//         "timeStamp": patient.timeStamp,
//         "deviceBatteryPercentage": patient.deviceBatteryPercentage,
//       });
//     } on FirebaseException catch (e) {
//       // ignore: avoid_print
//       print("❌ Error on saving user location:${e.message}");
//       throw Exception();
//     }
//   }

//   /// Retrieves all the latest records of patients
//   static Future<List<PatientHistory>> getAllPatientsLatestHistory() async {
//     try {
//       // for caching until retrieval of certain needed records (documents)
//       List<PatientHistory> allPatientLatestHistory = [];

//       // for conditional purposes only
//       final lastTimeEncounter = DateTime.now();

//       // StreamSubscription
//       _historyCollectionReference.snapshots().listen((snapshot) {
//         // for every document in snapshot of documents
//         for (var doc in snapshot.docs) {
//           // retrieves a single document as a Map<String, dynamic>
//           var data = doc.data() as Map<String, dynamic>;
//           // retieve the timeStamp in the map
//           DateTime timeStamp = DateTime.parse(data["timeStamp"]);
//           // only retrive the document I needed, in this case, the latest patient record (document) their is.
//           if (timeStamp.difference(lastTimeEncounter).inSeconds <= 30) {
//             // if it is latest, then add the PatientHisotry to the List of PatientHistory
//             allPatientLatestHistory.add(
//               PatientHistory(

//                 deviceID: doc["deviceID"],
//                 patientID: doc["patientID"],
//                 isInSafeZone: doc["isInSafeZone"],
//                 currentlyIn: doc["currentlyIn"],
//                 currentLocationLng: doc["currentLocationLng"],
//                 currentLocationLat: doc["currentLocationLat"],
//                 timeStamp: timeStamp.toString(),
//                 deviceBatteryPercentage: doc["deviceBatteryPercentage"],
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
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';

// not yet tested out as of Jan 26, 2026
class MyHistoryReposity {
  static final CollectionReference _historyCollectionReference =
      FirebaseFirestore.instance.collection("History");

  // FOR PATIENT SIMULATION
  static Future<void> savePatientLocation(HistoryModel patient) async {
    try {
      print("savePatientLocation TRY WAS RUNNNNNNNNNNNNNNNNNNNNNNN");
      _historyCollectionReference.doc().set({
        "deviceID": patient.deviceID,
        "patientID": patient.patientID,
        "isInSafeZone": patient.isInSafeZone,
        "currentLocationLng": patient.currentLocationLng,
        "currentLocationLat": patient.currentLocationLat,
        "currentlyIn": patient.currentlyIn,
        "timeStamp": patient.timeStamp,
        "deviceBatteryPercentage": patient.deviceBatteryPercentage,
      });
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print("❌ Error on saving user location:${e.message}");
      throw Exception();
    }
  }

  /// Retrieves all the latest records of patients
  static Future<List<HistoryModel>> getAllPatientsLatestHistory() async {
    try {
      print(
        "getAllPatientsLatestHistory was run TRY WAS RUNNNNNNNNNNNNNNNNNNNNNNN",
      );
      // for caching until retrieval of certain needed records (documents)
      List<HistoryModel> allPatientLatestHistory = [];

      // for conditional purposes only
      final lastTimeEncounter = DateTime.now();

      // StreamSubscription
      _historyCollectionReference.snapshots().listen((snapshot) {
        // for every document in snapshot of documents
        for (var doc in snapshot.docs) {
          // retrieves a single document as a Map<String, dynamic>
          var timeStampData = doc.data() as Map<String, dynamic>;
          // retieve the timeStamp in the map
          // DateTime timeStamp = DateTime.parse(
          //   timeStampData["timeStamp"].toString(),
          // );

          print("BEFORE TIMESTAMPPPPPPPPPPPP: $timeStampData");
          DateTime timeStamp = DateTime.parse(
            MyDateFormatter.formatDate(
              dateTimeInString: timeStampData["timeStamp"],
              formatOptions: 8,
            ),
          );
          print("TIMESTAMPPPPPPPPPPPPPPPPPPPPPP IS: $timeStamp");
          // only retrive the document I needed, in this case, the latest patient record (document) their is.
          if (timeStamp.difference(lastTimeEncounter).inSeconds <= 30) {
            // if it is latest, then add the PatientHisotry to the List of PatientHistory
            allPatientLatestHistory.add(
              HistoryModel(
                deviceID: doc["deviceID"] ?? "No Data Retrieved",
                patientID: doc["patientID"] ?? "No Data Retrieved",
                isInSafeZone: doc["isInSafeZone"] ?? "No Data Retrieved",
                currentlyIn: doc["currentlyIn"] ?? "No Data Retrieved",
                currentLocationLng:
                    doc["currentLocationLng"] ?? "No Data Retrieved",
                currentLocationLat:
                    doc["currentLocationLat"] ?? "No Data Retrieved",
                timeStamp: timeStamp.toString(),
                deviceBatteryPercentage:
                    doc["deviceBatteryPercentage"] ?? "No Data Retrieved",
              ),
            );
          }
        }
      });
      return allPatientLatestHistory;
    } catch (e) {
      print("❌ Something went wrong in getAllPatientHistory function: $e");
      throw Exception();
    }
  }

  /// To get a specific patient's location data by patientID
  static Future<HistoryModel> getSpecificPatientHistory(
    String patientID,
  ) async {
    // query the patient data based on patientID
    QuerySnapshot querySnapshot = await _historyCollectionReference
        .where("patientID", isEqualTo: patientID)
        .get();

    // because QuerySnapshot returns a DocumentSnapshot, call .data() to get a generic Object and convert it to Map to use it accordinglyhe Map
    final data = querySnapshot.docs.first.data() as Map<String, dynamic>;

    // finally, return the data as a HistoryModel object
    return HistoryModel(
      deviceID: data["deviceID"],
      patientID: data["patientID"],
      isInSafeZone: data["isInSafeZone"],
      currentlyIn: data["currentlyIn"],
      currentLocationLng: data["currentLocationLng"],
      currentLocationLat: data["currentLocationLat"],
      timeStamp: data["timeStamp"],
      deviceBatteryPercentage: data["deviceBatteryPercentage"],
    );
  }
}
