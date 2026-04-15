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
  String assistedByWhenInDanger;

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
    required this.assistedByWhenInDanger,
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
        assistedByWhenInDanger: data['assistedByWhenInDanger'] ?? "",
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
  static Map<String, dynamic> toMap(
    MyRealtimeLocationModel data, [
    String assistedByWhenInDanger = "",
  ]) {
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
      // only used when the patient is in danger, otherwise it will be an empty string
      "assistedByWhenInDanger": assistedByWhenInDanger,
    };
  }
}
