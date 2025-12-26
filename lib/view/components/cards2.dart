import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';

/// This widget if for other formation of Card (used for Medical role)
class MyCardInfoDisplayer2 extends StatefulWidget {
  final VoidCallback? onTap;
  final String? profilePicture;
  // acts as the title of the card
  final String name;
  // acts as the subtitle of the card
  final String diagnosis;
  // acts as the description/additional info of the card
  final String treatment;
  final String medic;
  final String fromDate;
  final String untilDate;

  const MyCardInfoDisplayer2({
    super.key,
    this.onTap,
    required this.name,
    required this.diagnosis,
    required this.treatment,
    this.medic = "This should supposed to be the medic",
    this.profilePicture,
    required this.fromDate,
    required this.untilDate,
    // this.personsList,
  });

  @override
  State<MyCardInfoDisplayer2> createState() => _MyCardInfoDisplayer2();
}

class _MyCardInfoDisplayer2 extends State<MyCardInfoDisplayer2> {
  /// To store the information of the medic, in order to get their name for instance.
  PersonalInfo? medicInfo;

  @override
  void initState() {
    super.initState();
    getMedicInfo();
  }

  Future<void> getMedicInfo() async {
    final personalInfo = await MyPersonalInfoRepository.getSpecificPersonalInfo(
      userID: widget.medic,
    );
    setState(() {
      medicInfo = personalInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () {},
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.85,
        height: MyDimensionAdapter.getHeight(context) * 0.2,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePictureArea(context),
            SizedBox(width: 3),
            informationArea(context),
          ],
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
        width: MyDimensionAdapter.getWidth(context) * 0.15,
        height: MyDimensionAdapter.getHeight(context) * 0.2,
        // alignment: Alignment.topCenter,
        margin: EdgeInsets.only(left: 10, top: 5),
        padding: EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 0),
        // color: Colors.blue,
        child: CircleAvatar(
          // radius: 10,
          backgroundColor: const Color.fromARGB(179, 255, 255, 255),
          child: MyImageDisplayer(
            isOval: false,
            profileImageSize: 80,
            base64ImageString: MyImageProcessor.decodeStringToUint8List(
              widget.profilePicture!,
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
          height: MyDimensionAdapter.getHeight(context) * 0.2,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(left: 10, right: 20),
          // color: Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MyDimensionAdapter.getWidth(context) * 0.385,
                    // color: Colors.amber,
                    child: MyTextFormatter.h3(
                      text: widget.name,
                      fontsize: kDefaultFontSize + 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  FittedBox(child: dateArea()),
                ],
              ),
              Container(
                width: MyDimensionAdapter.getWidth(context),
                height: 1,
                margin: EdgeInsets.only(bottom: 3),
                color: MyColorPalette.lightBlue,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    color: const Color.fromARGB(210, 115, 182, 237),
                    size: 22,
                  ),
                  SizedBox(width: 2),
                  Expanded(
                    child: MyTextFormatter.p(
                      // widget.diagnosis
                      text:
                          "jBDkjbwd ajkdbawkd a dawhdbjwhd ejkwbedehj ewdbwe dwd weded ededede de d w dew ",
                      maxLines: 2,
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    color: const Color.fromARGB(210, 115, 182, 237),
                    size: 22,
                  ),
                  // Icon(Icons.co_present_sharp),
                  SizedBox(width: 5),
                  Expanded(
                    child: MyTextFormatter.p(
                      text: widget.treatment,
                      maxLines: 2,
                    ),
                    // child: dateArea(),
                  ),
                ],
              ),

              Container(
                width: MyDimensionAdapter.getWidth(context),
                height: 1,
                margin: EdgeInsets.only(top: 3, bottom: 2),
                color: MyColorPalette.lightBlue,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.co_present_sharp,
                    color: const Color.fromARGB(210, 115, 182, 237),
                    size: 19,
                  ),
                  // Icon(Icons.co_present_sharp),
                  SizedBox(width: 5),
                  Expanded(
                    child: MyTextFormatter.p(
                      text: medicInfo?.name ?? "No Medic Found",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text dateArea() {
    // remove the ", 2025" part in the String
    List<String> from = (widget.fromDate != "")
        ? widget.fromDate.split(" ")
        : ["0", "10", "2"];

    // // if the day of the date is a single number (like 1-9), add a '0' as a padding to make it 01-09.
    // // if (from[1].length == 2) {
    // //   print("LEFT PADDINGGGGGGGGG");
    setState(() {
      //          this code here is just the same logic as the above if statement.
      //          the 3 in this (3, "0") means the width of the String value which is the from[1]'s value
      //          if the length og from[1] is less than the width, pad the "0".
      //          therefore, if the value of from[1] is a 1-9 number String, it will become "01" - "09"
      from[1] = from[1].padLeft(3, "0");
    });
    // // }

    // remove the ", 2025" part in the String
    List<String> until = (widget.untilDate != "")
        ? widget.untilDate.split(" ")
        : ["0", "1", "2"];
    return MyTextFormatter.p(
      // whats happening here?
      // from[0] means we get the month (like Dec, Jan, Feb, etc.)
      // from[1] means we get the 2nd element which is a day with a comma (like "20,", "21,", etc")
      //        .substring(0,1) means we subtract a certain part of the string,
      //        0 means the index of the included element,
      //        while the 1 means the index of element to be subtracted.
      //        In this case, since we are expecting a string value like "12,", "23,", etc.
      //        we only need to subtract the comma so a (0,2) argument means remove from 0 to 1 element.
      //        In a "23," String value, "2" is the index 0, "3" is the index 1, and "," is the index 2.
      //        So in short, these are the arguments (implicit, explicit), implicit means include, explicit means exclude.
      // until[1] means we get the as from[1]'s value
      // until[2] means we get the year
      text: "${from[0]} ${from[1].substring(0, 2)}-${until[1]} ${until[2]}",
      // text: "Hello World".substring(1, 5),
      fontsize: kDefaultFontSize - 4,
    );
  }
}
