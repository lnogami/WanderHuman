import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/history_reposity.dart';
import 'package:wanderhuman_app/helper/medical_services_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/model/medication_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/cards2.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication_history.dart';
import 'package:wanderhuman_app/view/userRolesUI/patient/frequently_go_to.dart';
import 'package:wanderhuman_app/view/userRolesUI/patient/static_mini_map_card.dart';

class MyTabBar extends StatefulWidget {
  final PersonalInfo patient;
  final double width;
  final double height;
  const MyTabBar({
    super.key,
    required this.patient,
    required this.width,
    required this.height,
  });

  @override
  State<MyTabBar> createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar> {
  final ScrollController forAllScrollController = ScrollController();

  // Medical History Related
  final List<CombinedMedicalRecord> isNotYetOkayList = [];
  final List<CombinedMedicalRecord> isNowOkayList = [];
  final Map<String, PersonalInfo> medicalStaffs = {};
  bool isLoadingMedicalRecords = true;

  Future<void> getMedicalStaffs() async {
    try {
      var medics = await MyPersonalInfoRepository.getAllPersonalInfoRecords(
        fieldName: "userType",
        valueToLookFor: "Medical Service",
      );

      for (var medic in medics) {
        medicalStaffs[medic.userID] = medic;
      }
    } catch (e, stackTrace) {
      log("ERROR IN getMedicalStaff: $e \n $stackTrace");
      rethrow;
    }
  }

  Future<List<CombinedMedicalRecord>> getCombinedRecords() async {
    try {
      // 1. IMPORTANT: Clear the lists first!
      // Because FutureBuilder can run multiple times, if you don't clear these,
      // your lists will duplicate their data every time the screen redraws.
      isNotYetOkayList.clear();
      isNowOkayList.clear();

      log("Fetching medical records for Patient ID: ${widget.patient.userID}");

      // 2. Only fetch the Medical Records (We already have the PersonalInfo!)
      List<MedicationModel> medicalRecords =
          await MyMedicalRepository.getAllRecords(
            fieldName: "patientID",
            isEqualTo: widget.patient.userID,
          );

      // 3. Merge the data using the widget.personalInfo you already have
      List<CombinedMedicalRecord> combinedList = [];

      for (var record in medicalRecords) {
        var combinedRecord = CombinedMedicalRecord(
          medicalRecord: record,
          personalInfo: widget.patient, // ✅ Use the data you already have!
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

      setState(() => isLoadingMedicalRecords = false);

      return combinedList.reversed.toList();
    } catch (e, stackTrace) {
      log("ERROR IN getCombinedRecords: $e \n $stackTrace");
      rethrow; // Let the FutureBuilder know it failed
    }
  }

  // In Danger History
  final List<MyHistoryModel> inDangerHistoryList = [];
  bool isInDangerHistoryListLoading = true;
  Future<void> getInDangerHistory() async {
    try {
      var logs = await MyHistoryReposity.getPatientHistory(
        widget.patient.userID,
        field1: "isInSafeZone",
        value1: false,
        field2: "isCurrentlySafe",
        value2: false,
      );
      inDangerHistoryList.addAll(logs);

      setState(() => isInDangerHistoryListLoading = false);
      log(
        "**********************${widget.patient.name} IS IN DANGER HISTORY logs: ${inDangerHistoryList.length}",
      );
    } catch (e, stackTrace) {
      log("ERROR IN getInDangerHistory: $e \nin $stackTrace");
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    getMedicalStaffs();
    getCombinedRecords();
    getInDangerHistory();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              // textScaler: TextScaler.noScaling,
              padding: EdgeInsets.only(left: 20, right: 20),
              labelPadding: EdgeInsets.only(left: 7, right: 7),
              unselectedLabelColor: Colors.grey.shade500,
              labelColor: Colors.blue,
              splashBorderRadius: BorderRadius.circular(15),
              tabs: [
                Tab(
                  // text: "Frequently Go-To",
                  height: widget.height * 0.07,
                  icon: Icon(
                    Icons.directions_walk_outlined,
                    color: Colors.blue,
                  ),
                  child: FittedBox(
                    child: MyTextFormatter.p(text: "Frequently Go-To"),
                  ),
                ),
                Tab(
                  // text: "Medical History",
                  height: widget.height * 0.07,
                  icon: Icon(
                    Icons.medical_information_rounded,
                    color: Colors.blue,
                  ),
                  child: FittedBox(
                    child: MyTextFormatter.p(text: "Medical History"),
                  ),
                ),
                Tab(
                  // text: "In Danger History",
                  height: widget.height * 0.07,
                  icon: Icon(Icons.warning_rounded, color: Colors.blue),
                  child: FittedBox(
                    child: MyTextFormatter.p(text: "In Danger History"),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FrequentlyGoToArea(patientID: widget.patient.userID),
                  SingleChildScrollView(child: patientMedicalInfoTab()),
                  inDangerHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container inDangerHistoryTab() {
    return Container(
      width: widget.width * 0.80,
      height: widget.height,
      // color: Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          MyCustTooltip(
            triggerMode: TooltipTriggerMode.tap,
            message:
                "Outside Safe Zone automatically means in danger, while In Danger means something happened inside the safe zone.",
            heightConstraints: 90,
            duration: 3000,
            child: MyTextFormatter.h3(
              text: "In Danger History",
              fontsize: kDefaultFontSize + 9,
              lineHeight: 1,
            ),
          ),
          SizedBox(height: 20),

          (isInDangerHistoryListLoading)
              ? Center(child: CircularProgressIndicator.adaptive())
              : Expanded(
                  child: (inDangerHistoryList.isEmpty)
                      ? Center(
                          child: MyTextFormatter.p(
                            text: "Oops. No History Found.",
                          ),
                        )
                      : RawScrollbar(
                          controller: forAllScrollController,
                          thumbColor: Colors.blue.shade300,
                          padding: EdgeInsets.only(
                            top: 15,
                            right: 20,
                            bottom: 10,
                          ),
                          thumbVisibility: true,
                          trackVisibility: false,
                          thickness: 5,
                          interactive: false,
                          radius: Radius.circular(7),
                          child: ListView.builder(
                            controller: forAllScrollController,
                            itemCount: inDangerHistoryList.length,
                            padding: EdgeInsets.only(top: 10, bottom: 20),
                            itemBuilder: (context, index) {
                              return MyStaticMiniMapCard(
                                width: widget.width,
                                height: widget.height,
                                history: inDangerHistoryList[index],
                              );
                            },
                          ),
                        ),
                ),
        ],
      ),
    );
  }

  SafeArea patientMedicalInfoTab() {
    return SafeArea(
      // child:
      child: Center(
        child: (isLoadingMedicalRecords)
            ? CircularProgressIndicator.adaptive()
            : SizedBox(
                width: widget.width * 0.8,
                // color: Colors.amber,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyCustTooltip(
                      message:
                          "Medical History is intended for tracking light medical procedures only. Not designed for managing prescription-based medications.",
                      triggerMode: TooltipTriggerMode.tap,
                      heightConstraints: 90,
                      duration: 3000,
                      child: MyTextFormatter.h3(
                        text: "Medical History",
                        fontsize: kDefaultFontSize + 9,
                        lineHeight: 1,
                      ),
                    ),
                    SizedBox(height: 20),

                    if (isNotYetOkayList.isNotEmpty) ...[
                      MyTextFormatter.p(
                        text: "Not Yet Okay",
                        fontsize: kDefaultFontSize - 4,
                      ),
                      ListView.builder(
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: isNotYetOkayList.length,
                        itemBuilder: (context, index) {
                          final combinedItem = isNotYetOkayList[index];
                          final record = combinedItem.medicalRecord;
                          final patient = combinedItem.personalInfo;

                          // Display the data
                          return MyCardInfoDisplayer2(
                            // Handle cases where patient info might be missing
                            // profilePicture: patient?.picture ?? "",
                            name: patient?.name ?? "Unknown Patient",
                            diagnosis: record.diagnosis,
                            treatment: record.treatment,
                            medic: medicalStaffs[record.medic]!,
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
                      MyLine(
                        length: widget.width * 0.80,
                        isVertical: false,
                        isRounded: false,
                        thickness: 5,
                        color: Colors.grey.shade400,
                      ),
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
                          medic: medicalStaffs[record.medic]!,
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
                    SizedBox(height: 20),
                  ],
                ),
              ),
        //     );
        //   }
        // },
      ),
    );
  }
}
