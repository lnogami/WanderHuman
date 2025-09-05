import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

// Step 1: User Data Model
class MapUser {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final bool isOnline;
  final DateTime lastSeen;

  MapUser({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isOnline,
    required this.lastSeen,
  });
}

class MyMapBody extends StatefulWidget {
  const MyMapBody({super.key});

  @override
  State<MyMapBody> createState() => _MyMapBodyState();
}

class _MyMapBodyState extends State<MyMapBody> {
  // Step 2: Essential MapBox Components
  mp.MapboxMap? mapboxMapController;
  mp.PointAnnotationManager? pointAnnotationManager;

  // Step 3: Data Management
  final Map<String, mp.PointAnnotation> userMarkers = {};
  final Map<String, Uint8List> preloadedImages = {};
  List<MapUser> currentUsers = [];

  // Step 4: Real-time Update Streams
  StreamSubscription<List<MapUser>>? userUpdatesStream;
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    _preloadMarkerImages();
    _startListeningToUsers();
  }

  @override
  void dispose() {
    userUpdatesStream?.cancel();
    updateTimer?.cancel();
    super.dispose();
  }

  // Step 5: Preload marker images for performance
  Future<void> _preloadMarkerImages() async {
    preloadedImages['online'] = await _loadImage(
      'assets/icons/user_online.png',
    );
    preloadedImages['offline'] = await _loadImage(
      'assets/icons/user_offline.png',
    );
  }

  Future<Uint8List> _loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mp.MapWidget(
        onMapCreated: _onMapCreated,
        styleUri: mp.MapboxStyles.STANDARD,
        cameraOptions: mp.CameraOptions(
          center: mp.Point(
            coordinates: mp.Position(-122.4194, 37.7749), // San Francisco
          ),
          zoom: 12.0,
        ),
      ),
      floatingActionButton: _buildControlButtons(),
    );
  }

  // Step 6: Initialize Map and Annotation Manager
  Future<void> _onMapCreated(mp.MapboxMap controller) async {
    mapboxMapController = controller;

    // Create the annotation manager for handling markers
    pointAnnotationManager = await controller.annotations
        .createPointAnnotationManager();

    // Set up tap events for user markers
    pointAnnotationManager?.tapEvents(
      onTap: (mp.PointAnnotation tappedAnnotation) {
        _handleMarkerTap(tappedAnnotation);
      },
    );

    // Initial marker creation if users already loaded
    if (currentUsers.isNotEmpty) {
      await _updateAllUserMarkers();
    }
  }

  // Step 7: Handle Real-time User Updates
  void _startListeningToUsers() {
    // Simulate real-time updates (replace with your data source)
    updateTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _simulateUserUpdates();
    });

    /* Replace above with real data source like:
    userUpdatesStream = FirebaseFirestore.instance
      .collection('users')
      .where('isOnline', isEqualTo: true)
      .snapshots()
      .listen((snapshot) {
        final users = snapshot.docs.map((doc) => MapUser.fromFirestore(doc)).toList();
        _handleUserUpdates(users);
      });
    */
  }

  // Step 8: Process User Updates
  Future<void> _handleUserUpdates(List<MapUser> updatedUsers) async {
    setState(() {
      currentUsers = updatedUsers;
    });

    if (pointAnnotationManager != null) {
      await _updateAllUserMarkers();
    }
  }

  // Step 9: Efficient Marker Updates
  Future<void> _updateAllUserMarkers() async {
    if (pointAnnotationManager == null) return;

    // Get current user IDs
    final currentUserIds = currentUsers.map((u) => u.id).toSet();
    final existingUserIds = userMarkers.keys.toSet();

    // Remove markers for users no longer in the list
    final usersToRemove = existingUserIds.difference(currentUserIds);
    for (final userId in usersToRemove) {
      await _removeUserMarker(userId);
    }

    // Update or create markers for current users
    for (final user in currentUsers) {
      if (userMarkers.containsKey(user.id)) {
        await _updateUserMarker(user);
      } else {
        await _createUserMarker(user);
      }
    }
  }

  // Step 10: Create Individual User Marker
  Future<void> _createUserMarker(MapUser user) async {
    try {
      final imageKey = user.isOnline ? 'online' : 'offline';
      final imageData = preloadedImages[imageKey];

      if (imageData == null) return;

      final options = mp.PointAnnotationOptions(
        geometry: mp.Point(
          coordinates: mp.Position(user.longitude, user.latitude),
        ),
        image: imageData,
        iconSize: 0.2,
        iconColor: user.isOnline
            ? Colors.green.toARGB32()
            : Colors.grey.toARGB32(),
        textField: user.name,
        textSize: 11.0,
        textColor: user.isOnline
            ? Colors.black.toARGB32()
            : Colors.grey.toARGB32(),
        textAnchor: mp.TextAnchor.BOTTOM,
        textOffset: [0, -1.5],
        isDraggable: false,
      );

      final annotation = await pointAnnotationManager?.create(options);
      if (annotation != null) {
        userMarkers[user.id] = annotation;
      }
    } catch (e) {
      print('Error creating marker for ${user.name}: $e');
    }
  }

  // Step 11: Update Existing Marker
  Future<void> _updateUserMarker(MapUser user) async {
    final annotation = userMarkers[user.id];
    if (annotation == null) return;

    try {
      final imageKey = user.isOnline ? 'online' : 'offline';
      final imageData = preloadedImages[imageKey];

      if (imageData == null) return;

      final updatedOptions = mp.PointAnnotationOptions(
        geometry: mp.Point(
          coordinates: mp.Position(user.longitude, user.latitude),
        ),
        image: imageData,
        iconSize: 0.2,
        iconColor: user.isOnline
            ? Colors.green.toARGB32()
            : Colors.grey.toARGB32(),
        textField: user.name,
        textSize: 11.0,
        textColor: user.isOnline
            ? Colors.black.toARGB32()
            : Colors.grey.toARGB32(),
        textAnchor: mp.TextAnchor.BOTTOM,
        textOffset: [0, -1.5],
        isDraggable: false,
      );

      await pointAnnotationManager?.update(annotation);
    } catch (e) {
      print('Error updating marker for ${user.name}: $e');
    }
  }

  // Step 12: Remove User Marker
  Future<void> _removeUserMarker(String userId) async {
    final annotation = userMarkers.remove(userId);
    if (annotation != null) {
      await pointAnnotationManager?.delete(annotation);
    }
  }

  // Step 13: Handle Marker Interactions
  void _handleMarkerTap(mp.PointAnnotation tappedAnnotation) {
    // Find which user was tapped
    final tappedUserId = userMarkers.entries
        .firstWhere(
          (entry) => entry.value == tappedAnnotation,
          orElse: () => MapEntry('', tappedAnnotation),
        )
        .key;

    if (tappedUserId.isNotEmpty) {
      final user = currentUsers.firstWhere((u) => u.id == tappedUserId);
      _showUserInfo(user);
    }
  }

  void _showUserInfo(MapUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${user.isOnline ? "Online" : "Offline"}'),
            Text(
              'Location: ${user.latitude.toStringAsFixed(4)}, ${user.longitude.toStringAsFixed(4)}',
            ),
            Text('Last seen: ${user.lastSeen.toString().substring(0, 19)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _moveToUser(user);
            },
            child: Text('Go to Location'),
          ),
        ],
      ),
    );
  }

  // Step 14: Camera Controls
  void _moveToUser(MapUser user) {
    mapboxMapController?.setCamera(
      mp.CameraOptions(
        center: mp.Point(
          coordinates: mp.Position(user.longitude, user.latitude),
        ),
        zoom: 16.0,
      ),
    );
  }

  void _fitAllUsers() {
    if (currentUsers.isEmpty) return;

    final lats = currentUsers.map((u) => u.latitude).toList();
    final lngs = currentUsers.map((u) => u.longitude).toList();

    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    mapboxMapController?.setCamera(
      mp.CameraOptions(
        center: mp.Point(
          coordinates: mp.Position(
            (minLng + maxLng) / 2,
            (minLat + maxLat) / 2,
          ),
        ),
        zoom: _calculateZoom(maxLat - minLat, maxLng - minLng),
      ),
    );
  }

  double _calculateZoom(double latDiff, double lngDiff) {
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    if (maxDiff < 0.01) return 14.0;
    if (maxDiff < 0.05) return 11.0;
    if (maxDiff < 0.1) return 9.0;
    return 7.0;
  }

  // Step 15: Control Buttons
  Widget _buildControlButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "fit_all",
          onPressed: _fitAllUsers,
          mini: true,
          child: Icon(Icons.center_focus_strong),
        ),
        SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "refresh",
          onPressed: () => _updateAllUserMarkers(),
          mini: true,
          child: Icon(Icons.refresh),
        ),
      ],
    );
  }

  // Simulate user updates (replace with real data source)
  void _simulateUserUpdates() {
    final users = [
      MapUser(
        id: '1',
        name: 'Alice',
        latitude: 37.7749 + (DateTime.now().millisecond % 100) * 0.0001,
        longitude: -122.4194 + (DateTime.now().millisecond % 100) * 0.0001,
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
      MapUser(
        id: '2',
        name: 'Bob',
        latitude: 37.7849 + (DateTime.now().second % 10) * 0.0001,
        longitude: -122.4094 + (DateTime.now().second % 10) * 0.0001,
        isOnline: DateTime.now().second % 20 < 15, // Online/offline simulation
        lastSeen: DateTime.now().subtract(
          Duration(minutes: DateTime.now().second % 20),
        ),
      ),
    ];

    _handleUserUpdates(users);
  }
}
