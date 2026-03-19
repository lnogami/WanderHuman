import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/lines.dart';

/// Will contain all the animations I could possible make
class MyAnimations {
  /// This widget belongs to HomePatientListDropDownState where it could be found in HomePage
  static Stack homeDropDownIconButton(
    BuildContext context, {
    required double width,
    required double height,
    required bool isExpanded,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          top: (height / 2) - (height / ((isExpanded) ? 2.2 : 2)),
          right: (width / 2) - (width / ((isExpanded) ? 3.5 : 2.5)),
          child: Icon(
            Icons.person_rounded,
            size: 25,
            color: const Color.fromARGB(255, 146, 146, 146),
            shadows: [Shadow(color: Colors.white, blurRadius: 4)],
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          top: (height / 2) - (height / (isExpanded ? 1.35 : 3.5)),
          left: (width / 2) - (width / (isExpanded ? 2.25 : 3)),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            // We create a custom value from 0.0 to 1.0 to act as our animation slider
            tween: Tween<double>(
              begin: isExpanded ? 0.0 : 1.0,
              end: isExpanded ? 1.0 : 0.0,
            ),
            builder: (context, value, child) {
              return Icon(
                Icons.search_rounded,
                // Smoothly morphs size from 20 to 48
                size: 20.0 + (28.0 * value),
                // Smoothly blends the grey into the blue
                color: Color.lerp(
                  Colors.grey.shade700,
                  Colors.blue.shade600,
                  value,
                ),
                shadows: [
                  Shadow(
                    color: Colors.white,
                    // Smoothly shrinks the blur radius from 6 to 4
                    blurRadius: 6.0 - (2.0 * value),
                  ),
                ],
              );
            },
          ),
        ),

        // Horizontal Line
        if (isExpanded)
          Positioned(
            bottom: 0,
            child: MyLine(
              length: MyDimensionAdapter.getWidth(context) * 0.1,
              isVertical: false,
              margin: 0,
            ),
          ),
      ],
    );
  }
}
