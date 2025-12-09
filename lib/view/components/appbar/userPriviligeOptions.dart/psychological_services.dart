import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/firebase_services.dart';
import 'package:wanderhuman_app/utilities/properties/universal_sizes.dart';
import 'package:wanderhuman_app/view/add_patient_form/add_patient_form.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/option_container.dart';
import 'package:wanderhuman_app/view/home/widgets/map/patient_simulator/patient_simulator_container.dart';

class PsychologicalPrivilege extends StatelessWidget {
  const PsychologicalPrivilege({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // admin exclusive options
          (MyFirebaseServices.getUserType() == "admin")
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(height: 10),
                    optionsContainer(
                      context,
                      Icons.person_pin_circle_outlined,
                      bgColor: Colors.green[300]!,
                      "Simulate",
                      onTap: () {
                        //
                        // Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => PatientSimulatorContainer(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    optionsContainer(
                      context,
                      Icons.add_outlined,
                      "Placeholder",
                      onTap: () {
                        showMyAnimatedSnackBar(
                          context: context,
                          dataToDisplay: "Admin Privilege",
                        );
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                )
              : SizedBox(height: 0),

          SizedBox(height: MySizes.buttonsHorizontalGap),

          // buttons/options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 10),
              optionsContainer(
                context,
                Icons.person_outline_rounded,
                "Acount",
                onTap: () {
                  MyFirebaseServices.getAllPersonalInfoRecords()
                      .then((value) {
                        showMyAnimatedSnackBar(
                          context: context,
                          dataToDisplay: "${value.length}",
                        );
                      })
                      .catchError((error) {
                        showMyAnimatedSnackBar(
                          context: context,
                          dataToDisplay: error.toString(),
                        );
                      });
                },
              ),
              SizedBox(height: 10),
              optionsContainer(
                context,
                Icons.add_outlined,
                "Add Patient",
                onTap: () {
                  AddPatientForm();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPatientForm()),
                  );
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
