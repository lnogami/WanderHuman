import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_active_persons_provider.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/cards3.dart';
import 'package:wanderhuman_app/view/components/gradients.dart';
import 'package:wanderhuman_app/view/components/last_element_padding.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/individual_tasks/individual_tasks_page.dart';

/// Summary record of all patients
class HomeLifePatientRecords extends StatefulWidget {
  const HomeLifePatientRecords({super.key});

  @override
  State<HomeLifePatientRecords> createState() => _HomeLifePatientRecordsState();
}

class _HomeLifePatientRecordsState extends State<HomeLifePatientRecords> {
  // final List<String> patientNames = const ["Hori", "Verti", "Diago", "Dimensio"];
  late MyHomeActivePersonsProvider activePersonsProvider;

  bool isLoading = true;
  List<PersonalInfo> patients = [];

  Future<void> getPatient() async {
    List<PersonalInfo> tempPatients = [];
    List<PersonalInfo> fetchedRecords =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();
    for (var person in fetchedRecords) {
      if (person.userType == "Patient") {
        tempPatients.add(person);
      }
    }

    tempPatients.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    patients = tempPatients;
    setState(() => isLoading = false);
  }

  /// TODO: create a logic where if one of the users open this page for the first time,
  ///       a condition will check if the current doc for the day is already written or not base on the condition if(docID == DateTime.now().toString())
  ///       If not yet, write the whole process autonomously base on HLPlanner. Then display the data.
  ///       else, do nothing, just display the data.
  // Future<List<HLPatientTaskModel>> getPatient() async {
  // }

  @override
  void initState() {
    super.initState();
    getPatient();
  }

  @override
  Widget build(BuildContext context) {
    activePersonsProvider = context.watch<MyHomeActivePersonsProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 237, 250),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          body(),
          appBar(context),
          // to have a fading visual effect at the bottom of the screen
          MyGradients.fadingBottomGradient(context),
        ],
      ),
    );
  }

  Positioned appBar(BuildContext context) {
    return Positioned(
      top: kToolbarHeight * 0.7,
      child: MyCustAppBar(
        title: "Manage Patient",
        backButton: () {
          Navigator.pop(context);
          // the 2 lines below are for debugging purposes only
          // Navigator.pop(context);
          // MyNavigator.goTo(context, HomeLifePatientRecords());
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
    );
  }

  Widget body() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (patients.isEmpty) {
      return Center(child: MyTextFormatter.p(text: "No Patient Found . ."));
    } else {
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
          itemCount: patients.length,
          itemBuilder: (context, index) {
            // if this is the first in the list, return a top padded CardInfoDisplayer
            if (index == 0) {
              return MyElementPadding.firstListElementPadding(
                padding: 10,
                widget: MyCardInfoDisplayer3(
                  personalInfo: patients[index],
                  batteryPercentage: activePersonsProvider
                      .devicesBattery[patients[index].userID],
                  onTap: () {
                    MyNavigator.goTo(
                      context,
                      IndividualTasks(patientInfo: patients[index]),
                    );
                  },
                ),
              );
            }
            // if the element is the last, return a bottom padded CardInfoDisplayer
            else if (patients.length == index + 1) {
              return MyElementPadding.lastListElementPadding(
                widget: MyCardInfoDisplayer3(
                  personalInfo: patients[index],
                  batteryPercentage: activePersonsProvider
                      .devicesBattery[patients[index].userID],
                  onTap: () {
                    MyNavigator.goTo(
                      context,
                      IndividualTasks(patientInfo: patients[index]),
                    );
                  },
                ),
              );
            } else {
              return MyCardInfoDisplayer3(
                personalInfo: patients[index],
                batteryPercentage: activePersonsProvider
                    .devicesBattery[patients[index].userID],
                onTap: () {
                  MyNavigator.goTo(
                    context,
                    IndividualTasks(patientInfo: patients[index]),
                  );
                },
              );
            }
          },
        ),
      );
    }
  }
}
