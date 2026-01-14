import 'package:flutter/material.dart';

class MyLine extends StatelessWidget {
  final bool isVertical;
  final double length;
  final double thickness;
  final Color color;
  final bool isRounded;
  const MyLine({
    super.key,
    this.isVertical = true,
    required this.length,
    this.thickness = 1,
    this.color = Colors.black26,
    this.isRounded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Container(
        width: thickness,
        height: length,
        decoration: BoxDecoration(
          color: color,
          borderRadius: isRounded ? BorderRadius.circular(10) : null,
        ),
        margin: EdgeInsets.symmetric(horizontal: 5),
      );
    } else {
      return Container(
        width: length,
        height: thickness,
        decoration: BoxDecoration(
          color: color,
          borderRadius: isRounded ? BorderRadius.circular(10) : null,
        ),
        margin: EdgeInsets.symmetric(vertical: 5),
      );
    }
  }
}
