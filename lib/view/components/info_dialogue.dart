import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';

/// a Dialog box for Information purposes only (has a single button only)
void myInfoDialogue({
  required BuildContext context,
  String alertTitle = "Info",
  required String alertContent,
  Color barrierColor = const Color.fromARGB(180, 60, 84, 104),
  VoidCallback? onPress,
  String onPressText = "Yes",
  Color onPressColor = MyColorPalette.splashColor,
  Color onPressTextColor = Colors.white,
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
            color: onPressColor,
            onPressed:
                onPress ??
                () {
                  Navigator.pop(context);
                },
            child: Text("Okay", style: TextStyle(color: onPressTextColor)),
          ),
        ],
      );
    },
  );
}
