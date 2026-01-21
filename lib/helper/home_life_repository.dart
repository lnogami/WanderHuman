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
  /// Root collection reference (1st Layer)
  static final CollectionReference _rootCollection = FirebaseFirestore.instance
      .collection("HomeLife");

  /// This is the 2nd Layer of data (subcollection 1) where it is for participants
  static final String _subcollection1 = "HLParticipants";

  /// This is the 3nd Layer of data (subcollection 2) where it is for the tasks for each participants
  static final String _subcollection2 = "HLTasks";

  // =========================================================
  // Level 1: The Date (The "Container")
  // =========================================================

  /// Creates the document for the day (e.g., 'DEC 17,2025' or '2025-10-27')
  /// ##### This will only create a Document once per day
  /// The [bool] return type is not really needed to be use, it's just
  /// for debugging purposes only, its still works without using the return type.  <br>
  /// returns `true` if the dailyRecord successfully created, `false` otherwise
  static Future<bool> createDailyRecord({required String dateID}) async {
    // to format the date (remove the time) so we could have a uniform time
    String dateOnlyFormat = MyDateFormatter.formatDate(
      dateTimeInString: dateID,
    );

    // if the record is not yet added, add it
    if (!await _isDailyRecordAlreadyRecorded(dateOnlyFormat)) {
      // create the first Layer document
      await _rootCollection.doc(dateOnlyFormat).set({
        "createdAt": DateTime.now().toString(),
        "dateID": dateOnlyFormat,
      }, SetOptions(merge: true));

      // this print is for debugging purposes only
      print("CREATE RECORD: DAILY RECORD HAS BEEN ADDED");

      // first, get all the task from the HomeLifePlanner
      //        HomeLifePlanner is the source of truth for these tasks
      List<HomeLifePlannerModel> tasks =
          await HomeLifePlannerRepository.getAllTasks();
      // then, iterate all the tasks to make individual records
      for (var task in tasks) {
        // in each task, there are multiple participants, so get each participant's ID by spliting them
        List<String> participantsIDs = task.participants.split(",");
        // and then, iterate again, base on those participantsIDs
        for (var participantID in participantsIDs) {
          // since those are just IDs, now we need to get the actual data of those participant patient
          //                           so we can use them later on
          PersonalInfo personalInfo =
              await MyPersonalInfoRepository.getSpecificPersonalInfo(
                userID: participantID,
              );

          // /// TODO: this implementation of customized ID is not yet final, because it might not work as intended later on.
          // // this is for creating a customized taskID, that is Readable in the database (for debugging purposes)
          // String tempTaskID = "L2_${personalInfo.name}_${task.taskName}";
          // // after that, replace all the whitespaces with underscores, so that it will be a single word
          // //             I am not still familiar with RegExp's symbols hehe
          // String formattedTaskID = tempTaskID.replaceAll(RegExp(r'\s+'), '_');

          // finally, for the Layer 2 (HLParticipants)
          //          Add those participants in the dailyRecord
          _addParticipant(
            dateID: dateOnlyFormat,
            patient: HLPatientTaskModel(
              patientName: personalInfo.name,
              assignedCaregiver: task.createdBy,
            ),

            /// TODO the four commented out lines below this is deletable
            // (deletable) : this implementation of customized ID is not yet final, because it might not work as intended later on.
            // the taskID for each individual task is named from the combination
            //            of taskName and participant patient's name (for readability in the database, debugging purposes)
            // taskID: formattedTaskID,
            taskID: participantID,
          );
          print("ADDED PARTICIPANT: ${personalInfo.name}");

          // this will filter out the task that has not schedule for this day
          // for example lets's say the only day schedule a task have is Mon and today is Tuesday
          //             therefore the task will not be created because today is not it's scheduled day.
          List<String> daySchedule = task.repeatInterval.split(",");
          // and also, if todays date exceeds the untilDate, the task does not created.
          DateTime untilDateInDateTimeFormat = DateTime.parse(task.untilDate)
              .add(
                Duration(days: 1),
              ); // add 1 day because the condition is < today

          if (daySchedule.contains(
                MyDateFormatter.formatDate(
                  dateTimeInString: DateTime.now(),
                  formatOptions: 7,
                  customedFormat:
                      "EEE", // EEE means short name of day ex.Mon,Tue
                ),
              ) &&
              // if today is before the untilDate, the task will be created
              DateTime.now().isBefore(untilDateInDateTimeFormat)) {
            // and also, finally, for the Layer 3 (HLTasks)
            //            Add those tasks in the dailyRecord
            _addTask(
              dateID: dateOnlyFormat, // for L1 Doc
              participantID: participantID, // for L2 Doc
              task: HLTaskModel(
                taskID: task.taskID,
                taskName: task.taskName,
                description: task.taskDescription,
                time: task.time,
                isDone: false,
                isDoneBy: '', // will be filled later when it isDone is true,
                caregiverId: task.createdBy,
                createdAt: dateID,
              ),
            );
          } else {
            print(
              "NOTICEEEEEEEEEE: Task: ${task.taskName}, was not created because it's either beyond the untilDate of (${task.untilDate} while today is ${DateTime.now()}), OR today is not in its schedule ${daySchedule.join(", ")}",
            );
          }
        }
      }
      // this bool return type is for debugging purposes only
      return true;
    } else {
      print("CREATE RECORD: DAILY RECORD ALREADYYYY EXISTS");
      // this bool return type is for debugging purposes only
      return false;
    }
  }

  /// To check if the daily record is already recorded
  /// This method is only visible in the back-end
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
      "time": task.time,
      "isDone": task.isDone,
      "isDoneBy": task.isDoneBy,
      "caregiverId": task.caregiverId,
      "createdAt": task.createdAt,
    });
  }

  // Use this `ONLY` if the IndividualTasks for the days is already created and you want to add a task in the planner.
  static Future<bool> insertDailyRecord({
    required String dateID,
    required HomeLifePlannerModel task,
  }) async {
    // to format the date (remove the time) so we could have a uniform time
    String dateOnlyFormat = MyDateFormatter.formatDate(
      dateTimeInString: dateID,
    );

    // if the record is not yet added, add it
    if (await _isDailyRecordAlreadyRecorded(dateOnlyFormat)) {
      // await _rootCollection.doc(dateOnlyFormat).set({
      //   "createdAt": DateTime.now().toString(),
      //   "dateID": dateOnlyFormat,
      // }, SetOptions(merge: true));
      // // this print is for debugging purposes only
      // print("CREATE RECORD: DAILY RECORD HAS BEEN ADDED");

      // // first, get all the task from the HomeLifePlanner
      // //        HomeLifePlanner is the source of truth for these tasks
      // List<HomeLifePlannerModel> tasks =
      //     await HomeLifePlannerRepository.getAllTasks();
      // then, iterate all the tasks to make individual records
      // for (var task in tasks) {

      // in each task, there are multiple participants, so get each participant's ID by spliting them
      List<String> participantsIDs = task.participants.split(",");
      // and then, iterate again, base on those participantsIDs
      for (var participantID in participantsIDs) {
        // since those are just IDs, now we need to get the actual data of those participant patient
        //                           so we can use them later on
        PersonalInfo personalInfo =
            await MyPersonalInfoRepository.getSpecificPersonalInfo(
              userID: participantID,
            );

        // finally, for the Layer 2 (HLParticipants)
        //          Add those participants in the dailyRecord
        _addParticipant(
          dateID: dateOnlyFormat,
          patient: HLPatientTaskModel(
            patientName: personalInfo.name,
            assignedCaregiver: task.createdBy,
          ),
          taskID: participantID,
        );
        print("ADDED PARTICIPANT: ${personalInfo.name}");

        // this will filter out the task that has not schedule for this day
        List<String> daySchedule = task.repeatInterval.split(",");
        if (daySchedule.contains(
          MyDateFormatter.formatDate(
            dateTimeInString: DateTime.now(),
            formatOptions: 7,
            customedFormat: "EEE", // EEE means short name of day ex.Mon,Tue
          ),
        )) {
          // and also, finally, for the Layer 3 (HLTasks)
          //            Add those tasks in the dailyRecord
          _addTask(
            dateID: dateOnlyFormat, // for L1 Doc
            participantID: participantID, // for L2 Doc
            task: HLTaskModel(
              taskID: task.taskID,
              taskName: task.taskName,
              description: task.taskDescription,
              time: task.time,
              isDone: false,
              isDoneBy: '', // will be filled later when it isDone is true
              caregiverId: task.createdBy,
              createdAt: dateOnlyFormat,
            ),
          );
        }

        print("ADDED TASKKKKK TO: ${participantID}}");
      }
      // }

      // this bool return type is for debugging purposes only
      return true;
    } else {
      print(
        "INSERT RECORD STATUS: DAILY RECORD WAS NOT YET BEEN CREATED. WAITING FOR THE INDIVIDUAL TASK PAGE TO OPEN",
      );
      // this bool return type is for debugging purposes only
      return false;
    }
  }

  // =========================================================
  // Getter Logic
  // =========================================================

  /// This function has two purposes:
  /// 1. For retrieving all individual patient's tasks, DO NOT provide an argument for `isToRetrieveUnFinishTasks` <br>
  /// 2. To retrieve only those unfinished tasks, provide `isToRetrieveUnFinishTasks` as `true`
  static Future<List<HLTaskModel>> getIndividualPatientTasks({
    required String dateID,
    required String participantID,
    bool isToRetrieveUnFinishTasks = false,
  }) async {
    try {
      // QuerySnapshot tasksSnapshot = await _rootCollection
      //     .doc(dateID)
      //     .collection(_subcollection1)
      //     .doc(participantID)
      //     .collection(_subcollection2)
      //     .get();

      late QuerySnapshot tasksSnapshot;

      // if calling this function to retrieve unfinished task
      if (isToRetrieveUnFinishTasks) {
        tasksSnapshot = await _rootCollection
            .doc(
              MyDateFormatter.formatDate(
                // dateTimeInString: DateTime.now().toString(),
                dateTimeInString: dateID,
              ),
            )
            .collection(_subcollection1)
            .doc(participantID)
            .collection(_subcollection2)
            .where("isDone", isEqualTo: false)
            .get();

        print("TASKSNAPSHOT DOC COUNT: ${tasksSnapshot.size}");
      }
      // else, if calling this function to retrieve all task
      else {
        tasksSnapshot = await _rootCollection
            .doc(
              MyDateFormatter.formatDate(
                // dateTimeInString: DateTime.now().toString(),
                dateTimeInString: dateID,
              ),
            )
            .collection(_subcollection1)
            .doc(participantID)
            .collection(_subcollection2)
            .get();

        print("TASKSNAPSHOT DOC COUNT: ${tasksSnapshot.size}");
      }

      // // what's happening here is that we use the QuerySnapshot [taskSnapshot]
      // // to call all the documents [docs]
      // // then, iterate all the documents with a doc variable as parameter (this returns an Iterable object)
      // //      in each doc, we get its data by calling .data(),
      // //                   then we convert it as Map<String, dynmic> because .data() will return a generic Object
      // //                   then return it as an HLTaskModel object, it will be
      // //                        added to the .toList() method one by one in each iteration
      // // then, after iterating all the doc in docs, we will convert to .toList()
      // //       because .map((e){}) will not run in the first place if it wont call .toList(), the CPU will just skip the .map((e){})
      // //       method calling the .toList() will materialize the data inside it, meaning those data will be created in memory
      // // finally, return it as a list of HLTaskModel objects
      // return tasksSnapshot.docs.map((doc) {
      //   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      //   return HLTaskModel.fromFirestore(data, doc.id);
      // }).toList();
      List<HLTaskModel> tasks = tasksSnapshot.docs.map((doc) {
        // 1. EXTRACT: We cast .data() to a Map because Firestore returns a generic Object.
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // print("DOES NOT ERROR AFTER CASTING");
        // print("IS DATA EMPTY?: ${data.isEmpty}");

        // 2. TRANSFORM: We convert the raw Map into our clean HLTaskModel object.
        return HLTaskModel.fromFirestore(data, doc.id);
      }).toList();
      // 3. EXECUTE: .map() is "Lazy". It prepares the transformation instruction but doesn't run it yet.
      //    Calling .toList() forces the iteration to happen NOW, processing all documents
      //    and returning the final List<HLTaskModel>.

      // sorts the list chronologically (by converting time to minutes)
      // I think this somewhat like a quicksort, a as the pivot (middle element in the list)
      // a compared to b, if a is smaller than b return -1 then b will go to the right side of a and vice versa.
      tasks.sort((a, b) {
        return _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time));
      });

      return tasks;
    }
    // just in case an error occurs, we will know what it is
    catch (e) {
      print(
        "ERROW WHEN RETRIEVING DATAAAAAAAAAAAAAAAAA in getIndividualPatientTasks method: $e",
      );
      // throw FirebaseException(plugin: e.toString());
      rethrow;
    }
  }

  // Helper function to convert "03:00 PM" -> 900 (minutes)
  // THIS IS FROM GEMINI not my code hehe
  /// This function is associated for helping to sort a list based on Time
  static int _timeToMinutes(String timeString) {
    // 1. Split the string into parts: "03:00" and "PM"
    // Assuming format "hh:mm AM/PM" or "h:mm AM/PM"
    final parts = timeString.split(' ');
    final timeParts = parts[0].split(':');

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    String period = parts[1]; // AM or PM

    // 2. Adjust hour for AM/PM logic
    if (period == "PM" && hour != 12) {
      hour += 12; // 3 PM becomes 15
    } else if (period == "AM" && hour == 12) {
      hour = 0; // 12 AM becomes 0
    }

    // 3. Return total minutes
    return (hour * 60) + minute;
  }

  // TODO not yet implemented
  /// This will return all the dailyTaskRecorded of an Individual.
  static Future<List<HLTaskModel>> getAllIndividualPatientTasks({
    required String dateID,
    required String participantID,
    bool isToRetrieveUnFinishTasks = false,
  }) async {
    try {
      List<HLTaskModel> allTasks = [];
      List<String> dates = await getAllDaysOfRecordedTasks();

      for (var date in dates) {
        QuerySnapshot tasksSnapshot = await _rootCollection
            .doc(MyDateFormatter.formatDate(dateTimeInString: date))
            .collection(_subcollection1)
            .doc(participantID)
            .collection(_subcollection2)
            .get();

        print("TASKSNAPSHOT DOC COUNT: ${tasksSnapshot.size}");

        List<HLTaskModel> tasks = tasksSnapshot.docs.map((doc) {
          // 1. EXTRACT: We cast .data() to a Map because Firestore returns a generic Object.
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // print("DOES NOT ERROR AFTER CASTING");
          // print("IS DATA EMPTY?: ${data.isEmpty}");

          // 2. TRANSFORM: We convert the raw Map into our clean HLTaskModel object.
          return HLTaskModel.fromFirestore(data, doc.id);
        }).toList();
        // 3. EXECUTE: .map() is "Lazy". It prepares the transformation instruction but doesn't run it yet.
        //    Calling .toList() forces the iteration to happen NOW, processing all documents
        //    and returning the final List<HLTaskModel>.

        // sorts the list chronologically (by converting time to minutes)
        // I think this somewhat like a quicksort, a as the pivot (middle element in the list)
        // a compared to b, if a is smaller than b return -1 then b will go to the right side of a and vice versa.
        tasks.sort((a, b) {
          return _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time));
        });

        allTasks.addAll(tasks);
      }

      // return tasks;
      return allTasks.reversed.toList();
    }
    // just in case an error occurs, we will know what it is
    catch (e) {
      print(
        "ERROW WHEN RETRIEVING DATAAAAAAAAAAAAAAAAA in getIndividualPatientTasks method: $e",
      );
      // throw FirebaseException(plugin: e.toString());
      rethrow;
    }
  }

  static Future<bool> getTaskStatus({
    required String dateID,
    required String participantID,
    required String taskID,
  }) async {
    // NOTE: always use MyDateFormatter in the first doc, because we named the first doc
    //       as a formatter date String like "Jan 10, 2025".
    //       Otherwise, it will cause an unintended bug.
    DocumentSnapshot<Map<String, dynamic>> docRef = await _rootCollection
        .doc(MyDateFormatter.formatDate(dateTimeInString: dateID))
        .collection("HLParticipants")
        .doc(participantID)
        .collection("HLTasks")
        .doc(taskID)
        .get();
    Map doc = docRef.data() as Map<String, dynamic>;

    return doc["isDone"];
  }

  /// Will return all the dateID (doc ID) of all the dailyRecordedTask
  static Future<List<String>> getAllDaysOfRecordedTasks() async {
    QuerySnapshot records = await _rootCollection.get();

    // will return all the dateID
    return records.docs.map((doc) {
      return doc.id;
    }).toList();
  }

  // =========================================================
  // Update Logic
  // =========================================================

  // TODO: not yet implemented
  /// To update the status (isDone) of a task
  static Future<void> updateIsDoneTaskStatus({
    required String dateID,
    required String participantID,
    required String taskID,
    required bool isDone,
    required String isDoneBy,
  }) async {
    try {
      // NOTE: always use MyDateFormatter in the first doc, because we named the first doc
      //       as a formatter date String like "Jan 10, 2025".
      //       Otherwise, it will cause an unintended bug.
      DocumentReference docRef = _rootCollection
          .doc(MyDateFormatter.formatDate(dateTimeInString: dateID))
          .collection("HLParticipants")
          .doc(participantID)
          .collection("HLTasks")
          .doc(taskID);

      bool isAlreadyDone = await getTaskStatus(
        dateID: dateID,
        participantID: participantID,
        taskID: taskID,
      );

      // only update if status isDone is false
      if (!isAlreadyDone) {
        await docRef.set({
          "isDone": isDone,
          "isDoneBy": isDoneBy,
        }, SetOptions(merge: true));
      }

      print("SUCCESSFULLY UPDATED TASK STATUS: $isDone");
    } catch (e) {
      print("ERROR WHEN UPDATING TASK STATUS: $e");
    }
  }

  /// To update a task
  static Future<void> updateTask({
    required String dateID,
    required String participantID,
    required HLTaskModel task,
  }) async {
    DocumentReference docRef = _rootCollection
        .doc(
          MyDateFormatter.formatDate(
            dateTimeInString: DateTime.now().toString(),
          ),
        )
        .collection("HLParticipants")
        .doc(participantID)
        .collection("HLTasks")
        .doc(task.taskID);

    await docRef.set({
      "taskID": task
          .taskID, // Ensures the ID inside the data matches the document name
      "taskName": task.taskName,
      "description": task.description,
      "time": task.time,
      "isDone": task.isDone,
      // "isDoneBy": task.isDoneBy,
      "caregiverId": task.caregiverId,
      // "createdAt": task.createdAt,
    }, SetOptions(merge: true));
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

  /// for deleting a single task of the day
  static Future<void> deleteATaskForTheDay({
    required String dateID,
    required String participantID,
    required String taskID,
  }) async {
    try {
      // split all the participants of the task
      List<String> participantsIDs = participantID.split(",");
      // and then, iterate each participant's ID then delete each corresponding task.
      for (var participantID in participantsIDs) {
        DocumentReference docRef = _rootCollection
            .doc(
              MyDateFormatter.formatDate(
                dateTimeInString: DateTime.now().toString(),
              ),
            )
            .collection("HLParticipants")
            .doc(participantID)
            .collection("HLTasks")
            .doc(taskID);

        await docRef.delete();
        // final taskName = docRef as Map;
        // print("${taskName["taskName"]}");
      }
      print("SUCCESSFULLY DELETE THE TASK FOR EACH INDIVIDUAL PARTICIPANTS.");
    } catch (e) {
      print("ERROR DELETING A TASK IN HOMELIFEREPOSITORY, ERROR: $e");
      rethrow;
    }
  }

  // static Future<void> removeParticipant({
  //   required String dateID,
  //   required String participantID,
  // }) async {
  //   // This leaves the patient's tasks orphaned, but removes the patient from the list
  //   await _rootCollection
  //       .doc(dateID)
  //       .collection("HLParticipants")
  //       .doc(participantID)
  //       .delete();
  // }
}
