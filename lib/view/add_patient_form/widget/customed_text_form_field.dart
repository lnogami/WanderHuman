import 'package:flutter/material.dart';

class MyCustomizedTextFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final String label;
  final String hintText;
  final double bottomMargin;
  final String errorMessage;

  const MyCustomizedTextFormField({
    super.key,
    required this.validator,
    required this.label,
    required this.hintText,
    this.bottomMargin = 10,
    this.errorMessage = "Input something",
  });

  @override
  State<MyCustomizedTextFormField> createState() =>
      _MyCustomizedTextFormFieldState();
}

class _MyCustomizedTextFormFieldState extends State<MyCustomizedTextFormField> {
  final double borderRadius = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: EdgeInsets.only(bottom: widget.bottomMargin, left: 20, right: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
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
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: Colors.blue),
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
