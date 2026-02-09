import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/geofence_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/geofence_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/textfield.dart';

class SavingGeofenceForm extends StatefulWidget {
  final String loggedInUserID;
  const SavingGeofenceForm({super.key, required this.loggedInUserID});

  @override
  State<SavingGeofenceForm> createState() => _SavingGeofenceFormState();
}

class _SavingGeofenceFormState extends State<SavingGeofenceForm> {
  // // for displaying the dropdown menu of patients to register in the geofence
  // List<String> allPatientsNameToDisplay = ["Select Patient To Add"];
  // // for storing the actual PersonalInfo objects of the patients to register in the geofence
  // List<PersonalInfo> allPatients = [];

  TextEditingController safeZoneNameController = TextEditingController();

  // PARTICIPANTS
  List<PersonalInfo> participants = [];
  // List<Map<String, bool>> isSelectedParticipants = [];
  List<String> addedParticipants = [];
  bool isAllParticipantsSelected = true;

  // this is to simulate loading while fetching of patients data from firestore
  bool isLoading = true;
  // this is for animation when saving the geofence
  bool isSaving = false;

  Future<void> getAllPatients() async {
    participants = await MyPersonalInfoRepository.getAllPersonalInfoRecords(
      fieldName: "userType",
      valueToLookFor: "Patient",
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // MyLine(
              //   length: MyDimensionAdapter.getWidth(context) * 0.15,
              //   thickness: 4,
              //   isRounded: true,
              //   isVertical: false,
              //   color: Colors.grey.shade600,
              // ),
              // SizedBox(height: 10),
              MyCustAppBar(
                title: "Saving Safe Zone Form",
                fontSize: kDefaultFontSize + 4,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 35),

              MyCustTextfield(
                labelText: "Safezone name",
                prefixIcon: Icons.location_on_rounded,
                textController: safeZoneNameController,
              ),
              SizedBox(height: 20),

              (isLoading)
                  ? CircularProgressIndicator.adaptive()
                  : participantsDropDown(context),
              SizedBox(height: 20),

              Spacer(),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  SizedBox(width: 10),
                  (isSaving)
                      ? CircularProgressIndicator.adaptive()
                      : MyCustButton(
                          buttonText: "Save Safe Zone",
                          buttonTextColor: Colors.white,
                          buttonTextFontSize: kDefaultFontSize + 2,
                          buttonTextFontWeight: FontWeight.w600,
                          buttonTextSpacing: 1.2,
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();

                            // animate the button to show the saving process occurs
                            setState(() => isSaving = true);
                            await saveExecution(context);
                            setState(() => isSaving = false);

                            // after saving the geofence, close the form
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveExecution(BuildContext context) {
    List<List<Position>> listOfMarkedPositions = context
        .read<MyHomeGeofenceConfigurationProvider>()
        .listOfMarkedPositions;

    return MyGeofenceRepository.createGeofence(
      MyGeofenceModel(
        geofenceID:
            "", // This will be generated in the repository to match the doc.id
        geofenceName: safeZoneNameController.text.trim(),
        geofenceCoordinates: listOfMarkedPositions.first,
        centerCoordinates: Position(125.79929, 7.42916),
        createdAt: MyDateFormatter.formatDate(
          dateTimeInString: DateTime.now().toString(),
        ),
        createdBy: widget.loggedInUserID,
        registeredPatients: addedParticipants,
        isActive: true,
      ),
    );
  }

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
                side: BorderSide(
                  color:
                      // (isEditable)?
                      Colors.blue.shade200,
                  // : Colors.grey.shade400,
                  width: 1.5,
                ),
                // overlayColor: WidgetStatePropertyAll(Colors.amber),
                // secondary: Icon(Icons.person_outline_rounded),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue.shade400,
                contentPadding: EdgeInsets.only(left: 5, right: 5),
                title: Text("All Patients"),
                value: isAllParticipantsSelected,
                onChanged: (value) {
                  setState(() {
                    isAllParticipantsSelected = value!;

                    // remove all added participants if not all participants selected
                    if (!isAllParticipantsSelected) {
                      addedParticipants.clear();
                    }
                    // else, add all participants to addedParticipants list
                    else {
                      addedParticipants.addAll(
                        participants.map((participant) {
                          return participant.userID;
                        }),
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

          child: ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              return Card(
                // the logic in this margin is simple if the index is first or last item there will be a larger margin
                margin: (index == 0 || index == participants.length - 1)
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
                      participants[index].userID,
                    ),
                    title: Text(participants[index].name),
                    onChanged: (participant) {
                      setState(() {
                        // if already added, remove from addedParticipants list
                        if (addedParticipants.contains(
                          participants[index].userID,
                        )) {
                          addedParticipants.remove(participants[index].userID);
                        }
                        // else, add to addedParticipants list
                        else {
                          addedParticipants.add(participants[index].userID);
                        }

                        // if all participants are added, set isAllParticipantsSelected to true
                        if (addedParticipants.length == participants.length) {
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
      ],
    );
  }
}
