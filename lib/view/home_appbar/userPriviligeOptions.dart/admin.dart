import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/option_container.dart';
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
                bgColor: const Color.fromARGB(99, 216, 255, 219),
                "Simulate",
                onTap: () {
                  // Will uncomment later on
                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(
                  //     builder: (context) => PatientSimulatorContainer(),
                  //   ),
                  // );

                  // tempoary code
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay:
                        "Sorry, this functionality is offlimits for now.",
                  );
                },
              ),
              SizedBox(width: 5),
              optionsContainer(
                context,
                Icons.folder_copy_outlined,
                fontSize: 13,
                "Manage",
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
