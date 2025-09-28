import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/history.dart';
import 'package:wanderhuman_app/model/personal_info.dart';

class MyFirebaseServices {
  // cache of Personal Info
  static final CollectionReference _personalInfoCollectionReference =
      FirebaseFirestore.instance.collection("Personal Info");

  static final CollectionReference _historyCollectionReference =
      FirebaseFirestore.instance.collection("History");

  static String _userType = "";
  // static List<PersonalInfo> _personalInfoRecords = []; // caching purposes

  // this will create the document reference with a unique ID. (It is just a document without data yet).
  static DocumentReference _genereatePatientID() {
    return _personalInfoCollectionReference.doc();
  }

  // this will add data to the document with the unique ID
  static void addPatient(PersonalInfo patient) {
    // .set method is just an add({}), but here we can specify the document ID which is the purpose of _genereatePatientID() method.
    _genereatePatientID().set({
      "userID": _genereatePatientID().id,
      "userType": patient.userType,
      "name": patient.name,
      "age": patient.age,
      "sex": patient.sex,
      "birthdate": patient.birthdate,
      "guardianContactNumber": patient.guardianContactNumber,
      "address": patient.address,
      "notableBehavior": patient.notableBehavior,
      "picture": patient.picture,
      "createdAt": patient.createdAt.toString(),
      "lastUpdatedAt": patient.lastUpdatedAt.toString(),
      "registeredBy": patient.registeredBy,
      "asignedCaregiver": patient.asignedCaregiver,
      "deviceID": patient.deviceID,
      // "email": patient.email,
    });
  }

  // returns all the records there is in PersonalInfo collection in database (FirebaseFirestore)
  static Future<List<PersonalInfo>> getAllPersonalInfoRecords() async {
    try {
      QuerySnapshot querySnapshot = await _personalInfoCollectionReference
          // .where("userType", isEqualTo: "Patient")
          .get();
      List<PersonalInfo> patients = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PersonalInfo.fromFirestore(doc.id, data);
      }).toList();

      // // to cache personal innfo records, for the purpose of getPatientIdAandName()
      // _personalInfoRecords = patients;

      // ignore: avoid_print
      print('✅🔍 Successfully fetched ${patients.length} patients');
      return patients;
    } catch (e) {
      // ignore: avoid_print
      print("🔍 $e");
      throw Exception();
    }
  }

  // To get the name of a specific Logged In user.
  // And behind the scene sets the userType which is callable by getUserType() method

  /// Gets the name of the currently logged-in user and sets their userType
  /// in the static [_userType] variable for app-wide access.
  ///
  /// ⚠️ **Important:** This should ONLY be called during login/authentication process
  /// as it modifies the global user state.
  ///
  /// **Parameters:**
  /// - [personsList] - List containing user records from Firestore
  /// - [userIDToLookFor] - The authenticated user's ID
  ///
  /// **Side effects:**
  /// - Sets the static [_userType] variable
  /// - Prints debug information to console
  ///
  /// **Example:**
  /// ```dart
  /// List<PersonalInfo> allUsers = await getAllPersonalInfoRecords();
  /// String currentUserName = getSpecificUserNameOfTheLoggedInAccount(
  ///   personsList: allUsers,
  ///   userIDToLookFor: authenticatedUserID,
  /// );
  /// // Now getUserType() will return the correct user type
  /// ```
  static String getSpecificUserNameOfTheLoggedInAccount({
    required List<PersonalInfo> personsList,
    required String userIDToLookFor,
  }) {
    for (var person in personsList) {
      if (person.userID == userIDToLookFor) {
        // sets user type behind the scene, accessible only on getUserType method.
        _userType = person.userType;
        return person.name;
      }
    }
    return "No User Found!";
  }

  /// To get the role of the current user (Caregiver or Admin).
  static String getUserType() {
    return _userType;
  }

  /// Gets the name of any user from the records without affecting
  /// the logged-in user's context or [_userType] variable.
  /// Use this for general lookups, displaying patient names, etc.
  ///
  /// **Parameters:**
  /// - [personsList] - List of all PersonalInfo records
  /// - [userIDToLookFor] - The user ID to search for
  ///
  /// **Returns:** The user's name if found, `"No User Found!"` otherwise.
  ///
  /// **Example usage:**
  /// ```dart
  /// List<PersonalInfo> users = await MyFirebaseServices.getAllPersonalInfoRecords();
  /// String userName = MyFirebaseServices.getSpecificUserName(
  ///   personsList: users,
  ///   userIDToLookFor: "some-user-id"
  /// );
  /// ```
  static String getSpecificUserName({
    required List<PersonalInfo> personsList,
    required String userIDToLookFor,
  }) {
    for (var person in personsList) {
      if (person.userID == userIDToLookFor) {
        // ignore: avoid_print
        print(
          "FOUNDDDDDDDDDDDDDDDDDDDDDDDDDDDD User: ${person.name}  with user type: $_userType",
        );
        return person.name;
      }
    }
    // print("NO USER FOUND!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    return "No User Found!";
  }

  //// NOT WORKING YET
  // static Future<List<String>> getAllUserID() async {
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection("Personal Info")
  //         .get();
  //     List<String> userIDs = querySnapshot.docs.map((doc) => doc.id).toList();
  //     return userIDs;
  //   } catch (e) {
  //     // ignore: avoid_print
  //     throw Exception("Error fetching user IDs: $e");
  //   }
  // }

  // FOR PATIENT SIMULATION
  static Future<void> savePatientLocation(PatientHistory patient) async {
    try {
      _historyCollectionReference.doc().set({
        "patientID": patient.patientID,
        "isInSafeZone": patient.isInSafeZone,
        "currentLocation": patient.currentLocation,
        "currentlyIn": patient.currentlyIn,
        "timeStamp": patient.timeStamp,
        "deviceBatteryPercentage": patient.deviceBatteryPercentage,
      });
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print("❌ Error on saving user location:${e.message}");
      throw Exception();
    }
  }

  // static Map<String, String> getPatientIdAandName() {
  //   try {
  //     _personalInfoRecords;
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print("❌ Error getting patient id and name: $e");
  //     throw Exception();
  //   }
  //
  //   return {};
  // }

  /// Retrieves all the latest records of patients
  static Future<List<PatientHistory>> getAllPatientsLatestHistory() async {
    try {
      // for caching until retrieval of certain needed records (documents)
      List<PatientHistory> allPatientLatestHistory = [];

      // for conditional purposes only
      final lastTimeEncounter = DateTime.now();

      // StreamSubscription
      _historyCollectionReference.snapshots().listen((snapshot) {
        // for every document in snapshot of documents
        for (var doc in snapshot.docs) {
          // retrieves a single document as a Map<String, dynamic>
          var data = doc.data() as Map<String, dynamic>;
          // retieve the timeStamp in the map
          DateTime timeStamp = DateTime.parse(data["timeStamp"]);
          // only retrive the document I needed, in this case, the latest patient record (document) their is.
          if (timeStamp.difference(lastTimeEncounter).inSeconds <= 30) {
            // if it is latest, then add the PatientHisotry to the List of PatientHistory
            allPatientLatestHistory.add(
              PatientHistory(
                patientID: doc["patientID"],
                isInSafeZone: doc["isInSafeZone"],
                currentlyIn: doc["currentlyIn"],
                currentLocation: doc["currentLocation"],
                timeStamp: timeStamp,
                deviceBatteryPercentage: doc["deviceBatteryPercentage"],
              ),
            );
          }
        }
      });
      return allPatientLatestHistory;
    } catch (e) {
      print("❌ Something went wrong in getAllPatientHistory function: $e");
      throw Exception();
    }
  }
}
