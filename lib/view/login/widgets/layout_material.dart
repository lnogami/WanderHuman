import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

class MyLayoutMaterial extends StatelessWidget {
  final double distanceFromTop;

  /// Determines if the material is a square, must use isSquareSize
  final bool isSquare;

  /// Used with isSquare = true
  final double? isSquareSize;

  /// The width is automatically adjusted base on the screensize, so the widthPercentage is the ratio of how much of the screen you want to occupy.
  final double widthPercentage;

  /// The height is automatically adjusted base on the screensize, so the heightPercentage is the ratio of how much of the screen you want to occupy.
  final double heightPercentage;
  final Color color;
  final double borderRadius;

  /// Rotatable by default, must set to false if with contents that should not be upside down.
  final bool isRotatable;

  /// Does not work if isRotatable is set to false.
  final double rotationAngle;

  /// The Widget to be put inside the LayoutMaterial
  final Widget child;

  /// this is a widget I created for the purpose of my own design style.
  const MyLayoutMaterial({
    super.key,
    required this.distanceFromTop,
    this.isSquare = false,
    this.isSquareSize,
    this.widthPercentage = 1.0,
    this.heightPercentage = 1.0,
    this.color = Colors.white,
    this.borderRadius = 0,
    this.isRotatable = true,
    this.rotationAngle = 1,
    this.child = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: distanceFromTop,
      child: Container(
        width: (isSquare)
            ? isSquareSize!
            : (MyDimensionAdapter.getHeight(context) * widthPercentage),
        height: (isSquare)
            ? isSquareSize
            : (MyDimensionAdapter.getHeight(context) * heightPercentage),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        transform: Matrix4.rotationZ((isRotatable) ? (pi / -rotationAngle) : 0),
        transformAlignment: Alignment.center,
        child: Center(child: child),
      ),
    );
  }
}
