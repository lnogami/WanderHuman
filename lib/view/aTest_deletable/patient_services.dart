// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wanderhuman_app/view/aTest_deletable/patient.dart';

// // This service is responsible for fetching/listening to patients from Firestore
// class PatientService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Listen to ALL patients in Firestore
//   Stream<List<Patient>> listenToPatients() {
//     return _firestore.collection("patients").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return Patient.fromFirestore(doc.id, doc.data());
//       }).toList();
//     });
//   }

//   // Update patient trail when they leave safe zone
//   Future<void> updateTrail(String patientId, double lat, double lng) async {
//     await _firestore.collection("patients").doc(patientId).update({
//       "trail": FieldValue.arrayUnion([
//         {"lat": lat, "lng": lng},
//       ]),
//     });
//   }
// }
