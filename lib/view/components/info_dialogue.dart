import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

/// a Dialog box for Information purposes only (has a single button only)
void myInfoDialogue({
  required BuildContext context,
  String alertTitle = "Info",
  required String alertContent,
  Color barrierColor = const Color.fromARGB(180, 60, 84, 104),
  VoidCallback? onPress,
  bool isDismissible = true,
  String onPressText = "Yes",
  Color onPressColor = const Color.fromARGB(255, 26, 139, 232),
  Color onPressTextColor = Colors.white,
}) {
  // showDialog(
  //   context: context,
  //   barrierColor: barrierColor,
  //   // fullscreenDialog: true,
  //   builder: (context) {
  //     return CupertinoAlertDialog(
  //       title: Text(alertTitle),
  //       content: Text(
  //         alertContent,
  //         style: TextStyle(fontSize: kDefaultFontSize),
  //       ),
  //       actions: [
  //         MaterialButton(
  //           color: onPressColor,
  //           onPressed:
  //               onPress ??
  //               () {
  //                 Navigator.pop(context);
  //               },
  //           child: MyTextFormatter.h3(
  //             text: onPressText,
  //             color: onPressTextColor,
  //             fontWeight: FontWeight.w400,
  //             textSpace: 1.2,
  //           ),
  //         ),
  //       ],
  //     );
  //   },
  // );

  showCupertinoDialog(
    barrierColor: barrierColor,
    context: context,
    barrierDismissible: isDismissible,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(alertTitle),
        insetAnimationDuration: Duration(milliseconds: 400),
        insetAnimationCurve: Curves.bounceInOut,
        content: Text(
          alertContent,
          // style: TextStyle(fontSize: kDefaultFontSize),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: onPress,
            child: MyTextFormatter.p(
              text: onPressText,
              color: onPressColor,
              fontWeight: FontWeight.w600,
              fontsize: kDefaultFontSize + 2.5,
            ),
          ),
        ],
      );
    },
  );
}
