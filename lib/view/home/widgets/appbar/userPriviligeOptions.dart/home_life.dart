import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/option_container.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/individual_tasks/patient_records.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/planner/manage_tasks.dart';

class HomeLifePrivilege extends StatelessWidget {
  const HomeLifePrivilege({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Medical Service exclusive options
        (MyPersonalInfoRepository.getUserType() == "Home Life")
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(height: 10),
                  optionsContainer(
                    context,
                    Icons.folder_copy_outlined,
                    "Records",
                    onTap: () {
                      MyNavigator.goTo(context, HomeLifePatientRecords());
                    },
                  ),
                  SizedBox(height: 10),
                  optionsContainer(
                    context,
                    Icons.note_add_outlined,
                    "Planner",
                    onTap: () {
                      MyNavigator.goTo(context, HomeLifeManageTask());
                    },
                  ),
                  SizedBox(height: 10),
                ],
              )
            : SizedBox(height: 0),
      ],
    );
  }
}
