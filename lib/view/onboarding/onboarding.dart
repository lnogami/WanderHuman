import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});
  // the base distance of each layout
  final double _distanceFromTop = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context),
        color: Colors.amber.shade100,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: _distanceFromTop + 20,
              child: Container(
                width: MyDimensionAdapter.getWidth(context) + 100,
                height: MyDimensionAdapter.getWidth(context) * 0.25,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: BoxBorder.all(color: Colors.blue),
                  // borderRadius: BorderRadius.circular(30),
                ),
                transform: Matrix4.rotationZ(pi / -10.5),
                transformAlignment: Alignment.center,
              ),
            ),
            Positioned(
              top: _distanceFromTop,
              child: Container(
                width: MyDimensionAdapter.getWidth(context) * 0.35,
                height: MyDimensionAdapter.getWidth(context) * 0.35,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: BoxBorder.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(30),
                ),
                // transform: Matrix4.rotationZ(pi / 2.5),
                transform: Matrix4.rotationZ(pi / -10.5),
                transformAlignment: Alignment.center,
                child: Text("Hello, World!"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
