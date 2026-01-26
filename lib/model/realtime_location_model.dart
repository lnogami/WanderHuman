// newly added, not yet tested out
class RealtimeLocationModel {
  String deviceID;
  String patientID;
  bool isInSafeZone;
  String currentlyIn;
  String currentLocationLng;
  String currentLocationLat;
  String timeStamp;
  int deviceBatteryPercentage;

  RealtimeLocationModel({
    required this.deviceID,
    required this.patientID,
    required this.isInSafeZone,
    required this.currentlyIn,
    required this.currentLocationLng,
    required this.currentLocationLat,
    required this.timeStamp,
    required this.deviceBatteryPercentage,
  });

  factory RealtimeLocationModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return RealtimeLocationModel(
      deviceID: data['deviceID'] ?? "",
      patientID: data['patientID'] ?? "",
      isInSafeZone: data['isInSafeZone'] ?? "",
      currentlyIn: data['currentlyIn'] ?? "",
      currentLocationLng: data['currentLocationLng'] ?? "",
      currentLocationLat: data['currentLocationLat'] ?? "",
      timeStamp: data['timeStamp'] ?? "",
      deviceBatteryPercentage: data['deviceBatteryPercentage'] ?? "",
    );
  }
}
