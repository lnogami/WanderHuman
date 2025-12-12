import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/history.dart';

class MyHistoryReposity {
  static final CollectionReference _historyCollectionReference =
      FirebaseFirestore.instance.collection("History");

  // FOR PATIENT SIMULATION
  static Future<void> savePatientLocation(PatientHistory patient) async {
    try {
      _historyCollectionReference.doc().set({
        "patientID": patient.patientID,
        "isInSafeZone": patient.isInSafeZone,
        "currentLocation": patient.currentLocation,
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
  static Future<List<PatientHistory>> getAllPatientsLatestHistory() async {
    try {
      // for caching until retrieval of certain needed records (documents)
      List<PatientHistory> allPatientLatestHistory = [];

      // for conditional purposes only
      final lastTimeEncounter = DateTime.now();

      // StreamSubscription
      _historyCollectionReference.snapshots().listen((snapshot) {
        // for every document in snapshot of documents
        for (var doc in snapshot.docs) {
          // retrieves a single document as a Map<String, dynamic>
          var data = doc.data() as Map<String, dynamic>;
          // retieve the timeStamp in the map
          DateTime timeStamp = DateTime.parse(data["timeStamp"]);
          // only retrive the document I needed, in this case, the latest patient record (document) their is.
          if (timeStamp.difference(lastTimeEncounter).inSeconds <= 30) {
            // if it is latest, then add the PatientHisotry to the List of PatientHistory
            allPatientLatestHistory.add(
              PatientHistory(
                patientID: doc["patientID"],
                isInSafeZone: doc["isInSafeZone"],
                currentlyIn: doc["currentlyIn"],
                currentLocation: doc["currentLocation"],
                timeStamp: timeStamp,
                deviceBatteryPercentage: doc["deviceBatteryPercentage"],
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
}
