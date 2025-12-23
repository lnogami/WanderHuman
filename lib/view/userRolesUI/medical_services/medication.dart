import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/medical_services_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/medication_model.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/my_page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';

class Medication extends StatefulWidget {
  const Medication({super.key});

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
  String dateTime = DateTime.now().toString();

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _patientsInfo = getPatient();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    patientsNames.clear();
    selectedNameValue = "";
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
        MyCustAppBar(
          title: "Medication",
          color: const Color.fromARGB(160, 33, 149, 243),
          textColor: Colors.white,
          fontWeight: FontWeight.w600,
          backButton: () {
            Navigator.pop(context);
            Navigator.pop(context);
            MyNavigator.goTo(context, Medication());
          },
          backButtonColor: Colors.white70,
        ),
        SizedBox(height: 25),

        // acts as a header for the form
        dateTimeTimer(),

        // MyDateTimeTimerHeader(),
        FutureBuilder(
          future: _patientsInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return MyDropdownMenuButton(
                icon: Icon(Icons.person_outline_rounded, size: 32),
                items: patientsNames,
                initialValue: patientsNames[0],
                hintText: "Select a Patient",
                onChanged: (patient) {
                  if (selectedNameValue != patientsNames[0]) {
                    setState(() {
                      print("PATIENT NAMEEEEE: $patient");
                      // assigns the _selectedPatient
                      getSpecificPatient(patient!);
                      selectedNameValue = patient;
                      // showMyAnimatedSnackBar(
                      //   context: context,
                      //   dataToDisplay: _selectedPatient!.name,
                      // );
                    });
                  }
                },
              );
            }
          },
        ),

        SizedBox(height: 20),

        MyCustTextfield(
          labelText: "Diagnosis",
          prefixIcon: Icons.info_outline_rounded,
          textController: diagnosisController,
          borderRadius: 7,
          borderColor: MyColorPalette.borderColor,
          activeBorderColor: MyColorPalette.borderColor,
        ),
        treatmentArea(context),

        buttonArea(context),
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
          margin: EdgeInsets.only(top: 20),
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
    int seconds = 5;
    Timer.periodic(Duration(seconds: seconds), (timer) {
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

          // SAVE BUTTON
          MyCustButton(
            buttonText: "Save",
            buttonTextColor: Colors.white,
            buttonTextFontSize: 18,
            buttonTextSpacing: 1.2,
            buttonWidth: MyDimensionAdapter.getWidth(context) * 0.40,
            onTap: () {
              MyMedicalRepository.addRecord(
                MedicationModel(
                  // recordID: "",
                  patientID: _selectedPatient!.userID,
                  diagnosis: diagnosisController.text,
                  treatment: treatmentController.text,
                  medic: FirebaseAuth.instance.currentUser!.uid,
                  fromDate: "",
                  untilDate: "",
                  isNowOkay: false,
                  createdAt: DateTime.now().toString(),
                ),
              );
              print(
                "ADDEDDDDDDDDDDDDDD: userID: ${_selectedPatient?.userID},  name: ${_selectedPatient?.name},  diagnosis: ${diagnosisController.text},  treatment: ${treatmentController.text}, medic: ${FirebaseAuth.instance.currentUser!.uid}",
              );
              showMyAnimatedSnackBar(context: context, dataToDisplay: "Done..");
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
        // Navigator.pop(context);
        MyNavigator.goTo(context, const Medication());
      },
      child: SizedBox(
        width: MyDimensionAdapter.getWidth(context) * 0.30,
        child: Center(child: Text("Cancel", style: TextStyle(fontSize: 16))),
      ),
    );
  }
}
