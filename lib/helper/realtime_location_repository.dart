import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/realtime_location_model.dart';

// not yet tested out as of Jan 26, 2026
class MyRealtimeLocationReposity {
  static final CollectionReference _realtimeLocationCollectionReference =
      FirebaseFirestore.instance.collection("Realtime Location");

  // FOR PATIENT SIMULATION
  static Future<void> savePatientLocation(RealtimeLocationModel patient) async {
    try {
      _realtimeLocationCollectionReference.doc().set({
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
  static Future<List<RealtimeLocationModel>>
  getAllPatientsCurrentLocation() async {
    try {
      // for caching until retrieval of certain needed records (documents)
      List<RealtimeLocationModel> allPatientLatestHistory = [];

      // for conditional purposes only
      final lastTimeEncounter = DateTime.now();

      // StreamSubscription
      _realtimeLocationCollectionReference.snapshots().listen((snapshot) {
        // for every document in snapshot of documents
        for (var doc in snapshot.docs) {
          // retrieves a single document as a Map<String, dynamic>
          var timeStampData = doc.data() as Map<String, dynamic>;
          // retieve the timeStamp in the map
          DateTime timeStamp = DateTime.parse(timeStampData["timeStamp"]);
          // only retrive the document I needed, in this case, the latest patient record (document) their is.
          if (timeStamp.difference(lastTimeEncounter).inSeconds <= 30) {
            // if it is latest, then add the PatientHisotry to the List of PatientHistory
            allPatientLatestHistory.add(
              RealtimeLocationModel(
                deviceID: doc["deviceID"],
                patientID: doc["patientID"],
                isInSafeZone: doc["isInSafeZone"],
                currentlyIn: doc["currentlyIn"],
                currentLocationLng: doc["currentLocationLng"],
                currentLocationLat: doc["currentLocationLat"],
                timeStamp: timeStamp.toString(),
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

  /// To get a specific patient's location data by patientID
  static Future<RealtimeLocationModel> getSpecificPatientHistory(
    String patientID,
  ) async {
    // query the patient data based on patientID
    QuerySnapshot querySnapshot = await _realtimeLocationCollectionReference
        .where("patientID", isEqualTo: patientID)
        .get();

    // because QuerySnapshot returns a DocumentSnapshot, call .data() to get a generic Object and convert it to Map to use it accordingly
    final data = querySnapshot.docs.first.data() as Map<String, dynamic>;

    // finally, return the data as a RealtimeLocationModel object
    return RealtimeLocationModel(
      deviceID: data["deviceID"],
      patientID: data["patientID"],
      isInSafeZone: data["isInSafeZone"],
      currentlyIn: data["currentlyIn"],
      currentLocationLng: data["currentLocationLng"],
      currentLocationLat: data["currentLocationLat"],
      timeStamp: data["timeStamp"],
      deviceBatteryPercentage: data["deviceBatteryPercentage"],
    );
    // }
  }
}
