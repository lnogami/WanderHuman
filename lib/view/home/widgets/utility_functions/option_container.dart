// this will serve as an option button.
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/color_palette.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

Container optionsContainer(
  BuildContext context,
  IconData icon,
  String text, {
  required VoidCallback onTap,
  Color bgColor = const Color.fromARGB(100, 33, 149, 243),
}) {
  return Container(
    width: MyDimensionAdapter.getWidth(context) * 0.35,
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
            Text(text),
          ],
        ),
      ),
    ),
  );
}
