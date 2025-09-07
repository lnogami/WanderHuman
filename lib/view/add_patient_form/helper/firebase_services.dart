import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/view/add_patient_form/helper/firebase_patients.dart';

// final personalInfo = FirebaseFirestore.instance
//                           .collection("Personal Info")
//                           .add({
//                             "id": 1,
//                             "usertype": "Caregiver",
//                             "name": "Hori Zontal",
//                             "gender": "male",
//                             "contactNumber": "09876543210",
//                             "address": "NA",
//                             "notableTrait": "Imaginative, doer",
//                             "profilePictureUrl": "NA",
//                             "createdAt": FieldValue.serverTimestamp(),
//                           });

class MyFirebaseServices {
  // cache of Personal Info
  static final CollectionReference _collectionReference = FirebaseFirestore
      .instance
      .collection("Personal Info");

  // add patients
  static void addPatient(Patients patient) {
    FirebaseFirestore.instance.collection("Personal Info").add({
      "name": patient.name,
      "age": patient.age,
      "sex": patient.sex,
      "birthdate": patient.birthdate,
      "guardianContactNumber": patient.guardianContactNumber,
      "address": patient.address,
      "notableBehavior": patient.notableBehavior,
      "picture": patient.picture,
      "createdAt": patient.createdAt,
      "lastUpdatedAt": patient.lastUpdatedAt,
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

  static Future<List<String>> getAllUserID() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Personal Info")
          .get();
      List<String> userIDs = querySnapshot.docs.map((doc) => doc.id).toList();
      return userIDs;
    } catch (e) {
      // ignore: avoid_print
      throw Exception("Error fetching user IDs: $e");
    }
  }
}
