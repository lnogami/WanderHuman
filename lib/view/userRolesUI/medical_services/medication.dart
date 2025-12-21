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
import 'package:wanderhuman_app/view/components/date_picker.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';

class Medication extends StatefulWidget {
  const Medication({super.key});

  @override
  State<Medication> createState() => _MedicationState();
}

// enum Sex { male, female, other }

class _MedicationState extends State<Medication> {
  final _formKey = GlobalKey<FormState>();
  // Sex groupCurrentValue = Sex.other;

  Uint8List? imageInBytes;

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
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
            },
            backButtonColor: Colors.white70,
          ),
          SizedBox(height: 25),
          // image part of the form
          GestureDetector(
            child: (imageInBytes == null)
                ? CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      Icons.person_pin_rounded,
                      color: Colors.grey.shade400,
                      size: 80,
                    ),
                  )
                : MyImageDisplayer(
                    profileImageSize:
                        // if naka protrait mode, mag base sa width, otherwise if naka landscape, mag basesa height
                        (MyDimensionAdapter.getWidth(context) <
                            MyDimensionAdapter.getHeight(context))
                        ? MyDimensionAdapter.getWidth(context) * 0.3
                        : MyDimensionAdapter.getWidth(context) * 0.2,
                    base64ImageString: imageInBytes,
                  ),
            onTap: () async {
              MyImageProcessor.myImagePicker().then((value) async {
                setState(() {
                  // this ensures that if no image was picked, the current image will remain
                  if (value != "") {
                    pictureValue = value;
                    imageInBytes = MyImageProcessor.decodeStringToUint8List(
                      value,
                    );
                  }
                });
                print("PICTURE VALUE IN FORM: $pictureValue");
              });
            },
          ),
          SizedBox(height: 5),
          Text("Tap to Select an Image", style: TextStyle(fontSize: 12)),
          SizedBox(height: 20),
          MyCustomizedTextFormField(
            bottomMargin: 0,
            label: "Name",
            hintText: "Enter Full Name",
            allowedTextInputsOptions: 2,
            keyboardType: TextInputType.name,
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
            height: MyDimensionAdapter.getHeight(context) * 0.12,
            child: Row(
              children: [
                Expanded(
                  child: MyCustomizedTextFormField(
                    // focusNode: (sexValue != "" && ageValue == "")
                    //     ? (FocusNode(canRequestFocus: false)
                    //         ..unfocus()
                    //         ..skipTraversal)
                    //     : null,
                    keyboardType: TextInputType.number,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    allowedTextInputsOptions: 3,
                    bottomMargin: 0,
                    label: "Age",
                    hintText: "ex.56",
                    onChange: (value) {
                      setState(() {
                        ageValue = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Input valid age";
                      }
                      return null;
                    },
                  ),
                ),
                sexDeterminer(context),
                // Expanded(
                //   child:
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Text(
                //       "Sex/Gender",
                //       style: TextStyle(
                //         fontSize: 15,
                //         color: (sexValue == "")
                //             ? const Color.fromARGB(255, 173, 57, 51)
                //             : Colors.blue,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     SizedBox(
                //       width: MyDimensionAdapter.getWidth(context) * 0.45,
                //       height: 35,
                //       child: RadioListTile.adaptive(
                //         // dense: true,
                //         title: Text(
                //           "Male",
                //           style: TextStyle(
                //             fontSize: 15,
                //             color: (sexValue == "") ? Colors.grey : Colors.blue,
                //           ),
                //         ),
                //         fillColor: WidgetStateProperty.resolveWith(
                //           (states) => states.contains(WidgetState.selected)
                //               ? Colors.blue
                //               : const Color.fromARGB(255, 125, 184, 236),
                //         ),
                //         value: Sex.male,
                //         groupValue: groupCurrentValue,
                //         onChanged: (value) {
                //           setState(() {
                //             groupCurrentValue = value!;
                //             sexValue = value.name.toString();
                //           });
                //         },
                //       ),
                //     ),
                //     SizedBox(
                //       width: MyDimensionAdapter.getWidth(context) * 0.45,
                //       child: RadioListTile.adaptive(
                //         // dense: true,
                //         fillColor: WidgetStateProperty.resolveWith(
                //           (states) => states.contains(WidgetState.selected)
                //               ? Colors.blue
                //               : const Color.fromARGB(255, 125, 184, 236),
                //         ),

                //         activeColor: Colors.blue,
                //         title: Text(
                //           "Female",
                //           style: TextStyle(
                //             fontSize: 15,
                //             color: (sexValue == "") ? Colors.grey : Colors.blue,
                //           ),
                //         ),
                //         value: Sex.female,
                //         groupValue: groupCurrentValue,
                //         onChanged: (value) {
                //           setState(() {
                //             groupCurrentValue = value!;
                //             sexValue = value.name.toString();
                //           });
                //         },
                //       ),
                //     ),
                //   ],
                // ),
                //// ),
              ],
            ),
          ),
          // MyCustomizedTextFormField(
          //   label: "Birth date",
          //   hintText: "Month/Day/Year",
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return "Input valid name";
          //     }
          //     setState(() {
          //       birthdateValue = value;
          //     });
          //     return null;
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 2.5, bottom: 25),
            child: MyCustButton(
              borderRadius: 8,
              widthPercentage: 0.88,
              color: const Color.fromARGB(255, 233, 241, 254),
              borderColor: Colors.blue.shade200,
              borderWidth: 1,
              buttonShadowColor: const Color.fromARGB(255, 200, 221, 255),
              buttonTextFontSize: kDefaultFontSize + 1.5,
              buttonTextSpacing: 1,
              buttonText: (birthdateValue == "")
                  ? "Birthdate"
                  : "Birthdate: ${MyDateFormatter.formatDate(dateTimeInString: birthdateValue)}",
              // : birthdateValue,
              onTap: () {
                // the age parameter is just for determining the approximate birth year, so the the UX of using this date picker will improve.
                myDatePicker(context, age: ageValue).then((date) {
                  if (date == null) {
                    return "";
                  }
                  setState(() {
                    birthdateValue = date.toString();
                  });
                });
                // setState(() {
                //   birthdateValue = ageValue;
                // });
              },
            ),
          ),
          MyCustomizedTextFormField(
            label: "Guardian Contact Number",
            hintText: "ex. 09123456789",
            allowedTextInputsOptions: 3,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Input a valid number";
              }
              setState(() {
                contactNumberValue = value;
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

  Container sexDeterminer(BuildContext context) {
    double buttonWidth = MyDimensionAdapter.getWidth(context) * 0.28;
    double buttonHeight = MyDimensionAdapter.getHeight(context) * 0.0635;
    return Container(
      // color: Colors.amber,
      width: MyDimensionAdapter.getWidth(context) * 0.57,
      // height: MyDimensionAdapter.getHeight(context) * 0.2,
      margin: EdgeInsets.only(right: 18, top: 2),
      child: Column(
        children: [
          MyTextFormatter.p(text: "Sex", fontsize: kDefaultFontSize - 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    sexValue = "male";
                  });
                },
                child: Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: (sexValue == "male")
                        ? Colors.blue.shade100
                        : Colors.transparent,

                    border: BoxBorder.all(
                      color: (sexValue == "male")
                          ? Colors.blue.shade400
                          : MyColorPalette.borderColor,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Center(child: Text("MALE")),
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    sexValue = "female";
                  });
                },
                child: Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: (sexValue == "female")
                        ? Colors.blue.shade100
                        : Colors.transparent,
                    border: BoxBorder.all(
                      color: (sexValue == "female")
                          ? Colors.blue.shade400
                          : MyColorPalette.borderColor,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Center(child: Text("FEMALE")),
                ),
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
