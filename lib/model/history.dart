import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class PatientHistory {
  String patientID;
  bool isInSafeZone;
  String currentlyIn;
  Position currentLocation;
  DateTime timeStamp;
  String deviceBatteryPercentage;

  PatientHistory({
    required this.patientID,
    required this.isInSafeZone,
    required this.currentlyIn,
    required this.currentLocation,
    required this.timeStamp,
    required this.deviceBatteryPercentage,
  });

  factory PatientHistory.toFirestore(
    String patientID,
    bool isInSafeZone,
    String currentlyIn,
    Position currentLocation,
    DateTime timeStamp,
    String deviceBatteryPercentage,
  ) {
    return PatientHistory(
      patientID: patientID,
      isInSafeZone: isInSafeZone,
      currentlyIn: currentlyIn,
      currentLocation: currentLocation,
      timeStamp: timeStamp,
      deviceBatteryPercentage: deviceBatteryPercentage,
    );
  }
}
