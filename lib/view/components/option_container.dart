// this will serve as an option button.
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

// /// This is a button inside the home_appbar
// Container optionsContainer(
//   BuildContext context,
//   IconData icon,
//   String text, {
//   double buttonWidthMultiplier = 1,
//   double fontSize = kDefaultFontSize,

//   /// Pass here an anonymous function (){}
//   required VoidCallback onTap,
//   Color bgColor = const Color.fromARGB(100, 33, 149, 243),
// }) {
//   return Container(
//     width:
//         MyDimensionAdapter.getWidth(context) *
//         ((buttonWidthMultiplier == 1) ? 0.35 : buttonWidthMultiplier),
//     height: 55,
//     // padding: EdgeInsets.only(left: 5, right: 10),
//     decoration: BoxDecoration(
//       color: bgColor,
//       borderRadius: BorderRadius.all(Radius.circular(5)),
//     ),
//     child: Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.all(Radius.circular(5)),
//         splashColor: MyColorPalette.splashColor,
//         onTap: () {
//           onTap();
//         },
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Icon(icon, color: Colors.black87),
//             Text(
//               text,
//               style: TextStyle(
//                 fontSize: fontSize,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

/// This is a button inside the home_appbar. <br>
/// There are themes for this buttons. Just assign an appropriate number to <br>
/// ```
/// appbarOptionButtonStyle = 1
/// ```
Container optionsContainer(
  BuildContext context,
  IconData icon,
  String text, {
  double buttonWidthMultiplier = 1,
  double fontSize = kDefaultFontSize,

  /// Pass here an anonymous function (){}
  required VoidCallback onTap,
  // Color bgColor = const Color.fromARGB(100, 33, 149, 243),
  // Color bgColor = const Color.fromARGB(67, 31, 152, 252),
  Color? bgColor,
  // This will determine what theme/style of buttons the options will be
  int appbarOptionButtonsStyle = 0,
}) {
  if (appbarOptionButtonsStyle == 0) {
    bgColor = bgColor ?? const Color.fromARGB(100, 240, 246, 255);

    return Container(
      width:
          MyDimensionAdapter.getWidth(context) *
          ((buttonWidthMultiplier == 1) ? 0.35 : buttonWidthMultiplier),
      height: 55,
      // padding: EdgeInsets.only(left: 5, right: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(7)),
        border: BoxBorder.all(width: 2, color: Colors.white),
        boxShadow: [
          BoxShadow(
            // color: Colors.black26,
            color: const Color.fromARGB(70, 0, 104, 189),
            offset: Offset(0, 0),
            blurRadius: 3,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          splashColor: MyColorPalette.splashColor,
          onTap: () {
            onTap();
          },
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(icon, color: Colors.black87),
              Icon(
                icon,
                color: (text != "Logout")
                    ? const Color.fromARGB(200, 30, 136, 229)
                    : const Color.fromARGB(159, 80, 117, 150),
              ),
              Container(
                width: MyDimensionAdapter.getWidth(context) * 0.18,
                // color: Colors.amber,
                margin: EdgeInsets.only(left: 5),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    overflow: TextOverflow.ellipsis,
                    height: 1.1,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Bluish White Transparent
  else if (appbarOptionButtonsStyle == 1) {
    bgColor = bgColor ?? const Color.fromARGB(100, 198, 223, 255);
    return Container(
      width:
          MyDimensionAdapter.getWidth(context) *
          ((buttonWidthMultiplier == 1) ? 0.35 : buttonWidthMultiplier),
      height: 55,
      // padding: EdgeInsets.only(left: 5, right: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(7)),
        border: BoxBorder.all(width: 2, color: Colors.white),
        boxShadow: [
          BoxShadow(
            // color: Colors.black26,
            color: const Color.fromARGB(70, 0, 104, 189),
            offset: Offset(0, 0),
            blurRadius: 3,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          splashColor: MyColorPalette.splashColor,
          onTap: () {
            onTap();
          },
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(icon, color: Colors.black87),
              Icon(icon, color: const Color.fromARGB(180, 25, 118, 210)),
              Container(
                width: MyDimensionAdapter.getWidth(context) * 0.18,
                // color: Colors.amber,
                margin: EdgeInsets.only(left: 5),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    height: 1.1,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } else {
    return Container(
      width:
          MyDimensionAdapter.getWidth(context) *
          ((buttonWidthMultiplier == 1) ? 0.35 : buttonWidthMultiplier),
      height: 55,
      // padding: EdgeInsets.only(left: 5, right: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          splashColor: MyColorPalette.splashColor,
          onTap: () {
            onTap();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(icon, color: Colors.black87),
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
