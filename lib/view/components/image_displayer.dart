import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';

/// This automatcally process the Image from the database and display it.
// ignore: must_be_immutable
class MyImageDisplayer extends StatefulWidget {
  /// Size of the profile image to be displayed.
  /// NOTE: If MyImageDisplayer is placed inside a CircleAvatar, this property will be ignored.
  final double profileImageSize;

  /// If userID is not  provided, the current logged in user's ID will be used.
  final String? userID;

  Uint8List? base64ImageString;

  MyImageDisplayer({
    super.key,
    this.profileImageSize = 150,
    this.userID,
    this.base64ImageString,
  });

  @override
  State<MyImageDisplayer> createState() => MyImageDisplayerState();
}

// local loader from image picker, for testing purposes only
// Future<String> _imageLoader() async {
//   await Future.delayed(const Duration(milliseconds: 400));
//   return MyImageProcessor.base64Image;
// }

class MyImageDisplayerState extends State<MyImageDisplayer> {
  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   // future: _imageLoader(),
    //   future: _imageLoaderFromFireBase(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       // != ""  kay naka set sya "" sa imagePicker if walay gi pick
    //       if (snapshot.hasData || snapshot.data != "") {
    //         print(
    //           "Snapshot Dataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: ${snapshot.data!.length}",
    //         );
    if (widget.base64ImageString != null) {
      //         print(
      //           "Snapshot Dataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: ${snapshot.data!.length}",
      //         );
      return ClipOval(
        child: Image.memory(
          // base64Decode(widget.base64ImageString ?? snapshot.data!),
          widget.base64ImageString!,
          width: widget.profileImageSize,
          height: widget.profileImageSize,
          fit: BoxFit.cover,
          // Error Builder: Shows an icon if the string is broken
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person_rounded,
              size: widget.profileImageSize,
              color: Colors.grey,
            );
          },
        ),
      );
      // } else {
      //   return Icon(
      //     Icons.person_rounded,
      //     size: widget.profileImageSize,
      //     color: Colors.grey,
      //   );
      // }
    } else {
      return ClipOval(
        child: SizedBox(
          width: widget.profileImageSize,
          height: widget.profileImageSize,
          child: CircularProgressIndicator(),
        ),
      );
    }
    // },
    // );
  }

  // // loads image from firebase
  // Future<String> _imageLoaderFromFireBase() async {
  //   PersonalInfo personalInfo =
  //       await MyPersonalInfoRepository.getSpecificPersonalInfo(
  //         // if userID is null, get the current logged in user's ID
  //         userID: widget.userID ?? FirebaseAuth.instance.currentUser!.uid,
  //       );
  //   // MyImageProcessor.base64Image = personalInfo.picture;

  //   // print("USERRRRRRRRRRRRRRRRRRRRRRRRRRRRRR: ${personalInfo.name}");
  //   // print(
  //   //   "BASE64 IMAGE STRING LENGTH FROM DATABASE: ${personalInfo.picture.length}",
  //   // );
  //   // print(
  //   //   "Loaded Image from Databaseeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee: ${personalInfo.picture}",
  //   // );

  //   // 1. CLEANUP STEP: Fix the string before touching it
  //   String safeString = personalInfo.picture;

  //   // Remove any hidden newlines (common DB artifact)
  //   safeString = safeString.replaceAll('\n', '').replaceAll('\r', '');

  //   // Restore missing padding '=' until length is divisible by 4
  //   while (safeString.length % 4 != 0) {
  //     safeString += '=';
  //   }

  //   // print(
  //   //   "SAFE STRING LENGTHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH: ${safeString.length}",
  //   // );

  //   return safeString;
  // }
}
