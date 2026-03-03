import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/settings_model.dart';

class MySettigsRepository {
  static final CollectionReference _settingsCollection = FirebaseFirestore
      .instance
      .collection('Settings');

  static DocumentReference _generateDocID(String userID) {
    return _settingsCollection.doc(userID);
  }

  /// Add settings
  static Future<void> addSettings({required MySettingsModel settings}) async {
    try {
      DocumentReference docRef = _generateDocID(settings.userID);

      await docRef.set({
        'userID': settings.userID,
        'zoomLevel': settings.zoomLevel,
        'alwaysFollowYourAvatar': settings.alwaysFollowYourAvatar,
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      log("Error adding settings: $e, at $stackTrace");
      rethrow;
    }
  }

  /// Fetches the settings for a specific user from Firestore.
  static Future<MySettingsModel> getSettingsOfTheUser({
    required String userID,
  }) async {
    try {
      DocumentSnapshot doc = await _settingsCollection.doc(userID).get();

      if (doc.exists) {
        return MySettingsModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        // Return default settings if no document exists
        return MySettingsModel(
          userID: userID,
          zoomLevel: 15,
          alwaysFollowYourAvatar: true,
        );
      }
    } catch (e) {
      log("Error fetching settings: $e");
      rethrow;
    }
  }

  static Future<bool> doesSettingsForThisUserExist({
    required String userID,
  }) async {
    try {
      var docs = await _settingsCollection.doc(userID).get();

      if (docs.exists) {
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      log(
        "Error in the function doesSettingsForThisUserExist: $e, at: $stackTrace",
      );
      rethrow;
    }
  }

  /// Updates or creates the settings for a specific user in Firestore.
  static Future<void> updateSettings({
    required MySettingsModel settings,
  }) async {
    try {
      await _settingsCollection.doc(settings.userID).set({
        'userID': settings.userID,
        'zoomLevel': settings.zoomLevel,
        'alwaysFollowYourAvatar': settings.alwaysFollowYourAvatar,
      }, SetOptions(merge: true));
      log("Settings successfully updated for user: ${settings.userID}");
    } catch (e) {
      log("Error updating settings: $e");
      rethrow;
    }
  }
}
