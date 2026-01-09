import 'package:flutter/material.dart';

class MyTimeFormatter {
  static TimeOfDay stringToTimeOfDay(String stringToTime) {
    // 1. Remove the "TimeOfDay(" prefix and ")" suffix
    // Format becomes: "14:30"
    String cleanTime = stringToTime
        .replaceAll("TimeOfDay(", "")
        .replaceAll(")", "");

    // 2. Split by the colon
    List<String> parts = cleanTime.split(":");

    // 3. Create the TimeOfDay object
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
