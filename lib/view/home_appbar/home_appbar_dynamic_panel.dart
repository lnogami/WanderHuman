import 'dart:developer';

class MyDynamicAppbarHeight {
  /// This is the height of the outer AnimatedContainer
  static double expandingOuterPanelHeight(String userType) {
    log("USER TYPE: ${userType.toUpperCase()}");
    switch (userType.toUpperCase()) {
      case "ADMIN":
        return 220;
      case "SOCIAL SERVICE":
        return 220;
      case "MEDICAL SERVICE":
        return 220;
      case "PSYCHOLOGICAL SERVICE":
        return 190;
      case "HOME LIFE":
        return 220;
      case "PSD":
        return 190;
      default:
        return 0;
    }
  }

  /// This is the height of the inner AnimatedContainer
  static double expandingInnerPanelHeight(String userType) {
    log("USER TYPE: ${userType.toUpperCase()}");
    switch (userType.toUpperCase()) {
      case "ADMIN":
        return 160;
      case "SOCIAL SERVICE":
        return 160;
      case "MEDICAL SERVICE":
        return 160;
      case "PSYCHOLOGICAL SERVICE":
        return 150;
      case "HOME LIFE":
        return 160;
      case "PSD":
        return 150;
      default:
        return 0;
    }
  }
}
