import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';

class MyGeofenceRepository {
  static final CollectionReference geofenceColRef = FirebaseFirestore.instance
      .collection("Geofences");

  // used for creating a geofence to have the same geofenceID as the doc.id
  static DocumentReference _getDocRef() {
    return geofenceColRef.doc();
  }

  // try {} catch (e, stackTrace) {
  //       log("ERROR WHILE CREATING GEOFENCE: $e. AT $stackTrace");
  //     }
  static Future<void> createGeofence(MyGeofenceModel geofenceModel) async {
    try {
      // await geofenceColRef.add({
      //   "geofenceID": _docRef.id,
      //   "geofenceName": geofenceModel.geofenceName,
      //   "geofenceCoordinates": geofenceModel.geofenceCoordinates,
      //   "createdAt": geofenceModel.createdAt,
      //   "createdBy": geofenceModel.createdBy,
      //   "registeredPatients": geofenceModel.registeredPatients,
      //   "isActive": geofenceModel.isActive,
      // });

      // the purpose of this docRef is to get the docID beforehand, so that it can be used for geofenceID
      final DocumentReference docRef = _getDocRef();
      await docRef.set(geofenceModel.toFirestore(docID: docRef.id));

      log("GEOFENCE CREATED SUCCESSFULLY");
    } catch (e, stackTrace) {
      log("ERROR WHILE CREATING GEOFENCE: $e. AT $stackTrace");
      rethrow;
    }
  }

  static Future<MyGeofenceModel> getGeofence({
    required String geofenceID,
  }) async {
    try {
      final DocumentSnapshot docSnapshot = await geofenceColRef
          .doc(geofenceID)
          .get();

      return MyGeofenceModel.fromFirestore(
        docId: docSnapshot.id,
        data: docSnapshot.data() as Map<String, dynamic>,
      );
    } catch (e, stackTrace) {
      log("ERROR WHILE GETTING GEOFENCE: $e. AT $stackTrace");
      rethrow;
    }
  }

  static Future<List<MyGeofenceModel>> getAllGeofences({
    String? field,
    dynamic fieldValue,
  }) async {
    try {
      late QuerySnapshot querySnapshot;

      if (field != null && fieldValue != null) {
        querySnapshot = await geofenceColRef
            .where(field, isEqualTo: fieldValue)
            .get();
      } else {
        querySnapshot = await geofenceColRef.get();
      }

      return querySnapshot.docs.map((doc) {
        return MyGeofenceModel.fromFirestore(
          docId: doc.id,
          data: doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e, stackTrace) {
      log("ERROR WHILE GETTING ALL GEOFENCES: $e. AT $stackTrace");
      rethrow;
    }
  }

  // Returns a list of all active geofences
  static Future<List<MyGeofenceModel>> getActiveGeofences() {
    try {
      return getAllGeofences(field: "isActive", fieldValue: true).then((
        geofences,
      ) {
        if (geofences.isNotEmpty) {
          return geofences; // Return all active geofences
        } else {
          // throw Exception("No active geofence found");
          return [];
        }
      });
    } catch (e, stackTrace) {
      log("ERROR WHILE GETTING ALL GEOFENCES: $e. AT $stackTrace");
      rethrow;
    }
  }

  // This function checks if a patient is already registered in any active geofence.
  static Future<bool> isPatientAlreadyRegisteredInAnActiveGeofence({
    required String? patientID,
    String geofenceIDToBeExcluded = "",
  }) async {
    try {
      final List<MyGeofenceModel> activeGeofences = await getActiveGeofences();
      for (final geofence in activeGeofences) {
        // the provided geofence to be excluded from this rule
        if (geofenceIDToBeExcluded == geofence.geofenceID) continue;

        if (geofence.registeredPatients.contains(patientID)) {
          return true; // Patient is already registered in an active geofence
        }
      }
      return false; // Patient is not registered in any active geofence
    } catch (e, stackTrace) {
      log(
        "ERROR WHILE CHECKING IF PATIENT IS IN AN ACTIVE GEOFENCE: $e. AT $stackTrace",
      );
      rethrow;
    }
  }

  static Future<void> updateGeofence({
    required String id,
    required MyGeofenceModel geofenceModel,
  }) async {
    try {
      await geofenceColRef.doc(id).set(geofenceModel.toFirestore(docID: id));

      log("GEOFENCE UPDATED SUCCESSFULLY");
    } catch (e, stackTrace) {
      log("ERROR WHILE UPDATING GEOFENCE: $e. AT $stackTrace");
      rethrow;
    }
  }

  static Future<void> deleteGeofence({required String id}) async {
    try {
      await geofenceColRef.doc(id).delete();

      log("GEOFENCE DELETED SUCCESSFULLY");
    } catch (e, stackTrace) {
      log("ERROR WHILE DELETING GEOFENCE: $e. AT $stackTrace");
      rethrow;
    }
  }
}
