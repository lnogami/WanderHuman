import 'package:flutter/material.dart';

class EyeCon extends StatefulWidget {
  final bool isPasswordVisible;
  final Color color;
  final IconData? icon;

  /// This my customized Widget
  const EyeCon({
    super.key,
    required this.isPasswordVisible,
    this.color = Colors.blueAccent,
    this.icon = Icons.visibility_rounded,
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
