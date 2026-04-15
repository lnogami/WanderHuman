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
  required int batteryPercentage,
  required bool enableBatteryPecentage,
  bool isAPatient =
      true, // true by default because this function is initialy for patients
  required bool isCurrentlySafe,
  double iconRotate = 0.0,
  bool isIconRotateEnabled = false,
}) async {
  //
  String formattedName = nameFormatter(
    name: name,
    batteryPercentage: batteryPercentage,
    isPatient: isAPatient,
    enableBatteryPercentage: enableBatteryPecentage,
  );

  return PointAnnotationOptions(
    // textHaloColor: Colors.blue.toARGB32(),
    textHaloColor: (isAPatient)
        ? (isCurrentlySafe)
              ? Colors.blue.toARGB32()
              : Colors.red.toARGB32()
        : Colors.grey.shade800.toARGB32(),
    textHaloWidth: (isAPatient) ? 1.0 : 1.5,
    textLetterSpacing: 0.08,
    image: await makeCircularImage(
      imageData!,
      isIconRotateEnabled: isIconRotateEnabled,
    ),
    iconSize: 0.35,
    // icon color is still static because I used a png image as marker
    iconColor: Colors.blue.toARGB32(), // if image is not applicable
    textField: formattedName,
    textSize: MySizes.mapTextFieldSize,
    textColor: Colors.white.toARGB32(),
    textOcclusionOpacity: 1,
    isDraggable: false,
    textAnchor: TextAnchor.BOTTOM,
    textOffset: [0, -1.2],
    geometry: Point(coordinates: myPosition),
    iconRotate: (isIconRotateEnabled) ? iconRotate : 0.0,
  );
}

Future<Uint8List> makeCircularImage(
  Uint8List imageBytes, {
  int size = 200,
  int borderWidth = 20,
  bool isIconRotateEnabled = false,
}) async {
  // Decode the image
  var image = img.decodeImage(imageBytes);

  if (image == null) return imageBytes;

  // --- NEW: CENTER CROP LOGIC ---
  // 1. Find the shortest side to make a perfect square
  int shortestSide = min(image.width, image.height);

  // 2. Calculate the X and Y offsets to center the crop
  int offsetX = (image.width - shortestSide) ~/ 2;
  int offsetY = (image.height - shortestSide) ~/ 2;

  // 3. Crop the original image into a 1:1 square
  var squareImage = img.copyCrop(
    image,
    x: offsetX,
    y: offsetY,
    width: shortestSide,
    height: shortestSide,
  );
  // ------------------------------

  // Resize to desired size (now safe from warping because it's already a square!)
  var resized = img.copyResize(squareImage, width: size, height: size);

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

  // --- NEW: DRAW A DIRECTIONAL POINTER (ARROW) ---
  // We draw a triangle pointing UP (0 degrees).
  // When Mapbox rotates the image, this arrow will point to the heading.
  if (isIconRotateEnabled) {
    int arrowHeight = borderWidth + 15; // How far down the arrow goes
    int arrowHalfWidth = 15; // How wide the base of the arrow is

    for (int y = 0; y < arrowHeight; y++) {
      for (
        int x = (centerX - arrowHalfWidth).toInt();
        x <= (centerX + arrowHalfWidth).toInt();
        x++
      ) {
        // Simple triangle math: the width of the arrow gets wider as we move down the Y axis
        double currentHalfWidth = (y / arrowHeight) * arrowHalfWidth;

        if ((x - centerX).abs() <= currentHalfWidth) {
          // Draw a blue arrow (Matches Colors.blue)
          // You can change the RGB values here if your app theme uses a different color
          circularImage.setPixelRgba(x, y, 33, 149, 243, 255);
        }
      }
    }
  }

  return Uint8List.fromList(img.encodePng(circularImage));
}

String nameFormatter({
  required String name,
  required int batteryPercentage,
  required bool isPatient,
  required bool enableBatteryPercentage,
}) {
  // Patient
  if (isPatient) {
    if (enableBatteryPercentage) {
      return "$name \n${batteryPercentage.toString()}%";
    } else {
      return name;
    }
  }
  // Staff
  else {
    // Me
    if (name == "Me") {
      return name;
    }
    // Others
    else {
      if (enableBatteryPercentage) {
        return "${name.split(" ").first} (staff)\n${batteryPercentage.toString()}%";
      } else {
        return "${name.split(" ").first} (staff)";
      }
    }
  }

  // (isAPatient)
  //       ? "$name \n${batteryPercentage.toString()}%" // THIS IS A PATIENT NAME
  //       : (name == "Me") // FOR STAFF NAME
  //       ? name // FOR LOGGED IN USER NAME
  //       : "${name.split(" ").first} (staff)\n${batteryPercentage.toString()}%", // FOR STAFF NAME
}

// Future<Uint8List> makeCircularImage(
//   Uint8List imageBytes, {
//   int size = 200,
//   int borderWidth = 20,
// }) async {
//   // Decode the image
//   var image = img.decodeImage(imageBytes);

//   if (image == null) return imageBytes;

//   // Resize to desired size
//   var resized = img.copyResize(image, width: size, height: size);

//   // Create a circular image with transparency
//   var circularImage = img.Image(width: size, height: size, numChannels: 4);

//   double radius = size / 2;
//   double centerX = size / 2;
//   double centerY = size / 2;

//   // Draw the image with a circular mask
//   for (int y = 0; y < size; y++) {
//     for (int x = 0; x < size; x++) {
//       // Calculate distance from center
//       double dx = x - centerX;
//       double dy = y - centerY;
//       double distance = sqrt(dx * dx + dy * dy);

//       if (distance <= radius - borderWidth) {
//         // Copy pixel from resized image (inner circle)
//         var pixel = resized.getPixel(x, y);
//         int r = pixel.r.toInt();
//         int g = pixel.g.toInt();
//         int b = pixel.b.toInt();
//         int a = pixel.a.toInt();
//         circularImage.setPixelRgba(x, y, r, g, b, a);
//       } else if (distance <= radius) {
//         // Draw white border
//         circularImage.setPixelRgba(x, y, 255, 255, 255, 255);
//       } else {
//         // Set transparent pixel outside circle
//         circularImage.setPixelRgba(x, y, 0, 0, 0, 0);
//       }
//     }
//   }

//   return Uint8List.fromList(img.encodePng(circularImage));
// }
