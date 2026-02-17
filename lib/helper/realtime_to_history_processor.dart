// // import 'dart:async';
// // import 'dart:developer';

// // import 'package:wanderhuman_app/helper/history_reposity.dart';
// // import 'package:wanderhuman_app/model/history_model.dart';
// // import 'package:wanderhuman_app/model/realtime_location_model.dart';

// // class MyRealtimeToHistoryProcessor {

// //   static int millisecondsTimeGap = 1000;

// //   static Timer? _timer;
// //   static bool _hasTimerExceedTimeGap = false;

// //   static bool get hasTimerExceedTimeGap => _hasTimerExceedTimeGap;

// //   static set hasTimerExceedTimeGap(bool value) {
// //     _hasTimerExceedTimeGap = value;
// //   }

// //   /// The time gap for each RealtimeLocation save to History
// //   static Future<void> initTimer() async {
// //     try {
// //       if (_timer == null) {
// //         // initializes the Timer object and
// //         _timer = Timer.periodic(Duration(milliseconds: millisecondsTimeGap), (timer){
// //           hasTimerExceedTimeGap = true;
// //         });

// //         log("TIMER SUCCESSFULLY INITIALIZED");
// //       } else {
// //         log("TIMER ALREADY INITIALIZED");
// //       }
// //     } catch (e, stackTrace) {
// //       log("AN ERROR OCCURED IN INIT TIMER FUNCTION: $e, AT $stackTrace");
// //     }
// //   }

// //   static Future<void> saveToHistory(MyRealtimeLocationModel patient) async {
// //     try {
// //       MyHistoryReposity.savePatientLocation(
// //         HistoryModel(
// //           deviceID: patient.deviceID,
// //           patientID: patient.patientID,
// //           isInSafeZone: patient.isInSafeZone,
// //           isCurrentlySafe: patient.isCurrentlySafe,
// //           currentlyIn: patient.currentlyIn,
// //           currentLocationLng: patient.currentLocationLng,
// //           currentLocationLat: patient.currentLocationLat,
// //           timeStamp: patient.timeStamp,
// //           deviceBatteryPercentage: patient.deviceBatteryPercentage,
// //           bPM: patient.bPM,
// //           requestBPM: patient.requestBPM,
// //         ),
// //       );

// //       log("SUCCESSFULLY SAVED TO HISTORY!");
// //     } catch (e, stackTrace) {
// //       log("AN ERROR OCCURED IN SAVE TO HISTORY FUNCTION: $e, AT $stackTrace");
// //     }
// //   }
// // }

// import 'dart:async';
// import 'dart:developer';

// import 'package:wanderhuman_app/helper/history_reposity.dart';
// import 'package:wanderhuman_app/model/history_model.dart';
// import 'package:wanderhuman_app/model/realtime_location_model.dart';

// class MyRealtimeToHistoryProcessor {
//   static int timeGapInSeconds = 30;
//   static Timer? _timer;

//   // ✅ The "Waiting Room" Buffer.
//   // It uses the patientID as the key, so if a patient sends 5 updates in 1 second,
//   // it just overwrites the old one. We only keep the absolute latest location.
//   static final Map<String, MyRealtimeLocationModel> _patientBuffer = {};

//   /// Call this from your Stream to put the latest data into the waiting room
//   static void addPatientToBuffer(MyRealtimeLocationModel patientData) {
//     _patientBuffer[patientData.patientID] = patientData;
//   }

//   /// Starts the sweeping timer
//   static Future<void> initTimer() async {
//     try {
//       if (_timer == null) {
//         _timer = Timer.periodic(Duration(seconds: timeGapInSeconds), (timer) {
//           // Only hit the database if there is actually data waiting
//           if (_patientBuffer.isNotEmpty) {
//             // 1. Loop through everyone in the waiting room and save them
//             for (var patient in _patientBuffer.values) {
//               _saveToHistory(patient);
//             }

//             // 2. Empty the waiting room so we don't save duplicate data next second
//             _patientBuffer.clear();
//           }
//         });

//         log("HISTORY TIMER SUCCESSFULLY INITIALIZED");
//       } else {
//         log("HISTORY TIMER ALREADY INITIALIZED");
//       }
//     } catch (e, stackTrace) {
//       log("AN ERROR OCCURED IN INIT TIMER FUNCTION: $e, AT $stackTrace");
//     }
//   }

//   /// Stops the sweeping timer
//   static void stopTimer() {
//     _timer?.cancel();
//     _timer = null;
//     _patientBuffer.clear();
//     log("HISTORY TIMER STOPPED");
//   }

//   // Made this private (_) since it only needs to be called by the timer now
//   static Future<void> _saveToHistory(MyRealtimeLocationModel patient) async {
//     try {
//       await MyHistoryReposity.savePatientLocation(
//         HistoryModel(
//           deviceID: patient.deviceID,
//           patientID: patient.patientID,
//           isInSafeZone: patient.isInSafeZone,
//           isCurrentlySafe: patient.isCurrentlySafe,
//           currentlyIn: patient.currentlyIn,
//           currentLocationLng: patient.currentLocationLng,
//           currentLocationLat: patient.currentLocationLat,
//           timeStamp: patient.timeStamp,
//           deviceBatteryPercentage: patient.deviceBatteryPercentage,
//           bPM: patient.bPM,
//           requestBPM: patient.requestBPM,
//         ),
//       );
//       // Removed the success log here because it will spam your console every 1 second
//     } catch (e, stackTrace) {
//       log("ERROR SAVING HISTORY FOR ${patient.patientID}: $e, AT $stackTrace");
//     }
//   }
// }
