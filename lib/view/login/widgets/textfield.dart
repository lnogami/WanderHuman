// to be constructed..
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

class MyCustTextfield extends StatelessWidget {
  /// The width is automatically adjusted base on the screensize, so the widthPercentage is the ratio of how much of the screen you want to occupy.
  final double widthPercentage;

  /// The height is automatically adjusted base on the screensize, so the heightPercentage is the ratio of how much of the screen you want to occupy.
  final double heightPercentage;

  final bool isUsingStaticDimension;
  final String? hintText;
  final String labelText;
  final IconData prefixIcon;
  final Color prefixIconColor;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color activeBorderColor;

  /// This will manage the data the textfield will accept
  final TextEditingController textController;

  /// My customized textfield
  const MyCustTextfield({
    super.key,
    this.isUsingStaticDimension = true,
    this.widthPercentage = 1.0,
    this.heightPercentage = 1.0,
    this.hintText,
    required this.labelText,
    required this.prefixIcon,
    this.prefixIconColor = Colors.grey,
    required this.textController,
    this.borderRadius = 30,
    this.borderWidth = 1,
    this.borderColor = Colors.blue,
    this.activeBorderColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (isUsingStaticDimension)
          ? MyDimensionAdapter.getWidth(context) * 0.80
          : MyDimensionAdapter.getWidth(context) * widthPercentage,
      height: (isUsingStaticDimension)
          ? 50
          : MyDimensionAdapter.getHeight(context) * heightPercentage,
      // color: Colors.purple.shade200,
      child: TextField(
        controller: textController,

        decoration: InputDecoration(
          // helper: Text("Username.."),
          // hint: Text("Username.."),
          labelText: labelText,
          hintText: (hintText != null) ? hintText : "",
          alignLabelWithHint: true,
          filled: true,
          contentPadding: EdgeInsets.only(
            // left: -50,
            top: 3,
            right: 3,
            bottom: 5,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(prefixIcon),
          ),
          prefixIconConstraints: BoxConstraints.tight(Size(50, 32)),
          // prefixIconConstraints: BoxConstraints.,
          prefixIconColor: prefixIconColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: borderWidth + 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
