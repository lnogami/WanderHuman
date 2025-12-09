import 'package:flutter/widgets.dart';

/// A utitility class to adapt dimensions based on the current context.
/// This class provides methods to get the width and height of the screen.
class MyDimensionAdapter {
  /// Returns the width of the screen based on the current context.
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Returns the height of the screen based on the current context.
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
