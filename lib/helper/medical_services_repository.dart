import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/medication_model.dart';

class MyMedicalRepository {
  static final CollectionReference _medicalCollectionReference =
      FirebaseFirestore.instance.collection("MedicalRecords");

  // just in case lang gamitonon ni
  static DocumentReference _generateRecordID() {
    return _medicalCollectionReference.doc();
  }

  /// The bool return type is only for debugging purposes, a feedback to know if the method is successfully executed.
  static bool addRecord(MedicationModel record) {
    DocumentReference docRef = _generateRecordID();
    try {
      docRef.set({
        "recordID": docRef.id,
        "patientID": record.patientID,
        "diagnosis": record.diagnosis,
        "treatment": record.treatment,
        "medic": record.medic,
        "fromDate": record.fromDate,
        "untilDate": record.untilDate,
        "isNowOkay": record.isNowOkay,
        "createdAt": record.createdAt,
      });
      return true;
    } catch (e) {
      print("ERROR while Adding Medical Recordddddd: ${e.toString()}");
      return false;
    }
  }

  /// The bool return type is only for debugging purposes, a feedback to know if the method is successfully executed.
  /// #### recordID is for identifying which record should be updated.
  static bool updateRecord({
    required MedicationModel record,
    required String recordID,
  }) {
    DocumentReference docRef = _medicalCollectionReference.doc(recordID);
    try {
      docRef.set(
        {
          "recordID": docRef.id,
          // "patientID": record.patientID,
          "diagnosis": record.diagnosis,
          "treatment": record.treatment,
          // "medic": record.medic,
          "fromDate": record.fromDate,
          "untilDate": record.untilDate,
          "isNowOkay": record.isNowOkay,
          // "createdAt": record.createdAt,
        },
        // SetOptions(merge: true) must be specified in order to avoid overwriting (remove those not spcified in the set argument) the exisiting data.
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print("ERROR while Adding Medical Recordddddd: ${e.toString()}");
      return false;
    }
  }

  // parameters not yet applied
  static Future<List<MedicationModel>> getAllRecords({
    String? fieldName,
    String? isEqualTo,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _medicalCollectionReference
          // .where("userType", isEqualTo: "Patient")
          .get();

      List<MedicationModel> medicalRecords = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return MedicationModel.fromFirestore(doc.id, data);
      }).toList();

      return medicalRecords;
    } catch (e) {
      print(
        "AN ERROR OCCURED WHILE WHILE FETCHING DATA FROM FIREBASE (getAllRecords): ${e.toString()}",
      );
      throw Exception();
    }
  }
}
