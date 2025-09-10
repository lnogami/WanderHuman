// import 'dart:math';

// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
// import 'package:wanderhuman_app/view/home/widgets/map/users_history.dart';

// void showAllUsers({
//   required mp.MapboxMap mapboxMapController,
//   required List<FirebaseUserHistory> allUsers,
// }) {
//   if (allUsers.isEmpty) return;

//   final lats = allUsers.map((u) => u.currentLocation.latitude).toList();
//   final lngs = allUsers.map((u) => u.currentLocation.longitude).toList();

//   final minLat = lats.reduce(min);
//   final maxLat = lats.reduce(max);
//   final minLng = lngs.reduce(min);
//   final maxLng = lngs.reduce(max);

//   mapboxMapController.setCamera(
//     mp.CameraOptions(
//       center: mp.Point(
//         coordinates: mp.Position((minLng + maxLng) / 2, (minLat + maxLat) / 2),
//       ),
//       zoom: _calculateZoomForBounds(maxLat - minLat, maxLng - minLng),
//     ),
//   );
// }

// double _calculateZoomForBounds(double latDiff, double lngDiff) {
//   final maxDiff = max(latDiff, lngDiff);
//   if (maxDiff < 0.01) return 14.0;
//   if (maxDiff < 0.05) return 11.0;
//   if (maxDiff < 0.1) return 9.0;
//   return 7.0;
// }

// TODO: not yet implemented
