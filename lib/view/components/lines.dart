import 'package:flutter/material.dart';

class MyLine extends StatelessWidget {
  final bool isVertical;
  final double length;
  final double thickness;
  final Color color;
  const MyLine({
    super.key,
    this.isVertical = true,
    required this.length,
    this.thickness = 1,
    this.color = Colors.black26,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Container(
        width: thickness,
        height: length,
        color: color,
        margin: EdgeInsets.symmetric(horizontal: 5),
      );
    } else {
      return Container(
        width: length,
        height: thickness,
        color: color,
        margin: EdgeInsets.symmetric(vertical: 5),
      );
    }
  }
}
