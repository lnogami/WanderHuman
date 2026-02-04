import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyGeofenceModel {
  String geofenceID;
  String geofenceName;
  List<List<Position>> geofenceCoordinates;
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

  factory MyGeofenceModel.fromFirestore(Map<String, dynamic> data) {
    return MyGeofenceModel(
      geofenceID: data["geofenceID"] ?? "",
      geofenceName: data["geofenceName"] ?? "",
      geofenceCoordinates: data["geofenceCoordinates"] ?? [],
      centerCoordinates: data["centerCoordinates"] ?? [],
      createdAt: data["createdAt"] ?? "",
      createdBy: data["createdBy"] ?? "",
      registeredPatients: data["registeredPatients"] ?? [],
      isActive: data["isActive"] ?? false,
    );
  }
}
