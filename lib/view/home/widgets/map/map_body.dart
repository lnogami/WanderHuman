import 'dart:async';
import 'dart:developer';
import 'package:battery_plus/battery_plus.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
// import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/model/realtime_location_model.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/info_dialogue.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/home/home.dart';
// import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/bottom_modal_sheet_for_patient.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/listen_to_patients.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/point_annotation_options.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';

class MapBody extends StatefulWidget {
  /// This will contain the data of the logged in user for efficient usage in every other components.
  final PersonalInfo loggedInUserData;
  const MapBody({super.key, required this.loggedInUserData});

  @override
  State<MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  // // For app user specific
  // // this will be used as a deviceID for app users, unlike the patient that have the specific device
  // String appUserID = FirebaseAuth.instance.currentUser!.uid;
  // late PersonalInfo personalInfo;
  // Future<void> getPersonalInfo() async {
  //   final tempPerson = await MyPersonalInfoRepository.getSpecificPersonalInfo(
  //     userID: appUserID,
  //   );

  //   setState(() {
  //     personalInfo = tempPerson;
  //   });
  // }

  // controller for the map
  mp.MapboxMap? mapboxMapController;
  // point annotation manager
  mp.PointAnnotationManager? pointAnnotationManager;
  // to listen to the user's location changes
  StreamSubscription? userPositionStream;
  // Keep track of existing annotations by Firestore document ID
  Map<String, mp.PointAnnotation> userAnnotations = {};
  // Add this to your state variables
  // The first Map is for ?, and the second Map is for ?
  Map<String, Map<String, dynamic>> annotationData = {};
  // temporary
  gl.Position? myPosition;

  // TODO: after pressing the refresh, the UI will not change if you logout (but it is already logged out, just the UI doesn't change)
  // this will check if the location is enabled or not, if not, a dialog box
  // will appear to refresh the screen.
  bool isLocationServiceEnabled = false;
  Future<void> checkLocationServiceStatus() async {
    isLocationServiceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    // mounted refers to if the widget is still on the tree
    if (mounted) {
      // code to be added here to make this code appear again if the Location is still turned off.
      // showMyDialogBox(context, isLocationServiceEnabled);
      if (!isLocationServiceEnabled) {
        myInfoDialogue(
          context: context,
          alertTitle: "Location is Off",
          alertContent: "\nPlease turn it on first.",
          onPressText: "Refresh",
          barrierColor: Color.fromARGB(72, 45, 60, 71),
          onPress: () {
            // this will simulate a refresh
            Navigator.pop(context);
            Navigator.pop(context);
            MyNavigator.goTo(context, HomePage());
          },
        );
      }
    }
  }

  /// this will initialize the mapbox API
  Future<void> setupMapboxAccessToken() async {
    mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  }

  @override
  void initState() {
    super.initState();
    // getPersonalInfo(); //(deletable)
    setupMapboxAccessToken();
    checkAndRequestLocationPermission();
    checkLocationServiceStatus();
    // updatePatient(); // for tranfering firestore dummy data to realtime database only (deletable)
  }

  @override
  void dispose() {
    // cancels the subscriptionStream to avoid memory leaks
    userPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return mp.MapWidget(
      onMapCreated: _onMapCreated,
      // this is the styles of the map
      // static realistic view
      styleUri: mp.MapboxStyles.SATELLITE_STREETS,
      //// dynamic 3D view
      // styleUri: mp.MapboxStyles.STANDARD,
      onStyleLoadedListener: (styleLoadedEventData) {
        _onStyleLoadedListener(context: context, event: styleLoadedEventData);
      },
    );
  }

  // (newly added), not yet fully tested,
  _onStyleLoadedListener({
    required BuildContext context,
    required mp.StyleLoadedEventData? event,
  }) async {
    // this works with MapboxStyles.STANDARD as it is dynamic (NOTE: this does not work with SATELLITE_STREETS)
    mapboxMapController!.style.setStyleImportConfigProperty(
      "basemap",
      "lightPreset",
      "night",
    );
    mapboxMapController!.style.setStyleImportConfigProperty(
      "basemap",
      "showLandmarkIcons",
      true,
    );
  }

  /// this is the entry point of mapbox's map
  void _onMapCreated(mp.MapboxMap controller) async {
    // setState is not really necessary here because this method is immediately called when this Widget is being built (its like in initState)
    setState(() {
      mapboxMapController = controller;
    });

    // using addPostFrameCallback ensures it doesn't conflict with the build cycle
    // it will wait until the current fram finishes rendering
    // though its not really neccessary here (just like the setState above)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // store the controller globally (State Management) to make it accessible anywhere
      context.read<MyMapboxRefProvider>().setMapboxMapController(controller);
    });

    // manages point annotations
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

    // I AM NOT ALLOWED TO HIDE THE MAPBOX LOGO BECAUSE IT'S IN SERVICE TERMS AND POLICES.

    // the stroked i icon next to MapBox icon
    mapboxMapController!.attribution.updateSettings(
      mp.AttributionSettings(
        iconColor: const Color.fromARGB(100, 33, 149, 243).toARGB32(),
        position: mp.OrnamentPosition.BOTTOM_RIGHT,
      ),
    );

    // the compass icon in the map that only appears if the map is tilted
    mapboxMapController!.compass.updateSettings(
      // mp.CompassSettings(marginTop: 80, marginRight: 15, opacity: 0.70),
      mp.CompassSettings(marginTop: 90, marginRight: 70, opacity: 0.60),
    );

    //// original code of the new method getLocationServiceStatus()
    // bool isLocationServiceEnabled =
    //     await gl.Geolocator.isLocationServiceEnabled();

    // // Start listening to Firebase users
    // listenToPatients();

    ListenToPatients.listenToPatients(
      annotationData: annotationData,
      userAnnotations: userAnnotations,
      pointAnnotationManager: pointAnnotationManager,
      // ignore: use_build_context_synchronously
      context: context,
    );
  }

  // /// Add this to your state variables
  // /// The first Map is for ?, and the second Map is for ?
  // Map<String, Map<String, dynamic>> annotationData = {};

  /// Listen to Firestore collection in real-time
  // void listenToPatients() async {
  //   // History is just a placeholder,    "RealTime" is the collection here.
  //   FirebaseFirestore.instance.collection("History").snapshots().listen((
  //     snapshot,
  //   ) async {
  //     try {
  //       // showMyAnimatedSnackBar(
  //       //   context: context,
  //       //   dataToDisplay: personsList.length.toString(),
  //       // );
  //
  //       int n = 0; // (deletable) for debugging purposes only
  //
  //       // // iterate every document in History collection
  //       // for (var doc in snapshot.docs) {
  //       //   var data = doc.data();
  //       //   n++;
  //
  //       //   // Extract coordinates   // naka list man gud ni maong ingani [""][0]   naka List ni sya pag save sa firestore kay Position object man gud ang gisend, naconvert sya into array pag abot sa firestore
  //       //   double lng = data["currentLocation"][0] ?? "NULL lng";
  //       //   double lat = data["currentLocation"][1] ?? "NULL lat";
  //
  //       //   // to get user name
  //       //   String name = MyPersonalInfoRepository.getSpecificUserName(
  //       //     personsList: personsList,
  //       //     userIDToLookFor: data["patientID"],
  //       //   );
  //
  //       //   // to get personal info based on patient's ID
  //       //   PersonalInfo personalInfo =
  //       //       await MyPersonalInfoRepository.getSpecificPersonalInfo(
  //       //         userID: data["patientID"],
  //       //       );
  //
  //       //   // Store the data associated with this document
  //       //   annotationData[doc.id] = {
  //       //     'name': name,
  //       //     'patientID': data["patientID"],
  //       //     'number': n, //for debugging purposes only, might delete later on
  //       //     'lng': lng,
  //       //     'lat': lat,
  //       //     'currentlyIn': data["currentlyIn"],
  //       //     'isInSafeZone': data["isInSafeZone"],
  //       //     'timeStamp': data["timeStamp"],
  //       //     'deviceBatteryPercentage': data["deviceBatteryPercentage"],
  //       //     //
  //       //     'age': personalInfo.age,
  //       //     'sex': personalInfo.sex,
  //       //     'contactInfo': personalInfo.contactNumber,
  //       //     'address': personalInfo.address,
  //       //     'notableBehavior': personalInfo.notableBehavior,
  //       //   };
  //
  //       // newer version of the code above this line
  //       // iterate every document in History collection
  //       for (var doc in snapshot.docs) {
  //         var data = doc.data();
  //         // I just converted the data into an object so that it is readable for me
  //         HistoryModel historyModel = HistoryModel.fromFirestore(data);
  //         n++;
  //
  //         // // Extract coordinates   // naka list man gud ni maong ingani [""][0]   naka List ni sya pag save sa firestore kay Position object man gud ang gisend, naconvert sya into array pag abot sa firestore
  //         // double lng = data["currentLocation"][0] ?? "NULL lng";
  //         // double lat = data["currentLocation"][1] ?? "NULL lat";
  //         // (to be used when the current data in the database is replaced with updated ones)
  //         double lng = double.parse(historyModel.currentLocationLng);
  //         double lat = double.parse(historyModel.currentLocationLat);
  //
  //         // to get personal info based on patient's ID
  //         PersonalInfo personalInfo =
  //             await MyPersonalInfoRepository.getSpecificPersonalInfo(
  //               userID: historyModel.patientID,
  //             );
  //         String name = personalInfo.name;
  //
  //         // Store the data associated with this document
  //         annotationData[doc.id] = {
  //           'name': name,
  //           'patientID': historyModel.patientID,
  //           'number': n, //for debugging purposes only, might delete later on
  //           'lng': lng,
  //           'lat': lat,
  //           'currentlyIn': historyModel.currentlyIn,
  //           'isInSafeZone': historyModel.isInSafeZone,
  //           'timeStamp': historyModel.timeStamp,
  //           'deviceBatteryPercentage': historyModel.deviceBatteryPercentage
  //               .toString(),
  //           //
  //           'age': personalInfo.age,
  //           'sex': personalInfo.sex,
  //           'contactInfo': personalInfo.contactNumber,
  //           'address': personalInfo.address,
  //           'notableBehavior': personalInfo.notableBehavior,
  //         };
  //
  //         // // (deletable) pang debug ra ni
  //         // if (name == "Coach Anzai") {
  //         //   showMyAnimatedSnackBar(
  //         //     context: context,
  //         //     dataToDisplay: "$n). $name: ${doc.data().toString()}",
  //         //   );
  //         // }
  //
  //         // // load image as the marker (temporary)
  //         // final Uint8List imageData = await imageToIconLoader(
  //         //   // "assets/icons/isagi.jpg",
  //         //   "assets/icons/pin.png",
  //         // );
  //         // load image as the marker (temporary)
  //         final Uint8List patientIcon =
  //             MyImageProcessor.decodeStringToUint8List(personalInfo.picture);
  //
  //         // If the user already has an annotation, update its position
  //         if (userAnnotations.containsKey(doc.id)) {
  //           // remove old annotation
  //           pointAnnotationManager?.delete(userAnnotations[doc.id]!);
  //           // create new annotation at the updated location
  //           var newAnnotation = await pointAnnotationManager?.create(
  //             await myPointAnnotationOptions(
  //               name: name,
  //               myPosition: mp.Position(lng, lat),
  //               imageData: patientIcon,
  //             ),
  //           );
  //           // then add a new annotation to the map
  //           userAnnotations[doc.id] = newAnnotation!;
  //         } else {
  //           // create new annation
  //           var newAnnotation = await pointAnnotationManager?.create(
  //             await myPointAnnotationOptions(
  //               name: name,
  //               myPosition: mp.Position(lng, lat),
  //               imageData: patientIcon,
  //             ),
  //           );
  //           // then add the new annotation to the map
  //           userAnnotations[doc.id] = newAnnotation!;
  //         }
  //
  //         // // setting tap events to the marker
  //         // pointAnnotationManager?.tapEvents(
  //         //   onTap: (mp.PointAnnotation tappedAnnotation) {
  //         //     // bottomModalSheet(context);
  //         //     print("NAMEEEEEEEEEEEEEEEEEEEEEEEE: $name");
  //         //     showMyBottomNavigationSheet(context: context, name: "$name: $n");
  //         //   },
  //         // );
  //
  //         // set up tap events ONCE, outside the loop
  //         pointAnnotationManager?.tapEvents(
  //           onTap: (mp.PointAnnotation tappedAnnotation) {
  //             // find which document this annotation belongs to
  //             String? docId = userAnnotations.entries
  //                 .firstWhere(
  //                   (entry) => entry.value == tappedAnnotation,
  //                   orElse: () => MapEntry('', tappedAnnotation),
  //                 )
  //                 .key;
  //
  //             if (docId.isNotEmpty && annotationData.containsKey(docId)) {
  //               var data = annotationData[docId]!;
  //               showMyBottomNavigationSheet(
  //                 context: context,
  //                 name: "${data['name']} : ${data['number']}",
  //                 sex: data['sex'] ?? "NO DATA ACQUIRED",
  //                 age: data['age'] ?? "NO DATA ACQUIRED",
  //                 contactInfo: data['contactInfo'] ?? "NO DATA ACQUIRED",
  //                 address: data['address'] ?? "NO DATA ACQUIRED",
  //                 notableBehavior:
  //                     data['notableBehavior'] ?? "NO DATA ACQUIRED",
  //               );
  //             }
  //           },
  //         );
  //       }
  //     } catch (e, stackTrace) {
  //       // showMyAnimatedSnackBar(context: context, dataToDisplay: e.toString());
  //       print("ERROR ON LISTENTOPATIENTS METHOD: ${e.toString()}");
  //       print("ERROR ONNNNNNNNNNNNNNNNNNNNNNNN: $stackTrace");
  //     }
  //   });
  // }

  //------------------------------------------------------------------------------

  /// This will ask for persmission to the user to allow the app to access location services.
  /// This method is for the `app users` (not for patients, since the device will provide their location data)
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
            // CameraOptios sets where the map is centered and how zoomed in it is.
            mapboxMapController?.setCamera(
              mp.CameraOptions(
                zoom: 15.0,
                // bearing: 50.0,
                // pitch: 50.0,
                center: mp.Point(
                  // TODO: this could be change to adapt to a new feature, where if the user clicks a patient icon, that patient icon becomes the center of the screen
                  coordinates: mp.Position(
                    position.longitude,
                    position.latitude,
                  ),
                ),
              ),

              // (deletable) this is just for testing purposes only
              // mp.CameraOptions(
              //   center: mp.Point(
              //     coordinates: mp.Position(-74.0445, 40.6892),
              //   ), // Statue of Liberty
              //   zoom: 16.0,
              //   pitch:
              //       45.0, // Tilting the camera makes 3D landmarks much easier to see
              // ),
            );

            updateUserLocation(position);

            /* NOTE: this was transferred to a separate file
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

            // temprary commented out sa ni
            // load image as the marker
            // final Uint8List imageData = await imageToIconLoader(
            //   // "assets/icons/isagi.jpg",
            //   personalInfo.picture,
            // );
            mp.PointAnnotationOptions pointAnnotationOptions =
                await myPointAnnotationOptions(
                  imageData: MyImageProcessor.decodeStringToUint8List(
                    widget.loggedInUserData.picture,
                  ),
                  name: widget.loggedInUserData.name,
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

  // this will update the location data of only the staff, the patients' location data will be hanlded by the device
  Future<void> updateUserLocation(gl.Position position) async {
    try {
      return MyRealtimeLocationReposity.updateLocation(
        deviceID: widget.loggedInUserData.userID,
        realtimeData: MyRealtimeLocationModel(
          deviceID: widget.loggedInUserData.userID,
          patientID: widget.loggedInUserData.userID,
          isInSafeZone: true,
          currentlyIn: "NOT APPLICABLE",
          currentLocationLng: position.longitude.toString(),
          currentLocationLat: position.latitude.toString(),
          timeStamp: MyDateFormatter.formatDate(
            dateTimeInString: DateTime.now(),
            formatOptions: 8,
          ),
          deviceBatteryPercentage: await Battery().batteryLevel,
          bPM: "NOT APPLICABLE",
          requestBPM: false,
        ),
      );
    } catch (e, stackTrace) {
      log("ERROR WHILE UPDATING USER LOCATION in MapBody: $e. AT $stackTrace");
    }
  }

  // // for transfering the firebase data to realtime database only (deletable)
  // Future<void> updatePatient() async {
  //   try {
  //     List<PersonalInfo> persons =
  //         await MyPersonalInfoRepository.getAllPersonalInfoRecords(
  //           fieldName: "userType",
  //           valueToLookFor: "Patient",
  //         );
  //     for (var person in persons) {
  //       HistoryModel historyModel =
  //           await MyHistoryReposity.getSpecificPatientHistory(person.userID);
  //       MyRealtimeLocationReposity.updateLocation(
  //         deviceID: person.userID,
  //         realtimeData: MyRealtimeLocationModel(
  //           deviceID: person.userID,
  //           patientID: person.userID,
  //           isInSafeZone: true,
  //           currentlyIn: "NOT APPLICABLE",
  //           currentLocationLng: historyModel.currentLocationLng,
  //           currentLocationLat: historyModel.currentLocationLat,
  //           timeStamp: MyDateFormatter.formatDate(
  //             dateTimeInString: DateTime.now(),
  //             formatOptions: 8,
  //           ),
  //           deviceBatteryPercentage: await Battery().batteryLevel,
  //           bPM: "NOT APPLICABLE",
  //           requestBPM: false,
  //         ),
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     log("ERROR WHILE UPDATING USER LOCATION in MapBody: $e. AT $stackTrace");
  //   }
  // }

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
