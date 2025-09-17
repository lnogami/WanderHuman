import 'package:flutter/material.dart';
// import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

//// this is my creation
// ScaffoldFeatureController showMySnackBar({
//   required BuildContext context,
//   required String dataToDisplay,
//   Color borderColor = Colors.white,
//   Color bgColor = Colors.white60,
// }) {
//   double width = MyDimensionAdapter.getWidth(context);
//   double height = 100;

//   return ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       backgroundColor: Colors.transparent,
//       width: width,
//       behavior: SnackBarBehavior.floating,
//       // animation: CurvedAnimation(
//       //   // custom curve
//       //   parent: AnimationController(
//       //     vsync: ScaffoldMessenger.of(context),
//       //     duration: const Duration(milliseconds: 1500),
//       //   ),
//       //   curve: Curves.easeOutCubic,
//       // ),
//       clipBehavior: Clip.antiAliasWithSaveLayer,
//       content: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.all(Radius.circular(30)),
//           border: Border.all(width: 1, color: borderColor),
//         ),
//         child: Center(child: Text(dataToDisplay.toString())),
//       ),
//     ),
//   );
// }

// this is not my creation
void showMyAnimatedSnackBar({
  required BuildContext context,
  required String dataToDisplay,
  Color borderColor = Colors.white,
  Color bgColor = Colors.white60,
  bool isAutoDismiss = true,
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        bottom: 70,
        left: 20,
        right: 20,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, offset, child) {
            return Transform.translate(offset: offset * 100, child: child);
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Center(child: Text(dataToDisplay)),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);

  // Auto dismiss after 2s
  Future.delayed(const Duration(milliseconds: 3500), () {
    if (isAutoDismiss) {
      overlayEntry.remove();
    }
  });
}
