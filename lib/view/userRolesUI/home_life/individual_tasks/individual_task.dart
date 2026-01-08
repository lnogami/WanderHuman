import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/individual_tasks/individual_task_card.dart';

class IndividualTasks extends StatefulWidget {
  final PersonalInfo patientInfo;
  const IndividualTasks({super.key, required this.patientInfo});

  @override
  State<IndividualTasks> createState() => _IndividualTasksState();
}

class _IndividualTasksState extends State<IndividualTasks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColorPalette.formColor,
      body: SafeArea(
        child: Container(
          width: MyDimensionAdapter.getWidth(context),
          child: Column(
            children: [
              MyCustAppBar(
                title: "Tasks for ${widget.patientInfo.name}",
                backButton: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  MyNavigator.goTo(
                    context,
                    IndividualTasks(patientInfo: widget.patientInfo),
                  );
                },
              ),
              SizedBox(height: 30),

              IndividualTaskCard(),
              SizedBox(height: 10),
              IndividualTaskCard(),
            ],
          ),
        ),
      ),
    );
  }
}
