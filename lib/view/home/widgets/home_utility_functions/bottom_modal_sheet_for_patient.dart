import 'dart:developer';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/userRolesUI/patient/patient_details_page.dart';

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
        height: MyDimensionAdapter.getHeight(context) * 0.835,
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
              thickness: 4,
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
            MyTextFormatter.h3(
              text: name,
              fontsize: kDefaultFontSize + 10,
              lineHeight: 1,
            ),
            SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     MyTextFormatter.p(
            //       text: "is currently in ",
            //       fontsize: kDefaultFontSize - 4,
            //       color: Colors.grey.shade600,
            //     ),
            //     MyTextFormatter.p(
            //       text: currentlyIn,
            //       fontsize: kDefaultFontSize - 4,
            //       fontWeight: FontWeight.w600,
            //       color: Colors.grey.shade700,
            //     ),
            //   ],
            // ),
            // SizedBox(height: 15),

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
                    textValue: notableBehavior,
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //// (deletable) old code, updated version is the isCurrentlySafeArea(context, isCurrentlySafe),
                  // fixedSizedContainers(
                  //   width: MyDimensionAdapter.getWidth(context) * 0.12,
                  //   textLabel: "Is Safe",
                  //   textValue: (isCurrentlySafe) ? "YES" : "NO",
                  //   valueColor: (isCurrentlySafe)
                  //       ? Colors.blue.shade400
                  //       : Colors.red.shade400,
                  // ),
                  isCurrentlySafeArea(
                    context,
                    isCurrentlySafe: isCurrentlySafe,
                    deviceID: deviceID,
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

            MyCustTooltip(
              triggerMode: TooltipTriggerMode.tap,
              message: ((currentlyIn == "Unknown"))
                  ? "No beacons detected nearby, the patient is not in a known location."
                  : "This indicates the indoor location of the patient, which is determined by the beacones.",
              opacity: 200,
              child: Container(
                width: MyDimensionAdapter.getWidth(context) * 0.80,
                padding: EdgeInsets.only(top: 1.5, bottom: 1.5),
                margin: EdgeInsets.only(bottom: 15),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyTextFormatter.p(
                      text: "is currently in ",
                      fontsize: kDefaultFontSize - 4,
                      color: Colors.grey.shade700,
                    ),
                    MyTextFormatter.p(
                      text: currentlyIn,
                      fontsize: kDefaultFontSize - 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ],
                ),
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

Container isCurrentlySafeArea(
  BuildContext context, {
  required bool isCurrentlySafe,
  required String deviceID,
}) {
  return Container(
    width: MyDimensionAdapter.getWidth(context) * 0.12,
    // height: MyDimensionAdapter.getHeight(context) * 0.12,
    child: Column(
      children: [
        MyTextFormatter.p(text: "Is Safe", fontsize: kDefaultFontSize - 4),
        (isCurrentlySafe)
            ? MyCustTooltip(
                triggerMode: TooltipTriggerMode.tap,
                message:
                    "Tap this again when the patient is in danger to assess the situation.",
                child: MyTextFormatter.p(
                  text: "YES",
                  color: Colors.blue.shade400,
                  fontsize: kDefaultFontSize + 2,
                  fontWeight: FontWeight.w600,
                ),
              )
            : AnimatedTextKit(
                onTap: () {
                  myAlertDialogue(
                    context: context,
                    alertTitle: "Confirm Patient Status",
                    alertContent: "Confirm that this patient is now okay?",
                    onApprovalButtonText: "Acknowledge",
                    onCancelButtonText: "Not yet",
                    onApprovalPressed: () async {
                      await MyRealtimeLocationReposity.updateASingleField(
                        deviceID: deviceID,
                        fieldToUpdate: "isCurrentlySafe",
                        value: "true",
                        isABooleanValue: true,
                      );

                      log(
                        "SUCCESSFULLY UPDATED PATIENT STATUS TO SAFEEEEEEEEEEE",
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context); // removes the dialog box
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context); // removes the bottom sheet
                    },
                  );
                },
                repeatForever: true,
                pause: Duration(milliseconds: 0),
                animatedTexts: [
                  FlickerAnimatedText(
                    "NO",
                    textStyle: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: kDefaultFontSize + 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ],
    ),
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
