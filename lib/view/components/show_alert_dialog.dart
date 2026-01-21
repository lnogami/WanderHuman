import 'package:flutter/material.dart';

showMyDialogBox(BuildContext context, bool isLocationEnabled) {
  if (!isLocationEnabled) {
    showDialog(
      context: context,
      // barrierDismissible: isLocationEnabled,  // to be updated later. This will prevent the use from dismissing the dialog by tapping outside of it, if the location is still disabled.
      builder: (context) {
        return AlertDialog(
          title: Text("Location is Off"),
          content: Text("Please, turn on your device's Location. Thank you!"),
        );
      },
    );
  }
}
