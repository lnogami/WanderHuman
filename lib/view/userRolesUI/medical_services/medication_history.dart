// import 'package:flutter/material.dart';
// import 'package:wanderhuman_app/helper/medical_services_repository.dart';
// import 'package:wanderhuman_app/helper/personal_info_repository.dart';
// import 'package:wanderhuman_app/model/medication_model.dart';
// import 'package:wanderhuman_app/model/personal_info.dart';
// import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
// import 'package:wanderhuman_app/view/components/appbar.dart';
// import 'package:wanderhuman_app/view/components/cards2.dart';
// import 'package:wanderhuman_app/view/components/dropdown_button.dart';
// import 'package:wanderhuman_app/view/components/page_navigator.dart';
// import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication.dart';

// class CombinedMedicalRecord {
//   final MedicationModel medicalRecord;
//   final PersonalInfo? personalInfo; // Nullable in case user is deleted

//   CombinedMedicalRecord({required this.medicalRecord, this.personalInfo});
// }

// class MedicalHistory extends StatefulWidget {
//   const MedicalHistory({super.key});

//   @override
//   State<MedicalHistory> createState() => _MedicalHistoryState();
// }

// class _MedicalHistoryState extends State<MedicalHistory> {
//   final List<String> statusChoices = const ["Not Yet Okay", "Is Now Okay"];
//   String selectedStatusFilter = "";

//   List<CombinedMedicalRecord> notYetOkayList = [];
//   List<CombinedMedicalRecord> isNowOkayList = [];

//   Future<List<CombinedMedicalRecord>> getCombinedRecords() async {
//     // 1. Fetch BOTH collections in parallel
//     final results = await Future.wait([
//       MyMedicalRepository.getAllRecords(),
//       MyPersonalInfoRepository.getAllPersonalInfoRecords(),
//     ]);

//     final medicalRecords = results[0] as List<MedicationModel>;
//     final allPersonalInfo = results[1] as List<PersonalInfo>;

//     // 2. Convert PersonalInfo List to a Map for O(1) lookup
//     final Map<String, PersonalInfo> userMap = {
//       for (var user in allPersonalInfo) user.userID: user,
//     };

//     // 3. Clear lists and populate them based on isNowOkay
//     notYetOkayList.clear();
//     isNowOkayList.clear();

//     for (var record in medicalRecords) {
//       final patientInfo = userMap[record.patientID];
//       final combined = CombinedMedicalRecord(
//         medicalRecord: record,
//         personalInfo: patientInfo,
//       );

//       // Filter into appropriate list based on isNowOkay
//       if (record.isNowOkay) {
//         isNowOkayList.add(combined);
//       } else {
//         notYetOkayList.add(combined);
//       }
//     }

//     // 4. Sort both lists by time range (fromDate, then untilDate)
//     _sortByTimeRange(notYetOkayList);
//     _sortByTimeRange(isNowOkayList);

//     // Return combined list for FutureBuilder
//     return [...notYetOkayList, ...isNowOkayList];
//   }

//   // Helper method to sort by time range efficiently
//   void _sortByTimeRange(List<CombinedMedicalRecord> list) {
//     list.sort((a, b) {
//       // Primary sort: fromDate (earliest first)
//       int fromDateComparison = a.medicalRecord.fromDate.compareTo(
//         b.medicalRecord.fromDate,
//       );
//       if (fromDateComparison != 0) {
//         return fromDateComparison;
//       }
//       // Secondary sort: untilDate if fromDate is the same (longest duration first)
//       return b.medicalRecord.untilDate.compareTo(a.medicalRecord.untilDate);
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     selectedStatusFilter = statusChoices[0];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 227, 237, 250),
//       body: Container(
//         width: MyDimensionAdapter.getWidth(context),
//         height: MyDimensionAdapter.getHeight(context) * 1.2,
//         color: Colors.amber.shade100,
//         child: FutureBuilder(
//           future: getCombinedRecords(), // Call the new merging function
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text("No records found"));
//               }
//               return Column(
//                 children: [
//                   SafeArea(
//                     child: MyCustAppBar(
//                       title: "Medical History",
//                       backButton: () => Navigator.pop(context),
//                       // ... rest of your app bar code
//                     ),
//                   ),
//                   SizedBox(height: 10),

//                   MyDropdownMenuButton(
//                     items: statusChoices,
//                     initialValue: selectedStatusFilter,
//                     isLeadingIconVisible: false,
//                     onChanged: (value) {
//                       setState(() {
//                         selectedStatusFilter = value!;
//                       });
//                     },
//                   ),

//                   (selectedStatusFilter == statusChoices[0])
//                       ? Expanded(
//                           child: Container(
//                             width: MyDimensionAdapter.getWidth(context),
//                             // height: MyDimensionAdapter.getHeight(context) * 0.8,
//                             color: Colors.green,
//                             padding: const EdgeInsets.only(
//                               // top: 0,
//                               // bottom: 56,
//                               left: 20,
//                               right: 20,
//                             ),
//                             child: RawScrollbar(
//                               thumbColor: Colors.blue.shade300,
//                               padding: EdgeInsets.only(
//                                 right: -20,
//                                 // top: (kDefaultFontSize * 2) + 10,
//                               ),
//                               thumbVisibility: true,
//                               trackVisibility: true,
//                               interactive:
//                                   false, // prevents accidental touch scrolling
//                               thickness: 4,
//                               radius: Radius.circular(30),
//                               child: ListView.builder(
//                                 padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                                 itemCount: snapshot.data!.length,
//                                 itemBuilder: (context, index) {
//                                   final combinedItem = snapshot.data![index];
//                                   final record = combinedItem.medicalRecord;
//                                   final patient = combinedItem.personalInfo;

//                                   // Display the data
//                                   return MyCardInfoDisplayer2(
//                                     // Handle cases where patient info might be missing
//                                     profilePicture: patient?.picture ?? "",
//                                     name: patient?.name ?? "Unknown Patient",
//                                     diagnosis: record.diagnosis,
//                                     treatment: record.treatment,
//                                     medic: record.medic,
//                                     fromDate: record.fromDate,
//                                     untilDate: record.untilDate,
//                                     onTap: () {
//                                       // You can pass the combined data or just the patient info
//                                       if (patient != null) {
//                                         MyNavigator.goTo(
//                                           context,
//                                           Medication(
//                                             bufferedPatientInfo: patient,
//                                             recordID: record.recordID,
//                                             medicationModel: record,
//                                           ),
//                                         );
//                                       }
//                                     },
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         )
//                       : Expanded(child: SizedBox()),
//                 ],
//               );
//             } else {
//               return const Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/medical_services_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/medication_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/cards2.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication.dart';

class CombinedMedicalRecord {
  final MedicationModel medicalRecord;
  final PersonalInfo? personalInfo; // Nullable in case user is deleted

  CombinedMedicalRecord({required this.medicalRecord, this.personalInfo});
}

class MedicalHistory extends StatefulWidget {
  const MedicalHistory({super.key});

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {
  late double width;
  late double height;

  final List<String> statusChoices = const ["Not Yet Okay", "Is Now Okay"];
  String selectedStatusFilter = "";

  List<CombinedMedicalRecord> isNotYetOkayList = [];
  List<CombinedMedicalRecord> isNowOkayList = [];

  Future<List<CombinedMedicalRecord>> getCombinedRecords() async {
    // 1. Fetch BOTH collections in parallel (Faster than waiting for one, then the other)
    final results = await Future.wait([
      MyMedicalRepository.getAllRecords(),
      MyPersonalInfoRepository.getAllPersonalInfoRecords(),
    ]);

    // it will look like this:
    // List<CombinedMedicalRecord> combinedList = [List<MedicationModel>, List<PersonalInfo>];
    final medicalRecords = results[0] as List<MedicationModel>;
    final allPersonalInfo = results[1] as List<PersonalInfo>;

    // 2. OPTIMIZATION: Convert PersonalInfo List to a Map
    // Key: userID, Value: PersonalInfo object
    // This makes lookup instant!
    final Map<String, PersonalInfo> userMap = {
      for (var user in allPersonalInfo) user.userID: user,
    };

    // 3. Merge the data
    List<CombinedMedicalRecord> combinedList = [];

    for (var record in medicalRecords) {
      // Look up the patient info using the map (Instant)
      final patientInfo = userMap[record.patientID];

      combinedList.add(
        CombinedMedicalRecord(medicalRecord: record, personalInfo: patientInfo),
      );

      // Filter into appropriate list based on isNowOkay
      if (record.isNowOkay) {
        isNowOkayList.add(
          CombinedMedicalRecord(
            medicalRecord: record,
            personalInfo: patientInfo,
          ),
        );
      }
      // And those who are not yet okay
      else {
        isNotYetOkayList.add(
          CombinedMedicalRecord(
            medicalRecord: record,
            personalInfo: patientInfo,
          ),
        );
      }
    }

    // combinedList.sort(
    //   (a, b) => a.medicalRecord.fromDate.compareTo(b.medicalRecord.fromDate),
    // );

    isNotYetOkayList.sort((a, b) {
      return b.medicalRecord.fromDate.compareTo(a.medicalRecord.fromDate);
    });
    isNowOkayList.sort((a, b) {
      return b.medicalRecord.fromDate.compareTo(a.medicalRecord.fromDate);
    });

    return combinedList.reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    selectedStatusFilter = statusChoices[0];
  }

  @override
  Widget build(BuildContext context) {
    width = MyDimensionAdapter.getWidth(context);
    height = MyDimensionAdapter.getHeight(context) * 1.2;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 237, 250),
      body: Container(
        width: width,
        height: height,
        // color: Colors.amber.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SafeArea(
              child: MyCustAppBar(
                title: "Medical History",
                backButton: () => Navigator.pop(context),
                // ... rest of your app bar code
              ),
            ),
            SizedBox(height: 20),

            // MyDropdownMenuButton(
            //   items: statusChoices,
            //   initialValue: selectedStatusFilter,
            //   isLeadingIconVisible: false,
            //   onChanged: (value) {
            //     setState(() {
            //       isNotYetOkayList.clear();
            //       isNowOkayList.clear();
            //       selectedStatusFilter = value!;
            //     });
            //   },
            // ),
            notYetOkayAndOkayButtons(),
            SizedBox(height: 10),

            Container(
              height: height * 0.655,
              child: FutureBuilder(
                future: getCombinedRecords(), // Call the new merging function
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No records found"));
                    }
                    return returnSpecificWidget(selectedStatusFilter);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row notYetOkayAndOkayButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 7,
      children: [
        MyCustButton(
          buttonText: statusChoices[0],
          widthPercentage: 0.35,
          height: 35,
          borderRadius: 50,
          buttonTextFontSize: kDefaultFontSize - 2,
          buttonTextSpacing: 1.2,
          color: (selectedStatusFilter == statusChoices[0])
              ? Colors.blue.shade400
              : Colors.transparent,
          borderColor: (selectedStatusFilter == statusChoices[0])
              ? Colors.white
              : const Color.fromARGB(230, 170, 210, 243),
          buttonTextColor: (selectedStatusFilter == statusChoices[0])
              ? Colors.white
              : Colors.grey.shade700,
          enableShadow: (selectedStatusFilter == statusChoices[0])
              ? true
              : false,
          onTap: () {
            setState(() {
              isNotYetOkayList.clear();
              isNowOkayList.clear();
              selectedStatusFilter = statusChoices[0];
            });
          },
        ),
        MyCustButton(
          buttonText: statusChoices[1],
          widthPercentage: 0.35,
          height: 35,
          borderRadius: 50,
          buttonTextFontSize: kDefaultFontSize - 2,
          buttonTextSpacing: 1.2,
          color: (selectedStatusFilter == statusChoices[1])
              ? Colors.blue.shade400
              : Colors.transparent,
          borderColor: (selectedStatusFilter == statusChoices[1])
              ? Colors.white
              : const Color.fromARGB(230, 170, 210, 243),
          buttonTextColor: (selectedStatusFilter == statusChoices[1])
              ? Colors.white
              : Colors.grey.shade700,
          enableShadow: (selectedStatusFilter == statusChoices[1])
              ? true
              : false,
          onTap: () {
            setState(() {
              isNotYetOkayList.clear();
              isNowOkayList.clear();
              selectedStatusFilter = statusChoices[1];
            });
          },
        ),
      ],
    );
  }

  /// Returns a specific widget based on the data fetched from the databasbe.
  Widget returnSpecificWidget(String statusFilter) {
    // return early if either list is empty
    if (statusFilter == statusChoices[1] && isNowOkayList.isEmpty) {
      return Center(
        child: MyTextFormatter.p(
          text: "No records found.\nLet's hope they'll be okay soon.\n:(",
          fontsize: kDefaultFontSize + 2,
          maxLines: 3,
        ),
      );
    } else if (statusFilter == statusChoices[0] && isNotYetOkayList.isEmpty) {
      return Center(
        child: MyTextFormatter.p(
          text: "Thank God, everyone is okay!",
          fontsize: kDefaultFontSize + 4,
          maxLines: 2,
        ),
      );
    }

    // the return by default is the Is Now Okay list
    switch (statusFilter) {
      case "Is Now Okay":
        return Container(
          width: width,
          // height: height * 0.8,
          // color: Colors.green,
          padding: const EdgeInsets.only(
            // top: 0,
            // bottom: 56,
            left: 20,
            right: 20,
          ),
          child: RawScrollbar(
            thumbColor: Colors.blue.shade300,
            padding: EdgeInsets.only(
              right: -20,
              // top: (kDefaultFontSize * 2) + 10,
            ),
            thumbVisibility: true,
            trackVisibility: true,
            interactive: false, // prevents accidental touch scrolling
            thickness: 4,
            radius: Radius.circular(30),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              itemCount: isNowOkayList.length,
              itemBuilder: (context, index) {
                final combinedItem = isNowOkayList[index];
                final record = combinedItem.medicalRecord;
                final patient = combinedItem.personalInfo;

                // Display the data
                return MyCardInfoDisplayer2(
                  // Handle cases where patient info might be missing
                  profilePicture: patient?.picture ?? "",
                  name: patient?.name ?? "Unknown Patient",
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
                  onLongPress: () {
                    myAlertDialogue(
                      context: context,
                      alertTitle: "Confirm To Delete Record",
                      alertContent:
                          "\nAre you sure you want to delete ${patient?.name}'s record?",
                      onApprovalPressed: () {
                        MyMedicalRepository.deleteRecord(
                          recordID: record.recordID!,
                        );
                        // setState(() {
                        //   isNowOkayList.removeAt(index);
                        // });
                        Navigator.pop(context);
                        Navigator.pop(context);
                        MyNavigator.goTo(context, MedicalHistory());
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      default:
        return Container(
          width: width,
          // height: MyDimensionAdapter.getHeight(context) * 0.8,
          // color: Colors.green,
          padding: const EdgeInsets.only(
            // top: 0,
            // bottom: 56,
            left: 20,
            right: 20,
          ),
          child: RawScrollbar(
            thumbColor: Colors.blue.shade300,
            padding: EdgeInsets.only(
              right: -20,
              // top: (kDefaultFontSize * 2) + 10,
            ),
            thumbVisibility: true,
            trackVisibility: true,
            interactive: false, // prevents accidental touch scrolling
            thickness: 4,
            radius: Radius.circular(30),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              itemCount: isNotYetOkayList.length,
              itemBuilder: (context, index) {
                final combinedItem = isNotYetOkayList[index];
                final record = combinedItem.medicalRecord;
                final patient = combinedItem.personalInfo;

                // Display the data
                return MyCardInfoDisplayer2(
                  // Handle cases where patient info might be missing
                  profilePicture: patient?.picture ?? "",
                  name: patient?.name ?? "Unknown Patient",
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
          ),
        );
    }
  }
}
