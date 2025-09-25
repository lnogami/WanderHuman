import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/helper/firebase_services.dart';
import 'package:wanderhuman_app/model/history.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';

///
Future<bool> savePatientLocation({
  required String patientID,
  required DateTime lastSaved,

  /// NOTE: must be in this order Lng, Lat, and Alt (optional)
  required Position currentPositon,
  int deviceBatteryPercentage = 0,
  BuildContext? context, // for debugging purposes ra ni
}) async {
  // retrieves all patient history in firebase
  List<PatientHistory> allPatientsHistory =
      await MyFirebaseServices.getAllPatientsLatestHistory();
  // retrieves the latest record of a specific patient based on patientID
  PatientHistory patientHistory = allPatientsHistory.firstWhere(
    (element) => element.patientID == patientID,
    // this is just a placeholder (yet) if no data is available
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

  if (certainSecondsHasPassed || locationChanged) {
    MyFirebaseServices.savePatientLocation(
      PatientHistory(
        patientID:
            "${FirebaseAuth.instance.currentUser!.uid}_as_PATIENT", // statically base on the current logged in user
        isInSafeZone: true,
        currentlyIn: "Livingroom",
        currentLocation: currentPositon,
        timeStamp: DateTime.timestamp(),
        deviceBatteryPercentage: deviceBatteryPercentage.toString(),
      ),
    );
    showMyAnimatedSnackBar(
      context: context!,
      dataToDisplay: "Succesfully saved data! On time of: $lastSaved",
    );
    return true;
  } else {
    showMyAnimatedSnackBar(context: context!, dataToDisplay: "UNSUCCESSFUL!");
    print("❌ UNSUCCESSFUL - No save needed - conditions not met");
    return false;
  }
}
