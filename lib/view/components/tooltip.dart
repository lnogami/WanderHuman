import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

class MyCustTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final double heightConstraints;
  final double widthPercentage;
  final int duration;
  final TooltipTriggerMode triggerMode;
  final int opacity;

  ///##### A custom tooltip widget with predefined styling. This widget helps the user know what a component does by showing [message] information/help about a certain component/widget.
  const MyCustTooltip({
    super.key,
    required this.child,
    required this.message,
    this.duration = 1500,
    this.widthPercentage = 0.9,
    this.heightConstraints = 50,
    this.triggerMode = TooltipTriggerMode.longPress,
    this.opacity = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: triggerMode,
      message: message,
      showDuration: Duration(milliseconds: duration),
      constraints: BoxConstraints.expand(
        height: heightConstraints,
        width: MyDimensionAdapter.getWidth(context) * widthPercentage,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(
          (opacity > 255)
              ? 255
              : (opacity < 0)
              ? 0
              : opacity,
        ),
        // color: Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(80),
            blurRadius: 4,
            offset: Offset.zero,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: child,
    );
  }
}
