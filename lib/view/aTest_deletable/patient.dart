// // This is a simple model class for Patient
// // It helps us convert Firestore firestoreData into a Dart object
// class Patient {
//   final String id;
//   final double lat;
//   final double lng;
//   final double safeZoneLat;
//   final double safeZoneLng;
//   final double safeZoneRadius; // in meters
//   final List<Map<String, double>> trail; // list of {lat, lng}

//   Patient({
//     required this.id,
//     required this.lat,
//     required this.lng,
//     required this.safeZoneLat,
//     required this.safeZoneLng,
//     required this.safeZoneRadius,
//     required this.trail,
//   });

//   // Factory = convert Firestore document → Patient object
//   factory Patient.fromFirestore(String id, Map<String, dynamic> firestoreData) {
//     return Patient(
//       id: id,
//       lat: firestoreData['lat'] ?? 0,
//       lng: firestoreData['lng'] ?? 0,
//       safeZoneLat: firestoreData['safeZoneLat'] ?? 0,
//       safeZoneLng: firestoreData['safeZoneLng'] ?? 0,
//       safeZoneRadius: (firestoreData['safeZoneRadius'] ?? 100).toDouble(),
//       trail: List<Map<String, double>>.from(
//         (firestoreData['trail'] ?? []).map(
//           (coord) => {"lat": coord['lat'], "lng": coord['lng']},
//         ),
//       ),
//     );
//   }
// }
