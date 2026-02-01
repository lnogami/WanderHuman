import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/option_container.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication.dart';
import 'package:wanderhuman_app/view/userRolesUI/medical_services/medication_history.dart';

class MedicalPrivilege extends StatelessWidget {
  const MedicalPrivilege({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 10),
              optionsContainer(
                context,
                Icons.folder_copy_outlined,
                "Med History",
                onTap: () {
                  MyNavigator.goTo(context, MedicalHistory());
                },
              ),
              SizedBox(height: 10),
              optionsContainer(
                context,
                Icons.medication_outlined,
                "Medication",
                onTap: () {
                  MyNavigator.goTo(context, Medication());
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
