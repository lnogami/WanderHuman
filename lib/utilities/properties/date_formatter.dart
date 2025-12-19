import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Processes Timestamp, DateTime, or any of the two but in a String representation format.
///
/// This class is created on December 17, 2025
class MyDateFormatter {
  /// Returns the current date and time
  static DateTime now = DateTime.now();

  /// Returns the current day number (1-31)
  static DateTime nowsDate = DateTime.now()..day;

  /// Returns dateTime in a specific format:
  /// [1] Dec 17, 2025
  /// [2] 12 17, 2025
  /// [3] 12/17/2025
  /// [4] 12/17/25
  /// [6] 12/17/25 12:00 AM
  static String formatDate({
    required dynamic dateTimeInString,
    int? formatOptions,
  }) {
    DateTime dateTime = _dateTimeParser(dateTimeInString)!;

    switch (formatOptions) {
      case 1:
        return DateFormat('MMM d, y').format(dateTime);
      case 2:
        return DateFormat('MM d, y').format(dateTime);
      case 3:
        return DateFormat('MM/dd/y').format(dateTime);
      case 4:
        return DateFormat('MM/dd/yy').format(dateTime);
      case 5:
        return DateFormat('MM/dd/yy hh:mm a').format(dateTime);
      default:
        return DateFormat('MMM d, y').format(dateTime);
    }
  }

  /// Converts a String datetime into a DateTime object
  static DateTime? _dateTimeParser(dynamic dateTimeToParse) {
    if (dateTimeToParse == null) return DateTime.now();

    // if it is a real Timestamp, convert it directly to DateTime
    // SCENARIO 1: It is a Timestamp
    if (dateTimeToParse is Timestamp) {
      return dateTimeToParse.toDate();
    }
    // if it is a String representation of a Timestamp, convert it to DateTime
    // SCENARIO 2: It is a String
    else if (dateTimeToParse is String) {
      // CHECK: Is it the "Dirty" Timestamp String?
      // Looks like: "Timestamp(seconds=1765895446, nanoseconds=802000000)"
      if (dateTimeToParse.contains("Timestamp(seconds=")) {
        return _parseDirtyTimestampString(dateTimeToParse);
      }

      // CHECK: Is it a standard date string? (e.g. "2025-12-17")
      return DateTime.tryParse(dateTimeToParse) ?? DateTime.now();
    }
    // SCENARIO 3: It is already a DateTime
    else if (dateTimeToParse is DateTime) {
      return dateTimeToParse;
    }

    return DateTime.now();
  }

  /// HELPER: Extracts numbers from the string "Timestamp(seconds=...)"
  static DateTime _parseDirtyTimestampString(String dirtyString) {
    try {
      // Find the numbers using Regex
      final secondsMatch = RegExp(r'seconds=(\d+)').firstMatch(dirtyString);
      final nanosecondsMatch = RegExp(
        r'nanoseconds=(\d+)',
      ).firstMatch(dirtyString);

      if (secondsMatch != null && nanosecondsMatch != null) {
        int seconds = int.parse(secondsMatch.group(1)!);
        int nanoseconds = int.parse(nanosecondsMatch.group(1)!);

        // Reconstruct the Timestamp and convert to DateTime
        return Timestamp(seconds, nanoseconds).toDate();
      }
    } catch (e) {
      print("Error parsing dirty timestamp: $e");
    }
    // Fail safe
    return DateTime.now();
  }

  // /// Converts a Timestamp datetime (from Firebase) into a DateTime object
  // static DateTime timestampDateTimeParser(Timestamp dateTimeToParse) {
  //   Timestamp timestamp = dateTimeToParse;
  //   return timestamp.toDate();
  // }

  // /// Returns a string like "2004 or 2005"     //does not work yet
  // static String estimateBirthYear(int age) {
  //   int currentYear = DateTime.now().year;
  //   int lateYear = currentYear - age; // If birthday passed
  //   int earlyYear = currentYear - age - 1; // If birthday coming up

  //   return "$earlyYear or $lateYear";
  // }
}
