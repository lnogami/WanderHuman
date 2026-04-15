import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';

class HomeAppBarProvider extends ChangeNotifier {
  // Widget cachedImageWidget = MyImageDisplayer();
  // String _cachedImageString = "";
  bool? _isAppBarExpanded;
  Uint8List? _cachedImageString;
  PersonalInfo? _loggedInUserData;

  bool get isAppBarExpanded => _isAppBarExpanded!;
  PersonalInfo get loggedInUserData => _loggedInUserData!;
  String get userName => _loggedInUserData?.name ?? "...";
  Uint8List? get cachedImageString => _cachedImageString;

  /// Fetches the personal data of the current logged in user. This must only be called once.
  Future<void> initUserData(PersonalInfo currentlyLoggedInUserData) async {
    try {
      _isAppBarExpanded = false;
      _loggedInUserData = currentlyLoggedInUserData;
      _cachedImageString = await compute(
        base64Decode,
        currentlyLoggedInUserData.picture,
      );

      notifyListeners(); // Updates both App Bar and Modal immediately
    } catch (e) {
      log("Error fetching user data: $e");
    }
  }

  /// The value must be a true or false.
  Future<void> toggleAppBarExpansion(bool value) async {
    _isAppBarExpanded = value;
    notifyListeners();
    log("AppBar expansion toggled to $_isAppBarExpanded");
  }

  /// Call this when something changes in this current logged in user's data
  Future<void> refreshLoggedInUserData() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      PersonalInfo info =
          await MyPersonalInfoRepository.getSpecificPersonalInfo(userID: uid);

      _loggedInUserData = info;

      notifyListeners();
    } catch (e) {
      log("Error refreshing picture: $e");
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
      log("Error refreshing picture: $e");
    }
  }
}
