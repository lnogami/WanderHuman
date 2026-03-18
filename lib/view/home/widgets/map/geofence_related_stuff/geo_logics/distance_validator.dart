// import 'dart:math' as math;

// class MyDistanceValidator{
//   /// Calculates the distance between two points in meters using the Haversine formula.
//   static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
//     const double earthRadius = 6371000; // Radius of the earth in meters
//     double dLat = _toRadians(lat2 - lat1);
//     double dlng = _toRadians(lng2 - lng1);

//     double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_toRadians(lat1)) *
//             math.cos(_toRadians(lat2)) *
//             math.sin(dlng / 2) *
//             math.sin(dlng / 2);

//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     return earthRadius * c;
//   }

//   static double _toRadians(double degree) {
//     return degree * (math.pi / 180);
//   }

//   /// Checks if the distance between two points is within a specified threshold.
//   static bool isWithinThreshold({
//     required double lat1,
//     required double lng1,
//     required double lat2,
//     required double lng2,
//     required double thresholdInMeters,
//   }) {
//     double distance = calculateDistance(lat1, lng1, lat2, lng2);
//     return distance <= thresholdInMeters;
//   }

// }

import 'dart:developer';
import 'dart:math' as math;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyDistanceValidator {
  final List<Map<String, double>> _buffer = [];
  final int bufferSize = 10;
  final double maxWalkingSpeedMs =
      2.5; // Max meters per second (brisk walk/light jog)

  Map<String, double>? lastValidLocation;
  DateTime? lastTimestamp;

  double _lastValidHeading = 0.0;
  double get currentHeading => _lastValidHeading;

  /// Filters out GPS noise using a buffer and anomaly detection
  // Map<String, double>? processNewLocation( double lng, double lat) {
  Position? processNewLocation(double lng, double lat) {
    DateTime now = DateTime.now();

    // --- STEP 1: ANOMALY DETECTION (The Velocity Test) ---
    if (lastValidLocation != null && lastTimestamp != null) {
      double distance = calculateDistance(
        lastValidLocation!['lng']!,
        lastValidLocation!['lat']!,
        lng,
        lat,
      );

      double timeSeconds = now.difference(lastTimestamp!).inSeconds.toDouble();
      if (timeSeconds == 0) timeSeconds = 1; // Prevent division by zero

      double speed = distance / timeSeconds;

      // If speed > 2.5m/s (roughly 9km/h), it's likely a GPS jump/noise
      if (speed > maxWalkingSpeedMs) {
        log(
          "NOTICEEEEE: Anomaly detected! Speed: $speed m/s. Coordinate ignored.",
        );
        lastTimestamp = now;
        // return lastValidLocation;
        return Position(lastValidLocation!['lng']!, lastValidLocation!['lat']!);
      }
    }

    // --- STEP 2: BUFFERING (The Queue) ---
    _buffer.add({'lat': lat, 'lng': lng});
    if (_buffer.length > bufferSize) {
      _buffer.removeAt(0); // Keep only the latest 10
    }

    // For debugging purposes only
    for (int i = 0; i < _buffer.length; i++) {
      log(
        "Buffered Position [$i]: lng:${_buffer[i]['lng']}, lat:${_buffer[i]['lat']}",
      );
    }

    // --- STEP 3: SMOOTHING (Simple Moving Average) ---
    double avgLng =
        _buffer.map((e) => e['lng']!).reduce((a, b) => a + b) / _buffer.length;
    double avgLat =
        _buffer.map((e) => e['lat']!).reduce((a, b) => a + b) / _buffer.length;

    // --- STEP 4: HEADING FILTER ---
    if (lastValidLocation != null) {
      double distMoved = calculateDistance(
        lastValidLocation!['lng']!,
        lastValidLocation!['lat']!,
        avgLng,
        avgLat,
      );

      // Only update heading if they moved more than 2 meters
      // This prevents the "spinning icon" while stationary
      if (distMoved > 2.0) {
        _lastValidHeading = _calculateBearing(
          lastValidLocation!['lat']!,
          lastValidLocation!['lng']!,
          avgLat,
          avgLng,
        );
      }
    }

    lastValidLocation = {'lng': avgLng, 'lat': avgLat};
    lastTimestamp = now;

    // return lastValidLocation;
    return Position(avgLng, avgLat);
  }

  // The Haversine code you provided goes here...
  static double calculateDistance(
    double lng1,
    double lat1,
    double lng2,
    double lat2,
  ) {
    const double earthRadius = 6371000;
    double dLat = (lat2 - lat1) * (math.pi / 180);
    double dlng = (lng2 - lng1) * (math.pi / 180);
    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dlng / 2) *
            math.sin(dlng / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Calculates the bearing (0-360 degrees) between two points
  double _calculateBearing(double lat1, double lng1, double lat2, double lng2) {
    double dLon = (lng2 - lng1) * (math.pi / 180);
    double y = math.sin(dLon) * math.cos(lat2 * (math.pi / 180));
    double x =
        math.cos(lat1 * (math.pi / 180)) * math.sin(lat2 * (math.pi / 180)) -
        math.sin(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.cos(dLon);

    double brng = math.atan2(y, x) * (180 / math.pi);
    return (brng + 360) % 360; // Normalize to 0-360
  }
}
