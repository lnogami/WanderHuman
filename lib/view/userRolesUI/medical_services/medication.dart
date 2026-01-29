// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/medical_services_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/medication_model.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/view/components/date_picker.dart';
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/textfield.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication_history.dart';

class Medication extends StatefulWidget {
  /// This is for editing the Medication Form of a certain patient's medication record.
  final PersonalInfo? bufferedPatientInfo;
  final MedicationModel? medicationModel;
  final String? recordID;

  const Medication({
    super.key,
    this.bufferedPatientInfo,
    this.recordID,
    this.medicationModel,
  });

  @override
  State<Medication> createState() => _MedicationState();
}

class _MedicationState extends State<Medication> {
  // default values
  List<String> patientsNames = ["Please Select Patient"];
  String selectedNameValue = "";
  TextEditingController diagnosisController = TextEditingController();
  TextEditingController treatmentController = TextEditingController();
  Future<List<PersonalInfo>>? _patientsInfo;
  PersonalInfo? _selectedPatient;
  String fromDate = "";
  String untilDate = "";
  String dateTime = DateTime.now().toString();
  bool isNowOkay = false;

  /// only becomes true if a single info in this form is subject to change.
  /// this is only usable if the Medication widget is accessed through MedicationHistory widget.
  bool isAltered = false;

  // for User Experience enhancer
  IconData icon = Icons.person_outline_rounded;

  // timer
  Timer? timer;

  // database connector call
  Future<List<PersonalInfo>> getPatient() async {
    List<PersonalInfo> patients = [];
    List<PersonalInfo> fetchedRecords =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();
    for (var person in fetchedRecords) {
      if (person.userType == "Patient") {
        setState(() {
          patients.add(person);
          patientsNames.add(person.name);
        });
      }
    }
    return patients;
  }

  // Future<List<PersonalInfo>> getPatient() async {
  //   return MyPersonalInfoRepository.getAllPersonalInfoRecords(
  //     fieldToLookFor: "userType",
  //     fieldValue: "Patient",
  //   );
  // }

  // database connector call
  Future<void> getSpecificPatient(String name) async {
    List<PersonalInfo> fetchedRecords =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();
    for (var person in fetchedRecords) {
      if (person.name == name) {
        setState(() {
          _selectedPatient = person;
        });
      }
    }
  }

  // as of Dec 26, 2025,  not yet verified, I need to analyze this later
  void _checkForChanges() {
    // If there is no original model (New Record mode), we might not need this logic
    // or we treat everything as altered.
    if (widget.medicationModel == null) return;

    bool hasChanges = false;

    // 1. Check Diagnosis
    if (diagnosisController.text != widget.medicationModel!.diagnosis) {
      hasChanges = true;
    }
    // 2. Check Treatment
    else if (treatmentController.text != widget.medicationModel!.treatment) {
      hasChanges = true;
    }
    // 3. Check Boolean Toggle
    else if (isNowOkay != widget.medicationModel!.isNowOkay) {
      hasChanges = true;
    }
    // 4. Check Dates
    else if (fromDate != widget.medicationModel!.fromDate) {
      hasChanges = true;
    } else if (untilDate != widget.medicationModel!.untilDate) {
      hasChanges = true;
    }

    // Only call setState if the status actually changed to avoid infinite rebuilds
    if (isAltered != hasChanges) {
      setState(() {
        isAltered = hasChanges;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _patientsInfo = getPatient();

    // if bufferedPatientInfo and recordID is not null
    if (widget.bufferedPatientInfo != null &&
        widget.recordID != null &&
        widget.medicationModel != null) {
      setState(() {
        fromDate = widget.medicationModel!.fromDate;
        untilDate = widget.medicationModel!.untilDate;
        fromDateTimeFormat = DateTime.tryParse(fromDate);
        untilDateTimeFormat = DateTime.tryParse(untilDate);
        diagnosisController.text = widget.medicationModel!.diagnosis;
        treatmentController.text = widget.medicationModel!.treatment;
        isNowOkay = widget.medicationModel!.isNowOkay;
      });

      diagnosisController.addListener(_checkForChanges);
      treatmentController.addListener(_checkForChanges);
    }

    // Initialize timer only once when widget is created
    _initializeTimer();
  }

  void _initializeTimer() {
    int seconds = 5;
    timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      if (MyDateFormatter.formatDate(
            dateTimeInString: dateTime,
            formatOptions: 6,
          ) !=
          MyDateFormatter.formatDate(
            dateTimeInString: DateTime.now(),
            formatOptions: 6,
          )) {
        if (mounted) {
          setState(() {
            seconds = 60;
            dateTime = DateTime.now().toString();
          });
        }
        print("Timeeeeeeee: $dateTime");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    diagnosisController.dispose();
    treatmentController.dispose();
    diagnosisController.removeListener(_checkForChanges);
    treatmentController.removeListener(_checkForChanges);
    patientsNames.clear();
    selectedNameValue = "";
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColorPalette.formColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        // this is the main body of the Form
        child: Container(
          padding: EdgeInsets.only(bottom: 30),
          width: MyDimensionAdapter.getWidth(context),
          // decoration: const BoxDecoration(color: MyColorPalette.lightBlue),
          child: formSpace(context),
        ),
      ),
    );
  }

  Column formSpace(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SafeArea(
          child: MyCustAppBar(
            title: "Medication",
            color: const Color.fromARGB(160, 33, 149, 243),
            textColor: Colors.white,
            fontWeight: FontWeight.w600,
            backButton: () {
              Navigator.pop(context);
              // Navigator.pop(context);
              // MyNavigator.goTo(context, Medication());
            },
            backButtonColor: Colors.white70,
          ),
        ),
        SizedBox(height: 25),

        // acts as a header for the form
        dateTimeTimer(),

        // MyDateTimeTimerHeader(),
        (widget.bufferedPatientInfo == null)
            /// if bufferecPatientInfo is not null, it means this Medication widget is accesed from MedicationHistory widget.
            ? FutureBuilder(
                future: _patientsInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return MyDropdownMenuButton(
                      icon: Icon(icon, size: 32),
                      items: patientsNames,
                      initialValue: patientsNames[0],
                      hintText: "Select a Patient",
                      onChanged: (patient) {
                        if (patient != patientsNames[0]) {
                          setState(() {
                            icon = Icons.person_rounded;
                            print("PATIENT NAMEEEEE: $patient");
                            // assigns the _selectedPatient
                            getSpecificPatient(patient!);
                            selectedNameValue = patient;
                            // showMyAnimatedSnackBar(
                            //   context: context,
                            //   dataToDisplay: _selectedPatient!.name,
                            // );
                            print("SELECTED NAME VALUE: $selectedNameValue");
                          });
                        } else {
                          setState(() {
                            icon = Icons.person_outline_outlined;
                            selectedNameValue = patientsNames[0];
                            // _selectedPatient = null;
                            print("SELECTED NAME VALUE: $selectedNameValue");
                          });
                        }
                      },
                    );
                  }
                },
              )
            : MyCustTextfield(
                labelText: "Patient",
                prefixIcon: Icons.person_outline_rounded,
                textController: TextEditingController()
                  ..text = widget.bufferedPatientInfo!.name,
                isReadOnly: true,
                borderRadius: 7,
                borderColor: Colors.blueGrey.shade100,
                borderWidth: 1.5,
                activeBorderColor: Colors.blueGrey.shade100,
              ),

        SizedBox(height: 15),

        dateTimeArea(context),

        SizedBox(height: 25),

        MyCustTextfield(
          labelText: "Diagnosis",
          prefixIcon: Icons.info_outline_rounded,
          textController: diagnosisController,
          borderRadius: 7,
          borderColor: MyColorPalette.borderColor,
          activeBorderColor: MyColorPalette.borderColor,
        ),
        treatmentArea(context),

        SizedBox(height: 15),
        MyTextFormatter.p(
          text: (widget.bufferedPatientInfo != null)
              ? "${widget.bufferedPatientInfo?.name}'s Condition"
              : "Patient's Conditon",
          fontsize: kDefaultFontSize - 2.5,
        ),
        MyCustButton(
          buttonText: (isNowOkay == true)
              ? "Already in Good Condition"
              : "Not Yet Okay",
          onTap: () async {
            // by default, when registering a medication, it will be "Not Yet Okay".
            //             it can only be change if this is viewed from Med History
            if (widget.bufferedPatientInfo != null) {
              setState(() {
                isNowOkay = !isNowOkay;
                if (isNowOkay != widget.medicationModel!.isNowOkay) {
                  isAltered = true;
                } else {
                  isAltered = false;
                }
              });
            }
          },
          widthPercentage: 0.8,
          borderColor: (isNowOkay == true)
              ? MyColorPalette.borderColor
              : Colors.red.shade100,
          borderRadius: 7,
          color: (isNowOkay == true)
              ? MyColorPalette.formColor
              : Colors.red.shade50,
          buttonTextFontSize: kDefaultFontSize + 1,
          buttonTextSpacing: 1,
          buttonShadowColor: (isNowOkay == true)
              ? Colors.blue.shade200
              : Colors.red.shade300,
        ),

        SizedBox(height: 30),
        buttonArea(context),
      ],
    );
  }

  // for storing DateTime values
  DateTime? fromDateTimeFormat;
  DateTime? untilDateTimeFormat;
  // // for storing String DateTime value
  // String? from;
  Row dateTimeArea(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // From Date Button
        Column(
          children: [
            MyTextFormatter.p(
              text: "From When",
              fontsize: kDefaultFontSize - 2.5,
            ),
            MyCustButton(
              buttonText: (fromDate == "")
                  ? "From Date"
                  : MyDateFormatter.formatDate(dateTimeInString: fromDate),
              onTap: () async {
                // store a temporary original DateTime
                DateTime? pickedFromDate = await myDatePicker(
                  context,
                  initialYear: DateTime.now().year,
                );

                // naay na pick nga date
                if (pickedFromDate != null) {
                  setState(() {
                    fromDateTimeFormat = pickedFromDate;
                    isAltered = true;
                    // // then use it to format a Human Comprehensible date format
                    // from = MyDateFormatter.formatDate(
                    //   dateTimeInString: fromDateTimeFormat,
                    // );
                    print("pickedFromDate is not null: $pickedFromDate");
                    print("BEFORE DATE: $fromDateTimeFormat");
                  });

                  // this is if the Medication is access through Medication (not from MedicationHistory)
                  if (untilDateTimeFormat == null) {
                    setState(() {
                      fromDate = fromDateTimeFormat.toString();
                      isAltered = true;
                    });
                  } else {
                    if ((fromDateTimeFormat!.isAfter(untilDateTimeFormat!))) {
                      showMyAnimatedSnackBar(
                        context: context,
                        dataToDisplay:
                            "NOTICE: From Date must be before Until Date as it is the start of the medication durationn.",
                      );
                    }
                    // else if (untilDateTimeFormat != null) {
                    else {
                      setState(() {
                        fromDate = fromDateTimeFormat.toString();
                        isAltered = true;
                      });
                      print("TRUEEEEEEEEEEEEEEEEEEEEEEEEE else if");
                    }
                  }
                }
              },
              widthPercentage: 0.38,
              borderColor: MyColorPalette.borderColor,
              borderRadius: 7,
              color: MyColorPalette.formColor,
              buttonTextFontSize: kDefaultFontSize + 1,
              buttonTextSpacing: 1,
              buttonShadowColor: Colors.blue.shade200,
            ),
          ],
        ),

        SizedBox(width: 10),

        // Until Date Button
        Column(
          children: [
            MyTextFormatter.p(
              text: "Until When",
              fontsize: kDefaultFontSize - 2.5,
            ),
            // MyCustButton(
            //   buttonText: (untilDate == "")
            //       ? "Until When"
            //       : MyDateFormatter.formatDate(dateTimeInString: untilDate),
            //   onTap: () async {
            //     // store a temporary original DateTime
            //     DateTime? tempUntil = await myDatePicker(
            //       context,
            //       initialYear: DateTime.now().year,
            //     );

            //     // then put it in fromDateTimeFormat
            //     setState(() {
            //       untilDateTimeFormat = tempUntil;
            //     });

            //     print("UNTIL DATE: $untilDateTimeFormat");

            //     // finally, store the String formatted value to the field variable
            //     // untilDateTimeFormat must not be before fromDateTimeFormat

            //     if (fromDateTimeFormat == null) {
            //       showMyAnimatedSnackBar(
            //         context: context,
            //         dataToDisplay: "NOTICE: Fill out the From Date first.",
            //       );
            //     } else if (!(untilDateTimeFormat!.isBefore(
            //       fromDateTimeFormat!,
            //     ))) {
            //       print(
            //         "TRUEEEEEEEEEEEEEEEEEEEEEEEEE, error! untilDate is before fromDate",
            //       );
            //       setState(() {
            //         untilDate = untilDateTimeFormat.toString();
            //         isAltered = true;
            //       });
            //     } else {
            //       showMyAnimatedSnackBar(
            //         context: context,
            //         dataToDisplay:
            //             "NOTICE: Until Date must not be before From Date as it is the end duration of medication.",
            //       );
            //       setState(() {
            //         untilDate = "Until When";
            //       });
            //     }
            //   },
            //   widthPercentage: 0.38,
            //   borderColor: MyColorPalette.borderColor,
            //   borderRadius: 7,
            //   color: MyColorPalette.formColor,
            //   buttonTextFontSize: kDefaultFontSize + 1,
            //   buttonTextSpacing: 1,
            //   buttonShadowColor: Colors.blue.shade200,
            // ),
            MyCustButton(
              buttonText: (untilDate == "")
                  ? "Until Date"
                  : MyDateFormatter.formatDate(dateTimeInString: untilDate),
              onTap: () async {
                // store a temporary original DateTime
                DateTime? pickedUntilDate = await myDatePicker(
                  context,
                  initialYear: DateTime.now().year,
                );

                // naay na pick nga date
                if (pickedUntilDate != null) {
                  setState(() {
                    untilDateTimeFormat = pickedUntilDate;
                    isAltered = true;
                    // // then use it to format a Human Comprehensible date format
                    // from = MyDateFormatter.formatDate(
                    //   dateTimeInString: fromDateTimeFormat,
                    // );
                    print(
                      "untilDateTimeFormat is not null: $untilDateTimeFormat",
                    );
                    print("UNTIL DATE: $untilDateTimeFormat");
                  });

                  if ((untilDateTimeFormat!.isBefore(fromDateTimeFormat!))) {
                    showMyAnimatedSnackBar(
                      context: context,
                      dataToDisplay:
                          "NOTICE: From Date must be after From Date as it is the end of the medication duration.",
                    );
                  } else if (fromDateTimeFormat == null) {
                    showMyAnimatedSnackBar(
                      context: context,
                      dataToDisplay: "NOTICE: Fill out the From Date first.",
                    );
                  } else {
                    setState(() {
                      untilDate = untilDateTimeFormat.toString();
                      isAltered = true;
                    });
                    print("TRUEEEEEEEEEEEEEEEEEEEEEEEEE else");
                  }
                }
              },
              widthPercentage: 0.38,
              borderColor: MyColorPalette.borderColor,
              borderRadius: 7,
              color: MyColorPalette.formColor,
              buttonTextFontSize: kDefaultFontSize + 1,
              buttonTextSpacing: 1,
              buttonShadowColor: Colors.blue.shade200,
            ),
          ],
        ),
      ],
    );
  }

  Column treatmentArea(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MyDimensionAdapter.getWidth(context) * 0.8,
          height: MyDimensionAdapter.getHeight(context) * 0.12,
          margin: EdgeInsets.only(top: 10),
          child: TextField(
            // if expand is true, maxlines or minLines must be null
            maxLines: null,
            expands: true,
            controller: treatmentController,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              filled: true,
              contentPadding: const EdgeInsets.only(
                top: 3,
                right: 3,
                bottom: 5,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.zoom_out_rounded),
              ),
              label: Text(
                "Treatment",
                style: TextStyle(fontSize: kDefaultFontSize + 2),
              ),
              prefixIconConstraints: BoxConstraints.tight(Size(50, 32)),
              prefixIconColor: Colors.grey,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: MyColorPalette.borderColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: MyColorPalette.borderColor,
                  width: 2.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container dateTimeTimer() {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.85,
      margin: EdgeInsets.only(bottom: 30),
      padding: EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.all(Radius.circular(7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              MyTextFormatter.p(
                text: "Today is ",
                fontsize: kDefaultFontSize + 1,
              ),
              MyTextFormatter.p(
                text: MyDateFormatter.formatDate(
                  dateTimeInString: DateTime.now(),
                  formatOptions: 7,
                  customedFormat: "EEEE",
                ),
                fontsize: kDefaultFontSize + 7,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade500,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              MyTextFormatter.p(
                text: MyDateFormatter.formatDate(
                  dateTimeInString: dateTime,
                  formatOptions: 7,
                  customedFormat: "MMM d",
                ),
                fontsize: kDefaultFontSize + 5,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade400,
              ),
              MyTextFormatter.p(text: ", "),
              MyTextFormatter.p(
                text:
                    "${MyDateFormatter.formatDate(dateTimeInString: dateTime, formatOptions: 7, customedFormat: "y")}  ",
                fontsize: kDefaultFontSize + 2,
                // color: Colors.blue.shade400,
              ),
              MyTextFormatter.p(
                text:
                    "${MyDateFormatter.formatDate(dateTimeInString: dateTime, formatOptions: 7, customedFormat: "hh:mm")} ",
                fontsize: kDefaultFontSize + 5,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade400,
              ),
              MyTextFormatter.p(
                text:
                    "${MyDateFormatter.formatDate(dateTimeInString: dateTime, formatOptions: 7, customedFormat: "a")} ",
                fontsize: kDefaultFontSize + 2,
                // color: Colors.blue.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // This is where the two buttons are located
  SizedBox buttonArea(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cancelButton(context),

          SizedBox(width: 10),

          //    SAVE BUTTON   (if no patient is provided)
          //    UPDATE BUTTON (if patient is explicitly provided, which also means, this widget is accessed from MedicaitonHistory widget)
          // if bufferecPatientInfo is not null, it means this Medication widget is accesed from MedicationHistory widget.
          (widget.bufferedPatientInfo == null)
              ? MyCustButton(
                  buttonText: "Save",
                  buttonTextColor: Colors.white,
                  buttonTextFontSize: 18,
                  buttonTextSpacing: 1.2,
                  buttonWidth: MyDimensionAdapter.getWidth(context) * 0.40,
                  onTap: () {
                    if (selectedNameValue != patientsNames[0] &&
                        diagnosisController.text != "" &&
                        treatmentController.text != "" &&
                        fromDate != "" &&
                        untilDate != "" &&
                        diagnosisController.text != "" &&
                        treatmentController.text != "") {
                      myAlertDialogue(
                        context: context,
                        alertTitle: "Confirm to Save",
                        alertContent: "Please press to continue",
                        onApprovalPressed: () {
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay: "Saving..",
                          );
                          MyMedicalRepository.addRecord(
                            MedicationModel(
                              // recordID: "",
                              patientID: _selectedPatient!.userID,
                              diagnosis: diagnosisController.text,
                              treatment: treatmentController.text,
                              medic: FirebaseAuth.instance.currentUser!.uid,
                              fromDate: fromDate,
                              untilDate: untilDate,
                              isNowOkay: false,
                              createdAt: DateTime.now().toString(),
                            ),
                          );
                          // removes the dialog box
                          Navigator.pop(context);
                          // removes the Medication Page
                          Navigator.pop(context);
                          // goes to the MedicationHistory Page after saving an entry
                          MyNavigator.goTo(context, MedicalHistory());
                          // print(
                          //   "ADDEDDDDDDDDDDDDDD: userID: ${_selectedPatient?.userID},  name: ${_selectedPatient?.name},  diagnosis: ${diagnosisController.text},  treatment: ${treatmentController.text}, medic: ${FirebaseAuth.instance.currentUser!.uid}",
                          // );
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay: "Done..",
                          );
                          // Navigator.pop(context);
                          // }
                        },
                      );
                    } else {
                      showMyAnimatedSnackBar(
                        context: context,
                        bgColor: Colors.white70,
                        dataToDisplay:
                            "Please fill out all the required fields.",
                      );
                    }
                  },
                )
              : MyCustButton(
                  buttonText: "Update",
                  buttonTextColor: Colors.white,
                  buttonTextFontSize: 18,
                  buttonTextSpacing: 1.2,
                  color: (isAltered) ? Colors.blue : Colors.grey.shade400,
                  buttonShadowColor: (isAltered)
                      ? Colors.blue
                      : Colors.grey.shade600,
                  buttonWidth: MyDimensionAdapter.getWidth(context) * 0.40,
                  onTap: () {
                    if (isAltered) {
                      myAlertDialogue(
                        context: context,
                        alertContent: "Are you sure about these changes?",
                        onApprovalPressed: () {
                          MyMedicalRepository.updateRecord(
                            // NA means not applicable (not editable)
                            record: MedicationModel(
                              // recordID: "",
                              patientID:
                                  widget.bufferedPatientInfo!.userID, // NA
                              diagnosis: diagnosisController.text,
                              treatment: treatmentController.text,
                              medic:
                                  FirebaseAuth.instance.currentUser!.uid, // NA
                              fromDate: fromDate,
                              untilDate: DateTime.now().toString(),
                              isNowOkay: isNowOkay,
                              createdAt:
                                  widget.medicationModel!.createdAt, // NA
                            ),
                            recordID: widget.recordID!,
                          );
                          Future.delayed(const Duration(milliseconds: 800), () {
                            // removes the dialog box
                            Navigator.pop(context);
                            // removes the Medication Page
                            Navigator.pop(context);
                            // removes the MedicationHistory Page
                            Navigator.pop(context);
                            // reloads the MedicationHistory Page
                            MyNavigator.goTo(context, MedicalHistory());
                          });
                          // print(
                          //   "ADDEDDDDDDDDDDDDDD: userID: ${_selectedPatient?.userID},  name: ${_selectedPatient?.name},  diagnosis: ${diagnosisController.text},  treatment: ${treatmentController.text}, medic: ${FirebaseAuth.instance.currentUser!.uid}",
                          // );
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay: "Done..",
                          );
                        },
                      );
                    }
                    // Navigator.pop(context);
                    // }
                  },
                ),
        ],
      ),
    );
  }

  // Just a form Cancelation button, nothing else
  GestureDetector cancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // Navigator.pop(context);
        // MyNavigator.goTo(context, const Medication());
      },
      child: SizedBox(
        width: MyDimensionAdapter.getWidth(context) * 0.30,
        child: Center(child: Text("Cancel", style: TextStyle(fontSize: 16))),
      ),
    );
  }
}
