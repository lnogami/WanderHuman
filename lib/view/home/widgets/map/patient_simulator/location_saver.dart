import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/helper/history_reposity.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';

///
Future<bool> savePatientLocation({
  required String patientID,
  required DateTime lastSaved,

  /// NOTE: must be in this order Lng, Lat, and Alt (optional)
  required Position currentPositon,
  int deviceBatteryPercentage = 0,
  BuildContext? context, // for debugging purposes ra ni
}) async {
  try {
    // // retrieves all patient history in firebase
    // List<HistoryModel> allPatientsHistory =
    //     await MyHistoryReposity.getAllPatientsLatestHistory();
    // // retrieves the latest record of a specific patient based on patientID
    // HistoryModel patientHistory = allPatientsHistory.firstWhere(
    //   (element) => element.patientID == patientID,
    //   // this is just a placeholder (yet) if no data is available
    //   orElse: () => HistoryModel(
    //     deviceID: "No Data Retrived",
    //     patientID: patientID, // place holder
    //     isInSafeZone: false, // place holder
    //     currentlyIn: "No Data Retrived", // place holder
    //     // currentLocation: currentPositon, // place holder
    //     currentLocationLng: currentPositon.lng.toString(), // place holder
    //     currentLocationLat: currentPositon.alt.toString(), // place holder
    //     timeStamp: lastSaved.toString(), // place holder
    //     deviceBatteryPercentage: "100", // place holder
    //   ),
    // );
    // Position patientLastLocation = Position(
    //   double.parse(patientHistory.currentLocationLng),
    //   double.parse(patientHistory.currentLocationLat),
    // );
    Position patientLastLocation = currentPositon;

    final now = DateTime.now();

    // Condition 1: checks if 30 seconds have passed since the last save
    bool certainSecondsHasPassed = now.difference(lastSaved).inSeconds >= 30;

    // Condition2: checks if the userLocation changed
    bool locationChanged =
        patientLastLocation.lng != currentPositon.lng ||
        patientLastLocation.lat != currentPositon.lat;

    if (certainSecondsHasPassed || locationChanged) {
      MyHistoryReposity.savePatientLocation(
        HistoryModel(
          deviceID: "No Data Retrieved",
          patientID: patientID, // place holder
          isInSafeZone: false, // place holder
          currentlyIn: "No Data Retrieved", // place holder
          // currentLocation: currentPositon, // place holder
          currentLocationLng: currentPositon.lng.toString(), // place holder
          currentLocationLat: currentPositon.lat.toString(), // place holder
          timeStamp: lastSaved.toString(), // place holder
          deviceBatteryPercentage: "100", // place holder
          bPM: "100",
          requestBPM: "100",
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
  } catch (e, stackTrace) {
    print("ERRORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR: $e");
    print("STACKTRACEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: $stackTrace");
    throw Exception();
  }
}
