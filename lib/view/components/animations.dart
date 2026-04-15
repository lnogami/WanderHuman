import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/lines.dart';

/// Will contain all the animations I could possible make
class MyAnimations {
  /// This widget belongs to HomePatientListDropDownState where it could be found in HomePage
  static Container homeDropDownIconButton(
    BuildContext context, {
    required double width,
    required double height,
    required bool isExpanded,
  }) {
    return Container(
      width: width,
      height: height,
      // width: 50,
      // height: 30,
      alignment: Alignment.center,
      child: Stack(
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
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:wanderhuman_app/view/components/lines.dart';

// /// Will contain all the animations I could possible make
// class MyAnimations {
//   /// This widget belongs to HomePatientListDropDownState where it could be found in HomePage
//   static Widget homeDropDownIconButton(
//     BuildContext context, {
//     required double width,
//     required double height,
//     required bool isExpanded,
//   }) {
//     // ✅ FIX 1: Wrap everything in a SizedBox to lock the bounds.
//     // Now, all alignments happen strictly within this tiny box, NOT the whole screen!
//     return SizedBox(
//       width: width,
//       height: height,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // --- PERSON ICON ---
//           // ✅ FIX 2: Replaced AnimatedPositioned with AnimatedAlign.
//           // Alignment uses percentages (-1.0 to 1.0). (0,0) is dead center.
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 400),
//             curve: Curves.easeInOut,
//             // Adjust these values to nudge the person exactly where you want them!
//             alignment: isExpanded
//                 ? const Alignment(0.3, -0.2) // Slightly right/up when open
//                 : const Alignment(0.5, 0.0), // Further right when closed
//             child: Icon(
//               Icons.person_rounded,
//               size: 25,
//               color: const Color.fromARGB(255, 146, 146, 146),
//               shadows: const [Shadow(color: Colors.white, blurRadius: 4)],
//             ),
//           ),

//           // --- SEARCH ICON ---
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 400),
//             curve: Curves.easeInOut,
//             // Adjust these values to nudge the search glass where it needs to land
//             alignment: isExpanded
//                 ? const Alignment(
//                     -0.2,
//                     -0.2,
//                   ) // Moves slightly top-left to encapsulate the person
//                 : const Alignment(0.0, 0.0), // Sits dead center when closed
//             child: TweenAnimationBuilder<double>(
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeInOut,
//               tween: Tween<double>(
//                 begin: isExpanded ? 0.0 : 1.0,
//                 end: isExpanded ? 1.0 : 0.0,
//               ),
//               builder: (context, value, child) {
//                 double currentSize = 20.0 + (28.0 * value);

//                 return Transform.translate(
//                   // ✅ FIX 3: Nudges the magnifying glass so the circular part acts as the true center
//                   offset: Offset(currentSize * 0.08, currentSize * 0.08),
//                   child: Icon(
//                     Icons.search_rounded,
//                     size: currentSize,
//                     color: Color.lerp(
//                       Colors.grey.shade700,
//                       Colors.blue.shade600,
//                       value,
//                     ),
//                     shadows: [
//                       Shadow(
//                         color: Colors.white,
//                         blurRadius: 6.0 - (2.0 * value),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),

//           // --- HORIZONTAL LINE ---
//           // ✅ FIX 4: Use AnimatedOpacity. It keeps the line constantly in the layout tree
//           // but completely invisible when closed, preventing sudden layout jumps!
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 400),
//               opacity: isExpanded ? 1.0 : 0.0,
//               child: MyLine(
//                 // Use the bounding box width (e.g., width * 0.8) instead of calling the adapter again
//                 length: width * 0.8,
//                 isVertical: false,
//                 margin: 0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
