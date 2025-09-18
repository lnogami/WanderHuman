import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/point_annotation_options.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/bottom_modal_sheet.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/show_alert_dialog.dart';

class PatientSimulator extends StatefulWidget {
  const PatientSimulator({super.key});

  @override
  State<PatientSimulator> createState() => _PatientSimulatorState();
}

class _PatientSimulatorState extends State<PatientSimulator> {
  // controller for the map
  mp.MapboxMap? mapboxMapController;

  // to listen to the user's location changes
  StreamSubscription? userPositionStream;

  // temporary
  gl.Position? myPosition;

  @override
  void initState() {
    super.initState();
    setupMapboxAccessToken();
    checkAndRequestLocationPermission();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // cancels the subscriptionStream to avoid memory leaks
    userPositionStream?.cancel();
    super.dispose();
  }

  Future<void> setupMapboxAccessToken() async {
    mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  }

  @override
  Widget build(BuildContext context) {
    return mp.MapWidget(
      onMapCreated: _onMapCreated,
      // this is the style of the map
      styleUri: mp.MapboxStyles.SATELLITE_STREETS,
    );
  }

  void _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      mapboxMapController = controller;
    });
    //temporary ra ni (deletable)
    // controller.annotations.createPointAnnotationManager();

    // logic for displaying user position/location on the map
    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    // scaleBar indicator, indicator of how much the map is zoomed in/out
    mapboxMapController!.scaleBar.updateSettings(
      mp.ScaleBarSettings(
        enabled: true,
        position: mp.OrnamentPosition.BOTTOM_LEFT,
        primaryColor: Colors.blue.toARGB32(),
        showTextBorder: true,
        textColor: Colors.blue.toARGB32(),
        borderWidth: 1,
        textBorderWidth: 0.2,
        marginBottom: 8,
        marginLeft: 8,
      ),
    );

    // the mapbox logo can be moved, but cannot be hidden as per MapBox's Terms and Policy
    mapboxMapController!.logo.updateSettings(
      mp.LogoSettings(
        position: mp.OrnamentPosition.BOTTOM_RIGHT,
        marginRight: 25,
      ),
    );

    // the stroked i icon next to MapBox icon
    mapboxMapController!.attribution.updateSettings(
      mp.AttributionSettings(
        iconColor: const Color.fromARGB(100, 33, 149, 243).toARGB32(),
        position: mp.OrnamentPosition.BOTTOM_RIGHT,
      ),
    );

    // the compass icon in the map that only appears if the map is tilted
    mapboxMapController!.compass.updateSettings(
      mp.CompassSettings(marginTop: 80, marginRight: 15, opacity: 0.70),
    );

    // I AM NOT ALLOWED TO HIDE THE MAPBOX LOGO BECAUSE IT'S IN SERVICE TERMS AND POLICES.

    bool isLocationServiceEnabled =
        await gl.Geolocator.isLocationServiceEnabled();
    // mounted refers to if the widget is still on the tree
    if (mounted) {
      // code to be added here to make this code appear again if the Location is still turned off.
      showMyDialogBox(context, isLocationServiceEnabled);
    }
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
          if (position != null && mapboxMapController != null) {
            // print(position);
            // temporary
            myPosition = position;
            mapboxMapController?.setCamera(
              mp.CameraOptions(
                zoom: 18.0,
                center: mp.Point(
                  coordinates: mp.Position(
                    position.longitude,
                    position.latitude,
                  ),
                ),
              ),
            );

            /* 
              logic for adding annotations (marker),
              diri sya ibutang para marender sya if naa nay narender nga
              map og user postion
            */
            final pointAnnotationManager = await mapboxMapController
                ?.annotations
                .createPointAnnotationManager();
            // load image as the marker
            final Uint8List imageData = await imageToIconLoader(
              // "assets/icons/isagi.jpg",
              "assets/icons/pin.png",
            );

            /* 
            NOTE: this was transferred to a separate file
            ///// final Uint8List imageData = await converter();
            // define markers
            // mp.PointAnnotationOptions
            // pointAnnotationOptions = mp.PointAnnotationOptions(
            //   image: imageData,
            //   ///// temporary (deletable)
            //   ///// iconImage: "marker",
            //   iconSize: 0.15,
            //   // icon color is still static because I used a png image as marker
            //   iconColor: Colors.blue.toARGB32(),
            //   // THIS IS A PATIENT NAME
            //   textField: "Hori Zontal",
            //   textSize: 12.5,
            //   textColor: Colors.blue.toARGB32(),
            //   textOcclusionOpacity: 1,
            //   isDraggable: true,
            //   textAnchor: mp.TextAnchor.BOTTOM,
            //   textOffset: [0, -1.2],
            //   geometry: mp.Point(
            //     coordinates: mp.Position(
            //       // THIS IS THE PATIENTS CURRENT COORDINATES
            //       // temporary coordinates
            //       myPosition!.longitude,
            //       myPosition!.latitude,
            //     ),
            //   ),
            // );
            */

            mp.PointAnnotationOptions pointAnnotationOptions =
                myPointAnnotationOptions(
                  imageData: imageData,
                  name: "Hori Zontal",
                  textSize: 12.5,
                  myPosition: mp.Position(
                    // THIS IS THE PATIENTS CURRENT COORDINATES
                    // temporary coordinates
                    myPosition!.longitude,
                    myPosition!.latitude,
                  ),
                );

            // add the marker to the map
            pointAnnotationManager?.create(pointAnnotationOptions);
            // pointAnnotationManager?.createMulti(List<mp.PointAnnotation>);

            // setting tap events to the marker
            pointAnnotationManager?.tapEvents(
              onTap: (mp.PointAnnotation tappedAnnotation) {
                bottomModalSheet(context);
              },
            );
          }
        });
  }

  //// // this is a helper function to convert the image to Uint8List
  //// Future< Uint8List> converter() {
  ////  var cs = CustomMapMarker(
  ////     imagePath: "assets/icons/pin.png",
  ////   ).loadHQMarkerImage();
  ////   return cs;
  //// }

  /*
    this will convert the image to Uint8List
    so that it can be used as an icon for the marker
  */
  Future<Uint8List> imageToIconLoader(String imagePath) async {
    var byteData = await rootBundle.load(imagePath);
    return byteData.buffer.asUint8List();
  }
}
