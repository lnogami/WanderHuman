import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:wanderhuman_app/helper/firebase_services.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/bottom_modal_sheet_for_patient.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/point_annotation_options.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/show_alert_dialog.dart';

class MapBody extends StatefulWidget {
  const MapBody({super.key});

  @override
  State<MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  // controller for the map
  mp.MapboxMap? mapboxMapController;

  mp.PointAnnotationManager? pointAnnotationManager;

  // to listen to the user's location changes
  StreamSubscription? userPositionStream;

  // Keep track of existing annotations by Firestore document ID
  Map<String, mp.PointAnnotation> userAnnotations = {};

  // temporary
  gl.Position? myPosition;

  @override
  void initState() {
    super.initState();
    setupMapboxAccessToken();
    checkAndRequestLocationPermission();
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

    pointAnnotationManager = await mapboxMapController?.annotations
        .createPointAnnotationManager();

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

    // Start listening to Firebase users
    listenToPatients();
  }

  // Add this to your state variables
  Map<String, Map<String, dynamic>> annotationData = {};

  // Listen to Firestore collection "users" in real-time
  void listenToPatients() async {
    // History is just a placeholder,    "RealTime" is the collection here.
    FirebaseFirestore.instance.collection("History").snapshots().listen((
      snapshot,
    ) async {
      try {
        // to get user name, I must first retrieve all the records in PersonalInfo
        List<PersonalInfo> personsList =
            await MyFirebaseServices.getAllPersonalInfoRecords();

        showMyAnimatedSnackBar(
          context: context,
          dataToDisplay: personsList.length.toString(),
        );
        int n = 0; // (deletable) for debugging purposes only

        for (var doc in snapshot.docs) {
          var data = doc.data();
          n++;
          // Extract coordinates   // naka list man gud ni maong ingani [""][0]   naka List ni sya pag save sa firestore kay Position object man gud ang gisend, naconvert sya into array pag abot sa firestore
          double lng = data["currentLocation"][0] ?? "NULL lng";
          double lat = data["currentLocation"][1] ?? "NULL lat";
          // to get user name
          String name = MyFirebaseServices.getSpecificUserName(
            personsList: personsList,
            userIDToLookFor: data["patientID"],
          );

          // to get personal info based on patient's ID
          PersonalInfo personalInfo =
              await MyFirebaseServices.getSpecificPersonalInfo(
                userID: data["patientID"],
              );

          // Store the data associated with this document
          annotationData[doc.id] = {
            'name': name,
            'patientID': data["patientID"],
            'number': n, //for debugging purposes only, might delete later on
            'lng': lng,
            'lat': lat,
            'currentlyIn': data["currentlyIn"],
            'isInSafeZone': data["isInSafeZone"],
            'timeStamp': data["timeStamp"],
            'deviceBatteryPercentage': data["deviceBatteryPercentage"],
            //
            'age': personalInfo.age,
            'sex': personalInfo.sex,
            'contactInfo': personalInfo.contactNumber,
            'address': personalInfo.address,
            'notableBehavior': personalInfo.notableBehavior,
          };

          // // (deletable) pang debug ra ni
          // if (name == "Coach Anzai") {
          //   showMyAnimatedSnackBar(
          //     context: context,
          //     dataToDisplay: "$n). $name: ${doc.data().toString()}",
          //   );
          // }

          // If the user already has an annotation, update its position
          if (userAnnotations.containsKey(doc.id)) {
            // remove old annotation
            pointAnnotationManager?.delete(userAnnotations[doc.id]!);
            // create new annotation at the updated location
            var newAnnotation = await pointAnnotationManager?.create(
              myPointAnnotationOptions(
                name: name,
                myPosition: mp.Position(lng, lat),
              ),
            );

            userAnnotations[doc.id] = newAnnotation!;
          } else {
            // create new annation
            var newAnnotation = await pointAnnotationManager?.create(
              myPointAnnotationOptions(
                name: name,
                myPosition: mp.Position(lng, lat),
              ),
            );

            userAnnotations[doc.id] = newAnnotation!;
          }

          // // setting tap events to the marker
          // pointAnnotationManager?.tapEvents(
          //   onTap: (mp.PointAnnotation tappedAnnotation) {
          //     // bottomModalSheet(context);
          //     print("NAMEEEEEEEEEEEEEEEEEEEEEEEE: $name");
          //     showMyBottomNavigationSheet(context: context, name: "$name: $n");
          //   },
          // );

          // set up tap events ONCE, outside the loop
          pointAnnotationManager?.tapEvents(
            onTap: (mp.PointAnnotation tappedAnnotation) {
              // find which document this annotation belongs to
              String? docId = userAnnotations.entries
                  .firstWhere(
                    (entry) => entry.value == tappedAnnotation,
                    orElse: () => MapEntry('', tappedAnnotation),
                  )
                  .key;

              if (docId.isNotEmpty && annotationData.containsKey(docId)) {
                var data = annotationData[docId]!;
                showMyBottomNavigationSheet(
                  context: context,
                  name: "${data['name']} : ${data['number']}",
                  sex: data['sex'] ?? "NO DATA ACQUIRED",
                  age: data['age'] ?? "NO DATA ACQUIRED",
                  contactInfo: data['contactInfo'] ?? "NO DATA ACQUIRED",
                  address: data['address'] ?? "NO DATA ACQUIRED",
                  notableBehavior:
                      data['notableBehavior'] ?? "NO DATA ACQUIRED",
                );
              }
            },
          );
        }
      } catch (e) {
        // showMyAnimatedSnackBar(context: context, dataToDisplay: e.toString());
        print("ERROR ON LISTENTOPATIENTS METHOD: ${e.toString()}");
      }
    });
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
      distanceFilter: 100,
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
                zoom: 15.0,
                center: mp.Point(
                  coordinates: mp.Position(
                    position.longitude,
                    position.latitude,
                  ),
                ),
              ),
            );

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

            // // this was move to listenToPatients method
            // // setting tap events to the marker
            // pointAnnotationManager?.tapEvents(
            //   onTap: (mp.PointAnnotation tappedAnnotation) {
            //     // bottomModalSheet(context);

            //     showMyBottomNavigationSheet(
            //       context: context,
            //       name: "Hori Zontal",
            //     );
            //   },
            // );
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
