import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

/// a Dialog box for Information purposes only (has a single button only)
void myInfoDialogue({
  required BuildContext context,
  String alertTitle = "Info",
  required String alertContent,
  // Color barrierColor = const Color.fromARGB(180, 60, 84, 104),
  // Color barrierColor = const Color.fromARGB(108, 0, 14, 24),
  Color barrierColor = const Color.fromARGB(73, 188, 225, 255),
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
            child: MyTextFormatter.h3(
              text: onPressText,
              color: onPressTextColor,
              fontWeight: FontWeight.w400,
              textSpace: 1.2,
            ),
          ),
        ],
      );
    },
  );
}
