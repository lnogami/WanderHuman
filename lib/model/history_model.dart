// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// class PatientHistory {
//   String patientID;
//   bool isInSafeZone;
//   String currentlyIn;
//   Position currentLocation;
//   DateTime timeStamp;
//   String deviceBatteryPercentage;

//   PatientHistory({
//     required this.patientID,
//     required this.isInSafeZone,
//     required this.currentlyIn,
//     required this.currentLocation,
//     required this.timeStamp,
//     required this.deviceBatteryPercentage,
//   });

//   // factory PatientHistory.toFirestore(
//   //   String patientID,
//   //   bool isInSafeZone,
//   //   String currentlyIn,
//   //   // this will become an array in Firestore, but ma List sya inig retrieve ["currentPosition"][0] for longhitude and ["currentPosition"][1] for latitude
//   //   Position currentLocation,
//   //   DateTime timeStamp,
//   //   String deviceBatteryPercentage,
//   // ) {
//   //   return PatientHistory(
//   //     patientID: patientID,
//   //     isInSafeZone: isInSafeZone,
//   //     currentlyIn: currentlyIn,
//   //     currentLocation: currentLocation,
//   //     timeStamp: timeStamp,
//   //     deviceBatteryPercentage: deviceBatteryPercentage,
//   //   );
//   // }
// }

// newly added, not yet tested out
import 'package:wanderhuman_app/model/realtime_location_model.dart';

class MyHistoryModel {
  String deviceID;
  String patientID;
  bool isInSafeZone;
  bool isCurrentlySafe;
  String currentlyIn;
  String currentLocationLng;
  String currentLocationLat;
  String timeStamp;
  int deviceBatteryPercentage;
  String bPM;
  bool requestBPM;

  MyHistoryModel({
    required this.deviceID,
    required this.patientID,
    required this.isInSafeZone,
    required this.isCurrentlySafe,
    required this.currentlyIn,
    required this.currentLocationLng,
    required this.currentLocationLat,
    required this.timeStamp,
    required this.deviceBatteryPercentage,
    required this.bPM,
    required this.requestBPM,
  });

  factory MyHistoryModel.fromFirestore(Map<String, dynamic> data) {
    try {
      return MyHistoryModel(
        deviceID: data['deviceID'] ?? "",
        patientID: data['patientID'] ?? "",
        isInSafeZone: data['isInSafeZone'] ?? "",
        isCurrentlySafe: data['isCurrentlySafe'] ?? "",
        currentlyIn: data['currentlyIn'] ?? "",
        currentLocationLng: data['currentLocationLng'] ?? "",
        currentLocationLat: data['currentLocationLat'] ?? "",
        timeStamp: data['timeStamp'] ?? "",
        deviceBatteryPercentage: data['deviceBatteryPercentage'] ?? "",
        bPM: data['bPM'] ?? "",
        requestBPM: data['requestBPM'] ?? "",
      );
    } catch (e) {
      print(
        "AN ERROR OCCUREDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD WHILE EXECUTING HistoryModel.fromFirestore: $e",
      );
      print("DATE TIME FORMATTTTTTTTTTTTTT: ${DateTime.now().toString()}");
      throw Exception();
    }
  }

  /// To convert into Map object, for efficiently uploading to firebase
  static Map<String, dynamic> toMap(MyRealtimeLocationModel data) {
    return {
      "deviceID": data.deviceID,
      "patientID": data.patientID,
      "isInSafeZone": data.isInSafeZone,
      "isCurrentlySafe": data.isCurrentlySafe,
      "currentlyIn": data.currentlyIn,
      "currentLocationLng": data.currentLocationLng,
      "currentLocationLat": data.currentLocationLat,
      // "timeStamp": data.timeStamp,
      "timeStamp": DateTime.now().toString(), // temporary
      "deviceBatteryPercentage": data.deviceBatteryPercentage,
      "bPM": data.bPM,
      "requestBPM": data.requestBPM,
    };
  }
}
