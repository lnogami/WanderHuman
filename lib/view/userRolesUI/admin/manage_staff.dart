import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/my_page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/add_staff_form.dart';

class ManageStaff extends StatelessWidget {
  const ManageStaff({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: MyCustButton(
            buttonText: "Add Staff",
            onTap: () {
              // Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AddStaffForm()),
              // );
              MyNavigator.goTo(context, AddStaffForm());
            },
          ),
        ),
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:wanderhuman_app/helper/personal_info_repository.dart';
// import 'package:wanderhuman_app/view/components/button.dart';
// import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
// import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
// import 'package:wanderhuman_app/model/personal_info.dart';
// import 'package:wanderhuman_app/view/add_patient_form/widget/customed_text_form_field.dart';
// import 'package:wanderhuman_app/view/components/image_displayer.dart';
// import 'package:wanderhuman_app/view/components/image_picker.dart';
// import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';

// class AddStaffForm extends StatefulWidget {
//   const AddStaffForm({super.key});

//   @override
//   State<AddStaffForm> createState() => _AddStaffFormState();
// }

// enum Sex { male, female, other }

// class _AddStaffFormState extends State<AddStaffForm> {
//   final _formKey = GlobalKey<FormState>();
//   Sex groupCurrentValue = Sex.other;

//   // FORM Value
//   String nameValue = "";
//   String ageValue = "";
//   String sexValue = "";
//   String userRole = "";
//   String contactNumberValue = "";
//   String addressValue = "";
//   String notableBehaviorValue = "";
//   String pictureValue = "";
//   String createdAtValue = "";

//   Uint8List? imageInBytes;

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
//           height: MyDimensionAdapter.getHeight(context) * 1.1,
//           decoration: const BoxDecoration(color: MyColorPalette.lightBlue),
//           child: formSpace(context),
//         ),
//       ),
//     );
//   }

//   Form formSpace(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           headerBar(context),
//           MyCustomizedTextFormField(
//             isReadOnly: true,
//             bottomMargin: 0,
//             label: "Name",
//             hintText: "Enter Full Name",
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Input valid name";
//               }
//               setState(() {
//                 nameValue = value;
//               });
//               return null;
//             },
//           ),
//           //might change later to drop down menu
//           MyCustomizedTextFormField(
//             label: "Role/Position",
//             hintText: "Social Service, Home Life, etc.",
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Input valid name";
//               }
//               setState(() {
//                 userRole = value;
//               });
//               return null;
//             },
//           ),
//           SizedBox(
//             // color: Colors.amber.shade100,
//             height: MyDimensionAdapter.getHeight(context) * 0.15,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: MyCustomizedTextFormField(
//                     bottomMargin: 0,
//                     label: "Age",
//                     hintText: "ex.56",
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Input valid age";
//                       }
//                       setState(() {
//                         ageValue = value;
//                       });
//                       return null;
//                     },
//                   ),
//                 ),
//                 // Expanded(
//                 //   child:
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Sex/Gender",
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: (sexValue == "")
//                             ? const Color.fromARGB(255, 173, 57, 51)
//                             : Colors.blue,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(
//                       width: MyDimensionAdapter.getWidth(context) * 0.45,
//                       height: 35,
//                       child: RadioListTile<Sex>.adaptive(
//                         // dense: true,
//                         title: Text(
//                           "Male",
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: (sexValue == "") ? Colors.grey : Colors.blue,
//                           ),
//                         ),
//                         fillColor: WidgetStateProperty.resolveWith(
//                           (states) => states.contains(WidgetState.selected)
//                               ? Colors.blue
//                               : const Color.fromARGB(255, 125, 184, 236),
//                         ),
//                         value: Sex.male,
//                         groupValue: groupCurrentValue,
//                         onChanged: (value) {
//                           setState(() {
//                             groupCurrentValue = value!;
//                             sexValue = value.name.toString();
//                           });
//                         },
//                       ),
//                     ),
//                     SizedBox(
//                       width: MyDimensionAdapter.getWidth(context) * 0.45,
//                       child: RadioListTile.adaptive(
//                         // dense: true,
//                         fillColor: WidgetStateProperty.resolveWith(
//                           (states) => states.contains(WidgetState.selected)
//                               ? Colors.blue
//                               : const Color.fromARGB(255, 125, 184, 236),
//                         ),

//                         activeColor: Colors.blue,
//                         title: Text(
//                           "Female",
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: (sexValue == "") ? Colors.grey : Colors.blue,
//                           ),
//                         ),
//                         value: Sex.female,
//                         groupValue: groupCurrentValue,
//                         onChanged: (value) {
//                           setState(() {
//                             groupCurrentValue = value!;
//                             sexValue = value.name.toString();
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 // ),
//               ],
//             ),
//           ),

//           MyCustomizedTextFormField(
//             label: "Contact Number",
//             hintText: "ex. 09123456789",
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Input a valid number";
//               }
//               setState(() {
//                 contactNumberValue = value;
//               });
//               return null;
//             },
//           ),
//           MyCustomizedTextFormField(
//             label: "Address",
//             hintText: "enter Street, Municipal/City, Province",
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Input valid address";
//               }
//               setState(() {
//                 addressValue = value;
//               });
//               return null;
//             },
//           ),

//           (imageInBytes == null)
//               ? Icon(Icons.person_rounded, color: Colors.grey, size: 60)
//               : MyImageDisplayer(
//                   profileImageSize:
//                       // if naka protrait mode, mag base sa width, otherwise if naka landscape, mag basesa height
//                       (MyDimensionAdapter.getWidth(context) <
//                           MyDimensionAdapter.getHeight(context))
//                       ? MyDimensionAdapter.getWidth(context) * 0.3
//                       : MyDimensionAdapter.getWidth(context) * 0.2,
//                   base64ImageString: imageInBytes,
//                 ),

//           MyCustButton(
//             buttonText: "Pick an Image as User Profile",
//             onTap: () async {
//               // String userID = await FirebaseAuth.instance.currentUser!.uid;
//               // String userIDInDatabase =
//               //     await MyFirebaseServices.getSpecificPersonalInfo(
//               //       userID: userID,
//               //     ).then((personalInfo) => personalInfo.userID);
//               // MyImageProcessor.myImagePicker(userID: userIDInDatabase).then((
//               //   value,
//               // ) {
//               //   setState(() {
//               //     pictureValue = value;
//               //   });
//               // });
//               MyImageProcessor.myImagePicker().then((value) async {
//                 //TODO: ibalhinay ni sa save button para dili sya automatic save og picture if mamili lang og picture.
//                 await MyPersonalInfoRepository.uploadProfilePicture(
//                   userID: FirebaseAuth.instance.currentUser!.uid,
//                   base64Image: value,
//                 );

//                 setState(() {
//                   pictureValue = value;
//                   imageInBytes = MyImageProcessor.decodeStringToUint8List(
//                     value,
//                   );
//                 });
//                 print("PICTURE VALUE IN FORM: $pictureValue");

//                 // MyPersonalInfoRepository.getSpecificPersonalInfo(
//                 //   userID: FirebaseAuth.instance.currentUser!.uid,
//                 // ).then((personalInfo) async {
//                 //   String? docID =
//                 //       await MyPersonalInfoRepository.getDocIdByUserId(
//                 //         personalInfo.userID,
//                 //       );
//                 //   print("THE DOCUMENT ID OF ${personalInfo.userID} is: $docID");
//                 //   print(
//                 //     "PERSONAL INFO FETCHED IN FORM AFTER PICKING IMAGE: ${personalInfo.userID}",
//                 //   );
//                 //   MyPersonalInfoRepository.uploadProfilePicture(
//                 //     docID: docID!,
//                 //     base64Image: value,
//                 //   );
//                 // });
//               });
//             },
//           ),
//           // MyCustomizedTextFormField(
//           //   label: "Created at",
//           //   hintText: "Enter Age",
//           //   validator: (value) {
//           //     if (value == null || value.isEmpty) {
//           //       return "Input something";
//           //     }
//           //     setState(() {
//           //       createdAtValue = DateTime.timestamp().toString();
//           //     });
//           //     return null;
//           //   },
//           // ),
//           SizedBox(height: 20),
//           buttonArea(context),
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
//               if (_formKey.currentState!.validate()) {
//                 // TODO: to update form, change to addStaff function
//                 MyPersonalInfoRepository.addPatient(
//                   PersonalInfo(
//                     userID: FirebaseAuth.instance.currentUser!.uid,
//                     userType: "patient",
//                     name: nameValue,
//                     age: ageValue,
//                     sex: sexValue,
//                     birthdate: userRole,
//                     contactNumber: contactNumberValue,
//                     address: addressValue,
//                     notableBehavior: notableBehaviorValue,
//                     picture: pictureValue,
//                     createdAt: DateTime.timestamp().toString(),
//                     lastUpdatedAt: DateTime.timestamp().toString(),
//                     registeredBy: FirebaseAuth.instance.currentUser?.uid ?? "",
//                     asignedCaregiver:
//                         FirebaseAuth.instance.currentUser?.uid ?? "",
//                     deviceID: "12345", // later na lang ni
//                     email: "N/A", // later na lang ni
//                   ),
//                 );
//                 // this is just a sample display of the inputted data (deletable)
//                 showMyAnimatedSnackBar(
//                   context: context,
//                   dataToDisplay:
//                       """$nameValue \n 
//                       $ageValue \n 
//                       $sexValue \n 
//                       $userRole \n 
//                       $contactNumberValue \n 
//                       $addressValue \n 
//                       $notableBehaviorValue \n 
//                       $pictureValue \n 
//                       $createdAtValue
                       
//                       SUCCESSFULLY ADDED!""",
//                   //${MyFirebaseServices.getAllUserID()}
//                 );

//                 Navigator.pop(context);
//               }
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
//   Container headerBar(BuildContext context) {
//     return Container(
//       width: MyDimensionAdapter.getWidth(context),
//       height: kToolbarHeight,
//       margin: EdgeInsets.only(top: 0, bottom: 20),
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(160, 33, 149, 243),
//         // borderRadius: BorderRadius.circular(10),
//       ),
//       child: Center(
//         child: Text(
//           "Add Staff Form",
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.white,
//             letterSpacing: 0.7,
//           ),
//         ),
//       ),
//     );
//   }
// }
