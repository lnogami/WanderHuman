import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

// TODO: To adapt database later
/// This picks the image and encode Encodes it.
/// To pick image use the following method [MyImageProcessor.myImagePicker()]
/// Accessable String data via [MyImageProcessor.base64Image]
class MyImageProcessor {
  /// A String that holds the Base64 representation of the picked image.
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

      // TODO: be back here tomorrow
      // /// upload to database can be done here or outside this method
      // MyFirebaseServices.updateProfilePicture(
      //   userID: userID,
      //   base64Image: base64Image,
      // );

      return base64Image;
    }

    print("No image selected.");
    return "";
  }
}
