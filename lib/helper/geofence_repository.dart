import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';

class MyGeofenceRepository {
  final CollectionReference geofenceColRef = FirebaseFirestore.instance
      .collection("geofences");

  // used for creating a geofence to have the same geofenceID as the doc.id
  DocumentReference get _docRef => geofenceColRef.doc();
  // try {} catch (e, stackTrace) {
  //       log("ERROR WHILE CREATING GEOFENCE: $e. AT $stackTrace");
  //     }
  Future<void> createGeofence(MyGeofenceModel geofenceModel) async {
    try {
      await geofenceColRef.add({
        "geofenceID": _docRef.id,
        "geofenceName": geofenceModel.geofenceName,
        "geofenceCoordinates": geofenceModel.geofenceCoordinates,
        "createdAt": geofenceModel.createdAt,
        "createdBy": geofenceModel.createdBy,
        "registeredPatients": geofenceModel.registeredPatients,
        "isActive": geofenceModel.isActive,
      });

      log("GEOFENCE CREATED SUCCESSFULLY");
    } catch (e, stackTrace) {
      log("ERROR WHILE CREATING GEOFENCE: $e. AT $stackTrace");
      rethrow;
    }
  }

  Future<MyGeofenceModel> getGeofence({required String geofenceID}) async {
    try {
      final DocumentSnapshot docSnapshot = await geofenceColRef
          .doc(geofenceID)
          .get();

      return MyGeofenceModel.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
      );
    } catch (e, stackTrace) {
      log("ERROR WHILE GETTING GEOFENCE: $e. AT $stackTrace");
      rethrow;
    }
  }

  Future<List<MyGeofenceModel>> getAllGeofences({
    String? field,
    String? fieldValue,
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
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e, stackTrace) {
      log("ERROR WHILE GETTING ALL GEOFENCES: $e. AT $stackTrace");
      rethrow;
    }
  }
}
