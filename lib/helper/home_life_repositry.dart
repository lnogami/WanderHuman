// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wanderhuman_app/model/home_life_models/hl_planner_model.dart';
// import 'package:wanderhuman_app/model/home_life_models/patien_task_model.dart';
// import 'package:wanderhuman_app/model/home_life_models/task_model.dart';
// import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';

// class HomeLifeRepository {

//   /// Root collection reference
//   static final CollectionReference _collectionReference = FirebaseFirestore
//       .instance
//       .collection("HomeLife");

//   // generates doc name
//   static DocumentReference _getDocID(String dateDocID) {
//     return _collectionReference.doc(dateDocID);
//   }

//   /// Creates the document with the current Date as the taskID
//   // first doc
//   /// HomeLifePlanner is the model used here becuase it is the source of this data
//   static Future<void> addTaskForTheDay({required HomeLifePlanner task}) async {

//     DocumentReference docRef = _getDocID(task.taskID);
//     docRef.set({"taskID": task.taskID});
//   }

//   /// To ADD participants (patients) to the task
//   // second doc
//   static void addParticipants({required String dateDocID, required HLPatientTaskModel patient}) {
//     DocumentReference docRef = _getDocID(
//       dateDocID,
//     ).collection("HLParticipants").doc(patient.id);

//     docRef.set({
//       "patientID": patient.id,
//       "patientName": patient.patientName,
//       "assignedCaregiverID": patient.assignedCaregiver,
//     });
//   }

//   /// To ADD task
//   // the third doc (last doc)
//   static void addTask({required dateDocID,required String participantID, required HLTaskModel task}) {
//     DocumentReference docRef = _getDocID(
//       dateDocID,
//     ).collection("HLParticipants").doc(participantID).collection("HLTasks").doc(task.taskID);
//     docRef.set({
//       "taskID": docRef.id, // taskID will become the docRef.id
//       "taskName": task.taskName,
//       "description": task.description,
//       "isDone": task.isDone,
//       // this one can be different from assignedCaregiverID because there will be times that the assigned caregiver is not present, so other caregiver's ID is used instead.
//       "caregiverId": task.caregiverId,
//     });
//   }

//   // delete a daily record
//   static void removeTaskForTheDay({required String taskID}) {
//     _collectionReference.doc(taskID).delete();
//   }

//   //
//   static void removeParticipant({required String taskForTheDayID, required String participantID}) {
//     _collectionReference.doc(taskForTheDayID).collection("HLParticipants").doc(participantID).delete();
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:wanderhuman_app/model/home_life_models/patien_task_model.dart';
// import 'package:wanderhuman_app/model/home_life_models/task_model.dart';

// class HomeLifeRepository {
//   // Root collection reference
//   static final CollectionReference _homeLifeRef =
//       FirebaseFirestore.instance.collection("HomeLife");

//   /// 1. CREATE THE DAY (The Folder)
//   /// Returns the ID used (e.g., "2023-10-27")
//   static Future<void> createDayDocument({required String dateID}) async {
//     // We use .set with merge:true just in case the day already exists.
//     // We don't want to overwrite it if we accidentally call this twice.
//     await _homeLifeRef.doc(dateID).set({
//       "createdAt": FieldValue.serverTimestamp(),
//       "dateID": dateID,
//     }, SetOptions(merge: true));
//   }

//   /// 2. ADD PARTICIPANT (The Patient)
//   /// Notice we pass 'dateID' here explicitly. No static variables.
//   static Future<void> addParticipant({
//     required String dateID,
//     required HLPatientTaskModel patient
//   }) async {
//     await _homeLifeRef
//         .doc(dateID)
//         .collection("HLParticipants")
//         .doc(patient.id)
//         .set({
//           "patientID": patient.id,
//           "patientName": patient.patientName,
//           "assignedCaregiverID": patient.assignedCaregiver,
//         });
//   }

//   /// 3. ADD TASK (The Activity)
//   static Future<void> addTask({
//     required String dateID,
//     required String participantID,
//     required HLTaskModel task
//   }) async {
//     // If the task model doesn't have an ID yet, we let Firestore generate one
//     DocumentReference docRef = _homeLifeRef
//         .doc(dateID)
//         .collection("HLParticipants")
//         .doc(participantID)
//         .collection("HLTasks")
//         .doc(task.taskID); // If task.taskID is null, remove .doc() to auto-gen

//     await docRef.set({
//       "taskID": docRef.id, // Ensures the ID inside the data matches the document name
//       "taskName": task.taskName,
//       "description": task.description,
//       "isDone": task.isDone,
//       "caregiverId": task.caregiverId,
//     });
//   }

//   /// 4. DELETE DAY (Warning!)
//   static Future<void> removeDayRecord({required String dateID}) async {
//     // WARNING: In Firestore, deleting a parent document does NOT delete
//     // the subcollections. "HLParticipants" will still exist as "orphans".
//     // For now, this just deletes the folder wrapper.
//     await _homeLifeRef.doc(dateID).delete();
//   }

//   /// 5. DELETE PARTICIPANT
//   static Future<void> removeParticipant({
//     required String dateID,
//     required String participantID
//   }) async {
//     await _homeLifeRef
//         .doc(dateID)
//         .collection("HLParticipants")
//         .doc(participantID)
//         .delete();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/home_life_models/patient_task_model.dart';
import 'package:wanderhuman_app/model/home_life_models/task_model.dart';

// Fixed typo: Repositry -> Repository
class HomeLifeRepository {
  /// Root collection reference
  static final CollectionReference _rootCollection = FirebaseFirestore.instance
      .collection("HomeLife");

  // =========================================================
  // Level 1: The Date (The "Container")
  // =========================================================

  /// Creates the document for the day (e.g., '2025-10-27')
  /// RENAMED: 'taskID' -> 'dateID' to avoid confusion with actual tasks
  static Future<void> createDailyRecord({required String dateID}) async {
    // We just set a dummy field or a timestamp so the document exists
    await _rootCollection.doc(dateID).set({
      "createdAt": FieldValue.serverTimestamp(),
      "dateID": dateID,
    });
  }

  // =========================================================
  // Level 2: The Participant (The Patient)
  // =========================================================

  /// To ADD participants (patients) to the specific Date
  /// CHANGED: Added 'dateID' as a required parameter. No more 'bufferedTaskID'.
  static Future<void> addParticipant({
    required String dateID,
    required HLPatientTaskModel patient,
  }) async {
    DocumentReference docRef = _rootCollection
        .doc(dateID)
        .collection("HLParticipants")
        .doc(patient.id);

    await docRef.set({
      "patientID": patient.id,
      "patientName": patient.patientName,
      "assignedCaregiverID": patient.assignedCaregiver,
    });
  }

  // =========================================================
  // Level 3: The Task (The Actual Job)
  // =========================================================

  /// To ADD a task for a specific patient on a specific day
  static Future<void> addTask({
    required String dateID,
    required String participantID,
    required HLTaskModel task,
  }) async {
    // We get a reference. If task.id is null, we can generate a new one.
    DocumentReference docRef = _rootCollection
        .doc(dateID)
        .collection("HLParticipants")
        .doc(participantID)
        .collection("HLTasks")
        .doc(task.taskID); // If taskID is null, use .doc() to auto-generate

    await docRef.set({
      "taskID":
          docRef.id, // Ensures the ID inside the data matches the document name
      "taskName": task.taskName,
      "description": task.description,
      "isDone": task.isDone,
      "caregiverId": task.caregiverId,
    });
  }

  // =========================================================
  // Deletion Logic
  // =========================================================

  // WARNING: This only deletes the 'cover'. The tasks inside still exist technically.
  static Future<void> removeDailyRecord({required String dateID}) async {
    await _rootCollection.doc(dateID).delete();
  }

  static Future<void> removeParticipant({
    required String dateID,
    required String participantID,
  }) async {
    // This leaves the patient's tasks orphaned, but removes the patient from the list
    await _rootCollection
        .doc(dateID)
        .collection("HLParticipants")
        .doc(participantID)
        .delete();
  }
}
