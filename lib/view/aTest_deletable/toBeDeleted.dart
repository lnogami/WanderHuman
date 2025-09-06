// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:geolocator/geolocator.dart' as gl;
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
// import 'package:wanderhuman_app/view/home/widgets/utility_functions/bottom_modal_sheet.dart';
// import 'package:wanderhuman_app/view/home/widgets/utility_functions/show_alert_dialog.dart';

// // User model to represent each user
// class MapUser {
//   final String id;
//   final String name;
//   final double latitude;
//   final double longitude;
//   final Color markerColor;
//   final String? avatarPath; // Optional custom avatar
//   final bool isOnline;

//   MapUser({
//     required this.id,
//     required this.name,
//     required this.latitude,
//     required this.longitude,
//     this.markerColor = Colors.blue,
//     this.avatarPath,
//     this.isOnline = true,
//   });
// }

// class MapBody extends StatefulWidget {
//   const MapBody({super.key});

//   @override
//   State<MapBody> createState() => _MapBodyState();
// }

// class _MapBodyState extends State<MapBody> {
//   // controller for the map
//   mp.MapboxMap? mapboxMapController;
//   StreamSubscription? userPositionStream;

//   // Point annotation manager for handling multiple markers
//   mp.PointAnnotationManager? pointAnnotationManager;

//   // Current user position
//   gl.Position? myPosition;

//   // List of all users to display on map
//   List<MapUser> allUsers = [];

//   // Map to keep track of created annotations
//   Map<String, mp.PointAnnotation> userAnnotations = {};

//   @override
//   void initState() {
//     super.initState();
//     setup();
//     checkAndRequestLocationPermission();
//     // Initialize with some sample users (replace with your data source)
//     initializeSampleUsers();
//   }

//   @override
//   void dispose() {
//     userPositionStream?.cancel();
//     super.dispose();
//   }

//   Future<void> setup() async {
//     mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
//   }

//   // Initialize sample users - replace this with your actual data source
//   void initializeSampleUsers() {
//     allUsers = [
//       MapUser(
//         id: "user1",
//         name: "Alice Johnson",
//         latitude: 37.7749,
//         longitude: -122.4194,
//         markerColor: Colors.red,
//         isOnline: true,
//       ),
//       MapUser(
//         id: "user2",
//         name: "Bob Smith",
//         latitude: 37.7849,
//         longitude: -122.4094,
//         markerColor: Colors.green,
//         isOnline: true,
//       ),
//       MapUser(
//         id: "user3",
//         name: "Charlie Brown",
//         latitude: 37.7649,
//         longitude: -122.4294,
//         markerColor: Colors.purple,
//         isOnline: false,
//       ),
//     ];
//   }

//   // Method to update user locations (call this when you receive location updates)
//   void updateUserLocation(String userId, double latitude, double longitude) {
//     final userIndex = allUsers.indexWhere((user) => user.id == userId);
//     if (userIndex != -1) {
//       // Update user location
//       allUsers[userIndex] = MapUser(
//         id: allUsers[userIndex].id,
//         name: allUsers[userIndex].name,
//         latitude: latitude,
//         longitude: longitude,
//         markerColor: allUsers[userIndex].markerColor,
//         avatarPath: allUsers[userIndex].avatarPath,
//         isOnline: allUsers[userIndex].isOnline,
//       );

//       // Refresh markers on map
//       _updateUserMarkers();
//     }
//   }

//   // Method to add a new user
//   void addUser(MapUser newUser) {
//     if (!allUsers.any((user) => user.id == newUser.id)) {
//       setState(() {
//         allUsers.add(newUser);
//       });
//       _updateUserMarkers();
//     }
//   }

//   // Method to remove a user
//   void removeUser(String userId) {
//     setState(() {
//       allUsers.removeWhere((user) => user.id == userId);
//     });

//     // Remove the annotation from map
//     if (userAnnotations.containsKey(userId)) {
//       pointAnnotationManager?.delete(userAnnotations[userId]!);
//       userAnnotations.remove(userId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return mp.MapWidget(
//       onMapCreated: _onMapCreated,
//       styleUri: mp.MapboxStyles.SATELLITE_STREETS,
//     );
//   }

//   void _onMapCreated(mp.MapboxMap controller) async {
//     setState(() {
//       mapboxMapController = controller;
//     });

//     // Initialize point annotation manager
//     pointAnnotationManager = await mapboxMapController?.annotations
//         .createPointAnnotationManager();

//     // Configure map settings (same as your original code)
//     _configureMapSettings();

//     bool isLocationServiceEnabled =
//         await gl.Geolocator.isLocationServiceEnabled();
//     if (mounted) {
//       showMyDialogBox(context, isLocationServiceEnabled);
//     }

//     // Add all users to map after map is created
//     _updateUserMarkers();
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

//   // Method to update all user markers on the map
//   Future<void> _updateUserMarkers() async {
//     if (pointAnnotationManager == null) return;

//     // Clear existing annotations
//     for (var annotation in userAnnotations.values) {
//       await pointAnnotationManager?.delete(annotation);
//     }
//     userAnnotations.clear();

//     // Create markers for all users
//     for (var user in allUsers) {
//       await _createUserMarker(user);
//     }

//     // Set up tap events for all markers
//     pointAnnotationManager?.tapEvents(
//       onTap: (mp.PointAnnotation tappedAnnotation) {
//         // Find which user was tapped
//         String? tappedUserId;
//         for (var entry in userAnnotations.entries) {
//           if (entry.value == tappedAnnotation) {
//             tappedUserId = entry.key;
//             break;
//           }
//         }

//         if (tappedUserId != null) {
//           final tappedUser = allUsers.firstWhere(
//             (user) => user.id == tappedUserId,
//           );
//           _showUserBottomSheet(context, tappedUser);
//         }
//       },
//     );
//   }

//   // Create a marker for a specific user
//   Future<void> _createUserMarker(MapUser user) async {
//     try {
//       // Load different marker images based on user status or use custom avatar
//       String markerAsset = user.isOnline
//           ? "assets/icons/pin.png"
//           : "assets/icons/pin_offline.png";

//       // If user has custom avatar, you could create a custom marker
//       final Uint8List imageData = await imageToIconLoader(markerAsset);

//       mp.PointAnnotationOptions pointAnnotationOptions =
//           mp.PointAnnotationOptions(
//             image: imageData,
//             iconSize: 0.15,
//             iconColor: user.markerColor.toARGB32(),
//             textField: user.name,
//             textSize: 12.5,
//             textColor: user.isOnline
//                 ? Colors.blue.toARGB32()
//                 : Colors.grey.toARGB32(),
//             textOcclusionOpacity: 1,
//             isDraggable: false, // Set to true if you want users to drag markers
//             textAnchor: mp.TextAnchor.BOTTOM,
//             textOffset: [0, -1.2],
//             geometry: mp.Point(
//               coordinates: mp.Position(user.longitude, user.latitude),
//             ),
//           );

//       // Create the annotation
//       final annotation = await pointAnnotationManager?.create(
//         pointAnnotationOptions,
//       );
//       if (annotation != null) {
//         userAnnotations[user.id] = annotation;
//       }
//     } catch (e) {
//       print("Error creating marker for user ${user.name}: $e");
//     }
//   }

//   // Custom bottom sheet for user info
//   void _showUserBottomSheet(BuildContext context, MapUser user) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 user.name,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text("Status: ${user.isOnline ? 'Online' : 'Offline'}"),
//               Text("Lat: ${user.latitude.toStringAsFixed(6)}"),
//               Text("Lng: ${user.longitude.toStringAsFixed(6)}"),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       // Navigate to user location
//                       _moveToUser(user);
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Go to Location"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Add your custom action here (e.g., chat, call)
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Contact"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Move camera to specific user
//   void _moveToUser(MapUser user) {
//     mapboxMapController?.setCamera(
//       mp.CameraOptions(
//         zoom: 16.0,
//         center: mp.Point(
//           coordinates: mp.Position(user.longitude, user.latitude),
//         ),
//       ),
//     );
//   }

//   // Method to center map on all users
//   void _fitAllUsers() {
//     if (allUsers.isEmpty) return;

//     // Calculate bounds
//     double minLat = allUsers
//         .map((u) => u.latitude)
//         .reduce((a, b) => a < b ? a : b);
//     double maxLat = allUsers
//         .map((u) => u.latitude)
//         .reduce((a, b) => a > b ? a : b);
//     double minLng = allUsers
//         .map((u) => u.longitude)
//         .reduce((a, b) => a < b ? a : b);
//     double maxLng = allUsers
//         .map((u) => u.longitude)
//         .reduce((a, b) => a > b ? a : b);

//     // Add padding
//     double padding = 0.01;

//     mapboxMapController?.setCamera(
//       mp.CameraOptions(
//         center: mp.Point(
//           coordinates: mp.Position(
//             (minLng + maxLng) / 2,
//             (minLat + maxLat) / 2,
//           ),
//         ),
//         zoom: _calculateZoomLevel(
//           minLat - padding,
//           maxLat + padding,
//           minLng - padding,
//           maxLng + padding,
//         ),
//       ),
//     );
//   }

//   // Calculate appropriate zoom level for bounds
//   double _calculateZoomLevel(
//     double minLat,
//     double maxLat,
//     double minLng,
//     double maxLng,
//   ) {
//     double latDiff = maxLat - minLat;
//     double lngDiff = maxLng - minLng;
//     double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

//     if (maxDiff < 0.01) return 15.0;
//     if (maxDiff < 0.05) return 12.0;
//     if (maxDiff < 0.1) return 10.0;
//     if (maxDiff < 0.5) return 8.0;
//     return 6.0;
//   }

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
//       distanceFilter: 100,
//     );

//     userPositionStream?.cancel();
//     userPositionStream =
//         gl.Geolocator.getPositionStream(
//           locationSettings: locationSettings,
//         ).listen((gl.Position? position) async {
//           if (position != null && mapboxMapController != null) {
//             myPosition = position;

//             // Update current user location in the users list
//             updateUserLocation(
//               "current_user",
//               position.latitude,
//               position.longitude,
//             );

//             // Optionally center on current user
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
