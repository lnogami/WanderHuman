import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/utilities/universal_sizes.dart';

/// This is a customed function that returns PointAnnotationOptions.
PointAnnotationOptions myPointAnnotationOptions({
  Uint8List? imageData,
  required String name,
  double? textSize,
  required Position myPosition,
}) {
  return PointAnnotationOptions(
    textHaloColor: Colors.blue.toARGB32(),
    textHaloWidth: 1.0,
    textLetterSpacing: 0.08,
    image: imageData,
    ///// temporary (deletable)
    ///// iconImage: "marker",
    iconSize: 0.15,
    // icon color is still static because I used a png image as marker
    iconColor: Colors.blue.toARGB32(),
    textField: name, // THIS IS A PATIENT NAME
    textSize: MySizes().mapTextFieldSize,
    textColor: Colors.white.toARGB32(),
    textOcclusionOpacity: 1,
    isDraggable: true,
    textAnchor: TextAnchor.BOTTOM,
    textOffset: [0, -1.2],
    geometry: Point(
      coordinates: myPosition,
      // coordinates: Position(
      //   // THIS IS THE PATIENTS CURRENT COORDINATES
      //   // temporary coordinates
      //   myPosition!.longitude,
      //   myPosition!.latitude,
      // ),
    ),
  );
}
