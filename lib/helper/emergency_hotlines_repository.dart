import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/emergency_hotlines_model.dart';

class MyEmergencyHotlinesRepository {
  static final CollectionReference _collectionRef = FirebaseFirestore.instance
      .collection("Emergency Hotlines");

  static Future<void> addContact(MyEmergencyHotlinesModel hotline) async {
    try {
      DocumentReference docRef = _collectionRef.doc();

      await docRef.set({
        "hotLineID": docRef.id,
        "hotLineName": hotline.hotLineName,
        "hotLineNumber": hotline.hotLineNumber,
        "savedAt": hotline.savedAt,
        "savedBy": hotline.savedBy,
      });
    } catch (e) {
      // for debugging purposes, log is a built in method in dart
      log(
        "An ERROR HAPPEN ON EMERGENCY HOTLINE REPOSITORY at addContact(): $e",
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  static Future<List<MyEmergencyHotlinesModel>> getContacts({
    String? queryField,
    String? queryValue,
  }) async {
    try {
      late QuerySnapshot querySnapshot;

      // if query field and query value is provided, then filter the data based on the query
      if (queryField != null && queryValue != null) {
        querySnapshot = await _collectionRef
            .where(queryField, isEqualTo: queryValue)
            .get();
      }
      // return all data
      else {
        querySnapshot = await _collectionRef.get();
      }

      // store the querySnapshot into a List of EmergencyHotlinesModel
      // by iterating all the documents (docs) in the querySnapshot using
      // .map(e) method
      // then convert each doc.data as a Map to use it efficiently
      // then return each values as an EmergencyHotlinesModel object
      // after iterating all the doc in docs, convert the Iterable object with .toList() method
      // .map wont run unless .toList() is called after it.
      List<MyEmergencyHotlinesModel> emergencyHotlines = querySnapshot.docs.map(
        (doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return MyEmergencyHotlinesModel.fromFirebase(
            docID: doc.id,
            data: data,
          );
        },
      ).toList();

      emergencyHotlines.sort(
        (a, b) =>
            a.hotLineName.toLowerCase().compareTo(b.hotLineName.toLowerCase()),
      );

      return emergencyHotlines;
    } catch (e) {
      // for debugging purposes, log is a built in method in dart
      log(
        "An ERROR HAPPEN ON EMERGENCY HOTLINE REPOSITORY at getContacts(): $e",
        error: e,
        stackTrace: StackTrace.current,
      );
      throw Exception();
    }
  }

  static Future<void> updateContact({
    required String docID,
    required MyEmergencyHotlinesModel hotline,
  }) async {
    try {
      _collectionRef.doc(docID).set({
        "hotLineID": hotline.hotLineID,
        "hotLineName": hotline.hotLineName,
        "hotLineNumber": hotline.hotLineNumber,
        "savedAt": hotline.savedAt,
        "savedBy": hotline.savedBy,
      });
    } catch (e) {
      // for debugging purposes, log is a built in method in dart
      log(
        "An ERROR HAPPEN ON EMERGENCY HOTLINE REPOSITORY at updateContact(): $e",
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  static Future<void> deleteContact({required String docID}) async {
    try {
      await _collectionRef.doc(docID).delete();
    } catch (e) {
      // for debugging purposes, log is a built in method in dart
      log(
        "An ERROR HAPPEN ON EMERGENCY HOTLINE REPOSITORY at deleteContact(): $e",
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }
}
