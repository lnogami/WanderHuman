import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/personal_info.dart';

class MyFirebaseServices {
  // cache of Personal Info
  static final CollectionReference _collectionReference = FirebaseFirestore
      .instance
      .collection("Personal Info");

  static String _userType = "";

  // this will create the document reference with a unique ID. (It is just a document without data yet).
  static DocumentReference _genereatePatientID() {
    return _collectionReference.doc();
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

  // get all patients
  static Future<List<PersonalInfo>> getAllPatients() async {
    try {
      QuerySnapshot querySnapshot = await _collectionReference
          // .where("userType", isEqualTo: "Patient")
          .get();
      List<PersonalInfo> patients = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PersonalInfo.fromFirestore(doc.id, data);
      }).toList();

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
}
