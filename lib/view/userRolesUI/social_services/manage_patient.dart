import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/cards.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/social_services/add_patient.dart';
import 'package:wanderhuman_app/view/userRolesUI/social_services/view_patient_form.dart';

/// Summary record of all patients
class PatientRecords extends StatelessWidget {
  const PatientRecords({super.key});
  // final List<String> patientNames = const ["Hori", "Verti", "Diago", "Dimensio"];

  Future<List<PersonalInfo>> getPatient() async {
    List<PersonalInfo> patients = [];
    List<PersonalInfo> fetchedRecords =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();
    for (var person in fetchedRecords) {
      if (person.userType == "Patient") {
        patients.add(person);
      }
    }

    return patients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 237, 250),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Body
          FutureBuilder(
            future: getPatient(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  width: MyDimensionAdapter.getWidth(context),
                  height: MyDimensionAdapter.getHeight(context),
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + 20,
                    bottom: 56,
                    left: 20,
                    right: 20,
                  ),
                  // color: const Color.fromARGB(255, 227, 237, 250),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return MyCardInfoDisplayer(
                        profilePicture: snapshot.data![index].picture,
                        name: snapshot.data![index].name,
                        role: "${snapshot.data![index].age} years old",
                        contactNumber: snapshot.data![index].contactNumber,
                        emailAdd: snapshot.data![index].email,
                        onTap: () {
                          // Navigator.pop(context);
                          MyNavigator.goTo(
                            context,
                            ViewPatientForm(
                              patientPersonalInfo: snapshot.data![index],
                            ),
                          );
                        },
                        onLongPress: () {
                          myAlertDialogue(
                            context: context,
                            alertTitle: "Confirm To Delete Record",
                            alertContent:
                                "\nAre you sure you want to delete ${snapshot.data![index].name}'s record?",
                            onApprovalButtonText: "Yes, delete it",
                            onApprovalPressed: () {
                              MyPersonalInfoRepository.deletePersonalInfo(
                                userID: snapshot.data![index].userID,
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                              MyNavigator.goTo(context, PatientRecords());

                              showMyAnimatedSnackBar(
                                context: context,
                                dataToDisplay:
                                    "Successfully deleted ${snapshot.data![index].name}'s record.}",
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),

          // Appbar
          Positioned(
            // top: kToolbarHeight * 0.7,
            child: SafeArea(
              child: MyCustAppBar(
                title: "Manage Patient",
                backButton: () {
                  Navigator.pop(context);
                },
                actionButtons: [
                  IconButton(
                    highlightColor: Colors.blue.shade100,
                    onPressed: () async {
                      // Navigator.pop(context);
                      MyNavigator.goTo(
                        // ignore: use_build_context_synchronously
                        context,
                        AddPatientForm(
                          // bufferedpatientNames: await getPatient()
                          isFromManagePatientPage: true,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
