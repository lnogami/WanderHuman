// This is a simple model class for Patient
// It helps us convert Firestore data into a Dart object
class Patient {
  final String id;
  final double lat;
  final double lng;
  final double safeZoneLat;
  final double safeZoneLng;
  final double safeZoneRadius; // in meters
  final List<Map<String, double>> trail; // list of {lat, lng}

  Patient({
    required this.id,
    required this.lat,
    required this.lng,
    required this.safeZoneLat,
    required this.safeZoneLng,
    required this.safeZoneRadius,
    required this.trail,
  });

  // Factory = convert Firestore document → Patient object
  factory Patient.fromFirestore(String id, Map<String, dynamic> data) {
    return Patient(
      id: id,
      lat: data['lat'] ?? 0,
      lng: data['lng'] ?? 0,
      safeZoneLat: data['safeZoneLat'] ?? 0,
      safeZoneLng: data['safeZoneLng'] ?? 0,
      safeZoneRadius: (data['safeZoneRadius'] ?? 100).toDouble(),
      trail: List<Map<String, double>>.from(
        (data['trail'] ?? []).map(
          (coord) => {"lat": coord['lat'], "lng": coord['lng']},
        ),
      ),
    );
  }
}
