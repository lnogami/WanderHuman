import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/view/components/customed_text_form_field.dart';
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/my_page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';

class Medication extends StatefulWidget {
  const Medication({super.key});

  @override
  State<Medication> createState() => _MedicationState();
}

// enum Sex { male, female, other }

class _MedicationState extends State<Medication> {
  final _formKey = GlobalKey<FormState>();

  String dateTime = DateTime.now().toString();
  List<String> patientsNames = ["Please Select Patient"];
  String selectedNameValue = "Please Select Patient";

  Future<List<PersonalInfo>> getPatient() async {
    List<PersonalInfo> patients = [];
    List<PersonalInfo> fetchedRecords =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();
    for (var person in fetchedRecords) {
      if (person.userType == "Patient") {
        patients.add(person);
        patientsNames.add(person.name);
      }
    }

    return patients;
  }

  /// TODO: I'll be back here later, this might be removed or updated
  // FORM Value
  String nameValue = "";
  String ageValue = "";
  String sexValue = "";
  String birthdateValue = "";
  String contactNumberValue = "";
  String addressValue = "";
  String emailValue = "";
  String notableBehaviorValue = "";
  String pictureValue = "";
  String createdAtValue = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    getPatient();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _formKey.currentState?.reset();
    _formKey.currentState?.dispose();
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

  Form formSpace(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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

          FutureBuilder(
            future: getPatient(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return MyDropdownMenuButton(
                  items: patientsNames,
                  initialValue: patientsNames[0],
                  hintText: "Select a Patient",
                  onChanged: (patient) {
                    setState(() {
                      selectedNameValue = patient!;
                    });
                  },
                );
              }
            },
          ),

          dateTimeTimer(),
          MyCustomizedTextFormField(
            label: "Address",
            hintText: "enter Street, Municipal/City, Province",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Input valid address";
              }
              setState(() {
                addressValue = value;
              });
              return null;
            },
          ),
          MyCustomizedTextFormField(
            label: "Guardian Email Address",
            hintText: "guardian@gmail.com",
            keyboardType: TextInputType.emailAddress,
            allowedTextInputsOptions: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Input valid address";
              }
              setState(() {
                addressValue = value;
              });
              return null;
            },
          ),
          MyCustomizedTextFormField(
            label: "Notable Behavior",
            hintText: "ex. wakes up early",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Input something";
              }
              setState(() {
                notableBehaviorValue = value;
              });
              return null;
            },
          ),
          buttonArea(context),
        ],
      ),
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
        setState(() {
          seconds = 60;
          dateTime = DateTime.now().toString();
        });
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
              if (_formKey.currentState!.validate()) {
                // this method accepts Patients object so maong naay Patients diri
                MyPersonalInfoRepository.addPatient(
                  PersonalInfo(
                    // userID is not needed anymore here, because userID was
                    //        assigned to --> "userID": docRef.id  by default in
                    //        MyPersonalInfoRepository.addPatient
                    userID: "",
                    userType: "Patient",
                    name: nameValue,
                    age: ageValue,
                    sex: sexValue,
                    birthdate: birthdateValue,
                    contactNumber: contactNumberValue,
                    address: addressValue,
                    email: emailValue,
                    notableBehavior: notableBehaviorValue,
                    picture: pictureValue,
                    createdAt: DateTime.timestamp().toString(),
                    lastUpdatedAt: DateTime.timestamp().toString(),
                    registeredBy: FirebaseAuth.instance.currentUser?.uid ?? "",
                    asignedCaregiver:
                        FirebaseAuth.instance.currentUser?.uid ?? "",
                    deviceID: "12345", // later na lang ni
                  ),
                );
                // this is just a sample display of the inputted data (deletable)
                showMyAnimatedSnackBar(
                  context: context,
                  dataToDisplay:
                      """$nameValue \n 
                      $ageValue \n 
                      $sexValue \n 
                      $birthdateValue \n 
                      $contactNumberValue \n 
                      $addressValue \n 
                      $notableBehaviorValue \n 
                      $pictureValue \n 
                      $createdAtValue
                       
                      SUCCESSFULLY ADDED!""",
                  //${MyFirebaseServices.getAllUserID()}
                );

                Navigator.pop(context);
              }
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
      },
      child: SizedBox(
        width: MyDimensionAdapter.getWidth(context) * 0.30,
        child: Center(child: Text("Cancel", style: TextStyle(fontSize: 16))),
      ),
    );
  }
}
