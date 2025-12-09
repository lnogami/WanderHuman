// this will serve as an option button.
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/color_palette.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

/// This is a button inside the home_appbar
Container optionsContainer(
  BuildContext context,
  IconData icon,
  String text, {
  double buttonWidthMultiplier = 1,

  /// Pass here an anonymous function (){}
  required VoidCallback onTap,
  Color bgColor = const Color.fromARGB(100, 33, 149, 243),
}) {
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
            Text(text, style: TextStyle(overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    ),
  );
}
