import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';

class MyCustomizedTextFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final String label;
  final String hintText;
  final double bottomMargin;
  final String errorMessage;
  final bool isReadOnly;
  final FocusNode? focusNode;
  final AutovalidateMode? autoValidateMode;
  final void Function(String)? onChange;

  /// #### [0] (default) does nothing
  /// #### [1] For Allowing only letters, numbers and spaces
  /// #### [2] For Allowing only letters and spaces
  /// #### [3] For Allowing only numbers
  /// #### [4] For Deny only spaces and dashes
  /// #### [5] For Email
  final int allowedTextInputsOptions;

  /// To controll the keyboard type
  final TextInputType? keyboardType;

  const MyCustomizedTextFormField({
    super.key,
    required this.validator,
    required this.label,
    required this.hintText,
    this.bottomMargin = 10,
    this.errorMessage = "Input something",
    this.isReadOnly = false,
    this.focusNode,
    this.autoValidateMode,
    this.onChange,
    this.allowedTextInputsOptions = 0,
    this.keyboardType,
  });

  @override
  State<MyCustomizedTextFormField> createState() =>
      _MyCustomizedTextFormFieldState();
}

class _MyCustomizedTextFormFieldState extends State<MyCustomizedTextFormField> {
  final double borderRadius = 10;

  List<TextInputFormatter> textInputFormatter(int options) {
    switch (options) {
      case 1:
        return [
          // OPTION A: Allow ONLY Letters and Numbers (Blocks @, #, $, space, etc.)
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
        ];
      case 2:
        return [
          // OPTION B: Allow ONLY Numbers
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
        ];
      case 3:
        return [
          // OPTION B: Allow ONLY Numbers
          FilteringTextInputFormatter.digitsOnly,
        ];
      case 4:
        return [
          // // OPTION C: Deny ONLY specific characters (e.g., block spaces and dashes)
          FilteringTextInputFormatter.deny(RegExp(r'[ -]')),
        ];
      case 5:
        return [
          // // OPTION C: Deny ONLY specific characters (e.g., block spaces and dashes)
          FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@/\\\-.]')),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: EdgeInsets.only(bottom: widget.bottomMargin, left: 20, right: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        inputFormatters: textInputFormatter(widget.allowedTextInputsOptions),
        onChanged: widget.onChange,
        autovalidateMode: widget.autoValidateMode,
        focusNode: widget.focusNode,
        readOnly: widget.isReadOnly,
        decoration: InputDecoration(
          fillColor: Colors.white54,
          filled: true,
          labelText: widget.label,
          hint: Text(
            widget.hintText,
            style: TextStyle(
              color: const Color.fromARGB(255, 111, 136, 158),
              fontStyle: FontStyle.italic,
              // fontSize: 15,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: MyColorPalette.borderColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: MyColorPalette.borderColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        validator: widget.validator,

        //(value) {
        //   if (value == null || value.isEmpty) {
        //     return "Input something";
        //   }
        //   return null;
        // },
      ),
    );
  }
}
