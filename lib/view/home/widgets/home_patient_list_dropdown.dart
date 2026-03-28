import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_active_persons_provider.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/animations.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/map_camera_animations.dart';

class HomePatientListDropDown extends StatefulWidget {
  const HomePatientListDropDown({super.key});

  @override
  State<HomePatientListDropDown> createState() =>
      _HomePatientListDropDownState();
}

class _HomePatientListDropDownState extends State<HomePatientListDropDown> {
  late double width;
  late double height;
  // will determin if the dropdown is expanded or not
  bool isExpanded = false;
  // // will determin if the resources are loaded or not
  // bool isLoading = false;
  // this will contain the mapbox controller reference
  late MapboxMap _mapControllerRef;
  // for coloring the selected individual
  String selectedIndividualID = "";
  // // store all the patients and staffs
  // List<PersonalInfo> patientList = [];
  // //      id, position
  // Map<String, Position> patientLocations = {};
  // decoded images buffer
  // Map<String, Uint8List> decodedImagesBuffer = {};

  // Provider
  late MyHomeActivePersonsProvider activePersonsProvider;

  // // will return all the patients in the PersonalInfo in the database (PersonalInfo)
  // Future<void> getActivePatientList() async {
  //   // activeDevice includes both the patient device and the mobile app (caregivers)
  //
  //   // List<MyRealtimeActiveStatusModel> activeDevices =
  //   //     await MyRealtimeActiveStatusRepository.getAllDeviceIDWithActiveStatus();
  //
  //   // log("ALL ACTIVE DEVICESSSSSSSSSSSSSSSSSSSSSS: ${activeDevices.length}");
  //
  //   Map<String, PersonalInfo> activeDevices =
  //       activePersonsProvider.activePersons;
  //
  //   // Storing the data in a temporary local variable is a preventive measure for multiple occurance of data
  //   // that triggers when the dropdown is quickly clode while still loading then opening it again.
  //   List<PersonalInfo> tempPatientList = [];
  //   // Map<String, Position> tempPatientLocations = {};
  //   Map<String, Uint8List> tempDecodedImagesBuffer = {};
  //
  //   for (var device in activeDevices.values) {
  //     // log("PERSON's IDDDDDDDDDDDDDDDD: ${device.userID}");
  //
  //     var person = await MyPersonalInfoRepository.getSpecificPersonalInfo(
  //       userID: device.userID,
  //     );
  //
  //     log(
  //       "Active Person: ${person.name}, userID: ${person.userID}, deviceID: ${person.deviceID}",
  //     );
  //
  //     // add the patient as an active person to a temporaruy list
  //     tempPatientList.add(person);
  //     // // store the coordinates of the patient in a temporary map
  //     // tempPatientLocations[person.userID] =
  //     //     activePersonsProvider.personCurrentPosition[person.userID] ??
  //     //     await MyRealtimeLocationReposity.getLocation(
  //     //       deviceID: person.deviceID,
  //     //     );
  //     // store the decoded image in a temporary buffer
  //     tempDecodedImagesBuffer[person.userID] =
  //         MyImageProcessor.decodeStringToUint8List(person.picture);
  //   }
  //
  //   // log("ALL ACTIVE PERSONSSSSSSSSSSSSSSSSSSSSS: ${patientList.length}");
  //
  //   tempPatientList.sort((a, b) => a.name.compareTo(b.name));
  //
  //   setState(() {
  //     patientList = tempPatientList;
  //     // patientLocations = tempPatientLocations;
  //     decodedImagesBuffer = tempDecodedImagesBuffer;
  //     isLoading = false;
  //   });
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MyDimensionAdapter.getWidth(context) * 0.12;
    height = MyDimensionAdapter.getHeight(context) * 0.035;
    // first store the value of the provider in a variable
    final mapboxProvider = context.watch<MyMapboxRefProvider>();
    activePersonsProvider = context.watch<MyHomeActivePersonsProvider>();
    MyHomeSettingsProvider settingsProvider = context
        .watch<MyHomeSettingsProvider>();

    // this condition will prevent a few second error
    if (mapboxProvider.getMapboxMapController != null) {
      // then, call the getter to assign it to the mapbox controller reference
      _mapControllerRef = mapboxProvider.getMapboxMapController!;
    }

    return MyCustTooltip(
      message: "Tap to exapand/collapse patient list",
      child: GestureDetector(
        onTap: () {
          // this will close the appbar if it is open when opening this dropdown
          context.read<HomeAppBarProvider>().toggleAppBarExpansion(false);

          setState(() {
            isExpanded = !isExpanded;
            if (isExpanded) {
              selectedIndividualID = "";
            }
          });
        },
        // Main Container
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: width,
          padding: EdgeInsetsDirectional.only(
            top: (settingsProvider.minimizeHomePageButtons && isExpanded)
                ? 15
                : 0,
          ),
          decoration: BoxDecoration(
            color: (isExpanded) ? Colors.white60 : Colors.white54,
            borderRadius: (settingsProvider.minimizeHomePageButtons)
                ? BorderRadius.only(
                    topLeft: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  )
                : BorderRadius.all(Radius.circular(7)),
          ),
          child: Column(
            children: [
              // Dropdown Icon
              SizedBox(
                width: width,
                height: height,
                child: MyAnimations.homeDropDownIconButton(
                  context,
                  width: width,
                  height: height,
                  isExpanded: isExpanded,
                ),
              ),

              // Expanding/Collapsing Panel
              AnimatedContainer(
                duration: Duration(milliseconds: 400),
                width: MyDimensionAdapter.getWidth(context) * 0.12,
                height: (isExpanded)
                    ? MyDimensionAdapter.getHeight(context) * 0.675
                    : 0,
                padding: EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: (settingsProvider.minimizeHomePageButtons)
                      ? BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(50),
                        )
                      : BorderRadius.all(Radius.circular(7)),
                ),
                alignment: AlignmentGeometry.topCenter,
                // child: ClipRRect(
                //   borderRadius:
                //       (settingsProvider.minimizeHomePageButtons && isExpanded)
                //       ? BorderRadius.only(bottomLeft: Radius.circular(50))
                //       : BorderRadius.only(
                //           topLeft: Radius.circular(7),
                //           bottomLeft: Radius.circular(7),
                //         ),
                //   child: ListView.builder(
                //     itemCount: activePersonsProvider.activePersons.length,
                //     padding: EdgeInsets.only(bottom: 25),
                //     itemBuilder: (context, index) {
                //       return individualPatientIcon(
                //         personalInfo:
                //             activePersonsProvider.activePersons[index],
                //         context: context,
                //       );
                //     },
                //   ),
                // ),

                // ✅ FIX: Wrap the ListView in an AnimatedOpacity
                child: AnimatedOpacity(
                  // We make the fade slightly faster (300ms) than the drop (400ms)
                  // so the text fades out before the box completely closes!
                  duration: const Duration(milliseconds: 300),
                  opacity: isExpanded ? 1.0 : 0.0,
                  curve: Curves.easeInOut,
                  child: ListView.builder(
                    // ✅ PRO-TIP: Disable scrolling while the box is closed/animating
                    // so the user can't accidentally swipe invisible items
                    physics: isExpanded
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemCount: activePersonsProvider.activePersons.length,
                    padding: EdgeInsets.only(bottom: 25),
                    itemBuilder: (context, index) {
                      return individualPatientIcon(
                        personalInfo:
                            activePersonsProvider.activePersons[index],
                        context: context,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Patient pictures that acts as a tappable icon.
  GestureDetector individualPatientIcon({
    required PersonalInfo personalInfo,
    required BuildContext context,
  }) {
    // this will filer who are the patients among the staff
    bool isPatient = personalInfo.userType == "Patient";

    // for getting the logged in user's personal info, and use it later for enhancing user experience
    final PersonalInfo loggedInUserData = context
        .read<HomeAppBarProvider>()
        .loggedInUserData;

    // only get the first name from the full name
    String firstName = personalInfo.name.split(" ")[0];
    if (firstName.length > 6 && firstName.length <= 10) {
      firstName = firstName.substring(0, 7);
    } else if (firstName.length > 10) {
      firstName = firstName.substring(0, 8);
    }

    return GestureDetector(
      onTap: () {
        // // to handle a scenario where a patient's location is the default 0
        // if (patientLocations[personalInfo.userID]!.lng < 1 &&
        //     patientLocations[personalInfo.userID]!.lat < 1) {
        //   showMyAnimatedSnackBar(
        //     context: context,
        //     dataToDisplay: "Something went wrong.",
        //   );
        // } else {
        // MyMapCameraAnimations.myMapFlyTo(
        //   mapboxController: _mapControllerRef,
        //   // position: Position(125.7989268, 7.4233187),
        //   position: patientLocations[personalInfo.userID]!,
        //   zoomLevel: context.read<MyHomeSettingsProvider>().zoomLevel,
        //   // patientID: personalInfo.userID,
        // );
        // }

        Position? currentPosition =
            activePersonsProvider.personCurrentPosition[personalInfo.userID];

        // removes the person in the dropdown when they go offline
        if (!(activePersonsProvider.activePersons.contains(personalInfo))) {
          showMyAnimatedSnackBar(
            context: context,
            dataToDisplay: "Sorry, ${personalInfo.name} has gone offline.",
          );
          setState(() {
            activePersonsProvider.removeActivePerson(personalInfo.userID);
            activePersonsProvider.removeDecodedImageInBuffer(
              personalInfo.userID,
            );
          });
        }

        // debugging purposes only
        if (currentPosition == null) {
          showMyAnimatedSnackBar(
            context: context,
            dataToDisplay:
                "Something went wrong. Cannot determine the location.",
          );
          return;
        }

        // Zoom out if the same individual is selected again
        setState(() {
          if (selectedIndividualID == personalInfo.userID) {
            // revert back to default if individual is selected again
            selectedIndividualID = "";
            MyMapCameraAnimations.myMapZoom(
              mapboxController: _mapControllerRef,
              zoomLevel: 15,
            );
          } else {
            selectedIndividualID = personalInfo.userID;
            MyMapCameraAnimations.myMapFlyTo(
              mapboxController: _mapControllerRef,
              // position: Position(125.7989268, 7.4233187),
              // position: patientLocations[personalInfo.userID]!,
              position: currentPosition,
              zoomLevel: context.read<MyHomeSettingsProvider>().zoomLevel,
              // patientID: personalInfo.userID,
            );
          }
        });

        // debugging purposes only
        log(
          "============= [ID:${personalInfo.userID}] ${personalInfo.name}'s location is lng: ${currentPosition.lng} lat: ${currentPosition.lat}",
        );
        // showMyAnimatedSnackBar(
        //   context: context,
        //   dataToDisplay: "${personalInfo.name} userID: ${personalInfo.userID}",
        // );
      },
      child: Container(
        decoration: BoxDecoration(
          color: (selectedIndividualID == personalInfo.userID)
              ? Colors.blue.shade100
              : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
        padding: EdgeInsets.fromLTRB(2, 5, 2, 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircleAvatar(backgroundColor: Colors.blue,),
            AspectRatio(
              aspectRatio: 1 / 1,
              child: CircleAvatar(
                child: MyImageDisplayer(
                  base64ImageString: activePersonsProvider
                      .decodedImagesBuffer[personalInfo.userID],
                ),
              ),
            ),
            MyTextFormatter.p(
              text: (loggedInUserData.userID == personalInfo.userID)
                  ? "Me" // "you"
                  : firstName,
              fontsize: kDefaultFontSize - 4,
              fontWeight: (isPatient) ? FontWeight.w600 : FontWeight.w500,
              color: (isPatient) ? Colors.blue.shade700 : Colors.black,
            ),
          ],
        ),
      ),
    );
    //     }
    //   },
    // );
  }
}
