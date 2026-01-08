import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/hl_planner_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/home_life_models/hl_planner_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/date_picker.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';

class HomeLifePlanner extends StatefulWidget {
  const HomeLifePlanner({super.key});

  @override
  State<HomeLifePlanner> createState() => _HomeLifePlannerState();
}

class _HomeLifePlannerState extends State<HomeLifePlanner> {
  // TEXTFIELDS
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // DATES & TIME
  DateTime? fromDate;
  DateTime? untilDate;
  TimeOfDay? time;
  // choice for repeat every dropdown
  final List<String> repeatChoices = const [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];
  // the selected repeat intervals
  List<String> selectedRepeatInterval = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];
  bool isRepeatedEveryDay = true;

  // PARTICIPANTS
  List<PersonalInfo> participants = [];
  // List<Map<String, bool>> isSelectedParticipants = [];
  List<String> addedParticipants = [];
  bool isAllParticipantsSelected = true;

  /// Load participants from Database and add to participants list
  Future<void> loadParticipants() async {
    List<PersonalInfo> patientList =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();
    for (var patient in patientList) {
      // only add patients to participants list
      if (patient.userType.toUpperCase() == "PATIENT") {
        // add patient to participants list and isSelectedParticipants list
        participants.add(patient);
        addedParticipants.add(patient.userID);
        // // by default, all participants are selected
        // isSelectedParticipants.add({patient.userID: true});
      }
    }
    print(
      "LOADED PATIENTS LENGTHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH: ${participants.length}",
    );

    // sorts the participants List
    participants.sort((a, b) {
      return a.name.compareTo(b.name);
    });
  }

  @override
  void initState() {
    super.initState();
    loadParticipants();
    print(
      "LOADED PATIENTS LENGTHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH: ${participants.length}",
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: MyColorPalette.formColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MyDimensionAdapter.getWidth(context),
            // The height is only 0.9 not 1 because some parts of the screen is already occupied by SafeArea
            // height: (isAllParticipantsSelected)
            //     ? MyDimensionAdapter.getHeight(context) * 1.1
            //     : MyDimensionAdapter.getHeight(context) * 1.3,
            child: Column(
              children: [
                // APPBAR
                MyCustAppBar(
                  title: "Planner",
                  backButton: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    MyNavigator.goTo(context, HomeLifePlanner());
                  },
                  backButtonColor: Colors.blue.shade300,
                  actionButtons: [
                    MyCustTooltip(
                      message: "Hold the buttons to know what they are for.",
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),

                //
                MyCustTextfield(
                  labelText: "Title",
                  prefixIcon: Icons.title_rounded,
                  textController: titleController,
                  borderRadius: 7,
                  borderColor: MyColorPalette.borderColor,
                  activeBorderColor: MyColorPalette.borderColor,
                ),
                SizedBox(height: 10),

                //
                MyCustTextfield(
                  labelText: "Description",
                  prefixIcon: Icons.description_outlined,
                  textController: descriptionController,
                  borderRadius: 7,
                  borderColor: MyColorPalette.borderColor,
                  activeBorderColor: MyColorPalette.borderColor,
                ),
                SizedBox(height: 16),

                MyCustTooltip(
                  message: "What time the task should be executed?",
                  child: MyCustButton(
                    buttonText: (time == null)
                        ? "Select Time"
                        : time!.format(context),
                    buttonTextFontSize: kDefaultFontSize + 2,
                    borderRadius: 7,
                    color: MyColorPalette.formColor,
                    borderColor: MyColorPalette.borderColor,
                    buttonShadowColor: Colors.blue.shade200,
                    widthPercentage: 0.8,
                    buttonTextSpacing: 1,
                    onTap: () async {
                      TimeOfDay? tempTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() {
                        time = tempTime;
                      });

                      // This tells the system "Whatever is focused right now, please stop."
                      FocusManager.instance.primaryFocus?.unfocus();
                      print("TIMEEEEEEEEEE: $time");
                    },
                  ),
                ),
                SizedBox(height: 10),

                MyCustTooltip(
                  message: "How often the task should be repeated?",
                  child: repeatDropDown(context),
                ),
                SizedBox(height: 12),

                // FROM and UNTIL date buttons
                MyCustTooltip(
                  message:
                      "When the task should start [FROM] and when it approximately end [UNTIL]?",
                  child: dateButtons(context),
                ),
                SizedBox(height: 20),

                MyCustTooltip(
                  message: "Who are the participants involved in this task?",
                  child: participantsDropDown(context),
                ),

                // the space between the dropdown area and the buttons id proportional to whether all participants are selected or not (participantsArea is expanded).
                SizedBox(height: (!isAllParticipantsSelected) ? 40 : 60),

                saveAndCancelButtons(
                  onPressSave: () {
                    print("ADDED PARTICIPANTSssssssssssss: $addedParticipants");

                    saveExecution(context);
                  },
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column repeatDropDown(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MyDimensionAdapter.getWidth(context) * 0.8,
          height: MyDimensionAdapter.getHeight(context) * 0.07,
          decoration: BoxDecoration(
            // color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Card(
            margin: EdgeInsets.all(1),
            color: (isRepeatedEveryDay)
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
                side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                // overlayColor: WidgetStatePropertyAll(Colors.amber),
                // secondary: Icon(Icons.person_outline_rounded),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue.shade400,
                contentPadding: EdgeInsets.only(left: 5, right: 5),
                title: Text(
                  (isRepeatedEveryDay)
                      ? "Every Day"
                      : (selectedRepeatInterval.isEmpty)
                      ? "Please Select a Day"
                      : selectedRepeatInterval.join(", "),
                ),
                value: isRepeatedEveryDay,
                onChanged: (value) {
                  setState(() {
                    // if isRepeatedEveryDay (value) is true, clear selectedRepeatInterval list
                    if (isRepeatedEveryDay) {
                      selectedRepeatInterval.clear();
                    } else {
                      selectedRepeatInterval.addAll(repeatChoices);
                    }
                    isRepeatedEveryDay = value!;

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
          height: (!isRepeatedEveryDay)
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
            itemCount: repeatChoices.length,
            itemBuilder: (context, index) {
              return Card(
                // the logic in this margin is simple if the index is first or last item there will be a larger margin
                margin: (index == 0 || index == repeatChoices.length - 1)
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
                    title: Text(repeatChoices[index]),
                    // if selectedRepeatInterval contains the current choice, value is true
                    value: selectedRepeatInterval.contains(
                      repeatChoices[index],
                    ),
                    onChanged: (value) {
                      setState(() {
                        // if not yet added, add the day from the list
                        if (value! == true) {
                          selectedRepeatInterval.add(repeatChoices[index]);
                        }
                        // else, remove the day from selectedRepeatInterval list
                        else {
                          selectedRepeatInterval.remove(repeatChoices[index]);
                        }

                        // if all days are added, set isRepeatedEveryDay to true
                        if (selectedRepeatInterval.length ==
                            repeatChoices.length) {
                          isRepeatedEveryDay = true;
                        }
                        //// the else is not necessary because if not all days are selected, this area will be hidden right away
                        // else {
                        //   isRepeatedEveryDay = false;
                        // }
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

  SizedBox dateButtons(BuildContext context) {
    return SizedBox(
      width: MyDimensionAdapter.getWidth(context) * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyCustButton(
            buttonText: (fromDate == null)
                ? "FROM"
                : MyDateFormatter.formatDate(dateTimeInString: fromDate),
            borderRadius: 7,
            color: MyColorPalette.formColor,
            borderColor: MyColorPalette.borderColor,
            buttonShadowColor: Colors.blue.shade200,
            widthPercentage: 0.39,
            buttonTextSpacing: 1,
            onTap: () async {
              // This tells the system "Whatever is focused right now, please stop."
              FocusManager.instance.primaryFocus?.unfocus();

              DateTime? tempFromDate = await myDatePicker(context);

              // if tempDate is null, do nothing
              if (tempFromDate != null) {
                // if untilDate is null, still set fromDate value
                if (untilDate == null) {
                  setState(() {
                    fromDate = tempFromDate;
                  });
                }
                // tempFromDate cannot be before today
                else if (tempFromDate.isBefore(
                  DateTime.now().subtract(Duration(days: 1)),
                )) {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "The FROM date cannot be before today.",
                  );
                }
                // tempFromDate must be before untilDate (if untilDate has value)
                else if (tempFromDate.isBefore(untilDate!)) {
                  print("is BEFOREEEEEEEEEEEEEEEEE");
                  setState(() {
                    fromDate = tempFromDate;
                  });
                }
                // just a visual dialog saying you can't choose a date that is before FROM date
                else {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "FROM date must be before UNTIL date",
                  );
                }
              }
              // for debugging purposes only (deletable)
              print("FROM DATE CURRENT VALUE: $fromDate");
            },
          ),
          SizedBox(width: 7),
          MyCustButton(
            buttonText: (untilDate == null)
                ? "UNTIL"
                : MyDateFormatter.formatDate(dateTimeInString: untilDate),
            borderRadius: 7,
            color: MyColorPalette.formColor,
            borderColor: MyColorPalette.borderColor,
            buttonShadowColor: Colors.blue.shade200,
            widthPercentage: 0.39,
            buttonTextSpacing: 1,
            onTap: () async {
              // This tells the system "Whatever is focused right now, please stop."
              FocusManager.instance.primaryFocus?.unfocus();

              DateTime? tempUntilDate = await myDatePicker(context);
              // if tempDate is null, do nothing
              if (tempUntilDate != null) {
                print("tempUntilDate is NOT NULLLLLLLLLLLL");
                // if fromDate is null a snackbar will appear to ensure fromDate must be fillout first
                if (fromDate == null) {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "Please, fill out the FROM date first.",
                  );
                }
                // tempUntilDate cannot be before today
                else if (tempUntilDate.isBefore(DateTime.now())) {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "The UNTIL date cannot be before today.",
                  );
                }
                // tempUntilDate must be after fromDate (if fromDate has value)
                else if (tempUntilDate.isAfter(fromDate!)) {
                  print(
                    "TEMPUNTILDATE isAfter FROM DATEEEEEEEEEEEEEEEEEEEEEEEEEEE",
                  );
                  setState(() {
                    untilDate = tempUntilDate;
                  });
                }
                // just a visual dialog saying you can't choose a date that is before FROM date
                else {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "UNTIL date must be after FROM date",
                  );
                }
                // for debugging purposes only (deletable)
                print("UNTIL DATE CURRENT VALUE: $untilDate");
              }
            },
          ),
        ],
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
                side: BorderSide(color: Colors.blue.shade200, width: 1.5),
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

                    // print(
                    //   "PARTICIPANTS LENGTHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH: ${participants.length}",
                    // );
                    // print(
                    //   "ADDED PARTICIPANTS LENGTHHHHHHHHHHHHHHHHHHHHHHHHHHHHH: ${addedParticipants.length}",
                    // );

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

  Row saveAndCancelButtons({required VoidCallback onPressSave}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyCustButton(
          buttonText: "CANCEL",
          widthPercentage: 0.40,
          color: MyColorPalette.formColor,
          borderColor: Colors.transparent,
          enableShadow: false,
          buttonTextSpacing: 1,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        MyCustButton(
          buttonText: "SAVE",
          widthPercentage: 0.40,
          buttonTextFontSize: kDefaultFontSize + 1,
          buttonTextColor: Colors.white,
          buttonTextSpacing: 1,
          onTap: onPressSave,
        ),
      ],
    );
  }

  /// contains the execution logic when save button is pressed
  void saveExecution(BuildContext context) {
    // sort selectedRepeatInterval based on repeatChoices order
    setState(() {
      selectedRepeatInterval.sort((a, b) {
        return repeatChoices.indexOf(a) - repeatChoices.indexOf(b);
      });
    });

    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        time != null &&
        selectedRepeatInterval.isNotEmpty &&
        fromDate != null &&
        untilDate != null &&
        addedParticipants.isNotEmpty) {
      myAlertDialogue(
        context: context,
        alertTitle: "Confirm Save",
        alertContent: "Are you sure you want to save this task?",
        onApprovalPressed: () {
          HomeLifePlannerRepository.addTask(
            HomeLifePlannerModel(
              // taskID is left empty here, because it will be generated in repository
              taskID: '',
              taskName: titleController.text,
              taskDescription: descriptionController.text,
              participants: addedParticipants.join(','),
              repeatInterval: selectedRepeatInterval.join(','),
              time: time.toString(),
              fromDate: fromDate.toString(),
              untilDate: untilDate.toString(),
              createdAt: DateTime.now().toString(),
              createdBy: FirebaseAuth.instance.currentUser!.uid,
            ),
          );
          // removes the alert dialogue
          Navigator.pop(context);
          // to return to previous screen
          Navigator.pop(context);
          showMyAnimatedSnackBar(
            context: context,
            dataToDisplay: "The task has been saved successfully!",
          );
        },
      );
    } else {
      showMyAnimatedSnackBar(
        context: context,
        dataToDisplay: "Please, fill out all the required fields.",
      );
    }
  }
}
