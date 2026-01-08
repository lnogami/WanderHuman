import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/home_life_models/hl_planner_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/planner/planner.dart';

class TaskCard extends StatefulWidget {
  // final HomeLifePlannerModel task;
  // const TaskCard({super.key, required this.task});

  const TaskCard({super.key});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.8,
      height: MyDimensionAdapter.getHeight(context) * 0.12,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      decoration: BoxDecoration(
        // color: Colors.blue.shade100,
        color: Colors.white70,
        border: Border.all(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(7)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(56, 96, 181, 252),
            blurRadius: 4,
            // spreadRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          upperCardPart(context),
          // SizedBox(height: 5),
          SizedBox(height: 5),
          Expanded(
            child: Container(
              width: MyDimensionAdapter.getWidth(context) * 0.8,
              // color: Colors.blue.shade50,
              child: Text("Hello"),
            ),
          ),
        ],
      ),
    );
  }

  Row upperCardPart(BuildContext context) {
    return Row(
      children: [
        MyTextFormatter.h3(text: "Task Name", fontsize: kDefaultFontSize + 2),
        Spacer(),
        MyLine(length: MyDimensionAdapter.getWidth(context) * 0.07),
        Column(
          children: [
            MyTextFormatter.p(text: "Every", fontsize: kDefaultFontSize - 4),
            MyTextFormatter.p(text: "Wed"),
          ],
        ),
        MyLine(length: MyDimensionAdapter.getWidth(context) * 0.07),
        Column(
          children: [
            MyTextFormatter.p(text: "Every", fontsize: kDefaultFontSize - 4),
            MyTextFormatter.p(text: "Wed"),
          ],
        ),
      ],
    );
  }
}
