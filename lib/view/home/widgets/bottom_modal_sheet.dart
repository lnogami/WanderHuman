import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/font_family.dart';

void bottomModalSheet(BuildContext context) {
  // first container
  double firstContainerDistanceFromTheTop = 50;
  double firstContainerHeight = 110;
  // second container
  double secondContainerDistanceFromTheTop =
      firstContainerHeight + firstContainerDistanceFromTheTop;
  double secondContainerHeight = 50;
  // third container
  double thirdContainerDistanceFromTheTop =
      secondContainerDistanceFromTheTop + secondContainerHeight;
  double thirdContainerHeight = 250;
  double lineBreakTotalHeight = 10.0;
  // button distance from the top
  double buttonDistanceFromTheTop =
      thirdContainerDistanceFromTheTop + thirdContainerHeight;

  showModalBottomSheet(
    context: context,
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
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: MyDimensionAdapter.getWidth(context) * 0.4,
                  height: 8,
                  color: Colors.grey[350],
                ),
              ),
            ),
            // this is the first container
            Positioned(
              top: firstContainerDistanceFromTheTop,
              right: 20,
              child: CircleAvatar(
                // this will occupy 12.5% (0.125) of the screen width
                radius: MyDimensionAdapter.getWidth(context) * 0.125,
                child: Icon(Icons.person_rounded, color: Colors.blue),
              ),
            ),
            // this is the first container
            Positioned(
              top: firstContainerDistanceFromTheTop,
              left: 20,
              child: Container(
                width: MyDimensionAdapter.getWidth(context) * 0.65,
                height: firstContainerHeight,
                // color: Colors.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hori Zontal",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    shortTextLayouter(constText: "Age", dynamicText: "{125}"),
                    shortTextLayouter(
                      constText: "Gender",
                      dynamicText: "{Female}",
                    ),
                    shortTextLayouter(
                      constText: "Contact Info.",
                      dynamicText: "{09876543210}",
                    ),
                  ],
                ),
              ),
            ),
            // this is the second container
            // it is inside an automatically adjusting layouter.
            Positioned(
              top: secondContainerDistanceFromTheTop,
              left: 20,
              child: detailsWithLongTextLayouter(
                context,
                "Address",
                "{Purok Durian Mankilam, Tagum City, Davao del Norte}",
                containerHeight: secondContainerHeight,
              ),
            ),
            // this is the third container
            Positioned(
              top: thirdContainerDistanceFromTheTop,
              child: Container(
                width: MyDimensionAdapter.getWidth(context) - 40,
                height: thirdContainerHeight,
                // color: Colors.amber,
                child: Column(
                  children: [
                    // this is just a line break
                    lineBreak(context, lineBreakTotalHeight),
                    detailsWithLongTextLayouter(
                      context,
                      "Notable Trait",
                      constFontSize: 13,
                      "{Alternates between active and disoriented; often found lying in bed or sitting in the living room; needs regular monitoring.}",
                      // the - 12 is for the bottom margin of the line break
                      // - 2 is just an allowance of the lineBreak
                      containerHeight:
                          thirdContainerHeight - (lineBreakTotalHeight * 2) - 2,
                      noBorder: true,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: buttonDistanceFromTheTop + 10,
              child: Column(
                children: [
                  lineBreak(context, lineBreakTotalHeight),
                  Text(
                    // this is the constant text, meaning this one is predefined and will not change
                    "Check Patient",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
    // this property removes the default limit of the modal bottom sheet (.50 of the screen height)
    isScrollControlled: true,
  );
}

Row shortTextLayouter({
  required String constText,
  required String dynamicText,
  // temporary font family yet
  String fontFamily = MyFontFam.iansui,
  double constFontSize = 14,
}) {
  return Row(
    children: [
      Text(
        "$constText: ",
        style: TextStyle(
          fontSize: constFontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
      Text(
        dynamicText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.2,
          // temporary font family yet
          fontFamily: fontFamily,
        ),
      ),
    ],
  );
}

// this is a visual line break
Container lineBreak(BuildContext context, double lineBreakTotalHeight) {
  return Container(
    width: MyDimensionAdapter.getWidth(context) - 40,
    height: 1.0,
    margin: EdgeInsets.only(bottom: lineBreakTotalHeight),
    color: Colors.grey[350],
  );
}

/* 
  this is a container that will automatically adjust the width of dynamicText's 
  container in accordance to the length of the constText
*/
Container detailsWithLongTextLayouter(
  BuildContext context,
  String constText,
  String dynamicText, {
  double constFontSize = 14,
  double containerHeight = 50,
  bool noBorder = false,
}) {
  return Container(
    width: MyDimensionAdapter.getWidth(context) - 40,
    height: containerHeight,
    // color: Colors.greenAccent,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // this is the constant text, meaning this one is predefined and will not change
          "$constText: ",
          style: TextStyle(
            fontSize: constFontSize,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
          softWrap: true,
        ),
        Container(
          // color: Colors.green,
          /*
            what's happening here is that the width of this dynamicText 
            container will automatically adjust with accordance to the length 
            of constText.
          */
          width:
              MyDimensionAdapter.getWidth(context) -
              (constText.length * 10) -
              ((noBorder) ? 20 : 40),
          height: containerHeight,
          child: Text(
            // this is the dynamic text
            dynamicText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.1,
            ),
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}
