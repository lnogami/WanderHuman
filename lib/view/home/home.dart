import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/helper/realtime_temporary_test.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_emergency_contacts_button.dart';
import 'package:wanderhuman_app/view/home/widgets/home_patient_list_dropdown.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/saving_geofence_form.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/setting_geofence_bottom_panel.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/active_status.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/set_geofence_interface.dart';
import 'package:wanderhuman_app/view/home_appbar/home_appbar.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  // UID of the logged in user
  final String currentLoggedInUser = FirebaseAuth.instance.currentUser!.uid;

  // this will initialize the logged in user's personal info in the HomeAppBarProvider
  Future<void> initUserData() async {
    try {
      // Fetch the full object once to save reads
      PersonalInfo currentlyLoggedInUserData =
          await MyPersonalInfoRepository.getSpecificPersonalInfo(
            userID: currentLoggedInUser,
          );

      // using addPostFrameCallback ensures it doesn't conflict with the build cycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeAppBarProvider>().initUserData(
          currentlyLoggedInUserData,
        );
        setState(() {
          isLoading = false;
        });
      });
    } catch (e, stackTrace) {
      log("ERROR FETCHING DATAAAAAA: $e. AT $stackTrace");
    }
  }

  @override
  void initState() {
    super.initState();
    initUserData();
    ActiveStatus.setupOnDisconnectStatus();
  }

  @override
  void dispose() {
    ActiveStatus.setActiveStatusToOffline();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geofenceProvider = context
        .watch<MyHomeGeofenceConfigurationProvider>();
    bool isCreatingGeofence = geofenceProvider.isCreatingGeofence;
    bool isViewingGeofences = geofenceProvider.isViewingGeofences;

    return Scaffold(
      body: SafeArea(
        child: (isLoading)
            ? Center(child: CircularProgressIndicator())
            : Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Map body
                  Positioned(
                    // child: Container()
                    child: SizedBox(
                      width: MyDimensionAdapter.getWidth(context),
                      height: MyDimensionAdapter.getHeight(context),
                      child: MapBody(
                        loggedInUserData: context
                            .watch<HomeAppBarProvider>()
                            .loggedInUserData,
                      ),
                      // child: MyMapBody(),
                    ),
                  ),

                  // this only appears if the user is creating/viewing geofences
                  Positioned(
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      width: MyDimensionAdapter.getWidth(context),
                      height:
                          MyDimensionAdapter.getHeight(context) *
                          ((isCreatingGeofence) ? 0.25 : 0),
                      color: Colors.white70,
                      child: SettingGeofenceBottomPanel(),
                    ),
                  ),

                  // this only appears if the user is creating/viewing geofences
                  creatingOrViewingASafeZoneButtons(
                    context,
                    isCreatingGeofence,
                  ),

                  // -----------------------
                  // Emergency Contacts
                  Positioned(
                    top: MyDimensionAdapter.getHeight(context) * 0.12,
                    left: 18,
                    child: animatedOpacity(
                      child: MyHomeEmergencyContactsButton(),
                      isVisible: (!isCreatingGeofence && !isViewingGeofences),
                    ),
                  ),

                  // Set Geofence
                  Positioned(
                    top: MyDimensionAdapter.getHeight(context) * 0.2,
                    left: 18,
                    child: animatedOpacity(
                      child: SetGeofence(),
                      isVisible: (!isCreatingGeofence && !isViewingGeofences),
                    ),
                  ),

                  // Temporary for testing realtime database only (deletable)
                  Positioned(
                    top: MyDimensionAdapter.getHeight(context) * 0.27,
                    left: 18,
                    child: animatedOpacity(
                      child: IconButton(
                        onPressed: () {
                          MyNavigator.goTo(context, RealtimeTemporaryTest());
                        },
                        icon: Icon(
                          Icons.data_saver_on_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                      isVisible: (!isCreatingGeofence && !isViewingGeofences),
                    ),
                  ),

                  // Dropdown
                  Positioned(
                    // top: MyDimensionAdapter.getHeight(context) * 0.18,
                    top: MyDimensionAdapter.getHeight(context) * 0.12,
                    right: 18,
                    child: animatedOpacity(
                      child: HomePatientListDropDown(),
                      isVisible: (!isCreatingGeofence && !isViewingGeofences),
                    ),
                  ),

                  // Appbar
                  Positioned(
                    top: 20,
                    child: animatedOpacity(
                      child: HomeAppBar(
                        loggedInUserData: context
                            .watch<HomeAppBarProvider>()
                            .loggedInUserData,
                      ),
                      isVisible: (!isCreatingGeofence && !isViewingGeofences),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  IgnorePointer animatedOpacity({
    required Widget child,
    required bool isVisible,
  }) {
    // IgnorePointer ignores the invisible widget's touch events
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        opacity: (isVisible) ? 1 : 0,
        duration: Duration(milliseconds: 400),
        child: child,
      ),
    );
  }

  Positioned creatingOrViewingASafeZoneButtons(
    BuildContext context,
    bool isCreatingGeofence,
  ) {
    return Positioned(
      top: MyDimensionAdapter.getHeight(context) * 0.01,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        width:
            MyDimensionAdapter.getWidth(context) *
            ((isCreatingGeofence) ? 0.35 : 0),
        alignment: AlignmentGeometry.center,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(7),
            bottomLeft: Radius.circular(7),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              GestureDetector(
                onTap: () {
                  context
                      .read<MyHomeGeofenceConfigurationProvider>()
                      .toggleGeofenceCreation(false);
                  context
                      .read<MyHomeGeofenceConfigurationProvider>()
                      .toggleGeofenceViewing(false);
                  log(
                    context
                        .read<MyHomeGeofenceConfigurationProvider>()
                        .listOfMarkedPositions[0]
                        .length
                        .toString(),
                  );
                  log("CLOSE BUTTONNNNNNNNNNNNNNNNNNNNNNNNN");
                  // This is to clear the list of marked positions
                  context
                      .read<MyHomeGeofenceConfigurationProvider>()
                      .clearMarkedPositions();
                  // This is to clear the polygonManager's data
                  log(
                    context
                        .read<MyHomeGeofenceConfigurationProvider>()
                        .listOfMarkedPositions[0]
                        .length
                        .toString(),
                  );
                },
                child: Column(
                  children: [
                    Icon(Icons.close, color: Colors.grey.shade200, size: 32),
                    MyTextFormatter.p(
                      text: "Close",
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
              // this button is not visible viewing geofences only
              if (isCreatingGeofence)
                GestureDetector(
                  onTap: () {
                    if (!context
                        .read<MyHomeGeofenceConfigurationProvider>()
                        .isAboutToAddCenterPoint) {
                      context
                          .read<MyHomeGeofenceConfigurationProvider>()
                          .toggleIsAboutToAddCenterPoint(true);
                    } else {
                      MyNavigator.goTo(
                        context,
                        SavingGeofenceForm(loggedInUserID: currentLoggedInUser),
                        animationType: 1,
                      );
                    }
                    // Actions to be added here
                  },
                  child: Column(
                    children: [
                      Icon(Icons.check, color: Colors.blue, size: 32),
                      MyTextFormatter.p(
                        text: "Save",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }
}
