import 'dart:developer' as dev;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class MyAlertNotification {
  // 1. Create the plugin instance
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 2. Initialize settings (MUST run when app starts)
  static Future<void> init() async {
    try {
      // Inside NotificationHelper.init()
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission(); // <--- THIS IS CRITICAL for Android 13+

      // Android Initialization
      // 'mipmap/ic_launcher' uses the app's existing icon.
      // You can replace this with a specific icon name if you added one.
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS Initialization
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(settings: settings);
    } catch (e, stackTrace) {
      dev.log(
        "AN ERROR OCCURED WHEN INITIALIZING NOTIFICATIONS: $e,  AT: $stackTrace",
      );
    }
  }

  // 3. The Function You Wanted (Now robust and reusable)
  /// `patientName` is for the name of the patient that is outside the safe zone <br>
  /// `randomGeneratedIDForAlert` is an identification for the notification for each patient, each of them has their own unique ID assigned to them.
  static Future<void> triggerSafeZoneAlert({
    String? patientName,
    int? randomGeneratedIDForAlert,
    bool isForBreachingSafeZoneAlert = true,
  }) async {
    try {
      dev.log(
        "Random Number of patient: $patientName is ID: $randomGeneratedIDForAlert",
      );
      // A. Vibrate the phone (Heavy vibration for danger)
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [500, 1000, 500, 2000, 500, 2500]);
      }

      // B. Define Notification Details
      const AndroidNotificationDetails
      androidDetails = AndroidNotificationDetails(
        'safe_zone_channel_id', // ID (Must be unique)
        'Safe Zone Alerts', // Name (Visible to user in settings)
        // channelDescription: 'Alerts when the patient leaves the safe zone',
        channelDescription:
            'Alerts when the patient leaves the safe zone or is in danger inside safe zone.',
        importance: Importance.max, // MAX makes it pop up on screen
        priority: Priority.high, // HIGH ensures it makes sound
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(presentSound: true),
      );

      // Show the notification
      if (isForBreachingSafeZoneAlert) {
        // Notification for breaching the safe zone
        await _notifications.show(
          // ID (0 means this notification replaces previous ones with ID 0)
          id: randomGeneratedIDForAlert ?? 0,
          title: "NOTICE! 🚨",
          // title: '🚨 SAFE ZONE ALERT 🚨',
          body: (patientName != null)
              ? "$patientName has wandered outside the safe zone!"
              : 'The patient has wandered outside the safe zone!',
          notificationDetails: platformDetails,
        );
      } else {
        // Notification if in danger inside the safe zone
        await _notifications.show(
          // ID (0 means this notification replaces previous ones with ID 0)
          id: randomGeneratedIDForAlert ?? 0,
          title: "NOTICE! In Danger! 🚨",
          body: (patientName != null)
              ? "$patientName is currently in danger inside safe zone!"
              : 'The patient is currently in danger inside safe zone!',
          notificationDetails: platformDetails,
        );
      }
    } catch (e, stackTrace) {
      dev.log(
        "AN ERROR OCCURED WHEN TRIGGERING NOTIFICATION: $e,  AT: $stackTrace",
      );
    }
  }
}
