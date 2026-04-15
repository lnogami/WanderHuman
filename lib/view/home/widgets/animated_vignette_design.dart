// // // import 'dart:ui';
// // // import 'package:flutter/material.dart';

// // import 'package:flutter/material.dart';

// // class RectangularVignette extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return IgnorePointer(
// //       child: CustomPaint(size: Size.infinite, painter: VignettePainter()),
// //     );
// //   }
// // }

// // class VignettePainter extends CustomPainter {
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final rect = Offset.zero & size;

// //     // We create a paint object with a RadialGradient.
// //     // To make it look "square", we adjust the radius to cover the screen corners.
// //     final paint = Paint()
// //       ..shader = RadialGradient(
// //         // We use a very large radius (approx 1.4) to ensure the
// //         // "circular" part of the gradient stays in the corners,
// //         // making the sides look more linear/square.
// //         radius: 1.4,
// //         colors: [
// //           Colors.transparent, // Center
// //           Colors.black.withAlpha(127), // Mid-fade
// //           Colors.black, // Outer edges
// //         ],
// //         stops: const [0.4, 0.8, 1.0],
// //       ).createShader(rect);

// //     canvas.drawRect(rect, paint);
// //   }

// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) => false;
// // }

// import 'package:flutter/material.dart';

// class RectangularVignette extends StatelessWidget {
//   final Color fadeColor;
//   final double edgeThickness; // How far the fade reaches (0.0 to 1.0)

//   const RectangularVignette({
//     super.key,
//     this.fadeColor = Colors.black,
//     this.edgeThickness = 0.2,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: Stack(
//         children: [
//           // Top Fade
//           _gradient(Alignment.topCenter, Alignment.bottomCenter),
//           // Bottom Fade
//           _gradient(Alignment.bottomCenter, Alignment.topCenter),
//           // Left Fade
//           _gradient(Alignment.centerLeft, Alignment.centerRight),
//           // Right Fade
//           _gradient(Alignment.centerRight, Alignment.centerLeft),
//         ],
//       ),
//     );
//   }

//   Widget _gradient(Alignment begin, Alignment end) {
//     return Positioned.fill(
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: begin,
//             end: end,
//             stops: [0.0, edgeThickness],
//             colors: [fadeColor, Colors.transparent],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AnimatedWarningVignette extends StatefulWidget {
  final Color dangerColor;
  final bool isActive; // Toggle this to start/stop the animation

  const AnimatedWarningVignette({
    super.key,
    this.dangerColor = const Color.fromARGB(255, 234, 48, 48), // Deep Red
    this.isActive = true,
  });

  @override
  State<AnimatedWarningVignette> createState() =>
      _AnimatedWarningVignetteState();
}

class _AnimatedWarningVignetteState extends State<AnimatedWarningVignette>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thicknessAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    )..repeat(reverse: true); // This creates the "pulse"

    _thicknessAnimation = Tween<double>(
      begin: 0.15,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          child: Stack(
            children: [
              _gradient(Alignment.topCenter, Alignment.bottomCenter),
              _gradient(Alignment.bottomCenter, Alignment.topCenter),
              _gradient(Alignment.centerLeft, Alignment.centerRight),
              _gradient(Alignment.centerRight, Alignment.centerLeft),
            ],
          ),
        );
      },
    );
  }

  Widget _gradient(Alignment begin, Alignment end) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: [0.0, _thicknessAnimation.value],
            colors: [
              widget.dangerColor.withValues(alpha: _opacityAnimation.value / 2),
              // widget.dangerColor.withOpacity(_opacityAnimation.value),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
