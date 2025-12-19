// import 'package:flutter/material.dart';

// Future<DateTime?> myDatePicker(
//   BuildContext context, {
//   // entering age will determine the year of birth
//   int? initialYear,
//   int? firstDate,
//   int? lastDate,
// }) async {
//   return showDatePicker(
//     context: context,
//     // to be updated later if I still have time to update this initialDate to adapt to age
//     initialDate: DateTime(initialYear ?? 2000),
//     firstDate: DateTime(firstDate ?? 1800),
//     lastDate: DateTime(lastDate ?? 2300),
//   );
// }

import 'package:flutter/material.dart';

Future<DateTime?> myDatePicker(
  BuildContext context, {
  String? age,
  int? initialYear,
  int? firstDate,
  int? lastDate,
}) async {
  int targetYear;

  // 1. LOGIC: If age is provided, use your calculator. Otherwise use initialYear or default.
  if (age != null && age.isNotEmpty) {
    targetYear = birthYearCalculator(age);
  } else {
    targetYear = initialYear ?? 2000;
  }

  // 2. Define the bounds
  DateTime firstDateObj = DateTime(firstDate ?? 1900);
  DateTime lastDateObj = DateTime(lastDate ?? 2300);

  // 3. Create the initial date (January 1st of the calculated year)
  DateTime initialDateObj = DateTime(targetYear);

  // 4. SAFETY CHECK: Ensure the calculated date isn't outside the allowed range
  // (Flutter crashes if initialDate is outside firstDate/lastDate)
  if (initialDateObj.isBefore(firstDateObj)) {
    initialDateObj = firstDateObj;
  } else if (initialDateObj.isAfter(lastDateObj)) {
    initialDateObj = lastDateObj;
  }

  return showDatePicker(
    context: context,
    initialDate: initialDateObj,
    firstDate: firstDateObj,
    lastDate: lastDateObj,
  );
}

// ---------------------------------------------------------
// This represents your separate function.
// You don't need to copy this part if you already have it.
int birthYearCalculator(String age) {
  int ageInt = int.tryParse(age) ?? 0;
  return DateTime.now().year - ageInt;
}
