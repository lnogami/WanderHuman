// ignore_for_file: avoid_print, use_build_context_synchronously

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
import 'package:wanderhuman_app/view/components/date_picker.dart';
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/textfield.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/manage_staff.dart';

/// This page has two uses, for Global use (each staff can have limited access), and for admins who can only edit roles.
class ViewStaffForm extends StatefulWidget {
  final PersonalInfo staffPersonalInfo;
  const ViewStaffForm({super.key, required this.staffPersonalInfo});

  @override
  State<ViewStaffForm> createState() => _AddViewStaffFormState();
}

class _AddViewStaffFormState extends State<ViewStaffForm> {
  // These variables are for Global Use of this Page
  // this will enable you and only you, to edit your information as this Page is visible for everyone.
  bool isThisYourSelf = false;
  // this will enable an admin to edit some part of the information
  bool isAnAdmin = false;

  // While variable below are from Admin role specific page access
  bool otherInfoIsReadOnly = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailAddController = TextEditingController();

  String pictureValue = "";
  Uint8List? imageInBytes;
  bool isStaffSelected = false;
  String birthdateValue = "";
  String? selectedRoleValue;
  List<String> roles = [
    "No Role",
    "Admin",
    "Social Service",
    "Medical Service",
    "Psychological Service",
    "Home Life",
    "PSD",
  ];

  // for getting the role index
  int _getRoleIndex(String role) {
    switch (role) {
      case "Admin":
        return 1;
      case "Social Service":
        return 2;
      case "Medical Service":
        return 3;
      case "Psychological Service":
        return 4;
      case "Home Life":
        return 5;
      case "PSD":
        return 6;
      default:
        return 0;
    }
  }

  // this will identfiy if the loggedin user is an admin or not as this page is visible for everyone.
  Future<void> getLoggedInUserType() async {
    PersonalInfo personalInfo =
        await MyPersonalInfoRepository.getSpecificPersonalInfo(
          userID: FirebaseAuth.instance.currentUser!.uid,
        );

    if (personalInfo.userType == "Admin") {
      setState(() {
        isAnAdmin = true;
      });
    }
    if (widget.staffPersonalInfo.userID ==
        FirebaseAuth.instance.currentUser!.uid) {
      setState(() {
        isThisYourSelf = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getLoggedInUserType();

    setState(() {
      nameController.text = widget.staffPersonalInfo.name;
      contactNumController.text = widget.staffPersonalInfo.contactNumber;
      ageController.text = widget.staffPersonalInfo.age;
      birthdateValue = widget.staffPersonalInfo.birthdate;
      addressController.text = widget.staffPersonalInfo.address;
      emailAddController.text = widget.staffPersonalInfo.email;
      selectedRoleValue = widget.staffPersonalInfo.userType;
      pictureValue = widget.staffPersonalInfo.picture;
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    contactNumController.dispose();
    ageController.dispose();
    addressController.dispose();
    emailAddController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColorPalette.formColor,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          // this is the main body of the Form
          child: Container(
            // padding: EdgeInsets.all(20),
            width: MyDimensionAdapter.getWidth(context),
            // no specified height since sulod man sya sa SingleChildScrollView
            padding: EdgeInsets.only(bottom: 30),
            // decoration: const BoxDecoration(color: MyColorPalette.formColor),
            alignment: Alignment.center,
            child: formSpace(context),
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
          title: "Staff Information",
          color: const Color.fromARGB(160, 33, 149, 243),
          textColor: Colors.white,
          backButton: () {
            Navigator.pop(context);
            // Navigator.pop(context);
            // Navigator.pop(context);
            // MyNavigator.goTo(
            //   context,
            //   ViewStaffForm(staffPersonalInfo: widget.staffPersonalInfo),
            // );
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
                  if (isThisYourSelf) {
                    setState(() {
                      otherInfoIsReadOnly = !otherInfoIsReadOnly;
                    });
                  } else {
                    showMyAnimatedSnackBar(
                      context: context,
                      dataToDisplay:
                          "Sorry, you cannot edit others information.",
                      bgColor: Colors.white70,
                    );
                  }
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
        SizedBox(height: 45),

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Full name
            informationRow(
              labelText: "Full Name",
              textController: nameController,
              isReadOnly: otherInfoIsReadOnly,
              prefixIcon: Icons.person_outline_rounded,
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
                              widget.staffPersonalInfo.picture,
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
                } else {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay:
                        "To edit, top the edit button at the top right corner.",
                    bgColor: Colors.white,
                  );
                }
              },
            ),
            SizedBox(height: 5),
            Text("Tap to Select an Image", style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),

            // UserType dropdown
            (isAnAdmin)
                ? MyDropdownMenuButton(
                    items: roles,
                    initialValue:
                        roles[_getRoleIndex(widget.staffPersonalInfo.userType)],
                    // initialValue: roles[0]
                    hintText: "Role/Position:",
                    icon: Icon(
                      (selectedRoleValue != roles[0])
                          ? Icons.verified_user_rounded
                          : Icons.verified_user_outlined,
                      size: 32,
                    ),
                    onChanged: (selectedRole) {
                      setState(() {
                        selectedRoleValue = selectedRole;
                        print(
                          "SELECTED ROLE VALUEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: $selectedRoleValue",
                        );
                      });
                    },
                  )
                : informationRow(
                    labelText: "User Role",
                    textController: TextEditingController()
                      ..text = widget.staffPersonalInfo.userType,
                    isReadOnly: true,
                    prefixIcon: (otherInfoIsReadOnly)
                        ? Icons.info_outline_rounded
                        : Icons.info,
                  ),
            // additional space if you are an Admin, because this dropdown above will be visible
            if (widget.staffPersonalInfo.userType == "Admin")
              SizedBox(height: 30),

            // information part of the form
            informationRow(
              labelText: "Sex",
              textController: TextEditingController()
                ..text = widget.staffPersonalInfo.sex,
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? Icons.info_outline_rounded
                  : Icons.info,
            ),
            informationRow(
              labelText: "Age",
              textController: ageController,
              isReadOnly: otherInfoIsReadOnly,
              prefixIcon: Icons.calendar_month_outlined,
            ),
            (otherInfoIsReadOnly)
                ? informationRow(
                    labelText: "Birthdate",
                    textController: TextEditingController()
                      ..text = MyDateFormatter.formatDate(
                        dateTimeInString: birthdateValue,
                      ),
                    isReadOnly: true,
                    prefixIcon: Icons.calendar_month_outlined,
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 2.5, bottom: 25),
                    child: MyCustButton(
                      borderRadius: 8,
                      widthPercentage: 0.8,
                      color: MyColorPalette.formColor,
                      borderColor: MyColorPalette.borderColor,
                      borderWidth: 1,
                      buttonShadowColor: const Color.fromARGB(
                        255,
                        200,
                        221,
                        255,
                      ),
                      buttonTextFontSize: kDefaultFontSize + 1.5,
                      buttonTextSpacing: 1,
                      buttonText: (birthdateValue == "")
                          ? "Birthdate"
                          : "Birthdate: ${MyDateFormatter.formatDate(dateTimeInString: birthdateValue)}",
                      // : birthdateValue,
                      onTap: () {
                        // the age parameter is just for determining the approximate birth year, so the the UX of using this date picker will improve.
                        myDatePicker(context, age: ageController.text).then((
                          date,
                        ) {
                          if (date == null) {
                            return "";
                          }
                          setState(() {
                            birthdateValue = date.toString();
                          });
                        });
                      },
                    ),
                  ),
            informationRow(
              labelText: "Contact Number",
              textController: contactNumController,
              isReadOnly: otherInfoIsReadOnly,
              prefixIcon: Icons.call_outlined,
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
              isReadOnly: true,
              prefixIcon: Icons.email_outlined,
            ),
            informationRow(
              labelText: "Registed On",
              textController: TextEditingController()
                ..text = MyDateFormatter.formatDate(
                  dateTimeInString: widget.staffPersonalInfo.createdAt,
                ),
              isReadOnly: true,
              prefixIcon: (otherInfoIsReadOnly)
                  ? Icons.library_books_outlined
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
      alignment: Alignment.center,
      height: (isReadOnly)
          ? MyDimensionAdapter.getHeight(context) * 0.095
          : MyDimensionAdapter.getHeight(context) * 0.075,
      // color: Colors.amber,
      margin: const EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.only(top: (isReadOnly) ? 0 : 5),
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
            // the admin can only edit the role of the staff,
            // the staff can edit its own information, but not the role
            color: (!otherInfoIsReadOnly || isAnAdmin)
                ? Colors.blue
                : Colors.grey,
            buttonWidth: MyDimensionAdapter.getWidth(context) * 0.40,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();

              // the admin can only edit the role of the staff,
              // the staff can edit its own information, but not the role
              if (isThisYourSelf || isAnAdmin) {
                myAlertDialogue(
                  context: context,
                  alertTitle: "Are you sure?",
                  alertContent: (selectedRoleValue == "No Role")
                      ? "${widget.staffPersonalInfo.name} will be demoted to \nNo Role"
                      : "${widget.staffPersonalInfo.name} will be assigned as\n$selectedRoleValue",
                  // "${staffPersonalInfo?.name},\n${staffPersonalInfo?.picture},\n${selectedRoleValue},\n${staffPersonalInfo?.sex},\n${staffPersonalInfo?.contactNumber},\n${staffPersonalInfo?.age},\n${staffPersonalInfo?.address},\n${staffPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
                  // "${staffPersonalInfo?.name},\n${selectedRoleValue},\n${staffPersonalInfo?.sex},\n${staffPersonalInfo?.contactNumber},\n${staffPersonalInfo?.age},\n${staffPersonalInfo?.address},\n${staffPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
                  onApprovalPressed: () async {
                    await MyPersonalInfoRepository.updatePersonalInfo(
                      PersonalInfo(
                        userID: widget.staffPersonalInfo.userID, //
                        userType: selectedRoleValue!,
                        name: nameController.text,
                        age: ageController.text,
                        sex: widget.staffPersonalInfo.sex, //
                        birthdate: birthdateValue,
                        contactNumber: contactNumController.text,
                        address: addressController.text,
                        notableBehavior:
                            widget.staffPersonalInfo.notableBehavior, //
                        picture: (pictureValue == "")
                            ? widget.staffPersonalInfo.picture
                            : pictureValue,
                        createdAt: widget.staffPersonalInfo.createdAt, //
                        // to be change base on the current date
                        lastUpdatedAt: DateTime.now().toString(),
                        // if this is the first time saving this record from account creation
                        registeredBy:
                            (widget.staffPersonalInfo.registeredBy == "")
                            ? FirebaseAuth.instance.currentUser!.uid
                            : widget.staffPersonalInfo.registeredBy, //
                        asignedCaregiver:
                            widget.staffPersonalInfo.asignedCaregiver, //
                        deviceID: widget.staffPersonalInfo.deviceID, //
                        email: widget.staffPersonalInfo.email, //
                      ),
                    );

                    showMyAnimatedSnackBar(
                      context: context,
                      borderColor: Colors.white,
                      bgColor: Colors.white70,
                      dataToDisplay: "Successfully updated!",
                    );

                    // to pop out the dialog box
                    Navigator.pop(context);
                    Future.delayed(Duration(milliseconds: 1200), () {
                      // this refresh simulation is only for Admin roles,
                      // because this will direct to ManageStaff page, which is only admins should access
                      if (isAnAdmin) {
                        // to pop out the current page
                        Navigator.pop(context);
                        // to pop out the previous page (ManageStaff)
                        Navigator.pop(context);
                        // to simulate a refreshing page
                        MyNavigator.goTo(context, ManageStaff());
                      }
                      // this is for other roles
                      else {
                        Navigator.pop(context);
                      }
                    });
                  },
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
}
