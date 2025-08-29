import 'package:flutter/material.dart';

class EyeCon extends StatefulWidget {
  final bool isPasswordVisible;
  final Color color;

  /// This my customized Widget
  const EyeCon({
    super.key,
    required this.isPasswordVisible,
    this.color = Colors.blueAccent,
  });

  @override
  State<EyeCon> createState() => _EyeConState();
}

class _EyeConState extends State<EyeCon> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      (widget.isPasswordVisible)
          ? Icons.visibility_off_rounded
          : Icons.visibility_rounded,
      color: widget.color,
    );
  }
}
