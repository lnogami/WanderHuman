import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/helper/firebase_services.dart';
import 'package:wanderhuman_app/model/history.dart';

Future<void> savePatientLocation({
  required String patientID,
  required DateTime lastSaved,
  required Position currentPositon,
}) async {
  // retrieves all patient history in firebase
  List<PatientHistory> allPatientsHistory =
      await MyFirebaseServices.getAllPatientsLatestHistory();
  PatientHistory patientHistory = allPatientsHistory.firstWhere(
    (element) => element.patientID == patientID,
    orElse: () => PatientHistory(
      patientID: "No Data Retrived", // place holder
      isInSafeZone: false, // place holder
      currentlyIn: "No Data Retrived", // place holder
      currentLocation: currentPositon, // place holder
      timeStamp: DateTime.now(), // place holder
      deviceBatteryPercentage: "No Data Retrived", // place holder
    ),
  );
  Position patientLastLocation = patientHistory.currentLocation;

  final now = DateTime.now();

  // Condition 1: checks if 30 seconds have passed since the last save
  bool certainSecondsHasPassed = now.difference(lastSaved).inSeconds >= 30;

  // Condition2: checks if the userLocation changed
  bool locationChanged =
      patientLastLocation.lng != currentPositon.lng ||
      patientLastLocation.lat != currentPositon.lat;

  if (certainSecondsHasPassed || locationChanged) {}
}
