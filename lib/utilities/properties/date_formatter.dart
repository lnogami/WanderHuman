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

  ///#### Returns dateTime in a specific format:
  ///#### [1] Dec 17, 2025 (default)
  ///#### [2] 12 17, 2025
  ///#### [3] 12/17/2025
  ///#### [4] 12/17/25
  ///#### [5] 12/17/25 12:00 AM
  ///#### [6] Dec 17, 2025 12:00 AM
  ///#### [7] Provide your own format options
  /// Note: If you chose `7` as your formatOptions, provide `customeFormat` <br>
  /// ex. `MMM` -> (Dec), `d` -> (17), `y` -> (2025), `EEE` -> (Mon), `hh` -? hour, `mm` -> minute, `a` -> AM/PM)
  static String formatDate({
    required dynamic dateTimeInString,
    int? formatOptions,
    String? customedFormat,
  }) {
    DateTime dateTime = _dateTimeParser(dateTimeInString)!;

    try {
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
        case 6:
          return DateFormat('MMM d, y hh:mm a').format(dateTime);
        case 7:
          return DateFormat(customedFormat).format(dateTime);
        default:
          return DateFormat('MMM d, y').format(dateTime);
      }
    } catch (e) {
      return ("Invalid customedFormat");
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

      // ATTEMPT: "Can you read this string ('Jan 13, 2025') using the pattern 'MMM d, y'?"
      //
      // IF YES: Convert it to a DateTime object AND RETURN IT IMMEDIATELY.
      //         (The function stops here. It does NOT run any code below this.)
      //
      // IF NO:  (e.g., the string is "2025-01-13"), this line crashes (throws an error).
      //         The 'return' never happens.
      //         We jump straight to the 'catch' block.
      try {
        return DateFormat('MMM d, y').parse(dateTimeToParse);
      } catch (e) {
        // If it fails (e.g. it's "2026-01-01"), let the standard parser try below
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
