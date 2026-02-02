import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/fly_to.dart';

class HomePatientListDropDown extends StatefulWidget {
  const HomePatientListDropDown({super.key});

  @override
  State<HomePatientListDropDown> createState() =>
      _HomePatientListDropDownState();
}

class _HomePatientListDropDownState extends State<HomePatientListDropDown> {
  //is
  bool isExpanded = false;
  // this will contain the mapbox controller reference
  late MapboxMap _mapControllerRef;
  // (not yet implemented)
  // this will contain the History og patients
  // NOTE: History is just temporary, this must be change to Realtime Location if okay na ang device
  List patientsLocation = [];
  Future<void> getPatientsLocation() async {
    // TODO: add the Realtime Location collection here
    // MyHistoryReposity
  }

  // will return all the patients in the PersonalInfo in the database (PersonalInfo)
  Future<List<PersonalInfo>> getPatientList() async {
    // this is called in here to also fetch Realtime Location callction while getting the patient list
    getPatientsLocation();

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // first store the value of the provider in a variable
    final mapboxProvider = context.watch<MyMapboxRefProvider>();
    // this condition will prevent a few second error
    if (mapboxProvider.getMapboxMapController != null) {
      // then, call the getter to assign it to the mapbox controller reference
      _mapControllerRef = mapboxProvider.getMapboxMapController!;
    }

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
            color: (isExpanded) ? Colors.white60 : Colors.white54,
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          child: Column(
            children: [
              // Dropdown Icon
              (isExpanded)
                  // ? Icon(Icons.keyboard_arrow_up_rounded, size: 24)
                  // : Icon(Icons.keyboard_arrow_down_rounded, size: 24),
                  ? Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: Colors.blue.shade600,
                      // shadows: [Shadow(color: Colors.black12, blurRadius: 4)],
                    )
                  : Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: Colors.grey.shade700,
                    ),
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
  FutureBuilder individualPatientIcon({required PersonalInfo personalInfo}) {
    // only get the first name from the full name
    String firstName = personalInfo.name.split(" ")[0];
    if (firstName.length > 6 && firstName.length <= 10) {
      firstName = firstName.substring(0, 7);
    } else if (firstName.length > 10) {
      firstName = firstName.substring(0, 8);
    }
    // else if (firstName.length > 8) {
    //   firstName = firstName.substring(0, 8);
    // }

    return FutureBuilder(
      future: MyRealtimeLocationReposity.getLocation(
        deviceID: personalInfo.deviceID,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return GestureDetector(
            onTap: () {
              myMapFlyTo(
                mapboxController: _mapControllerRef,
                // position: Position(125.7989268, 7.4233187),
                position: snapshot.data!,
                patientID: personalInfo.userID,
              );
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(2, 7, 2, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CircleAvatar(backgroundColor: Colors.blue,),
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child: CircleAvatar(
                      child: MyImageDisplayer(
                        base64ImageString:
                            MyImageProcessor.decodeStringToUint8List(
                              personalInfo.picture,
                            ),
                      ),
                    ),
                  ),
                  MyTextFormatter.p(
                    text: firstName,
                    fontsize: kDefaultFontSize - 4,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
