import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';

class AddStaffForm extends StatefulWidget {
  const AddStaffForm({super.key});

  @override
  State<AddStaffForm> createState() => _AddStaffFormState();
}

enum Sex { male, female, other }

class _AddStaffFormState extends State<AddStaffForm> {
  // final _formKey = GlobalKey<FormState>();
  Sex groupCurrentValue = Sex.other;

  // FORM Value
  String nameValue = "";
  String ageValue = "";
  String sexValue = "";
  String userRole = "";
  String contactNumberValue = "";
  String addressValue = "";
  String notableBehaviorValue = "";
  String pictureValue = "";
  String createdAtValue = "";

  Uint8List? imageInBytes;

  List<String> items = ["No Role", "Admin", "Social Service", "Home Life"];

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    super.dispose();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
          decoration: const BoxDecoration(color: MyColorPalette.lightBlue),
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
          items: items,
          hintText: "Select a User",
          icon: Icon(Icons.person_outline_rounded, size: 32),
        ),
        SizedBox(height: 10),
        MyDropdownMenuButton(
          items: items,
          hintText: "Role/Position:",
          icon: Icon(Icons.verified_user_outlined, size: 32),
        ),
        SizedBox(height: 25),

        // image part of the form
        (imageInBytes == null)
            ? CircleAvatar(
                minRadius: 40,
                backgroundColor: Colors.grey.shade100,
                child: Icon(Icons.person_rounded, color: Colors.grey, size: 60),
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

        SizedBox(height: 10),

        MyCustButton(
          buttonText: "Select Picture",
          buttonTextColor: Colors.white,
          buttonTextFontWeight: FontWeight.w500,
          buttonTextFontSize: 16,
          onTap: () async {
            MyImageProcessor.myImagePicker().then((value) async {
              //TODO: ibalhinay ni sa save button para dili sya automatic save og picture if mamili lang og picture.
              // await MyPersonalInfoRepository.uploadProfilePicture(
              //   userID: FirebaseAuth.instance.currentUser!.uid,
              //   base64Image: value,
              // );

              setState(() {
                pictureValue = value;
                imageInBytes = MyImageProcessor.decodeStringToUint8List(value);
              });
              print("PICTURE VALUE IN FORM: $pictureValue");
            });
          },
        ),

        SizedBox(height: 20),

        // information part of the form
        informationRow(context, labelText: "Sex", valueText: sexValue),
        informationRow(
          context,
          labelText: "Cotact",
          valueText: contactNumberValue,
        ),
        informationRow(context, labelText: "Age", valueText: ageValue),
        informationRow(
          context,
          labelText: "Address",
          valueText: "skjabfab ajfkjbf",
        ),
        informationRow(
          context,
          labelText: "Registered On",
          valueText: "hbdbwdbwhdbwjbh",
        ),

        SizedBox(height: 20),
        buttonArea(context),
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
