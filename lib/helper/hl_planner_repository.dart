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
  static void addTask(HomeLifePlanner planner) {
    DocumentReference docRef = _generatedDocID();

    docRef.set({
      "taskID": docRef.id,
      "taskName": planner.taskName,
      "participants": planner.participants,
      "scheduledDate": planner.scheduledDate,
      "createdAt": planner.createdAt,
      "createdBy": planner.createdBy,
    });
  }

  // EDIT
  static void editTask({required taskID, required HomeLifePlanner planner}) {
    DocumentReference docRef = _collectionReference.doc(taskID);
    docRef.set({
      // "taskID": docRef.id, // NOT EDITABLE
      "taskName": planner.taskName,
      "participants": planner.participants,
      "scheduledDate": planner.scheduledDate,
      // "createdAt": planner.createdAt, // NOT EDITABLE
      "createdBy": planner.createdBy,
    }, SetOptions(merge: true));
  }

  // READ
  /// Can work with or without providing the following argument.
  Future<List<HomeLifePlanner>> getAllTasks({
    String? field,
    String? value,
  }) async {
    late QuerySnapshot querySnapshot;

    if (field != null && value != null) {
      querySnapshot = await _collectionReference
          .where(field, isEqualTo: value)
          .get();
    } else {
      querySnapshot = await _collectionReference.get();
    }

    List<HomeLifePlanner> tasks = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return HomeLifePlanner.fromFirebase(taskID: doc.id, data: data);
    }).toList();

    return tasks;
  }

  // DELETE
  void deleteTask({required String taskID}) {
    _collectionReference.doc(taskID).delete();
  }
}
