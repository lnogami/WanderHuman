import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/history.dart';
import 'package:wanderhuman_app/model/personal_info.dart';

class MyFirebaseServices {
  // cache of Personal Info
  static final CollectionReference _personalInfoCollectionReference =
      FirebaseFirestore.instance.collection("Personal Info");

  static final CollectionReference _historyCollectionReference =
      FirebaseFirestore.instance.collection("History");

  static String _userType = "";
  // static List<PersonalInfo> _personalInfoRecords = []; // caching purposes

  // this will create the document reference with a unique ID. (It is just a document without data yet).
  static DocumentReference _genereatePatientID() {
    return _personalInfoCollectionReference.doc();
  }

  // this will add data to the document with the unique ID
  static void addPatient(PersonalInfo patient) {
    // .set method is just an add({}), but here we can specify the document ID which is the purpose of _genereatePatientID() method.
    _genereatePatientID().set({
      "userID": _genereatePatientID().id,
      "userType": patient.userType,
      "name": patient.name,
      "age": patient.age,
      "sex": patient.sex,
      "birthdate": patient.birthdate,
      "guardianContactNumber": patient.guardianContactNumber,
      "address": patient.address,
      "notableBehavior": patient.notableBehavior,
      "picture": patient.picture,
      "createdAt": patient.createdAt.toString(),
      "lastUpdatedAt": patient.lastUpdatedAt.toString(),
      "registeredBy": patient.registeredBy,
      "asignedCaregiver": patient.asignedCaregiver,
      "deviceID": patient.deviceID,
      // "email": patient.email,
    });
  }

  // returns all the records there is in PersonalInfo collection in database (FirebaseFirestore)
  static Future<List<PersonalInfo>> getAllPersonalInfoRecords() async {
    try {
      QuerySnapshot querySnapshot = await _personalInfoCollectionReference
          // .where("userType", isEqualTo: "Patient")
          .get();
      List<PersonalInfo> patients = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PersonalInfo.fromFirestore(doc.id, data);
      }).toList();

      // // to cache personal innfo records, for the purpose of getPatientIdAandName()
      // _personalInfoRecords = patients;

      // ignore: avoid_print
      print('✅🔍 Successfully fetched ${patients.length} patients');
      return patients;
    } catch (e) {
      // ignore: avoid_print
      print("🔍 $e");
      throw Exception();
    }
  }

  // to get the name of a specific user
  static String getSpecificUserName({
    required List<PersonalInfo> personsList,
    required String userIDToLookFor,
  }) {
    for (var person in personsList) {
      if (person.userID == userIDToLookFor) {
        _userType = person.userType;
        return person.name;
      }
    }
    return "No User Found!";
  }

  /// to get the role of the current user (Caregiver or Admin)
  static String getUserType() {
    return _userType;
  }

  //// NOT WORKING YET
  // static Future<List<String>> getAllUserID() async {
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection("Personal Info")
  //         .get();
  //     List<String> userIDs = querySnapshot.docs.map((doc) => doc.id).toList();
  //     return userIDs;
  //   } catch (e) {
  //     // ignore: avoid_print
  //     throw Exception("Error fetching user IDs: $e");
  //   }
  // }

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

  // static Map<String, String> getPatientIdAandName() {
  //   try {
  //     _personalInfoRecords;
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print("❌ Error getting patient id and name: $e");
  //     throw Exception();
  //   }
  //
  //   return {};
  // }

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
