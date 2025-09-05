// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
// import 'package:geolocator/geolocator.dart' as gl;
// import 'package:wanderhuman_app/view/home/widgets/map/patient.dart';
// import 'package:wanderhuman_app/view/home/widgets/map/patient_services.dart';

// class PatientMap extends StatefulWidget {
//   const PatientMap({super.key});

//   @override
//   State<PatientMap> createState() => _PatientMapState();
// }

// class _PatientMapState extends State<PatientMap> {
//   mp.MapboxMap? _mapboxMap;

//   // Reuse managers (DON’T recreate them on every update)
//   mp.PointAnnotationManager? _pointMgr;
//   mp.PolylineAnnotationManager? _polylineMgr;

//   final PatientService _patientService = PatientService();
//   StreamSubscription<List<Patient>>? _patientsSub;

//   // Keep references so we can update instead of recreating
//   final Map<String, mp.PointAnnotation> _patientMarkers = {};
//   final Map<String, mp.PolylineAnnotation> _patientTrails = {};

//   @override
//   void initState() {
//     super.initState();

//     mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return mp.MapWidget(
//       onMapCreated: (mapboxMap) async {
//         _mapboxMap = mapboxMap;

//         // Create managers once
//         _pointMgr = await _mapboxMap!.annotations
//             .createPointAnnotationManager();
//         _polylineMgr = await _mapboxMap!.annotations
//             .createPolylineAnnotationManager();

//         _listenToPatients();
//       },
//     );
//   }

//   void _listenToPatients() {
//     _patientsSub?.cancel();
//     _patientsSub = _patientService.listenToPatients().listen((patients) {
//       for (final patient in patients) {
//         _updatePatientMarker(patient);
//         _checkSafeZoneAndMaybeAppendTrail(patient);
//         _drawOrUpdateTrail(patient);
//       }
//     });
//   }

//   // Create or update the patient's marker
//   Future<void> _updatePatientMarker(Patient patient) async {
//     if (_mapboxMap == null || _pointMgr == null) return;

//     final mp.Point newPoint = mp.Point(
//       coordinates: mp.Position(patient.lng, patient.lat),
//     );

//     if (_patientMarkers.containsKey(patient.id)) {
//       // ✅ Update existing marker: mutate geometry then call update()
//       final ann = _patientMarkers[patient.id]!;
//       ann.geometry = newPoint; // <-- mutate
//       await _pointMgr!.update(ann); // <-- apply
//     } else {
//       // ✅ Create new marker (NOTE: use geometry:, not point:)
//       final created = await _pointMgr!.create(
//         mp.PointAnnotationOptions(
//           geometry: newPoint,
//           textField: patient.id, // small label
//           textSize: 12,
//           // set an image if you need: image: <Uint8List>
//         ),
//       );
//       _patientMarkers[patient.id] = created;
//     }
//   }

//   // When outside the safe zone, append to their trail in your backend
//   void _checkSafeZoneAndMaybeAppendTrail(Patient patient) {
//     final distance = gl.Geolocator.distanceBetween(
//       patient.lat,
//       patient.lng,
//       patient.safeZoneLat,
//       patient.safeZoneLng,
//     );

//     if (distance > patient.safeZoneRadius) {
//       _patientService.updateTrail(patient.id, patient.lat, patient.lng);
//       // NOTE: patient.trail coming from Firestore will include new points
//       // on the next stream emission; draw method below will re-render.
//     }
//   }

//   // Create or update a polyline per patient
//   Future<void> _drawOrUpdateTrail(Patient patient) async {
//     if (_mapboxMap == null || _polylineMgr == null) return;

//     // // Convert your trail coords to Mapbox Points
//     // final List<mp.Point> points = patient.trail
//     //     .map((c) => mp.Point(coordinates: mp.Position(c['lng']!, c['lat']!)))
//     //     .toList();

//     // if (points.length < 2) {
//     //   // Not enough points to draw a line; optionally delete if it exists
//     //   if (_patientTrails.containsKey(patient.id)) {
//     //     await _polylineMgr!.delete(_patientTrails[patient.id]!);
//     //     _patientTrails.remove(patient.id);
//     //   }
//     //   return;
//     // }

//     // 1. Prepare the point list
//     final List<mp.Point> points = patient.trail
//         .map(
//           (coord) => mp.Point(
//             coordinates: mp.Position(
//               coord['lng']!, // note: longitude first
//               coord['lat']!,
//             ),
//           ),
//         )
//         .toList();

//     // assume `points` is List<mp.Point>
//     final List<mp.Position> coords = points
//         .map((p) => p.coordinates!) // extract Position from each Point
//         .toList();

//     // create LineString from positions
//     final mp.LineString lineString = mp.LineString(coordinates: coords);

//     // create a polyline annotation
//     final polylineOptions = mp.PolylineAnnotationOptions(
//       geometry: lineString,
//       lineWidth: 4.0,
//       lineColor: Colors.red.toARGB32(), // int ARGB color
//     );

//     // create it
//     final polyline = await _polylineMgr?.create(polylineOptions);

//     //   // 2. Update an existing polyline
//     //   if (_patientTrails.containsKey(patient.id)) {
//     //     final existing = _patientTrails[patient.id]!;
//     //     existing.geometry = points;
//     //     existing.lineColor = Colors.red.toARGB32();
//     //     existing.lineWidth = 4.0;
//     //     await _polylineMgr!.update(existing);
//     //   } else {
//     //     // 3. Create a new polyline
//     //     final created = await _polylineMgr!.create(
//     //       mp.PolylineAnnotationOptions(
//     //         geometry: points,               // <-- required field
//     //         lineColor: Colors.red.toARGB32(),  // ARGB integer
//     //         lineWidth: 4.0,
//     //       ),
//     //     );
//     //     _patientTrails[patient.id] = created;
//     //   }
//   }

//   @override
//   void dispose() {
//     _patientsSub?.cancel();
//     // (Optional) Clean up annotations
//     // _pointMgr?.deleteAll();
//     // _polylineMgr?.deleteAll();
//     super.dispose();
//   }
// }
