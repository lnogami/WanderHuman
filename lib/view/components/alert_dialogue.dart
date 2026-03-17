// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
// import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

// /// [onPressed] is a callback function (){}
// /// A Dialog that is primary used for decision making (Yes/No)
// void myAlertDialogue({
//   required BuildContext context,
//   String alertTitle = "Alert",
//   String alertContent = "Are you sure?",
//   Color barrierColor = const Color.fromARGB(180, 60, 84, 104),
//   required VoidCallback onApprovalPressed,
//   String onApprovalButtonText = "Yes",
//   Color onApprovalButtonColor = MyColorPalette.splashColor,
//   Color onApprovalButtonTextColor = Colors.white,
//   String onCancelButtonText = "No",
// }) {
//   showDialog(
//     context: context,
//     barrierColor: barrierColor,
//     // fullscreenDialog: true,
//     builder: (context) {
//       return CupertinoAlertDialog(
//         title: Text(alertTitle),
//         content: Text(
//           alertContent,
//           style: TextStyle(fontSize: kDefaultFontSize),
//         ),

//         actions: [
//           // MaterialButton(
//           //   onPressed: () {
//           //     Navigator.pop(context);
//           //   },
//           //   child: Text(onCancelButtonText),
//           // ),
//           // MaterialButton(
//           //   color: onApprovalButtonColor,
//           //   onPressed: onApprovalPressed,
//           //   child: Text(
//           //     onApprovalButtonText,
//           //     style: TextStyle(color: onApprovalButtonTextColor),
//           //   ),
//           // ),
//           Center(
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Container(
//                 padding: EdgeInsets.all(7),
//                 child: Text(onCancelButtonText),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: onApprovalPressed,
//             child: Container(
//               width: MyDimensionAdapter.getWidth(context) * 0.4,
//               color: onApprovalButtonColor,
//               alignment: Alignment.center,
//               child: Text(
//                 onApprovalButtonText,
//                 style: TextStyle(color: onApprovalButtonTextColor),
//               ),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

/// [onPressed] is a callback function (){}
/// A Dialog that is primary used for decision making (Yes/No)
void myAlertDialogue({
  required BuildContext context,
  String alertTitle = "Alert",
  String alertContent = "Are you sure?",
  Color barrierColor = const Color.fromARGB(180, 60, 84, 104),
  bool isDismissible = true,
  required VoidCallback onApprovalPressed,
  String onApprovalButtonText = "Yes",
  // Color onApprovalButtonColor = MyColorPalette.splashColor,
  Color onApprovalButtonColor = const Color.fromARGB(255, 26, 139, 232),
  Color onApprovalButtonTextColor = Colors.white,
  String onCancelButtonText = "No",
}) {
  showCupertinoDialog(
    barrierColor: barrierColor,
    context: context,
    barrierDismissible: isDismissible,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(alertTitle),
        content: Text(
          alertContent,
          // style: TextStyle(fontSize: kDefaultFontSize),
        ),

        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: MyTextFormatter.p(
              text: onCancelButtonText,
              color: Colors.grey.shade800,
            ),
          ),
          CupertinoDialogAction(
            onPressed: onApprovalPressed,
            child: MyTextFormatter.p(
              text: onApprovalButtonText,
              color: onApprovalButtonColor,
              fontWeight: FontWeight.w600,
              fontsize: kDefaultFontSize + 2.5,
            ),
          ),
        ],
      );
    },
  );
}
