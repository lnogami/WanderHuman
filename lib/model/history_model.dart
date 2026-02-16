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
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';

class HistoryModel {
  String deviceID;
  String patientID;
  bool isInSafeZone;
  bool isCurrentlySafe;
  String currentlyIn;
  String currentLocationLng;
  String currentLocationLat;
  String timeStamp;
  String deviceBatteryPercentage;
  String bPM;
  String requestBPM;

  HistoryModel({
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

  factory HistoryModel.fromFirestore(Map<String, dynamic> data) {
    try {
      return HistoryModel(
        deviceID: data['deviceID'] ?? "",
        patientID: data['patientID'] ?? "",
        isInSafeZone: data['isInSafeZone'] ?? "",
        isCurrentlySafe: data['isCurrentlySafe'] ?? "",
        currentlyIn: data['currentlyIn'] ?? "",
        currentLocationLng: data['currentLocationLng'] ?? "",
        currentLocationLat: data['currentLocationLat'] ?? "",
        timeStamp: MyDateFormatter.formatDate(
          dateTimeInString: data['timeStamp'].toString(),
        ),
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
}
