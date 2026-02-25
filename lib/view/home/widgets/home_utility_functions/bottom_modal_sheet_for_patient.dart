import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/view_patient_details/patient_details_page.dart';

void showMyBottomNavigationSheet({
  required BuildContext context,
  // required PersonalInfo personalInfo,
  required String patientID,
  required String name,
  required String age,
  required String sex,
  required String contactInfo,
  required String address,
  required String notableBehavior,
  required String profilePicture, // not yet implemented
  required String currentlyIn,
  required int batteryPercentage,
  required bool isCurrentlySafe,
  required String deviceID,
  required String birthDate,
  required String email,

  // 'patientID': realtimeLocModel.patientID,
  // 'currentlyIn': realtimeLocModel.currentlyIn,
  // 'isInSafeZone': realtimeLocModel.isInSafeZone,
  // 'timeStamp': realtimeLocModel.timeStamp,
  // 'deviceBatteryPercentage': realtimeLocModel
  //     .deviceBatteryPercentage
  //     .toString(),
  // 'userID': patient.userID,
  // 'age': patient.age,
  // 'sex': patient.sex,
  // 'contactInfo': patient.contactNumber,
  // 'address': patient.address,
  // 'notableBehavior': patient.notableBehavior,
}) {
  // Putting this in a variable instead of directly passing the MyImageProcessor to the MyImageDisplayer will prevent it from the flickering effect
  Uint8List formattedImage = MyImageProcessor.decodeStringToUint8List(
    profilePicture,
  );

  showBottomSheet(
    context: context,
    backgroundColor: const Color.fromARGB(235, 255, 255, 255),
    builder: (context) {
      return Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context) * 0.8,
        decoration: BoxDecoration(
          // color: Colors.purple[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          // alignment: Alignment.topCenter,
          children: [
            SizedBox(height: 5),
            MyLine(
              length: MyDimensionAdapter.getWidth(context) * 0.25,
              isRounded: true,
              isVertical: false,
              thickness: 7,
            ),
            SizedBox(height: 20),

            // Picture of the Patient
            CircleAvatar(
              backgroundColor: Colors.blue.withAlpha(200),
              radius: 56,
              child: MyImageDisplayer(base64ImageString: formattedImage),
            ),
            SizedBox(height: 10),

            // Name of the Patient
            MyTextFormatter.h3(text: name, fontsize: kDefaultFontSize + 10),
            SizedBox(height: 10),

            // Primary Details Area
            Container(
              width: MyDimensionAdapter.getWidth(context) * 0.8,
              height: 60,
              padding: EdgeInsets.fromLTRB(7, 7, 7, 4),
              margin: EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(
                color: Colors.white10,
                border: BoxBorder.all(color: Colors.white, width: 1.2),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(31, 0, 42, 100),
                    blurRadius: 4,
                    blurStyle: BlurStyle.outer,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              // color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  flexibleSizedContainers(
                    flex: 2,
                    textLabel: "Age",
                    textValue: age,
                  ),
                  verticalLine(context),
                  flexibleSizedContainers(
                    flex: 4,
                    textLabel: "Sex",
                    textValue: sex,
                  ),
                  verticalLine(context),
                  flexibleSizedContainers(
                    flex: 8,
                    textLabel: "Guardian's Contact",
                    textValue: contactInfo,
                  ),
                ],
              ),
            ),

            // Address Area
            Container(
              width: MyDimensionAdapter.getWidth(context) * 0.80,
              height: 75,
              padding: EdgeInsets.fromLTRB(7, 7, 7, 4),
              margin: EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(
                color: Colors.white10,
                border: BoxBorder.all(color: Colors.white, width: 1.2),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(31, 0, 42, 100),
                    blurRadius: 4,
                    blurStyle: BlurStyle.outer,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              // color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  flexibleSizedContainers(
                    flex: 2,
                    textValueSize: 15,
                    isPossibleToContainLongValue: true,
                    textLabel: "Address",
                    textValue: address,
                  ),
                ],
              ),
            ),

            // Notable Trait Area
            Container(
              width: MyDimensionAdapter.getWidth(context) * 0.80,
              height: 100,
              padding: EdgeInsets.fromLTRB(7, 7, 7, 4),
              margin: EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(
                color: Colors.white10,
                border: BoxBorder.all(color: Colors.white, width: 1.2),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(31, 0, 42, 100),
                    blurRadius: 4,
                    blurStyle: BlurStyle.outer,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              // color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  flexibleSizedContainers(
                    flex: 2,
                    textValueSize: 15,
                    isPossibleToContainLongValue: true,
                    textLabel: "Notable Behavior",
                    // "Often found lying in bed, or sitting in the living room. Needs regular monitoring.",
                    // textValue: notableBehavior,
                    textValue: patientID,
                  ),
                ],
              ),
            ),

            Container(
              width: MyDimensionAdapter.getWidth(context) * 0.8,
              height: 60,
              padding: EdgeInsets.fromLTRB(7, 7, 7, 4),
              margin: EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(
                color: Colors.white10,
                border: BoxBorder.all(color: Colors.white, width: 1.2),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(31, 0, 42, 100),
                    blurRadius: 4,
                    blurStyle: BlurStyle.outer,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  fixedSizedContainers(
                    width: MyDimensionAdapter.getWidth(context) * 0.12,
                    textLabel: "Is Safe",
                    textValue: (isCurrentlySafe) ? "YES" : "NO",
                    valueColor: (isCurrentlySafe)
                        ? Colors.blue.shade400
                        : Colors.red.shade400,
                  ),
                  verticalLine(context),
                  fixedSizedContainers(
                    width: MyDimensionAdapter.getWidth(context) * 0.12,
                    textLabel: "Battery",
                    textValue: "${batteryPercentage.toString()}%",
                  ),
                  verticalLine(context),
                  fixedSizedContainers(
                    // flex: 16,
                    width: MyDimensionAdapter.getWidth(context) * 0.45,
                    textLabel: "Device ID",
                    textValue: deviceID,
                    textValueSize: kDefaultFontSize - 1,
                  ),
                ],
              ),
            ),

            // Button
            MyCustButton(
              buttonText: "Check Patient",
              buttonTextColor: Colors.white,
              buttonTextFontWeight: FontWeight.w600,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return PatientDetailsPage(
                        // patientID: patientID,
                        // name: name,
                        personalInfo: PersonalInfo(
                          userID: patientID,
                          userType: "Patient",
                          name: name,
                          age: age,
                          sex: sex,
                          birthdate: "",
                          contactNumber: contactInfo,
                          address: address,
                          notableBehavior: notableBehavior,
                          picture: profilePicture,
                          createdAt: "",
                          lastUpdatedAt: "",
                          registeredBy: "",
                          asignedCaregiver: "",
                          deviceID: deviceID,
                          email: email,
                        ),
                        batteryPercentage: batteryPercentage,
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

// for visual separation purposes only
MyLine verticalLine(BuildContext context) {
  return MyLine(
    length: MyDimensionAdapter.getHeight(context) * 0.04,
    isRounded: true,
    color: Colors.grey.shade400,
  );
}

Flexible flexibleSizedContainers({
  int flex = 1,
  String textValue = "NO VALUE",
  String textLabel = "NO LABEL",
  double textLabelSize = kDefaultFontSize - 4,
  double textValueSize = kDefaultFontSize + 2,
  bool isPossibleToContainLongValue = false,
  double? width,
}) {
  return Flexible(
    flex: flex,
    child: Container(
      width: width,
      // decoration: BoxDecoration(color: Colors.green),
      child: Column(
        //// experimental layout
        // crossAxisAlignment: (isPossibleToContainLongValue)
        //     ? CrossAxisAlignment.start
        //     : CrossAxisAlignment.center,
        children: [
          MyTextFormatter.p(
            text: textLabel,
            fontsize: textLabelSize,
            fontWeight: FontWeight.w400,
          ),
          Text(
            // if walay sulod and textValue, kani ang default nga e display
            (textValue == "") ? "NO DATA TO DISPLAY HERE ..." : textValue,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: (isPossibleToContainLongValue) ? 2 : 1,
            style: TextStyle(
              // if walay sulod and textValue, kani ang default nga e display
              color: (textValue == "")
                  ? Colors.grey.shade500.withAlpha(200)
                  : Colors.grey.shade800,
              fontSize: textValueSize,
              fontWeight: FontWeight.w600,
              // if walay sulod and textValue, kani ang default nga e display
              fontStyle: (textValue == "")
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

Container fixedSizedContainers({
  String textValue = "NO VALUE",
  String textLabel = "NO LABEL",
  double textLabelSize = kDefaultFontSize - 4,
  double textValueSize = kDefaultFontSize + 2,
  bool isPossibleToContainLongValue = false,
  Color? valueColor,
  required double width,
}) {
  return Container(
    width: width,
    child: Column(
      children: [
        MyTextFormatter.p(
          text: textLabel,
          fontsize: textLabelSize,
          fontWeight: FontWeight.w400,
        ),
        Text(
          // if walay sulod and textValue, kani ang default nga e display
          (textValue == "") ? "NO DATA TO DISPLAY HERE ..." : textValue,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: (isPossibleToContainLongValue) ? 2 : 1,
          style: TextStyle(
            // if walay sulod and textValue, kani ang default nga e display
            color: (textValue == "")
                ? Colors.grey.shade500.withAlpha(200)
                : valueColor ?? Colors.grey.shade800,
            fontSize: textValueSize,
            fontWeight: FontWeight.w600,
            // if walay sulod and textValue, kani ang default nga e display
            fontStyle: (textValue == "") ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    ),
  );
}
