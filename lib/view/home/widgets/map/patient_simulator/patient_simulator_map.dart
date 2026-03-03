import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/show_alert_dialog.dart';
import 'package:wanderhuman_app/view/home/widgets/map/patient_simulator/location_saver.dart';

class PatientSimulator extends StatefulWidget {
  const PatientSimulator({super.key});

  @override
  State<PatientSimulator> createState() => _PatientSimulatorState();
}

class _PatientSimulatorState extends State<PatientSimulator> {
  // controller for the map
  // mp.MapboxMap? mbMapController;

  // mp.PointAnnotationManager? pointAnnotationManager;

  // to listen to the user's location changes
  StreamSubscription? userPositionStream;

  // List<StreamSubscription> patientStream = [];

  // temporary
  gl.Position? myPosition;

  // for triggering the save
  DateTime? lastSaveTime;

  // // Store reference to current annotation
  // mp.PointAnnotation? currentAnnotation;

  @override
  void initState() {
    super.initState();
    setupMapboxAccessToken();
    checkAndRequestLocationPermission();
    WakelockPlus.enable();
    _getDeviceBatteryPercentage();
  }

  @override
  void dispose() {
    // cancels the subscriptionStream to avoid memory leaks
    userPositionStream?.cancel();
    super.dispose();
  }

  // NOTE: this is not final yet, may or may not be implemented.
  final Battery battery = Battery();
  int deviceBatteryPercentage = 0;
  Future<void> _getDeviceBatteryPercentage() async {
    final level = await battery.batteryLevel;
    setState(() {
      deviceBatteryPercentage = level;
    });
  }

  Future<void> setupMapboxAccessToken() async {
    mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  }

  @override
  Widget build(BuildContext context) {
    // return mp.MapWidget(
    //   onMapCreated: _onMapCreated,
    //   // this is the style of the map
    //   styleUri: mp.MapboxStyles.SATELLITE_STREETS,
    // );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: Colors.blue),
          SizedBox(height: 10),
          MyTextFormatter.p(text: "Lng: ${myPosition?.longitude}"),
          MyTextFormatter.p(text: "Lat: ${myPosition?.latitude}"),
        ],
      ),
    );
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

    bool isLocationServiceEnabled =
        await gl.Geolocator.isLocationServiceEnabled();
    // mounted refers to if the widget is still on the tree
    if (mounted) {
      // code to be added here to make this code appear again if the Location is still turned off.
      showMyDialogBox(context, isLocationServiceEnabled);
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
      showMyAnimatedSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        isAutoDismiss: false,
        dataToDisplay:
            "NOTICE: The device's Location permission is permanently denied. Please turn it on in your phone's Settings",
      );
      // Permissions are permanently denied
      return Future.error(
        "Location permissions are permanently denied, we cannot request permissions.",
      );
    }
    // Permissions are granted, proceed with location functionality
    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 10,
    );

    /*
      this is stream, meaning it is listening to the user's location changes

      .cacel() stops the process then rerun again with an updated 
      gl.Geolocator.getPositionStream(...)
    */
    userPositionStream?.cancel();
    userPositionStream =
        gl.Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((gl.Position? position) async {
          if (position != null) {
            setState(() {
              myPosition = position;
            });

            bool isSaved = await savePatientLocation(
              patientID: "${FirebaseAuth.instance.currentUser!.uid}_as_PATIENT",
              lastSaved:
                  lastSaveTime ??
                  DateTime.now().subtract(Duration(seconds: 30)),
              currentPositon: mp.Position(
                myPosition!.longitude,
                myPosition!.latitude,
              ),
              deviceBatteryPercentage: deviceBatteryPercentage,
              context: context,
            );
            if (isSaved) {
              lastSaveTime = DateTime.now();
            }
          }
        });
  }

  /*
    this will convert the image to Uint8List
    so that it can be used as an icon for the marker
  */
  Future<Uint8List> imageToIconLoader(String imagePath) async {
    var byteData = await rootBundle.load(imagePath);
    return byteData.buffer.asUint8List();
  }
}
