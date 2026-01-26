import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/utilities/properties/universal_sizes.dart';

/// This is a customed function that returns PointAnnotationOptions.
Future<PointAnnotationOptions> myPointAnnotationOptions({
  Uint8List? imageData,
  required String name,
  double? textSize,
  required Position myPosition,
}) async {
  return PointAnnotationOptions(
    textHaloColor: Colors.blue.toARGB32(),
    textHaloWidth: 1.0,
    textLetterSpacing: 0.08,
    image: await makeCircularImage(imageData!),
    ///// temporary (deletable)
    ///// iconImage: "marker",
    iconSize: 0.35,
    // icon color is still static because I used a png image as marker
    iconColor: Colors.blue.toARGB32(),
    textField: name, // THIS IS A PATIENT NAME
    textSize: MySizes.mapTextFieldSize,
    textColor: Colors.white.toARGB32(),
    textOcclusionOpacity: 1,
    isDraggable: true,
    textAnchor: TextAnchor.BOTTOM,
    textOffset: [0, -1.2],
    geometry: Point(coordinates: myPosition),
  );
}

Future<Uint8List> makeCircularImage(
  Uint8List imageBytes, {
  int size = 200,
  int borderWidth = 20,
}) async {
  // Decode the image
  var image = img.decodeImage(imageBytes);

  if (image == null) return imageBytes;

  // Resize to desired size
  var resized = img.copyResize(image, width: size, height: size);

  // Create a circular image with transparency
  var circularImage = img.Image(width: size, height: size, numChannels: 4);

  double radius = size / 2;
  double centerX = size / 2;
  double centerY = size / 2;

  // Draw the image with a circular mask
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      // Calculate distance from center
      double dx = x - centerX;
      double dy = y - centerY;
      double distance = sqrt(dx * dx + dy * dy);

      if (distance <= radius - borderWidth) {
        // Copy pixel from resized image (inner circle)
        var pixel = resized.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();
        int a = pixel.a.toInt();
        circularImage.setPixelRgba(x, y, r, g, b, a);
      } else if (distance <= radius) {
        // Draw white border
        circularImage.setPixelRgba(x, y, 255, 255, 255, 255);
      } else {
        // Set transparent pixel outside circle
        circularImage.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  return Uint8List.fromList(img.encodePng(circularImage));
}
