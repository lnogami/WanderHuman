import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/medical_services_repository.dart';
import 'package:wanderhuman_app/model/medication_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/cards2.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication_history.dart';
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
  bool isMedicalHistoryAreaVisible = false;

  ScrollController rootScrollController = ScrollController();

  List<CombinedMedicalRecord> isNotYetOkayList = [];
  List<CombinedMedicalRecord> isNowOkayList = [];

  Future<List<CombinedMedicalRecord>> getCombinedRecords() async {
    try {
      // 1. IMPORTANT: Clear the lists first!
      // Because FutureBuilder can run multiple times, if you don't clear these,
      // your lists will duplicate their data every time the screen redraws.
      isNotYetOkayList.clear();
      isNowOkayList.clear();

      log(
        "Fetching medical records for Patient ID: ${widget.personalInfo.userID}",
      );

      // 2. Only fetch the Medical Records (We already have the PersonalInfo!)
      List<MedicationModel> medicalRecords =
          await MyMedicalRepository.getAllRecords(
            fieldName: "patientID",
            isEqualTo: widget.personalInfo.userID,
          );

      // 3. Merge the data using the widget.personalInfo you already have
      List<CombinedMedicalRecord> combinedList = [];

      for (var record in medicalRecords) {
        var combinedRecord = CombinedMedicalRecord(
          medicalRecord: record,
          personalInfo: widget.personalInfo, // ✅ Use the data you already have!
        );

        combinedList.add(combinedRecord);

        // Filter into appropriate lists
        if (record.isNowOkay) {
          isNowOkayList.add(combinedRecord);
        } else {
          isNotYetOkayList.add(combinedRecord);
        }
      }

      // 4. Sort the lists
      isNotYetOkayList.sort(
        (a, b) => b.medicalRecord.fromDate.compareTo(a.medicalRecord.fromDate),
      );
      isNowOkayList.sort(
        (a, b) => b.medicalRecord.fromDate.compareTo(a.medicalRecord.fromDate),
      );

      return combinedList.reversed.toList();
    } catch (e, stackTrace) {
      log("ERROR IN getCombinedRecords: $e \n $stackTrace");
      rethrow; // Let the FutureBuilder know it failed
    }
  }

  @override
  void dispose() {
    super.dispose();
    rootScrollController.dispose();
  }

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
        child: RawScrollbar(
          controller: rootScrollController,
          thumbColor: Colors.blue.shade300,
          trackColor: Colors.grey.shade300,
          interactive: false,
          trackRadius: Radius.circular(50),
          radius: Radius.circular(50),
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 3.5,
          padding: EdgeInsets.only(top: height * 0.33, bottom: 10),
          child: CustomScrollView(
            controller: rootScrollController,
            slivers: [
              appBar(context),
              SliverToBoxAdapter(
                child: FrequentlyGoToArea(
                  patientID: widget.personalInfo.userID,
                ),
              ),

              // The Button
              if (!isMedicalHistoryAreaVisible)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: MyCustButton(
                        buttonText: "Show Medical History?",
                        widthPercentage: 0.67,
                        color: Colors.blue.shade200,
                        borderColor: Colors.white,
                        buttonTextFontWeight: FontWeight.w500,
                        buttonTextColor: Colors.grey.shade800,
                        buttonTextSpacing: 1.2,
                        onTap: () {
                          setState(() => isMedicalHistoryAreaVisible = true);
                        },
                      ),
                    ),
                  ),
                ),

              // Medical History area is not visible by default, the user needs to click the button.
              if (isMedicalHistoryAreaVisible)
                SliverToBoxAdapter(
                  child: FutureBuilder(
                    future: getCombinedRecords(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: MyTextFormatter.p(text: "There is a problem."),
                        );
                      } else if (!snapshot.hasData) {
                        return Center(
                          child: MyTextFormatter.p(text: "No data available."),
                        );
                      } else {
                        return Center(
                          child: Container(
                            width: width * 0.8,
                            // color: Colors.amber,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyTextFormatter.h3(
                                  text: "Medical History",
                                  fontsize: kDefaultFontSize + 9,
                                ),
                                SizedBox(height: 10),

                                if (isNotYetOkayList.isNotEmpty) ...[
                                  MyTextFormatter.p(
                                    text: "Not Yet Okay",
                                    fontsize: kDefaultFontSize - 4,
                                  ),
                                  ListView.builder(
                                    padding: EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: isNotYetOkayList.length,
                                    itemBuilder: (context, index) {
                                      final combinedItem =
                                          isNotYetOkayList[index];
                                      final record = combinedItem.medicalRecord;
                                      final patient = combinedItem.personalInfo;

                                      // Display the data
                                      return MyCardInfoDisplayer2(
                                        // Handle cases where patient info might be missing
                                        // profilePicture: patient?.picture ?? "",
                                        name:
                                            patient?.name ?? "Unknown Patient",
                                        diagnosis: record.diagnosis,
                                        treatment: record.treatment,
                                        medic: record.medic,
                                        fromDate: record.fromDate,
                                        untilDate: record.untilDate,
                                        onTap: () {
                                          // You can pass the combined data or just the patient info
                                          if (patient != null) {
                                            MyNavigator.goTo(
                                              context,
                                              Medication(
                                                bufferedPatientInfo: patient,
                                                recordID: record.recordID,
                                                medicationModel: record,
                                                isAccessedByMedicalStaff: false,
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10),
                                ],

                                MyTextFormatter.p(
                                  text: "Already Okay",
                                  fontsize: kDefaultFontSize - 4,
                                ),
                                ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: isNowOkayList.length,
                                  itemBuilder: (context, index) {
                                    final combinedItem = isNowOkayList[index];
                                    final record = combinedItem.medicalRecord;
                                    final patient = combinedItem.personalInfo;

                                    // Display the data
                                    return MyCardInfoDisplayer2(
                                      // Handle cases where patient info might be missing
                                      // profilePicture: patient?.picture ?? "",
                                      name: patient?.name ?? "Unknown Patient",
                                      // name: "jkajd dkajdkjw dkjawd",
                                      diagnosis: record.diagnosis,
                                      treatment: record.treatment,
                                      medic: record.medic,
                                      fromDate: record.fromDate,
                                      untilDate: record.untilDate,
                                      onTap: () {
                                        // You can pass the combined data or just the patient info
                                        if (patient != null) {
                                          MyNavigator.goTo(
                                            context,
                                            Medication(
                                              bufferedPatientInfo: patient,
                                              recordID: record.recordID,
                                              medicationModel: record,
                                              isAccessedByMedicalStaff: true,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
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
