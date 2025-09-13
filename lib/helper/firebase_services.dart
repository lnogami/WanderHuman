import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/firebase_patients.dart';

class MyFirebaseServices {
  // cache of Personal Info
  static final CollectionReference _collectionReference = FirebaseFirestore
      .instance
      .collection("Personal Info");

  // this will create the document reference with a unique ID. (It is just a document without data yet).
  static DocumentReference _genereatePatientID() {
    return _collectionReference.doc();
  }

  // this will add data to the document with the unique ID
  static void addPatient(Patients patient) {
    // .set method is just an add({}), but here we can specify the document ID which is the purpose of _genereatePatientID() method.
    _genereatePatientID().set({
      "userID": _genereatePatientID().id,
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

  // Still Cannot fetch data from the firestore
  // get all patients
  static Future<List<Patients>> getAllPatients() async {
    try {
      QuerySnapshot querySnapshot = await _collectionReference
          // .where("userType", isEqualTo: "Patient")
          .get();
      List<Patients> patients = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Patients.fromFirestore(doc.id, data);
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
    required List<Patients> personsList,
    required String userIDToLookFor,
  }) {
    List userIDs = [];
    for (var person in personsList) {
      if (person.userID == userIDToLookFor) {
        return person.name;
      }
      userIDs.add(person.name);
    }
    print(" ✅✅✅✅✅✅ List of User IDs: $userIDs");

    return "No User Found!";
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
