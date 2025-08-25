import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, bool isLocationEnabled) {
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
