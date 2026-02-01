// import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
// import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/bottom_modal_sheet_for_patient.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/point_annotation_options.dart';

/// Listen to realtime database in real-time
void listenToPatients({
  required Map<String, Map<String, dynamic>> annotationData,
  required Map<String, mp.PointAnnotation> userAnnotations,
  mp.PointAnnotationManager? pointAnnotationManager,
  required BuildContext context,
}) async {
  //// Unfinished work, to be back later on
  // MyRealtimeLocationReposity.getRealtimePatientLocationStream(
  //   deviceID: "P16IcIuyKHAkc2vlqIBD",
  // ).listen((data) {
  //   try {} catch (e, stackTrace) {
  //     log("AN ERROR OCCURED WHILE LISTENING TO PATIENTS: $e. AT $stackTrace");
  //   }
  // });

  // History is just a placeholder,    "RealTime" is the collection here.
  FirebaseFirestore.instance.collection("History").snapshots().listen((
    snapshot,
  ) async {
    try {
      int n = 0; // (deletable) for debugging purposes only

      // iterate every document in History collection
      for (var doc in snapshot.docs) {
        var data = doc.data();
        // I just converted the data into an object so that it is readable for me
        HistoryModel historyModel = HistoryModel.fromFirestore(data);
        n++;

        // // Extract coordinates   // naka list man gud ni maong ingani [""][0]   naka List ni sya pag save sa firestore kay Position object man gud ang gisend, naconvert sya into array pag abot sa firestore
        // double lng = data["currentLocation"][0] ?? "NULL lng";
        // double lat = data["currentLocation"][1] ?? "NULL lat";
        // (to be used when the current data in the database is replaced with updated ones)
        double lng = double.parse(historyModel.currentLocationLng);
        double lat = double.parse(historyModel.currentLocationLat);

        // to get personal info based on patient's ID
        PersonalInfo personalInfo =
            await MyPersonalInfoRepository.getSpecificPersonalInfo(
              userID: historyModel.patientID,
            );
        String name = personalInfo.name;

        // Store the data associated with this document
        annotationData[doc.id] = {
          'name': name,
          'patientID': historyModel.patientID,
          'number': n, //for debugging purposes only, might delete later on
          'lng': lng,
          'lat': lat,
          'currentlyIn': historyModel.currentlyIn,
          'isInSafeZone': historyModel.isInSafeZone,
          'timeStamp': historyModel.timeStamp,
          'deviceBatteryPercentage': historyModel.deviceBatteryPercentage
              .toString(),
          //
          'age': personalInfo.age,
          'sex': personalInfo.sex,
          'contactInfo': personalInfo.contactNumber,
          'address': personalInfo.address,
          'notableBehavior': personalInfo.notableBehavior,
        };

        // // load image as the marker (temporary)
        // final Uint8List imageData = await imageToIconLoader(
        //   // "assets/icons/isagi.jpg",
        //   "assets/icons/pin.png",
        // );
        // load image as the marker (temporary)
        final Uint8List patientIcon = MyImageProcessor.decodeStringToUint8List(
          personalInfo.picture,
        );

        // If the user already has an annotation, update its position
        if (userAnnotations.containsKey(doc.id)) {
          // remove old annotation
          pointAnnotationManager?.delete(userAnnotations[doc.id]!);
          // create new annotation at the updated location
          var newAnnotation = await pointAnnotationManager?.create(
            await myPointAnnotationOptions(
              name: name,
              myPosition: mp.Position(lng, lat),
              imageData: patientIcon,
            ),
          );
          // then add a new annotation to the map
          userAnnotations[doc.id] = newAnnotation!;
        } else {
          // create new annation
          var newAnnotation = await pointAnnotationManager?.create(
            await myPointAnnotationOptions(
              name: name,
              myPosition: mp.Position(lng, lat),
              imageData: patientIcon,
            ),
          );
          // then add the new annotation to the map
          userAnnotations[doc.id] = newAnnotation!;
        }

        // set up tap events ONCE, outside the loop
        pointAnnotationManager?.tapEvents(
          onTap: (mp.PointAnnotation tappedAnnotation) {
            // find which document this annotation belongs to
            String? docId = userAnnotations.entries
                .firstWhere(
                  (entry) => entry.value == tappedAnnotation,
                  orElse: () => MapEntry('', tappedAnnotation),
                )
                .key;

            if (docId.isNotEmpty && annotationData.containsKey(docId)) {
              var data = annotationData[docId]!;
              showMyBottomNavigationSheet(
                context: context,
                name: "${data['name']} : ${data['number']}",
                sex: data['sex'] ?? "NO DATA ACQUIRED",
                age: data['age'] ?? "NO DATA ACQUIRED",
                contactInfo: data['contactInfo'] ?? "NO DATA ACQUIRED",
                address: data['address'] ?? "NO DATA ACQUIRED",
                notableBehavior: data['notableBehavior'] ?? "NO DATA ACQUIRED",
              );
            }
          },
        );
      }
    } catch (e, stackTrace) {
      // showMyAnimatedSnackBar(context: context, dataToDisplay: e.toString());
      print("ERROR ON LISTENTOPATIENTS METHOD: ${e.toString()}");
      print("ERROR ONNNNNNNNNNNNNNNNNNNNNNNN: $stackTrace");
    }
  });
}
