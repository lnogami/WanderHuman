import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/userRolesUI/social_services/mini_widgets/frequently_go_to.dart';

/// This widget is visible in the HomePage (in the Map page)
class PatientDetailsPage extends StatefulWidget {
  final PersonalInfo personalInfo;
  final int batteryPercentage;
  const PatientDetailsPage({
    super.key,
    required this.personalInfo,
    required this.batteryPercentage,
  });

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  double headerBarExpandedHeight = 200;
  late double width;
  late double height;

  @override
  Widget build(BuildContext context) {
    width = MyDimensionAdapter.getWidth(context);
    height = MyDimensionAdapter.getHeight(context);

    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 7, 191, 53),
      body: Container(
        width: width,
        height: height,
        // color: Colors.purple.shade200,
        child: CustomScrollView(
          slivers: [
            appBar(context),
            SliverToBoxAdapter(
              child: FrequentlyGoToArea(patientID: widget.personalInfo.userID),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(childCount: 15, (
                builder,
                index,
              ) {
                return Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  padding: EdgeInsets.only(bottom: 20),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar appBar(BuildContext context) {
    return SliverAppBar(
      primary: true,
      actionsPadding: EdgeInsets.all(0),
      forceMaterialTransparency: true,
      // backgroundColor: const Color.fromARGB(255, 239, 249, 255),
      title: Container(
        width: width,
        height: kToolbarHeight,
        decoration: BoxDecoration(
          // color: Colors.amber.withAlpha(100),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(100),
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // colors: [
            //   const Color.fromARGB(255, 209, 234, 255),
            //   const Color.fromARGB(255, 242, 248, 250),
            //   Colors.white70,
            //   Colors.white12,
            //   // Colors.white10,
            //   Colors.transparent,
            // ],
            colors: [
              const Color.fromARGB(50, 209, 234, 255),
              const Color.fromARGB(200, 242, 248, 250),
              const Color.fromARGB(255, 242, 248, 250),
              Colors.white70,
              Colors.white54,
              Colors.white10,
              // Colors.white10,
              Colors.transparent,
            ],
          ),
        ),
        child: appBarTitleArea(context),
      ),
      centerTitle: true,
      forceElevated: true,
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      // backgroundColor: Colors.green,
      collapsedHeight: kToolbarHeight,
      expandedHeight: headerBarExpandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        // background: Image.asset("assets/icons/isagi.jpg"),
        background: Container(
          decoration: BoxDecoration(
            // color: Colors.blue.withAlpha(200),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 209, 234, 255),
                const Color.fromARGB(255, 246, 248, 249),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Container(
            // color: Colors.blue,
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: -5,
                    child: Container(
                      width: width * 0.45,
                      height: headerBarExpandedHeight,
                      // color: Colors.green.withAlpha(100),
                      // child: Image.asset(
                      //   "assets/icons/isagi.jpg",
                      //   // "assets/icons/longwidth_placeholder.jpg",
                      //   fit: BoxFit.fitHeight,
                      // ),
                      child: MyImageDisplayer(
                        isOval: false,
                        base64ImageString:
                            MyImageProcessor.decodeStringToUint8List(
                              widget.personalInfo.picture,
                            ),
                      ),
                    ),
                  ),

                  // image's left gradient
                  imageLeftGradient(context),

                  // image's top gradient
                  imageTopGradient(context),

                  // image's bottom gradient
                  imageBottomGradient(context),

                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: width * 0.65,
                      height: height * 0.26,
                      padding: EdgeInsets.only(
                        // top: MyDimensionAdapter.getHeight(context) * 0.2,
                        left: 20,
                        top: 70,
                      ),
                      // color: Colors.green.withAlpha(100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          // Device ID
                          miniSidePanelInfo(
                            label: "Device ID",
                            value: widget.personalInfo.deviceID,
                          ),
                          // Battery Percentage
                          miniSidePanelInfo(
                            label: "Battery Percentage",
                            value: "${widget.batteryPercentage}%",
                            fontsize: kDefaultFontSize + 7,
                          ),
                          // // Notable Behavior
                          // miniSidePanelInfo(
                          //   label: "Notable Behavior",
                          //   value: "",
                          // ),
                          // Container(
                          //   width: width * 0.5,
                          //   margin: EdgeInsets.only(left: 4.5),
                          //   child: MyTextFormatter.p(
                          //     // text: widget.personalInfo.notableBehavior,
                          //     text:
                          //         "kad akjbda a wdkjbawd dkjabwq dqkwbdwd grojdpod dlfknsnfse fsnfsklnf sfkjes",
                          //     fontWeight: FontWeight.w500,
                          //     maxLines: 2,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // child: Row(
              //   children: [
              //     Flexible(
              //       flex: 2,
              //       child: Column(
              //         children: [
              //           Expanded(child: Container(color: Colors.green)),
              //         ],
              //       ),
              //     ),
              //     Flexible(
              //       flex: 1,
              //       child: Column(
              //         children: [
              //           // displays name and avatar
              //           expandedPatientDemographicHeader(context),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ),
          ),
          // ),
        ),
      ),
    );
  }

  Column miniSidePanelInfo({
    required String label,
    required String value,
    double fontsize = kDefaultFontSize,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextFormatter.p(
          text: "$label: ",
          fontsize: kDefaultFontSize - 2,
          color: Colors.grey.shade700,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 7),
          child: MyTextFormatter.p(
            text: value,
            fontWeight: FontWeight.w500,
            fontsize: fontsize,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Row appBarTitleArea(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blue),
        ),
        SizedBox(width: 15),
        SizedBox(
          // color: Colors.grey,
          width: width * 0.63,
          child: Text(
            widget.personalInfo.name, // the name of the patient
            // "Hellooooooooooooooooooooooooooo",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Positioned imageBottomGradient(BuildContext context) {
    return Positioned(
      // this is proportionally based on the container widht of the image
      bottom: 0,
      right: 0,
      child: Container(
        width: width * 0.44,
        height: 35,
        decoration: BoxDecoration(
          // color: Colors.deepOrange.withAlpha(150),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.0, 0.15, 0.3, 0.6, 1.0],
            colors: [
              Colors.white,
              Colors.white70,
              Colors.white38,
              Colors.white10,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Positioned imageTopGradient(BuildContext context) {
    return Positioned(
      // this is proportionally based on the container widht of the image
      top: 0,
      right: 0,
      child: Container(
        width: width * 0.44,
        height: 35,
        decoration: BoxDecoration(
          // color: Colors.deepOrange.withAlpha(150),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.1, 0.3, 0.6, 1.0],
            colors: [
              Colors.white,
              Colors.white70,
              Colors.white38,
              Colors.white10,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Positioned imageLeftGradient(BuildContext context) {
    return Positioned(
      // this is proportionally based on the container widht of the image
      right: width * 0.34,
      child: Container(
        width: width * 0.10,
        height: headerBarExpandedHeight,
        decoration: BoxDecoration(
          // color: Colors.deepOrange.withAlpha(150),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            // stops: [0.0, 0.6, 1.0],
            colors: [
              const Color.fromARGB(255, 246, 248, 249),
              const Color.fromARGB(255, 247, 248, 249),
              // Colors.white,
              //   Colors.white,
              // Colors.white70,
              Colors.white54,
              Colors.white24,
              Colors.white10,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
