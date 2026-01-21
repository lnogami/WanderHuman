import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';

class HomeAppBarProvider extends ChangeNotifier {
  // bool isExpanded = false;

  // Widget cachedImageWidget = MyImageDisplayer();
  // String _cachedImageString = "";
  Uint8List? _cachedImageString;
  // to contain the fetched user name
  String _userName = "...";

  Uint8List? get cachedImageString => _cachedImageString;
  String get userName => _userName;

  // /// if Expanded, then Collaps, otherwise reverse.
  // void toggleAppBar() {
  //   isExpanded = !isExpanded;
  //   notifyListeners(); // this is just like a setState() but for providers
  // }

  /// Fetches BOTH the Name and the Profile Picture string at once.
  /// Call this in initState of your Home screen.
  Future<void> initUserData() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the full object once to save reads
      PersonalInfo info =
          await MyPersonalInfoRepository.getSpecificPersonalInfo(userID: uid);

      _userName = info.name;
      _cachedImageString = await compute(base64Decode, info.picture.toString());

      notifyListeners(); // Updates both App Bar and Modal immediately
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  /// Call this specifically after uploading a new picture
  Future<void> refreshProfilePicture({String? userID}) async {
    try {
      final String uid = userID ?? FirebaseAuth.instance.currentUser!.uid;
      PersonalInfo info =
          await MyPersonalInfoRepository.getSpecificPersonalInfo(userID: uid);

      // _cachedImageString = info.picture.toString();

      _cachedImageString = await compute(base64Decode, info.picture.toString());
      notifyListeners();
    } catch (e) {
      print("Error refreshing picture: $e");
    }
  }
}

// String profilePictureBase64String()  {

//   return MyPersonalInfoRepository.getSpecificPersonalInfo(userID: FirebaseAuth.instance.currentUser!.uid)
//       .then((personalInfo) {
//       return personalInfo.picture;
//   });

// }
