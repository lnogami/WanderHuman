import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/components/button.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/add_patient_form/helper/firebase_patients.dart';
import 'package:wanderhuman_app/view/add_patient_form/helper/firebase_services.dart';
import 'package:wanderhuman_app/view/add_patient_form/widget/customed_text_form_field.dart';
import 'package:wanderhuman_app/view/home/widgets/utility_functions/my_animated_snackbar.dart';

class AddPatientForm extends StatefulWidget {
  const AddPatientForm({super.key});

  @override
  State<AddPatientForm> createState() => _AddPatientFormState();
}

enum Sex { male, female, other }

class _AddPatientFormState extends State<AddPatientForm> {
  final _formKey = GlobalKey<FormState>();
  Sex groupCurrentValue = Sex.other;

  // FORM Value
  String nameValue = "";
  String ageValue = "";
  String sexValue = "";
  String birthdateValue = "";
  String guardianContactNumberValue = "";
  String addressValue = "";
  String notableBehaviorValue = "";
  String pictureValue = "";
  String createdAtValue = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          // padding: EdgeInsets.all(20),
          width: MyDimensionAdapter.getWidth(context),
          height: MyDimensionAdapter.getHeight(context) * 1.1,
          decoration: const BoxDecoration(
            color: Color.fromARGB(211, 186, 220, 247),
          ),
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
          headerBar(context),
          MyCustomizedTextFormField(
            bottomMargin: 0,
            label: "Name",
            hintText: "Enter Full Name",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Input valid name";
              }
              setState(() {
                nameValue = value;
              });
              return null;
            },
          ),
          SizedBox(
            // color: Colors.amber.shade100,
            height: MyDimensionAdapter.getHeight(context) * 0.15,
            child: Row(
              children: [
                Expanded(
                  child: MyCustomizedTextFormField(
                    bottomMargin: 0,
                    label: "Age",
                    hintText: "ex.56",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Input valid age";
                      }
                      setState(() {
                        ageValue = value;
                      });
                      return null;
                    },
                  ),
                ),
                // Expanded(
                //   child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Sex/Gender",
                      style: TextStyle(
                        fontSize: 15,
                        color: (sexValue == "")
                            ? const Color.fromARGB(255, 173, 57, 51)
                            : Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: MyDimensionAdapter.getWidth(context) * 0.45,
                      height: 35,
                      child: RadioListTile.adaptive(
                        // dense: true,
                        title: Text(
                          "Male",
                          style: TextStyle(
                            fontSize: 15,
                            color: (sexValue == "") ? Colors.grey : Colors.blue,
                          ),
                        ),
                        fillColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 125, 184, 236),
                        ),
                        value: Sex.male,
                        groupValue: groupCurrentValue,
                        onChanged: (value) {
                          setState(() {
                            groupCurrentValue = value!;
                            sexValue = value.name.toString();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: MyDimensionAdapter.getWidth(context) * 0.45,
                      child: RadioListTile.adaptive(
                        // dense: true,
                        fillColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 125, 184, 236),
                        ),
                        activeColor: Colors.blue,
                        title: Text(
                          "Female",
                          style: TextStyle(
                            fontSize: 15,
                            color: (sexValue == "") ? Colors.grey : Colors.blue,
                          ),
                        ),
                        value: Sex.female,
                        groupValue: groupCurrentValue,
                        onChanged: (value) {
                          setState(() {
                            groupCurrentValue = value!;
                            sexValue = value.name.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // ),
              ],
            ),
          ),
          MyCustomizedTextFormField(
            label: "Birth date",
            hintText: "Month/Day/Year",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Input valid name";
              }
              setState(() {
                birthdateValue = value;
              });
              return null;
            },
          ),
          MyCustomizedTextFormField(
            label: "Guardian Contact Number",
            hintText: "ex. 09123456789",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Input a valid number";
              }
              setState(() {
                guardianContactNumberValue = value;
              });
              return null;
            },
          ),
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
          MyCustomizedTextFormField(
            label: "Picture",
            hintText: "Enter Name",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Input something";
              }
              setState(() {
                pictureValue = value;
              });
              return null;
            },
          ),
          // MyCustomizedTextFormField(
          //   label: "Created at",
          //   hintText: "Enter Age",
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return "Input something";
          //     }
          //     setState(() {
          //       createdAtValue = DateTime.timestamp().toString();
          //     });
          //     return null;
          //   },
          // ),
          buttonArea(context),
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
                MyFirebaseServices.addPatient(
                  Patients(
                    name: nameValue,
                    age: ageValue,
                    sex: sexValue,
                    birthdate: birthdateValue,
                    guardianContactNumber: guardianContactNumberValue,
                    address: addressValue,
                    notableBehavior: notableBehaviorValue,
                    picture: pictureValue,
                    createdAt: DateTime.timestamp().toString(),
                    lastUpdatedAt: DateTime.timestamp().toString(),
                    registeredBy: FirebaseAuth.instance.currentUser?.uid ?? "",
                    asignedCaregiver:
                        FirebaseAuth.instance.currentUser?.uid ?? "",
                    deviceID: "12345", // later na lang ni
                    // email: "", // later na lang ni
                  ),
                );
                showMyAnimatedSnackBar(
                  context: context,
                  dataToDisplay:
                      """$nameValue \n 
                      $ageValue \n 
                      $sexValue \n 
                      $birthdateValue \n 
                      $guardianContactNumberValue \n 
                      $addressValue \n 
                      $notableBehaviorValue \n 
                      $pictureValue \n 
                      $createdAtValue
                      ${MyFirebaseServices.getAllUserID()}
                      SUCCESSFULLY ADDED!""",
                );
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

  // Header (functions as an AppBar but not literally AppBar)
  Container headerBar(BuildContext context) {
    return Container(
      width: MyDimensionAdapter.getWidth(context),
      height: kToolbarHeight,
      margin: EdgeInsets.only(top: 0, bottom: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(160, 33, 149, 243),
        // borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "Add Patient Form",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
}
