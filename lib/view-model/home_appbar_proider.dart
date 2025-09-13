import 'package:flutter/material.dart';

class HomeAppBarProvider extends ChangeNotifier {
  bool isExpanded = false;

  /// if Expanded, then Collaps, otherwise reverse.
  void toggleAppBar() {
    isExpanded = !isExpanded;
    notifyListeners(); // this is just like a setState() but for providers
  }
}

// NOTE: not yet implemented, or it may be wont implemented at all.
