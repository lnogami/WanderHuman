import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';

class AddStaffForm extends StatefulWidget {
  const AddStaffForm({super.key});

  @override
  State<AddStaffForm> createState() => _AddStaffFormState();
}

// enum Sex { male, female, other }

class _AddStaffFormState extends State<AddStaffForm> {
  // final _formKey = GlobalKey<FormState>();
  // Sex groupCurrentValue = Sex.other;

  // FORM Value
  // String nameValue = "";
  // String ageValue = "";
  // String sexValue = "";
  // String userRole = "";
  // String contactNumberValue = "";
  // String addressValue = "";
  // String notableBehaviorValue = "";
  String pictureValue = "";
  // String createdAtValue = "";

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
  String? selectedRoleValue;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        // this is the main body of the Form
        child: Container(
          // padding: EdgeInsets.all(20),
          width: MyDimensionAdapter.getWidth(context),
          height: MyDimensionAdapter.getHeight(context) * 1.1,
          decoration: const BoxDecoration(color: MyColorPalette.formColor),
          child: formSpace(context),
        ),
      ),
    );
  }

  Column formSpace(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        headerBar(context),

        MyDropdownMenuButton(
          items: staffNames,
          initialValue: staffNames[0],
          hintText: "Select a User",
          icon: Icon(
            (selectedNameValue != staffNames[0])
                ? Icons.person_rounded
                : Icons.person_outline_rounded,
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

              isStaffSelected = (staffNames[0] == selectedUser) ? false : true;
            });
            if (selectedNameValue != staffNames[0]) {
              PersonalInfo tempInfo = await getStaffInfo(selectedNameValue!);
              setState(() {
                staffPersonalInfo = tempInfo;
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
                            minRadius: 40,
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.grey,
                              size: 60,
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
                        //TODO: ibalhinay ni sa save button para dili sya automatic save og picture if mamili lang og picture.
                        // await MyPersonalInfoRepository.uploadProfilePicture(
                        //   userID: FirebaseAuth.instance.currentUser!.uid,
                        //   base64Image: value,
                        // );
                        setState(() {
                          pictureValue = value;
                          imageInBytes =
                              MyImageProcessor.decodeStringToUint8List(value);
                        });
                        print("PICTURE VALUE IN FORM: $pictureValue");
                      });
                    },
                  ),
                  SizedBox(height: 5),
                  Text("Tap Select an Image", style: TextStyle(fontSize: 12)),
                  SizedBox(height: 20),

                  MyDropdownMenuButton(
                    items: roles,
                    initialValue: roles[0],
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
                  SizedBox(height: 10),

                  // information part of the form
                  informationRow(
                    context,
                    labelText: "Sex",
                    valueText: staffPersonalInfo!.sex,
                  ),
                  informationRow(
                    context,
                    labelText: "Cotact",
                    valueText: staffPersonalInfo!.contactNumber,
                  ),
                  informationRow(
                    context,
                    labelText: "Age",
                    valueText: staffPersonalInfo!.age,
                  ),
                  informationRow(
                    context,
                    labelText: "Address",
                    valueText: staffPersonalInfo!.address,
                  ),
                  informationRow(
                    context,
                    labelText: "Registered On",
                    valueText: staffPersonalInfo!.createdAt,
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

  Container informationRow(
    BuildContext context, {
    String labelText = "Label",
    String valueText = "Value",
  }) {
    return Container(
      // color: Colors.amber,
      width: MyDimensionAdapter.getWidth(context) * 0.90,
      // height: MyDimensionAdapter.getHeight(context) * 0.07,
      padding: EdgeInsets.only(left: 10, right: 5),
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // color: Colors.blueGrey,
            width: MyDimensionAdapter.getWidth(context) * 0.25,
            child: Text(
              labelText,
              softWrap: true,
              maxLines: 2,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            // color: Colors.blueGrey,
            width: MyDimensionAdapter.getWidth(context) * 0.60,
            child: Text(
              valueText,
              softWrap: true,
              maxLines: 2,
              // overflow: TextOverflow.ellipsis,
            ),
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
              showMyAnimatedSnackBar(
                context: context,
                dataToDisplay:
                    "${staffPersonalInfo?.name},\n${staffPersonalInfo?.picture},\n${selectedRoleValue},\n${staffPersonalInfo?.sex},\n${staffPersonalInfo?.contactNumber},\n${staffPersonalInfo?.age},\n${staffPersonalInfo?.address},\n${staffPersonalInfo?.createdAt},\nRegisted by: ${FirebaseAuth.instance.currentUser!.uid},\n",
              );

              // if (_formKey.currentState!.validate()) {
              //   // TODO: to update form, change to addStaff function
              //   MyPersonalInfoRepository.addPatient(
              //     PersonalInfo(
              //       userID: FirebaseAuth.instance.currentUser!.uid,
              //       userType: "patient",
              //       name: nameValue,
              //       age: ageValue,
              //       sex: sexValue,
              //       birthdate: userRole,
              //       contactNumber: contactNumberValue,
              //       address: addressValue,
              //       notableBehavior: notableBehaviorValue,
              //       picture: pictureValue,
              //       createdAt: DateTime.timestamp().toString(),
              //       lastUpdatedAt: DateTime.timestamp().toString(),
              //       registeredBy: FirebaseAuth.instance.currentUser?.uid ?? "",
              //       asignedCaregiver:
              //           FirebaseAuth.instance.currentUser?.uid ?? "",
              //       deviceID: "12345", // later na lang ni
              //       email: "N/A", // later na lang ni
              //     ),
              //   );
              //   // this is just a sample display of the inputted data (deletable)
              //   showMyAnimatedSnackBar(
              //     context: context,
              //     dataToDisplay:
              //         """$nameValue \n
              //         $ageValue \n
              //         $sexValue \n
              //         $userRole \n
              //         $contactNumberValue \n
              //         $addressValue \n
              //         $notableBehaviorValue \n
              //         $pictureValue \n
              //         $createdAtValue

              //         SUCCESSFULLY ADDED!""",
              //     //${MyFirebaseServices.getAllUserID()}
              //   );

              //   Navigator.pop(context);
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
          "Add Staff Form",
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

Future<List<String>> getStaffName() async {
  List<String> staffNames = [];
  List<PersonalInfo> personsList =
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

// Future<PersonalInfo> getUserPersonalInfo(){

//   PersonalInfo personalInfo = MyPersonalInfoRepository.get
//   return personalInfo;
// }
