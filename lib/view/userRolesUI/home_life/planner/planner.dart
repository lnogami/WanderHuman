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
import 'package:wanderhuman_app/utilities/properties/time_of_day_formater.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/date_picker.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/planner/manage_tasks.dart';

class HomeLifePlanner extends StatefulWidget {
  final HomeLifePlannerModel? plannedTask;
  const HomeLifePlanner({super.key, this.plannedTask});

  @override
  State<HomeLifePlanner> createState() => _HomeLifePlannerState();
}

class _HomeLifePlannerState extends State<HomeLifePlanner> {
  // CONTROLLS WRITE/EDIT ACCESS OF THE FORM
  bool isEditable = true;
  Color notEditableColor = Colors.grey.shade300;
  String bufferedStaffName = ""; // not yet implemented

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

  /// Only works if plannedTask is provided
  /// This will initialize the planner variable if planneTask is provided.
  Future<void> initializePlannedTask() async {
    if (widget.plannedTask != null) {
      isEditable = false;
      titleController.text = widget.plannedTask!.taskName;
      descriptionController.text = widget.plannedTask!.taskDescription;
      fromDate = DateTime.parse(widget.plannedTask!.fromDate); //
      untilDate = DateTime.parse(widget.plannedTask!.untilDate);
      time = MyTimeFormatter.stringToTimeOfDay(widget.plannedTask!.time);
      selectedRepeatInterval = widget.plannedTask!.repeatInterval.split(",");
      addedParticipants = widget.plannedTask!.participants.split(",");

      bufferedStaffName = (await getStaffName(
        widget.plannedTask!.createdBy,
      )).join(","); // await the async call

      // this will make the paricipants dropdown expand
      if (addedParticipants.length != participants.length) {
        isAllParticipantsSelected = false;
      }
    }
    setState(() {});
  }

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

    // notify the framework that participants have been loaded so the UI can rebuild
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // load participants first, then initialize the planned task so
    // initialization logic can rely on the participants list
    loadParticipants().then((_) {
      initializePlannedTask();
      // ensure the UI reflects initialized values
      if (mounted) setState(() {});
    });

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
                appbar(context),
                SizedBox(height: 40),

                //
                MyCustTextfield(
                  labelText: "Title",
                  prefixIcon: Icons.title_rounded,
                  textController: titleController,
                  borderRadius: 7,
                  borderColor: (isEditable)
                      ? MyColorPalette.borderColor
                      : notEditableColor,
                  activeBorderColor: (isEditable)
                      ? MyColorPalette.borderColor
                      : notEditableColor,
                  isReadOnly: !isEditable,
                ),
                SizedBox(height: 10),

                //
                MyCustTextfield(
                  labelText: "Description",
                  prefixIcon: Icons.description_outlined,
                  textController: descriptionController,
                  borderRadius: 7,
                  borderColor: (isEditable)
                      ? MyColorPalette.borderColor
                      : notEditableColor,
                  activeBorderColor: (isEditable)
                      ? MyColorPalette.borderColor
                      : notEditableColor,
                  isReadOnly: !isEditable,
                ),
                SizedBox(height: 16),

                MyCustTooltip(
                  message: "What time the task should be executed?",
                  child: timeButton(context),
                ),
                SizedBox(height: 10),

                (isEditable)
                    ? MyCustTooltip(
                        message: "How often the task should be repeated?",
                        child: repeatDropDown(context),
                      )
                    : notEditableDisplay(
                        context,
                        text: selectedRepeatInterval.join(", "),
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
                // MyCustTooltip(
                //   message: "Who are the participants involved in this task?",
                //   child: (isEditable)
                //       ? participantsDropDown(context)
                //       : notEditableDisplay(
                //           context,
                //           text: addedParticipants.join(", "),
                //         ),
                // ),

                // the space between the dropdown area and the buttons id proportional to whether all participants are selected or not (participantsArea is expanded).
                SizedBox(height: (!isAllParticipantsSelected) ? 40 : 60),

                saveAndCancelButtons(
                  onPressSave: () {
                    print("ADDED PARTICIPANTSssssssssssss: $addedParticipants");

                    saveExecution(context);
                  },
                ),
                (widget.plannedTask != null) ? footer() : SizedBox(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  MyCustAppBar appbar(BuildContext context) {
    return MyCustAppBar(
      title: "Planner",
      backButton: () {
        Navigator.pop(context);
        Navigator.pop(context);
        MyNavigator.goTo(
          context,
          HomeLifePlanner(plannedTask: widget.plannedTask),
        );
      },
      backButtonColor: Colors.blue.shade300,
      actionButtons: [
        MyCustTooltip(
          message: "Hold the buttons to know what they are for.",
          child: Icon(Icons.info_outline_rounded, color: Colors.grey.shade400),
        ),
        (widget.plannedTask != null)
            ? MyCustTooltip(
                message: "Tap to edit the task",
                child: IconButton(
                  onPressed: () {
                    // permission previlige, you can't edit this task because you are not the one who created this.
                    if (FirebaseAuth.instance.currentUser!.uid ==
                        widget.plannedTask!.createdBy) {
                      setState(() {
                        isEditable = !isEditable;
                      });
                    } else {
                      showMyAnimatedSnackBar(
                        context: context,
                        dataToDisplay:
                            "You don't have permission to edit this task. Ask the creator [$bufferedStaffName] to edit it.",
                      );
                    }
                  },
                  icon: Icon(
                    (isEditable) ? Icons.draw_rounded : Icons.draw_outlined,
                    color: (isEditable)
                        ? Colors.blue.shade400
                        : Colors.grey.shade400,
                    size: (isEditable) ? 32 : 24,
                  ),
                ),
              )
            : SizedBox(),
        // to limit the right padding of the action buttons if there are two of them
        SizedBox(width: (widget.plannedTask != null) ? 5 : 15),
      ],
    );
  }

  Container notEditableDisplay(
    BuildContext context, {
    required String text,
    double widthPercentage = 0.8,
  }) {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * widthPercentage,
      height: MyDimensionAdapter.getHeight(context) * 0.065,
      decoration: BoxDecoration(
        color: Colors.white60,
        border: Border.all(color: notEditableColor, width: 1.5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Center(child: MyTextFormatter.p(text: text)),
    );
  }

  MyCustButton timeButton(BuildContext context) {
    return MyCustButton(
      buttonText: (time == null) ? "Select Time" : time!.format(context),
      buttonTextFontSize: kDefaultFontSize + 2,
      borderRadius: 7,
      color: MyColorPalette.formColor,
      borderColor: (isEditable) ? MyColorPalette.borderColor : notEditableColor,
      buttonShadowColor: (isEditable) ? Colors.blue.shade200 : notEditableColor,
      widthPercentage: 0.8,
      buttonTextSpacing: 1,
      onTap: () async {
        if (isEditable) {
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
        }
      },
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
          // if plannedTask is not provided it is editable, else not editable
          (widget.plannedTask == null)
              ? MyCustButton(
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
                    DateTime? tempFromDate = await myDatePicker(context);

                    // This tells the system "Whatever is focused right now, please stop."
                    // This one should be after an await call to work properly.
                    FocusManager.instance.primaryFocus?.unfocus();

                    // if tempDate is null, do nothing
                    if (tempFromDate != null) {
                      // tempFromDate cannot be before today
                      if (tempFromDate.isBefore(
                        DateTime.now().subtract(Duration(days: 1)),
                      )) {
                        showMyAnimatedSnackBar(
                          // ignore: use_build_context_synchronously
                          context: context,
                          dataToDisplay:
                              "The FROM date cannot be before today.",
                        );
                      }
                      // if untilDate is null, still set fromDate value
                      else if (untilDate == null) {
                        setState(() {
                          fromDate = tempFromDate;
                        });
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
                )
              : notEditableDisplay(
                  context,
                  text: MyDateFormatter.formatDate(
                    dateTimeInString: fromDate.toString(),
                  ),
                  widthPercentage: 0.38,
                ),
          SizedBox(width: 7),

          (isEditable)
              ? MyCustButton(
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
                    DateTime? tempUntilDate = await myDatePicker(context);

                    // This tells the system "Whatever is focused right now, please stop."
                    // This one should be after an await call to work properly.
                    FocusManager.instance.primaryFocus?.unfocus();

                    // if tempDate is null, do nothing
                    if (tempUntilDate != null) {
                      print("tempUntilDate is NOT NULLLLLLLLLLLL");
                      // if fromDate is null a snackbar will appear to ensure fromDate must be fillout first
                      if (fromDate == null) {
                        showMyAnimatedSnackBar(
                          context: context,
                          dataToDisplay:
                              "Please, fill out the FROM date first.",
                        );
                      }
                      // tempUntilDate cannot be before today
                      else if (tempUntilDate.isBefore(DateTime.now())) {
                        showMyAnimatedSnackBar(
                          context: context,
                          dataToDisplay:
                              "The UNTIL date cannot be before today.",
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
                )
              : notEditableDisplay(
                  context,
                  text: MyDateFormatter.formatDate(
                    dateTimeInString: untilDate.toString(),
                  ),
                  widthPercentage: 0.38,
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
                side: BorderSide(
                  color: (isEditable)
                      ? Colors.blue.shade200
                      : Colors.grey.shade400,
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
                  // this prevents execution if it is not editable
                  if (isEditable) {
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
                  }
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
                    side: BorderSide(
                      color: (isEditable)
                          ? Colors.blue.shade200
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
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
                      if (isEditable) {
                        setState(() {
                          // if already added, remove from addedParticipants list
                          if (addedParticipants.contains(
                            participants[index].userID,
                          )) {
                            addedParticipants.remove(
                              participants[index].userID,
                            );
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
                      }
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
          buttonText: (widget.plannedTask == null) ? "SAVE" : "UPDATE",
          widthPercentage: 0.40,
          buttonTextFontSize: kDefaultFontSize + 1,
          buttonTextColor: Colors.white,
          color: (isEditable) ? Colors.blue : Colors.grey.shade400,
          buttonShadowColor: (isEditable) ? Colors.blue : Colors.grey,
          buttonTextSpacing: 1,
          onTap: (isEditable) ? onPressSave : () {},
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
        alertTitle: (widget.plannedTask == null)
            ? "Confirm Save"
            : "Confirm Update",
        alertContent: (widget.plannedTask == null)
            ? "Are you sure you want to save this task?"
            : "Are you sure about this update you have made?",
        onApprovalPressed: () {
          if (widget.plannedTask != null) {
            HomeLifePlannerRepository.editTask(
              taskID: widget.plannedTask!.taskID,
              planner: HomeLifePlannerModel(
                taskID: widget.plannedTask!.taskID,
                taskName: titleController.text,
                taskDescription: descriptionController.text,
                participants: addedParticipants.join(','),
                repeatInterval: selectedRepeatInterval.join(','),
                time: MyTimeFormatter.timeOfDayToString(time!),
                fromDate: fromDate.toString(),
                untilDate: untilDate.toString(),
                createdAt: widget.plannedTask!.createdAt,
                createdBy: widget.plannedTask!.createdBy,
              ),
            );
          } else {
            HomeLifePlannerRepository.addTask(
              HomeLifePlannerModel(
                // taskID is left empty here, because it will be generated in repository
                taskID: '',
                taskName: titleController.text,
                taskDescription: descriptionController.text,
                participants: addedParticipants.join(','),
                repeatInterval: selectedRepeatInterval.join(','),
                time: MyTimeFormatter.timeOfDayToString(time!),
                fromDate: fromDate.toString(),
                untilDate: untilDate.toString(),
                createdAt: DateTime.now().toString(),
                createdBy: FirebaseAuth.instance.currentUser!.uid,
              ),
            );
          }
          // removes the alert dialogue
          Navigator.pop(context);
          // removes this screen
          Navigator.pop(context);
          // removes the previous screen to simulate a refreshing page
          Navigator.pop(context);
          // to return to previous screen
          MyNavigator.goTo(context, HomeLifeManageTask());
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

  // personal ID hash to personal name converter
  Future<List<String>> getStaffName(String names) async {
    // to store the staff names
    List<String> staffNames = [];
    // split all the id by ,
    List<String> personalIDs = names.split(",");
    for (String personalID in personalIDs) {
      PersonalInfo staff =
          await MyPersonalInfoRepository.getSpecificPersonalInfo(
            userID: personalID,
          );
      // then add all the names to staffNames list
      staffNames.add(staff.name);
      print("STAFF NAMEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: ${staff.name}");
    }
    return staffNames;
  }

  Column footer() {
    return Column(
      children: [
        SizedBox(height: 45),
        MyTextFormatter.p(
          text: "Created by: $bufferedStaffName",
          fontsize: kDefaultFontSize - 2,
          color: Colors.grey.shade600,
        ),
      ],
    );
  }
}
