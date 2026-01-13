import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/cards3.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/individual_tasks/individual_tasks_page.dart';

/// Summary record of all patients
class HomeLifePatientRecords extends StatelessWidget {
  const HomeLifePatientRecords({super.key});
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

  /// TODO: create a logic where if one of the users open this page for the first time,
  ///       a condition will check if the current doc for the day is already written or not base on the condition if(docID == DateTime.now().toString())
  ///       If not yet, write the whole process autonomously base on HLPlanner. Then display the data.
  ///       else, do nothing, just display the data.
  // Future<List<HLPatientTaskModel>> getPatient() async {
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 237, 250),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
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
                      return MyCardInfoDisplayer3(
                        personalInfo: snapshot.data![index],
                        // profilePicture: snapshot.data![index].picture,
                        // name: snapshot.data![index].name,
                        // age: "${snapshot.data![index].age} years old",
                        // contactNumber: snapshot.data![index].contactNumber,
                        // emailAdd: snapshot.data![index].email,
                        onTap: () {
                          MyNavigator.goTo(
                            context,
                            // ViewPatientForm(
                            //   patientPersonalInfo: snapshot.data![index],
                            // ),
                            IndividualTasks(patientInfo: snapshot.data![index]),
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

          Positioned(
            top: kToolbarHeight * 0.7,
            child: MyCustAppBar(
              title: "Manage Patient",
              backButton: () {
                Navigator.pop(context);
                Navigator.pop(context);
                MyNavigator.goTo(context, HomeLifePatientRecords());
              },
              actionButtons: [
                // IconButton(
                //   highlightColor: Colors.blue.shade100,
                //   onPressed: () async {
                //     // Navigator.pop(context);
                //     MyNavigator.goTo(
                //       // ignore: use_build_context_synchronously
                //       context,
                //       AddPatientForm(
                //         // bufferedpatientNames: await getPatient()
                //       ),
                //     );
                //   },
                //   icon: Icon(
                //     Icons.person_add_alt_1_rounded,
                //     color: Colors.blue.shade400,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
