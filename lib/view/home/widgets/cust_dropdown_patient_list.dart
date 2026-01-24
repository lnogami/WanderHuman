import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';

class HomePatientListDropDown extends StatefulWidget {
  const HomePatientListDropDown({super.key});

  @override
  State<HomePatientListDropDown> createState() =>
      _HomePatientListDropDownState();
}

class _HomePatientListDropDownState extends State<HomePatientListDropDown> {
  //is
  bool isExpanded = false;

  // will return all the patients in the PersonalInfo in the database (PersonalInfo)
  Future<List<PersonalInfo>> getPatientList() async {
    List<PersonalInfo> patientList =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords(
          fieldName: "userType",
          valueToLookFor: "Patient",
        );
    // sort the patients by name in ascending order
    patientList.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    return patientList;
  }

  @override
  Widget build(BuildContext context) {
    return MyCustTooltip(
      message: "Tap to exapand/collapse patient list",
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        // Main Container
        child: Container(
          width: MyDimensionAdapter.getWidth(context) * 0.12,
          decoration: BoxDecoration(
            color: (isExpanded) ? Colors.white70 : Colors.white54,
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          child: Column(
            children: [
              // Dropdown Icon
              (isExpanded)
                  ? Icon(Icons.keyboard_arrow_up_rounded, size: 24)
                  : Icon(Icons.keyboard_arrow_down_rounded, size: 24),
              // Horizontal Line
              if (isExpanded)
                MyLine(
                  length: MyDimensionAdapter.getWidth(context) * 0.1,
                  isVertical: false,
                  margin: 0,
                ),
              // Expanding/Collapsing Panel
              AnimatedContainer(
                duration: Duration(milliseconds: 400),
                width: MyDimensionAdapter.getWidth(context) * 0.12,
                height: (isExpanded)
                    ? MyDimensionAdapter.getHeight(context) * 0.65
                    : 0,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                alignment: AlignmentGeometry.topCenter,
                child: FutureBuilder(
                  future: getPatientList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (!snapshot.hasData) {
                      return MyTextFormatter.p(
                        text: " No\n data",
                        maxLines: 2,
                        fontsize: kDefaultFontSize - 2,
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return individualPatientIcon(
                            personalInfo: snapshot.data![index],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Patient pictures that acts as a tappable icon.
  GestureDetector individualPatientIcon({required PersonalInfo personalInfo}) {
    // only get the first name from the full name
    String firstName = personalInfo.name.split(" ")[0];
    // if first name is too long, only get the 6 characters
    if (firstName.length > 6) firstName = firstName.substring(0, 10);

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.fromLTRB(2, 5, 2, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircleAvatar(backgroundColor: Colors.blue,),
            AspectRatio(
              aspectRatio: 1 / 1,
              child: CircleAvatar(
                child: MyImageDisplayer(
                  base64ImageString: MyImageProcessor.decodeStringToUint8List(
                    personalInfo.picture,
                  ),
                ),
              ),
            ),
            MyTextFormatter.p(text: firstName, fontsize: kDefaultFontSize - 4),
          ],
        ),
      ),
    );
  }
}
