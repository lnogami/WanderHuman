import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/utilities/properties/universal_sizes.dart';
import 'package:wanderhuman_app/view/components/my_page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/option_container.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication_history.dart';

class MedicalPrivilege extends StatelessWidget {
  const MedicalPrivilege({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // admin exclusive options
          (MyPersonalInfoRepository.getUserType() == "Medical Service")
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(height: 10),
                    optionsContainer(
                      context,
                      Icons.person_pin_circle_outlined,
                      "Med History",
                      onTap: () {
                        MyNavigator.goTo(context, MedicalHistory());
                      },
                    ),
                    SizedBox(height: 10),
                    optionsContainer(
                      context,
                      Icons.add_outlined,
                      "Medication",
                      onTap: () {
                        MyNavigator.goTo(context, Medication());
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
                  MyPersonalInfoRepository.getAllPersonalInfoRecords()
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
                  // AddPatientForm();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => AddPatientForm()),
                  // );
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
