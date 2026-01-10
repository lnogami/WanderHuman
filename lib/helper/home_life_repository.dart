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

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/helper/hl_planner_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/home_life_models/hl_planner_model.dart';
import 'package:wanderhuman_app/model/home_life_models/patient_task_model.dart';
import 'package:wanderhuman_app/model/home_life_models/task_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';

/// HomeLifeRepository is the executer of the HomeLifePlanner
/// Therefore, HomeLifePlanner is the single source of truth for every tasks.
class HomeLifeRepository {
  /// Root collection reference
  static final CollectionReference _rootCollection = FirebaseFirestore.instance
      .collection("HomeLife");

  // =========================================================
  // Level 1: The Date (The "Container")
  // =========================================================

  /// Creates the document for the day (e.g., 'DEC 17,2025' or '2025-10-27')
  /// ##### This will only create a Document once per day
  static Future<void> createDailyRecord({required String dateID}) async {
    // to format the date (remove the time) so we could have a uniform time
    String dateOnlyFormat = MyDateFormatter.formatDate(
      dateTimeInString: dateID,
    );

    // if the record is not yet added, add it
    if (!await _isDailyRecordAlreadyRecorded(dateOnlyFormat)) {
      await _rootCollection.doc(dateOnlyFormat).set({
        "createdAt": DateTime.now().toString(),
        "dateID": dateOnlyFormat,
      }, SetOptions(merge: true));
      // this print is for debugging purposes only
      print("CREATE RECORD: DAILY RECORD HAS BEEN ADDED");

      // first, get all the task from the HomeLifePlanner
      //        HomeLifePlanner is the source of truth forthese tasks
      List<HomeLifePlannerModel> tasks =
          await HomeLifePlannerRepository.getAllTasks();
      // then, iterate all the tasks to make individual records
      for (var task in tasks) {
        // in each task, there are multiple participants, so get each participant's ID by spliting them
        List participantsIDs = task.participants.split(",");
        // and then, iterate again, base on those participantsIDs
        for (var participantID in participantsIDs) {
          // since those are just IDs, now we need to get the actual data of those participant patient
          //                           so we can use them later on
          PersonalInfo personalInfo =
              await MyPersonalInfoRepository.getSpecificPersonalInfo(
                userID: participantID,
              );
          //

          /// TODO: this implementation of customized ID is not yet final, because it might not work as intended later on.
          // this is for creating a customized taskID, that is Readable in the database (for debugging purposes)
          String tempTaskID = "L2_${personalInfo.name}_${task.taskName}";
          // after that, replace all the whitespaces with underscores, so that it will be a single word
          //             I am not still familiar with RegExp's symbols hehe
          String formattedTaskID = tempTaskID.replaceAll(RegExp(r'\s+'), '_');

          // finally, for the Layer 2 (HLParticipants)
          //          Add those participants in the dailyRecord
          _addParticipant(
            dateID: dateOnlyFormat,
            patient: HLPatientTaskModel(
              patientName: personalInfo.name,
              assignedCaregiver: task.createdBy,
            ),

            /// TODO: this implementation of customized ID is not yet final, because it might not work as intended later on.
            // the taskID for each individual task is named from the combination
            //            of taskName and participant patient's name (for readability in the database, debugging purposes)
            taskID: formattedTaskID,
          );
          print("ADDED PARTICIPANT: ${personalInfo.name}");

          // and also, finally, for the Layer 3 (HLTasks)
          //            Add those tasks in the dailyRecord
          _addTask(
            dateID: dateOnlyFormat, // for L1 Doc
            participantID: formattedTaskID, // for L2 Doc
            task: HLTaskModel(
              // L3 just means Layer 3, to indicate it is in the Tasks
              taskID: "L3_$formattedTaskID",
              taskName: task.taskName,
              description: task.taskDescription,
              isDone: false,
              caregiverId: task.createdBy,
            ),
          );
          print("ADDED TASKKKKK: L3_${formattedTaskID}");
        }
      }
    } else {
      print("CREATE RECORD: DAILY RECORD ALREADYYYY EXISTS");
    }
  }

  /// To check if the daily record is already recorded
  /// This method is visible in the back-end
  static Future<bool> _isDailyRecordAlreadyRecorded(String dateID) async {
    // bool isAlreadyRecorded = false;
    QuerySnapshot homeLifeRepository = await _rootCollection
        .where("dateID", isEqualTo: dateID)
        .get();

    // return isAlreadyRecorded;
    return homeLifeRepository.docs.isNotEmpty;
  }

  // =========================================================
  // Level 2: The Participant (The Patient)
  // =========================================================

  /// To ADD participants (patients) to the specific Date
  /// CHANGED: Added 'dateID' as a required parameter. No more 'bufferedTaskID'.
  /// ###### Part of the automation in createDailyRecord() method
  static Future<void> _addParticipant({
    required String dateID,
    required HLPatientTaskModel patient,
    // the taskID is a combination of taskName and the patientsName, for readability when debugging in the database hehe
    required String taskID,
  }) async {
    DocumentReference docRef = _rootCollection
        .doc(dateID)
        .collection("HLParticipants")
        .doc(taskID);

    await docRef.set({
      "patientID": taskID,
      "patientName": patient.patientName,
      "assignedCaregiverID": patient.assignedCaregiver,
    });
  }

  // =========================================================
  // Level 3: The Task (The Actual Job)
  // =========================================================

  /// To ADD a task for a specific patient on a specific day
  /// ###### Part of the automation in createDailyRecord() method
  static Future<void> _addTask({
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
      "taskID": task
          .taskID, // Ensures the ID inside the data matches the document name
      "taskName": task.taskName,
      "description": task.description,
      "isDone": task.isDone,
      "caregiverId": task.caregiverId,
    });
  }

  // =========================================================
  // Deletion Logic
  // =========================================================

  // /// WARNING: This only deletes the 'cover'. The tasks inside still exist technically.
  // static Future<void> removeDailyRecord({required String dateID}) async {
  //   await _rootCollection.doc(dateID).delete();
  // }

  /// This will safely delete the dailyRecord doc and its nested data (subcollections and documents) insdie it.
  static Future<void> deleteDailyRecord(String dateID) async {
    // 1. Reference the day
    DocumentReference dayRef = _rootCollection.doc(dateID);
    // 2. FETCH all participants inside this day
    var participantsSnapshot = await dayRef.collection('HLParticipants').get();
    // 3. LOOP through each participant
    for (var participantDoc in participantsSnapshot.docs) {
      // A. FETCH all tasks for this participant
      var tasksSnapshot = await participantDoc.reference
          .collection('HLTasks')
          .get();
      // B. DELETE every task (Batching is faster, but simple loop works for small data)
      for (var taskDoc in tasksSnapshot.docs) {
        await taskDoc.reference.delete();
      }
      // C. DELETE the participant document itself
      await participantDoc.reference.delete();
    }
    // 4. FINALLY, delete the day (the parent document)
    await dayRef.delete();
  }

  /// This is for safely deleting an Individual's Record
  static Future<void> deleteIndividualRecord({
    required String dateID,
    required String taskID,
  }) async {
    // 1. Reference the day
    DocumentReference dayRef = _rootCollection.doc(dateID);
    // 2. FETCH all participants inside this day
    var participantsSnapshot = await dayRef
        .collection('HLParticipants')
        .doc(taskID)
        .get();
    // A. FETCH all tasks for this participant
    var tasksSnapshot = await participantsSnapshot.reference
        .collection('HLTasks')
        .get();
    // B. DELETE every task (Batching is faster, but simple loop works for small data)
    for (var taskDoc in tasksSnapshot.docs) {
      await taskDoc.reference.delete();
    }
    // C. DELETE the participant document itself
    await participantsSnapshot.reference.delete();
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
