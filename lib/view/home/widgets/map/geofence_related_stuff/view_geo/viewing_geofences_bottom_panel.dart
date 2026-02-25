// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/geofence_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/textfield.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/map_camera_animations.dart';

class ViewingGeofencesBottomPanel extends StatefulWidget {
  const ViewingGeofencesBottomPanel({super.key});

  @override
  State<ViewingGeofencesBottomPanel> createState() =>
      _ViewingGeofencesBottomPanelState();
}

class _ViewingGeofencesBottomPanelState
    extends State<ViewingGeofencesBottomPanel> {
  double width = 0;
  bool isLoadingResources = true;
  bool isExpanded = false;

  late FixedExtentScrollController scrollController;
  late ScrollController infoFieldsScrollController;
  late ScrollController participantsScrollController;
  List<MyGeofenceModel> allGeofences = [];
  late MyGeofenceModel selectedGeofence;
  int selectedGeofenceIndex = 0;
  late bool isCurrentlySelectedGeofenceActive;

  List<PersonalInfo> listOfPatients = [];
  List<String> addedParticipants = [];
  TextEditingController geofenceNameController = TextEditingController();
  bool isAllParticipantsSelected = false;
  bool isSavingUpdate = false;

  Future<void> getAllPatients() async {
    final tempVar = await MyPersonalInfoRepository.getAllPersonalInfoRecords(
      fieldName: "userType",
      valueToLookFor: "Patient",
    );
    setState(() => listOfPatients = tempVar);
    log("All Patients Fetched: ${listOfPatients.length}");
  }

  Future<void> getAllGeofences() async {
    await getAllPatients();

    // Get all the geofences from the database
    final tempVar = await MyGeofenceRepository.getAllGeofences();
    tempVar.sort((a, b) => a.geofenceName.compareTo(b.geofenceName));

    // early exit if there is no single geofence in existence
    if (tempVar.isEmpty) {
      setState(() {
        allGeofences = [];
        isExpanded = false;
        // context
        //     .read<MyHomeGeofenceConfigurationProvider>()
        //     .toggleGeofenceCreation(false); // just in case still needed
        context
            .read<MyHomeGeofenceConfigurationProvider>()
            .toggleGeofenceViewing(false);
      });
      return;
    }
    setState(() {
      allGeofences = tempVar;
      // for safety purposes
      if (selectedGeofenceIndex >= allGeofences.length) {
        selectedGeofenceIndex = allGeofences.length - 1;
        log("THE SAFETY MEASURE WAS EXECUTED!");
      }
      selectedGeofence = allGeofences[selectedGeofenceIndex];
      isCurrentlySelectedGeofenceActive = selectedGeofence.isActive;
      geofenceNameController.text = selectedGeofence.geofenceName;
      addedParticipants = selectedGeofence.registeredPatients;
      if (listOfPatients.length == addedParticipants.length) {
        isAllParticipantsSelected = true;
      }
      isLoadingResources = false;
    });
    log("All Geofences Fetched: ${allGeofences.length}");
  }

  @override
  initState() {
    super.initState();
    getAllGeofences();
    scrollController = FixedExtentScrollController(initialItem: 0);
    infoFieldsScrollController = ScrollController();
    participantsScrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    infoFieldsScrollController.dispose();
    participantsScrollController.dispose();
    geofenceNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MyDimensionAdapter.getWidth(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: width,
      height:
          MyDimensionAdapter.getHeight(context) * ((isExpanded) ? 0.85 : 0.25),
      color: Colors.white60,
      child: (allGeofences.isEmpty)
          // If there are no geofences, this will appear as default
          ? ifNoGeofenceIsInExistenceShowDefaultPanel()
          // If there are geofences, this will appear instead
          : Column(
              children: [
                (isLoadingResources)
                    // a circular progress indicator
                    ? ifResourcesIsStillBeingLoaded(context)
                    // Scrollable List of Geofences (Safe Zones)
                    // The widget that's visible when all resources has been fetched
                    : SizedBox(
                        width: width,
                        height: MyDimensionAdapter.getHeight(context) * 0.24,
                        // color: Colors.amber,
                        child: RawScrollbar(
                          radius: Radius.circular(50),
                          interactive: false,
                          thumbVisibility: true,
                          trackVisibility: true,
                          trackColor: Colors.grey.shade300,
                          thumbColor: Colors.blue.shade200,
                          thickness: 4,
                          // padding: EdgeInsets.only(right: -20, top: 5, bottom: 5),
                          padding: EdgeInsets.only(
                            // right: (width * -0.095),
                            top: 10,
                            bottom: 15,
                          ),
                          controller: scrollController,
                          child: ListWheelScrollView(
                            // key: ValueKey(listOfPositions!.length),
                            perspective: 0.005,
                            controller: scrollController,
                            // squeeze: 2,
                            // useMagnifier: true,
                            // offAxisFraction: 1,
                            // perspective: RenderListWheelViewport.,
                            diameterRatio: 1.3,
                            itemExtent:
                                MyDimensionAdapter.getHeight(context) * 0.1,
                            onSelectedItemChanged: (value) {
                              setState(() {
                                // get the current selected geofence
                                selectedGeofence = allGeofences[value];
                                selectedGeofenceIndex = value;
                                isCurrentlySelectedGeofenceActive =
                                    selectedGeofence.isActive;
                                geofenceNameController.text =
                                    selectedGeofence.geofenceName;
                                // clear the addedParticipants list first before adding new value to it
                                addedParticipants.clear();
                                addedParticipants.addAll(
                                  selectedGeofence.registeredPatients,
                                );
                                // this will set isAllParticipantsSelected to true or false
                                if (listOfPatients.length ==
                                    addedParticipants.length) {
                                  isAllParticipantsSelected = true;
                                } else {
                                  isAllParticipantsSelected = false;
                                }
                              });

                              MyMapCameraAnimations.myMapFlyTo(
                                mapboxController: context
                                    .read<MyMapboxRefProvider>()
                                    .getMapboxMapController!,
                                position: selectedGeofence.centerCoordinates,
                                zoomLevel: context
                                    .read<MyHomeSettingsProvider>()
                                    .zoomLevel,
                              );
                            },
                            children: myIterator(),
                          ),
                        ),
                      ),
                MyLine(length: width * 0.8, isVertical: false, margin: 0),
                //
                if (isExpanded)
                  Expanded(
                    child: RawScrollbar(
                      controller: infoFieldsScrollController,
                      radius: Radius.circular(50),
                      interactive: false,
                      thumbVisibility: true,
                      trackVisibility: true,
                      trackColor: Colors.grey.shade300,
                      thumbColor: Colors.blue.shade200,
                      thickness: 4,
                      padding: EdgeInsets.only(top: 15, bottom: 10),
                      child: SingleChildScrollView(
                        controller: infoFieldsScrollController,
                        child: SizedBox(
                          width: width,
                          // color: Colors.amber,
                          child: infoFields(selectedGeofence),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  SizedBox ifResourcesIsStillBeingLoaded(BuildContext context) {
    return SizedBox(
      height: MyDimensionAdapter.getHeight(context) * 0.24,
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Column ifNoGeofenceIsInExistenceShowDefaultPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.query_stats_outlined, color: Colors.grey.shade600, size: 64),
        SizedBox(height: 15),
        MyTextFormatter.p(
          text: "There is no Safezone in existence.",
          color: Colors.grey.shade700,
          fontsize: kDefaultFontSize + 2,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  // Textboxes
  Column infoFields(MyGeofenceModel? geofence) {
    return Column(
      spacing: 2.5,
      children: [
        SizedBox(height: 15),
        layoutedTextFields(
          label: "Safezone Name",
          child: MyCustTextfield(
            labelText: "",
            prefixIcon: Icons.abc_outlined,
            borderRadius: 7,
            textController: geofenceNameController,
          ),
        ),
        SizedBox(height: 9.5),

        // Boolean Button
        MyCustButton(
          buttonText: (isCurrentlySelectedGeofenceActive)
              ? "Is currently Active"
              : "Not currently Active",
          color: (isCurrentlySelectedGeofenceActive)
              ? Colors.blue
              : Colors.grey.shade400,
          buttonShadowColor: (isCurrentlySelectedGeofenceActive)
              ? Colors.blue
              : Colors.grey.shade400,
          buttonTextColor: Colors.white,
          buttonTextFontSize: kDefaultFontSize + 2,
          buttonTextFontWeight: FontWeight.w600,
          buttonTextSpacing: 1.2,
          borderRadius: 7,
          widthPercentage: 0.8,
          onTap: () {
            setState(() {
              isCurrentlySelectedGeofenceActive =
                  !isCurrentlySelectedGeofenceActive;
            });
          },
        ),
        SizedBox(height: 1),

        layoutedTextFields(
          label: "Created At",
          child: MyCustTextfield(
            labelText: "",
            prefixIcon: Icons.info_outline_rounded,
            borderRadius: 7,
            isReadOnly: true,
            textController: TextEditingController()
              ..text = geofence?.createdAt ?? "",
            borderColor: Colors.grey.shade400,
            activeBorderColor: Colors.grey.shade400,
          ),
        ),
        layoutedTextFields(
          label: "Created By",
          child: MyCustTextfield(
            labelText: "",
            prefixIcon: Icons.info_outline_rounded,
            borderRadius: 7,
            isReadOnly: true,
            textController: TextEditingController()
              ..text = geofence?.createdBy ?? "",
            borderColor: Colors.grey.shade400,
            activeBorderColor: Colors.grey.shade400,
          ),
        ),
        participantsDropDown(context),
        SizedBox(height: 10),
        saveAndCancelButtons(),
        SizedBox(height: 10),
      ],
    );
  }

  // infoFields > layoutedTextFields
  Column layoutedTextFields({required MyCustTextfield child, String? label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: MyTextFormatter.p(
            text: label ?? "",
            fontsize: kDefaultFontSize - 4,
            color: Colors.grey.shade800,
          ),
        ),
        child,
      ],
    );
  }

  // this is responsible for
  List<Widget> myIterator() {
    if (allGeofences.isEmpty) return [];
    // int length = MyMapGeofence.customShapePoints.length;
    List<Widget> widgets = <Widget>[];
    for (var geofence in allGeofences) {
      widgets.add(_myCustomContainer(geofence));
      // log("Geofence Name: ${geofence.geofenceName}");
    }
    return widgets;
  }

  // containers for the ListWheelScrollView childred, the UI
  GestureDetector _myCustomContainer(MyGeofenceModel geofence) {
    return GestureDetector(
      onTap: () {
        // can't be expanded if resources are still being loaded
        if (!isLoadingResources) {
          setState(() => isExpanded = !isExpanded);
        }
      },
      onLongPress: () {
        myAlertDialogue(
          context: context,
          alertTitle: "Delete Geofence",
          alertContent: "Are you sure you want to delete this Safezone?",
          onApprovalPressed: () async {
            // Delete the geofence from the database
            await MyGeofenceRepository.deleteGeofence(
              id: selectedGeofence.geofenceID,
            );
            // to refresh the fetched geofences
            getAllGeofences();

            Navigator.pop(context);
          },
        );
      },
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.8,
        height: MyDimensionAdapter.getHeight(context) * 0.25,
        margin: EdgeInsets.only(top: 5),
        padding: EdgeInsets.only(left: 20, right: 10),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(7),
          border: BoxBorder.all(color: MyColorPalette.formColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextFormatter.p(
              text: "Safezone Name: ",
              fontsize: kDefaultFontSize - 4,
            ),
            SizedBox(width: 5),
            MyTextFormatter.h3(
              text: geofence.geofenceName,
              color: (geofence.isActive)
                  ? MyColorPalette.subtitleTextColor
                  : Colors.grey.shade600,
            ),
          ],
        ),
        // child: SizedBox(height: 100, child: child),
        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Spacer(),
        //     Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.end,
        //       children: [
        //         MyTextFormatter.p(text: "Longhitude: "),
        //         MyTextFormatter.p(text: "Latitude: "),
        //       ],
        //     ),
        //     SizedBox(width: 4.0),
        //     Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         MyTextFormatter.p(
        //           text: "${postion.lng}",
        //           color: Colors.blue.shade500,
        //           fontWeight: FontWeight.w600,
        //         ),
        //         MyTextFormatter.p(
        //           text: "${postion.lat}",
        //           color: Colors.blue.shade500,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ],
        //     ),
        //     Spacer(),
        //   ],
        // ),
      ),
    );
  }

  //
  Column participantsDropDown(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextFormatter.p(
          text: "Add Participants:",
          fontsize: kDefaultFontSize - 1,
        ),
        Container(
          width: MyDimensionAdapter.getWidth(context) * 0.8,
          height: MyDimensionAdapter.getHeight(context) * 0.075,
          decoration: BoxDecoration(
            // color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Card(
            margin: EdgeInsets.all(1),
            color: (isAllParticipantsSelected)
                ? const Color.fromARGB(255, 225, 237, 253)
                : MyColorPalette.formColor,
            borderOnForeground: true,
            surfaceTintColor: MyColorPalette.splashColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            shadowColor: Colors.blue.shade200,
            elevation: 2.5,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(splashColor: const Color.fromARGB(51, 74, 173, 255)),
              child: CheckboxListTile.adaptive(
                side: BorderSide(
                  color:
                      // (isEditable)?
                      Colors.blue.shade200,
                  // : Colors.grey.shade400,
                  width: 1.5,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue.shade400,
                contentPadding: EdgeInsets.only(left: 5, right: 5),
                title: Text("All Patients"),
                value: isAllParticipantsSelected,
                onChanged: (value) {
                  setState(() {
                    isAllParticipantsSelected = value!;
                    log(
                      "THE VALUE OF IS ALL PARTICIPANTS SELECTED: $isAllParticipantsSelected",
                    );

                    // remove all added participants if not all participants selected
                    if (!isAllParticipantsSelected) {
                      addedParticipants.clear();
                    }
                    // else, add all participants to addedParticipants list
                    else {
                      addedParticipants.addAll(
                        listOfPatients.map((participant) {
                          return participant.userID;
                        }),
                      );

                      log(
                        "NOTICEEEEEEEEEEEEEEEEEEEEEEEE: ADDED PARTICIPANTS: $addedParticipants",
                      );
                    }
                    // This helper method finds whatever text field is currently active and closes it
                    FocusScope.of(context).unfocus();
                  });
                },
              ),
            ),
          ),
        ),

        // Added Participants AREA
        AnimatedContainer(
          duration: Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
          width: MyDimensionAdapter.getWidth(context) * 0.77,
          // if not all participants selected, show the added participants area
          height: (!isAllParticipantsSelected)
              ? MyDimensionAdapter.getHeight(context) * 0.3
              : 0,
          padding: EdgeInsets.only(left: 7, right: 7),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 252, 253, 255),
            border: Border(
              left: BorderSide(width: 1, color: Colors.blue.shade200),
              right: BorderSide(width: 1, color: Colors.blue.shade200),
              bottom: BorderSide(width: 1, color: Colors.blue.shade200),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(7),
              bottomRight: Radius.circular(7),
            ),
          ),

          child: RawScrollbar(
            controller: participantsScrollController,
            radius: Radius.circular(50),
            interactive: false,
            thumbVisibility: true,
            trackVisibility: true,
            trackColor: Colors.grey.shade300,
            thumbColor: Colors.blue.shade200,
            thickness: 4,
            padding: EdgeInsets.only(right: -10),
            child: ListView.builder(
              controller: participantsScrollController,
              itemCount: listOfPatients.length,
              itemBuilder: (context, index) {
                return Card(
                  // the logic in this margin is simple if the index is first or last item there will be a larger margin
                  margin: (index == 0 || index == listOfPatients.length - 1)
                      ? // if index is 0 means the first element, else it is the last element
                        (index == 0)
                            ? EdgeInsets.only(top: 7.5)
                            : EdgeInsets.only(top: 7, bottom: 8)
                      : EdgeInsets.only(top: 7),
                  color: const Color.fromARGB(255, 233, 242, 255),
                  borderOnForeground: true,
                  surfaceTintColor: MyColorPalette.splashColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  shadowColor: Colors.blue.shade100,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: const Color.fromARGB(
                        51,
                        74,
                        173,
                        255,
                      ), // The ripple color (Splash)
                      // highlightColor:
                      //     MyColorPalette.formColor, // The background hold color
                    ),
                    child: CheckboxListTile.adaptive(
                      // to match the Card's shape
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                      overlayColor: WidgetStatePropertyAll(Colors.amber),
                      // secondary: Icon(Icons.person_outline_rounded),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.blue.shade200,
                      contentPadding: EdgeInsets.only(left: 5, right: 5),
                      value: addedParticipants.contains(
                        listOfPatients[index].userID,
                      ),
                      title: Text(listOfPatients[index].name),
                      onChanged: (participant) {
                        setState(() {
                          // if already added, remove from addedParticipants list
                          if (addedParticipants.contains(
                            listOfPatients[index].userID,
                          )) {
                            addedParticipants.remove(
                              listOfPatients[index].userID,
                            );
                          }
                          // else, add to addedParticipants list
                          else {
                            addedParticipants.add(listOfPatients[index].userID);
                          }

                          // if all participants are added, set isAllParticipantsSelected to true
                          if (addedParticipants.length ==
                              listOfPatients.length) {
                            isAllParticipantsSelected = true;
                          } else {
                            isAllParticipantsSelected = false;
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Row saveAndCancelButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5,
      children: [
        MyCustButton(
          buttonText: "Cancel",
          color: Colors.transparent,
          enableShadow: false,
          borderColor: Colors.transparent,
          widthPercentage: 0.25,
          buttonTextSpacing: 1.2,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        (isSavingUpdate)
            ? CircularProgressIndicator.adaptive()
            : MyCustButton(
                buttonText: "Save Changes",
                buttonTextSpacing: 1.2,
                buttonTextColor: Colors.white,
                buttonTextFontSize: kDefaultFontSize + 2,
                onTap: () async {
                  // to start the animation of the button
                  setState(() {
                    isSavingUpdate = true;
                  });
                  // this will verify if the patient is already registered in another active safezone
                  bool alreadyExist = false;
                  String name = "";
                  for (var patient in addedParticipants) {
                    if (await MyGeofenceRepository.isPatientAlreadyRegisteredInAnActiveGeofence(
                      patientID: patient,
                      geofenceIDToBeExcluded: selectedGeofence.geofenceID,
                    )) {
                      alreadyExist = true;
                      final patientName =
                          await MyPersonalInfoRepository.getSpecificPersonalInfo(
                            userID: patient,
                          );
                      name = patientName.name;
                    }
                  }

                  // can only update if the patient is not already registered in another safezone OR if the safezone will be inactive
                  if (!alreadyExist || !isCurrentlySelectedGeofenceActive) {
                    myAlertDialogue(
                      context: context,
                      alertTitle: "Confirm Update",
                      alertContent:
                          "Are you sure you want to save these changes?",
                      onApprovalPressed: () async {
                        // to start the animation of the button
                        // setState(() {
                        //   isSavingUpdate = true;
                        // });
                        await MyGeofenceRepository.updateGeofence(
                          id: selectedGeofence.geofenceID,
                          geofenceModel: MyGeofenceModel(
                            geofenceID: selectedGeofence.geofenceID,
                            geofenceName: geofenceNameController.text,
                            geofenceCoordinates:
                                selectedGeofence.geofenceCoordinates,
                            centerCoordinates:
                                selectedGeofence.centerCoordinates,
                            createdAt: selectedGeofence.createdAt,
                            createdBy: selectedGeofence.createdBy,
                            registeredPatients: addedParticipants,
                            isActive: isCurrentlySelectedGeofenceActive,
                          ),
                        );

                        log(
                          "Successfully Updated Geofence with ID: ${selectedGeofence.geofenceID}",
                        );

                        Navigator.pop(context);
                        Future.delayed(Duration(milliseconds: 500), () {
                          // to animate a closing panel effect after saving changes
                          isExpanded = false;
                          // to refresh the fetched geofences
                          getAllGeofences();
                        });
                      },
                    );
                  } else {
                    showMyAnimatedSnackBar(
                      context: context,
                      dataToDisplay:
                          "Patient $name is already registered in another safezone",
                    );
                  }

                  // to stop the animation of the button
                  setState(() {
                    isSavingUpdate = false;
                  });
                },
              ),
      ],
    );
  }
}
