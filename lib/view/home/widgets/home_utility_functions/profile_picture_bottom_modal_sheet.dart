import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/font_family.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';

void showProfilePictureBottomModalSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.white70,
    context: context,
    builder: (context) {
      return Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context) * 0.8,
        decoration: BoxDecoration(
          // color: Colors.purple[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MyDimensionAdapter.getWidth(context) * 0.4,
              height: MyDimensionAdapter.getWidth(context) * 0.4,
              margin: EdgeInsets.only(
                top: MyDimensionAdapter.getHeight(context) * 0.06,
                bottom: MyDimensionAdapter.getHeight(context) * 0.01,
              ),
              child: CircleAvatar(
                child: MyImageDisplayer(
                  base64ImageString: context
                      .watch<HomeAppBarProvider>()
                      .cachedImageString,
                ),
              ),
            ),
            Consumer<HomeAppBarProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.userName,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 23, 84, 134),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            MyCustButton(
              buttonText: "Change Picture",
              buttonTextFontWeight: FontWeight.w600,
              buttonTextColor: Colors.white,
              color: Colors.blue,
              onTap: () async {
                // to pick the image from gallery or camera
                String base64Image = await MyImageProcessor.myImagePicker();
                // CHECK: Did the user actually pick something?
                // If they pressed "Cancel", base64Image might be empty.
                if (base64Image.isNotEmpty) {
                  // 2. Upload the image AND WAIT (await) for it to finish
                  await MyPersonalInfoRepository.uploadProfilePicture(
                    userID: FirebaseAuth.instance.currentUser!.uid,
                    base64Image: base64Image,
                  );

                  // 3. Only NOW do we refresh, because we know the upload is done.
                  if (context.mounted) {
                    context.read<HomeAppBarProvider>().refreshProfilePicture();
                  }
                } else {
                  print("User cancelled image picker");
                }
              },
            ),
          ],
        ),
      );
    },
    // this property removes the default limit of the modal bottom sheet (.50 of the screen height)
    isScrollControlled: true,
  );
}

// currently not in use
Row shortTextLayouter({
  required String constText,
  required String dynamicText,
  // temporary font family yet
  String fontFamily = MyFontFam.iansui,
  double constFontSize = 13.5,
}) {
  return Row(
    children: [
      Text(
        "$constText: ",
        style: TextStyle(
          fontSize: constFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      Text(
        dynamicText,
        style: TextStyle(
          fontSize: 13.7,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.2,
          // temporary font family yet
          fontFamily: fontFamily,
        ),
      ),
    ],
  );
}

// currently not in use
// this is a visual line break
Container lineBreak(BuildContext context, double lineBreakTotalHeight) {
  return Container(
    width: MyDimensionAdapter.getWidth(context) - 40,
    height: 1.0,
    margin: EdgeInsets.only(bottom: lineBreakTotalHeight),
    color: Colors.grey[350],
  );
}

//currently not in use
/* 
  this is a container that will automatically adjust the width of dynamicText's 
  container in accordance to the length of the constText
*/
Container detailsWithLongTextLayouter(
  BuildContext context,
  String constText,
  String dynamicText, {
  double constFontSize = 13.5,
  double containerHeight = 50,
  bool noBorder = false,
}) {
  return Container(
    width: MyDimensionAdapter.getWidth(context) - 40,
    height: containerHeight,
    // color: Colors.greenAccent,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // this is the constant text, meaning this one is predefined and will not change
          "$constText: ",
          style: TextStyle(
            fontSize: constFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          softWrap: true,
        ),
        Container(
          // color: Colors.green,
          /*
            what's happening here is that the width of this dynamicText 
            container will automatically adjust with accordance to the length 
            of constText.
          */
          width:
              MyDimensionAdapter.getWidth(context) -
              (constText.length * 10) -
              ((noBorder) ? 20 : 45),
          height: containerHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              // this is the dynamic text
              dynamicText,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.1,
              ),
              softWrap: true,
            ),
          ),
        ),
      ],
    ),
  );
}
