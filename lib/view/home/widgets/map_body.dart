import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

class MapBody extends StatefulWidget {
  const MapBody({super.key});

  @override
  State<MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  // controller for the map
  mp.MapboxMap? mapboxMapController;

  StreamSubscription? userPositionStream;

  // temporary
  gl.Position? myPosition;

  @override
  void initState() {
    super.initState();
    setup();
    checkAndRequestLocationPermission();
  }

  @override
  void dispose() {
    // cancels the subscriptionStream to avoid memory leaks
    userPositionStream?.cancel();
    super.dispose();
  }

  Future<void> setup() async {
    mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  }

  @override
  Widget build(BuildContext context) {
    return mp.MapWidget(
      onMapCreated: _onMapCreated,
      // this is the style of the map
      styleUri: mp.MapboxStyles.LIGHT,
    );
  }

  void _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      mapboxMapController = controller;
    });

    // logic for displaying user position/location on the map
    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    // logic for adding annotations (marker)
    final pointAnnotationManager = await mapboxMapController?.annotations
        .createPointAnnotationManager();
    final Uint8List imageData = await loadHQMarkerImage();
    mp.PointAnnotationOptions pointAnnotationOptions =
        mp.PointAnnotationOptions(
          image: imageData,
          iconSize: 1.0,
          geometry: mp.Point(
            coordinates: mp.Position(
              // temporary coordinates
              myPosition!.longitude,
              myPosition!.latitude,
            ),
          ),
        );
    pointAnnotationManager?.create(pointAnnotationOptions);
  }

  //------------------------------------------------------------------------------
  /*
    This will ask for persmission to the user to allow the app to access location
    services.
  */
  Future<void> checkAndRequestLocationPermission() async {
    bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return Future.error("Location services are disabled.");
      // return;
    }

    gl.LocationPermission permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      // this will popup a message dialog requesting for permission
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        // Permissions are denied
        return Future.error("Location services are denied.");
        // return;
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return Future.error(
        "Location permissions are permanently denied, we cannot request permissions.",
      );
      // return;
    }
    // Permissions are granted, proceed with location functionality
    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userPositionStream?.cancel();
    userPositionStream =
        gl.Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((gl.Position? position) {
          if (position != null && mapboxMapController != null) {
            // print(position);
            // temporary
            myPosition = position;
            mapboxMapController?.setCamera(
              mp.CameraOptions(
                zoom: 15.0,
                center: mp.Point(
                  coordinates: mp.Position(
                    position.longitude,
                    position.latitude,
                  ),
                ),
              ),
            );
          }
        });
  }

  // this will convert the image to Uint8List
  // so that it can be used as an icon for the marker
  Future<Uint8List> loadHQMarkerImage() async {
    var byteData = await rootBundle.load("assets/icons/pin.png");
    print('TTTTTTTTTTTTTTTTTTLoaded image bytes: ${byteData.lengthInBytes}');
    return byteData.buffer.asUint8List();
  }
}
