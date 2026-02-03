import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/model/realtime_active_status_model.dart';

class MyRealtimeActiveStatusRepository {
  static final DatabaseReference _rootRef = MyRealtimeLocationReposity.rootRef;

  static DatabaseReference get _activeStatusRef =>
      _rootRef.child("Active_Status");

  /// Returns a list of deviceID of all the active devices
  static Future<List<MyRealtimeActiveStatusModel>>
  getAllDeviceIDWithActiveStatus() async {
    try {
      log("IT WORKED BEFORE SNAPSHOTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
      final DataSnapshot snapshot = await _activeStatusRef
          // .child("Realtime_Location")
          // .child("Active_Status")
          .get();
      log("IT WORKED AFTER SNAPSHOTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");

      if (snapshot.exists && snapshot.value != null) {
        List<MyRealtimeActiveStatusModel> activeDeviceIDList = [];

        // the deviceId node
        final Map<dynamic, dynamic> rawData = snapshot.value as Map;

        rawData.forEach((key, value) {
          if (value is Map) {
            // the data inside the deviceID node
            final Map<dynamic, dynamic> mapValue = value;

            if (mapValue["isActive"] == true) {
              activeDeviceIDList.add(
                MyRealtimeActiveStatusModel(
                  userID: key.toString(),
                  isActive: mapValue["isActive"],
                ),
              );
            }

            log(
              "THE VALUE AREEEEEEEEEEEEEEEEEE: ${mapValue["userID"]?.toString()} \n",
            );
          }
        });

        return activeDeviceIDList;
      }
      return [];
    } catch (e, stackTrace) {
      log("ERROR WHILE RETRIEVING ACTIVE STATUS: $e. AT $stackTrace");
      rethrow;
    }
  }

  static Future<bool> getActiveStatus({required String userID}) async {
    try {
      final snapshot = await _rootRef
          .child("Active_Status")
          .child(userID)
          .get();
      if (snapshot.exists && snapshot.value != null) {
        // return data.value["isActive"];
        Map dataMap = Map<String, dynamic>.from(snapshot.value as Map);
        return dataMap["isActive"];
      } else {
        return false;
      }
    } catch (e, stackTrace) {
      log("ERROR WHILE RETRIEVING ACTIVE STATUS: $e. AT $stackTrace");
      rethrow;
    }
  }

  // Update user/device status
  static Future<void> updateActiveStatus({
    required String userID,
    required bool isActive,
  }) async {
    try {
      final snapshot = await _rootRef
          .child("Active_Status")
          .child(userID)
          .get();

      // if the device ID is already in the database, update it
      if (snapshot.exists && snapshot.value != null) {
        _rootRef.child("Active_Status").child(userID).update({
          "isActive": isActive,
        });
      }
      // else, create a new one
      else {
        _rootRef.child("Active_Status").child(userID).set({
          // "deviceID": deviceID,
          "isActive": isActive,
        });
      }
    } catch (e, stackTrace) {
      log("ERROR WHILE UPDATING ACTIVE STATUS: $e. AT $stackTrace");
      rethrow;
    }
  }

  /// This will trigger if the mobile device is disconnected to the internet or closing the app
  static Future<void> setupOnDisconnectStatus(String userID) async {
    // 1. Tell the server: "If I lose connection, set isActive to false"
    await _rootRef.child("Active_Status").child(userID).onDisconnect().update({
      "isActive": false,
    });

    // 2. Now set yourself to true so the server knows you are currently here
    await updateActiveStatus(userID: userID, isActive: true);
  }
}
