import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';

class MyImageDisplayer extends StatefulWidget {
  final double profileImageSize;

  const MyImageDisplayer({super.key, this.profileImageSize = 150});

  @override
  State<MyImageDisplayer> createState() => MyImageDisplayerState();
}

Future<String> imageLoader() async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MyImageProcessor.base64Image;
}

class MyImageDisplayerState extends State<MyImageDisplayer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageLoader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // != ""  kay naka set sya "" sa imagePicker if walay gi pick
          if (snapshot.hasData || snapshot.data != "") {
            return ClipOval(
              child: Image.memory(
                base64Decode(snapshot.data!),
                width: widget.profileImageSize,
                height: widget.profileImageSize,
                fit: BoxFit.cover,
                // Error Builder: Shows an icon if the string is broken
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.error,
                    size: widget.profileImageSize,
                    color: Color.fromARGB(186, 189, 96, 86),
                  );
                },
              ),
            );
          } else {
            return Icon(
              Icons.person_rounded,
              size: widget.profileImageSize,
              color: Colors.grey,
            );
          }
        } else {
          return ClipOval(
            child: SizedBox(
              width: widget.profileImageSize,
              height: widget.profileImageSize,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
