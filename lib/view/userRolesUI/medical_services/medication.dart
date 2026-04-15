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
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/textfield.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication_history.dart';

class Medication extends StatefulWidget {
  final PersonalInfo? bufferedPatientInfo;
  final MedicationModel? medicationModel;
  final String? recordID;
  final bool isAccessedByMedicalStaff;

  const Medication({
    super.key,
    this.bufferedPatientInfo,
    this.recordID,
    this.medicationModel,
    this.isAccessedByMedicalStaff = false,
  });

  @override
  State<Medication> createState() => _MedicationState();
}

class _MedicationState extends State<Medication> {
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
  bool isAltered = false;
  IconData icon = Icons.person_outline_rounded;
  Timer? timer;
  int numberOfDaysValidForEditing = 14;

  bool isValidForEditing() {
    if (widget.medicationModel == null) return true;
    DateTime creationDate = DateTime.parse(widget.medicationModel!.createdAt);
    DateTime expirationDate = creationDate.add(
      Duration(days: numberOfDaysValidForEditing),
    );
    return expirationDate.isAfter(DateTime.now());
  }

  bool get canEdit => widget.isAccessedByMedicalStaff && isValidForEditing();

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

  void _checkForChanges() {
    if (widget.medicationModel == null) return;
    bool hasChanges = false;
    if (diagnosisController.text != widget.medicationModel!.diagnosis) {
      hasChanges = true;
    } else if (treatmentController.text != widget.medicationModel!.treatment) {
      hasChanges = true;
    } else if (isNowOkay != widget.medicationModel!.isNowOkay) {
      hasChanges = true;
    } else if (fromDate != widget.medicationModel!.fromDate) {
      hasChanges = true;
    } else if (untilDate != widget.medicationModel!.untilDate) {
      hasChanges = true;
    }

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
        child: Container(
          padding: const EdgeInsets.only(bottom: 30),
          width: MyDimensionAdapter.getWidth(context),
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
            backButton: () => Navigator.pop(context),
            backButtonColor: Colors.white70,
          ),
        ),
        const SizedBox(height: 25),

        if (widget.bufferedPatientInfo == null) ...[
          dateTimeTimer(),
          MyLine(
            length: MyDimensionAdapter.getWidth(context) * 0.85,
            color: Colors.grey.shade400,
            isVertical: false,
            isRounded: true,
            margin: 20,
          ),
        ],

        const SizedBox(height: 10),

        (widget.bufferedPatientInfo == null)
            ? FutureBuilder(
                future: _patientsInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                            getSpecificPatient(patient!);
                            selectedNameValue = patient;
                          });
                        } else {
                          setState(() {
                            icon = Icons.person_outline_outlined;
                            selectedNameValue = patientsNames[0];
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

        const SizedBox(height: 15),
        dateTimeArea(context),
        const SizedBox(height: 25),

        MyCustTextfield(
          labelText: "Diagnosis",
          prefixIcon: Icons.info_outline_rounded,
          textController: diagnosisController,
          borderRadius: 7,
          isReadOnly: !canEdit,
          borderColor: canEdit
              ? MyColorPalette.borderColor
              : Colors.grey.shade400,
          activeBorderColor: canEdit
              ? MyColorPalette.borderColor
              : Colors.grey.shade400,
        ),
        treatmentArea(context),

        const SizedBox(height: 15),
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
          onTap: canEdit
              ? () {
                  setState(() {
                    isNowOkay = !isNowOkay;
                    if (widget.medicationModel != null) {
                      isAltered =
                          (isNowOkay != widget.medicationModel!.isNowOkay);
                    } else {
                      isAltered = true;
                    }
                  });
                }
              : () {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay:
                        "This record is locked or you do not have permission to edit.",
                    bgColor: Colors.white,
                  );
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

        const SizedBox(height: 30),
        if (widget.isAccessedByMedicalStaff) buttonArea(context),
      ],
    );
  }

  DateTime? fromDateTimeFormat;
  DateTime? untilDateTimeFormat;

  Row dateTimeArea(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
              onTap: canEdit
                  ? () async {
                      late DateTime? pickedFromDate;

                      if (widget.bufferedPatientInfo == null &&
                          widget.medicationModel == null) {
                        pickedFromDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDate: DateTime.now(),
                        );
                      } else {
                        pickedFromDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDate:
                              DateTime.tryParse(
                                widget.medicationModel!.fromDate,
                              ) ??
                              DateTime.now(),
                        );
                      }

                      if (pickedFromDate != null) {
                        setState(() {
                          fromDateTimeFormat = pickedFromDate;
                          isAltered = true;
                        });

                        if (untilDateTimeFormat == null) {
                          setState(() {
                            fromDate = fromDateTimeFormat.toString();
                          });
                        } else {
                          if (fromDateTimeFormat!.isAfter(
                            untilDateTimeFormat!,
                          )) {
                            showMyAnimatedSnackBar(
                              context: context,
                              dataToDisplay:
                                  "NOTICE: From Date must be before Until Date as it is the start of the medication duration.",
                            );
                          } else {
                            setState(() {
                              fromDate = fromDateTimeFormat.toString();
                            });
                          }
                        }
                      }
                    }
                  : () {
                      showMyAnimatedSnackBar(
                        context: context,
                        dataToDisplay: "This record is locked.",
                      );
                    },
              widthPercentage: 0.38,
              borderColor: canEdit
                  ? MyColorPalette.borderColor
                  : Colors.grey.shade400,
              borderRadius: 7,
              color: MyColorPalette.formColor,
              buttonTextFontSize: kDefaultFontSize + 1,
              buttonTextSpacing: 1,
              enableShadow: canEdit,
              buttonShadowColor: canEdit
                  ? Colors.blue.shade200
                  : Colors.transparent,
            ),
          ],
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            MyTextFormatter.p(
              text: "Until When",
              fontsize: kDefaultFontSize - 2.5,
            ),
            MyCustButton(
              buttonText: (untilDate == "")
                  ? "Until Date"
                  : MyDateFormatter.formatDate(dateTimeInString: untilDate),
              onTap: canEdit
                  ? () async {
                      late DateTime? pickedUntilDate;

                      if (widget.bufferedPatientInfo == null &&
                          widget.medicationModel == null) {
                        pickedUntilDate = await showDatePicker(
                          context: context,
                          firstDate: fromDateTimeFormat ?? DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                          initialDate: DateTime.now(),
                        );
                      } else {
                        pickedUntilDate = await showDatePicker(
                          context: context,
                          firstDate: fromDateTimeFormat ?? DateTime.now(),
                          lastDate: DateTime.now(),
                          initialDate:
                              DateTime.tryParse(
                                widget.medicationModel!.untilDate,
                              ) ??
                              DateTime.now(),
                        );
                      }

                      if (pickedUntilDate != null) {
                        setState(() {
                          untilDateTimeFormat = pickedUntilDate;
                          isAltered = true;
                        });

                        if (untilDateTimeFormat!.isBefore(
                          fromDateTimeFormat!,
                        )) {
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay:
                                "NOTICE: Until Date must be after From Date.",
                          );
                        } else if (fromDateTimeFormat == null) {
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay:
                                "NOTICE: Fill out the From Date first.",
                          );
                        } else {
                          setState(() {
                            untilDate = untilDateTimeFormat.toString();
                          });
                        }
                      }
                    }
                  : () {
                      showMyAnimatedSnackBar(
                        context: context,
                        dataToDisplay: "This record is locked.",
                      );
                    },
              widthPercentage: 0.38,
              borderColor: canEdit
                  ? MyColorPalette.borderColor
                  : Colors.grey.shade400,
              borderRadius: 7,
              color: MyColorPalette.formColor,
              buttonTextFontSize: kDefaultFontSize + 1,
              buttonTextSpacing: 1,
              enableShadow: canEdit,
              buttonShadowColor: canEdit
                  ? Colors.blue.shade200
                  : Colors.transparent,
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
          margin: const EdgeInsets.only(top: 10),
          child: TextField(
            readOnly: !canEdit,
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
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.zoom_out_rounded),
              ),
              label: Text(
                "Treatment",
                style: TextStyle(fontSize: kDefaultFontSize + 2),
              ),
              prefixIconConstraints: BoxConstraints.tight(const Size(50, 32)),
              prefixIconColor: Colors.grey,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: canEdit
                      ? MyColorPalette.borderColor
                      : Colors.grey.shade400,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: canEdit
                      ? MyColorPalette.borderColor
                      : Colors.grey.shade400,
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
      padding: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.all(Radius.circular(7)),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox buttonArea(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cancelButton(context),
          const SizedBox(width: 10),
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
                        untilDate != "") {
                      myAlertDialogue(
                        context: context,
                        alertTitle: "Confirm to Save",
                        alertContent:
                            "Confirming will save this record to the database.",
                        onApprovalPressed: () {
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay: "Saving..",
                          );
                          MyMedicalRepository.addRecord(
                            MedicationModel(
                              patientID: _selectedPatient!.userID,
                              diagnosis: diagnosisController.text,
                              treatment: treatmentController.text,
                              medic: FirebaseAuth.instance.currentUser!.uid,
                              fromDate: fromDate,
                              untilDate: untilDate,
                              isNowOkay: isNowOkay,
                              createdAt: DateTime.now().toString(),
                            ),
                          );
                          Navigator.pop(context);
                          Navigator.pop(context);
                          MyNavigator.goTo(context, const MedicalHistory());
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay: "Successfully saved!",
                          );
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
                  color: (isAltered && canEdit)
                      ? Colors.blue
                      : Colors.grey.shade400,
                  buttonShadowColor: (isAltered && canEdit)
                      ? Colors.blue
                      : Colors.grey.shade600,
                  buttonWidth: MyDimensionAdapter.getWidth(context) * 0.40,
                  onTap: canEdit
                      ? () {
                          if (isAltered) {
                            myAlertDialogue(
                              context: context,
                              alertTitle: "Confirm to Update",
                              alertContent: "Are you sure about these changes?",
                              onApprovalPressed: () {
                                MyMedicalRepository.updateRecord(
                                  record: MedicationModel(
                                    patientID:
                                        widget.bufferedPatientInfo!.userID,
                                    diagnosis: diagnosisController.text,
                                    treatment: treatmentController.text,
                                    medic:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    fromDate: fromDate,
                                    untilDate: untilDate,
                                    isNowOkay: isNowOkay,
                                    createdAt:
                                        widget.medicationModel!.createdAt,
                                  ),
                                  recordID: widget.recordID!,
                                );
                                Future.delayed(
                                  const Duration(milliseconds: 800),
                                  () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    MyNavigator.goTo(
                                      context,
                                      const MedicalHistory(),
                                    );
                                  },
                                );
                                showMyAnimatedSnackBar(
                                  context: context,
                                  dataToDisplay: "Successfully updated..",
                                );
                              },
                            );
                          }
                        }
                      : () {
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay:
                                "Sorry, editing is only allowed within $numberOfDaysValidForEditing days after the record creation.",
                            bgColor: Colors.white70,
                          );
                        },
                ),
        ],
      ),
    );
  }

  GestureDetector cancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: SizedBox(
        width: MyDimensionAdapter.getWidth(context) * 0.30,
        child: const Center(
          child: Text("Cancel", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
