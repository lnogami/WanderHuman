import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderhuman_app/helper/realtime_active_status_repository.dart';

class ActiveStatus {
  static Future<void> setActiveStatusToOnline() async {
    await MyRealtimeActiveStatusRepository.updateActiveStatus(
      userID: FirebaseAuth.instance.currentUser!.uid,
      isActive: true,
    );
  }

  static Future<void> setActiveStatusToOffline() async {
    await MyRealtimeActiveStatusRepository.updateActiveStatus(
      userID: FirebaseAuth.instance.currentUser!.uid,
      isActive: false,
    );
  }

  /// This will trigger if the mobile device is disconnected to the internet or closing the app
  /// Calling this method will set the isActive to true
  static Future<void> setupOnDisconnectStatus() async {
    await MyRealtimeActiveStatusRepository.setupOnDisconnectStatus(
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  //// (not yet implemented) (deletable)
  // static void setupConnectionStatusObserver() {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     MyRealtimeActiveStatusRepository.observeConnection(user.uid);
  //   } else {
  //     log("⚠️ Cannot setup observer: No user logged in.");
  //   }
  // }
}
