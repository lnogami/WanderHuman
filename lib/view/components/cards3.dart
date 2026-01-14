import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/home_life_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';

/// This widget if for other formation of Card (used for Home Life age)
class MyCardInfoDisplayer3 extends StatelessWidget {
  final VoidCallback? onTap;
  final PersonalInfo personalInfo;
  // final String profilePicture;
  // // acts as the title of the card
  // final String name;
  // // acts as the subtitle of the card
  // final String age;
  // // acts as the description/additional info of the card
  // final String contactNumber;
  // final String emailAdd;
  // final String batteryPercentage;
  final String batteryPercentage;
  MyCardInfoDisplayer3({
    super.key,
    this.onTap,
    // required this.name,
    // required this.age,
    // required this.contactNumber,
    // this.emailAdd = "No Email",
    // required this.profilePicture,
    required this.personalInfo,
    // required this.batteryPercentage,
    this.batteryPercentage = "99",
  });

  Future<String> numberOfTasksLeft() async {
    List numberOfTasks = await HomeLifeRepository.getIndividualPatientTasks(
      dateID: DateTime.now().toString(),
      participantID: personalInfo.userID,
      isToRetrieveUnFinishTasks: true,
    );

    return numberOfTasks.length.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.85,
        height: MyDimensionAdapter.getHeight(context) * 0.145,
        margin: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(10),
          border: BoxBorder.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(56, 96, 181, 252),
              blurRadius: 4,
              // spreadRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [profilePictureArea(context), informationArea(context)],
        ),
      ),
    );
  }

  ClipRRect profilePictureArea(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.25,
        height: MyDimensionAdapter.getHeight(context),
        margin: EdgeInsets.only(left: 20),
        padding: EdgeInsets.only(top: 12, bottom: 12, left: 5, right: 5),
        // color: Colors.blue,
        child: CircleAvatar(
          // radius: 10,
          backgroundColor: const Color.fromARGB(179, 255, 255, 255),
          child: MyImageDisplayer(
            profileImageSize: 80,
            base64ImageString: MyImageProcessor.decodeStringToUint8List(
              personalInfo.picture,
            ),
          ),
        ),
      ),
    );
  }

  Expanded informationArea(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: Container(
          width: MyDimensionAdapter.getWidth(context) * 0.25,
          height: MyDimensionAdapter.getHeight(context),
          padding: EdgeInsets.only(left: 10, right: 20),
          // color: Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextFormatter.h3(
                text: personalInfo.name,
                // fontsize: kDefaultFontSize + 2,
                fontWeight: FontWeight.w600,
              ),
              Container(
                width: MyDimensionAdapter.getWidth(context),
                height: 1,
                margin: EdgeInsets.only(top: 5, bottom: 5),
                color: MyColorPalette.lightBlue,
              ),
              Row(
                children: [
                  MyTextFormatter.h5(
                    text: "${personalInfo.age} years old",
                    fontsize: kDefaultFontSize - 1,
                  ),
                  Spacer(),
                  FutureBuilder(
                    future: numberOfTasksLeft(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Container(
                          width: MyDimensionAdapter.getWidth(context) * 0.042,
                          height: MyDimensionAdapter.getWidth(context) * 0.042,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                            color: taskColorDeterminer(
                              int.tryParse(snapshot.data!)!,
                            ),
                          ),

                          // CircleAvatar(
                          //   backgroundColor: taskColorDeterminer(int.tryParse("0")!),
                          //   radius: 8,
                          child: FittedBox(
                            child: MyTextFormatter.p(
                              text: snapshot.data!,
                              // fontsize: kDefaultFontSize + 2,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: MyDimensionAdapter.getWidth(context) * 0.042,
                          height: MyDimensionAdapter.getWidth(context) * 0.042,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 1.5,
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(width: 2.5),
                  MyTextFormatter.p(
                    text: "Tasks Left",
                    fontsize: kDefaultFontSize - 4,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    personalInfo.contactNumber,
                    style: TextStyle(
                      fontSize: (kDefaultFontSize - 1.35),
                      // color: Colors.blue.shade400,
                    ),
                  ),
                  Spacer(),
                  // CircleAvatar(backgroundColor: Colors.green, radius: 5),
                  batteryVisual(
                    context: context,
                    percentage: int.tryParse(batteryPercentage)!,
                    // percentage: int.tryParse("100")!,
                  ),
                  SizedBox(width: 2.5),
                  MyTextFormatter.p(
                    text: "$batteryPercentage%",
                    fontsize: kDefaultFontSize - 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color taskColorDeterminer(int tasks) {
  if (tasks > 3) {
    return const Color.fromARGB(255, 205, 77, 75);
  } else if (tasks > 0) {
    return const Color.fromARGB(255, 240, 145, 3);
  } else {
    return Colors.green.shade400;
  }
}

Container batteryVisual({
  required BuildContext context,
  required int percentage,
}) {
  Color color = batteryColorDeterminer(percentage);
  // Color color = Colors.blue;
  // battery container

  return Container(
    width: MyDimensionAdapter.getWidth(context) * 0.12,
    height: MyDimensionAdapter.getHeight(context) * 0.02,
    // color: Colors.purple,
    padding: EdgeInsets.only(left: 5, right: 5),
    // the battery
    child: Container(
      width: MyDimensionAdapter.getWidth(context) * 0.07,
      height: MyDimensionAdapter.getHeight(context) * 0.02,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),

      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // battery positive side
          Positioned(
            left: -3,
            child: Container(
              width: MyDimensionAdapter.getWidth(context) * 0.015,
              height: MyDimensionAdapter.getHeight(context) * 0.01,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2),
                  bottomLeft: Radius.circular(2),
                ),

                color: color,
              ),
            ),
          ),
          // battery body
          Positioned(
            left: 2,
            child: Container(
              width: MyDimensionAdapter.getWidth(context) * 0.08,
              height: MyDimensionAdapter.getHeight(context) * 0.016,
              padding: EdgeInsets.only(left: 1.5, right: 1.5),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // battery bar below 25%
                  Expanded(
                    child: Container(
                      // width: MyDimensionAdapter.getWidth(context) * 0.025,
                      height: MyDimensionAdapter.getHeight(context) * 0.013,
                      color: color,
                    ),
                  ),

                  SizedBox(width: 1.5),
                  Expanded(
                    child: Container(
                      // width: MyDimensionAdapter.getWidth(context) * 0.025,
                      height: MyDimensionAdapter.getHeight(context) * 0.013,
                      color: (percentage >= 25)
                          ? color
                          : MyColorPalette.formColor,
                    ),
                  ),

                  SizedBox(width: 1.5),
                  Expanded(
                    child: Container(
                      // width: MyDimensionAdapter.getWidth(context) * 0.025,
                      height: MyDimensionAdapter.getHeight(context) * 0.013,
                      color: (percentage >= 50)
                          ? color
                          : MyColorPalette.formColor,
                    ),
                  ),

                  SizedBox(width: 1.5),
                  Expanded(
                    child: Container(
                      // width: MyDimensionAdapter.getWidth(context) * 0.025,
                      height: MyDimensionAdapter.getHeight(context) * 0.013,
                      color: (percentage >= 75)
                          ? color
                          : MyColorPalette.formColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Color batteryColorDeterminer(int percentage) {
  if (percentage >= 75) {
    return Colors.green.shade400;
  } else if (percentage >= 50) {
    return Colors.lightGreen.shade400;
  } else if (percentage >= 25) {
    return Colors.orange.shade500;
  } else {
    return Colors.redAccent.shade200;
  }
}
