import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

class MyCustTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final double heightConstraints;
  final double widthPercentage;
  final int duration;

  ///##### A custom tooltip widget with predefined styling. This widget helps the user know what a component does by showing [message] information/help about a certain component/widget.
  const MyCustTooltip({
    super.key,
    required this.child,
    required this.message,
    this.duration = 1500,
    this.widthPercentage = 0.9,
    this.heightConstraints = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      showDuration: Duration(milliseconds: duration),
      constraints: BoxConstraints.expand(
        height: heightConstraints,
        width: MyDimensionAdapter.getWidth(context) * widthPercentage,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade300,
        borderRadius: BorderRadius.circular(7),
      ),
      child: child,
    );
  }
}
