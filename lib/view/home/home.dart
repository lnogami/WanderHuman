import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
// import 'package:wanderhuman_app/helper/realtime_temporary_test.dart';
import 'package:wanderhuman_app/helper/settings_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/model/settings_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_emergency_contacts_button.dart';
import 'package:wanderhuman_app/view/home/widgets/home_patient_list_dropdown.dart';
import 'package:wanderhuman_app/view/home/widgets/animated_vignette_design.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/saving_geofence_form.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/setting_geofence_bottom_panel.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/active_status.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/set_geofence_interface.dart';
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
        if (context.mounted) {
          context.read<HomeAppBarProvider>().initUserData(
            currentlyLoggedInUserData,
          );
          setState(() {
            isLoading = false;
          });
        }
      });
    } catch (e, stackTrace) {
      log("ERROR FETCHING DATAAAAAA: $e. AT $stackTrace");
    }
  }

  Future<void> setupUserSettings() async {
    late MySettingsModel userSettings;
    // verifies if this person has no settings data yet
    bool isSettingsForThisUserIsAvailable =
        await MySettigsRepository.doesSettingsForThisUserExist(
          userID: currentLoggedInUser,
        );

    // if there is no settings yet for this user, create one
    if (!isSettingsForThisUserIsAvailable) {
      userSettings = MySettingsModel(
        userID: currentLoggedInUser,
        zoomLevel: 15.0,
        alwaysFollowYourAvatar: false,
      );

      await MySettigsRepository.addSettings(settings: userSettings);
    } else {
      userSettings = await MySettigsRepository.getSettingsOfTheUser(
        userID: currentLoggedInUser,
      );
    }

    if (context.mounted) {
      context.read<MyHomeSettingsProvider>().initUserSettings(userSettings);
    }
  }

  @override
  void initState() {
    super.initState();
    initUserData();
    setupUserSettings();
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
    // for special button activation
    bool isAboutToAddCenterPoint = context
        .watch<MyHomeGeofenceConfigurationProvider>()
        .isAboutToAddCenterPoint;

    return PopScope(
      // 1. Set this to false to completely block the default back button behavior
      canPop: false,

      // 2. This triggers when the user presses the back button
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        // If the system already popped the screen, do nothing
        if (didPop) return;

        // // 3. Show your custom confirmation dialog
        // final bool shouldExit = await showExitDialog(context);
        // // 4. If they clicked "Yes", forcefully close the app
        // if (shouldExit) {
        //   SystemNavigator.pop();
        // }

        // Show confirmation dialog
        myAlertDialogue(
          context: context,
          alertTitle: "Confirm Exit",
          alertContent: "Are you sure you want to exit WanderHuman?",
          onApprovalPressed: () {
            SystemNavigator.pop();
          },
        );
      },
      child: Scaffold(
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

                    // Danger indicator
                    Positioned.fill(
                      // child: RectangularVignette(
                      //   fadeColor: Colors.red.withAlpha(100),
                      //   edgeThickness:
                      //       0.15, // 25% of the screen fades from each side
                      // ),
                      child: AnimatedWarningVignette(
                        isActive:
                            (context
                                .watch<MyHomeGeofenceConfigurationProvider>()
                                .patientsInDanger
                                .isNotEmpty)
                            ? true
                            : false,
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
                      isCreatingGeofence: isCreatingGeofence,
                      isAboutToAddCenterPoint: isAboutToAddCenterPoint,
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

                    // // Temporary for testing realtime database only (deletable)
                    // Positioned(
                    //   top: MyDimensionAdapter.getHeight(context) * 0.27,
                    //   left: 18,
                    //   child: animatedOpacity(
                    //     child: IconButton(
                    //       onPressed: () {
                    //         MyNavigator.goTo(context, RealtimeTemporaryTest());
                    //       },
                    //       icon: Icon(
                    //         Icons.data_saver_on_rounded,
                    //         color: Colors.amber,
                    //         size: 32,
                    //       ),
                    //     ),
                    //     isVisible: (!isCreatingGeofence && !isViewingGeofences),
                    //   ),
                    // ),

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

  // Close and Save geofence button
  Positioned creatingOrViewingASafeZoneButtons(
    BuildContext context, {
    required bool isCreatingGeofence,
    required bool isAboutToAddCenterPoint,
  }) {
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
                  MyHomeGeofenceConfigurationProvider
                  geofenceConfigurationProvider = context
                      .read<MyHomeGeofenceConfigurationProvider>();

                  myAlertDialogue(
                    context: context,
                    alertTitle: "Confirm Cancel",
                    alertContent:
                        "Are you sure you want to cancel? \nThe recent activity data will be deleted.",
                    onApprovalPressed: () {
                      geofenceConfigurationProvider.toggleGeofenceCreation(
                        false,
                      );
                      geofenceConfigurationProvider.toggleGeofenceViewing(
                        false,
                      );

                      // for debugging purposes only
                      log(
                        geofenceConfigurationProvider
                            .listOfMarkedPositions[0]
                            .length
                            .toString(),
                      );
                      log("CLOSE BUTTONNNNNNNNNNNNNNNNNNNNNNNNN");

                      // clear all the temporary data in the provider
                      geofenceConfigurationProvider
                          .clearAllCachedTemporaryData();

                      log(
                        geofenceConfigurationProvider
                            .listOfMarkedPositions[0]
                            .length
                            .toString(),
                      );

                      Navigator.pop(context); // closes dialog box
                    },
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

              creatingGeofencesButtons(
                isCreatingGeofence,
                isAboutToAddCenterPoint,
              ),

              // this button is not visible if viewing geofences only
              SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector creatingGeofencesButtons(
    bool isCreatingGeofence,
    bool isAboutToAddCenterPoint,
  ) {
    return (isCreatingGeofence && !isAboutToAddCenterPoint)
        // For creating the outside circle of the geofence
        ? GestureDetector(
            onTap: () {
              // don't proceed if the list of marked points is empty
              if (context
                      .read<MyHomeGeofenceConfigurationProvider>()
                      .listOfMarkedPointAnnotations
                      .length <
                  3) {
                showMyAnimatedSnackBar(
                  context: context,
                  dataToDisplay:
                      "Mark the points where you want to be the borders of your safezone is.",
                  bgColor: Colors.white,
                );
              }
              // proceed only if there are marked coordinates
              else {
                myAlertDialogue(
                  context: context,
                  alertTitle: "Save Marked Coordinates",
                  alertContent:
                      "Are you sure you want to save this coordinates as your safezone's borders?\nYou wont be able to add more coordinates to it, if you want to add you need to close this first and start from the beginning.",
                  onApprovalPressed: () {
                    // toggle the isAboutToAddCenterPoint to true
                    context
                        .read<MyHomeGeofenceConfigurationProvider>()
                        .toggleIsAboutToAddCenterPoint(true);

                    Navigator.pop(context);
                  },
                );
              }
            },
            child: Column(
              children: [
                Icon(Icons.check_rounded, color: Colors.blue, size: 32),
                MyTextFormatter.p(
                  text: "Save",
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          )
        // For creating the center point of the geofence
        : GestureDetector(
            onTap: () {
              if (context
                      .read<MyHomeGeofenceConfigurationProvider>()
                      .centerPoint ==
                  null) {
                showMyAnimatedSnackBar(
                  context: context,
                  dataToDisplay:
                      "Please, mark the center point first to proceed.",
                );
              } else {
                myAlertDialogue(
                  context: context,
                  alertTitle: "Save Center Point",
                  alertContent:
                      "Are you sure you want to save the center point of this safezone?",
                  onApprovalPressed: () {
                    Navigator.pop(context);
                    MyNavigator.goTo(
                      context,
                      SavingGeofenceForm(loggedInUserID: currentLoggedInUser),
                      animationType: 1,
                    );
                  },
                );
              }
            },
            child: Column(
              children: [
                Icon(Icons.check_rounded, color: Colors.blue, size: 32),
                MyTextFormatter.p(
                  text: "Finish",
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          );
  }
}
