// // ignore_for_file: avoid_print

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:wanderhuman_app/helper/personal_info_repository.dart';
// import 'package:wanderhuman_app/model/personal_info.dart';
// import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
// import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
// import 'package:wanderhuman_app/view/components/appbar.dart';
// import 'package:wanderhuman_app/view/components/button.dart';
// import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
// import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
// import 'package:wanderhuman_app/view/components/dropdown_button.dart';
// import 'package:wanderhuman_app/view/components/image_displayer.dart';
// import 'package:wanderhuman_app/view/components/image_picker.dart';
// import 'package:wanderhuman_app/view/components/my_page_navigator.dart';
// import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
// import 'package:wanderhuman_app/view/userRolesUI/admin/manage_staff.dart';

// class AddStaffForm extends StatefulWidget {
//   final List<PersonalInfo>? bufferedStaffNames;
//   const AddStaffForm({super.key, this.bufferedStaffNames});

//   @override
//   State<AddStaffForm> createState() => _AddStaffFormState();
// }

// // enum Sex { male, female, other }

// class _AddStaffFormState extends State<AddStaffForm> {
//   String pictureValue = "";

//   Uint8List? imageInBytes;

//   List<String> staffNames = [
//     "No Name Selected",
//     // "Hori",
//     // "Verti",
//     // "Diago",
//     // "Dimensio",
//   ];
//   String? selectedNameValue;

//   // Map<String, String> staffInfo = {};
//   bool isStaffSelected = false;
//   PersonalInfo? staffPersonalInfo;

//   List<String> roles = [
//     "No Role",
//     "Admin",
//     "Social Service",
//     "Medical Service",
//     "Psychological Service",
//     "Home Life",
//     "PSD",
//   ];
//   String? selectedRoleValue;

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     selectedNameValue = staffNames[0];

//     // gets all the name of the staff
//     getStaffName().then((value) {
//       setState(() {
//         staffNames.addAll(value);
//         print("STAFF NAMESSSSSSSSSSSSSSSSS: $staffNames");
//       });
//     });
//     print("STAFF NAMESSSSSSSSSSSSSSSSS: $staffNames");
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         // this is the main body of the Form
//         child: Container(
//           // padding: EdgeInsets.all(20),
//           width: MyDimensionAdapter.getWidth(context),
//           // height: (selectedNameValue == staffNames[0])
//           //     ? MyDimensionAdapter.getHeight(context) * 1.2
//           //     : double.infinity,
//           decoration: const BoxDecoration(color: MyColorPalette.formColor),
//           child: formSpace(context),
//         ),
//       ),
//     );
//   }

//   Column formSpace(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         // headerBar(context),
//         MyCustAppBar(
//           title: "Add Staff Form",
//           color: const Color.fromARGB(160, 33, 149, 243),
//           textColor: Colors.white,
//           backButton: () {
//             Navigator.pop(context);
//             MyNavigator.goTo(context, const ManageStaff());
//           },
//           backButtonColor: const Color.fromARGB(235, 255, 255, 255),
//         ),

//         SizedBox(height: 20),

//         MyDropdownMenuButton(
//           items: staffNames,
//           initialValue: staffNames[0],
//           hintText: "Select a User",
//           icon: Icon(
//             (selectedNameValue == staffNames[0])
//                 ? Icons.person_outline_rounded
//                 : Icons.person_rounded,
//             size: 32,
//           ),
//           onChanged: (selectedUser) async {
//             setState(() {
//               selectedNameValue = selectedUser;
//               // print(
//               //   "SELECTED NAME VALUEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: $selectedNameValue",
//               // );

//               // to reset role once the user selection has changed
//               selectedRoleValue = roles[0];
//               imageInBytes = null;

//               isStaffSelected = (staffNames[0] == selectedUser) ? false : true;
//             });
//             if (selectedNameValue != staffNames[0]) {
//               PersonalInfo tempInfo = await getStaffInfo(selectedNameValue!);
//               setState(() {
//                 staffPersonalInfo = tempInfo;
//                 // print(
//                 //   "STAFF ID OF SELECTED STAFF: ${staffPersonalInfo!.userID}",
//                 // );
//                 // print("TRIGGEREDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD 1");
//               });
//             }
//           },
//         ),
//         SizedBox(height: 25),

//         (isStaffSelected && staffPersonalInfo != null)
//             ? Column(
//                 children: [
//                   // image part of the form
//                   GestureDetector(
//                     child: (imageInBytes == null)
//                         ? CircleAvatar(
//                             radius: 60,
//                             backgroundColor: MyColorPalette.formColor,
//                             child: (widget.bufferedStaffNames != null)
//                                 ? MyImageDisplayer(
//                                     base64ImageString:
//                                         MyImageProcessor.decodeStringToUint8List(
//                                           staffPersonalInfo!.picture,
//                                         ),
//                                   )
//                                 : Icon(
//                                     Icons.person_pin_rounded,
//                                     color: Colors.grey,
//                                     // size: // if naka protrait mode, mag base sa width, otherwise if naka landscape, mag basesa height
//                                     // (MyDimensionAdapter.getWidth(context) <
//                                     //     MyDimensionAdapter.getHeight(
//                                     //       context,
//                                     // ))
//                                     // ? MyDimensionAdapter.getWidth(context) *
//                                     //       0.3
//                                     // : MyDimensionAdapter.getWidth(context) *
//                                     //       0.2,
//                                   ),
//                           )
//                         // this MyImageDisplayer is for displaying image from imagePicker,
//                         // while the one above is for displaying image that was passed down (from ManageStaff)
//                         : MyImageDisplayer(
//                             profileImageSize:
//                                 // if naka protrait mode, mag base sa width, otherwise if naka landscape, mag basesa height
//                                 (MyDimensionAdapter.getWidth(context) <
//                                     MyDimensionAdapter.getHeight(context))
//                                 ? MyDimensionAdapter.getWidth(context) * 0.3
//                                 : MyDimensionAdapter.getWidth(context) * 0.2,
//                             base64ImageString: imageInBytes,
//                           ),
//                     onTap: () async {
//                       MyImageProcessor.myImagePicker().then((value) async {
//                         //TODO: ibalhinay ni sa save button para dili sya automatic save og picture if mamili lang og picture.
//                         // await MyPersonalInfoRepository.uploadProfilePicture(
//                         //   userID: FirebaseAuth.instance.currentUser!.uid,
//                         //   base64Image: value,
//                         // );
//                         setState(() {
//                           pictureValue = value;
//                           imageInBytes =
//                               MyImageProcessor.decodeStringToUint8List(value);
//                         });
//                         print("PICTURE VALUE IN FORM: $pictureValue");
//                       });
//                     },
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     "Tap to Select an Image",
//                     style: TextStyle(fontSize: 12),
//                   ),
//                   SizedBox(height: 20),

//                   MyDropdownMenuButton(
//                     items: roles,
//                     initialValue: roles[0],
//                     hintText: "Role/Position:",
//                     icon: Icon(
//                       (selectedRoleValue != roles[0])
//                           ? Icons.verified_user_rounded
//                           : Icons.verified_user_outlined,
//                       size: 32,
//                     ),
//                     onChanged: (selectedRole) {
//                       setState(() {
//                         selectedRoleValue = selectedRole;
//                         print(
//                           "SELECTED ROLE VALUEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: $selectedRoleValue",
//                         );
//                       });
//                     },
//                   ),
//                   SizedBox(height: 10),

//                   // information part of the form
//                   informationRow(
//                     context,
//                     labelText: "Sex",
//                     valueText: staffPersonalInfo!.sex,
//                   ),
//                   informationRow(
//                     context,
//                     labelText: "Cotact",
//                     valueText: staffPersonalInfo!.contactNumber,
//                   ),
//                   informationRow(
//                     context,
//                     labelText: "Age",
//                     valueText: staffPersonalInfo!.age,
//                   ),
//                   informationRow(
//                     context,
//                     labelText: "Address",
//                     valueText: staffPersonalInfo!.address,
//                   ),
//                   informationRow(
//                     context,
//                     labelText: "Registered On",
//                     valueText: MyDateFormatter.formatDate(
//                       dateTimeInString: staffPersonalInfo!.createdAt,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   buttonArea(context),
//                 ],
//               )
//             : ((isStaffSelected)
//                   // this will display if the information is loading when selected from the dropdown menu
//                   ? Column(
//                       children: [
//                         Center(child: Text("Loading staff information...")),
//                         CircularProgressIndicator(),
//                       ],
//                     )
//                   // this will just suggest the user to select a name from the dropdown menu
//                   : Column(
//                       children: [
//                         Center(
//                           child: Text("Please select a staff to Add Role"),
//                         ),
//                       ],
//                     )),
//       ],
//     );
//   }

//   Container informationRow(
//     BuildContext context, {
//     String labelText = "Label",
//     String valueText = "Value",
//   }) {
//     return Container(
//       // color: Colors.amber,
//       width: MyDimensionAdapter.getWidth(context) * 0.90,
//       // height: MyDimensionAdapter.getHeight(context) * 0.07,
//       padding: EdgeInsets.only(left: 10, right: 5),
//       margin: EdgeInsets.only(top: 5, bottom: 5),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             // color: Colors.blueGrey,
//             width: MyDimensionAdapter.getWidth(context) * 0.25,
//             child: Text(
//               labelText,
//               softWrap: true,
//               maxLines: 2,
//               // overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           Container(
//             // color: Colors.blueGrey,
//             width: MyDimensionAdapter.getWidth(context) * 0.60,
//             child: Text(
//               valueText,
//               softWrap: true,
//               maxLines: 2,
//               // overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // This is where the two buttons are located
//   SizedBox buttonArea(BuildContext context) {
//     return SizedBox(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           cancelButton(context),
//           SizedBox(width: 10),

//           // SAVE BUTTON
//           MyCustButton(
//             buttonText: "Save",
//             buttonTextColor: Colors.white,
//             buttonTextFontSize: 18,
//             buttonTextSpacing: 1.2,
//             buttonWidth: MyDimensionAdapter.getWidth(context) * 0.40,
//             onTap: () {
//               myAlertDialogue(
//                 context: context,
//                 alertTitle: "Are you sure?",
//                 alertContent:
//                     "${staffPersonalInfo!.name} will be assigned as\n$selectedRoleValue",
//                 // "${staffPersonalInfo?.name},\n${staffPersonalInfo?.picture},\n${selectedRoleValue},\n${staffPersonalInfo?.sex},\n${staffPersonalInfo?.contactNumber},\n${staffPersonalInfo?.age},\n${staffPersonalInfo?.address},\n${staffPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
//                 // "${staffPersonalInfo?.name},\n${selectedRoleValue},\n${staffPersonalInfo?.sex},\n${staffPersonalInfo?.contactNumber},\n${staffPersonalInfo?.age},\n${staffPersonalInfo?.address},\n${staffPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
//                 onApprovalPressed: () async {
//                   print("IS PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDDD");
//                   bool isItTrue = true;
//                   isItTrue = await MyPersonalInfoRepository.updatePersonalInfo(
//                     PersonalInfo(
//                       userID: staffPersonalInfo!.userID,
//                       userType: selectedRoleValue!,
//                       name: staffPersonalInfo!.name,
//                       age: staffPersonalInfo!.age,
//                       sex: staffPersonalInfo!.sex,
//                       birthdate: staffPersonalInfo!.birthdate,
//                       contactNumber: staffPersonalInfo!.contactNumber,
//                       address: staffPersonalInfo!.address,
//                       notableBehavior: staffPersonalInfo!.notableBehavior,
//                       picture: pictureValue,
//                       createdAt: staffPersonalInfo!.createdAt,
//                       lastUpdatedAt: staffPersonalInfo!
//                           .lastUpdatedAt, // to be change base on the current date
//                       registeredBy: FirebaseAuth.instance.currentUser!.uid,
//                       asignedCaregiver: staffPersonalInfo!.asignedCaregiver,
//                       deviceID: staffPersonalInfo!.deviceID,
//                       email: staffPersonalInfo!.email,
//                     ),
//                   );

//                   print("DID THE UPDATE WORKKKKKKKKKKKKKKKKKKKK? : $isItTrue");

//                   print("IS PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDDD 2222222222222");
//                   showMyAnimatedSnackBar(
//                     // ignore: use_build_context_synchronously
//                     context: context,
//                     borderColor: Colors.blue.shade300,
//                     bgColor: Colors.blue.shade100,
//                     dataToDisplay: "Completed!",
//                   );
//                   // ignore: use_build_context_synchronously
//                   Navigator.pop(context);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Just a form Cancelation button, nothing else
//   GestureDetector cancelButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pop(context);
//       },
//       child: SizedBox(
//         width: MyDimensionAdapter.getWidth(context) * 0.30,
//         child: Center(child: Text("Cancel", style: TextStyle(fontSize: 16))),
//       ),
//     );
//   }

//   // Header (functions as an AppBar but not literally AppBar)
//   // Container headerBar(BuildContext context) {
//   //   return Container(
//   //     width: MyDimensionAdapter.getWidth(context),
//   //     height: kToolbarHeight,
//   //     margin: EdgeInsets.only(top: 0, bottom: 20),
//   //     decoration: BoxDecoration(
//   //       color: const Color.fromARGB(160, 33, 149, 243),
//   //       // borderRadius: BorderRadius.circular(10),
//   //     ),
//   //     child: Center(
//   //       child: Text(
//   //         "Add Staff Form",
//   //         style: TextStyle(
//   //           fontSize: 20,
//   //           color: Colors.white,
//   //           letterSpacing: 0.7,
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   Future<List<String>> getStaffName() async {
//     List<String> staffNames = [];
//     List<PersonalInfo> personsList =
//         widget.bufferedStaffNames ??
//         await MyPersonalInfoRepository.getAllPersonalInfoRecords();

//     for (var person in personsList) {
//       if (person.userType != "Patient") {
//         staffNames.add(person.name);
//       }
//     }

//     return staffNames;
//   }

//   Future<PersonalInfo> getStaffInfo(String userName) async {
//     try {
//       PersonalInfo? staffInfo;
//       List<PersonalInfo> personalInfo =
//           widget.bufferedStaffNames ??
//           await MyPersonalInfoRepository.getAllPersonalInfoRecords();

//       for (var person in personalInfo) {
//         if (person.name == userName) {
//           staffInfo = person;
//         }
//       }

//       return staffInfo!;
//     } catch (e) {
//       print("ERROR RETRIEVING DATA ON getStaffInfo: $e");
//       throw Exception();
//     }
//   }
// }

//
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
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';

class AddStaffForm extends StatefulWidget {
  final List<PersonalInfo>? bufferedStaffNames;
  const AddStaffForm({super.key, this.bufferedStaffNames});

  @override
  State<AddStaffForm> createState() => _AddStaffFormState();
}

// enum Sex { male, female, other }

class _AddStaffFormState extends State<AddStaffForm> {
  bool otherInfoIsReadOnly = true;
  TextEditingController contactNumController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailAddController = TextEditingController();

  String pictureValue = "";

  Uint8List? imageInBytes;

  List<String> staffNames = [
    "No Name Selected",
    // "Hori",
    // "Verti",
    // "Diago",
    // "Dimensio",
  ];
  String? selectedNameValue;

  // Map<String, String> staffInfo = {};
  bool isStaffSelected = false;
  PersonalInfo? staffPersonalInfo;

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
  int getRoleIndex(String role) {
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

  String? selectedRoleValue;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    selectedNameValue = staffNames[0];

    // gets all the name of the staff
    getStaffName().then((value) {
      setState(() {
        staffNames.addAll(value);
        print("STAFF NAMESSSSSSSSSSSSSSSSS: $staffNames");
      });
    });
    print("STAFF NAMESSSSSSSSSSSSSSSSS: $staffNames");
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
          padding: EdgeInsets.only(bottom: 20),
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
          title: "Add Staff Form",
          color: const Color.fromARGB(160, 33, 149, 243),
          textColor: Colors.white,
          backButton: () {
            Navigator.pop(context);
          },
          backButtonColor: const Color.fromARGB(235, 255, 255, 255),
          actionButtons: [
            // if no user was selected yet, this toggleable wont appear
            (selectedNameValue != staffNames[0])
                ? Tooltip(
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
                  )
                : SizedBox(),
            SizedBox(width: 7),
          ],
        ),

        SizedBox(height: 20),

        MyDropdownMenuButton(
          items: staffNames,
          initialValue: staffNames[0],
          hintText: "Select a User",
          icon: Icon(
            (selectedNameValue == staffNames[0])
                ? Icons.person_outline_rounded
                : Icons.person_rounded,
            size: 32,
          ),
          onChanged: (selectedUser) async {
            setState(() {
              selectedNameValue = selectedUser;
              // print(
              //   "SELECTED NAME VALUEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: $selectedNameValue",
              // );

              // to reset role once the user selection has changed
              selectedRoleValue = roles[0];
              imageInBytes = null;

              isStaffSelected = (staffNames[0] == selectedUser) ? false : true;
            });
            if (selectedNameValue != staffNames[0]) {
              PersonalInfo tempInfo = await getStaffInfo(selectedNameValue!);
              setState(() {
                staffPersonalInfo = tempInfo;
                contactNumController.text = staffPersonalInfo!.contactNumber;
                ageController.text = staffPersonalInfo!.age;
                addressController.text = staffPersonalInfo!.address;
                emailAddController.text = staffPersonalInfo!.email;
                // print(
                //   "STAFF ID OF SELECTED STAFF: ${staffPersonalInfo!.userID}",
                // );
                // print("TRIGGEREDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD 1");
              });
            }
          },
        ),
        SizedBox(height: 25),

        (isStaffSelected && staffPersonalInfo != null)
            ? Column(
                children: [
                  // image part of the form
                  GestureDetector(
                    child: (imageInBytes == null)
                        ? CircleAvatar(
                            radius: 60,
                            backgroundColor: MyColorPalette.formColor,
                            child: (widget.bufferedStaffNames != null)
                                ? MyImageDisplayer(
                                    base64ImageString:
                                        MyImageProcessor.decodeStringToUint8List(
                                          staffPersonalInfo!.picture,
                                        ),
                                  )
                                : Icon(
                                    Icons.person_pin_rounded,
                                    color: Colors.grey,
                                    // size: // if naka protrait mode, mag base sa width, otherwise if naka landscape, mag basesa height
                                    // (MyDimensionAdapter.getWidth(context) <
                                    //     MyDimensionAdapter.getHeight(
                                    //       context,
                                    // ))
                                    // ? MyDimensionAdapter.getWidth(context) *
                                    //       0.3
                                    // : MyDimensionAdapter.getWidth(context) *
                                    //       0.2,
                                  ),
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
                          // this ensures that if no image was picked, the current image will remain
                          if (value != "") {
                            pictureValue = value;
                            imageInBytes =
                                MyImageProcessor.decodeStringToUint8List(value);
                          }
                        });
                        print("PICTURE VALUE IN FORM: $pictureValue");
                      });
                    },
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Tap to Select an Image",
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 20),

                  MyDropdownMenuButton(
                    items: roles,
                    initialValue:
                        roles[getRoleIndex(staffPersonalInfo!.userType)],
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
                  ),
                  SizedBox(height: 30),

                  // information part of the form
                  informationRow(
                    labelText: "Sex",
                    textController: TextEditingController()
                      ..text = staffPersonalInfo!.sex,
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
                        dateTimeInString: staffPersonalInfo!.createdAt,
                      ),
                    isReadOnly: true,
                    prefixIcon: (otherInfoIsReadOnly)
                        ? Icons.info_outline_rounded
                        : Icons.info,
                  ),

                  SizedBox(height: 20),
                  buttonArea(context),
                ],
              )
            : ((isStaffSelected)
                  // this will display if the information is loading when selected from the dropdown menu
                  ? Column(
                      children: [
                        Center(child: Text("Loading staff information...")),
                        CircularProgressIndicator(),
                      ],
                    )
                  // this will just suggest the user to select a name from the dropdown menu
                  : Column(
                      children: [
                        Center(
                          child: Text("Please select a staff to Add Role"),
                        ),
                      ],
                    )),
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
                    "${staffPersonalInfo!.name} will be assigned as\n$selectedRoleValue",
                // "${staffPersonalInfo?.name},\n${staffPersonalInfo?.picture},\n${selectedRoleValue},\n${staffPersonalInfo?.sex},\n${staffPersonalInfo?.contactNumber},\n${staffPersonalInfo?.age},\n${staffPersonalInfo?.address},\n${staffPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
                // "${staffPersonalInfo?.name},\n${selectedRoleValue},\n${staffPersonalInfo?.sex},\n${staffPersonalInfo?.contactNumber},\n${staffPersonalInfo?.age},\n${staffPersonalInfo?.address},\n${staffPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
                onApprovalPressed: () async {
                  print("IS PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                  bool isItTrue = true;
                  isItTrue = await MyPersonalInfoRepository.updatePersonalInfo(
                    PersonalInfo(
                      userID: staffPersonalInfo!.userID,
                      userType: selectedRoleValue!,
                      name: staffPersonalInfo!.name,
                      age: staffPersonalInfo!.age,
                      sex: staffPersonalInfo!.sex,
                      birthdate: staffPersonalInfo!.birthdate,
                      contactNumber: staffPersonalInfo!.contactNumber,
                      address: staffPersonalInfo!.address,
                      notableBehavior: staffPersonalInfo!.notableBehavior,
                      picture: pictureValue,
                      createdAt: staffPersonalInfo!.createdAt,
                      lastUpdatedAt: staffPersonalInfo!
                          .lastUpdatedAt, // to be change base on the current date
                      registeredBy: FirebaseAuth.instance.currentUser!.uid,
                      asignedCaregiver: staffPersonalInfo!.asignedCaregiver,
                      deviceID: staffPersonalInfo!.deviceID,
                      email: staffPersonalInfo!.email,
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

  Future<List<String>> getStaffName() async {
    List<String> staffNames = [];
    List<PersonalInfo> personsList =
        widget.bufferedStaffNames ??
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();

    for (var person in personsList) {
      if (person.userType != "Patient") {
        staffNames.add(person.name);
      }
    }

    return staffNames;
  }

  Future<PersonalInfo> getStaffInfo(String userName) async {
    try {
      PersonalInfo? staffInfo;
      List<PersonalInfo> personalInfo =
          widget.bufferedStaffNames ??
          await MyPersonalInfoRepository.getAllPersonalInfoRecords();

      for (var person in personalInfo) {
        if (person.name == userName) {
          staffInfo = person;
        }
      }

      return staffInfo!;
    } catch (e) {
      print("ERROR RETRIEVING DATA ON getStaffInfo: $e");
      throw Exception();
    }
  }
}
