import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

class MyGradients {
  /// This is Stack layout associated.
  static Positioned fadingBottomGradient(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: 40,
        decoration: BoxDecoration(
          // color: Colors.amber.withAlpha(100),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white10, Colors.white30, MyColorPalette.formColor],
          ),
        ),
      ),
    );
  }
}
