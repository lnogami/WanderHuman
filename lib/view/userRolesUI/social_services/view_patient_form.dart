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
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/textfield.dart';
import 'package:wanderhuman_app/view/userRolesUI/social_services/mini_widgets/frequently_go_to.dart';

class ViewPatientForm extends StatefulWidget {
  final PersonalInfo patientPersonalInfo;
  const ViewPatientForm({super.key, required this.patientPersonalInfo});

  @override
  State<ViewPatientForm> createState() => _AddViewPatientFormState();
}

class _AddViewPatientFormState extends State<ViewPatientForm> {
  bool otherInfoIsReadOnly = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController deviceIDController = TextEditingController();
  TextEditingController contactNumController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailAddController = TextEditingController();
  TextEditingController notableBehaviorController = TextEditingController();
  TextEditingController assignedCaregiverController = TextEditingController();

  // // newly added
  // String assignedCaregiverName = "";
  // String assignedCaregiverID = "";
  // Future<void> getAssignedCaregiverName() async {
  //   try {
  //     MyPersonalInfoRepository.getSpecificPersonalInfo(
  //       userID: assignedCaregiverController.text,
  //     ).then((personalInfo) {
  //       setState(() {
  //         assignedCaregiverName = personalInfo.name;
  //       });
  //     });
  //   } catch (e) {
  //     print("Error on getAssignedCaregiverName: $e");
  //     rethrow;
  //   }
  // }

  ScrollController wholePageScrollController = ScrollController();

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

  @override
  void initState() {
    super.initState();

    setState(() {
      nameController.text = widget.patientPersonalInfo.name;
      deviceIDController.text = widget.patientPersonalInfo.deviceID;
      contactNumController.text = widget.patientPersonalInfo.contactNumber;
      ageController.text = widget.patientPersonalInfo.age;
      addressController.text = widget.patientPersonalInfo.address;
      emailAddController.text = widget.patientPersonalInfo.email;
      notableBehaviorController.text =
          widget.patientPersonalInfo.notableBehavior;
      assignedCaregiverController.text =
          widget.patientPersonalInfo.asignedCaregiver;
      pictureValue = widget.patientPersonalInfo.picture;
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    deviceIDController.dispose();
    contactNumController.dispose();
    ageController.dispose();
    addressController.dispose();
    emailAddController.dispose();
    notableBehaviorController.dispose();
    assignedCaregiverController.dispose();
    wholePageScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColorPalette.formColor,
      body: SafeArea(
        child: RawScrollbar(
          controller: wholePageScrollController,
          thumbColor: Colors.blue.shade300,
          padding: EdgeInsets.only(right: 0, top: (kDefaultFontSize * 4) + 10),
          thumbVisibility: true,
          trackVisibility: true,
          interactive: false, // prevents accidental touch scrolling
          thickness: 5,
          radius: Radius.circular(7),
          child: SingleChildScrollView(
            controller: wholePageScrollController,
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
          },
          backButtonColor: const Color.fromARGB(235, 255, 255, 255),
          actionButtonsRightMargin: (otherInfoIsReadOnly) ? 5 : -5,
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
                  size: (otherInfoIsReadOnly) ? 32 : 45,
                ),
              ),
            ),
            SizedBox(width: 7),
          ],
        ),

        SizedBox(height: 30),

        Column(
          children: [
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
                if (!otherInfoIsReadOnly) {
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
                }
              },
            ),
            (!otherInfoIsReadOnly)
                ? Container(
                    margin: EdgeInsets.only(top: 5, bottom: 20),
                    child: Text(
                      "Tap to Select an Image",
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                : SizedBox(height: 10),

            informationRow(
              labelText: "Full Name",
              textController: nameController,
              isReadOnly: otherInfoIsReadOnly,
              prefixIcon: Icons.person_outline_rounded,
            ),

            informationRow(
              labelText: "Device ID",
              textController: deviceIDController,
              isReadOnly: otherInfoIsReadOnly,
              prefixIcon: Icons.person_outline_rounded,
            ),

            notableBehaviorTextArea(context),
            SizedBox(height: 10),

            // information part of the form
            informationRow(
              labelText: "Sex",
              textController: TextEditingController()
                ..text = widget.patientPersonalInfo.sex,
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? (widget.patientPersonalInfo.sex == "male")
                        ? Icons.man_outlined
                        : Icons.woman_outlined
                  : Icons.info,
            ),
            informationRow(
              labelText: "Age",
              textController: TextEditingController()
                ..text = widget.patientPersonalInfo.age,
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? Icons.calendar_month_outlined
                  : Icons.info,
            ),
            informationRow(
              labelText: "Birthdate",
              textController: TextEditingController()
                ..text = MyDateFormatter.formatDate(
                  dateTimeInString: (widget.patientPersonalInfo.birthdate),
                ),
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? Icons.calendar_today_outlined
                  : Icons.info,
            ),
            informationRow(
              labelText: "Contact Number",
              textController: contactNumController,
              isReadOnly: otherInfoIsReadOnly,
              prefixIcon: Icons.contact_emergency_outlined,
            ),
            informationRow(
              labelText: "Address",
              textController: addressController,
              isReadOnly: otherInfoIsReadOnly,
              prefixIcon: Icons.maps_home_work_outlined,
            ),
            informationRow(
              labelText: "Email Address",
              textController: emailAddController,
              isReadOnly: otherInfoIsReadOnly,
              prefixIcon: Icons.contact_mail_outlined,
            ),
            // informationRow(
            //   labelText: "Assigned Caregiver",
            //   textController: assignedCaregiverController,
            //   isReadOnly: otherInfoIsReadOnly,
            //   prefixIcon: Icons.assignment_ind_outlined,
            // ),
            informationRow(
              labelText: "Registed On",
              textController: TextEditingController()
                ..text = MyDateFormatter.formatDate(
                  dateTimeInString: widget.patientPersonalInfo.createdAt,
                ),
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? Icons.library_books_outlined
                  : Icons.info,
            ),
            informationRow(
              labelText: "Last Updated At",
              textController: TextEditingController()
                ..text = MyDateFormatter.formatDate(
                  dateTimeInString: widget.patientPersonalInfo.lastUpdatedAt,
                ),
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? Icons.library_books_outlined
                  : Icons.info,
            ),

            SizedBox(height: 20),
            (otherInfoIsReadOnly) ? SizedBox() : buttonArea(context),

            // Frequently Go-To Area
            FrequentlyGoToArea(patientID: widget.patientPersonalInfo.userID),
          ],
        ),
      ],
    );
  }

  Column notableBehaviorTextArea(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (otherInfoIsReadOnly)
            ? Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  "Notable Behavior",
                  style: TextStyle(fontSize: kDefaultFontSize - 2),
                ),
              )
            : SizedBox(),
        Container(
          width: MyDimensionAdapter.getWidth(context) * 0.8,
          height: MyDimensionAdapter.getHeight(context) * 0.12,
          margin: EdgeInsets.only(top: (otherInfoIsReadOnly) ? 0 : 5),
          child: TextField(
            readOnly: otherInfoIsReadOnly,
            // if expand is true, maxlines or minLines must be null
            maxLines: null,
            expands: true,
            controller: notableBehaviorController,
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
              label: (otherInfoIsReadOnly)
                  ? SizedBox()
                  : Text(
                      "Notable Behavior",
                      style: TextStyle(fontSize: kDefaultFontSize + 2),
                    ),
              prefixIconConstraints: BoxConstraints.tight(Size(50, 32)),
              prefixIconColor: Colors.grey,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: (otherInfoIsReadOnly)
                      ? Colors.blueGrey.shade200
                      : MyColorPalette.borderColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: (otherInfoIsReadOnly)
                      ? Colors.blueGrey.shade200
                      : MyColorPalette.borderColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Stack notableBehaviorTextArea(BuildContext context) {
  //   return Stack(
  //     alignment: Alignment.topLeft,
  //     clipBehavior: Clip.none,
  //     children: [
  //       Container(
  //         width: MyDimensionAdapter.getWidth(context),
  //         height:
  //             MyDimensionAdapter.getHeight(context) *
  //             ((otherInfoIsReadOnly) ? 0.1 : 0.095),
  //         margin: EdgeInsets.only(top: 20, bottom: 10, left: 38, right: 35),
  //         decoration: BoxDecoration(
  //           color: const Color.fromARGB(255, 252, 253, 255),
  //           borderRadius: BorderRadius.circular(7),
  //           border: BoxBorder.all(width: 1, color: Colors.blueGrey.shade200),
  //         ),
  //       ),
  //       Positioned(
  //         left: (otherInfoIsReadOnly) ? 45 : 85,
  //         top: 17,
  //         child: Container(
  //           color: (otherInfoIsReadOnly)
  //               ? Colors.transparent
  //               : const Color.fromARGB(255, 252, 253, 255),
  //           width: kDefaultFontSize * 8.2,
  //           height: 10,
  //         ),
  //       ),
  //       Positioned(
  //         left: (otherInfoIsReadOnly) ? 48 : 90,
  //         top: (otherInfoIsReadOnly) ? 2 : 13,
  //         child: MyTextFormatter.p(
  //           text: "Notable Behavior",
  //           fontsize: kDefaultFontSize - 2,
  //         ),
  //       ),
  //       Positioned(
  //         left: 90,
  //         top: 25,
  //         child: Container(
  //           width: MyDimensionAdapter.getWidth(context) * 0.64,
  //           height: MyDimensionAdapter.getHeight(context) * 0.09,
  //           // color: Colors.amber,
  //           child: SingleChildScrollView(
  //             child: MyTextFormatter.p(
  //               // text: widget.patientPersonalInfo.notableBehavior,
  //               text:
  //                   "shkhe ekjfe sjkfkjef sefkjeskfjes skjfheshfeskf sfkjeskfjebs bbqoj[0qi3r sfsojf[pefk sfnes[fe[ e[r [rs0irpseirpose risoirepois eipsoirpoeispro s eioiepo]]]]]]",
  //               maxLines: 5,
  //               fontsize: kDefaultFontSize + 1.5,
  //             ),
  //           ),
  //         ),
  //       ),
  //       Positioned(
  //         left: 55,
  //         top: 30,
  //         child: Icon(Icons.unfold_more_outlined, color: Colors.grey),
  //       ),
  //     ],
  //   );
  // }

  Widget informationRow({
    required String labelText,
    IconData prefixIcon = Icons.info_outline_rounded,
    required TextEditingController textController,
    bool isReadOnly = true,

    /// for additional height in case the text is multi-line
    double heightMultiplier = 1,
    int maxLines = 1,
  }) {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.9,
      height: (isReadOnly)
          ? (MyDimensionAdapter.getHeight(context) * 0.095) * heightMultiplier
          : (MyDimensionAdapter.getHeight(context) * 0.075) * heightMultiplier,
      // color: Colors.amber,
      margin: const EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.only(left: 17, top: (isReadOnly) ? 0 : 5),
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
                    maxLines: maxLines,
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
              // this will revert back the textfields to read only mode after saving.
              otherInfoIsReadOnly = true;
              myAlertDialogue(
                context: context,
                alertTitle: "Are you sure?",
                alertContent:
                    "Please recheck if the information provided are accurate and true.",
                // "${patientPersonalInfo?.name},\n${patientPersonalInfo?.picture},\n${selectedRoleValue},\n${patientPersonalInfo?.sex},\n${patientPersonalInfo?.contactNumber},\n${patientPersonalInfo?.age},\n${patientPersonalInfo?.address},\n${patientPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
                // "${patientPersonalInfo?.name},\n${selectedRoleValue},\n${patientPersonalInfo?.sex},\n${patientPersonalInfo?.contactNumber},\n${patientPersonalInfo?.age},\n${patientPersonalInfo?.address},\n${patientPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
                onApprovalPressed: () async {
                  print("IS PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                  bool isItTrue = true;
                  isItTrue = await MyPersonalInfoRepository.updatePersonalInfo(
                    PersonalInfo(
                      userID: widget.patientPersonalInfo.userID,
                      userType: widget.patientPersonalInfo.userType,
                      name: nameController.text, //
                      deviceID: deviceIDController.text,
                      age: widget.patientPersonalInfo.age, //
                      sex: widget.patientPersonalInfo.sex,
                      birthdate: widget.patientPersonalInfo.birthdate,
                      contactNumber: contactNumController.text, //
                      address: addressController.text, //
                      notableBehavior: notableBehaviorController.text, //
                      picture: pictureValue, //
                      createdAt: widget.patientPersonalInfo.createdAt,
                      lastUpdatedAt: DateTime.now().toString(),
                      registeredBy:
                          "${widget.patientPersonalInfo.registeredBy} --> (Updated by) ${FirebaseAuth.instance.currentUser!.uid}",
                      asignedCaregiver: assignedCaregiverController.text,
                      email: emailAddController.text,
                    ),
                  );

                  print("DID THE UPDATE WORKKKKKKKKKKKKKKKKKKKK? : $isItTrue");

                  print("IS PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDDD 2222222222222");
                  showMyAnimatedSnackBar(
                    // ignore: use_build_context_synchronously
                    context: context,
                    borderColor: Colors.white,
                    bgColor: Colors.white60,
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
