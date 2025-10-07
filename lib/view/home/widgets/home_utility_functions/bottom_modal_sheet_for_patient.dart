import 'package:flutter/material.dart';
import 'package:wanderhuman_app/components/button.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/view_patient_details/patient_details_page.dart';

void showMyBottomNavigationSheet({
  required BuildContext context,
  required String name,
  required String age,
  required String sex,
  required String contactInfo,
  required String address,
  required String notableBehavior,
  // String profilePicture,   // not yet implemented
}) {
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
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: MyDimensionAdapter.getWidth(context) * .30,
                  height: 8,
                  color: Colors.grey,
                ),
              ),
            ),

            // Picture of the Patient
            Positioned(
              top: 45,
              child: CircleAvatar(
                backgroundColor: Colors.blue.withAlpha(200),
                radius: 45,
              ),
            ),

            // Name of the Patient
            Positioned(
              top: 145,
              child: Text(
                name,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            // Primary Details Area
            Positioned(
              top: 200,
              child: Container(
                width: MyDimensionAdapter.getWidth(context) - 40,
                height: 55,
                // color: Colors.amber,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    flexibleSizedContainers(
                      flex: 2,
                      textLabel: "Age",
                      textValue: age,
                    ),
                    verticalLine(),
                    flexibleSizedContainers(
                      flex: 4,
                      textLabel: "Sex",
                      textValue: sex,
                    ),
                    verticalLine(),
                    flexibleSizedContainers(
                      flex: 8,
                      textLabel: "Guardian's Contact",
                      textValue: contactInfo,
                    ),
                  ],
                ),
              ),
            ),

            // Address Area
            Positioned(
              top: 275,
              child: Container(
                width: MyDimensionAdapter.getWidth(context) - 40,
                height: 75,
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
            ),

            // Notable Trait Area
            Positioned(
              top: 365,
              child: Container(
                width: MyDimensionAdapter.getWidth(context) - 40,
                height: 100,
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
            ),

            // Button
            Positioned(
              top: 480,
              child: MyCustButton(
                buttonText: "Check Patient",
                buttonTextColor: Colors.white,
                buttonTextFontWeight: FontWeight.w600,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return PatientDetailsPage(name: name);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

// for visual separation purposes only
Container verticalLine({Color color = Colors.grey}) {
  return Container(
    width: 1,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: color,
    ),
  );
}

Flexible flexibleSizedContainers({
  int flex = 1,
  String textValue = "NO VALUE",
  String textLabel = "NO LABEL",
  double textLabelSize = 12,
  double textValueSize = 18,
  bool isPossibleToContainLongValue = false,
}) {
  return Flexible(
    flex: flex,
    child: Container(
      // decoration: BoxDecoration(color: Colors.green),
      child: Column(
        //// experimental layout
        // crossAxisAlignment: (isPossibleToContainLongValue)
        //     ? CrossAxisAlignment.start
        //     : CrossAxisAlignment.center,
        children: [
          Text(
            textLabel,
            style: TextStyle(
              fontSize: textLabelSize,
              fontWeight: FontWeight.w400,
            ),
          ),
          (isPossibleToContainLongValue) ? SizedBox(height: 10) : Spacer(),
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
                  : const Color.fromARGB(255, 13, 13, 14),
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
