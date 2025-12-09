import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

// TODO: To adapt database later
class MyImageProcessor {
  static String base64Image = "";

  /// a Widget
  /// Picks an image from the gallery, compresses it, and returns its Base64 string representation.
  static Future<String> myImagePicker() async {
    final ImagePicker imagePicker = await ImagePicker();

    // Pick the image AND compress it immediately
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Compress to 50% quality
      maxWidth: 800, // Resize to max 800px width
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();

      // This string will be MUCH shorter now
      String base64StringImage = base64Encode(imageBytes);

      print("Compressed Base64 String: $base64StringImage");
      base64Image = base64StringImage;
      return base64Image;
    }

    print("No image selected.");
    return "";
  }
}
