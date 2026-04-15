import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/model/realtime_active_status_model.dart';

class MyRealtimeActiveStatusRepository {
  static final DatabaseReference _rootRef = MyRealtimeLocationReposity.rootRef;
  static StreamSubscription? connectionObserverSubscription;

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

  // static Future<bool> getActiveStatus({required String userID}) async {
  //   try {
  //     final snapshot = await _rootRef
  //         .child("Active_Status")
  //         .child(userID)
  //         .get();
  //     if (snapshot.exists && snapshot.value != null) {
  //       // return data.value["isActive"];
  //       Map dataMap = Map<String, dynamic>.from(snapshot.value as Map);
  //       return dataMap["isActive"];
  //     } else {
  //       return false;
  //     }
  //   } catch (e, stackTrace) {
  //     log("ERROR WHILE RETRIEVING ACTIVE STATUS: $e. AT $stackTrace");
  //     rethrow;
  //   }
  // }
  static Future<bool> getActiveStatus({required String userID}) async {
    try {
      final snapshot = await _rootRef
          .child("Active_Status")
          .child(userID)
          .get();

      if (!snapshot.exists) {
        // This is to cater special case where deviceID is different from userID, because by default, those who do not have WanderHuman device assigned to them has assigend userID as their deviceID
        var allDeviceIDWithActiveStatus =
            await getAllDeviceIDWithActiveStatus();
        var personalInfo =
            await MyPersonalInfoRepository.getSpecificPersonalInfo(
              userID: userID,
            );

        return allDeviceIDWithActiveStatus.any((deviceID) {
          return deviceID.userID == personalInfo.deviceID &&
              deviceID.isActive == true;
        });
      } else if (snapshot.value != null) {
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

  // Add this to realtime_active_status_repository.dart
  static Stream<List<MyRealtimeActiveStatusModel>> streamAllActivePersons() {
    return _activeStatusRef.onValue.map((DatabaseEvent event) {
      List<MyRealtimeActiveStatusModel> activeDeviceIDList = [];
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        // 2. Parse the raw Map data just like your Future method
        final Map<dynamic, dynamic> rawData = snapshot.value as Map;

        rawData.forEach((key, value) {
          if (value is Map) {
            final Map<dynamic, dynamic> mapValue = value;

            // 3. We only care about people who are currently active
            if (mapValue["isActive"] == true) {
              activeDeviceIDList.add(
                MyRealtimeActiveStatusModel(
                  userID: key.toString(),
                  isActive: mapValue["isActive"],
                ),
              );
            }
          }
        });
      }

      return activeDeviceIDList;
    });
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

  static void observeConnection(String userID) {
    // NOTE: This is the right instance to use for Firebase Realtime Database (RTDB) that is set on Singapore (asia-southeast1)
    //       The FirebaseDatabase.instance().ref() by default is directed to the US (us-central1).
    //       So it wont work because the RTDB in US does not know this app exist, as it only existed in the Singapore RTDB.
    connectionObserverSubscription =
        FirebaseDatabase.instanceFor(
          // use instanceFor instead of FirebaseDatabase.instance()
          app: Firebase.app(),
          databaseURL: dotenv.env["MY_REALTIME_DATABASE_LINK"],
        ).ref(".info/connected").onValue.listen((event) {
          bool connected = event.snapshot.value as bool;

          if (connected) {
            log("CONNECTION OBSERVER: ✅ CONNECTION ESTABLISHING...");

            // 1. CLEAR any previous onDisconnect tasks to be safe
            _activeStatusRef.child(userID).onDisconnect().cancel();

            // 2. SET the onDisconnect task FIRST
            _activeStatusRef.child(userID).onDisconnect().update({
              "isActive": false,
            });

            // 3. SET THE ACTIVE STATUS SECOND
            _activeStatusRef.child(userID).update({"isActive": true});

            log("CONNECTION OBSERVER: ✅ CONNECTION ESTABLISHED");
          } else {
            log("❌ CONNECTION LOST LOCALLY - Will reconnect automatically");
          }
        });
  }
}
