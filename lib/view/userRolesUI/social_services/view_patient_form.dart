// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/my_page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/manage_staff.dart';

class ViewPatientForm extends StatefulWidget {
  final PersonalInfo patientPersonalInfo;
  const ViewPatientForm({super.key, required this.patientPersonalInfo});

  @override
  State<ViewPatientForm> createState() => _AddViewPatientFormState();
}

class _AddViewPatientFormState extends State<ViewPatientForm> {
  bool otherInfoIsReadOnly = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailAddController = TextEditingController();

  String pictureValue = "";

  Uint8List? imageInBytes;

  // List<String> staffNames = [
  //   "No Name Selected",
  //   // "Hori",
  //   // "Verti",
  //   // "Diago",
  //   // "Dimensio",
  // ];

  // Map<String, String> staffInfo = {};
  // bool isStaffSelected = false;

  // List<String> roles = [
  //   "No Role",
  //   "Admin",
  //   "Social Service",
  //   "Medical Service",
  //   "Psychological Service",
  //   "Home Life",
  //   "PSD",
  // ];

  // // for getting the role index
  // int _getRoleIndex(String role) {
  //   switch (role) {
  //     case "Admin":
  //       return 1;
  //     case "Social Service":
  //       return 2;
  //     case "Medical Service":
  //       return 3;
  //     case "Psychological Service":
  //       return 4;
  //     case "Home Life":
  //       return 5;
  //     case "PSD":
  //       return 6;
  //     default:
  //       return 0;
  //   }
  // }

  String? selectedRoleValue;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    setState(() {
      nameController.text = widget.patientPersonalInfo.name;
      contactNumController.text = widget.patientPersonalInfo.contactNumber;
      ageController.text = widget.patientPersonalInfo.age;
      addressController.text = widget.patientPersonalInfo.address;
      emailAddController.text = widget.patientPersonalInfo.email;
      selectedRoleValue = widget.patientPersonalInfo.userType;
      pictureValue = widget.patientPersonalInfo.picture;
    });
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
          // padding: EdgeInsets.all(20),
          width: MyDimensionAdapter.getWidth(context),
          // no specified height since sulod man sya sa SingleChildScrollView
          padding: EdgeInsets.only(bottom: 30),
          // decoration: const BoxDecoration(color: MyColorPalette.formColor),
          child: formSpace(context),
        ),
      ),
    );
  }

  Column formSpace(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // headerBar(context),
        MyCustAppBar(
          title: "Patient Information",
          color: const Color.fromARGB(160, 33, 149, 243),
          textColor: Colors.white,
          backButton: () {
            Navigator.pop(context);
            MyNavigator.goTo(context, const ManageStaff());
          },
          backButtonColor: const Color.fromARGB(235, 255, 255, 255),
          actionButtons: [
            Tooltip(
              message: (otherInfoIsReadOnly)
                  ? "Turn on to enable editing other details of the staff."
                  : "Press again to turn off editing other details of the staff.",
              child: IconButton(
                highlightColor: Colors.white24,
                onPressed: () {
                  setState(() {
                    otherInfoIsReadOnly = !otherInfoIsReadOnly;
                  });
                },
                icon: Icon(
                  Icons.edit_note_outlined,
                  color: (otherInfoIsReadOnly)
                      ? const Color.fromARGB(255, 202, 202, 202)
                      : const Color.fromARGB(235, 255, 255, 255),
                  size: 32,
                ),
              ),
            ),

            SizedBox(width: 7),
          ],
        ),

        SizedBox(height: 20),

        SizedBox(height: 25),

        Column(
          children: [
            informationRow(
              labelText: "Full Name",
              textController: nameController,
              isReadOnly: otherInfoIsReadOnly,
            ),
            // image part of the form
            GestureDetector(
              child: (imageInBytes == null)
                  ? CircleAvatar(
                      radius: 60,
                      backgroundColor: MyColorPalette.formColor,
                      child: (MyImageDisplayer(
                        base64ImageString:
                            MyImageProcessor.decodeStringToUint8List(
                              widget.patientPersonalInfo.picture,
                            ),
                      )),
                    )
                  // this MyImageDisplayer is for displaying image from imagePicker,
                  // while the one above is for displaying image that was passed down (from ManageStaff)
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
                    pictureValue = value;
                    imageInBytes = MyImageProcessor.decodeStringToUint8List(
                      value,
                    );
                  });
                  print("PICTURE VALUE IN FORM: $pictureValue");
                });
              },
            ),
            SizedBox(height: 5),
            Text("Tap to Select an Image", style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),

            // MyDropdownMenuButton(
            //   items: roles,
            //   initialValue:
            //       roles[_getRoleIndex(widget.patientPersonalInfo.userType)],
            //   // initialValue: roles[0]
            //   hintText: "Role/Position:",
            //   icon: Icon(
            //     (selectedRoleValue != roles[0])
            //         ? Icons.verified_user_rounded
            //         : Icons.verified_user_outlined,
            //     size: 32,
            //   ),
            //   onChanged: (selectedRole) {
            //     setState(() {
            //       selectedRoleValue = selectedRole;
            //       print(
            //         "SELECTED ROLE VALUEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: $selectedRoleValue",
            //       );
            //     });
            //   },
            // ),
            // SizedBox(height: 30),

            // information part of the form
            informationRow(
              labelText: "Sex",
              textController: TextEditingController()
                ..text = widget.patientPersonalInfo.sex,
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? Icons.info_outline_rounded
                  : Icons.info,
            ),
            informationRow(
              labelText: "Contact Number",
              textController: contactNumController,
              isReadOnly: otherInfoIsReadOnly,
            ),
            informationRow(
              labelText: "Address",
              textController: addressController,
              isReadOnly: otherInfoIsReadOnly,
            ),
            informationRow(
              labelText: "Email Address",
              textController: emailAddController,
              isReadOnly: otherInfoIsReadOnly,
            ),
            informationRow(
              labelText: "Registed On",
              textController: TextEditingController()
                ..text = MyDateFormatter.formatDate(
                  dateTimeInString: widget.patientPersonalInfo.createdAt,
                ),
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? Icons.info_outline_rounded
                  : Icons.info,
            ),

            SizedBox(height: 20),
            buttonArea(context),
          ],
        ),
      ],
    );
  }

  Widget informationRow({
    required String labelText,
    IconData prefixIcon = Icons.info_outline_rounded,
    required TextEditingController textController,
    bool isReadOnly = true,
  }) {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.9,
      height: (isReadOnly)
          ? MyDimensionAdapter.getHeight(context) * 0.095
          : MyDimensionAdapter.getHeight(context) * 0.075,
      // color: Colors.amber,
      margin: const EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.only(left: 20, top: (isReadOnly) ? 0 : 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (isReadOnly)
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: MyTextFormatter.p(
                    text: labelText,
                    fontsize: kDefaultFontSize - 2,
                  ),
                )
              : SizedBox(),
          MyCustTextfield(
            labelText: (isReadOnly) ? "" : labelText,
            prefixIcon: prefixIcon,
            textController: textController,
            isReadOnly: isReadOnly,
            borderRadius: 7,
            borderColor: (isReadOnly)
                ? Colors.blueGrey.shade200
                : MyColorPalette.borderColor,
            activeBorderColor: (isReadOnly)
                ? Colors.blueGrey.shade200
                : MyColorPalette.borderColor,
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
              myAlertDialogue(
                context: context,
                alertTitle: "Are you sure?",
                alertContent:
                    "${widget.patientPersonalInfo.name} will be assigned as\n$selectedRoleValue",
                // "${patientPersonalInfo?.name},\n${patientPersonalInfo?.picture},\n${selectedRoleValue},\n${patientPersonalInfo?.sex},\n${patientPersonalInfo?.contactNumber},\n${patientPersonalInfo?.age},\n${patientPersonalInfo?.address},\n${patientPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
                // "${patientPersonalInfo?.name},\n${selectedRoleValue},\n${patientPersonalInfo?.sex},\n${patientPersonalInfo?.contactNumber},\n${patientPersonalInfo?.age},\n${patientPersonalInfo?.address},\n${patientPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
                onApprovalPressed: () async {
                  print("IS PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                  bool isItTrue = true;
                  isItTrue = await MyPersonalInfoRepository.updatePersonalInfo(
                    PersonalInfo(
                      userID: widget.patientPersonalInfo.userID,
                      userType: selectedRoleValue!,
                      name: widget.patientPersonalInfo.name,
                      age: widget.patientPersonalInfo.age,
                      sex: widget.patientPersonalInfo.sex,
                      birthdate: widget.patientPersonalInfo.birthdate,
                      contactNumber: widget.patientPersonalInfo.contactNumber,
                      address: widget.patientPersonalInfo.address,
                      notableBehavior:
                          widget.patientPersonalInfo.notableBehavior,
                      picture: pictureValue,
                      createdAt: widget.patientPersonalInfo.createdAt,
                      lastUpdatedAt: widget
                          .patientPersonalInfo
                          .lastUpdatedAt, // to be change base on the current date
                      registeredBy: FirebaseAuth.instance.currentUser!.uid,
                      asignedCaregiver:
                          widget.patientPersonalInfo.asignedCaregiver,
                      deviceID: widget.patientPersonalInfo.deviceID,
                      email: widget.patientPersonalInfo.email,
                    ),
                  );

                  print("DID THE UPDATE WORKKKKKKKKKKKKKKKKKKKK? : $isItTrue");

                  print("IS PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDDD 2222222222222");
                  showMyAnimatedSnackBar(
                    // ignore: use_build_context_synchronously
                    context: context,
                    borderColor: Colors.blue.shade300,
                    bgColor: Colors.blue.shade100,
                    dataToDisplay: "Completed!",
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
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
  // Container headerBar(BuildContext context) {
  //   return Container(
  //     width: MyDimensionAdapter.getWidth(context),
  //     height: kToolbarHeight,
  //     margin: EdgeInsets.only(top: 0, bottom: 20),
  //     decoration: BoxDecoration(
  //       color: const Color.fromARGB(160, 33, 149, 243),
  //       // borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Center(
  //       child: Text(
  //         "Add Staff Form",
  //         style: TextStyle(
  //           fontSize: 20,
  //           color: Colors.white,
  //           letterSpacing: 0.7,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Future<List<String>> getStaffName() async {
  //   List<String> staffNames = [];
  //   List<PersonalInfo> personsList =
  //       widget.bufferedStaffNames ??
  //       await MyPersonalInfoRepository.getAllPersonalInfoRecords();

  //   for (var person in personsList) {
  //     if (person.userType != "Patient") {
  //       staffNames.add(person.name);
  //     }
  //   }

  //   return staffNames;
  // }

  // Future<PersonalInfo> getStaffInfo(String userName) async {
  //   try {
  //     PersonalInfo? staffInfo;
  //     List<PersonalInfo> personalInfo =
  //         widget.bufferedStaffNames ??
  //         await MyPersonalInfoRepository.getAllPersonalInfoRecords();

  //     for (var person in personalInfo) {
  //       if (person.name == userName) {
  //         staffInfo = person;
  //       }
  //     }

  //     return staffInfo!;
  //   } catch (e) {
  //     print("ERROR RETRIEVING DATA ON getStaffInfo: $e");
  //     throw Exception();
  //   }
  // }
}
