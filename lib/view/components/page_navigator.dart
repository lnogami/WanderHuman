import 'package:flutter/material.dart';

class MyNavigator {
  /// Navigates to the [nextPage] with a custom animation.
  static void goTo(BuildContext context, Widget nextPage) {
    //
    Navigator.push(
      context,
      PageRouteBuilder(
        // The page you are going to
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,

        // Speed of the animation (Adjust as needed)
        transitionDuration: const Duration(milliseconds: 600),

        // The Animation Logic
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // ----------------------------------------------------------------
          // OPTION 1: SLIDE FROM RIGHT (Standard iOS/Android feel) [ACTIVE]
          // ----------------------------------------------------------------
          const begin = Offset(1.0, 0.0); // X=1.0 means start from right
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );

          // ----------------------------------------------------------------
          // OPTION 2: SLIDE FROM BOTTOM (Good for Modal/Details pages)
          // ----------------------------------------------------------------
          // const begin = Offset(0.0, 1.0); // Y=1.0 means start from bottom
          // const end = Offset.zero;
          // const curve = Curves.easeInOut;
          // var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          // return SlideTransition(position: animation.drive(tween), child: child);

          // ----------------------------------------------------------------
          // OPTION 3: FADE TRANSITION (Simple & Elegant)
          // ----------------------------------------------------------------
          // return FadeTransition(
          //   opacity: animation,
          //   child: child,
          // );

          // ----------------------------------------------------------------
          // OPTION 4: SCALE TRANSITION (Zooms in from center)
          // ----------------------------------------------------------------
          // return ScaleTransition(
          //   scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          //     CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
          //   ),
          //   child: child,
          // );

          // ----------------------------------------------------------------
          // OPTION 5: ROTATION + SCALE (Playful/Crazy)
          // ----------------------------------------------------------------
          // return RotationTransition(
          //   turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          //   child: ScaleTransition(
          //     scale: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          //     child: child,
          //   ),
          // );
        },
      ),
    );
  }
}
