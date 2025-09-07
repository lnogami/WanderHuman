// // ignore_for_file: avoid_print

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:geolocator/geolocator.dart' as gl;
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wanderhuman_app/view/home/widgets/map/independent_functions/move_to_user.dart';
// import 'package:wanderhuman_app/view/home/widgets/map/independent_functions/show_all_users.dart';
// import 'package:wanderhuman_app/view/home/widgets/map/users_history.dart';
// import 'package:wanderhuman_app/view/home/widgets/utility_functions/show_alert_dialog.dart';

// // Safe zone configuration
// class SafeZone {
//   final double centerLatitude;
//   final double centerLongitude;
//   final double radiusInMeters;
//   final String name;

//   SafeZone({
//     required this.centerLatitude,
//     required this.centerLongitude,
//     required this.radiusInMeters,
//     required this.name,
//   });

//   bool isPointInside(double lat, double lng) {
//     final distance = gl.Geolocator.distanceBetween(
//       centerLatitude,
//       centerLongitude,
//       lat,
//       lng,
//     );
//     return distance <= radiusInMeters;
//   }
// }

// class MapBody extends StatefulWidget {
//   const MapBody({super.key});

//   @override
//   State<MapBody> createState() => _MapBodyState();
// }

// class _MapBodyState extends State<MapBody> {
//   // Core MapBox components
//   mp.MapboxMap? mapboxMapController;
//   mp.PointAnnotationManager? pointAnnotationManager;
//   mp.PolylineAnnotationManager? polylineAnnotationManager;
//   mp.CircleAnnotationManager? circleAnnotationManager;

//   // Streams and timers
//   StreamSubscription? userPositionStream;
//   StreamSubscription<QuerySnapshot>? firebaseUserHistorysStream;
//   Timer? locationUpdateTimer;

//   // Data management
//   final Map<String, mp.PointAnnotation> userMarkers = {};
//   final Map<String, mp.PolylineAnnotation> userTrails = {};
//   final Map<String, List<mp.Position>> userLocationHistory = {};
//   final Map<String, Uint8List> preloadedImages = {};
//   List<FirebaseUserHistory> allUsers = [];
//   gl.Position? myPosition;

//   // Safe zone configuration
//   late SafeZone safeZone;
//   mp.CircleAnnotation? safeZoneCircle;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSafeZone();
//     _preloadMarkerImages();
//     setup();
//     checkAndRequestLocationPermission();
//     _startFirebaseListener();
//     _startLocationUpdateTimer();
//   }

//   @override
//   void dispose() {
//     userPositionStream?.cancel();
//     firebaseUserHistorysStream?.cancel();
//     locationUpdateTimer?.cancel();
//     super.dispose();
//   }

//   void _initializeSafeZone() {
//     // Configure your safe zone here
//     safeZone = SafeZone(
//       centerLatitude: 37.7749, // San Francisco center
//       centerLongitude: -122.4194,
//       radiusInMeters: 1000, // 1km radius
//       name: "Safe Zone",
//     );
//   }

//   Future<void> _preloadMarkerImages() async {
//     try {
//       preloadedImages['safe'] = await imageToIconLoader(
//         "assets/icons/user_safe.png",
//       );
//       preloadedImages['warning'] = await imageToIconLoader(
//         "assets/icons/user_warning.png",
//       );
//       preloadedImages['danger'] = await imageToIconLoader(
//         "assets/icons/user_danger.png",
//       );
//       preloadedImages['offline'] = await imageToIconLoader(
//         "assets/icons/user_offline.png",
//       );
//     } catch (e) {
//       print("Error preloading images: $e");
//       // Fallback to default pin
//       preloadedImages['safe'] = await imageToIconLoader("assets/icons/pin.png");
//       preloadedImages['warning'] = preloadedImages['safe']!;
//       preloadedImages['danger'] = preloadedImages['safe']!;
//       preloadedImages['offline'] = preloadedImages['safe']!;
//     }
//   }

//   Future<void> setup() async {
//     mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: mp.MapWidget(
//         onMapCreated: _onMapCreated,
//         styleUri: mp.MapboxStyles.SATELLITE_STREETS,
//       ),
//       floatingActionButton: _buildControlButtons(),
//     );
//   }

//   Widget _buildControlButtons() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         FloatingActionButton(
//           heroTag: "center_safe_zone",
//           mini: true,
//           onPressed: _centerOnSafeZone,
//           tooltip: "Center on Safe Zone",
//           child: const Icon(Icons.location_searching),
//         ),
//         const SizedBox(height: 8),
//         FloatingActionButton(
//           heroTag: "show_all_users",
//           mini: true,
//           onPressed: () {
//             showAllUsers(
//               mapboxMapController: mapboxMapController!,
//               allUsers: allUsers,
//             );
//           },
//           tooltip: "Show All Users",
//           child: const Icon(Icons.people),
//         ),
//         const SizedBox(height: 8),
//         FloatingActionButton(
//           heroTag: "clear_trails",
//           mini: true,
//           onPressed: _clearAllTrails,
//           tooltip: "Clear Trails",
//           child: const Icon(Icons.clear_all),
//         ),
//       ],
//     );
//   }

//   void _onMapCreated(mp.MapboxMap controller) async {
//     setState(() {
//       mapboxMapController = controller;
//     });

//     // Initialize annotation managers
//     pointAnnotationManager = await controller.annotations
//         .createPointAnnotationManager();
//     polylineAnnotationManager = await controller.annotations
//         .createPolylineAnnotationManager();
//     circleAnnotationManager = await controller.annotations
//         .createCircleAnnotationManager();

//     _configureMapSettings();
//     _drawSafeZone();

//     // Set up marker tap events
//     pointAnnotationManager?.tapEvents(
//       onTap: (mp.PointAnnotation tappedAnnotation) {
//         _handleMarkerTap(tappedAnnotation);
//       },
//     );

//     bool isLocationServiceEnabled =
//         await gl.Geolocator.isLocationServiceEnabled();
//     if (mounted) {
//       showMyDialogBox(context, isLocationServiceEnabled);
//     }
//   }

//   void _configureMapSettings() {
//     // Location component settings
//     mapboxMapController?.location.updateSettings(
//       mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
//     );

//     // Scale bar settings
//     mapboxMapController!.scaleBar.updateSettings(
//       mp.ScaleBarSettings(
//         enabled: true,
//         position: mp.OrnamentPosition.BOTTOM_LEFT,
//         primaryColor: Colors.blue.toARGB32(),
//         showTextBorder: true,
//         textColor: Colors.blue.toARGB32(),
//         borderWidth: 1,
//         textBorderWidth: 0.2,
//         marginBottom: 8,
//         marginLeft: 8,
//       ),
//     );

//     // Logo settings
//     mapboxMapController!.logo.updateSettings(
//       mp.LogoSettings(
//         position: mp.OrnamentPosition.BOTTOM_RIGHT,
//         marginRight: 25,
//       ),
//     );

//     // Attribution settings
//     mapboxMapController!.attribution.updateSettings(
//       mp.AttributionSettings(
//         iconColor: const Color.fromARGB(100, 33, 149, 243).toARGB32(),
//         position: mp.OrnamentPosition.BOTTOM_RIGHT,
//       ),
//     );

//     // Compass settings
//     mapboxMapController!.compass.updateSettings(
//       mp.CompassSettings(marginTop: 80, marginRight: 15, opacity: 0.70),
//     );
//   }

//   // Draw safe zone circle on map
//   Future<void> _drawSafeZone() async {
//     if (circleAnnotationManager == null) return;

//     final circleOptions = mp.CircleAnnotationOptions(
//       geometry: mp.Point(
//         coordinates: mp.Position(
//           safeZone.centerLongitude,
//           safeZone.centerLatitude,
//         ),
//       ),
//       circleRadius: _metersToCircleRadius(safeZone.radiusInMeters),
//       circleColor: Colors.green.withAlpha(50).toARGB32(),
//       circleStrokeColor: Colors.green.toARGB32(),
//       circleStrokeWidth: 12.0,
//     );

//     safeZoneCircle = await circleAnnotationManager?.create(circleOptions);
//   }

//   double _metersToCircleRadius(double meters) {
//     // Approximate conversion - adjust based on your needs
//     return meters * 0.00001;
//   }

//   // Start Firebase real-time listener
//   void _startFirebaseListener() {
//     firebaseUserHistorysStream = FirebaseFirestore.instance
//         .collection('History')
//         // .where('userType', isEqualTo: "Patient")
//         .snapshots()
//         .listen(
//           (QuerySnapshot snapshot) {
//             final users = snapshot.docs
//                 .map((doc) => FirebaseUserHistory.fromFirestore(doc))
//                 .toList();
//             _handleFirebaseUserHistoryUpdates(users);
//           },
//           onError: (error) {
//             print("Firebase listener error: $error");
//           },
//         );
//   }

//   // Handle Firebase user updates
//   void _handleFirebaseUserHistoryUpdates(List<FirebaseUserHistory> users) {
//     setState(() {
//       allUsers = users;
//     });
//     _updateAllUserMarkers();
//   }

//   // Start timer for location updates (every 5 minutes)
//   void _startLocationUpdateTimer() {
//     locationUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
//       _updateUserLocationsInFirebase();
//     });
//   }

//   // Update user locations in Firebase
//   Future<void> _updateUserLocationsInFirebase() async {
//     if (myPosition == null) return;

//     try {
//       final isInSafe = safeZone.isPointInside(
//         myPosition!.latitude,
//         myPosition!.longitude,
//       );

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc('current_user') // Replace with actual user ID
//           .set({
//             'latitude': myPosition!.latitude,
//             'longitude': myPosition!.longitude,
//             'lastUpdate': FieldValue.serverTimestamp(),
//             'isInSafeZone': isInSafe,
//             'status': isInSafe ? 'safe' : 'warning',
//             'isOnline': true,
//           }, SetOptions(merge: true));
//     } catch (e) {
//       print("Error updating location in Firebase: $e");
//     }
//   }

//   // Update all user markers
//   Future<void> _updateAllUserMarkers() async {
//     if (pointAnnotationManager == null) return;

//     // Get current user IDs
//     final currentUserIds = allUsers.map((u) => u.patientID).toSet();
//     final existingUserIds = userMarkers.keys.toSet();

//     // Remove markers for users no longer online
//     final usersToRemove = existingUserIds.difference(currentUserIds);
//     for (final userId in usersToRemove) {
//       await _removeUserMarker(userId);
//     }

//     // Update or create markers for current users
//     for (final user in allUsers) {
//       if (userMarkers.containsKey(user.patientID)) {
//         await _updateUserMarker(user);
//       } else {
//         await _createUserMarker(user);
//       }

//       // Update location history and trails
//       _updateUserLocationHistory(user);

//       // Draw trail if user is outside safe zone
//       if (!user.isInSafeZone) {
//         await _updateUserTrail(user);
//       }
//     }
//   }

//   // Create marker for user
//   Future<void> _createUserMarker(FirebaseUserHistory user) async {
//     try {
//       // final imageKey = _getImageKeyForUser(user);
//       // final imageData = preloadedImages[imageKey];
//       // if (imageData == null) return;

//       final options = mp.PointAnnotationOptions(
//         geometry: mp.Point(
//           // coordinates: mp.Position(user.longitude, user.latitude),
//           coordinates: mp.Position(
//             user.currentLocation.longitude,
//             user.currentLocation.latitude,
//           ),
//         ),
//         // image: imageData,
//         iconSize: 0.15,
//         // iconColor: _getColorForUser(user).toARGB32(),
//         // TODO: to be added Personal Info
//         // textField: user.name,
//         textSize: 12.5,
//         // textColor: _getColorForUser(user).toARGB32(),
//         textAnchor: mp.TextAnchor.BOTTOM,
//         textOffset: [0, -1.2],
//         isDraggable: false,
//       );

//       final annotation = await pointAnnotationManager?.create(options);
//       if (annotation != null) {
//         userMarkers[user.patientID] = annotation;
//       }
//     } catch (e) {
//       // TODO: to be added Personal Info
//       // print("Error creating marker for ${user.name}: $e");
//     }
//   }

//   // Update existing user marker
//   Future<void> _updateUserMarker(FirebaseUserHistory user) async {
//     final annotation = userMarkers[user.patientID];
//     if (annotation == null) return;

//     try {
//       // final imageKey = _getImageKeyForUser(user);
//       // final imageData = preloadedImages[imageKey];
//       // if (imageData == null) return;

//       // final updatedOptions =
//       mp.PointAnnotationOptions(
//         geometry: mp.Point(
//           coordinates: mp.Position(
//             user.currentLocation.longitude,
//             user.currentLocation.latitude,
//           ),
//         ),
//         // image: imageData,
//         iconSize: 0.15,
//         // iconColor: _getColorForUser(user).toARGB32(),
//         // TODO: to be added Personal Info
//         // textField: user.name,
//         textField: "Temporary Name",
//         textSize: 12.5,
//         // textColor: _getColorForUser(user).toARGB32(),
//         textAnchor: mp.TextAnchor.BOTTOM,
//         textOffset: [0, -1.2],
//         isDraggable: false,
//       );

//       await pointAnnotationManager?.update(annotation);
//     } catch (e) {
//       // TODO: to be added Personal Info
//       // print("Error updating marker for ${user.name}: $e");
//     }
//   }

//   // Remove user marker
//   Future<void> _removeUserMarker(String userId) async {
//     final annotation = userMarkers.remove(userId);
//     if (annotation != null) {
//       await pointAnnotationManager?.delete(annotation);
//     }

//     // Also remove trail
//     final trail = userTrails.remove(userId);
//     if (trail != null) {
//       await polylineAnnotationManager?.delete(trail);
//     }

//     // Clear location history
//     userLocationHistory.remove(userId);
//   }

//   // Update user location history
//   void _updateUserLocationHistory(FirebaseUserHistory user) {
//     final position = mp.Position(
//       user.currentLocation.longitude,
//       user.currentLocation.latitude,
//     );

//     if (!userLocationHistory.containsKey(user.patientID)) {
//       userLocationHistory[user.patientID] = [];
//     }

//     final history = userLocationHistory[user.patientID]!;

//     // Add new position if it's different from the last one
//     if (history.isEmpty ||
//         (history.last.lng != position.lng ||
//             history.last.lat != position.lat)) {
//       history.add(position);

//       // Limit history to last 50 points to prevent memory issues
//       if (history.length > 50) {
//         history.removeAt(0);
//       }
//     }
//   }

//   // Update user trail line
//   Future<void> _updateUserTrail(FirebaseUserHistory user) async {
//     if (polylineAnnotationManager == null) return;

//     final history = userLocationHistory[user.patientID];
//     if (history == null || history.length < 2) return;

//     try {
//       // Remove existing trail
//       final existingTrail = userTrails[user.patientID];
//       if (existingTrail != null) {
//         await polylineAnnotationManager?.delete(existingTrail);
//       }

//       // Create new trail
//       final polylineOptions = mp.PolylineAnnotationOptions(
//         geometry: mp.LineString(coordinates: history),
//         lineColor: _getTrailColorForUser(user).toARGB32(),
//         lineWidth: 3.0,
//         lineOpacity: 0.8,
//       );

//       final trail = await polylineAnnotationManager?.create(polylineOptions);
//       if (trail != null) {
//         userTrails[user.patientID] = trail;
//       }
//     } catch (e) {
//       //
//       // print("Error updating trail for ${user.name}: $e");
//     }
//   }

//   // Get appropriate image key for user status
//   // String _getImageKeyForUser(FirebaseUserHistory user) {
//   //   if (!user.isOnline) return 'offline';
//   //   return user.status;
//   // }

//   // // Get color for user based on status
//   // Color _getColorForUser(FirebaseUserHistory user) {
//   //   if (!user.isOnline) return Colors.grey;

//   //   switch (user.status) {
//   //     case 'safe':
//   //       return Colors.green;
//   //     case 'warning':
//   //       return Colors.orange;
//   //     case 'danger':
//   //       return Colors.red;
//   //     default:
//   //       return Colors.blue;
//   //   }
//   // }

//   // Get trail color for user
//   Color _getTrailColorForUser(FirebaseUserHistory user) {
//     return user.isInSafeZone ? Colors.green : Colors.red;
//   }

//   // Handle marker tap
//   void _handleMarkerTap(mp.PointAnnotation tappedAnnotation) {
//     final tappedUserId = userMarkers.entries
//         .firstWhere(
//           (entry) => entry.value == tappedAnnotation,
//           orElse: () => MapEntry('', tappedAnnotation),
//         )
//         .key;

//     if (tappedUserId.isNotEmpty) {
//       final user = allUsers.firstWhere((u) => u.patientID == tappedUserId);
//       _showUserBottomSheet(user);
//     }
//   }

//   // Show user information bottom sheet
//   void _showUserBottomSheet(FirebaseUserHistory user) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               // user.name,
//               "temporary name",
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(
//                   user.isInSafeZone ? Icons.check_circle : Icons.warning,
//                   color: user.isInSafeZone ? Colors.green : Colors.red,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(user.isInSafeZone ? "In Safe Zone" : "Outside Safe Zone"),
//               ],
//             ),
//             // Text("Status: ${user.status.toUpperCase()}"),
//             // Text("Last Update: ${user.lastUpdate.toString().substring(0, 16)}"),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     moveToUser(
//                       mapboxMapController: mapboxMapController!,
//                       user: user,
//                     );
//                   },
//                   child: const Text("Go to Location"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _toggleUserTrail(user.patientID);
//                   },
//                   child: const Text("Toggle Trail"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Navigation methods
//   // GIBALHIN NA NI NAKOG SEPARATE FILE
//   // // void _moveToUser(FirebaseUserHistory user) {
//   // //   mapboxMapController?.setCamera(
//   // //     mp.CameraOptions(
//   // //       center: mp.Point(
//   // //         coordinates: mp.Position(
//   // //           user.currentLocation.longitude,
//   // //           user.currentLocation.latitude,
//   // //         ),
//   // //       ),
//   // //       zoom: 16.0,
//   // //     ),
//   // //   );
//   // // }

//   void _centerOnSafeZone() {
//     mapboxMapController?.setCamera(
//       mp.CameraOptions(
//         center: mp.Point(
//           coordinates: mp.Position(
//             safeZone.centerLongitude,
//             safeZone.centerLatitude,
//           ),
//         ),
//         zoom: 14.0,
//       ),
//     );
//   }

//   // GIBALHIN NA NI NAKOG SEPARATE FILE
//   // // void _showAllUsers() {
//   // //   if (allUsers.isEmpty) return;

//   // //   final lats = allUsers.map((u) => u.currentLocation.latitude).toList();
//   // //   final lngs = allUsers.map((u) => u.currentLocation.longitude).toList();

//   // //   final minLat = lats.reduce(min);
//   // //   final maxLat = lats.reduce(max);
//   // //   final minLng = lngs.reduce(min);
//   // //   final maxLng = lngs.reduce(max);

//   // //   mapboxMapController?.setCamera(
//   // //     mp.CameraOptions(
//   // //       center: mp.Point(
//   // //         coordinates: mp.Position(
//   // //           (minLng + maxLng) / 2,
//   // //           (minLat + maxLat) / 2,
//   // //         ),
//   // //       ),
//   // //       zoom: _calculateZoomForBounds(maxLat - minLat, maxLng - minLng),
//   // //     ),
//   // //   );
//   // // }

//   // // double _calculateZoomForBounds(double latDiff, double lngDiff) {
//   // //   final maxDiff = max(latDiff, lngDiff);
//   // //   if (maxDiff < 0.01) return 14.0;
//   // //   if (maxDiff < 0.05) return 11.0;
//   // //   if (maxDiff < 0.1) return 9.0;
//   // //   return 7.0;
//   // // }

//   // Toggle user trail visibility
//   void _toggleUserTrail(String userId) {
//     // Implementation for showing/hiding specific user trails
//     final trail = userTrails[userId];
//     if (trail != null) {
//       // Trail exists, remove it
//       polylineAnnotationManager?.delete(trail);
//       userTrails.remove(userId);
//     } else {
//       // Trail doesn't exist, create it if user is outside safe zone
//       final user = allUsers.firstWhere((u) => u.patientID == userId);
//       if (!user.isInSafeZone) {
//         _updateUserTrail(user);
//       }
//     }
//   }

//   // Clear all trails
//   void _clearAllTrails() async {
//     for (final trail in userTrails.values) {
//       await polylineAnnotationManager?.delete(trail);
//     }
//     userTrails.clear();
//     userLocationHistory.clear();
//   }

//   // Location permission and tracking (same as original)
//   Future<void> checkAndRequestLocationPermission() async {
//     bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error("Location services are disabled.");
//     }

//     gl.LocationPermission permission = await gl.Geolocator.checkPermission();

//     if (permission == gl.LocationPermission.denied) {
//       permission = await gl.Geolocator.requestPermission();
//       if (permission == gl.LocationPermission.denied) {
//         return Future.error("Location services are denied.");
//       }
//     }

//     if (permission == gl.LocationPermission.deniedForever) {
//       return Future.error(
//         "Location permissions are permanently denied, we cannot request permissions.",
//       );
//     }

//     gl.LocationSettings locationSettings = gl.LocationSettings(
//       accuracy: gl.LocationAccuracy.high,
//       distanceFilter: 50, // Update every 50 meters
//     );

//     userPositionStream?.cancel();
//     userPositionStream =
//         gl.Geolocator.getPositionStream(
//           locationSettings: locationSettings,
//         ).listen((gl.Position? position) async {
//           if (position != null && mapboxMapController != null) {
//             myPosition = position;

//             // Center camera on current user location
//             mapboxMapController?.setCamera(
//               mp.CameraOptions(
//                 zoom: 15.0,
//                 center: mp.Point(
//                   coordinates: mp.Position(
//                     position.longitude,
//                     position.latitude,
//                   ),
//                 ),
//               ),
//             );
//           }
//         });
//   }

//   Future<Uint8List> imageToIconLoader(String imagePath) async {
//     var byteData = await rootBundle.load(imagePath);
//     return byteData.buffer.asUint8List();
//   }
// }
