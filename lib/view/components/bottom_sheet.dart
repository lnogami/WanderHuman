import 'package:flutter/material.dart';

class MyBottomPanel {
  /// A generic bottom sheet
  static void showMyBottomPanel({
    required BuildContext context,
    required dynamic child,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return child;
      },
    );
  }
}
