import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/helper/realtime_active_status_repository.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/model/realtime_active_status_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/fly_to.dart';

class HomePatientListDropDown extends StatefulWidget {
  const HomePatientListDropDown({super.key});

  @override
  State<HomePatientListDropDown> createState() =>
      _HomePatientListDropDownState();
}

class _HomePatientListDropDownState extends State<HomePatientListDropDown> {
  // will determin if the dropdown is expanded or not
  bool isExpanded = false;
  // will determin if the resources are loaded or not
  bool isLoading = false;
  // this will contain the mapbox controller reference
  late MapboxMap _mapControllerRef;
  // for coloring the selected individual
  String selectedIndividualID = "";
  // store all the patients and staffs
  List<PersonalInfo> patientList = [];
  //      id, position
  Map<String, Position> patientLocations = {};
  // decoded images buffer
  Map<String, Uint8List> decodedImagesBuffer = {};

  // will return all the patients in the PersonalInfo in the database (PersonalInfo)
  Future<void> getActivePatientList() async {
    List<MyRealtimeActiveStatusModel> activeDevices =
        await MyRealtimeActiveStatusRepository.getAllDeviceIDWithActiveStatus();
    // log("ALL ACTIVE DEVICESSSSSSSSSSSSSSSSSSSSSS: ${activeDevices.length}");

    // Storing the data in a temporary local variable is a preventive measure for multiple occurance of data
    // that triggers when the dropdown is quickly clode while still loading then opening it again.
    List<PersonalInfo> tempPatientList = [];
    Map<String, Position> tempPatientLocations = {};
    Map<String, Uint8List> tempDecodedImagesBuffer = {};

    for (var device in activeDevices) {
      // log("PERSON's IDDDDDDDDDDDDDDDD: ${device.userID}");

      var person = await MyPersonalInfoRepository.getSpecificPersonalInfo(
        userID: device.userID,
      );

      // add the patient as an active person to a temporaruy list
      tempPatientList.add(
        await MyPersonalInfoRepository.getSpecificPersonalInfo(
          userID: device.userID,
        ),
      );
      // store the coordinates of the patient in a temporary map
      tempPatientLocations[device.userID] =
          await MyRealtimeLocationReposity.getLocation(deviceID: device.userID);
      // store the decoded image in a temporary buffer
      tempDecodedImagesBuffer[device.userID] =
          MyImageProcessor.decodeStringToUint8List(person.picture);
    }

    // log("ALL ACTIVE PERSONSSSSSSSSSSSSSSSSSSSSS: ${patientList.length}");

    tempPatientList.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      patientList = tempPatientList;
      patientLocations = tempPatientLocations;
      decodedImagesBuffer = tempDecodedImagesBuffer;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // first store the value of the provider in a variable
    final mapboxProvider = context.watch<MyMapboxRefProvider>();
    // this condition will prevent a few second error
    if (mapboxProvider.getMapboxMapController != null) {
      // then, call the getter to assign it to the mapbox controller reference
      _mapControllerRef = mapboxProvider.getMapboxMapController!;
    }

    return MyCustTooltip(
      message: "Tap to exapand/collapse patient list",
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
            if (isExpanded) {
              isLoading = true;
              getActivePatientList();
            } else {
              patientList.clear();
              patientLocations.clear();
              decodedImagesBuffer.clear();
              selectedIndividualID = "";
            }
          });
        },
        // Main Container
        child: Container(
          width: MyDimensionAdapter.getWidth(context) * 0.12,
          decoration: BoxDecoration(
            color: (isExpanded) ? Colors.white60 : Colors.white54,
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          child: Column(
            children: [
              // Dropdown Icon
              (isExpanded)
                  // ? Icon(Icons.keyboard_arrow_up_rounded, size: 24)
                  // : Icon(Icons.keyboard_arrow_down_rounded, size: 24),
                  ? Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: Colors.blue.shade600,
                      // shadows: [Shadow(color: Colors.black12, blurRadius: 4)],
                    )
                  : Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: Colors.grey.shade700,
                    ),
              // Horizontal Line
              if (isExpanded)
                MyLine(
                  length: MyDimensionAdapter.getWidth(context) * 0.1,
                  isVertical: false,
                  margin: 0,
                ),
              // Expanding/Collapsing Panel
              AnimatedContainer(
                duration: Duration(milliseconds: 400),
                width: MyDimensionAdapter.getWidth(context) * 0.12,
                height: (isExpanded)
                    ? MyDimensionAdapter.getHeight(context) * 0.65
                    : 0,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                alignment: AlignmentGeometry.topCenter,
                child: (isLoading)
                    ? CircularProgressIndicator.adaptive()
                    : ListView.builder(
                        itemCount: patientList.length,
                        itemBuilder: (context, index) {
                          return individualPatientIcon(
                            personalInfo: patientList[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Patient pictures that acts as a tappable icon.
  GestureDetector individualPatientIcon({required PersonalInfo personalInfo}) {
    bool isPatient = personalInfo.userType == "Patient";

    // only get the first name from the full name
    String firstName = personalInfo.name.split(" ")[0];
    if (firstName.length > 6 && firstName.length <= 10) {
      firstName = firstName.substring(0, 7);
    } else if (firstName.length > 10) {
      firstName = firstName.substring(0, 8);
    }

    return GestureDetector(
      onTap: () {
        myMapFlyTo(
          mapboxController: _mapControllerRef,
          // position: Position(125.7989268, 7.4233187),
          position: patientLocations[personalInfo.userID]!,
          // patientID: personalInfo.userID,
        );

        setState(() {
          selectedIndividualID = personalInfo.userID;
        });
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
                  base64ImageString: decodedImagesBuffer[personalInfo.userID],
                ),
              ),
            ),
            MyTextFormatter.p(
              text: firstName,
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
