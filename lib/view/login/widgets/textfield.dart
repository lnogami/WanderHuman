import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/login/widgets/eyecon.dart';

class MyCustTextfield extends StatefulWidget {
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
  final FocusNode? focusNode;
  final bool isPasswordField;
  final Color color;
  final IconData? suffixIcon;
  final Color suffixIconColor;
  final bool isReadOnly;

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
    this.suffixIconColor = Colors.blue,
    required this.textController,
    this.borderRadius = 30,
    this.borderWidth = 1,
    this.borderColor = Colors.blue,
    this.activeBorderColor = Colors.blue,
    this.focusNode,
    this.isPasswordField = false,
    this.color = Colors.transparent,
    this.suffixIcon,
    this.isReadOnly = false,
  });

  @override
  State<MyCustTextfield> createState() => _MyCustTextfieldState();
}

class _MyCustTextfieldState extends State<MyCustTextfield> {
  bool _isObscurePassword = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (widget.isUsingStaticDimension)
          ? MyDimensionAdapter.getWidth(context) * 0.80
          : MyDimensionAdapter.getWidth(context) * widget.widthPercentage,
      height: (widget.isUsingStaticDimension)
          ? 50
          : MyDimensionAdapter.getHeight(context) * widget.heightPercentage,
      // color: Colors.purple.shade200,
      child: TextField(
        controller: widget.textController,
        focusNode: widget.focusNode,
        readOnly: widget.isReadOnly,
        obscureText: _isObscurePassword,
        obscuringCharacter: "*",
        decoration: InputDecoration(
          labelText: widget.labelText,
          // hint text, example: inogami@gmail.com
          hint: (widget.hintText != null)
              ? Text(
                  widget.hintText!,
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Text(""),
          alignLabelWithHint: true,
          filled: true,
          contentPadding: const EdgeInsets.only(top: 3, right: 3, bottom: 5),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(widget.prefixIcon),
          ),
          prefixIconConstraints: BoxConstraints.tight(Size(50, 32)),
          prefixIconColor: widget.prefixIconColor,
          suffixIcon: (widget.suffixIcon != null || widget.isPasswordField)
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isObscurePassword = !_isObscurePassword;
                    });
                  },
                  child: (widget.isPasswordField)
                      ? EyeCon(
                          isPasswordVisible: _isObscurePassword,
                          color: widget.suffixIconColor,
                        )
                      : Icon(
                          widget.suffixIcon,
                          color: widget.suffixIconColor,
                          blendMode: BlendMode.src,
                        ),
                )
              : null,
          suffixIconColor: widget.suffixIconColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor,
              width: widget.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.activeBorderColor,
              width: widget.borderWidth + 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
