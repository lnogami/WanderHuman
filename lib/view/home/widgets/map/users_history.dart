// User model for Firebase data
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class FirebaseUserHistory {
  // final String id;
  // final String name;
  // final double latitude;
  // final double longitude;
  // final bool isOnline;
  // final DateTime lastUpdate;
  // final bool isInSafeZone;
  // final String status; // 'safe', 'warning', 'danger'
  // final Map<String, dynamic>? metadata;
  final String patientID;
  final String currentlyIn;
  final Position currentLocation;
  final String timeStamp;
  final bool isInSafeZone;
  final String deviceBatteryPercentage;

  FirebaseUserHistory({
    // required this.id,
    // required this.name,
    // required this.latitude,
    // required this.longitude,
    // required this.isOnline,
    // required this.lastUpdate,
    // required this.isInSafeZone,
    // required this.status,
    // this.metadata,
    required this.patientID,
    required this.currentlyIn,
    required this.currentLocation,
    required this.timeStamp,
    required this.isInSafeZone,
    required this.deviceBatteryPercentage,
  });

  factory FirebaseUserHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseUserHistory(
      // id: doc.id,
      // name: data['name'] ?? 'Unknown User',
      // latitude: (data['latitude'] ?? 0.0).toDouble(),
      // longitude: (data['longitude'] ?? 0.0).toDouble(),
      // isOnline: data['isOnline'] ?? false,
      // lastUpdate:
      //     (data['lastUpdate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // isInSafeZone: data['isInSafeZone'] ?? false,
      // status: data['status'] ?? 'safe',
      // metadata: data['metadata'],
      patientID: data['patientID'] ?? 'Unknown User',
      currentlyIn: data['currentlyIn'] ?? 'Unknown User',
      currentLocation: data['currentLocation'] ?? '0,0',
      timeStamp: data['timeStamp'] ?? 'Unknown User',
      isInSafeZone: data['isInSafeZone'] ?? false,
      deviceBatteryPercentage:
          data['deviceBatteryPercentage'] ?? 'Unknown User',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      // 'name': name,
      // 'latitude': latitude,
      // 'longitude': longitude,
      // 'isOnline': isOnline,
      // 'lastUpdate': Timestamp.fromDate(lastUpdate),
      // 'isInSafeZone': isInSafeZone,
      // 'status': status,
      // 'metadata': metadata,
      'patientID': patientID,
      'currentlyIn': currentlyIn,
      'currentLocation': currentLocation,
      'timeStamp': timeStamp,
      'isInSafeZone': isInSafeZone,
    };
  }
}
