// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// class MyGeofenceModel {
//   String geofenceID;
//   String geofenceName;
//   List<Position> geofenceCoordinates;
//   Position centerCoordinates;
//   String createdAt;
//   String createdBy;
//   List<String> registeredPatients;
//   bool isActive;

//   MyGeofenceModel({
//     required this.geofenceID,
//     required this.geofenceName,
//     required this.geofenceCoordinates,
//     required this.centerCoordinates,
//     required this.createdAt,
//     required this.createdBy,
//     required this.registeredPatients,
//     required this.isActive,
//   });

//   factory MyGeofenceModel.fromFirestore(Map<String, dynamic> data) {
//     return MyGeofenceModel(
//       geofenceID: data["geofenceID"] ?? "",
//       geofenceName: data["geofenceName"] ?? "",
//       geofenceCoordinates: data["geofenceCoordinates"] ?? [],
//       centerCoordinates: data["centerCoordinates"] ?? [],
//       createdAt: data["createdAt"] ?? "",
//       createdBy: data["createdBy"] ?? "",
//       registeredPatients: data["registeredPatients"] ?? [],
//       isActive: data["isActive"] ?? false,
//     );
//   }

//   // Helper functions for converting coordinates between different formats

//   /// `List<Position>` object to `List<Map<String, double>>` for easier storage in Firestore
//   static List<Map<String, double>> coordinatesToListOfMaps(List<Position> coordinates){
//     return coordinates.map((position) {
//       return {
//         "lng": position.lng as double,
//         "lat": position.lat as double,
//       };
//     }).toList();
//   }

//   /// `List<Map<String, double>>` object to `List<Position>` for easier retrieval from Firestore
//   static List<Position> listOfMapsToCoordinates(List<Map<String, double>> listOfMaps){
//     return listOfMaps.map((map) {
//       return Position(
//         map["lng"] as double,
//         map["lat"] as double,
//       );
//     }).toList();
//   }
// }

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyGeofenceModel {
  String geofenceID;
  String geofenceName;
  // 1. Store the USEFUL type (Position), not the raw Map
  List<Position> geofenceCoordinates;
  Position centerCoordinates;
  String createdAt;
  String createdBy;
  List<String> registeredPatients;
  bool isActive;

  MyGeofenceModel({
    required this.geofenceID,
    required this.geofenceName,
    required this.geofenceCoordinates,
    required this.centerCoordinates,
    required this.createdAt,
    required this.createdBy,
    required this.registeredPatients,
    required this.isActive,
  });

  // ==========================================
  // READ: Firestore Map -> App Object
  // ==========================================
  factory MyGeofenceModel.fromFirestore({
    required Map<String, dynamic> data,
    required String docId,
  }) {
    return MyGeofenceModel(
      geofenceID: docId, // Use the doc ID from Firestore
      geofenceName: data["geofenceName"] ?? "",

      // 2. CONVERT the list of maps into a List of Positions
      geofenceCoordinates:
          (data["geofenceCoordinates"] as List<dynamic>?)
              ?.map(
                (item) => Position(
                  (item["lng"] as num).toDouble(),
                  (item["lat"] as num).toDouble(),
                ),
              )
              .toList() ??
          [],

      // 3. CONVERT the single map into a single Position
      centerCoordinates: Position(
        (data["centerCoordinates"]?["lng"] as num? ?? 0.0).toDouble(),
        (data["centerCoordinates"]?["lat"] as num? ?? 0.0).toDouble(),
      ),

      createdAt: data["createdAt"] ?? "",
      createdBy: data["createdBy"] ?? "",

      // 4. SAFE CASTING for the String list
      registeredPatients: List<String>.from(data["registeredPatients"] ?? []),
      isActive: data["isActive"] ?? false,
    );
  }

  // ==========================================
  // WRITE: App Object -> Firestore Map
  // ==========================================
  Map<String, dynamic> toFirestore({required String docID}) {
    return {
      "geofenceID": docID,
      "geofenceName": geofenceName,
      // Convert List<Position> back to List<Map>
      "geofenceCoordinates": geofenceCoordinates
          .map((pos) => {"lng": pos.lng, "lat": pos.lat})
          .toList(),
      // Convert Position back to Map
      "centerCoordinates": {
        "lng": centerCoordinates.lng,
        "lat": centerCoordinates.lat,
      },
      "createdAt": createdAt,
      "createdBy": createdBy,
      "registeredPatients": registeredPatients,
      "isActive": isActive,
    };
  }
}
