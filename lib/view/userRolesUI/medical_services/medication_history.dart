import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/medical_services_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/medication_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/cards2.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication.dart';

class CombinedMedicalRecord {
  final MedicationModel medicalRecord;
  final PersonalInfo? personalInfo; // Nullable in case user is deleted

  CombinedMedicalRecord({required this.medicalRecord, this.personalInfo});
}

class MedicalHistory extends StatelessWidget {
  const MedicalHistory({super.key});

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
    }

    return combinedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 237, 250),
      body: Stack(
        children: [
          FutureBuilder<List<CombinedMedicalRecord>>(
            future: getCombinedRecords(), // Call the new merging function
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No records found"));
                }
                return Container(
                  width: MyDimensionAdapter.getWidth(context),
                  height: MyDimensionAdapter.getHeight(context),
                  padding: const EdgeInsets.only(
                    top: kToolbarHeight + 20,
                    bottom: 56,
                    left: 20,
                    right: 20,
                  ),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final combinedItem = snapshot.data![index];
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
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          // ... Your existing AppBar Positioned widget ...
          Positioned(
            // top: kToolbarHeight * 0.7,
            child: MyCustAppBar(
              title: "Medical History",
              backButton: () => Navigator.pop(context),
              // ... rest of your app bar code
            ),
          ),
        ],
      ),
    );
  }
}
