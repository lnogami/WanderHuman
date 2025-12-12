// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderhuman_app/model/personal_info.dart';

class MyPersonalInfoRepository {
  // cache of Personal Info
  static final CollectionReference _personalInfoCollectionReference =
      FirebaseFirestore.instance.collection("Personal Info");

  static String _userType = "";

  // static List<PersonalInfo> _personalInfoRecords = []; // caching purposes

  // this will create the document reference with a unique ID. (It is just a document without data yet).
  static DocumentReference _genereatePatientID() {
    return _personalInfoCollectionReference.doc();
  }

  // this will add data to the document with the unique ID
  static void addPatient(PersonalInfo patient) {
    DocumentReference docRef = _genereatePatientID();

    // .set method is just an add({}), but here we can specify the document ID
    //      which is the purpose of _genereatePatientID() method (to create a
    //      document first, then use that created document's ID as the ID).
    docRef.set({
      "userID": docRef.id,
      "userType": patient.userType,
      "name": patient.name,
      "age": patient.age,
      "sex": patient.sex,
      "birthdate": patient.birthdate,
      "contactNumber": patient.contactNumber,
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

      print('✅🔍 Successfully fetched ${patients.length} patients');
      return patients;
    } catch (e) {
      print("🔍 $e");
      throw Exception();
    }
  }

  static Future<PersonalInfo> getSpecificPersonalInfo({
    required String userID,
  }) async {
    try {
      List<PersonalInfo> allPersonalInfoRecords =
          await getAllPersonalInfoRecords();
      PersonalInfo? personalInfo;

      for (var individualRecord in allPersonalInfoRecords) {
        if (individualRecord.userID == userID) {
          personalInfo = individualRecord;
        }
      }

      if (personalInfo == null)
        throw Exception("❌❌❌ No PersonalInfo found for userID: $userID");

      return PersonalInfo(
        userID: personalInfo.userID,
        userType: personalInfo.userType,
        name: personalInfo.name,
        age: personalInfo.age,
        sex: personalInfo.sex,
        birthdate: personalInfo.birthdate,
        contactNumber: personalInfo.contactNumber,
        address: personalInfo.address,
        notableBehavior: personalInfo.notableBehavior,
        picture: personalInfo.picture,
        createdAt: personalInfo.createdAt,
        lastUpdatedAt: personalInfo.lastUpdatedAt,
        registeredBy: personalInfo.registeredBy,
        asignedCaregiver: personalInfo.asignedCaregiver,
        deviceID: personalInfo.deviceID,
        email: personalInfo.email,
      );
    } catch (e) {
      print("❌ AN EXCEPTION OCCURRED IN getSpecificPersonalInfo METHOD: $e");
      throw Exception();
    }
  }

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
        print(
          "FOUNDDDDDDDDDDDDDDDDDDDDDDDDDDDD User: ${person.name}  with user type: $_userType",
        );
        return person.name;
      }
    }

    return "No User Found!";
  }

  static Future<void> uploadProfilePicture({
    // required String docID,
    required String userID,
    required String base64Image,
  }) async {
    try {
      // MyPersonalInfoRepository.getSpecificPersonalInfo(
      //   userID: FirebaseAuth.instance.currentUser!.uid,
      // ).then((personalInfo) async {
      //   String? docID = await MyPersonalInfoRepository.getDocIdByUserId(
      //     personalInfo.userID,
      //   );
      //   print("THE DOCUMENT ID OF ${personalInfo.userID} is: $docID");
      //   print(
      //     "PERSONAL INFO FETCHED IN FORM AFTER PICKING IMAGE: ${personalInfo.userID}",
      //   );
      //   MyPersonalInfoRepository.uploadProfilePicture(
      //     docID: docID!,
      //     base64Image: value,
      //   );
      // });

      String? docID = await getDocIdByUserId(userID);

      await _personalInfoCollectionReference.doc(docID).update({
        "profilePictureURL": base64Image,
      });
      print("✅✅✅ Successfully uploaded profile picture for userID: $docID");
    } catch (e) {
      print("❌❌❌ Error uploading profile picture: $e");
      throw Exception();
    }
  }

  static Future<String?> getDocIdByUserId(String targetUserId) async {
    final collectionRef = FirebaseFirestore.instance.collection(
      'Personal Info',
    );

    // Query the collection
    final querySnapshot = await collectionRef
        .where('userID', isEqualTo: targetUserId) // Searching contents
        .limit(1) // Optimization: Stop after finding the first match
        .get();

    // Check if we found any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Access the first document found
      final docSnapshot = querySnapshot.docs.first;

      // Return the Document ID
      return docSnapshot.id;
    } else {
      print("No document found with userID: $targetUserId");
      return null;
    }
  }
}
