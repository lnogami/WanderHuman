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

  /// This will convert a TimeOfDay to a clean String representation, instead of
  /// `.toString()` which will results a "TimeOfDay(07:00)",
  /// use this timeOfDayToString method instead to have a clean 07:00 format.
  static String timeOfDayToString(TimeOfDay time) {
    int hour = time.hour;
    int minute = time.minute;

    // 1. Determine AM or PM
    String period = hour >= 12 ? "PM" : "AM";

    // 2. Convert to 12-hour format
    // The modulo operator (%) gives the remainder.
    // 13 % 12 = 1.
    // 12 % 12 = 0.
    int hour12 = hour % 12;

    // 3. Handle the "0" edge case (Midnight and Noon should be 12, not 0)
    if (hour12 == 0) {
      hour12 = 12;
    }

    // 4. Pad minute with a 0 if it's single digit (e.g., "5" becomes "05")
    String minuteStr = minute.toString().padLeft(2, '0');

    return "$hour12:$minuteStr $period";
  }
}
