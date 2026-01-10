import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';

/// [onPressed] is a callback function (){}
/// A Dialog that is primary used for decision making (Yes/No)
void myAlertDialogue({
  required BuildContext context,
  String alertTitle = "Alert",
  String alertContent = "Are you sure?",
  Color barrierColor = const Color.fromARGB(180, 60, 84, 104),
  required VoidCallback onApprovalPressed,
  String onApprovalButtonText = "Yes",
  Color onApprovalButtonColor = MyColorPalette.splashColor,
  Color onApprovalButtonTextColor = Colors.white,
}) {
  showDialog(
    context: context,
    barrierColor: barrierColor,
    // fullscreenDialog: true,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(alertTitle),
        content: Text(
          alertContent,
          style: TextStyle(fontSize: kDefaultFontSize),
        ),

        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("No"),
          ),
          MaterialButton(
            color: onApprovalButtonColor,
            onPressed: onApprovalPressed,
            child: Text(
              onApprovalButtonText,
              style: TextStyle(color: onApprovalButtonTextColor),
            ),
          ),
        ],
      );
    },
  );
}
