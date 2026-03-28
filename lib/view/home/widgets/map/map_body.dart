import 'dart:async';
import 'dart:developer';
import 'package:battery_plus/battery_plus.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/audios/audio_player.dart';
import 'package:wanderhuman_app/helper/geofence_repository.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/main.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';
// import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/model/realtime_location_model.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view-model/home_active_persons_provider.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view-model/home_miscellaneous_provider.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/info_dialogue.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/map_geofence_drawer.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/geo_logics/distance_validator.dart';
// import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/bottom_modal_sheet_for_patient.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/listen_to_patients.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/map_camera_animations.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/map_interactions.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/point_annotation_options.dart';

class MapBody extends StatefulWidget {
  /// This will contain the data of the logged in user for efficient usage in every other components.
  final PersonalInfo loggedInUserData;
  const MapBody({super.key, required this.loggedInUserData});

  @override
  State<MapBody> createState() => _MapBodyState();
}

// RouteAware is an observer for route pages
class _MapBodyState extends State<MapBody> with RouteAware {
  /// Controller for the map
  mp.MapboxMap? mapboxMapController;

  /// The generic point annotation manager for patients and caregivers that are visible in the map
  mp.PointAnnotationManager? pointAnnotationManager;
  // This is not really needed but I use this for identification which is for moving a layer above or below other manager id.
  final String pointAnnotationManagerID = "persons_annotations";

  /// This will hold all the active geofences (safezones)
  List<MyGeofenceModel> activeGeofences = [];

  /// To listen to the mobile app user's location changes
  StreamSubscription? currentLoggedInUserPositionStream;
  // Tracks the filtered blue dot (or avatar) on the map
  mp.PointAnnotation? myFilteredPuck;

  /// Keep track of existing annotations by Firestore document ID
  Map<String, mp.PointAnnotation> userAnnotations = {};

  /// The first Map is for ID, and the second Map is for the data of each individual
  Map<String, Map<String, dynamic>> annotationData = {};
  // // temporary
  // gl.Position? myPosition;

  // Geofence related stuff
  mp.PolygonAnnotationManager? polygonAnnotationManager;
  final String polygonAnnotationManagerID = "active_geofences_annotations";
  // List<List<mp.Position>> listOfPositions = [];
  int numberOfActiveGeofences = 0; // for debugging purposes only (deletable)

  // Provider
  late MyHomeSettingsProvider myHomeSettingsProvider;
  late HomeAppBarProvider myHomeAppBarProvider;
  late MyHomeActivePersonsProvider myHomeActivePersonsProvider;

  // This two Managers are for temporary scenarios like when creating a safe zone (geofence)
  mp.PolygonAnnotationManager? markedPolygonAnnotationManager;
  mp.PointAnnotationManager? markedPointAnnotationManager;

  // This will check if the location is enabled or not, if not, a dialog box will appear to refresh the screen.
  bool isLocationServiceEnabled = false;

  // Audio effects
  final MyAudioPlayer _myAudioPlayer = MyAudioPlayer();
  bool isIntroAudioPlayingForTheFirstTime = true;

  late DateTime lastLoggedInUserUpdateToDatabase;
  mp.Position? lastSavedDatabasePosition;

  // Position Validator, this will validate if a coordinates given by GPS is valid or just a noise
  final MyDistanceValidator myDistanceValidator = MyDistanceValidator();

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
            // This will soft restart the App
            Phoenix.rebirth(context);
          },
        );
      }
    }
  }

  /// setup all the active geofences (safezones)
  Future<void> setupGeofences() async {
    try {
      activeGeofences = await MyGeofenceRepository.getActiveGeofences();

      // return if there are no active geofences
      if (activeGeofences.isEmpty) return;

      polygonAnnotationManager = await mapboxMapController?.annotations
          .createPolygonAnnotationManager(id: polygonAnnotationManagerID);

      // This will make the point annotation for persons appear above the polygon annotation for geofences
      mapboxMapController!.style.moveStyleLayer(
        pointAnnotationManagerID,
        mp.LayerPosition(above: polygonAnnotationManagerID),
      );

      numberOfActiveGeofences = activeGeofences.length;

      for (final geofence in activeGeofences) {
        MyMapGeofenceDrawer.drawPolygon(
          polygonManager: polygonAnnotationManager!,
          positions: [
            geofence.geofenceCoordinates
                .map((pos) => mp.Position(pos.lng, pos.lat))
                .toList(),
          ],
          // The forth (3rd index) mapView is a dark theme
          polygonColor: (myHomeSettingsProvider.mapView == 3)
              ? Colors.orange.toARGB32()
              : null,
        );
      }

      log("The number of active geofences is: $numberOfActiveGeofences");
    } catch (e, stackTrace) {
      log("ERROR WHILE SETTING UP GEOFENCES: $e. AT $stackTrace");
    }
  }

  /// this will initialize the mapbox API
  Future<void> setupMapboxAccessToken() async {
    mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  }

  void updateMapStyle(int styleIndex) {
    final newUri = getMapViewStyle(styleIndex);
    mapboxMapController?.style.setStyleURI(newUri);
  }

  @override
  void initState() {
    super.initState();
    setupMapboxAccessToken();
    checkAndRequestLocationPermission();
    checkLocationServiceStatus();
    lastLoggedInUserUpdateToDatabase = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // setup all the active geofences (safezones)
      setupGeofences();
      // Add the current logged in user in the active perons list
      myHomeActivePersonsProvider.addActivePerson(
        context.read<HomeAppBarProvider>().loggedInUserData,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // --- VISIBILITY EVENTS ---
    // Subscribe to the RouteObserver again if the widget is rebuilt, for routing purposes, like if the map is covered by another page or visible again.
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // cancels the subscriptionStream to avoid memory leaks
    currentLoggedInUserPositionStream?.cancel();
    // 3. Unsubscribe and Stop Listening when widget is destroyed
    routeObserver.unsubscribe(this);
    // this method will stop all the StreamSubscriptions to save resources
    ListenToPatients.stopListening();
    _myAudioPlayer.dispose();

    // Remove the current logged in user in the active perons list
    Future.microtask(() {
      myHomeActivePersonsProvider.removeActivePerson(
        myHomeAppBarProvider.loggedInUserData.userID,
      );
    });

    super.dispose();
  }

  // --- VISIBILITY EVENTS ---
  @override
  void didPushNext() {
    // 4. Called when a new screen covers this map
    log("Notice: Map is covered by another page. Pausing streams...");
    ListenToPatients.stopListening();
  }

  @override
  void didPopNext() {
    // 5. Called when the top screen is popped and map is visible again
    log("Notice: Map is visible again. Resuming streams...");
    // You need to call your start method here again!
    ListenToPatients.listenToPatients(
      annotationData: annotationData,
      userAnnotations: userAnnotations,
      pointAnnotationManager: pointAnnotationManager,
      context: context,
      // activeGeofences: activeGeofences,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This will act as a listener for polygonManager that if the listOfMarkedPositions is empty, clear the drawn polygon (geofence)
    List<List<mp.Position>> listOfMarkedPositions = context
        .watch<MyHomeGeofenceConfigurationProvider>()
        .listOfMarkedPositions;
    if (listOfMarkedPositions[0].isEmpty &&
        markedPolygonAnnotationManager != null &&
        markedPointAnnotationManager != null) {
      markedPolygonAnnotationManager!.deleteAll();
      markedPointAnnotationManager!.deleteAll();
    }

    // This will listen to changes
    // cameraZoomLevel = context.watch<MyHomeSettingsProvider>().zoomLevel;
    myHomeSettingsProvider = context.watch<MyHomeSettingsProvider>();
    myHomeAppBarProvider = context.watch<HomeAppBarProvider>();
    myHomeActivePersonsProvider = context.read<MyHomeActivePersonsProvider>();

    return mp.MapWidget(
      onMapCreated: _onMapCreated,
      // This will set the initial place of what the map displays while still processing the location data it needs.
      cameraOptions: mp.CameraOptions(zoom: 0),
      // this is the styles of the map
      // static realistic view
      styleUri: getMapViewStyle(myHomeSettingsProvider.mapView),
      onStyleDataLoadedListener: (styleDataLoadedEventData) {},
      //// styleUri: mp.MapboxStyles.STANDARD_SATELLITE,
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
    if (myHomeSettingsProvider.mapView == 3) {
      mapboxMapController?.style.setStyleImportConfigProperty(
        "basemap",
        "lightPreset",
        "night",
      );
      mapboxMapController?.style.setStyleImportConfigProperty(
        "basemap",
        "showLandmarkIcons",
        true,
      );
    }
  }

  /// this is the entry point of mapbox's map
  void _onMapCreated(mp.MapboxMap controller) async {
    // setState is not really necessary here because this method is immediately called when this Widget is being built (its like in initState)
    setState(() {
      mapboxMapController = controller;
    });

    // manages the polygon annotations, this if for geofence related stuff
    markedPolygonAnnotationManager = await mapboxMapController!.annotations
        .createPolygonAnnotationManager();
    markedPointAnnotationManager = await mapboxMapController!.annotations
        .createPointAnnotationManager();

    // using addPostFrameCallback ensures it doesn't conflict with the build cycle
    // it will wait until the current fram finishes rendering
    // though its not really neccessary here (just like the setState above)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyMapboxRefProvider>().setMapboxMapController(controller);
      // this is for setting up the geofence configuration, this will initialize the PolygonAnnotationManager and PointAnnotationManager that will be used for creating geofences and marking the tapped points in the map when creating geofences
      context
          .read<MyHomeGeofenceConfigurationProvider>()
          .initPolygonAndPointManagers(
            polygonManager: markedPolygonAnnotationManager!,
            pointManager: markedPointAnnotationManager!,
          );

      // other mapbox's requirements for its rules and policies
      initOtherMapRequirements(mapboxMapController!);
    });

    // manages point annotations
    pointAnnotationManager = await mapboxMapController?.annotations
        .createPointAnnotationManager(id: pointAnnotationManagerID);

    // This part of the code is for listening to realtime database data
    ListenToPatients.listenToPatients(
      annotationData: annotationData,
      userAnnotations: userAnnotations,
      pointAnnotationManager: pointAnnotationManager,
      // ignore: use_build_context_synchronously
      context: context,
      // activeGeofences: activeGeofences,
    );

    // This part of the code is for creating geofences
    if (context.mounted) {
      MyMapInteractions.tapInteraction(
        mapboxMapController: mapboxMapController!,
        polygonManager: markedPolygonAnnotationManager,
        pointAnnotationManager: markedPointAnnotationManager,
        // ignore: use_build_context_synchronously
        context: context,
      );

      // mapboxMapController!.style.setStyleURI(
      //   getMapViewStyle(myHomeSettingsProvider.mapView),
      // );
      updateMapStyle(myHomeSettingsProvider.mapView);
    }

    if (isLocationServiceEnabled) {
      _myAudioPlayer.playLocalAudio("audios/introduction_audio.mp3");
    }

    // MyMapCameraAnimations.myMapFlyTo(
    //   position: mp.Position(125.79742622088162, 7.4283929355574685),
    //   mapboxController: mapboxMapController!,
    //   zoomLevel: 15.0,
    //   animationDurationInMilliseconds: 6250,
    // );
  }

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
      // accuracy: gl.LocationAccuracy.best,
      accuracy: gl.LocationAccuracy.high,
      // distanceFilter: 100,
      distanceFilter: (myHomeSettingsProvider.alwaysFollowYourAvatar) ? 0 : 20,
    );

    positionStreamOfTheCurrentLoggedInUser(locationSettings);
  }

  // the stream where the position of the user is updated
  void positionStreamOfTheCurrentLoggedInUser(
    gl.LocationSettings locationSettings,
  ) {
    currentLoggedInUserPositionStream?.cancel();
    currentLoggedInUserPositionStream =
        gl.Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((gl.Position? position) async {
          if (position != null && mapboxMapController != null) {
            mp.Position? validatedPosition = myDistanceValidator
                .processNewLocation(position.longitude, position.latitude);
            log(
              "VVVVVVVVVVVVVVVVVVVVVVALIDATED POSITION: lng:${validatedPosition?.lng}, lat:${validatedPosition?.lat}",
            );
            if (validatedPosition == null) return;

            // State management purposes
            myHomeActivePersonsProvider.updatePersonCurrentPosition(
              myHomeAppBarProvider.loggedInUserData.userID,
              mp.Position(validatedPosition.lng, validatedPosition.lat),
            );

            // CameraOptios sets where the map is centered and how zoomed in it is.
            if (isIntroAudioPlayingForTheFirstTime ||
                myHomeSettingsProvider.alwaysFollowYourAvatar) {
              await MyMapCameraAnimations.myMapFlyTo(
                mapboxController: mapboxMapController!,
                position: validatedPosition,
                animationDurationInMilliseconds:
                    (isIntroAudioPlayingForTheFirstTime)
                    ? ((myHomeSettingsProvider.zoomLevel.toInt()) + 6250)
                    : 700,
                zoomLevel: myHomeSettingsProvider.zoomLevel,
              );
              Future.delayed(Duration(milliseconds: 6260), () {
                if (context.mounted) {
                  setState(() => isIntroAudioPlayingForTheFirstTime = false);
                  // ignore: use_build_context_synchronously
                  context
                      .read<MyHomeMiscellaneousProvider>()
                      .setIsIntroAnimationDone(true);
                }
              });
            }

            // updateLoggedInUserLocationToTheDatabase(position);
            updateLoggedInUserLocationToTheDatabase(
              validatedPosition.lng.toDouble(),
              validatedPosition.lat.toDouble(),
            );

            // Feature to change users avatar in real time
            if (!myHomeSettingsProvider.useDefaultAvatar &&
                pointAnnotationManager != null) {
              // 1. If the puck doesn't exist yet, create it
              if (myFilteredPuck == null) {
                mp.PointAnnotationOptions puckOptions =
                    await myPointAnnotationOptions(
                      imageData: MyImageProcessor.decodeStringToUint8List(
                        widget.loggedInUserData.picture,
                      ),
                      // name: widget.loggedInUserData.name,
                      name: "Me",
                      textSize: 12.5,
                      myPosition: mp.Position(
                        validatedPosition.lng,
                        validatedPosition.lat,
                      ),
                      isCurrentlySafe: true,
                      iconRotate: myDistanceValidator.currentHeading,
                      isIconRotateEnabled: true,
                      isAPatient: false,
                    );

                myFilteredPuck = await pointAnnotationManager!.create(
                  puckOptions,
                );
              }
              // 2. If it already exists, just smoothly move it to the new clean coordinate
              else {
                myFilteredPuck!.geometry = mp.Point(
                  coordinates: mp.Position(
                    validatedPosition.lng,
                    validatedPosition.lat,
                  ),
                );
                // myFilteredPuck!.iconRotate = myDistanceValidator.currentHeading;
                myFilteredPuck!.iconRotate = 57.0;

                pointAnnotationManager!.update(myFilteredPuck!);
              }
            }
          }
        });
  }

  // Now accepts the clean doubles directly
  Future<void> updateLoggedInUserLocationToTheDatabase(
    double filteredLng,
    double filteredLat,
  ) async {
    try {
      DateTime now = DateTime.now();

      // GATE 1: THE TIME GATE                           // originally 30 seconds
      if (now.difference(lastLoggedInUserUpdateToDatabase).inSeconds < 15) {
        log(
          "LOGGED IN USER's LOCATION DATA WAS SKIPPED: (TOO EARLY TO SAVE LOCATION DATA!)",
        );
        return;
      }

      // GATE 2: THE DISTANCE GATE
      if (lastSavedDatabasePosition != null) {
        double distanceMoved = MyDistanceValidator.calculateDistance(
          lastSavedDatabasePosition!.lng.toDouble(),
          lastSavedDatabasePosition!.lat.toDouble(),
          filteredLng,
          filteredLat,
        );

        // If they moved less than 5 meters in 30 seconds, they are basically stationary.
        if (distanceMoved < 5.0) {
          // Reset the timer so we check again in 30 seconds, but DO NOT write to Firebase.
          lastLoggedInUserUpdateToDatabase = now;
          log(
            "DB WRITE SKIPPED: User is stationary. (Moved only ${distanceMoved.toStringAsFixed(2)} meters!)",
          );
          return;
        }
      }

      // --- PASSED BOTH GATES: SAVE TO FIREBASE ---
      log("SAVING LOGGED IN USER's LOCATION DATA TO FIREBASE!");

      // Update our trackers
      lastLoggedInUserUpdateToDatabase = now;
      lastSavedDatabasePosition = mp.Position(filteredLng, filteredLat);

      await MyRealtimeLocationReposity.updateLocation(
        deviceID: widget.loggedInUserData.userID,
        realtimeData: MyRealtimeLocationModel(
          deviceID: widget.loggedInUserData.userID,
          patientID: widget.loggedInUserData.userID,
          isInSafeZone: true,
          isCurrentlySafe: true,
          currentlyIn: "NOT APPLICABLE",
          currentLocationLng: filteredLng.toString(),
          currentLocationLat: filteredLat.toString(),
          timeStamp: MyDateFormatter.formatDate(
            dateTimeInString: now,
            formatOptions: 8,
          ),
          deviceBatteryPercentage: await Battery().batteryLevel,
          bPM: "NOT APPLICABLE",
          requestBPM: false,
        ),
      );

      log(
        "########## CURRENTLY LOGGED IN USERS DATA WAS SUCCESSFULLY SAVE IN THE DATABASE",
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

  String getMapViewStyle(int style) {
    switch (style) {
      case 1:
        return mp.MapboxStyles.MAPBOX_STREETS;
      case 2:
        return mp.MapboxStyles.OUTDOORS;
      case 3:
        return mp.MapboxStyles.STANDARD;
      default:
        return mp.MapboxStyles.SATELLITE_STREETS;
    }
  }

  // these were just the things that I can' remove in the map interface because of the MapBox's Terms and Policy, but I can change their position and appearance
  void initOtherMapRequirements(mp.MapboxMap mapController) {
    // logic for displaying user position/location on the map
    if (myHomeSettingsProvider.useDefaultAvatar) {
      mapboxMapController!.location.updateSettings(
        mp.LocationComponentSettings(
          enabled: myHomeSettingsProvider.useDefaultAvatar,
          pulsingEnabled: myHomeSettingsProvider.useDefaultAvatar,
          showAccuracyRing: myHomeSettingsProvider.enableAvatarDistanceAccuracy,
          // accuracyRingColor: const Color.fromARGB(45, 33, 149, 243).toARGB32(),
          // accuracyRingBorderColor: Colors.white12.toARGB32(),
          // Shows the directional cone/arrow
          puckBearingEnabled: true,
          // Defines the direction of the arrow/cone
          puckBearing: mp.PuckBearing.HEADING,
        ),
      );
    }

    // scaleBar indicator, indicator of how much the map is zoomed in/out
    mapboxMapController!.scaleBar.updateSettings(
      mp.ScaleBarSettings(
        enabled: true,
        position: mp.OrnamentPosition.BOTTOM_LEFT,
        primaryColor: Colors.blue.withAlpha(100).toARGB32(),
        showTextBorder: true,
        textColor: Colors.blue.withAlpha(200).toARGB32(),
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
      mp.CompassSettings(
        marginTop: MyDimensionAdapter.getHeight(context) * 0.12,
        marginRight: MyDimensionAdapter.getWidth(context) * 0.16,
        opacity: 0.50,
      ),
    );
  }
}
