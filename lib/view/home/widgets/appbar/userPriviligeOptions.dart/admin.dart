import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/components/my_page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/option_container.dart';
import 'package:wanderhuman_app/view/home/widgets/map/patient_simulator/patient_simulator_container.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/manage_staff.dart';

class AdminPrivilege extends StatelessWidget {
  const AdminPrivilege({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 5),
              // Simulate - only acts as a temporary device to test patient features
              //          - Might not be available in the final release.
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
              SizedBox(width: 5),
              optionsContainer(
                context,
                Icons.add_outlined,
                fontSize: 13,
                "Manage Staff",
                onTap: () {
                  // showMyAnimatedSnackBar(
                  //   context: context,
                  //   dataToDisplay: "Manage Staff Clicked",
                  // );

                  // Navigator.of(context).push(
                  //   MaterialPageRoute(builder: (context) => ManageStaff()),
                  // );
                  MyNavigator.goTo(context, ManageStaff());
                },
              ),
              SizedBox(width: 5),
            ],
          ),
        ],
      ),
    );
  }
}
