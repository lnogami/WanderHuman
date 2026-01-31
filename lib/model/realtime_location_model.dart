// // newly added, not yet tested out
// class RealtimeLocationModel {
//   String deviceID;
//   String patientID;
//   bool isInSafeZone;
//   String currentlyIn;
//   String currentLocationLng;
//   String currentLocationLat;
//   String timeStamp;
//   int deviceBatteryPercentage;

//   RealtimeLocationModel({
//     required this.deviceID,
//     required this.patientID,
//     required this.isInSafeZone,
//     required this.currentlyIn,
//     required this.currentLocationLng,
//     required this.currentLocationLat,
//     required this.timeStamp,
//     required this.deviceBatteryPercentage,
//   });

//   factory RealtimeLocationModel.fromFirestore(
//     String id,
//     Map<String, dynamic> data,
//   ) {
//     return RealtimeLocationModel(
//       deviceID: data['deviceID'] ?? "",
//       patientID: data['patientID'] ?? "",
//       isInSafeZone: data['isInSafeZone'] ?? "",
//       currentlyIn: data['currentlyIn'] ?? "",
//       currentLocationLng: data['currentLocationLng'] ?? "",
//       currentLocationLat: data['currentLocationLat'] ?? "",
//       timeStamp: data['timeStamp'] ?? "",
//       deviceBatteryPercentage: data['deviceBatteryPercentage'] ?? "",
//     );
//   }
// }

class MyRealtimeLocationModel {
  String deviceID;
  String patientID;
  bool isInSafeZone;
  String currentlyIn;
  String currentLocationLng;
  String currentLocationLat;
  String timeStamp;
  int deviceBatteryPercentage;
  String bPM;
  bool requestBPM;

  MyRealtimeLocationModel({
    required this.deviceID,
    required this.patientID,
    required this.isInSafeZone,
    required this.currentlyIn,
    required this.currentLocationLng,
    required this.currentLocationLat,
    required this.timeStamp,
    required this.deviceBatteryPercentage,
    required this.bPM,
    required this.requestBPM,
  });

  static Map<String, dynamic> toMap(MyRealtimeLocationModel data) {
    return {
      "deviceID": data.deviceID,
      "patientID": data.patientID,
      "isInSafeZone": data.isInSafeZone,
      "currentlyIn": data.currentlyIn,
      "currentLocationLng": data.currentLocationLng,
      "currentLocationLat": data.currentLocationLat,
      "timeStamp": data.timeStamp,
      "deviceBatteryPercentage": data.deviceBatteryPercentage,
      "bPM": data.bPM,
      "requestBPM": data.requestBPM,
    };
  }

  // renamed from fromFirestore to fromMap for clarity
  factory MyRealtimeLocationModel.fromMap({
    required String deviceID,
    required Map<String, dynamic> data,
  }) {
    try {
      return MyRealtimeLocationModel(
        deviceID: data['deviceID'] ?? "",
        patientID: data['patientID'] ?? "",
        isInSafeZone: data['isInSafeZone'] ?? false,
        currentlyIn: data['currentlyIn'] ?? "",
        currentLocationLng: data['currentLocationLng'] ?? "",
        currentLocationLat: data['currentLocationLat'] ?? "",
        timeStamp: data['timeStamp'] ?? "",
        deviceBatteryPercentage: data['deviceBatteryPercentage'] ?? 1,
        bPM: data['bPM'] ?? "",
        requestBPM: data['requestBPM'] ?? false,
      );
    } catch (e) {
      print(
        "AN ERROR OCCUREDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD WHILE EXECUTING HistoryModel.fromFirestore: $e",
      );
      print("DATE TIME FORMATTTTTTTTTTTTTT: ${DateTime.now().toString()}");
      throw Exception();
    }
  }
}
