import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/model/realtime_location_model.dart';

class MyHistoryReposity {
  /// This will contain all the last saved times for each patient
  static final Map<String, DateTime> _lastSavedTimes = {};

  /// This _timeGapInSeconds means the duration between each log to save to the database
  static final int _timeGapInSeconds = 30;

  /// Root collection for History
  static final CollectionReference _rootCollection = FirebaseFirestore.instance
      .collection("History");

  /// Sub-collection for PatientLogs
  static final String _subCollection = "PatientLogs";

  /// This checks RAM instead of the Database (Instant & Free)
  static bool _shouldSaveNow(String patientID) {
    // If we have never saved for this patient in this session, save now.
    if (!_lastSavedTimes.containsKey(patientID)) {
      return true;
    }

    DateTime lastSave = _lastSavedTimes[patientID]!;
    DateTime now = DateTime.now();

    // Check if 30 seconds have passed
    if (now.difference(lastSave).inSeconds >= _timeGapInSeconds) {
      return true;
    }

    return false;
  }

  static Future<void> savePatientLocation({
    required MyRealtimeLocationModel locationData,
  }) async {
    try {
      // 3. Check memory first!
      // This stops the code from doing ANY database work if it's too soon.
      if (!_shouldSaveNow(locationData.patientID)) {
        // Uncomment this if you want to see how many saves are being skipped
        log(
          "NOTICEEEEE: Skipping history save for ${locationData.patientID} (Too soon)",
        );
        return;
      }

      // 4. Update the "Last Saved" time immediately so we don't save again too soon
      _lastSavedTimes[locationData.patientID] = DateTime.now();

      // 5. Proceed with saving to Firestore
      // (You don't need _isPatientLogsEmpty checks anymore if you trust the timestamps)

      await _rootCollection
          .doc(locationData.patientID)
          .collection(_subCollection)
          .doc(DateTime.now().toString())
          .set(MyHistoryModel.toMap(locationData));

      log("✅ SUCCESSFULLY SAVED HISTORY for ${locationData.patientID}");
    } catch (e, stackTrace) {
      log("ERROR SAVING HISTORY: $e \nAT: $stackTrace");
    }
  }

  // /// Retrieve all history logs for a specific patient
  // static Future<List<MyHistoryModel>> getPatientHistory(
  //   String patientID, {
  //   String orderBy = "timeStamp",
  //   String? fieldToLookFor,
  //   String? fieldValue,
  //   bool isDescending = true,
  // }) async {
  //   try {
  //     late QuerySnapshot snapshot;
  //     bool? isFieldValueBoolean = bool.tryParse(fieldValue ?? "");
  //
  //     if (fieldToLookFor != null && fieldValue != null) {
  //       snapshot = await _rootCollection
  //           .doc(patientID)
  //           .collection(_subCollection)
  //           .where(fieldToLookFor, isNotEqualTo: isFieldValueBoolean ?? fieldValue)
  //           .orderBy(orderBy, descending: isDescending) // Get newest first
  //           .get();
  //     } else if (orderBy == "timeStamp") {
  //       snapshot = await _rootCollection
  //           .doc(patientID)
  //           .collection(_subCollection)
  //           .orderBy(orderBy, descending: isDescending) // Get newest first
  //           .get();
  //     } else {
  //       snapshot = await _rootCollection
  //           .doc(patientID)
  //           .collection(_subCollection)
  //           .get();
  //     }
  //
  //     return snapshot.docs.map((doc) {
  //       return MyHistoryModel.fromFirestore(doc.data() as Map<String, dynamic>);
  //     }).toList();
  //   } catch (e) {
  //     log("ERROR FETCHING HISTORY: $e");
  //     return [];
  //   }
  // }

  /// Retrieve all history logs for a specific patient
  static Future<List<MyHistoryModel>> getPatientHistory(
    String patientID, {
    String orderBy = "timeStamp",
    String? field1,
    dynamic value1, // Changed to dynamic so you can pass bools directly
    String? field2,
    dynamic value2,
    bool isDescending = true,
  }) async {
    try {
      late QuerySnapshot snapshot;

      // ==========================================
      // THE "OR" QUERY LOGIC
      // ==========================================
      if (field1 != null &&
          field2 != null &&
          value1 != null &&
          value2 != null) {
        snapshot = await _rootCollection
            .doc(patientID)
            .collection(_subCollection)
            .where(
              Filter.or(
                Filter(field1, isEqualTo: value1),
                Filter(field2, isEqualTo: value2),
              ),
            )
            .orderBy(orderBy, descending: isDescending)
            .get();

        log(
          "**************** DONE FETCHING DATA IN getPatientHistory, ${snapshot.docs.length}",
        );
        // ==========================================
        // STANDARD SINGLE-FIELD QUERY
        // ==========================================
      } else if (field1 != null && value1 != null) {
        snapshot = await _rootCollection
            .doc(patientID)
            .collection(_subCollection)
            .where(field1, isEqualTo: value1)
            .orderBy(orderBy, descending: isDescending)
            .get();

        // ==========================================
        // JUST ORDERED (NO FILTERS)
        // ==========================================
      } else {
        snapshot = await _rootCollection
            .doc(patientID)
            .collection(_subCollection)
            .orderBy(orderBy, descending: isDescending)
            .get();
      }

      log(
        "=======================\nNumber of Data fetched for ($patientID): ${snapshot.docs.length}",
      );

      return snapshot.docs.map((doc) {
        return MyHistoryModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      log("ERROR FETCHING HISTORY: $e");
      return [];
    }
  }

  // (not yet tested as of March 22, 2026)
  /// Fetches history and groups "Unsafe" episodes into separate sessions.
  static Future<List<List<MyHistoryModel>>> getGroupedUnsafeSessions(
    String patientID,
  ) async {
    // 1. Fetch all logs for this patient.
    // IMPORTANT: We fetch in ASCENDING order (isDescending: false)
    // so we can "trace" the path chronologically from start to finish.
    List<MyHistoryModel> allLogs = await getPatientHistory(
      patientID,
      isDescending: false,
    );

    List<List<MyHistoryModel>> groupedSessions = [];
    List<MyHistoryModel> currentSession = [];

    for (int i = 0; i < allLogs.length; i++) {
      MyHistoryModel logEntry = allLogs[i];

      // Check if the patient is OUTSIDE the safe zone
      if (logEntry.isInSafeZone == false) {
        currentSession.add(logEntry);
      }
      // If the patient is INSIDE (Safe), it means the "Unsafe Session" has ended
      else {
        if (currentSession.isNotEmpty) {
          // Add the completed unsafe session to our master list
          groupedSessions.add(List.from(currentSession));
          // Reset for the next time they might go out
          currentSession.clear();
        }
      }
    }

    // Catch the case where the patient is STILL outside when the logs end
    if (currentSession.isNotEmpty) {
      groupedSessions.add(currentSession);
    }

    // Return the sessions. We reverse the outer list so the
    // LATEST alert appears at the top of your Card List.
    return groupedSessions.reversed.toList();
  }

  /// Retrieve all history logs for a specific patient
  static Future<List<MyHistoryModel>> getPatientFrequentlyGoToHistory(
    String patientID, {
    String? fieldToLookFor,
    String? fieldValue,
    String? fieldValueStart,
    String? fieldValueEnd,
    String orderBy = "timeStamp",
    bool isDescending = true,
  }) async {
    try {
      late QuerySnapshot snapshot;

      if (fieldToLookFor != null &&
          fieldValueStart != null &&
          fieldValueEnd != null) {
        snapshot = await _rootCollection
            .doc(patientID)
            .collection(_subCollection)
            .where(fieldToLookFor, isGreaterThanOrEqualTo: fieldValueStart)
            .where(fieldToLookFor, isLessThanOrEqualTo: fieldValueEnd)
            .orderBy(
              fieldToLookFor,
              descending: isDescending,
            ) // Get newest first
            .get();
      } else if (fieldToLookFor != null && fieldValue != null) {
        snapshot = await _rootCollection
            .doc(patientID)
            .collection(_subCollection)
            .where(fieldToLookFor, isEqualTo: fieldValue)
            .orderBy(
              fieldToLookFor,
              descending: isDescending,
            ) // Get newest first
            .get();
      } else if (orderBy == "timeStamp") {
        snapshot = await _rootCollection
            .doc(patientID)
            .collection(_subCollection)
            .orderBy(orderBy, descending: isDescending) // Get newest first
            .get();
      } else {
        snapshot = await _rootCollection
            .doc(patientID)
            .collection(_subCollection)
            .get();
      }

      return snapshot.docs.map((doc) {
        return MyHistoryModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      log("ERROR FETCHING HISTORY: $e");
      return [];
    }
  }

  // Not yet implemented (as of March 21, 2026)
  static Future<MyHistoryModel?> getLatestHistoryLog(String patientID) async {
    try {
      QuerySnapshot snapshot = await _rootCollection
          .doc(patientID)
          .collection(_subCollection)
          .orderBy('timeStamp', descending: true) // 1. Sort newest first
          .limit(1) // 2. ONLY download the top 1 result
          .get();

      // 3. Check if the collection is empty before trying to read it
      if (snapshot.docs.isNotEmpty) {
        // Return the single document
        return MyHistoryModel.fromFirestore(
          snapshot.docs.first.data() as Map<String, dynamic>,
        );
      } else {
        return null; // No history exists yet
      }
    } catch (e) {
      log("Error fetching latest log: $e");
      return null;
    }
  }

  // // for debugging purposes only
  // static Future<void> removePatientHistory(
  //   String patientID, {
  //   required dynamic timeStampToDelete,
  // }) async {
  //   try {
  //     await _rootCollection
  //         .doc(patientID)
  //         .collection(_subCollection)
  //         .where("currentLocationLng", isEqualTo: timeStampToDelete)
  //         .get()
  //         .then((snapshot) {
  //           for (var doc in snapshot.docs) {
  //             if (snapshot.docs.first.exists) continue;
  //             doc.reference.delete();
  //           }
  //         });
  //     log(
  //       "-------------------------\n✅ SUCCESSFULLY REMOVED HISTORY for $patientID",
  //     );
  //   } catch (e, stackTrace) {
  //     log("ERROR REMOVING HISTORY: $e \nAT: $stackTrace");
  //   }
  // }
}
