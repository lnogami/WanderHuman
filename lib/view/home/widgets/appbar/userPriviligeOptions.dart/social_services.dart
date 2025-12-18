import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/components/my_page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/option_container.dart';
import 'package:wanderhuman_app/view/userRolesUI/social_services/add_patient.dart';
import 'package:wanderhuman_app/view/userRolesUI/social_services/patient_records.dart';

class SocialServicesPrivilege extends StatelessWidget {
  const SocialServicesPrivilege({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.amber,
      child: Column(
        children: [
          // buttons/options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 10),
              optionsContainer(
                context,
                Icons.person_outline_rounded,
                "Records",
                onTap: () {
                  Navigator.pop(context);
                  MyNavigator.goTo(context, PatientRecords());
                },
              ),
              SizedBox(height: 10),
              optionsContainer(
                context,
                Icons.add_outlined,
                "Add Patient",
                onTap: () {
                  Navigator.pop(context);
                  MyNavigator.goTo(context, AddPatientForm());
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
