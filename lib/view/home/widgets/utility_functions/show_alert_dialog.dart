import 'package:flutter/material.dart';

showMyDialogBox(BuildContext context, bool isLocationEnabled) {
  // bool isAlertDialogVisible = true;
  // while (!isLocationEnabled) {
  //   if (!isLocationEnabled && context.mounted) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Location is Off"),
  //         content: Text("Please, turn on your device's Location. Thank you!"),
  //       );
  //     },
  //   );
  // }
  if (!isLocationEnabled) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Location is Off"),
          content: Text("Please, turn on your device's Location. Thank you!"),
        );
      },
    );
  }
}
