import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/home_life_models/hl_planner_model.dart';

class HomeLifePlannerRepository {
  static final CollectionReference _collectionReference = FirebaseFirestore
      .instance
      .collection("HLPlanner");

  // to generatedID beforehand
  static DocumentReference _generatedDocID() {
    return _collectionReference.doc();
  }

  // ADD
  static void addTask(HomeLifePlannerModel planner) {
    DocumentReference docRef = _generatedDocID();

    docRef.set({
      "taskID": docRef.id,
      "taskName": planner.taskName,
      "taskDescription": planner.taskDescription,
      "participants": planner.participants,
      "repeatInterval": planner.repeatInterval,
      "time": planner.time,
      "fromDate": planner.fromDate,
      "untilDate": planner.untilDate,
      "createdAt": planner.createdAt,
      "createdBy": planner.createdBy,
    });
  }

  // EDIT
  static void editTask({
    required taskID,
    required HomeLifePlannerModel planner,
  }) {
    DocumentReference docRef = _collectionReference.doc(taskID);
    docRef.set({
      // "taskID": docRef.id, // NOT EDITABLE
      "taskName": planner.taskName,
      "participants": planner.participants,
      "taskDescription": planner.taskDescription,
      "repeatInterval": planner.repeatInterval,
      "time": planner.time,
      // "scheduledDate": planner.scheduledDate,
      "fromDate": planner.fromDate,
      "untilDate": planner.untilDate,
      // "createdAt": planner.createdAt, // NOT EDITABLE
      "createdBy": planner.createdBy,
    }, SetOptions(merge: true));
  }

  // READ
  /// Can work with or without providing the following argument.
  static Future<List<HomeLifePlannerModel>> getAllTasks({
    String? field,
    String? value,
  }) async {
    late QuerySnapshot querySnapshot;

    // for querying purposes
    if (field != null && value != null) {
      querySnapshot = await _collectionReference
          .where(field, isEqualTo: value)
          .get();
    }
    // for no query, get all records
    else {
      querySnapshot = await _collectionReference.get();
    }

    List<HomeLifePlannerModel> tasks = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return HomeLifePlannerModel.fromFirebase(taskID: doc.id, data: data);
    }).toList();

    return tasks;
  }

  // DELETE
  static Future<void> deleteTask({required String taskID}) async {
    _collectionReference.doc(taskID).delete();
  }
}
